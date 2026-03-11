# Stack Research

**Domain:** AI Agent Platform — CRM, Multi-Channel Chat (WhatsApp + Instagram), SDR/Sales/Support Automation
**Researched:** 2026-03-11
**Confidence:** MEDIUM (external verification blocked; codebase confirmed + training data synthesis)

---

## Context & Constraints

This platform is built on **Lovable** — an AI development platform whose standard output is React + Supabase. The stack is therefore partially fixed:

- **Fixed:** React (frontend), Supabase (auth, database, storage, realtime, edge functions)
- **Chosen:** OpenAI GPT-4o / GPT-4o-mini (AI model — client decision)
- **Open:** WhatsApp/Instagram integration layer, AI orchestration pattern, state management approach

All library choices below are optimized to work within this constraint — not fight it.

---

## Recommended Stack

### Core Technologies (Fixed by Platform)

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| React | 18.3.1 | UI framework | Fixed by Lovable. Concurrent features (Suspense, transitions) needed for real-time chat UIs |
| TypeScript | 5.8.3 | Type safety | Fixed by Lovable. Critical for agent config schemas, CRM data models, webhook payloads |
| Supabase JS | 2.96.0 | BaaS client — auth, DB, storage, realtime, functions | Fixed by Lovable. Single SDK covers auth sessions, Postgres queries, realtime subscriptions, edge function invocations |
| Vite | 5.4.19 | Build tool and dev server | Fixed by Lovable. Fast HMR, ESM-native, optimal for SPA |
| Tailwind CSS | 3.4.17 | Utility-first styling | Fixed by Lovable. Works with shadcn/ui |
| shadcn/ui | latest | Accessible UI component primitives | Fixed by Lovable. Built on Radix UI — modal dialogs, command palettes, dropdowns, data tables all needed for CRM |

### State Management & Data Fetching

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| TanStack React Query | 5.83.0 | Server state, caching, sync | Critical for CRM — optimistic updates on lead moves, background refetch for live data, query invalidation after AI actions |
| Zustand | ~4.5 | Client-only UI state (modals, active agent, selected inbox) | Lightweight (1kb). Use for ephemeral UI state that doesn't belong in Supabase. Do NOT use for server state |

**Do NOT use Redux** — massively over-engineered for 10-50 users.

### Backend — Supabase Services

| Service | Purpose | Why |
|---------|---------|-----|
| Supabase Postgres | CRM data, agents config, conversations, leads, pipelines | Primary relational store. Row-level security (RLS) enforces role-based access (manager vs. seller) at DB layer |
| Supabase Auth | User sessions, JWT tokens, role claims | Custom claims (role: manager/seller) stored in JWT for RLS enforcement |
| Supabase Realtime | Live conversation updates, typing indicators, new message push, agent status | Postgres CDC via Realtime channels. Eliminates need for WebSocket server |
| Supabase Edge Functions (Deno) | Webhook receivers (WhatsApp/Instagram), AI orchestration, message routing | Serverless, co-located with DB. Only place to safely hold API secrets |
| Supabase Storage | Agent avatars, file attachments in chat, exported reports | S3-compatible, integrated with RLS |

### AI Layer

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| OpenAI Node SDK | ^4.x | GPT-4o/GPT-4o-mini API calls from Edge Functions | Client requirement. SDK runs in Deno via npm compat layer. Use streaming for responsive chat UX |

**Recommendation:** Start with Chat Completions API + manual context management in Supabase. Migrate to Assistants API if thread management becomes a bottleneck.

### WhatsApp Integration

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Evolution API | v2.x | WhatsApp integration via unofficial API | Self-hosted Node.js server. Supports multi-instance (one per connected WhatsApp number). Zero cost |
| Meta Cloud API (WhatsApp Business API) | v19+ | Official WhatsApp Business integration | Required for scale and compliance. Webhooks delivered to Supabase Edge Function |

**Dual-strategy:** Use Evolution API for zero-cost dev/testing and small volume. Meta Cloud API for production compliance. Both deliver to the same Supabase Edge Function — design a unified message adapter interface.

### Instagram DMs Integration

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Meta Graph API — Instagram Messaging | v19+ | Receive/send Instagram DMs via webhooks | Official API. Requires connected Facebook Page + Instagram Professional account |

**Critical:** `instagram_manage_messages` permission requires Meta App Review approval. Apply early — can take weeks.

### Forms & Validation

| Library | Version | Purpose |
|---------|---------|---------|
| React Hook Form | 7.61.1 | Agent config forms, CRM card editor, lead qualification rules |
| Zod | 3.25.76 | Schema validation — agent configs, webhook payloads, CRM field definitions |

### Real-Time UI & Data Visualization

| Library | Version | Purpose |
|---------|---------|---------|
| Recharts | 2.15.4 | Analytics dashboard — pipeline funnel, lead volume, agent performance |
| Framer Motion | 12.34.0 | CRM card drag, chat panel slide, agent status badges |
| Sonner | 1.7.4 | Toast notifications |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Redux / Redux Toolkit | Massive boilerplate for 10-50 users | TanStack React Query + Zustand |
| Custom WebSockets | Supabase Realtime provides WebSocket infrastructure | Supabase Realtime channels |
| Prisma / Drizzle | ORM breaks RLS integration; doesn't work in Edge Functions | supabase-js PostgREST client |
| Next.js | Incompatible with Lovable (Vite SPA) | Vite + React Router |
| LangChain.js | Heavy abstraction for a controlled GPT workflow | OpenAI SDK directly |
| Firebase | Redundant with Supabase | Supabase for everything |

---

## Stack Patterns by Scenario

**AI agent message handling:**
Incoming webhook (WhatsApp/Instagram) → Supabase Edge Function → validate + store in messages table → query conversation history → call OpenAI Chat Completions → store AI response → Realtime broadcasts to React UI → send reply back via WhatsApp/Instagram API

**CRM kanban (lead pipeline):**
Framer Motion drag → optimistic update via React Query → Supabase PATCH on leads.stage → Realtime notifies other users

**Round-robin lead distribution:**
Edge Function triggered by lead qualification event → query seller queue from Postgres → assign to next seller (service role bypasses RLS) → insert notification → Realtime pushes to assigned seller's UI

**Multi-inbox (multiple WhatsApp numbers):**
Each WhatsApp number is an inbox record → Evolution API instance per inbox → webhook URL includes inbox ID → Edge Function routes message to correct inbox/conversation

---

## Critical Pre-Implementation Verification

1. **Evolution API v2** — Check GitHub for active maintenance and current WhatsApp protocol compatibility
2. **Meta Instagram DM App Review** — Apply early, can take weeks
3. **OpenAI SDK in Deno** — Verify npm:openai import works in Supabase Edge Functions
4. **Supabase Realtime + RLS** — Verify RLS applies correctly to postgres_changes subscriptions
5. **Supabase Edge Function timeout** — Verify sufficient for OpenAI API calls; use streaming

---
*Stack research for: Teto Locadora AI Agent Platform*
*Researched: 2026-03-11*
