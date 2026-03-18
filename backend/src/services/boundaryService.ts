import { BlockReasonCode, ReportReasonCode } from '@prisma/client';
import { prisma } from '../lib/prisma.js';

const REBLOCK_COOLDOWN_HOURS = 24;

export const boundaryService = {
  async blockUser({
    blockerId,
    blockedId,
    reasonCode,
  }: {
    blockerId: string;
    blockedId: string;
    reasonCode?: BlockReasonCode;
  }) {
    if (blockerId == blockedId) {
      throw new Error('Cannot block yourself.');
    }

    const existing = await prisma.blockRelation.findUnique({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
    });

    if (existing?.isActive == true) {
      return existing;
    }

    if (existing?.unblockedAt != null) {
      const nextAllowed = new Date(existing.unblockedAt.getTime() + REBLOCK_COOLDOWN_HOURS * 60 * 60 * 1000);
      if (Date.now() < nextAllowed.getTime()) {
        throw new Error('Re-block cooldown active. Wait 24 hours before blocking this user again.');
      }
    }

    const relation = await prisma.blockRelation.upsert({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
      create: {
        blockerId,
        blockedId,
        reasonCode,
      },
      update: {
        isActive: true,
        reasonCode,
        unblockedAt: null,
      },
    });

    const blockersLast24h = await prisma.blockRelation.count({
      where: {
        blockedId,
        isActive: true,
        createdAt: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000),
        },
      },
    });

    if (blockersLast24h >= 50) {
      await prisma.highBlockAlert.create({
        data: {
          targetUserId: blockedId,
          blockersLast24h,
        },
      });
    }

    return relation;
  },

  async unblockUser({ blockerId, blockedId }: { blockerId: string; blockedId: string }) {
    return prisma.blockRelation.updateMany({
      where: {
        blockerId,
        blockedId,
        isActive: true,
      },
      data: {
        isActive: false,
        unblockedAt: new Date(),
      },
    });
  },

  async blockedAccounts(blockerId: string) {
    return prisma.blockRelation.findMany({
      where: {
        blockerId,
        isActive: true,
      },
      include: {
        blocked: {
          select: {
            id: true,
            displayName: true,
            profilePictureUrl: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  },

  async muteUser({ muterId, mutedId }: { muterId: string; mutedId: string }) {
    return prisma.muteRelation.upsert({
      where: {
        muterId_mutedId: {
          muterId,
          mutedId,
        },
      },
      create: {
        muterId,
        mutedId,
        isActive: true,
      },
      update: {
        isActive: true,
      },
    });
  },

  async unmuteUser({ muterId, mutedId }: { muterId: string; mutedId: string }) {
    return prisma.muteRelation.updateMany({
      where: {
        muterId,
        mutedId,
        isActive: true,
      },
      data: {
        isActive: false,
      },
    });
  },

  async reportUser({
    reporterId,
    reportedId,
    reasonCode,
    detail,
  }: {
    reporterId: string;
    reportedId: string;
    reasonCode: ReportReasonCode;
    detail?: string;
  }) {
    return prisma.userReport.create({
      data: {
        reporterId,
        reportedId,
        reasonCode,
        detail,
      },
    });
  },

  async blockedUserIdsForViewer(viewerId: string) {
    const relations = await prisma.blockRelation.findMany({
      where: {
        isActive: true,
        OR: [{ blockerId: viewerId }, { blockedId: viewerId }],
      },
      select: {
        blockerId: true,
        blockedId: true,
      },
    });

    const ids = new Set<string>();
    for (const row of relations) {
      if (row.blockerId == viewerId) {
        ids.add(row.blockedId);
      } else if (row.blockedId == viewerId) {
        ids.add(row.blockerId);
      }
    }
    return ids;
  },
};
