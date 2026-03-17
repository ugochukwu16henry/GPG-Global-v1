import crypto from 'crypto';
import { SensitiveField } from '@prisma/client';
import { env } from '../config/env.js';
import { prisma } from '../lib/prisma.js';

const encryptionKey = Buffer.from(env.VAULT_ENCRYPTION_KEY_HEX, 'hex');

function encrypt(plainText: string): string {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', encryptionKey, iv);
  const ciphertext = Buffer.concat([cipher.update(plainText, 'utf8'), cipher.final()]);
  const authTag = cipher.getAuthTag();
  return Buffer.concat([iv, authTag, ciphertext]).toString('base64');
}

function decrypt(payload: string): string {
  const data = Buffer.from(payload, 'base64');
  const iv = data.subarray(0, 12);
  const authTag = data.subarray(12, 28);
  const ciphertext = data.subarray(28);

  const decipher = crypto.createDecipheriv('aes-256-gcm', encryptionKey, iv);
  decipher.setAuthTag(authTag);
  const plainText = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
  return plainText.toString('utf8');
}

export const privacyVaultService = {
  async updateSensitiveFields(userId: string, genotype?: string, bloodGroup?: string) {
    return prisma.user.update({
      where: { id: userId },
      data: {
        genotypeCiphertext: genotype ? encrypt(genotype) : undefined,
        bloodGroupCiphertext: bloodGroup ? encrypt(bloodGroup) : undefined
      }
    });
  },

  async grantFieldAccess(ownerUserId: string, viewerUserId: string, field: SensitiveField) {
    return prisma.privacyGrant.upsert({
      where: {
        id: `${ownerUserId}:${viewerUserId}:${field}`
      },
      create: {
        id: `${ownerUserId}:${viewerUserId}:${field}`,
        ownerUserId,
        viewerUserId,
        field
      },
      update: {
        revokedAt: null
      }
    });
  },

  async revokeFieldAccess(ownerUserId: string, viewerUserId: string, field: SensitiveField) {
    return prisma.privacyGrant.updateMany({
      where: {
        ownerUserId,
        viewerUserId,
        field,
        revokedAt: null
      },
      data: {
        revokedAt: new Date()
      }
    });
  },

  async readSensitiveField(requestingUserId: string, ownerUserId: string, field: SensitiveField) {
    if (requestingUserId !== ownerUserId) {
      const grant = await prisma.privacyGrant.findFirst({
        where: {
          ownerUserId,
          viewerUserId: requestingUserId,
          field,
          revokedAt: null
        }
      });
      if (!grant) {
        return null;
      }
    }

    const user = await prisma.user.findUnique({ where: { id: ownerUserId } });
    if (!user) {
      return null;
    }

    if (field === SensitiveField.GENOTYPE && user.genotypeCiphertext) {
      return decrypt(user.genotypeCiphertext);
    }
    if (field === SensitiveField.BLOOD_GROUP && user.bloodGroupCiphertext) {
      return decrypt(user.bloodGroupCiphertext);
    }
    return null;
  },

  async setVisibility(userId: string, fieldKey: string, visibility: 'EVERYONE' | 'CONNECTIONS' | 'ONLY_ME') {
    await prisma.fieldVisibility.upsert({
      where: {
        userId_fieldKey: {
          userId,
          fieldKey
        }
      },
      create: {
        userId,
        fieldKey,
        visibility
      },
      update: {
        visibility
      }
    });

    return true;
  },

  async canViewField({
    ownerUserId,
    requestingUserId,
    fieldKey,
  }: {
    ownerUserId: string;
    requestingUserId: string;
    fieldKey: string;
  }) {
    if (ownerUserId === requestingUserId) {
      return true;
    }

    const setting = await prisma.fieldVisibility.findUnique({
      where: {
        userId_fieldKey: {
          userId: ownerUserId,
          fieldKey
        }
      }
    });

    const visibility = setting?.visibility ?? 'ONLY_ME';
    if (visibility === 'ONLY_ME') {
      return false;
    }
    if (visibility === 'EVERYONE') {
      return true;
    }

    return prisma.privacyGrant
      .findFirst({
        where: {
          ownerUserId,
          viewerUserId: requestingUserId,
          revokedAt: null
        }
      })
      .then((grant) => grant != null);
  }
};
