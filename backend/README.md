# GPG Global Backend (Node.js + TypeScript)

This backend is the production-ready foundation for moving from mock frontend data to real infrastructure.

## Implemented Core Capabilities

- Phone OTP auth flow (`sendPhoneOtp`, `verifyPhoneOtp`) via Supabase + internal OTP ledger.
- Relational PostgreSQL schema (Prisma) linking users to:
  - Missions
  - Pathway status
  - LGA/state
  - Marketplace/payment status
- Privacy vault:
  - AES-256-GCM encryption for Genotype/Blood Group
  - grant/revoke authorization toggles per sensitive field
- Mission peer search engine:
  - mission suggestions by text query
  - mission match count query
  - Neo4j graph query hook for service-year relationship search
- Marketplace payment monetization:
  - Stripe checkout + webhook updates to `LIVE_PROFESSIONAL`
  - Flutterwave webhook updates
  - Admin merit override -> `MERIT_GRANTED`
- AI Safety guardrails:
  - Llama 4 moderation endpoint integration
  - automatic moderation flags + control-room red-flag event pipeline
- API & real-time:
  - GraphQL (Apollo)
  - Socket.io room chat and admin red-flag push events

## Tech Stack

- API: Node.js + TypeScript + Apollo GraphQL + Express
- Realtime: Socket.io
- Relational DB: PostgreSQL (Supabase-ready) + Prisma ORM
- Social graph hook: Neo4j driver
- Payments: Stripe + Flutterwave webhooks

## Local Setup

1. Copy env file:

```bash
cp .env.example .env
```

2. Install dependencies:

```bash
npm install
```

3. Generate Prisma client and push schema:

```bash
npm run prisma:generate
npm run prisma:push
```

4. Run in dev mode:

```bash
npm run dev
```

## GraphQL Endpoint

- `http://localhost:4100/graphql`

### Example Mutations

- Send OTP
- Verify OTP
- Set user profile + mission/pathway
- Grant/revoke sensitive field access
- Create marketplace checkout
- Grant merit override
- Send chat message (with moderation)

## Control Room Signal

Whenever moderation finds a violation, backend emits:

- Socket event: `control-room:red-flag`

Payload includes severity, reason, label, room, and message id.
