# Roadmap: Teto Locadora — Plataforma de Agentes de IA

## Overview

Build the platform in four phases along its natural dependency chain. The foundation (auth, CRM, data model) must exist before any messaging can be stored. Messaging infrastructure must work before the AI agent has anything to act on. The AI agent and lead distribution are the platform's core value and ship together as Phase 3. Instagram, dashboards, and the external API ship last — Instagram because it is blocked on Meta App Review, dashboards because they require live data from the preceding phases, and the API because it surfaces data that must exist first.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation & CRM** - Auth, user roles, database schema, RLS, and full CRM kanban with pipeline management
- [ ] **Phase 2: Messaging Infrastructure** - Multi-inbox WhatsApp (Evolution API + Meta Cloud API), unified conversation UI, real-time updates
- [ ] **Phase 3: AI Agents & Lead Distribution** - Configurable AI agents with CRM tool-calling, human takeover, round-robin lead distribution
- [ ] **Phase 4: Instagram, Dashboards & API** - Instagram DMs, real-time monitoring, analytics dashboards, REST API and webhooks

## Phase Details

### Phase 1: Foundation & CRM
**Goal**: Managers and sellers can log in, manage users, and work leads through configurable CRM pipelines
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, AUTH-07, CRM-01, CRM-02, CRM-03, CRM-04, CRM-05, CRM-06, CRM-07, CRM-08, CRM-09, CRM-10, CRM-11
**Success Criteria** (what must be TRUE):
  1. User can log in with email/password and stay logged in across browser refreshes
  2. Manager can invite users and assign them the manager or seller role; deactivated users cannot log in
  3. Seller can only see leads and conversations assigned to them; manager can see everything
  4. Manager can create multiple pipelines with named, reorderable stages; user can drag leads between stages on a kanban board
  5. Every action on a lead (create, edit, move, AI action) appears in the lead's activity log with who/what/when
**Plans**: TBD

Plans:
- [ ] 01-01: Auth, user management, and RLS setup
- [ ] 01-02: CRM pipelines, stages, and lead CRUD
- [ ] 01-03: Kanban UI, activity log, and lead detail view

### Phase 2: Messaging Infrastructure
**Goal**: Users can send and receive WhatsApp messages across multiple inboxes with real-time updates in a unified conversation UI
**Depends on**: Phase 1
**Requirements**: CHAT-01, CHAT-02, CHAT-03, CHAT-04, CHAT-06, CHAT-07, CHAT-08, CHAT-09, CHAT-10
**Success Criteria** (what must be TRUE):
  1. Manager can connect multiple WhatsApp numbers; each number has its own inbox with its own conversation list
  2. User can send and receive WhatsApp messages via both Evolution API and Meta Cloud API; messages arrive without page refresh
  3. User can filter the conversation list by inbox, status, and assignment; conversations show sent/delivered/read indicators
  4. User can send and receive file and image attachments; internal notes are visible to team members but not the lead
**Plans**: TBD

Plans:
- [ ] 02-01: WhatsApp webhook receivers, Edge Functions, and dual-API send/receive
- [ ] 02-02: Inbox UI, conversation list, message thread, real-time Realtime channel, and attachments

### Phase 3: AI Agents & Lead Distribution
**Goal**: The AI SDR agent qualifies leads autonomously via WhatsApp, manages the CRM without human intervention, and distributes ready leads to sellers in round-robin rotation
**Depends on**: Phase 2
**Requirements**: AGENT-01, AGENT-02, AGENT-03, AGENT-04, AGENT-05, AGENT-06, AGENT-07, AGENT-08, AGENT-09, AGENT-10, AGENT-11, AGENT-12, DIST-01, DIST-02, DIST-03, DIST-04, DIST-05
**Success Criteria** (what must be TRUE):
  1. Manager can create and configure an AI agent (name, type, system prompt, model, qualification rules, handoff rules) and assign it to one or more inboxes
  2. When a new WhatsApp message arrives on an agent-enabled inbox, the agent responds autonomously using its configured prompt and rules
  3. The agent can create, edit, and move CRM leads between stages using tool calls; all AI actions are logged and soft-deleted only
  4. Seller can take over a conversation (AI stops responding); manager can re-enable AI on that conversation
  5. When the agent determines a lead is qualified, the lead is automatically assigned to the next available seller in round-robin rotation; offline sellers are skipped; seller receives a real-time notification with an AI-generated qualification summary
**Plans**: TBD

Plans:
- [ ] 03-01: Agent configuration UI and agent CRUD
- [ ] 03-02: Agent orchestrator Edge Function with CRM tool-calling and guardrails
- [ ] 03-03: Lead distribution engine (round-robin, skip-offline, notifications, qualification summary)

### Phase 4: Instagram, Dashboards & API
**Goal**: The platform is fully observable via dashboards, exposes data via REST API and webhooks, and supports Instagram DMs as a second channel
**Depends on**: Phase 3
**Requirements**: CHAT-05, DASH-01, DASH-02, DASH-03, DASH-04, API-01, API-02, API-03, API-04
**Success Criteria** (what must be TRUE):
  1. Manager can view a real-time monitoring dashboard showing active agents, open conversations, conversations in progress, and the handoff queue
  2. Manager can view pipeline funnel analytics (lead conversion rates per stage), seller performance metrics, and agent performance metrics
  3. User can receive and reply to Instagram DMs; Instagram conversations appear in the unified inbox alongside WhatsApp
  4. External systems can read and write leads and contacts via REST API authenticated with API keys; webhook events fire on lead status changes; manager can configure webhook destinations in the UI
**Plans**: TBD

Plans:
- [ ] 04-01: Dashboards (monitoring + analytics)
- [ ] 04-02: REST API, API key auth, and webhook engine
- [ ] 04-03: Instagram DM integration (webhook-instagram Edge Function + inbox channel)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & CRM | 0/3 | Not started | - |
| 2. Messaging Infrastructure | 0/2 | Not started | - |
| 3. AI Agents & Lead Distribution | 0/3 | Not started | - |
| 4. Instagram, Dashboards & API | 0/3 | Not started | - |
