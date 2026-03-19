import { config } from 'dotenv';
import { z } from 'zod';

config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4100),
  CLIENT_ORIGIN: z.string().default('http://localhost:3000'),

  DATABASE_URL: z.string().min(1),

  SUPABASE_URL: z.string().url().optional(),
  SUPABASE_ANON_KEY: z.string().min(1).optional(),
  SUPABASE_PUBLISHABLE_KEY: z.string().min(1).optional(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),

  JWT_SIGNING_SECRET: z.string().min(16),
  VAULT_ENCRYPTION_KEY_HEX: z.string().length(64),

  NEO4J_URI: z.string().min(1).default('neo4j://localhost:7687'),
  NEO4J_USER: z.string().min(1).default('neo4j'),
  NEO4J_PASSWORD: z.string().min(1).default('neo4j'),

  STRIPE_SECRET_KEY: z.string().min(1).optional(),
  STRIPE_WEBHOOK_SECRET: z.string().min(1).optional(),
  FLUTTERWAVE_SECRET_HASH: z.string().min(1).optional(),
  FLUTTERWAVE_SECRET_KEY: z.string().min(1).optional(),

  LLAMA4_MODERATION_URL: z.string().url().optional(),
  LLAMA4_MODERATION_API_KEY: z.string().min(1).optional(),

  S3_BUCKET: z.string().min(1).optional(),
  S3_REGION: z.string().min(1).optional(),
  CDN_BASE_URL: z.string().url().optional()
});

const parsed = envSchema.parse(process.env);

export const env = {
  ...parsed,
  SUPABASE_ANON_KEY: parsed.SUPABASE_ANON_KEY ?? parsed.SUPABASE_PUBLISHABLE_KEY,
};
