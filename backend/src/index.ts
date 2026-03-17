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
    context: async ({ req }) => {
      return {
        userId: (req.headers['x-user-id'] as string | undefined) ?? 'anonymous'
      };
    }
  })
);

const httpServer = createServer(app);
createSocketServer(httpServer);

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
