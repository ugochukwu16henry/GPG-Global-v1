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
    final blockedIds = viewerUserId == null
        ? <String>{}
        : await boundaryService.blockedUserIdsForViewer(viewerUserId);

    final rows = await prisma.post.findMany({
      take: limit,
      where: {
        isHiddenPendingReview: false,
        copyrightBlocked: false,
        authorUserId: blockedIds.isEmpty
            ? undefined
            : {
                notIn: blockedIds.toList(),
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

    if (blockedIds.isEmpty) {
      return rows;
    }

    return rows
        .map(
          (post) => {
            ...post,
            'comments': post.comments
                .where((comment) => !blockedIds.contains(comment.userId))
                .toList(),
          },
        )
        .toList(growable: false);
  },
};
