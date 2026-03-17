import { prisma } from '../lib/prisma.js';
import { sessionService } from './sessionService.js';

function makeCodeSeed() {
  return `${Math.floor(100000 + Math.random() * 900000)}`;
}

export const moderatorInviteService = {
  async createInviteCode({
    adminUserId,
    gatheringPlace,
    roleLabel,
  }: {
    adminUserId: string;
    gatheringPlace: string;
    roleLabel: string;
  }) {
    const prefix = gatheringPlace
      .split(' ')
      .slice(0, 2)
      .map((part) => part.replace(/[^A-Za-z]/g, '').toUpperCase())
      .filter((part) => part.length > 0)
      .join('-');

    const code = `${prefix || 'GPG'}-${makeCodeSeed()}`;

    return prisma.moderatorInviteCode.create({
      data: {
        code,
        gatheringPlace,
        roleLabel,
        createdByAdminId: adminUserId,
      },
    });
  },

  async listInviteCodes(limit: number) {
    return prisma.moderatorInviteCode.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
    });
  },

  async redeemInviteCode(code: string) {
    const invite = await prisma.moderatorInviteCode.findUnique({
      where: { code },
    });

    if (!invite || !invite.isActive) {
      throw new Error('Invalid or expired moderator invite code.');
    }

    const moderatorUserId = `moderator-${invite.id}`;

    await prisma.moderatorInviteCode.update({
      where: { id: invite.id },
      data: {
        isActive: false,
        consumedAt: new Date(),
        consumedByUserId: moderatorUserId,
      },
    });

    const session = sessionService.issueSessionToken({
      userId: moderatorUserId,
      role: 'moderator',
    });

    return {
      ...session,
      gatheringPlace: invite.gatheringPlace,
      roleLabel: invite.roleLabel,
    };
  },
};
