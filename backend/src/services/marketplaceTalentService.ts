import { prisma } from '../lib/prisma.js';

function approvedStatusClause(): any {
  return {
    OR: [{ status: 'APPROVED' }, { status: 'MERIT_GRANTED' }],
  };
}

async function ensureVendorApproved(userId: string) {
  const approval = await prisma.marketplaceApproval.findFirst({
    where: {
      userId,
      ...approvedStatusClause(),
    },
    orderBy: { createdAt: 'desc' },
  });

  if (!approval) {
    throw new Error('Vendor Studio is available only after admin approval.');
  }

  return approval;
}

export const marketplaceTalentService = {
  async vendorStudio(userId: string) {
    await ensureVendorApproved(userId);

    const studio = await prisma.vendorStudio.findUnique({
      where: { userId },
      include: {
        user: true,
        servicePricing: {
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!studio) {
      return null;
    }

    return studio;
  },

  async upsertVendorStudio({
    userId,
    category,
    profilePictureUrl,
    profileReelUrl,
    galleryUrls,
  }: {
    userId: string;
    category: string;
    profilePictureUrl?: string;
    profileReelUrl?: string;
    galleryUrls?: string[];
  }) {
    await ensureVendorApproved(userId);

    const studio = await prisma.vendorStudio.upsert({
      where: { userId },
      create: {
        userId,
        category,
        profilePictureUrl,
        profileReelUrl,
        galleryUrls: galleryUrls ?? [],
      },
      update: {
        category,
        profilePictureUrl,
        profileReelUrl,
        galleryUrls: galleryUrls ?? undefined,
      },
      include: {
        user: true,
        servicePricing: {
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    return studio;
  },

  async upsertVendorServicePricing({
    userId,
    serviceName,
    pricingMode,
    amountUsd,
    currency,
    unitLabel,
  }: {
    userId: string;
    serviceName: string;
    pricingMode: 'FIXED' | 'STARTING_FROM';
    amountUsd: number;
    currency?: string;
    unitLabel?: string;
  }) {
    await ensureVendorApproved(userId);

    return prisma.vendorServicePricing.create({
      data: {
        userId,
        serviceName,
        pricingMode,
        amountUsd,
        currency: currency ?? 'USD',
        unitLabel,
      },
    });
  },

  async marketplaceDirectory({
    search,
    country,
    category,
    limit,
  }: {
    search?: string;
    country?: string;
    category?: string;
    limit: number;
  }) {
    return prisma.vendorStudio.findMany({
      where: {
        category: category
          ? {
              contains: category,
              mode: 'insensitive',
            }
          : undefined,
        user: {
          country: country ?? undefined,
          displayName: search
            ? {
                contains: search,
                mode: 'insensitive',
              }
            : undefined,
          marketplaceApprovalEntries: {
            some: approvedStatusClause(),
          },
        },
      },
      include: {
        user: true,
        servicePricing: {
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { updatedAt: 'desc' },
      take: limit,
    });
  },

  async createPromotedAd({
    userId,
    mediaUrl,
    headline,
    reachLevel,
    targetCountry,
    targetStates,
    targetCountries,
    startDate,
    endDate,
  }: {
    userId: string;
    mediaUrl: string;
    headline?: string;
    reachLevel: 'CURRENT_STATE' | 'SELECTED_STATES' | 'GLOBAL_COUNTRIES';
    targetCountry?: string;
    targetStates?: string[];
    targetCountries?: string[];
    startDate: string;
    endDate: string;
  }) {
    await ensureVendorApproved(userId);

    const parsedStart = new Date(startDate);
    const parsedEnd = new Date(endDate);
    if (Number.isNaN(parsedStart.getTime()) || Number.isNaN(parsedEnd.getTime())) {
      throw new Error('Invalid promoted ad date range.');
    }
    if (parsedEnd <= parsedStart) {
      throw new Error('Promoted ad end date must be after start date.');
    }

    return prisma.promotedAd.create({
      data: {
        userId,
        mediaUrl,
        headline,
        reachLevel,
        targetCountry,
        targetStates: targetStates ?? [],
        targetCountries: targetCountries ?? [],
        startDate: parsedStart,
        endDate: parsedEnd,
      },
    });
  },

  async deactivatePromotedAd({
    userId,
    promotedAdId,
  }: {
    userId: string;
    promotedAdId: string;
  }) {
    const row = await prisma.promotedAd.findUnique({ where: { id: promotedAdId } });
    if (!row || row.userId !== userId) {
      throw new Error('Promoted ad not found for this vendor.');
    }

    await prisma.promotedAd.update({
      where: { id: promotedAdId },
      data: { isActive: false },
    });

    return true;
  },

  async myPromotedAds(userId: string, limit: number) {
    await ensureVendorApproved(userId);
    return prisma.promotedAd.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },

  async homeTalentBanners(userId: string, limit: number) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { country: true },
    });

    if (!user?.country) {
      return [];
    }

    return prisma.talentBroadcast.findMany({
      where: {
        country: user.country,
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  },
};
