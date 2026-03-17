import { prisma } from '../lib/prisma.js';
import { neo4jDriver } from '../lib/neo4j.js';

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
