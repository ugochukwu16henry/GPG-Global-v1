import { prisma } from '../lib/prisma.js';
import { neo4jDriver } from '../lib/neo4j.js';
import { boundaryService } from './boundaryService.js';

export const missionSearchService = {
  async suggestMissions(query: string) {
    if (!query.trim()) {
      return [];
    }

    const missions = await prisma.mission.findMany({
      where: {
        missionName: {
          contains: query,
          mode: 'insensitive'
        }
      },
      take: 10,
      orderBy: { missionName: 'asc' }
    });

    return missions;
  },

  async missionPeerMatch(missionId: string) {
    const count = await prisma.user.count({
      where: {
        missionId
      }
    });

    return {
      missionId,
      count,
      summary: `We found ${count} other people in the app from this mission.`
    };
  },

  async suggestedMissionPeersForUser(userId: string) {
    const currentUser = await prisma.user.findUnique({
      where: { id: userId },
      select: { missionId: true }
    });

    if (!currentUser?.missionId) {
      return [];
    }

    const blockedIds = await boundaryService.blockedUserIdsForViewer(userId);

    return prisma.user.findMany({
      where: {
        missionId: currentUser.missionId,
        id: {
          notIn: [userId, ...blockedIds],
        },
      },
      select: {
        id: true,
        displayName: true,
        lga: true,
        state: true
      },
      take: 30,
      orderBy: { createdAt: 'desc' }
    });
  },

  async pathwayPeerMatch({
    academicFocus,
    state,
    lga,
    viewerUserId,
  }: {
    academicFocus: string;
    state?: string;
    lga?: string;
    viewerUserId?: string;
  }) {
    const blockedIds = viewerUserId == null
        ? new Set<string>()
        : await boundaryService.blockedUserIdsForViewer(viewerUserId);

    const count = await prisma.user.count({
      where: {
        id: blockedIds.size === 0
            ? undefined
            : {
                notIn: Array.from(blockedIds),
              },
        isDegree: true,
        academicFocus: {
          equals: academicFocus,
          mode: 'insensitive'
        },
        state: state
            ? {
                equals: state,
                mode: 'insensitive'
              }
            : undefined,
        lga: lga
            ? {
                equals: lga,
                mode: 'insensitive'
              }
            : undefined
      }
    });

    return `Connect with ${count} others in your region also studying ${academicFocus}.`;
  },

  async missionPeerGraphQuery(missionCode: string, fromYear?: number, toYear?: number) {
    const session = neo4jDriver.session();
    try {
      const result = await session.run(
        `
        MATCH (u:User)-[:SERVED_IN]->(m:Mission {missionCode: $missionCode})
        WHERE ($fromYear IS NULL OR u.serviceStartYear >= $fromYear)
          AND ($toYear IS NULL OR u.serviceEndYear <= $toYear)
        RETURN u.id AS userId, u.displayName AS displayName
        LIMIT 50
        `,
        {
          missionCode,
          fromYear: fromYear ?? null,
          toYear: toYear ?? null
        }
      );

      return result.records.map((record) => ({
        userId: record.get('userId') as string,
        displayName: record.get('displayName') as string
      }));
    } finally {
      await session.close();
    }
  }
};
