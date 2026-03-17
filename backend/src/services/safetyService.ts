import { prisma } from '../lib/prisma.js';
import { adminService } from './adminService.js';

export const safetyService = {
  async createMetadataFlag({
    chatId,
    flaggedUserId,
    riskScore,
    conductCategory,
    summary,
  }: {
    chatId: string;
    flaggedUserId: string;
    riskScore: number;
    conductCategory:
      | 'DISRESPECTFUL_LANGUAGE'
      | 'IMMODEST_INAPPROPRIATE_CONTENT'
      | 'DISHONEST_CONDUCT'
      | 'UNWHOLESOME_BEHAVIOR';
    summary: string;
  }) {
    return prisma.safetyMetadataFlag.create({
      data: {
        chatId,
        flaggedUserId,
        riskScore,
        conductCategory,
        summary,
      },
    });
  },

  async createAiBreakGlassBundle({
    chatId,
    reportedUserId,
    conductCategory,
    riskScore,
    localAiSummary,
    evidenceMessages,
  }: {
    chatId: string;
    reportedUserId: string;
    conductCategory:
      | 'DISRESPECTFUL_LANGUAGE'
      | 'IMMODEST_INAPPROPRIATE_CONTENT'
      | 'DISHONEST_CONDUCT'
      | 'UNWHOLESOME_BEHAVIOR';
    riskScore: number;
    localAiSummary?: string;
    evidenceMessages: Array<{ senderUserId: string; body: string }>;
  }) {
    return prisma.breakGlassReportBundle.create({
      data: {
        trigger: 'HIGH_RISK_AI_ALERT',
        chatId,
        reportedUserId,
        conductCategory,
        riskScore,
        localAiSummary,
        evidenceMessages: {
          create: evidenceMessages.map((m) => ({
            senderUserId: m.senderUserId,
            body: m.body,
          })),
        },
      },
      include: {
        evidenceMessages: true,
      },
    });
  },

  async createUserReportBundle({
    chatId,
    reporterUserId,
    reportedUserId,
    conductCategory,
    messageFrankingProof,
    evidenceMessages,
  }: {
    chatId: string;
    reporterUserId: string;
    reportedUserId: string;
    conductCategory:
      | 'DISRESPECTFUL_LANGUAGE'
      | 'IMMODEST_INAPPROPRIATE_CONTENT'
      | 'DISHONEST_CONDUCT'
      | 'UNWHOLESOME_BEHAVIOR';
    messageFrankingProof: string;
    evidenceMessages: Array<{ senderUserId: string; body: string }>;
  }) {
    return prisma.breakGlassReportBundle.create({
      data: {
        trigger: 'USER_REPORT',
        chatId,
        reporterUserId,
        reportedUserId,
        conductCategory,
        messageFrankingProof,
        evidenceMessages: {
          create: evidenceMessages.map((m) => ({
            senderUserId: m.senderUserId,
            body: m.body,
          })),
        },
      },
      include: {
        evidenceMessages: true,
      },
    });
  },

  async listBundles(limit = 20) {
    return prisma.breakGlassReportBundle.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        evidenceMessages: {
          orderBy: { createdAt: 'asc' },
          take: 5,
        },
      },
    });
  },

  async resolveBundle({
    bundleId,
    adminUserId,
    action,
  }: {
    bundleId: string;
    adminUserId: string;
    action: 'DISMISSED' | 'WARNING_SENT' | 'SUSPENDED_7_DAYS' | 'PERMANENT_BAN';
  }) {
    const bundle = await prisma.breakGlassReportBundle.findUnique({ where: { id: bundleId } });
    if (!bundle) {
      throw new Error('Bundle not found.');
    }

    if (action === 'SUSPENDED_7_DAYS') {
      await adminService.suspendUser({
        adminUserId,
        userId: bundle.reportedUserId,
        hours: 7 * 24,
        reason: 'Break-glass moderation decision',
      });
    }

    if (action === 'PERMANENT_BAN') {
      await adminService.deleteBanUser({
        adminUserId,
        userId: bundle.reportedUserId,
        reason: 'Break-glass moderation decision',
      });
    }

    return prisma.breakGlassReportBundle.update({
      where: { id: bundleId },
      data: {
        resolution: action,
        resolvedByAdminId: adminUserId,
        resolvedAt: new Date(),
      },
      include: {
        evidenceMessages: true,
      },
    });
  },
};
