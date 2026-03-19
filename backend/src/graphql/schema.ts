import { prisma } from '../lib/prisma.js';
import { authService } from '../services/authService.js';
import { missionSearchService } from '../services/missionSearchService.js';
import { privacyVaultService } from '../services/privacyVaultService.js';
import { paymentService } from '../services/paymentService.js';
import { chatService } from '../services/chatService.js';
import { feedService } from '../services/feedService.js';
import { adminService } from '../services/adminService.js';
import { boundaryService } from '../services/boundaryService.js';
import { gatheringService } from '../services/gatheringService.js';
import { safetyService } from '../services/safetyService.js';
import { sessionService } from '../services/sessionService.js';
import { moderatorInviteService } from '../services/moderatorInviteService.js';
import { marketplaceTalentService } from '../services/marketplaceTalentService.js';
import { storageService, BucketName } from '../services/storageService.js';

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

  enum GatheringLevel {
    GLOBAL
    LOCAL
    SUB_GROUP
  }

  enum GroupCategory {
    GENERAL
    SELF_RELIANCE
    TEMPLE_PREP
    SOCIAL
  }

  enum GroupMembershipRole {
    MEMBER
    FRIEND
    SEEKER
    MODERATOR
    LEADER
  }

  enum FaithConductCategory {
    DISRESPECTFUL_LANGUAGE
    IMMODEST_INAPPROPRIATE_CONTENT
    DISHONEST_CONDUCT
    UNWHOLESOME_BEHAVIOR
  }

  enum BreakGlassResolutionAction {
    DISMISSED
    WARNING_SENT
    SUSPENDED_7_DAYS
    PERMANENT_BAN
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

  type SessionTokenPayload {
    userId: ID!
    role: String!
    sessionToken: String!
    expiresAt: String!
  }

  type AuthSessionResult {
    user: User!
    session: SessionTokenPayload!
  }

  type ModeratorInviteCode {
    id: ID!
    code: String!
    gatheringPlace: String!
    roleLabel: String!
    isActive: Boolean!
    createdAt: String!
  }

  type ModeratorSessionResult {
    userId: ID!
    role: String!
    sessionToken: String!
    expiresAt: String!
    gatheringPlace: String!
    roleLabel: String!
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
    country: String
    isMember: Boolean!
    pathwayStatus: PathwayStatus!
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
    timestampSeconds: Int
    author: FeedAuthor!
  }

  type FeedPost {
    id: ID!
    textBody: String
    mediaUrl: String
    skillHighlight: String
    videoCodec: String
    sourceResolution: String
    availableResolutions: [String!]
    captions: [String!]
    moderationTags: [String!]
    isHiddenPendingReview: Boolean!
    copyrightBlocked: Boolean!
    author: FeedAuthor!
    warmLikes: Int!
    prayerLikes: Int!
    reshareCount: Int!
    comments: [FeedComment!]!
    isBoosted: Boolean!
    promotedAdId: ID
  }

  type VendorServicePrice {
    id: ID!
    serviceName: String!
    pricingMode: String!
    amountUsd: Float!
    currency: String!
    unitLabel: String
    createdAt: String!
  }

  type VendorStudio {
    userId: ID!
    vendorName: String!
    country: String
    state: String
    category: String!
    profilePictureUrl: String
    profileReelUrl: String
    galleryUrls: [String!]!
    verified: Boolean!
    servicePricing: [VendorServicePrice!]!
  }

  type TalentBanner {
    id: ID!
    vendorUserId: ID!
    vendorName: String!
    category: String
    profilePictureUrl: String
    country: String!
    message: String!
    createdAt: String!
  }

  type PromotedAd {
    id: ID!
    userId: ID!
    mediaUrl: String!
    headline: String
    reachLevel: String!
    targetCountry: String
    targetStates: [String!]!
    targetCountries: [String!]!
    startDate: String!
    endDate: String!
    isActive: Boolean!
    createdAt: String!
  }

  type BlockedAccount {
    userId: ID!
    displayName: String!
    profilePictureUrl: String
    blockedAt: String!
  }

  type GatheringGroupSummary {
    id: ID!
    name: String!
    level: GatheringLevel!
    category: GroupCategory!
    memberCount: Int!
    isPrivate: Boolean!
  }

  type GatheringPlaceSummary {
    id: ID!
    name: String!
    country: String!
    stateOrCity: String!
    lga: String
    distanceMiles: Float
    groups: [GatheringGroupSummary!]!
  }

  type DigitalHandshake {
    message: String!
  }

  type BreakGlassEvidenceMessage {
    id: ID!
    senderUserId: ID!
    body: String!
    createdAt: String!
  }

  type BreakGlassReportBundle {
    id: ID!
    trigger: String!
    chatId: String!
    reporterUserId: ID
    reportedUserId: ID!
    conductCategory: FaithConductCategory!
    riskScore: Int
    localAiSummary: String
    messageFrankingProof: String
    resolution: String!
    createdAt: String!
    evidenceMessages: [BreakGlassEvidenceMessage!]!
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

  type MarketplaceApprovalRecord {
    id: ID!
    userId: ID!
    certificateTitle: String!
    status: String!
    reviewedByAdminId: ID
    reviewedAt: String
    createdAt: String!
  }

  type TalentFeatureRecord {
    id: ID!
    userId: ID!
    isFeatured: Boolean!
    updatedByAdminId: ID!
    updatedAt: String!
  }

  type AdModerationReviewRecord {
    id: ID!
    externalAdId: String!
    targeting: String!
    note: String
    status: String!
    reviewedByAdminId: ID
    reviewedAt: String
    createdAt: String!
  }

  type UserDisciplineRecord {
    userId: ID!
    suspendedUntil: String
    isShadowBanned: Boolean!
    isDeletedBanned: Boolean!
    updatedAt: String!
  }

  type BannedIdentityRecord {
    id: ID!
    phone: String
    deviceId: String
    reason: String!
    bannedByAdminId: ID!
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
    nearbyGatheringPlaces(userId: ID!, latitude: Float!, longitude: Float!, radiusMiles: Float = 20): [GatheringPlaceSummary!]!
    userGatheringGroups(userId: ID!): [GatheringGroupSummary!]!
    breakGlassBundles(limit: Int = 20): [BreakGlassReportBundle!]!
    moderatorInviteCodes(limit: Int = 20): [ModeratorInviteCode!]!
    adminActionLogs(limit: Int = 50): [AdminActionLog!]!
    marketplaceApprovals(limit: Int = 50): [MarketplaceApprovalRecord!]!
    talentFeatures(limit: Int = 50): [TalentFeatureRecord!]!
    adModerationReviews(limit: Int = 50): [AdModerationReviewRecord!]!
    userDisciplineStates(limit: Int = 100): [UserDisciplineRecord!]!
    bannedIdentities(limit: Int = 100): [BannedIdentityRecord!]!
    vendorStudio(userId: ID!): VendorStudio
    marketplaceDirectory(search: String, country: String, category: String, limit: Int = 50): [VendorStudio!]!
    homeTalentBanners(userId: ID!, limit: Int = 20): [TalentBanner!]!
    myPromotedAds(userId: ID!, limit: Int = 50): [PromotedAd!]!
    readSensitiveField(ownerUserId: ID!, field: SensitiveField!): String
  }

  type Mutation {
    sendPhoneOtp(phone: String!): OtpDispatch!
    verifyPhoneOtp(phone: String!, otpCode: String!): User!
    verifyPhoneOtpSession(phone: String!, otpCode: String!, displayName: String, isMember: Boolean): AuthSessionResult!
    issueAdminSession(adminSecret: String!): SessionTokenPayload!
    createModeratorInviteCode(gatheringPlace: String!, roleLabel: String!, adminUserId: ID!): ModeratorInviteCode!
    redeemModeratorInviteCode(code: String!): ModeratorSessionResult!
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

    createPost(
      authorUserId: ID!
      textBody: String
      mediaUrl: String
      skillHighlight: String
      videoCodec: String
      sourceResolution: String
      availableResolutions: [String!]
      captions: [String!]
      moderationTags: [String!]
      isHiddenPendingReview: Boolean
      copyrightBlocked: Boolean
    ): FeedPost!
    reactToPost(postId: ID!, userId: ID!, kind: String!): Boolean!
    resharePost(postId: ID!, userId: ID!, targetGroupId: String): Boolean!
    addComment(postId: ID!, userId: ID!, body: String!, timestampSeconds: Int): Boolean!

    adminSuspendUser(adminUserId: ID!, userId: ID!, hours: Int!, reason: String): Boolean!
    adminShadowBanUser(adminUserId: ID!, userId: ID!, reason: String): Boolean!
    adminDeleteBanUser(adminUserId: ID!, userId: ID!, phone: String, deviceId: String, reason: String): Boolean!
    adminApproveMarketplace(adminUserId: ID!, userId: ID!, certificateTitle: String!): Boolean!
    adminGrantMeritMarketplace(adminUserId: ID!, userId: ID!, certificateTitle: String!, reason: String!): Boolean!
    adminSetTalentFeatured(adminUserId: ID!, userId: ID!, isFeatured: Boolean!): Boolean!
    adminReviewAd(adminUserId: ID!, adId: ID!, targeting: String!, approved: Boolean!, note: String): Boolean!
    upsertVendorStudio(userId: ID!, category: String!, profilePictureUrl: String, profileReelUrl: String, galleryUrls: [String!]): VendorStudio!
    upsertVendorServicePricing(userId: ID!, serviceName: String!, pricingMode: String!, amountUsd: Float!, currency: String = "USD", unitLabel: String): VendorServicePrice!
    createPromotedAd(
      userId: ID!
      mediaUrl: String!
      headline: String
      reachLevel: String!
      targetCountry: String
      targetStates: [String!]
      targetCountries: [String!]
      startDate: String!
      endDate: String!
    ): PromotedAd!
    deactivatePromotedAd(userId: ID!, promotedAdId: ID!): Boolean!

    blockUser(blockerId: ID!, blockedId: ID!, reasonCode: BlockReasonCode): Boolean!
    unblockUser(blockerId: ID!, blockedId: ID!): Boolean!
    muteUser(muterId: ID!, mutedId: ID!): Boolean!
    unmuteUser(muterId: ID!, mutedId: ID!): Boolean!
    reportUser(reporterId: ID!, reportedId: ID!, reasonCode: ReportReasonCode!, detail: String): Boolean!

    createLocalGatheringPlace(
      name: String!
      country: String!
      stateOrCity: String!
      lga: String
      latitude: Float!
      longitude: Float!
    ): Boolean!
    createSubGroup(
      gatheringPlaceId: ID!
      name: String!
      category: GroupCategory!
      adminUserId: ID!
      isPrivate: Boolean
      parentGroupId: ID
    ): Boolean!
    joinGatheringGroup(userId: ID!, groupId: ID!, role: GroupMembershipRole): Boolean!
    checkInGatheringPlace(userId: ID!, gatheringPlaceId: ID!): DigitalHandshake!
    markChatRead(messageId: ID!, userId: ID!): Boolean!
    reportChatMessage(messageId: ID!, reporterId: ID!, localAdminUserId: ID): Boolean!
    createSafetyMetadataFlag(
      chatId: String!
      flaggedUserId: ID!
      riskScore: Int!
      conductCategory: FaithConductCategory!
      summary: String!
    ): Boolean!
    createAiBreakGlassBundle(
      chatId: String!
      reportedUserId: ID!
      conductCategory: FaithConductCategory!
      riskScore: Int!
      localAiSummary: String
      evidenceMessages: [String!]!
    ): Boolean!
    createUserReportBundle(
      chatId: String!
      reporterUserId: ID!
      reportedUserId: ID!
      conductCategory: FaithConductCategory!
      messageFrankingProof: String!
      evidenceMessages: [String!]!
    ): Boolean!
    resolveBreakGlassBundle(
      bundleId: ID!
      adminUserId: ID!
      action: BreakGlassResolutionAction!
    ): Boolean!

    sendChatMessage(senderUserId: ID!, roomId: String!, body: String!): ChatResult!

    # Storage — signed URLs for direct client uploads/downloads
    requestUploadUrl(userId: ID!, bucket: StorageBucket!, fileName: String!): UploadUrlResult!
    requestDownloadUrl(userId: ID!, bucket: StorageBucket!, path: String!): String!
    deleteStorageFile(userId: ID!, bucket: StorageBucket!, path: String!): Boolean!
  }

  # ─── Storage ───────────────────────────────────────────────────────────────

  enum StorageBucket {
    avatars
    media
    documents
  }

  type UploadUrlResult {
    signedUrl: String!
    token: String!
    path: String!
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

type AppRole = 'guest' | 'user' | 'moderator' | 'admin';

type RequestContext = {
  userId: string;
  role: string;
};

function requireAuthenticated(context: RequestContext) {
  if (context.userId == 'anonymous' || context.role == 'guest') {
    throw new Error('Authentication required.');
  }
}

function requireRole(context: RequestContext, allowedRoles: string[]) {
  requireAuthenticated(context);
  if (!allowedRoles.includes(context.role)) {
    throw new Error('Forbidden for this role.');
  }
}

function requireSelfOrRole(context: RequestContext, targetUserId: string, allowedRoles: string[]) {
  requireAuthenticated(context);
  if (context.userId == targetUserId) {
    return;
  }
  if (!allowedRoles.includes(context.role)) {
    throw new Error('Forbidden for this role.');
  }
}

async function resolveMediaReference(value?: string | null) {
  if (!value) {
    return null;
  }

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (!value.startsWith('users/')) {
    return value;
  }

  try {
    return await storageService.createDownloadUrl(storageService.BUCKETS.media as BucketName, value);
  } catch {
    return value;
  }
}

async function mapVendorStudioPayload(studio: any) {
  return {
    userId: studio.userId,
    vendorName: studio.user.displayName,
    country: studio.user.country,
    state: studio.user.state,
    category: studio.category,
    profilePictureUrl: studio.profilePictureUrl ?? studio.user.profilePictureUrl,
    profileReelUrl: await resolveMediaReference(studio.profileReelUrl),
    galleryUrls: await Promise.all(
      (studio.galleryUrls ?? []).map((url: string) => resolveMediaReference(url)),
    ),
    verified: true,
    servicePricing: studio.servicePricing.map((price: any) => ({
      ...price,
      amountUsd: Number(price.amountUsd),
      createdAt: price.createdAt.toISOString(),
    })),
  };
}

export const resolvers = {
  User: {
    age: (parent: { birthday?: Date | null }) => ageFromBirthday(parent.birthday),
  },

  FeedPost: {
    warmLikes: (parent: any) => (parent.reactions ?? []).filter((x: any) => x.kind === 'WARM_HEART').length,
    prayerLikes: (parent: any) => (parent.reactions ?? []).filter((x: any) => x.kind === 'PRAYER_HANDS').length,
    reshareCount: (parent: any) => (parent.reshares ?? []).length,
    author: (parent: any) => parent.author,
    comments: (parent: any) =>
      (parent.comments ?? []).map((comment: any) => ({
        id: comment.id,
        body: comment.body,
        timestampSeconds: comment.timestampSeconds,
        author: comment.user,
      })),
    isBoosted: (parent: any) => parent.isBoosted === true,
    promotedAdId: (parent: any) => parent.promotedAdId ?? null,
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
      context: RequestContext
    ) => {
      requireAuthenticated(context);
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
      context: RequestContext
    ) => {
      requireAuthenticated(context);
      const blockedIds = await boundaryService.blockedUserIdsForViewer(context.userId);
      return prisma.user.findMany({
        where: {
          id: blockedIds.size == 0
              ? undefined
              : {
                  notIn: Array.from(blockedIds),
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
    feed: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireAuthenticated(context);
      return feedService.feed(args.limit ?? 20, context.userId == 'anonymous' ? undefined : context.userId);
    },
    blockedAccounts: async (_: unknown, args: { userId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      const rows = await boundaryService.blockedAccounts(args.userId);
      return rows.map((row: any) => ({
        userId: row.blocked.id,
        displayName: row.blocked.displayName,
        profilePictureUrl: row.blocked.profilePictureUrl,
        blockedAt: row.createdAt.toISOString(),
      }));
    },
    nearbyGatheringPlaces: async (
      _: unknown,
      args: { userId: string; latitude: number; longitude: number; radiusMiles?: number },
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      const rows = await gatheringService.suggestNearbyGatheringPlaces(args);
      return rows.map((place: any) => ({
        id: place.id,
        name: place.name,
        country: place.country,
        stateOrCity: place.stateOrCity,
        lga: place.lga,
        distanceMiles: place.distanceMiles,
        groups: place.groups.map((group: any) => ({
          id: group.id,
          name: group.name,
          level: group.level,
          category: group.category,
          memberCount: group.memberships.length,
          isPrivate: group.isPrivate,
        })),
      }));
    },
    userGatheringGroups: async (_: unknown, args: { userId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      const rows = await gatheringService.groupsForUser(args.userId);
      return rows.map((row: any) => ({
        id: row.group.id,
        name: row.group.name,
        level: row.group.level,
        category: row.group.category,
        memberCount: row.group.memberships.length,
        isPrivate: row.group.isPrivate,
      }));
    },
    breakGlassBundles: (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['moderator', 'admin']);
      return safetyService.listBundles(args.limit ?? 20);
    },
    moderatorInviteCodes: (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      return moderatorInviteService.listInviteCodes(args.limit ?? 20);
    },
    adminActionLogs: (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      return adminService.recentLogs(args.limit ?? 50);
    },
    marketplaceApprovals: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      const rows = await adminService.marketplaceApprovals(args.limit ?? 50);
      return rows.map((row: any) => ({
        ...row,
        reviewedAt: row.reviewedAt?.toISOString() ?? null,
        createdAt: row.createdAt.toISOString(),
      }));
    },
    talentFeatures: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      const rows = await adminService.talentFeatures(args.limit ?? 50);
      return rows.map((row: any) => ({
        ...row,
        updatedAt: row.updatedAt.toISOString(),
      }));
    },
    adModerationReviews: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      const rows = await adminService.adModerationReviews(args.limit ?? 50);
      return rows.map((row: any) => ({
        ...row,
        reviewedAt: row.reviewedAt?.toISOString() ?? null,
        createdAt: row.createdAt.toISOString(),
      }));
    },
    userDisciplineStates: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      const rows = await adminService.userDisciplineStates(args.limit ?? 100);
      return rows.map((row: any) => ({
        ...row,
        suspendedUntil: row.suspendedUntil?.toISOString() ?? null,
        updatedAt: row.updatedAt.toISOString(),
      }));
    },
    bannedIdentities: async (_: unknown, args: { limit?: number }, context: RequestContext) => {
      requireRole(context, ['admin']);
      const rows = await adminService.bannedIdentities(args.limit ?? 100);
      return rows.map((row: any) => ({
        ...row,
        createdAt: row.createdAt.toISOString(),
      }));
    },
    vendorStudio: async (_: unknown, args: { userId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin', 'moderator']);
      const studio = await marketplaceTalentService.vendorStudio(args.userId);
      if (!studio) return null;
      return mapVendorStudioPayload(studio);
    },
    marketplaceDirectory: async (
      _: unknown,
      args: { search?: string; country?: string; category?: string; limit?: number },
      context: RequestContext,
    ) => {
      requireAuthenticated(context);
      const rows = await marketplaceTalentService.marketplaceDirectory({
        search: args.search,
        country: args.country,
        category: args.category,
        limit: args.limit ?? 50,
      });
      return Promise.all(rows.map((studio: any) => mapVendorStudioPayload(studio)));
    },
    homeTalentBanners: async (_: unknown, args: { userId: string; limit?: number }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin', 'moderator']);
      const rows = await marketplaceTalentService.homeTalentBanners(args.userId, args.limit ?? 20);
      return rows.map((row: any) => ({
        ...row,
        createdAt: row.createdAt.toISOString(),
      }));
    },
    myPromotedAds: async (_: unknown, args: { userId: string; limit?: number }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      const rows = await marketplaceTalentService.myPromotedAds(args.userId, args.limit ?? 50);
      return rows.map((row: any) => ({
        ...row,
        startDate: row.startDate.toISOString(),
        endDate: row.endDate.toISOString(),
        createdAt: row.createdAt.toISOString(),
      }));
    },
    readSensitiveField: (_: unknown, args: { ownerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }, context: RequestContext) => {
      requireAuthenticated(context);
      return privacyVaultService.readSensitiveField(context.userId, args.ownerUserId, args.field);
    }
  },

  Mutation: {
    sendPhoneOtp: (_: unknown, args: { phone: string }) => authService.sendPhoneOtp(args.phone),
    verifyPhoneOtp: async (_: unknown, args: { phone: string; otpCode: string }) => {
      const { user } = await authService.verifyPhoneOtp(args.phone, args.otpCode);
      return user;
    },
    verifyPhoneOtpSession: async (
      _: unknown,
      args: { phone: string; otpCode: string; displayName?: string; isMember?: boolean }
    ) => {
      return authService.verifyPhoneOtpSession(args);
    },
    issueAdminSession: async (_: unknown, args: { adminSecret: string }) => {
      return sessionService.issueAdminSession(args.adminSecret);
    },
    createModeratorInviteCode: async (
      _: unknown,
      args: { gatheringPlace: string; roleLabel: string; adminUserId: string },
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      return moderatorInviteService.createInviteCode(args);
    },
    redeemModeratorInviteCode: async (_: unknown, args: { code: string }) => {
      return moderatorInviteService.redeemInviteCode(args.code);
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
      },
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
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
      args: { userId: string; fieldKey: string; visibility: 'EVERYONE' | 'CONNECTIONS' | 'ONLY_ME' },
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      return privacyVaultService.setVisibility(args.userId, args.fieldKey, args.visibility);
    },
    setSafetyMode: async (
      _: unknown,
      args: { userId: string; femaleOnly: boolean; verifiedMembersOnly: boolean },
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      await prisma.user.update({
        where: { id: args.userId },
        data: {
          safeSearchFemaleOnly: args.femaleOnly,
          safeSearchVerifiedMembersOnly: args.verifiedMembersOnly,
        },
      });
      return true;
    },
    updateSensitiveFields: async (_: unknown, args: { userId: string; genotype?: string; bloodGroup?: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      await privacyVaultService.updateSensitiveFields(args.userId, args.genotype, args.bloodGroup);
      return true;
    },
    grantSensitiveField: async (_: unknown, args: { ownerUserId: string; viewerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }, context: RequestContext) => {
      requireSelfOrRole(context, args.ownerUserId, ['admin']);
      await privacyVaultService.grantFieldAccess(args.ownerUserId, args.viewerUserId, args.field);
      return true;
    },
    revokeSensitiveField: async (_: unknown, args: { ownerUserId: string; viewerUserId: string; field: 'GENOTYPE' | 'BLOOD_GROUP' }, context: RequestContext) => {
      requireSelfOrRole(context, args.ownerUserId, ['admin']);
      await privacyVaultService.revokeFieldAccess(args.ownerUserId, args.viewerUserId, args.field);
      return true;
    },
    createMarketplaceCheckout: async (_: unknown, args: { userId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      const checkoutUrl = await paymentService.createMarketplaceCheckout(args.userId);
      return { checkoutUrl };
    },
    grantMeritAccess: async (_: unknown, args: { userId: string; adminId: string; reason: string }, context: RequestContext) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminId) {
        throw new Error('Admin identity mismatch.');
      }
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
        videoCodec?: string;
        sourceResolution?: string;
        availableResolutions?: string[];
        captions?: string[];
        moderationTags?: string[];
        isHiddenPendingReview?: boolean;
        copyrightBlocked?: boolean;
      }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.authorUserId, ['admin']);
      const post = await feedService.createPost(args);
      return {
        ...post,
        author: {
          id: args.authorUserId,
          displayName: 'Unknown',
          profilePictureUrl: null,
        },
        videoCodec: args.videoCodec,
        sourceResolution: args.sourceResolution,
        availableResolutions: args.availableResolutions ?? [],
        captions: args.captions ?? [],
        moderationTags: args.moderationTags ?? [],
        isHiddenPendingReview: args.isHiddenPendingReview ?? false,
        copyrightBlocked: args.copyrightBlocked ?? false,
        reactions: [],
        comments: [],
        reshares: [],
      };
    },
    reactToPost: async (_: unknown, args: { postId: string; userId: string; kind: 'WARM_HEART' | 'PRAYER_HANDS' }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      await feedService.reactToPost(args);
      return true;
    },
    resharePost: async (_: unknown, args: { postId: string; userId: string; targetGroupId?: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      await feedService.resharePost(args);
      return true;
    },
    addComment: async (_: unknown, args: { postId: string; userId: string; body: string; timestampSeconds?: number }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      await feedService.addComment(args);
      return true;
    },
    adminSuspendUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; hours: number; reason?: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.suspendUser(args);
      return true;
    },
    adminShadowBanUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; reason?: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.shadowBanUser(args);
      return true;
    },
    adminDeleteBanUser: async (
      _: unknown,
      args: { adminUserId: string; userId: string; phone?: string; deviceId?: string; reason?: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.deleteBanUser(args);
      return true;
    },
    adminApproveMarketplace: async (
      _: unknown,
      args: { adminUserId: string; userId: string; certificateTitle: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.approveMarketplace(args);
      return true;
    },
    adminGrantMeritMarketplace: async (
      _: unknown,
      args: { adminUserId: string; userId: string; certificateTitle: string; reason: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.grantMeritMarketplace(args);
      return true;
    },
    adminSetTalentFeatured: async (
      _: unknown,
      args: { adminUserId: string; userId: string; isFeatured: boolean }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.setTalentFeatured(args);
      return true;
    },
    adminReviewAd: async (
      _: unknown,
      args: { adminUserId: string; adId: string; targeting: string; approved: boolean; note?: string }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      if (context.userId != args.adminUserId) {
        throw new Error('Admin identity mismatch.');
      }
      await adminService.reviewAd(args);
      return true;
    },
    upsertVendorStudio: async (
      _: unknown,
      args: {
        userId: string;
        category: string;
        profilePictureUrl?: string;
        profileReelUrl?: string;
        galleryUrls?: string[];
      },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      const studio = await marketplaceTalentService.upsertVendorStudio(args);
      return mapVendorStudioPayload(studio);
    },
    upsertVendorServicePricing: async (
      _: unknown,
      args: {
        userId: string;
        serviceName: string;
        pricingMode: 'FIXED' | 'STARTING_FROM';
        amountUsd: number;
        currency?: string;
        unitLabel?: string;
      },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      const row = await marketplaceTalentService.upsertVendorServicePricing(args);
      return {
        ...row,
        amountUsd: Number(row.amountUsd),
        createdAt: row.createdAt.toISOString(),
      };
    },
    createPromotedAd: async (
      _: unknown,
      args: {
        userId: string;
        mediaUrl: string;
        headline?: string;
        reachLevel: 'CURRENT_STATE' | 'SELECTED_STATES' | 'GLOBAL_COUNTRIES';
        targetCountry?: string;
        targetStates?: string[];
        targetCountries?: string[];
        startDate: string;
        endDate: string;
      },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      const row = await marketplaceTalentService.createPromotedAd(args);
      return {
        ...row,
        startDate: row.startDate.toISOString(),
        endDate: row.endDate.toISOString(),
        createdAt: row.createdAt.toISOString(),
      };
    },
    deactivatePromotedAd: async (
      _: unknown,
      args: { userId: string; promotedAdId: string },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['admin']);
      return marketplaceTalentService.deactivatePromotedAd(args);
    },
    blockUser: async (
      _: unknown,
      args: { blockerId: string; blockedId: string; reasonCode?: 'SPAM' | 'HARASSMENT' | 'INAPPROPRIATE_CONTENT' | 'OTHER' }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.blockerId, ['admin']);
      await boundaryService.blockUser(args);
      return true;
    },
    unblockUser: async (_: unknown, args: { blockerId: string; blockedId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.blockerId, ['admin']);
      await boundaryService.unblockUser(args);
      return true;
    },
    muteUser: async (_: unknown, args: { muterId: string; mutedId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.muterId, ['admin']);
      await boundaryService.muteUser(args);
      return true;
    },
    unmuteUser: async (_: unknown, args: { muterId: string; mutedId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.muterId, ['admin']);
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
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.reporterId, ['admin']);
      await boundaryService.reportUser(args);
      return true;
    },
    createLocalGatheringPlace: async (
      _: unknown,
      args: {
        name: string;
        country: string;
        stateOrCity: string;
        lga?: string;
        latitude: number;
        longitude: number;
      }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['admin']);
      await gatheringService.upsertLocalGatheringPlace(args);
      await gatheringService.ensureGlobalCommunity();
      return true;
    },
    createSubGroup: async (
      _: unknown,
      args: {
        gatheringPlaceId: string;
        name: string;
        category: 'GENERAL' | 'SELF_RELIANCE' | 'TEMPLE_PREP' | 'SOCIAL';
        adminUserId: string;
        isPrivate?: boolean;
        parentGroupId?: string;
      }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['moderator', 'admin']);
      if (context.userId != args.adminUserId && context.role != 'admin') {
        throw new Error('Moderator identity mismatch.');
      }
      await gatheringService.createSubGroup(args);
      return true;
    },
    joinGatheringGroup: async (
      _: unknown,
      args: {
        userId: string;
        groupId: string;
        role?: 'MEMBER' | 'FRIEND' | 'SEEKER' | 'MODERATOR' | 'LEADER';
      }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      await gatheringService.joinGroup(args);
      return true;
    },
    checkInGatheringPlace: async (
      _: unknown,
      args: { userId: string; gatheringPlaceId: string }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      return gatheringService.checkInToPlace(args);
    },
    markChatRead: async (_: unknown, args: { messageId: string; userId: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      await chatService.markRead(args.messageId, args.userId);
      return true;
    },
    reportChatMessage: async (
      _: unknown,
      args: { messageId: string; reporterId: string; localAdminUserId?: string }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.reporterId, ['moderator', 'admin']);
      await chatService.reportMessage(args);
      return true;
    },
    createSafetyMetadataFlag: async (
      _: unknown,
      args: {
        chatId: string;
        flaggedUserId: string;
        riskScore: number;
        conductCategory:
          | 'DISRESPECTFUL_LANGUAGE'
          | 'IMMODEST_INAPPROPRIATE_CONTENT'
          | 'DISHONEST_CONDUCT'
          | 'UNWHOLESOME_BEHAVIOR';
        summary: string;
      }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.flaggedUserId, ['moderator', 'admin']);
      await safetyService.createMetadataFlag(args);
      return true;
    },
    createAiBreakGlassBundle: async (
      _: unknown,
      args: {
        chatId: string;
        reportedUserId: string;
        conductCategory:
          | 'DISRESPECTFUL_LANGUAGE'
          | 'IMMODEST_INAPPROPRIATE_CONTENT'
          | 'DISHONEST_CONDUCT'
          | 'UNWHOLESOME_BEHAVIOR';
        riskScore: number;
        localAiSummary?: string;
        evidenceMessages: string[];
      }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.reportedUserId, ['moderator', 'admin']);
      await safetyService.createAiBreakGlassBundle({
        chatId: args.chatId,
        reportedUserId: args.reportedUserId,
        conductCategory: args.conductCategory,
        riskScore: args.riskScore,
        localAiSummary: args.localAiSummary,
        evidenceMessages: args.evidenceMessages.map((body) => ({
          senderUserId: args.reportedUserId,
          body,
        })),
      });
      return true;
    },
    createUserReportBundle: async (
      _: unknown,
      args: {
        chatId: string;
        reporterUserId: string;
        reportedUserId: string;
        conductCategory:
          | 'DISRESPECTFUL_LANGUAGE'
          | 'IMMODEST_INAPPROPRIATE_CONTENT'
          | 'DISHONEST_CONDUCT'
          | 'UNWHOLESOME_BEHAVIOR';
        messageFrankingProof: string;
        evidenceMessages: string[];
      }
    ,
      context: RequestContext
    ) => {
      requireSelfOrRole(context, args.reporterUserId, ['moderator', 'admin']);
      await safetyService.createUserReportBundle({
        chatId: args.chatId,
        reporterUserId: args.reporterUserId,
        reportedUserId: args.reportedUserId,
        conductCategory: args.conductCategory,
        messageFrankingProof: args.messageFrankingProof,
        evidenceMessages: args.evidenceMessages.map((body) => ({
          senderUserId: args.reportedUserId,
          body,
        })),
      });
      return true;
    },
    resolveBreakGlassBundle: async (
      _: unknown,
      args: {
        bundleId: string;
        adminUserId: string;
        action: 'DISMISSED' | 'WARNING_SENT' | 'SUSPENDED_7_DAYS' | 'PERMANENT_BAN';
      }
    ,
      context: RequestContext
    ) => {
      requireRole(context, ['moderator', 'admin']);
      if (context.userId != args.adminUserId && context.role != 'admin') {
        throw new Error('Moderator/Admin identity mismatch.');
      }
      await safetyService.resolveBundle(args);
      return true;
    },
    sendChatMessage: async (_: unknown, args: { senderUserId: string; roomId: string; body: string }, context: RequestContext) => {
      requireSelfOrRole(context, args.senderUserId, ['moderator', 'admin']);
      const result = await chatService.sendMessage(args.senderUserId, args.roomId, args.body);
      return {
        messageId: result.message.id,
        redFlag: result.redFlag
      };
    },

    // ── Storage ──────────────────────────────────────────────────────────────
    requestUploadUrl: async (
      _: unknown,
      args: { userId: string; bucket: BucketName; fileName: string },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      // Build a safe path: users/<userId>/<timestamp>_<sanitisedFileName>
      const safeName = args.fileName.replace(/[^a-zA-Z0-9._-]/g, '_').slice(0, 120);
      const path = `users/${args.userId}/${Date.now()}_${safeName}`;
      return storageService.createUploadUrl(args.bucket, path);
    },

    requestDownloadUrl: async (
      _: unknown,
      args: { userId: string; bucket: BucketName; path: string },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      return storageService.createDownloadUrl(args.bucket, args.path);
    },

    deleteStorageFile: async (
      _: unknown,
      args: { userId: string; bucket: BucketName; path: string },
      context: RequestContext,
    ) => {
      requireSelfOrRole(context, args.userId, ['moderator', 'admin']);
      // Only allow deletion of paths owned by the requesting user (unless admin)
      if (context.role !== 'admin' && !args.path.startsWith(`users/${args.userId}/`)) {
        throw new Error('You can only delete your own files.');
      }
      await storageService.deleteFile(args.bucket, args.path);
      return true;
    },
  }
};
