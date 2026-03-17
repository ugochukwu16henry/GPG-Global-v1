import { prisma } from '../lib/prisma.js';
import { authService } from '../services/authService.js';
import { missionSearchService } from '../services/missionSearchService.js';
import { privacyVaultService } from '../services/privacyVaultService.js';
import { paymentService } from '../services/paymentService.js';
import { chatService } from '../services/chatService.js';

export const typeDefs = `
  enum PathwayStatus {
    CONNECT
    DEGREE
    ALUMNI
  }

  enum SensitiveField {
    GENOTYPE
    BLOOD_GROUP
  }

  type User {
    id: ID!
    phone: String!
    displayName: String!
    isMember: Boolean!
    pathwayStatus: PathwayStatus!
    lga: String
    state: String
    professionalStatus: String!
    mission: Mission
  }

  type Mission {
    id: ID!
    missionCode: String!
    missionName: String!
    country: String!
    city: String
  }

  type OtpDispatch {
    phone: String!
    expiresAt: String!
    devOtpPreview: String
  }

  type MissionPeerMatch {
    missionId: String!
    count: Int!
    summary: String!
  }

  type MarketplaceCheckout {
    checkoutUrl: String!
  }

  type RedFlag {
    flagId: String!
    severity: String!
    reason: String!
    label: String!
    roomId: String!
    messageId: String!
  }

  type ChatResult {
    messageId: String!
    redFlag: RedFlag
  }

  type Query {
    user(id: ID!): User
    suggestMissions(query: String!): [Mission!]!
    missionPeerMatch(missionId: String!): MissionPeerMatch!
    readSensitiveField(ownerUserId: ID!, field: SensitiveField!): String
  }

  type Mutation {
    sendPhoneOtp(phone: String!): OtpDispatch!
    verifyPhoneOtp(phone: String!, otpCode: String!): User!
    setUserProfile(
      userId: ID!
      displayName: String
      isMember: Boolean
      missionId: ID
      pathwayStatus: PathwayStatus
      lga: String
      state: String
    ): User!

    updateSensitiveFields(userId: ID!, genotype: String, bloodGroup: String): Boolean!
    grantSensitiveField(ownerUserId: ID!, viewerUserId: ID!, field: SensitiveField!): Boolean!
    revokeSensitiveField(ownerUserId: ID!, viewerUserId: ID!, field: SensitiveField!): Boolean!

    createMarketplaceCheckout(userId: ID!): MarketplaceCheckout!
    grantMeritAccess(userId: ID!, adminId: ID!, reason: String!): Boolean!

    sendChatMessage(senderUserId: ID!, roomId: String!, body: String!): ChatResult!
  }
`;

export const resolvers = {
  Query: {
    user: (_: unknown, args: { id: string }) => {
      return prisma.user.findUnique({
        where: { id: args.id },
        include: { mission: true }
      });
    },
    suggestMissions: (_: unknown, args: { query: string }) => {
      return missionSearchService.suggestMissions(args.query);
    },
    missionPeerMatch: (_: unknown, args: { missionId: string }) => {
      return missionSearchService.missionPeerMatch(args.missionId);
    },
    readSensitiveField: (_: unknown, args: { ownerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }, context: { userId: string }) => {
      return privacyVaultService.readSensitiveField(context.userId, args.ownerUserId, args.field);
    }
  },

  Mutation: {
    sendPhoneOtp: (_: unknown, args: { phone: string }) => authService.sendPhoneOtp(args.phone),
    verifyPhoneOtp: async (_: unknown, args: { phone: string; otpCode: string }) => {
      const { user } = await authService.verifyPhoneOtp(args.phone, args.otpCode);
      return user;
    },
    setUserProfile: async (
      _: unknown,
      args: {
        userId: string;
        displayName?: string;
        isMember?: boolean;
        missionId?: string;
        pathwayStatus?: 'CONNECT' | 'DEGREE' | 'ALUMNI';
        lga?: string;
        state?: string;
      }
    ) => {
      return prisma.user.update({
        where: { id: args.userId },
        data: {
          displayName: args.displayName,
          isMember: args.isMember,
          missionId: args.missionId,
          pathwayStatus: args.pathwayStatus,
          lga: args.lga,
          state: args.state
        },
        include: { mission: true }
      });
    },
    updateSensitiveFields: async (_: unknown, args: { userId: string; genotype?: string; bloodGroup?: string }) => {
      await privacyVaultService.updateSensitiveFields(args.userId, args.genotype, args.bloodGroup);
      return true;
    },
    grantSensitiveField: async (_: unknown, args: { ownerUserId: string; viewerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }) => {
      await privacyVaultService.grantFieldAccess(args.ownerUserId, args.viewerUserId, args.field);
      return true;
    },
    revokeSensitiveField: async (_: unknown, args: { ownerUserId: string; viewerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }) => {
      await privacyVaultService.revokeFieldAccess(args.ownerUserId, args.viewerUserId, args.field);
      return true;
    },
    createMarketplaceCheckout: async (_: unknown, args: { userId: string }) => {
      const checkoutUrl = await paymentService.createMarketplaceCheckout(args.userId);
      return { checkoutUrl };
    },
    grantMeritAccess: async (_: unknown, args: { userId: string; adminId: string; reason: string }) => {
      await paymentService.grantMeritOverride(args.userId, args.adminId, args.reason);
      return true;
    },
    sendChatMessage: async (_: unknown, args: { senderUserId: string; roomId: string; body: string }) => {
      const result = await chatService.sendMessage(args.senderUserId, args.roomId, args.body);
      return {
        messageId: result.message.id,
        redFlag: result.redFlag
      };
    }
  }
};
