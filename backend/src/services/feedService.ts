import { prisma } from '../lib/prisma.js';
import { moderationService } from './moderationService.js';

export const feedService = {
  async createPost({
    authorUserId,
    textBody,
    mediaUrl,
    skillHighlight,
  }: {
    authorUserId: string;
    textBody?: string;
    mediaUrl?: string;
    skillHighlight?: string;
  }) {
    return prisma.post.create({
      data: {
        authorUserId,
        textBody,
        mediaUrl,
        skillHighlight,
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
  }: {
    postId: string;
    userId: string;
    body: string;
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
      },
    });
  },

  async feed(limit: number) {
    return prisma.post.findMany({
      take: limit,
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
  },
};
