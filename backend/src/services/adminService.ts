import { prisma } from '../lib/prisma.js';

export const adminService = {
  async suspendUser({
    adminUserId,
    userId,
    hours,
    reason,
  }: {
    adminUserId: string;
    userId: string;
    hours: number;
    reason?: string;
  }) {
    const suspendedUntil = new Date(Date.now() + hours * 60 * 60 * 1000);
    await prisma.userDisciplineState.upsert({
      where: { userId },
      create: {
        userId,
        suspendedUntil,
      },
      update: {
        suspendedUntil,
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: 'USER_SUSPENDED',
        targetUserId: userId,
        targetEntity: 'USER',
        reason,
        metadata: { hours, suspendedUntil: suspendedUntil.toISOString() },
      },
    });
  },

  async shadowBanUser({
    adminUserId,
    userId,
    reason,
  }: {
    adminUserId: string;
    userId: string;
    reason?: string;
  }) {
    await prisma.userDisciplineState.upsert({
      where: { userId },
      create: {
        userId,
        isShadowBanned: true,
      },
      update: {
        isShadowBanned: true,
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: 'USER_SHADOW_BANNED',
        targetUserId: userId,
        targetEntity: 'USER',
        reason,
      },
    });
  },

  async deleteBanUser({
    adminUserId,
    userId,
    phone,
    deviceId,
    reason,
  }: {
    adminUserId: string;
    userId: string;
    phone?: string;
    deviceId?: string;
    reason?: string;
  }) {
    await prisma.userDisciplineState.upsert({
      where: { userId },
      create: {
        userId,
        isDeletedBanned: true,
      },
      update: {
        isDeletedBanned: true,
      },
    });

    if (phone != null || deviceId != null) {
      await prisma.bannedIdentity.create({
        data: {
          phone,
          deviceId,
          reason: reason ?? 'Administrative permanent ban.',
          bannedByAdminId: adminUserId,
        },
      });
    }

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: 'USER_DELETE_BANNED',
        targetUserId: userId,
        targetEntity: 'USER',
        reason,
      },
    });
  },

  async approveMarketplace({
    adminUserId,
    userId,
    certificateTitle,
  }: {
    adminUserId: string;
    userId: string;
    certificateTitle: string;
  }) {
    await prisma.marketplaceApproval.create({
      data: {
        userId,
        certificateTitle,
        status: 'APPROVED',
        reviewedByAdminId: adminUserId,
        reviewedAt: new Date(),
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: 'MARKETPLACE_APPROVED',
        targetUserId: userId,
        targetEntity: 'MARKETPLACE_APPROVAL',
      },
    });
  },

  async grantMeritMarketplace({
    adminUserId,
    userId,
    certificateTitle,
    reason,
  }: {
    adminUserId: string;
    userId: string;
    certificateTitle: string;
    reason: string;
  }) {
    await prisma.marketplaceApproval.create({
      data: {
        userId,
        certificateTitle,
        status: 'MERIT_GRANTED',
        reviewedByAdminId: adminUserId,
        reviewedAt: new Date(),
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: 'MERIT_ACCESS_GRANTED',
        targetUserId: userId,
        targetEntity: 'MARKETPLACE_APPROVAL',
        reason,
      },
    });
  },

  async setTalentFeatured({
    adminUserId,
    userId,
    isFeatured,
  }: {
    adminUserId: string;
    userId: string;
    isFeatured: boolean;
  }) {
    await prisma.talentFeature.upsert({
      where: { userId },
      create: {
        userId,
        isFeatured,
        updatedByAdminId: adminUserId,
      },
      update: {
        isFeatured,
        updatedByAdminId: adminUserId,
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: isFeatured ? 'TALENT_FEATURED' : 'TALENT_UNFEATURED',
        targetUserId: userId,
        targetEntity: 'TALENT_FEATURE',
      },
    });
  },

  async reviewAd({
    adminUserId,
    adId,
    targeting,
    approved,
    note,
  }: {
    adminUserId: string;
    adId: string;
    targeting: string;
    approved: boolean;
    note?: string;
  }) {
    await prisma.adModerationReview.upsert({
      where: { externalAdId: adId },
      create: {
        externalAdId: adId,
        targeting,
        note,
        status: approved ? 'APPROVED' : 'REJECTED',
        reviewedByAdminId: adminUserId,
        reviewedAt: new Date(),
      },
      update: {
        targeting,
        note,
        status: approved ? 'APPROVED' : 'REJECTED',
        reviewedByAdminId: adminUserId,
        reviewedAt: new Date(),
      },
    });

    await prisma.adminActionLog.create({
      data: {
        adminUserId,
        action: approved ? 'AD_APPROVED' : 'AD_REJECTED',
        targetEntity: 'AD_REVIEW',
        reason: note,
        metadata: { adId, targeting },
      },
    });
  },

  async recentLogs(limit: number) {
    return prisma.adminActionLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },

  async marketplaceApprovals(limit: number) {
    return prisma.marketplaceApproval.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },

  async talentFeatures(limit: number) {
    return prisma.talentFeature.findMany({
      orderBy: { updatedAt: 'desc' },
      take: limit,
    });
  },

  async adModerationReviews(limit: number) {
    return prisma.adModerationReview.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },

  async userDisciplineStates(limit: number) {
    return prisma.userDisciplineState.findMany({
      orderBy: { updatedAt: 'desc' },
      take: limit,
    });
  },

  async bannedIdentities(limit: number) {
    return prisma.bannedIdentity.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },
};
