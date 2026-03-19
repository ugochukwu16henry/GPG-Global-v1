import axios from 'axios';
import { ChatViolationSeverity } from '@prisma/client';
import { env } from '../config/env.js';

type ModerationResult = {
  violates: boolean;
  severity: ChatViolationSeverity;
  reason: string;
  label: string;
};

export const moderationService = {
  async moderateMessage(text: string): Promise<ModerationResult> {
    if (!env.LLAMA4_MODERATION_URL || !env.LLAMA4_MODERATION_API_KEY) {
      return {
        violates: false,
        severity: ChatViolationSeverity.LOW,
        reason: 'Moderation service not configured',
        label: 'unconfigured'
      };
    }

    const response = await axios.post(
      env.LLAMA4_MODERATION_URL,
      { text, policy: 'gpg-gospel-standards' },
      {
        headers: {
          Authorization: `Bearer ${env.LLAMA4_MODERATION_API_KEY}`
        },
        timeout: 5000
      }
    );

    const data = response.data as {
      violates?: boolean;
      severity?: ChatViolationSeverity;
      reason?: string;
      label?: string;
    };

    return {
      violates: data.violates ?? false,
      severity: data.severity ?? ChatViolationSeverity.LOW,
      reason: data.reason ?? 'No violation',
      label: data.label ?? 'clean'
    };
  }
};
