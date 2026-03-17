import Stripe from 'stripe';
import { ProfessionalStatus } from '@prisma/client';
import { env } from '../config/env.js';
import { prisma } from '../lib/prisma.js';

const stripe = new Stripe(env.STRIPE_SECRET_KEY);

export const paymentService = {
  async createMarketplaceCheckout(userId: string) {
    const session = await stripe.checkout.sessions.create({
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

    const event = stripe.webhooks.constructEvent(rawBody, signature, env.STRIPE_WEBHOOK_SECRET);

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
