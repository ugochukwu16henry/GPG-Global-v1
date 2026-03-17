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
