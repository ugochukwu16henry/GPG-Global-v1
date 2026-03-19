import { prisma } from '../lib/prisma.js';
import { moderationService } from './moderationService.js';
import { boundaryService } from './boundaryService.js';

export const feedService = {
  async createPost({
    authorUserId,
    textBody,
    mediaUrl,
    skillHighlight,
    videoCodec,
    sourceResolution,
    availableResolutions,
    captions,
    moderationTags,
    isHiddenPendingReview,
    copyrightBlocked,
  }: {
    authorUserId: string;
    textBody?: string;
    mediaUrl?: string;
    skillHighlight?: string;
    videoCodec?: string;
    sourceResolution?: string;
    availableResolutions?: string[];
    captions?: string[];
    moderationTags?: string[];
    isHiddenPendingReview?: boolean;
    copyrightBlocked?: boolean;
  }) {
    return prisma.post.create({
      data: {
        authorUserId,
        textBody,
        mediaUrl,
        skillHighlight,
        videoCodec,
        sourceResolution,
        availableResolutions,
        captions,
        moderationTags,
        isHiddenPendingReview,
        copyrightBlocked,
      },
    });
  },

  async reactToPost({
    postId,
    userId,
    kind,
  }: {
    postId: string;
    userId: string;
    kind: 'WARM_HEART' | 'PRAYER_HANDS';
  }) {
    return prisma.postReaction.upsert({
      where: {
        postId_userId: {
          postId,
          userId,
        },
      },
      create: {
        postId,
        userId,
        kind,
      },
      update: {
        kind,
      },
    });
  },

  async resharePost({
    postId,
    userId,
    targetGroupId,
  }: {
    postId: string;
    userId: string;
    targetGroupId?: string;
  }) {
    return prisma.postReshare.create({
      data: {
        postId,
        userId,
        targetGroupId,
      },
    });
  },

  async addComment({
    postId,
    userId,
    body,
    timestampSeconds,
  }: {
    postId: string;
    userId: string;
    body: string;
    timestampSeconds?: number;
  }) {
    const moderation = await moderationService.moderateMessage(body);
    if (moderation.violates && moderation.severity !== 'LOW') {
      throw new Error('Comment blocked by wholesome moderation guardrail.');
    }

    return prisma.postComment.create({
      data: {
        postId,
        userId,
        body,
        timestampSeconds,
      },
    });
  },

  async feed(limit: number, viewerUserId?: string) {
    const blockedIds = viewerUserId == null
      ? new Set<string>()
      : await boundaryService.blockedUserIdsForViewer(viewerUserId);

    const viewer = viewerUserId == null
      ? null
      : await prisma.user.findUnique({
          where: { id: viewerUserId },
          select: { country: true, state: true },
        });

    const rows = await prisma.post.findMany({
      take: limit,
      where: {
        isHiddenPendingReview: false,
        copyrightBlocked: false,
        authorUserId: blockedIds.size == 0
            ? undefined
            : {
                notIn: Array.from(blockedIds),
              },
      },
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          select: {
            id: true,
            displayName: true,
            profilePictureUrl: true,
          },
        },
        reactions: true,
        comments: {
          include: {
            user: {
              select: {
                id: true,
                displayName: true,
              },
            },
          },
        },
        reshares: true,
      },
    });

    const promoted = viewer?.country
      ? await prisma.promotedAd.findMany({
          where: {
            isActive: true,
            startDate: { lte: new Date() },
            endDate: { gte: new Date() },
            userId: blockedIds.size == 0 ? undefined : { notIn: Array.from(blockedIds) },
            user: {
              marketplaceApprovalEntries: {
                some: {
                  OR: [{ status: 'APPROVED' }, { status: 'MERIT_GRANTED' }],
                },
              },
            },
          },
          include: {
            user: {
              select: {
                id: true,
                displayName: true,
                profilePictureUrl: true,
                country: true,
                state: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          take: Math.max(1, Math.ceil(limit / 3)),
        })
      : [];

    const studioRows = promoted.length == 0
      ? []
      : await prisma.vendorStudio.findMany({
          where: {
            userId: {
              in: promoted.map((ad) => ad.userId),
            },
          },
        });
    const studioByUserId = new Map(studioRows.map((row) => [row.userId, row]));

    const promotedMatched = promoted.filter((ad) => {
      const country = viewer?.country;
      const state = viewer?.state;
      if (!country) return false;

      if (ad.reachLevel == 'CURRENT_STATE') {
        return ad.targetCountry == country && ad.targetStates.includes(state ?? '');
      }

      if (ad.reachLevel == 'SELECTED_STATES') {
        return ad.targetCountry == country && ad.targetStates.includes(state ?? '');
      }

      if (ad.reachLevel == 'GLOBAL_COUNTRIES') {
        return ad.targetCountries.includes(country);
      }

      return false;
    });

    const promotedPosts = promotedMatched.map((ad) => {
      const studio = studioByUserId.get(ad.userId);
      return {
      id: `boost-${ad.id}`,
      textBody: ad.headline ?? `Featured talent: ${ad.user.displayName}`,
      mediaUrl:
        ad.mediaUrl ||
        studio?.profileReelUrl ||
        studio?.galleryUrls?.[0] ||
        null,
      skillHighlight: studio?.category ?? null,
      videoCodec: null,
      sourceResolution: null,
      availableResolutions: [],
      captions: [],
      moderationTags: ['BOOSTED'],
      isHiddenPendingReview: false,
      copyrightBlocked: false,
      author: ad.user,
      reactions: [],
      comments: [],
      reshares: [],
      isBoosted: true,
      promotedAdId: ad.id,
    };});

    if (blockedIds.size == 0) {
      return [...promotedPosts, ...rows].slice(0, limit);
    }

    const filteredRows = rows
      .map((post) => ({
        ...post,
        comments: post.comments.filter((comment) => !blockedIds.has(comment.userId)),
      }));

    return [...promotedPosts, ...filteredRows].slice(0, limit);
  },
};
