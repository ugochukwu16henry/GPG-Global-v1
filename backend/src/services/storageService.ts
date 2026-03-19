import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env.js';

// ---------------------------------------------------------------------------
// Buckets
// ---------------------------------------------------------------------------
// avatars   — public read, authenticated write. Profile pictures.
// media     — private. Post images/videos, signed download URLs.
// documents — private. Mission call letters, pathway certificates, reports.
// ---------------------------------------------------------------------------

export const BUCKETS = {
  avatars: 'avatars',
  media: 'media',
  documents: 'documents',
} as const;

export type BucketName = (typeof BUCKETS)[keyof typeof BUCKETS];

function getSupabaseClient() {
  if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error(
      'Supabase Storage is not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.'
    );
  }
  return createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
}

// Signed URL TTL (seconds)
const UPLOAD_TTL = 60 * 5;      // 5 minutes to upload
const DOWNLOAD_TTL = 60 * 60;   // 1 hour to read

// ---------------------------------------------------------------------------
// Bucket initialisation (run once at startup)
// ---------------------------------------------------------------------------
export async function ensureBucketsExist(): Promise<void> {
  if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
    console.warn('[storage] Supabase keys missing; skipping bucket initialization.');
    return;
  }
  const supabase = getSupabaseClient();
  const { data: existing } = await supabase.storage.listBuckets();
  const existingNames = new Set((existing ?? []).map((b) => b.name));

  const toCreate: Array<{ name: BucketName; public: boolean }> = [
    { name: BUCKETS.avatars,   public: true  },
    { name: BUCKETS.media,     public: false },
    { name: BUCKETS.documents, public: false },
  ];

  for (const bucket of toCreate) {
    if (!existingNames.has(bucket.name)) {
      const { error } = await supabase.storage.createBucket(bucket.name, {
        public: bucket.public,
        allowedMimeTypes: bucket.name === BUCKETS.documents
          ? ['application/pdf', 'image/*', 'video/*']
          : ['image/*', 'video/*'],
        fileSizeLimit: bucket.name === BUCKETS.documents ? 52_428_800 : 104_857_600, // 50 MB / 100 MB
      });
      if (error) {
        console.warn(`[storage] Could not create bucket "${bucket.name}":`, error.message);
      } else {
        console.log(`[storage] Bucket created: ${bucket.name}`);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Upload helpers
// ---------------------------------------------------------------------------

/**
 * Generate a signed URL so the client can upload a file directly to Supabase
 * Storage without streaming through the API server.
 */
export async function createUploadUrl(
  bucket: BucketName,
  path: string,
): Promise<{ signedUrl: string; token: string; path: string }> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUploadUrl(path);

  if (error || !data) {
    throw new Error(`Failed to create upload URL: ${error?.message}`);
  }

  return { signedUrl: data.signedUrl, token: data.token, path: data.path };
}

/**
 * Generate a signed download URL for private buckets.
 * For the public `avatars` bucket, getPublicUrl() is used instead.
 */
export async function createDownloadUrl(
  bucket: BucketName,
  path: string,
  expiresInSeconds = DOWNLOAD_TTL,
): Promise<string> {
  const supabase = getSupabaseClient();
  if (bucket === BUCKETS.avatars) {
    const { data } = supabase.storage.from(bucket).getPublicUrl(path);
    return data.publicUrl;
  }

  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, expiresInSeconds);

  if (error || !data) {
    throw new Error(`Failed to create download URL: ${error?.message}`);
  }

  return data.signedUrl;
}

/**
 * Delete a file from storage (e.g., when a user deletes their avatar or post).
 */
export async function deleteFile(bucket: BucketName, path: string): Promise<void> {
  const supabase = getSupabaseClient();
  const { error } = await supabase.storage.from(bucket).remove([path]);
  if (error) {
    throw new Error(`Failed to delete file: ${error.message}`);
  }
}

/**
 * List files under a prefix (folder) — useful for admin views.
 */
export async function listFiles(bucket: BucketName, prefix: string) {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase.storage.from(bucket).list(prefix, {
    limit: 100,
    sortBy: { column: 'created_at', order: 'desc' },
  });
  if (error) {
    throw new Error(`Failed to list files: ${error.message}`);
  }
  return data ?? [];
}

// ---------------------------------------------------------------------------
// Convenience: build canonical storage paths
// ---------------------------------------------------------------------------
export const storagePaths = {
  avatar:    (userId: string, ext: string)   => `users/${userId}/avatar.${ext}`,
  postMedia: (userId: string, postId: string, ext: string) =>
                                               `posts/${userId}/${postId}.${ext}`,
  document:  (userId: string, name: string)  => `docs/${userId}/${Date.now()}_${name}`,
};

export const storageService = {
  ensureBucketsExist,
  createUploadUrl,
  createDownloadUrl,
  deleteFile,
  listFiles,
  storagePaths,
  BUCKETS,
  UPLOAD_TTL,
};
