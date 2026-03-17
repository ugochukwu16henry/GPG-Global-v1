import crypto from 'crypto';
import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env.js';
import { prisma } from '../lib/prisma.js';

const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);

function hashOtp(value: string) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

function generateOtpCode() {
  return `${Math.floor(100000 + Math.random() * 900000)}`;
}

export const authService = {
  async sendPhoneOtp(phone: string) {
    const otpCode = generateOtpCode();
    const otpCodeHash = hashOtp(otpCode);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await prisma.authOtp.create({
      data: { phone, otpCodeHash, expiresAt }
    });

    await supabase.auth.signInWithOtp({ phone });

    return {
      phone,
      expiresAt,
      devOtpPreview: env.NODE_ENV === 'development' ? otpCode : undefined
    };
  },

  async verifyPhoneOtp(phone: string, otpCode: string) {
    const latest = await prisma.authOtp.findFirst({
      where: {
        phone,
        verifiedAt: null,
        expiresAt: { gt: new Date() }
      },
      orderBy: { createdAt: 'desc' }
    });

    if (!latest) {
      throw new Error('OTP expired or not found.');
    }

    if (latest.otpCodeHash !== hashOtp(otpCode)) {
      throw new Error('Invalid OTP code.');
    }

    const user = await prisma.user.upsert({
      where: { phone },
      update: {},
      create: {
        phone,
        displayName: 'New User'
      }
    });

    await prisma.authOtp.update({
      where: { id: latest.id },
      data: {
        verifiedAt: new Date(),
        userId: user.id
      }
    });

    return { user };
  }
};
