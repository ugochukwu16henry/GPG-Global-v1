import Stripe from 'stripe';
import { ProfessionalStatus } from '@prisma/client';
import { env } from '../config/env.js';
import { prisma } from '../lib/prisma.js';

const stripe = env.STRIPE_SECRET_KEY ? new Stripe(env.STRIPE_SECRET_KEY) : null;

function ensureStripeConfigured() {
  if (!stripe) {
    throw new Error(
      'Stripe integration is not configured. Set STRIPE_SECRET_KEY to enable checkout/webhooks.'
    );
  }
  return stripe;
}

export const paymentService = {
  async createMarketplaceCheckout(userId: string) {
    const stripeClient = ensureStripeConfigured();
    const session = await stripeClient.checkout.sessions.create({
      mode: 'payment',
      payment_method_types: ['card'],
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: 'usd',
            product_data: { name: 'GPG Marketplace Listing Fee' },
            unit_amount: 200
          }
        }
      ],
      metadata: {
        userId,
        feeType: 'marketplace-listing'
      },
      success_url: `${env.CLIENT_ORIGIN}/payments/success`,
      cancel_url: `${env.CLIENT_ORIGIN}/payments/cancel`
    });

    return session.url;
  },

  async grantMeritOverride(userId: string, grantedByAdminId: string, reason: string) {
    await prisma.$transaction([
      prisma.meritOverride.upsert({
        where: { userId },
        create: { userId, grantedByAdminId, reason },
        update: { grantedByAdminId, reason }
      }),
      prisma.user.update({
        where: { id: userId },
        data: {
          professionalStatus: ProfessionalStatus.MERIT_GRANTED
        }
      })
    ]);

    return { success: true };
  },

  async handleStripeEvent(rawBody: Buffer, signature: string | undefined) {
    if (!signature) {
      throw new Error('Missing Stripe signature');
    }

    const stripeClient = ensureStripeConfigured();
    if (!env.STRIPE_WEBHOOK_SECRET) {
      throw new Error('Stripe webhook is not configured. Set STRIPE_WEBHOOK_SECRET.');
    }

    const event = stripeClient.webhooks.constructEvent(rawBody, signature, env.STRIPE_WEBHOOK_SECRET);

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const userId = session.metadata?.userId;
      if (!userId) {
        return;
      }

      await prisma.$transaction([
        prisma.paymentEvent.create({
          data: {
            userId,
            provider: 'stripe',
            amountUsd: 2,
            externalRef: session.id,
            status: session.payment_status ?? 'paid',
            metadata: session as unknown as object
          }
        }),
        prisma.user.update({
          where: { id: userId },
          data: { professionalStatus: ProfessionalStatus.LIVE_PROFESSIONAL }
        })
      ]);
    }
  },

  async handleFlutterwaveEvent(eventBody: any, signature: string | undefined) {
    if (!env.FLUTTERWAVE_SECRET_HASH) {
      throw new Error('Flutterwave integration is not configured. Set FLUTTERWAVE_SECRET_HASH.');
    }
    if (signature !== env.FLUTTERWAVE_SECRET_HASH) {
      throw new Error('Invalid Flutterwave signature hash.');
    }

    const { tx_ref: txRef, status, amount, currency, meta } = eventBody?.data ?? {};
    if (!txRef || !meta?.userId) {
      return;
    }

    await prisma.$transaction([
      prisma.paymentEvent.create({
        data: {
          userId: meta.userId,
          provider: 'flutterwave',
          amountUsd: Number(amount ?? 2),
          currency: currency ?? 'USD',
          externalRef: txRef,
          status: status ?? 'successful',
          metadata: eventBody
        }
      }),
      prisma.user.update({
        where: { id: meta.userId },
        data: {
          professionalStatus: ProfessionalStatus.LIVE_PROFESSIONAL
        }
      })
    ]);
  }
};
