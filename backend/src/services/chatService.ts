import { prisma } from '../lib/prisma.js';
import { moderationService } from './moderationService.js';

export const chatService = {
  async sendMessage(senderUserId: string, roomId: string, body: string, threadId?: string) {
    const message = await prisma.chatMessage.create({
      data: {
        senderUserId,
        roomId,
        body,
        threadId,
      }
    });

    const moderation = await moderationService.moderateMessage(body);
    let redFlag: null | {
      flagId: string;
      severity: string;
      reason: string;
      label: string;
      roomId: string;
      messageId: string;
    } = null;

    if (moderation.violates) {
      const flag = await prisma.moderationFlag.create({
        data: {
          chatMessageId: message.id,
          severity: moderation.severity,
          reason: moderation.reason,
          aiLabel: moderation.label
        }
      });

      redFlag = {
        flagId: flag.id,
        severity: flag.severity,
        reason: flag.reason,
        label: flag.aiLabel,
        roomId,
        messageId: message.id
      };
    }

    return {
      message,
      redFlag
    };
  }
  ,

  async markRead(messageId: string, userId: string) {
    await prisma.groupMessageReadReceipt.upsert({
      where: {
        messageId_userId: {
          messageId,
          userId,
        },
      },
      create: {
        messageId,
        userId,
      },
      update: {
        readAt: new Date(),
      },
    });

    return true;
  },

  async reportMessage({
    messageId,
    reporterId,
    localAdminUserId,
  }: {
    messageId: string;
    reporterId: string;
    localAdminUserId?: string;
  }) {
    const message = await prisma.chatMessage.findUnique({ where: { id: messageId } });
    if (!message) {
      throw new Error('Message not found.');
    }

    await prisma.userReport.create({
      data: {
        reporterId,
        reportedId: message.senderUserId,
        reasonCode: 'HARASSMENT',
        detail: `Message report: ${messageId}`,
      },
    });

    const moderation = await moderationService.moderateMessage(message.body);
    if (moderation.violates && moderation.severity === 'HIGH') {
      await prisma.chatMessage.update({
        where: { id: messageId },
        data: { isHiddenByAi: true },
      });
    }

    return {
      actionRequiredFor: localAdminUserId,
      aiHidden: moderation.violates && moderation.severity === 'HIGH',
      decisionOptions: ['KEEP', 'DELETE', 'BAN_USER'],
    };
  }
};
