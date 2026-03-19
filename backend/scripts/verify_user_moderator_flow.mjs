const BASE = 'http://localhost:8080/graphql';
const ADMIN_SECRET = 'GPG-Admin-6mN4qT8vX2pL9sR3kH7wC5dJ1zF0bY';

async function gql({ token, userId, query, variables = {} }) {
  const res = await fetch(BASE, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { 'x-auth-token': token } : {}),
      ...(userId ? { 'x-user-id': userId } : {}),
    },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) {
    throw new Error(json.errors.map((e) => e.message).join('; '));
  }
  return json.data;
}

async function main() {
  const otpDispatch = await gql({
    query: `mutation($phone: String!) { sendPhoneOtp(phone: $phone) { devOtpPreview } }`,
    variables: { phone: '+2348090001122' },
  });
  const otp = otpDispatch.sendPhoneOtp.devOtpPreview;

  const userSessionData = await gql({
    query: `mutation($phone: String!, $otpCode: String!, $displayName: String, $isMember: Boolean) {
      verifyPhoneOtpSession(phone: $phone, otpCode: $otpCode, displayName: $displayName, isMember: $isMember) {
        user { id displayName }
        session { userId role sessionToken }
      }
    }`,
    variables: {
      phone: '+2348090001122',
      otpCode: otp,
      displayName: 'Flow Test User',
      isMember: true,
    },
  });

  const appUserId = userSessionData.verifyPhoneOtpSession.session.userId;
  const appUserToken = userSessionData.verifyPhoneOtpSession.session.sessionToken;
  console.log(`[user] session ok for ${appUserId}`);

  const adminSession = await gql({
    query: `mutation($secret: String!) { issueAdminSession(adminSecret: $secret) { userId role sessionToken } }`,
    variables: { secret: ADMIN_SECRET },
  });

  const adminToken = adminSession.issueAdminSession.sessionToken;
  const adminUserId = adminSession.issueAdminSession.userId;

  console.log(`[admin] session ok for ${adminUserId}`);

  const uploadData = await gql({
    token: appUserToken,
    userId: appUserId,
    query: `mutation($userId: ID!, $bucket: StorageBucket!, $fileName: String!) {
      requestUploadUrl(userId: $userId, bucket: $bucket, fileName: $fileName) {
        signedUrl
        path
      }
    }`,
    variables: {
      userId: appUserId,
      bucket: 'media',
      fileName: 'smoke-test.png',
    },
  });

  const upload = uploadData.requestUploadUrl;
  const pngBytes = Uint8Array.from([
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
    0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
    0x89, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9c, 0x63, 0xf8, 0xcf, 0xc0, 0x00,
    0x00, 0x03, 0x01, 0x01, 0x00, 0xc9, 0xfe, 0x92,
    0xef, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e,
    0x44, 0xae, 0x42, 0x60, 0x82,
  ]);

  const uploadRes = await fetch(upload.signedUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': 'image/png',
      'x-upsert': 'true',
    },
    body: pngBytes,
  });

  if (!uploadRes.ok) {
    throw new Error(`upload failed ${uploadRes.status}`);
  }
  console.log(`[storage] upload ok path=${upload.path}`);

  const createdPost = await gql({
    token: appUserToken,
    userId: appUserId,
    query: `mutation($authorUserId: ID!, $textBody: String, $mediaUrl: String) {
      createPost(authorUserId: $authorUserId, textBody: $textBody, mediaUrl: $mediaUrl) {
        id
        mediaUrl
      }
    }`,
    variables: {
      authorUserId: appUserId,
      textBody: 'Storage smoke test post',
      mediaUrl: upload.path,
    },
  });
  console.log(`[feed] createPost ok id=${createdPost.createPost.id}`);

  const feed = await gql({
    token: appUserToken,
    userId: appUserId,
    query: `query { feed(limit: 5) { id textBody mediaUrl author { id } } }`,
  });
  const uploadedPost = feed.feed.find((item) => item.id === createdPost.createPost.id);
  console.log(`[feed] signed media url resolved=${uploadedPost?.mediaUrl?.startsWith('http') === true}`);

  const modInvite = await gql({
    token: adminToken,
    userId: adminUserId,
    query: `mutation($gatheringPlace: String!, $roleLabel: String!, $adminUserId: ID!) {
      createModeratorInviteCode(gatheringPlace: $gatheringPlace, roleLabel: $roleLabel, adminUserId: $adminUserId) {
        code
      }
    }`,
    variables: {
      gatheringPlace: 'Lagos Island Gathering Place',
      roleLabel: 'Service Moderator',
      adminUserId: adminUserId,
    },
  });
  const modCode = modInvite.createModeratorInviteCode.code;
  console.log(`[moderator] invite created code=${modCode}`);

  const modSession = await gql({
    query: `mutation($code: String!) {
      redeemModeratorInviteCode(code: $code) {
        userId
        role
        sessionToken
        gatheringPlace
      }
    }`,
    variables: { code: modCode },
  });
  const moderator = modSession.redeemModeratorInviteCode;
  console.log(`[moderator] redeem ok user=${moderator.userId} place=${moderator.gatheringPlace}`);

  const bundles = await gql({
    token: moderator.sessionToken,
    userId: moderator.userId,
    query: `query { breakGlassBundles(limit: 5) { id } }`,
  });
  console.log(`[moderator] breakGlassBundles ok count=${bundles.breakGlassBundles.length}`);

  const nearby = await gql({
    token: moderator.sessionToken,
    userId: moderator.userId,
    query: `query($userId: ID!, $latitude: Float!, $longitude: Float!) {
      nearbyGatheringPlaces(userId: $userId, latitude: $latitude, longitude: $longitude) {
        id
        name
      }
    }`,
    variables: {
      userId: moderator.userId,
      latitude: 6.5244,
      longitude: 3.3792,
    },
  });
  console.log(`[moderator] nearbyGatheringPlaces ok count=${nearby.nearbyGatheringPlaces.length}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
