/**
 * GPG API endpoint checker — run with: node scripts/check_endpoints.mjs
 */
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

const BASE = 'http://localhost:8080';
const GRAPHQL = `${BASE}/graphql`;
const TOKEN = process.env.ADMIN_TOKEN || '';
const ADMIN_ID = 'admin-root';

const headers = {
  'Content-Type': 'application/json',
  'x-auth-token': TOKEN,
  'x-user-id': ADMIN_ID,
};

async function gql(label, query) {
  try {
    const res = await fetch(GRAPHQL, {
      method: 'POST',
      headers,
      body: JSON.stringify({ query }),
    });
    const j = await res.json();
    if (j.errors) {
      const msgs = j.errors.map(e => e.message).join('; ');
      console.log(`ERR  [${label}] ${msgs}`);
    } else {
      const dataKey = Object.keys(j.data ?? {})[0];
      const val = j.data?.[dataKey];
      const info = Array.isArray(val) ? `count=${val.length}` : val !== null && val !== undefined ? 'found' : 'null';
      console.log(`OK   [${label}] ${info}`);
    }
  } catch (e) {
    console.log(`FAIL [${label}] ${e.message}`);
  }
}

async function rest(label, path) {
  try {
    const res = await fetch(`${BASE}${path}`);
    const j = await res.json();
    console.log(`OK   [${label}] HTTP ${res.status} → ${JSON.stringify(j).slice(0, 80)}`);
  } catch (e) {
    console.log(`FAIL [${label}] ${e.message}`);
  }
}

// ── Get admin token first ────────────────────────────────────────────────────
async function getAdminToken() {
  const secret = 'GPG-Admin-6mN4qT8vX2pL9sR3kH7wC5dJ1zF0bY';
  const res = await fetch(GRAPHQL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query: `mutation { issueAdminSession(adminSecret: "${secret}") { userId role sessionToken expiresAt } }`,
    }),
  });
  const j = await res.json();
  if (j.errors) throw new Error(j.errors[0].message);
  return j.data.issueAdminSession.sessionToken;
}

// ── Run all checks ─────────────────────────────────────────────────────────
console.log('=== GPG API Endpoint Check ===\n');

// 1. REST
await rest('REST /health', '/health');

// 2. Auth
headers['x-auth-token'] = await getAdminToken();
console.log('OK   [issueAdminSession] token obtained\n');

// 3. Auth — OTP (no token needed, uses bare headers)
const noAuthHeaders = { 'Content-Type': 'application/json' };
try {
  const r = await fetch(GRAPHQL, {
    method: 'POST', headers: noAuthHeaders,
    body: JSON.stringify({ query: 'mutation { sendPhoneOtp(phone: "+2348012345678") { phone devOtpPreview } }' }),
  });
  const j = await r.json();
  const otp = j.data?.sendPhoneOtp?.devOtpPreview;
  console.log(j.errors ? `ERR  [sendPhoneOtp] ${j.errors[0].message}` : `OK   [sendPhoneOtp] devPreview=${otp ?? 'hidden (prod mode)'}`);
} catch (e) { console.log(`FAIL [sendPhoneOtp] ${e.message}`); }

// 4. User queries
await gql('user(admin-root)', `query { user(id: "${ADMIN_ID}") { id displayName isMember } }`);
await gql('communitySearch', 'query { communitySearch { id displayName } }');
await gql('suggestMissions', 'query { suggestMissions(query: "Nigeria") { id missionCode missionName } }');

// 5. Feed
await gql('feed', 'query { feed(limit: 3) { id textBody isBoosted promotedAdId warmLikes prayerLikes reshareCount author { id displayName } } }');

// 6. Marketplace
await gql('marketplaceDirectory', 'query { marketplaceDirectory(limit: 5) { userId vendorName category verified servicePricing { id serviceName amountUsd } } }');
await gql(`vendorStudio(${ADMIN_ID})`, `query { vendorStudio(userId: "${ADMIN_ID}") { userId vendorName category verified } }`);
await gql(`homeTalentBanners(${ADMIN_ID})`, `query { homeTalentBanners(userId: "${ADMIN_ID}", limit: 5) { id vendorName category country message createdAt } }`);
await gql(`myPromotedAds(${ADMIN_ID})`, `query { myPromotedAds(userId: "${ADMIN_ID}", limit: 5) { id reachLevel isActive startDate endDate } }`);

// 7. Admin queries
await gql('adminActionLogs', 'query { adminActionLogs(limit: 5) { id action targetEntity createdAt } }');
await gql('marketplaceApprovals', 'query { marketplaceApprovals(limit: 5) { id userId certificateTitle status createdAt } }');
await gql('talentFeatures', 'query { talentFeatures(limit: 5) { id userId isFeatured updatedAt } }');
await gql('adModerationReviews', 'query { adModerationReviews(limit: 5) { id externalAdId status } }');
await gql('bannedIdentities', 'query { bannedIdentities(limit: 5) { id reason createdAt } }');
await gql('userDisciplineStates', 'query { userDisciplineStates(limit: 5) { userId isShadowBanned isDeletedBanned } }');
await gql('moderatorInviteCodes', 'query { moderatorInviteCodes(limit: 5) { id code isActive } }');
await gql('breakGlassBundles', 'query { breakGlassBundles(limit: 3) { id trigger resolution createdAt } }');

// 8. Storage
await gql('requestUploadUrl', `mutation { requestUploadUrl(userId: "${ADMIN_ID}", bucket: avatars, fileName: "test-avatar.jpg") { signedUrl path token } }`);
await gql('requestDownloadUrl', `mutation { requestDownloadUrl(userId: "${ADMIN_ID}", bucket: avatars, path: "admin-root/test-avatar.jpg") }`);

// 9. Privacy vault
await gql('readSensitiveField', `query { readSensitiveField(ownerUserId: "${ADMIN_ID}", field: GENOTYPE) }`);

// 10. Gathering
await gql('userGatheringGroups', `query { userGatheringGroups(userId: "${ADMIN_ID}") { id name level category memberCount } }`);

console.log('\n=== Check complete ===');
