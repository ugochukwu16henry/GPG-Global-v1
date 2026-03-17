import { prisma } from '../lib/prisma.js';
import { moderationService } from './moderationService.js';

export const chatService = {
  async sendMessage(senderUserId: string, roomId: string, body: string) {
    const message = await prisma.chatMessage.create({
      data: {
        senderUserId,
        roomId,
        body
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
};
