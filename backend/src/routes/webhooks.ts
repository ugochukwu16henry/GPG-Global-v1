import { Router } from 'express';
import { paymentService } from '../services/paymentService.js';

export const webhooksRouter = Router();

webhooksRouter.post('/stripe', async (req, res) => {
  try {
    await paymentService.handleStripeEvent(req.body as Buffer, req.headers['stripe-signature'] as string | undefined);
    res.status(200).json({ received: true });
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

webhooksRouter.post('/flutterwave', async (req, res) => {
  try {
    await paymentService.handleFlutterwaveEvent(
      req.body,
      req.headers['verif-hash'] as string | undefined
    );
    res.status(200).json({ received: true });
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});
