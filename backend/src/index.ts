import express from 'express';
import cors from 'cors';
import { createServer } from 'node:http';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@as-integrations/express5';
import { env } from './config/env.js';
import { typeDefs, resolvers } from './graphql/schema.js';
import { healthRouter } from './routes/health.js';
import { webhooksRouter } from './routes/webhooks.js';
import { createSocketServer } from './realtime/socketServer.js';
import { prisma } from './lib/prisma.js';
import { neo4jDriver } from './lib/neo4j.js';
import { gatheringService } from './services/gatheringService.js';
import { sessionService } from './services/sessionService.js';
import { storageService } from './services/storageService.js';

const app = express();

app.use(
  cors({
    origin: env.CLIENT_ORIGIN,
    credentials: true
  })
);

app.use('/health', healthRouter);
app.use('/webhooks/stripe', express.raw({ type: 'application/json' }));
app.use('/webhooks', express.json());
app.use('/webhooks', webhooksRouter);

const apollo = new ApolloServer({
  typeDefs,
  resolvers
});

await apollo.start();

app.use(
  '/graphql',
  express.json(),
  expressMiddleware(apollo, {
    context: async ({ req }: { req: any }) => {
      const token = (req.headers['x-auth-token'] as string | undefined) ?? null;
      const verified = sessionService.verifySessionToken(token);
      const headerUserId = (req.headers['x-user-id'] as string | undefined) ?? 'anonymous';

      const userId = verified?.userId ?? headerUserId;
      const role = verified?.role ?? (headerUserId == 'anonymous' ? 'guest' : 'user');

      return {
        userId,
        role,
      };
    }
  })
);

const httpServer = createServer(app);
createSocketServer(httpServer);

await gatheringService.ensureGlobalCommunity();
await storageService.ensureBucketsExist();

httpServer.listen(env.PORT, () => {
  console.log(`GPG Backend listening on :${env.PORT}`);
  console.log(`GraphQL: http://localhost:${env.PORT}/graphql`);
});

async function shutdown() {
  await prisma.$disconnect();
  await neo4jDriver.close();
  process.exit(0);
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
