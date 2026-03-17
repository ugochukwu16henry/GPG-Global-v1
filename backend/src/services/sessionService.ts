import crypto from 'crypto';
import { env } from '../config/env.js';

type SessionRole = 'user' | 'moderator' | 'admin';

type SessionPayload = {
  sub: string;
  role: SessionRole;
  exp: number;
};

function toBase64Url(value: string) {
  return Buffer.from(value)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function fromBase64Url(value: string) {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const padding = normalized.length % 4 === 0 ? '' : '='.repeat(4 - (normalized.length % 4));
  return Buffer.from(normalized + padding, 'base64').toString('utf8');
}

function sign(input: string) {
  return crypto
    .createHmac('sha256', env.JWT_SIGNING_SECRET)
    .update(input)
    .digest('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

export const sessionService = {
  issueSessionToken({
    userId,
    role,
    ttlSeconds = 60 * 60 * 12,
  }: {
    userId: string;
    role: SessionRole;
    ttlSeconds?: number;
  }) {
    const header = toBase64Url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
    const exp = Math.floor(Date.now() / 1000) + ttlSeconds;
    const payload = toBase64Url(JSON.stringify({ sub: userId, role, exp } satisfies SessionPayload));
    const signature = sign(`${header}.${payload}`);

    return {
      sessionToken: `${header}.${payload}.${signature}`,
      expiresAt: new Date(exp * 1000).toISOString(),
      userId,
      role,
    };
  },

  verifySessionToken(token?: string | null) {
    if (!token) {
      return null;
    }

    const parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    const [header, payload, signature] = parts;
    const expected = sign(`${header}.${payload}`);
    if (signature != expected) {
      return null;
    }

    const decoded = JSON.parse(fromBase64Url(payload)) as SessionPayload;
    if (decoded.exp < Math.floor(Date.now() / 1000)) {
      return null;
    }

    return {
      userId: decoded.sub,
      role: decoded.role,
      expiresAt: new Date(decoded.exp * 1000).toISOString(),
    };
  },

  issueAdminSession(adminSecret: string) {
    const expected = process.env.ADMIN_DASHBOARD_SECRET ?? 'GPG-ADMIN-2026';
    if (adminSecret !== expected) {
      throw new Error('Invalid admin secret.');
    }

    return this.issueSessionToken({
      userId: 'admin-root',
      role: 'admin',
    });
  },
};