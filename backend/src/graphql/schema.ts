import { prisma } from '../lib/prisma.js';
import { authService } from '../services/authService.js';
import { missionSearchService } from '../services/missionSearchService.js';
import { privacyVaultService } from '../services/privacyVaultService.js';
import { paymentService } from '../services/paymentService.js';
import { chatService } from '../services/chatService.js';
import { feedService } from '../services/feedService.js';
import { adminService } from '../services/adminService.js';
import { boundaryService } from '../services/boundaryService.js';

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

  enum RelationshipStatus {
    SINGLE
    MARRIED
  }

  enum Gender {
    MALE
    FEMALE
  }

  enum VisibilityLevel {
    EVERYONE
    CONNECTIONS
    ONLY_ME
  }

  enum BlockReasonCode {
    SPAM
    HARASSMENT
    INAPPROPRIATE_CONTENT
    OTHER
  }

  enum ReportReasonCode {
    SPAM
    HARASSMENT
    SCAM
    INAPPROPRIATE_CONTENT
    OTHER
  }

  type User {
    id: ID!
    phone: String!
    displayName: String!
    profilePictureUrl: String
    bio: String
    country: String
    isMember: Boolean!
    servedMission: Boolean!
    birthday: String
    age: Int
    relationshipStatus: RelationshipStatus
    gender: Gender
    pathwayStatus: PathwayStatus!
    isPathwayConnect: Boolean!
    isDegree: Boolean!
    isAlumni: Boolean!
    academicFocus: String
    lga: String
    state: String
    allowsBirthdayBroadcast: Boolean!
    safeSearchFemaleOnly: Boolean!
    safeSearchVerifiedMembersOnly: Boolean!
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

  type MissionPeerSuggestion {
    id: ID!
    displayName: String!
    lga: String
    state: String
  }

  type CommunitySearchUser {
    id: ID!
    displayName: String!
    relationshipStatus: RelationshipStatus
    gender: Gender
    academicFocus: String
    lga: String
    state: String
    mission: Mission
  }

  type PathwayPeerResult {
    summary: String!
  }

  type FeedAuthor {
    id: ID!
    displayName: String!
    profilePictureUrl: String
  }

  type FeedComment {
    id: ID!
    body: String!
    author: FeedAuthor!
  }

  type FeedPost {
    id: ID!
    textBody: String
    mediaUrl: String
    skillHighlight: String
    author: FeedAuthor!
    warmLikes: Int!
    prayerLikes: Int!
    reshareCount: Int!
    comments: [FeedComment!]!
  }

  type BlockedAccount {
    userId: ID!
    displayName: String!
    profilePictureUrl: String
    blockedAt: String!
  }

  type AdminActionLog {
    id: ID!
    adminUserId: ID!
    action: String!
    targetUserId: ID
    targetEntity: String!
    reason: String
    createdAt: String!
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
    suggestedMissionPeers(userId: ID!): [MissionPeerSuggestion!]!
    pathwayPeerMatch(academicFocus: String!, state: String, lga: String): PathwayPeerResult!
    communitySearch(
      education: PathwayStatus
      missionId: ID
      relationshipStatus: RelationshipStatus
      talent: String
      gender: Gender
    ): [CommunitySearchUser!]!
    feed(limit: Int = 20): [FeedPost!]!
    blockedAccounts(userId: ID!): [BlockedAccount!]!
    adminActionLogs(limit: Int = 50): [AdminActionLog!]!
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
      profilePictureUrl: String
      bio: String
      country: String
      birthday: String
      relationshipStatus: RelationshipStatus
      gender: Gender
      servedMission: Boolean
      isPathwayConnect: Boolean
      isDegree: Boolean
      isAlumni: Boolean
      academicFocus: String
      allowsBirthdayBroadcast: Boolean
      safeSearchFemaleOnly: Boolean
      safeSearchVerifiedMembersOnly: Boolean
      lga: String
      state: String
    ): User!

    setFieldVisibility(userId: ID!, fieldKey: String!, visibility: VisibilityLevel!): Boolean!
    setSafetyMode(userId: ID!, femaleOnly: Boolean!, verifiedMembersOnly: Boolean!): Boolean!

    updateSensitiveFields(userId: ID!, genotype: String, bloodGroup: String): Boolean!
    grantSensitiveField(ownerUserId: ID!, viewerUserId: ID!, field: SensitiveField!): Boolean!
    revokeSensitiveField(ownerUserId: ID!, viewerUserId: ID!, field: SensitiveField!): Boolean!

    createMarketplaceCheckout(userId: ID!): MarketplaceCheckout!
    grantMeritAccess(userId: ID!, adminId: ID!, reason: String!): Boolean!

    createPost(authorUserId: ID!, textBody: String, mediaUrl: String, skillHighlight: String): FeedPost!
    reactToPost(postId: ID!, userId: ID!, kind: String!): Boolean!
    resharePost(postId: ID!, userId: ID!, targetGroupId: String): Boolean!
    addComment(postId: ID!, userId: ID!, body: String!): Boolean!

    adminSuspendUser(adminUserId: ID!, userId: ID!, hours: Int!, reason: String): Boolean!
    adminShadowBanUser(adminUserId: ID!, userId: ID!, reason: String): Boolean!
    adminDeleteBanUser(adminUserId: ID!, userId: ID!, phone: String, deviceId: String, reason: String): Boolean!
    adminApproveMarketplace(adminUserId: ID!, userId: ID!, certificateTitle: String!): Boolean!
    adminGrantMeritMarketplace(adminUserId: ID!, userId: ID!, certificateTitle: String!, reason: String!): Boolean!
    adminSetTalentFeatured(adminUserId: ID!, userId: ID!, isFeatured: Boolean!): Boolean!
    adminReviewAd(adminUserId: ID!, adId: ID!, targeting: String!, approved: Boolean!, note: String): Boolean!

    blockUser(blockerId: ID!, blockedId: ID!, reasonCode: BlockReasonCode): Boolean!
    unblockUser(blockerId: ID!, blockedId: ID!): Boolean!
    muteUser(muterId: ID!, mutedId: ID!): Boolean!
    unmuteUser(muterId: ID!, mutedId: ID!): Boolean!
    reportUser(reporterId: ID!, reportedId: ID!, reasonCode: ReportReasonCode!, detail: String): Boolean!

    sendChatMessage(senderUserId: ID!, roomId: String!, body: String!): ChatResult!
  }
`;

function ageFromBirthday(value?: Date | null) {
  if (!value) {
    return null;
  }
  const today = new Date();
  let age = today.getFullYear() - value.getFullYear();
  const monthDelta = today.getMonth() - value.getMonth();
  if (monthDelta < 0 || (monthDelta == 0 && today.getDate() < value.getDate())) {
    age -= 1;
  }
  return age;
}

export const resolvers = {
  User: {
    age: (parent: { birthday?: Date | null }) => ageFromBirthday(parent.birthday),
  },

  FeedPost: {
    warmLikes: (parent: any) => parent.reactions.filter((x: any) => x.kind === 'WARM_HEART').length,
    prayerLikes: (parent: any) => parent.reactions.filter((x: any) => x.kind === 'PRAYER_HANDS').length,
    reshareCount: (parent: any) => parent.reshares.length,
    author: (parent: any) => parent.author,
    comments: (parent: any) =>
      parent.comments.map((comment: any) => ({
        id: comment.id,
        body: comment.body,
        author: comment.user,
      })),
  },

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
    suggestedMissionPeers: (_: unknown, args: { userId: string }) => {
      return missionSearchService.suggestedMissionPeersForUser(args.userId);
    },
    pathwayPeerMatch: async (
      _: unknown,
      args: { academicFocus: string; state?: string; lga?: string },
      context: { userId: string }
    ) => {
      const summary = await missionSearchService.pathwayPeerMatch({
        ...args,
        viewerUserId: context.userId == 'anonymous' ? undefined : context.userId,
      });
      return { summary };
    },
    communitySearch: async (
      _: unknown,
      args: {
        education?: 'CONNECT' | 'DEGREE' | 'ALUMNI';
        missionId?: string;
        relationshipStatus?: 'SINGLE' | 'MARRIED';
        talent?: string;
        gender?: 'MALE' | 'FEMALE';
      },
      context: { userId: string }
    ) => {
      const blockedIds = await boundaryService.blockedUserIdsForViewer(context.userId);
      return prisma.user.findMany({
        where: {
          id: blockedIds.isEmpty
              ? undefined
              : {
                  notIn: blockedIds.toList(),
                },
          pathwayStatus: args.education,
          missionId: args.missionId,
          relationshipStatus: args.relationshipStatus,
          gender: args.gender,
          academicFocus: args.talent
              ? {
                  contains: args.talent,
                  mode: 'insensitive'
                }
              : undefined,
        } as any,
        include: {
          mission: true,
        },
        take: 50,
      });
    },
    feed: async (_: unknown, args: { limit?: number }, context: { userId: string }) => {
      return feedService.feed(args.limit ?? 20, context.userId == 'anonymous' ? undefined : context.userId);
    },
    blockedAccounts: async (_: unknown, args: { userId: string }) => {
      const rows = await boundaryService.blockedAccounts(args.userId);
      return rows.map((row) => ({
        userId: row.blocked.id,
        displayName: row.blocked.displayName,
        profilePictureUrl: row.blocked.profilePictureUrl,
        blockedAt: row.createdAt.toISOString(),
      }));
    },
    adminActionLogs: (_: unknown, args: { limit?: number }) => {
      return adminService.recentLogs(args.limit ?? 50);
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
        profilePictureUrl?: string;
        bio?: string;
        country?: string;
        birthday?: string;
        relationshipStatus?: 'SINGLE' | 'MARRIED';
        gender?: 'MALE' | 'FEMALE';
        servedMission?: boolean;
        isPathwayConnect?: boolean;
        isDegree?: boolean;
        isAlumni?: boolean;
        academicFocus?: string;
        allowsBirthdayBroadcast?: boolean;
        safeSearchFemaleOnly?: boolean;
        safeSearchVerifiedMembersOnly?: boolean;
        lga?: string;
        state?: string;
      }
    ) => {
      const updated = await prisma.user.update({
        where: { id: args.userId },
        data: {
          displayName: args.displayName,
          profilePictureUrl: args.profilePictureUrl,
          bio: args.bio,
          country: args.country,
          isMember: args.isMember,
          servedMission: args.servedMission,
          birthday: args.birthday ? new Date(args.birthday) : undefined,
          relationshipStatus: args.relationshipStatus,
          gender: args.gender,
          missionId: args.missionId,
          pathwayStatus: args.pathwayStatus,
          isPathwayConnect: args.isPathwayConnect,
          isDegree: args.isDegree,
          isAlumni: args.isAlumni,
          academicFocus: args.academicFocus,
          allowsBirthdayBroadcast: args.allowsBirthdayBroadcast,
          safeSearchFemaleOnly: args.safeSearchFemaleOnly,
          safeSearchVerifiedMembersOnly: args.safeSearchVerifiedMembersOnly,
          lga: args.lga,
          state: args.state
        } as any,
        include: { mission: true }
      });

      if (args.missionId && args.servedMission == true) {
        await prisma.missionAlumni.create({
          data: {
            userId: args.userId,
            missionId: args.missionId,
            serviceYearFrom: new Date().getFullYear() - 2,
            serviceYearTo: new Date().getFullYear(),
          },
        });
      }

      return updated;
    },
    setFieldVisibility: async (
      _: unknown,
      args: { userId: string; fieldKey: string; visibility: 'EVERYONE' | 'CONNECTIONS' | 'ONLY_ME' }
    ) => {
      return privacyVaultService.setVisibility(args.userId, args.fieldKey, args.visibility);
    },
    setSafetyMode: async (
      _: unknown,
      args: { userId: string; femaleOnly: boolean; verifiedMembersOnly: boolean }
    ) => {
      await prisma.user.update({
        where: { id: args.userId },
        data: {
          safeSearchFemaleOnly: args.femaleOnly,
          safeSearchVerifiedMembersOnly: args.verifiedMembersOnly,
        },
      });
      return true;
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
    createPost: async (
      _: unknown,
      args: {
        authorUserId: string;
        textBody?: string;
        mediaUrl?: string;
        skillHighlight?: string;
      }
    ) => {
      const post = await feedService.createPost(args);
      return {
        ...post,
        author: {
          id: args.authorUserId,
          displayName: 'Unknown',
          profilePictureUrl: null,
        },
        reactions: [],
        comments: [],
        reshares: [],
      };
    },
    reactToPost: async (_: unknown, args: { postId: string; userId: string; kind: 'WARM_HEART' | 'PRAYER_HANDS' }) => {
      await feedService.reactToPost(args);
      return true;
    },
    resharePost: async (_: unknown, args: { postId: string; userId: string; targetGroupId?: string }) => {
      await feedService.resharePost(args);
      return true;
    },
    addComment: async (_: unknown, args: { postId: string; userId: string; body: string }) => {
      await feedService.addComment(args);
      return true;
    },
    adminSuspendUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; hours: number; reason?: string }
    ) => {
      await adminService.suspendUser(args);
      return true;
    },
    adminShadowBanUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; reason?: string }
    ) => {
      await adminService.shadowBanUser(args);
      return true;
    },
    adminDeleteBanUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; phone?: string; deviceId?: string; reason?: string }
    ) => {
      await adminService.deleteBanUser(args);
      return true;
    },
    adminApproveMarketplace: async (
      _: unknown,
      args: { adminUserId: string; userId: string; certificateTitle: string }
    ) => {
      await adminService.approveMarketplace(args);
      return true;
    },
    adminGrantMeritMarketplace: async (
      _: unknown,
      args: { adminUserId: string; userId: string; certificateTitle: string; reason: string }
    ) => {
      await adminService.grantMeritMarketplace(args);
      return true;
    },
    adminSetTalentFeatured: async (
      _: unknown,
      args: { adminUserId: string; userId: string; isFeatured: boolean }
    ) => {
      await adminService.setTalentFeatured(args);
      return true;
    },
    adminReviewAd: async (
      _: unknown,
      args: { adminUserId: string; adId: string; targeting: string; approved: boolean; note?: string }
    ) => {
      await adminService.reviewAd(args);
      return true;
    },
    blockUser: async (
      _: unknown,
      args: { blockerId: string; blockedId: string; reasonCode?: 'SPAM' | 'HARASSMENT' | 'INAPPROPRIATE_CONTENT' | 'OTHER' }
    ) => {
      await boundaryService.blockUser(args);
      return true;
    },
    unblockUser: async (_: unknown, args: { blockerId: string; blockedId: string }) => {
      await boundaryService.unblockUser(args);
      return true;
    },
    muteUser: async (_: unknown, args: { muterId: string; mutedId: string }) => {
      await boundaryService.muteUser(args);
      return true;
    },
    unmuteUser: async (_: unknown, args: { muterId: string; mutedId: string }) => {
      await boundaryService.unmuteUser(args);
      return true;
    },
    reportUser: async (
      _: unknown,
      args: {
        reporterId: string;
        reportedId: string;
        reasonCode: 'SPAM' | 'HARASSMENT' | 'SCAM' | 'INAPPROPRIATE_CONTENT' | 'OTHER';
        detail?: string;
      }
    ) => {
      await boundaryService.reportUser(args);
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
