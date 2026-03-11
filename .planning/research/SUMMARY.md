# Project Research Summary

**Project:** Teto Locadora AI Agent Platform
**Domain:** AI Agent Platform — CRM, Multi-Channel Chat (WhatsApp + Instagram), SDR/Sales/Support Automation
**Researched:** 2026-03-11
**Confidence:** MEDIUM

## Executive Summary

This is an internal AI agent platform for an equipment rental company (Teto Locadora), built on the Lovable platform (React + Supabase). The system automates lead qualification via WhatsApp and Instagram using GPT-4o/GPT-4o-mini agents, feeds qualified leads into a CRM with pipeline management, and distributes them to human sales reps via round-robin assignment. The established pattern for this class of product is: async webhook ingestion → AI orchestration in Edge Functions → Postgres as authoritative state → Realtime broadcast to React UI. There is no separate application server — all backend logic lives in Supabase Edge Functions co-located with the database.

The recommended approach is to build sequentially along the critical dependency path: Auth/foundation → CRM → Inbox UI → WhatsApp integration → AI agent (with guardrails) → Lead distribution → Instagram → Dashboards → Hardening. The AI agent must be built with a human takeover mechanism and CRM guardrails before it is granted write access to any CRM data — skipping this step is the most dangerous technical risk in the project. The CRM and inbox infrastructure must exist before the agent can be useful, making them true blockers.

The key risks are external and architectural: (1) Instagram's `instagram_manage_messages` App Review must be submitted on day one, before any development begins, as approval takes 1-4 weeks and is commonly rejected on first submission; (2) the WhatsApp 24-hour customer service window must be architectured in from the start — retrofitting it is painful; (3) Evolution API numbers can be banned for bot-like behavior, so the Official Meta API should be the primary production channel; (4) OpenAI costs can spiral without conversation summarization and model tiering (GPT-4o-mini for SDR, GPT-4o for complex decisions). These are not speculative risks — they are predictable failure modes with well-documented mitigations.

---

## Key Findings

### Recommended Stack

The stack is substantially fixed by Lovable: React 18.3.1 + TypeScript 5.8.3 + Vite 5.4.19 + Tailwind + shadcn/ui on the frontend; Supabase (Postgres, Auth, Realtime, Edge Functions, Storage) on the backend. The variable decisions are: TanStack React Query 5.83.0 for server state (not Redux — massively over-engineered for 10-50 users), Zustand for ephemeral UI state, OpenAI SDK v4.x running in Deno Edge Functions, and a dual WhatsApp strategy using Evolution API v2.x for dev/low-volume and Meta Cloud API v19+ for production compliance. Instagram uses Meta Graph API v19+.

Explicitly avoid: Prisma/Drizzle (breaks RLS in Edge Functions), custom WebSocket servers (Supabase Realtime replaces them), LangChain.js (heavy abstraction for a controlled GPT workflow — use the OpenAI SDK directly), and Next.js (incompatible with Lovable's Vite SPA output).

**Core technologies:**
- React + Supabase JS: Fixed by Lovable — SPA frontend connected to single BaaS that handles auth, database, realtime, and serverless functions
- TanStack React Query 5.83.0: Server state management — optimistic updates on kanban drags, background refetch, query invalidation after AI CRM writes
- OpenAI SDK v4.x (in Deno): AI calls from Edge Functions only — never from the browser
- Evolution API v2.x: WhatsApp integration for dev and low-volume production; unofficial but zero-cost
- Meta Cloud API v19+ (WhatsApp + Instagram): Official channel integration required for compliance at scale
- Supabase Realtime: Postgres CDC replaces custom WebSocket infrastructure for live chat and notifications
- Zod + React Hook Form: Schema validation for agent configs, webhook payloads, CRM fields

### Expected Features

The platform must implement table stakes across seven categories: AI agent management, multi-channel chat (inbox), CRM, lead distribution, multi-user with RBAC, dashboards, and API/webhooks. Beyond table stakes, the features that make this platform valuable and should ship in v1 are: AI qualification rules and handoff rules, multi-inbox (multiple WhatsApp numbers), AI-managed pipeline (agent autonomously moves CRM cards), qualification summary on handoff, and a real-time monitoring dashboard.

**Must have (table stakes):**
- AI agent CRUD with system prompt, model selection, inbox assignment
- Unified inbox — all channels in one view with real-time updates
- WhatsApp send/receive with message status indicators
- CRM kanban board with multiple pipelines, drag-and-drop stages, lead CRUD
- Round-robin lead assignment with skip-offline logic
- Manager and seller roles with RLS-enforced access separation
- Login/logout with user management

**Should have (v1 differentiators):**
- AI qualification rules + handoff rules (core product value)
- Multi-inbox support (multiple WhatsApp numbers per account)
- Instagram DM integration
- AI-managed pipeline — agent moves kanban cards autonomously
- Qualification summary generated by AI on handoff to seller
- Seller availability toggle (online/offline)
- Real-time monitoring dashboard with live conversation feed
- Internal notes on conversations (not visible to lead)
- Activity log per lead

**Defer (v2+):**
- Agent knowledge base with RAG (document upload + embeddings)
- A/B testing agent prompts
- Custom fields per pipeline
- Lead scoring engine
- Weighted distribution (senior sellers get more leads)
- Export reports (CSV/PDF)
- Custom role permissions (granular RBAC beyond manager/seller)

**Anti-features (do not build):**
- Visual flow builder (Botpress-style) — prompt-based agents make this redundant
- Email channel — not requested, disproportionate complexity
- SSO/SAML — internal tool with <50 users
- GraphQL API — REST is sufficient for internal use

### Architecture Approach

The architecture is serverless with no separate application server. Supabase Edge Functions serve as the backend compute layer, co-located with the Postgres database. External channels (WhatsApp via Evolution/Meta, Instagram via Graph API) deliver webhooks to Edge Functions, which must respond within 5 seconds — so they acknowledge receipt immediately and invoke the AI orchestrator asynchronously using `EdgeRuntime.waitUntil`. The React SPA communicates with Supabase directly via the supabase-js client using JWT-authenticated PostgREST queries, with Postgres RLS enforcing row-level access control at the database layer (not in application code). Real-time updates flow via Supabase Realtime's Postgres CDC channels.

**Major components:**
1. Webhook Receivers (`webhook-whatsapp`, `webhook-instagram`) — validate signature, normalize payload, write to `messages` table, fire-and-forget orchestrator invocation
2. Agent Orchestrator — load context, call OpenAI with CRM function tools (`create_lead`, `move_lead_to_stage`, `qualify_lead`, `request_human_handoff`), execute tool calls, save AI reply, send back via channel API
3. Lead Distributor — triggered by Postgres on `leads.status = 'qualified'`, performs atomic `SELECT FOR UPDATE` round-robin assignment
4. React Frontend (3 views) — Manager (full access), Seller (own leads only), Monitoring (live dashboard)
5. Supabase Postgres — authoritative state for all application data, RLS enforces role separation, CDC feeds Realtime

### Critical Pitfalls

1. **WhatsApp 24-hour session window not architectured in** — After 24 hours since last inbound message, only pre-approved Message Templates can be sent. Must store `last_inbound_at` per conversation, check before every AI outbound message, and have approved re-engagement templates before launch. Address in the WhatsApp integration phase.

2. **Evolution API phone number bans** — Unofficial protocol triggers WhatsApp anti-spam. Mitigate with randomized send delays (1-4s), daily message caps, and using Meta Cloud API as the primary production channel. Reserve Evolution API for dev/testing.

3. **AI agent without guardrails gets CRM write access** — Agents will inevitably corrupt records or loop on re-qualification without a human takeover flag, confidence scoring, and soft-delete-only operations. Guardrails must be built before CRM write tools are activated.

4. **Supabase RLS not designed for dual human/agent access** — Service role key must only exist in Edge Functions, never in client bundles. RLS policies must be audited for USING(true) on sensitive tables.

5. **OpenAI cost spiral from full history in every call** — At 100+ active leads with 10+ turn histories, GPT-4o costs reach $50-200/day. Mitigate with GPT-4o-mini for SDR, conversation summarization after 10 turns, and a per-conversation token budget.

6. **Webhook reliability — missed events** — Meta stops delivering if endpoint returns non-200 or exceeds 20s timeout. Must use async pattern: insert raw payload to `webhook_events` table, return 200 immediately, process from queue.

7. **Instagram Meta App Review takes weeks** — Submit `instagram_manage_messages` permission request on day one. Build Instagram integration last; it will be blocked until approved.

---

## Implications for Roadmap

Based on combined research, the architecture's dependency chain and pitfall timing requirements directly dictate phase structure. The critical dependency path is: Foundation → CRM → Inbox → WhatsApp → AI Agent → Lead Distribution → Instagram → Dashboards → Hardening.

### Phase 0: Pre-Development Actions (Day 1)
**Rationale:** Two external blockers have multi-week lead times and must start before development. Failing to do this on day 1 delays the entire Instagram integration.
**Delivers:** Meta app review submitted; Instagram dev timeline is known
**Addresses:** Pitfall 7 (Instagram approval delay)
**Actions:** Submit Meta App Review for `instagram_manage_messages`; set up Facebook Business Manager and connected Instagram Professional account; prepare demo video for review submission.

### Phase 1: Foundation
**Rationale:** All subsequent phases depend on auth, database schema, and RLS. This is also where the dual human/agent access pattern must be established — retrofitting RLS is costly.
**Delivers:** Working auth with manager/seller roles, full DB schema, RLS policies, app shell with routing
**Addresses:** Auth, user management, pipelines CRUD, basic user invite flow
**Avoids:** Pitfall 4 (RLS dual access) — design service-role-only Edge Function pattern from the start; no `supabaseAdmin` in client code ever

### Phase 2: CRM Core
**Rationale:** CRM is a hard dependency for the AI agent — the agent cannot write to a pipeline that doesn't exist. Build and validate CRM data flows before introducing AI complexity.
**Delivers:** Kanban boards with drag-and-drop, multiple pipelines, lead CRUD, stage management, lead search/filter, seller-filtered views
**Uses:** Framer Motion (drag), TanStack React Query (optimistic updates), Supabase Realtime (live kanban sync)
**Implements:** Leads, pipelines, pipeline_stages, lead_field_values tables; sellers_own_leads RLS policy

### Phase 3: Inbox & Messaging UI
**Rationale:** WhatsApp integration (Phase 4) needs a working conversation UI to be testable. Build the inbox shell first with mock data, then connect real channel data.
**Delivers:** Unified inbox, conversation list with search/filter, message thread view, real-time message updates via Realtime, conversation assignment UI
**Implements:** Conversations, messages tables; Realtime channel for messages; Zustand for active conversation state

### Phase 4: WhatsApp Integration
**Rationale:** WhatsApp is the primary channel and must be production-ready before the AI agent is introduced. The 24-hour session window and async webhook pattern must be correct from first commit.
**Delivers:** Full WhatsApp send/receive via Evolution API (dev) and Meta Cloud API (production), message status indicators, multi-inbox support, file/image attachments
**Uses:** Supabase Edge Functions (webhook-whatsapp), Meta Cloud API v19+, Evolution API v2.x
**Avoids:** Pitfall 1 (24h session window) — implement `last_inbound_at` check and template fallback; Pitfall 2 (Evolution bans) — randomized delays, rate limits, Official API as primary; Pitfall 6 (webhook reliability) — async pattern, raw payload storage
**Research flag:** Needs phase research — Evolution API v2 compatibility with current WhatsApp protocol should be verified against GitHub activity before committing to it.

### Phase 5: AI Agent Core
**Rationale:** AI agent is the platform's core value proposition but requires CRM, Inbox, and WhatsApp to be in place. Guardrails and human takeover must be built before CRM write tools are activated — this is not optional.
**Delivers:** Agent config UI (system prompt, model, qualification rules, handoff rules), agent-orchestrator Edge Function with CRM tool calling, human takeover flag, AI action audit log, conversation summarization, model tiering (GPT-4o-mini for SDR)
**Uses:** OpenAI SDK v4.x in Deno, function calling with `create_lead` / `update_lead_field` / `move_lead_to_stage` / `qualify_lead` / `request_human_handoff` tools
**Avoids:** Pitfall 3 (AI rogue) — human takeover, soft-delete only, no-fly zones (AI cannot delete); Pitfall 5 (OpenAI cost) — GPT-4o-mini for SDR, summarization after turn 10

### Phase 6: Lead Distribution
**Rationale:** Depends on AI agent's `qualify_lead` tool being operational. The Postgres trigger + atomic round-robin must be tested with concurrent load.
**Delivers:** Round-robin lead assignment, skip-offline-seller logic, seller availability toggle, assignment notifications via Realtime, AI-generated qualification summary on handoff
**Implements:** lead_distribution_queue table, SELECT FOR UPDATE locking, Postgres trigger on leads.status = 'qualified', notifications table + Realtime channel
**Avoids:** Performance trap (round-robin double-assignment under concurrency)

### Phase 7: Instagram DMs
**Rationale:** Built last because Meta App Review (Phase 0) determines when this can ship. WhatsApp must be fully functional independently — Instagram is additive, not critical-path.
**Delivers:** Instagram DM send/receive via Meta Graph API, webhook-instagram Edge Function, channel appearing in unified inbox
**Dependency:** Meta app review approved (submitted Phase 0, expected 1-4 weeks)
**Research flag:** No additional research needed — same webhook/realtime pattern as WhatsApp. The blocker is approval, not implementation complexity.

### Phase 8: Dashboards & Analytics
**Rationale:** Depends on live data from agents, conversations, and leads. Build after the data-generating systems are stable.
**Delivers:** Real-time monitoring dashboard (live agent status, open conversations, handoff queue), agent performance metrics, seller performance, pipeline funnel analytics with Recharts
**Uses:** Recharts 2.15.4, TanStack React Query for analytics queries, Supabase Realtime for live feed

### Phase 9: Hardening
**Rationale:** Security and reliability audit after all features are in place. Covers the complete checklist from PITFALLS.md.
**Delivers:** Webhook signature validation audit, RLS coverage audit (no USING(true) on sensitive tables), OpenAI key confirmed in Supabase Vault, load test (20 simultaneous inbound messages), DB index audit for CRM query columns, rate limiting on Edge Functions
**Avoids:** All remaining security mistakes from PITFALLS.md

---

### Phase Ordering Rationale

- Phases 1-3 are pure infrastructure with no external dependencies — they can be built confidently before any API integrations complicate the picture.
- WhatsApp (Phase 4) precedes the AI agent (Phase 5) because the agent's first action is responding to WhatsApp messages. Testing the orchestrator without a real channel is incomplete.
- AI guardrails are embedded in Phase 5, not deferred — this is non-negotiable per PITFALLS.md Pitfall 3.
- Instagram is deliberately last (Phase 7) because it is blocked on external approval, not internal development capacity.
- Phase 0 is a pre-development action list, not a sprint — it has no code deliverables.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 4 (WhatsApp Integration):** Evolution API v2.x active maintenance and current WhatsApp protocol compatibility should be verified on GitHub before the integration phase begins. If Evolution API is stale, the dual-strategy defaults to Meta Cloud API only.
- **Phase 5 (AI Agent):** OpenAI SDK npm:openai import compatibility with Supabase Edge Functions (Deno) should be confirmed before writing orchestrator code. This is a known friction point.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Supabase Auth + RLS is extremely well-documented. No novel patterns.
- **Phase 2 (CRM Core):** Kanban with optimistic updates via React Query + Framer Motion is a standard pattern.
- **Phase 3 (Inbox UI):** Conversation UI with Supabase Realtime is standard.
- **Phase 6 (Lead Distribution):** Postgres SELECT FOR UPDATE round-robin is a well-known pattern.
- **Phase 8 (Dashboards):** Recharts + React Query is standard.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Core stack is fixed by Lovable (high confidence). Variable decisions (Evolution API v2, OpenAI in Deno) need pre-implementation verification before building. |
| Features | MEDIUM | Based on analysis of comparable platforms (Chatwoot, Respond.io, Intercom). Feature list aligns well with the domain but specific qualification rule requirements for equipment rental need client validation. |
| Architecture | HIGH | Architecture is derived from fixed Supabase constraints + established patterns. The async webhook decoupling, RLS design, and CRM tool-calling pattern are well-tested approaches. |
| Pitfalls | MEDIUM | WhatsApp/Instagram API behavior pitfalls are well-documented in community. OpenAI cost patterns are well-understood. Evolution API ban risk is empirically known but hard to quantify. |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Evolution API v2 health:** Verify GitHub activity and WhatsApp protocol compatibility before committing to dual WhatsApp strategy. If Evolution API is unmaintained, default to Meta Cloud API only from day one — this affects Phase 4 scope and cost structure.
- **OpenAI SDK in Deno:** Confirm `import npm:openai` works in current Supabase Edge Function runtime before writing orchestrator. If blocked, use fetch() directly against OpenAI API.
- **Client qualification rules:** The exact fields that constitute "qualified" for a rental lead (equipment type, rental period, budget, location) need to be defined with Teto Locadora before Phase 5. These drive the agent's system prompt and CRM schema.
- **Supabase Realtime + RLS on postgres_changes:** Verify that postgres_changes subscriptions correctly apply RLS filtering for the seller role. This is a known edge case that has changed across Supabase versions.
- **Meta App Review outcome:** Instagram development in Phase 7 is blocked until review is approved. If rejected on first submission, it delays Instagram by another 1-4 weeks. Build WhatsApp-only fallback as the "shippable" version.

---

## Sources

### Primary (HIGH confidence)
- Supabase official documentation — Auth, RLS, Edge Functions, Realtime patterns
- OpenAI API reference — Chat Completions, function calling, tool use
- Meta Graph API documentation v19+ — WhatsApp Cloud API, Instagram Messaging API

### Secondary (MEDIUM confidence)
- Chatwoot, Respond.io, Intercom feature analysis — feature expectations and table stakes
- Evolution API GitHub repository — WhatsApp unofficial protocol integration pattern
- Community patterns for Supabase + React Query + Realtime integration
- AI SDR tool analysis for qualification rules and handoff patterns

### Tertiary (LOW confidence — needs validation)
- Evolution API v2.x current WhatsApp protocol compatibility — verify against GitHub before Phase 4
- OpenAI npm:openai Deno import in Supabase Edge Functions — verify before Phase 5
- Supabase Realtime postgres_changes RLS filtering behavior — test before Phase 3 completion

---
*Research completed: 2026-03-11*
*Ready for roadmap: yes*
