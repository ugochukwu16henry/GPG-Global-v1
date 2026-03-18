import { config } from 'dotenv';
import { z } from 'zod';

config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4100),
  CLIENT_ORIGIN: z.string().default('http://localhost:3000'),

  DATABASE_URL: z.string().min(1),

  SUPABASE_URL: z.string().url(),
  SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),

  JWT_SIGNING_SECRET: z.string().min(16),
  VAULT_ENCRYPTION_KEY_HEX: z.string().length(64),

  NEO4J_URI: z.string().min(1),
  NEO4J_USER: z.string().min(1),
  NEO4J_PASSWORD: z.string().min(1),

  STRIPE_SECRET_KEY: z.string().min(1),
  STRIPE_WEBHOOK_SECRET: z.string().min(1),
  FLUTTERWAVE_SECRET_HASH: z.string().min(1),
  FLUTTERWAVE_SECRET_KEY: z.string().min(1),

  LLAMA4_MODERATION_URL: z.string().url(),
  LLAMA4_MODERATION_API_KEY: z.string().min(1),

  S3_BUCKET: z.string().min(1),
  S3_REGION: z.string().min(1),
  CDN_BASE_URL: z.string().url()
});

export const env = envSchema.parse(process.env);
