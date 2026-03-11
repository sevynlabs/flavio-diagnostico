# Architecture Research

**Domain:** AI Agent Platform — CRM, Multi-Channel Chat (WhatsApp + Instagram), SDR/Sales/Support Automation
**Researched:** 2026-03-11
**Confidence:** HIGH (derived from fixed stack constraints + established Supabase patterns)

---

## Overview

The platform is a single-tenant internal tool for Teto Locadora. The architecture has three primary concerns:

1. **Inbound channel handling** — WhatsApp and Instagram messages arriving as webhooks
2. **AI agent execution** — GPT-4o processing conversation context and operating on CRM data
3. **Human-facing interfaces** — React UI for monitoring, CRM management, and seller workspaces

All backend logic lives in Supabase (Postgres + Edge Functions + Realtime). There is no separate application server.

---

## Component Map

```
External Channels
  ├── WhatsApp (Evolution API instance per inbox)
  ├── WhatsApp (Meta Cloud API)
  └── Instagram DMs (Meta Graph API)
          │
          │ webhooks (HTTPS POST)
          ▼
Supabase Edge Functions
  ├── webhook-whatsapp    (receive + normalize WA messages)
  ├── webhook-instagram   (receive + normalize IG messages)
  ├── agent-orchestrator  (AI reasoning loop)
  ├── lead-distributor    (round-robin assignment)
  └── crm-api             (external integration endpoint)
          │
          │ service role DB access (bypasses RLS)
          ▼
Supabase Postgres
  (all application data)
          │
          │ Postgres CDC (change data capture)
          ▼
Supabase Realtime
  (broadcasts to subscribed React clients)
          │
          ▼
React Frontend (Lovable/Vite SPA)
  ├── Inbox UI           (multi-inbox conversation view)
  ├── CRM Kanban         (pipeline boards per seller/manager)
  ├── Agent Config       (prompt, rules, qualification criteria)
  ├── Monitoring Dashboard (live agent + conversation status)
  └── Analytics Dashboard (pipeline funnel, performance)
          │
          │ supabase-js (PostgREST + Auth JWT)
          ▼
Supabase Postgres (user-role queries, filtered by RLS)

External Services (called from Edge Functions only)
  ├── OpenAI API         (GPT-4o / GPT-4o-mini)
  ├── Evolution API      (send WhatsApp messages back)
  └── Meta Graph API     (send Instagram DM replies)
```

---

## Component Boundaries

### 1. Webhook Receivers (Edge Functions)

Responsible for: receiving raw payloads from WhatsApp (both Evolution and Meta) and Instagram, validating signatures, normalizing messages into a unified internal format, and writing to the `messages` table.

**Boundary rule:** These functions only write data. They do not call OpenAI. After inserting the message, they invoke the `agent-orchestrator` function asynchronously.

**Why separated:** Webhook endpoints must respond within 5 seconds or the external service retries. AI calls can take 10-30 seconds.

### 2. Agent Orchestrator (Edge Function)

Responsible for: loading conversation history, loading agent configuration, calling OpenAI Chat Completions, parsing the AI response, executing CRM actions, and sending the reply back through the originating channel API.

**Boundary rule:** This is the only function that calls OpenAI. It uses the service role key to write CRM changes on behalf of the AI.

**Tool calling pattern:** Use OpenAI function calling to expose CRM actions as tools: `create_lead`, `update_lead_field`, `move_lead_to_stage`, `qualify_lead`, `request_human_handoff`. The orchestrator executes whichever tools the model invokes, then makes a second completion call if needed.

### 3. Lead Distributor (Edge Function)

Responsible for: round-robin assignment of a qualified lead to the next available seller. Triggered by a Postgres trigger on `leads.status` change to `qualified`.

**Round-robin state:** Maintained in a `lead_distribution_queue` table with a pointer to the last assigned seller. Atomic update via `SELECT ... FOR UPDATE` to prevent double-assignment.

### 4. React Frontend

Three distinct user experiences:

- **Manager view:** Full access — all inboxes, conversations, leads, dashboards, agent configuration.
- **Seller view:** Restricted — only their assigned leads and conversations.
- **Monitoring view:** Live dashboard showing active agents, open conversations, handoff queue.

Role enforcement via Postgres RLS — the frontend does not implement its own access control logic.

---

## Data Flow

### Flow 1: Inbound Message from Lead

```
1. Lead sends WhatsApp message
2. Evolution API / Meta Cloud API POSTs webhook to webhook-whatsapp Edge Function
3. Validate signature, normalize payload, find/create contact + conversation + lead
4. INSERT into messages table
5. Return 200 OK immediately
6. agent-orchestrator invoked async:
   a. Load agent config, conversation history, lead data
   b. Call OpenAI Chat Completions with CRM tools
   c. Execute tool calls (update lead, move stage, etc.)
   d. Save AI response to messages table
   e. Send reply to WhatsApp
7. Supabase Realtime broadcasts to subscribed React clients
```

### Flow 2: Lead Qualification and Distribution

```
1. Agent calls qualify_lead tool → sets lead.status = 'qualified'
2. Postgres trigger invokes lead-distributor
3. Round-robin: SELECT next seller FOR UPDATE, assign lead, advance pointer
4. INSERT notification for assigned seller
5. Realtime broadcasts to seller → toast notification
6. Seller opens conversation with full history
```

### Flow 3: Human Handoff

```
1. Agent calls request_human_handoff → conversation.status = 'waiting_human'
2. AI deactivated for this conversation (ai_active = false)
3. Agent sends: "Um de nossos especialistas vai te atender em breve."
4. Conversation appears in handoff queue
5. Manager or seller picks up — agent stops responding
```

---

## Database Schema Overview

### Key Tables

**`users`** — id, email, full_name, role (manager/seller), avatar_url

**`inboxes`** — id, name, channel (whatsapp_evolution/whatsapp_meta/instagram), external_id, webhook_secret, agent_id FK, is_active

**`agents`** — id, name, type (sdr/sales/support), system_prompt, model, temperature, max_history, qualification_rules (jsonb), handoff_rules (jsonb), is_active

**`contacts`** — id, channel, external_id (phone/IG user), name, UNIQUE(channel, external_id)

**`leads`** — id, contact_id FK, pipeline_id FK, stage_id FK, assigned_seller_id FK, status (new/in_progress/qualified/distributed/closed_won/closed_lost), ai_active, source

**`lead_field_values`** — id, lead_id FK, field_key, field_value, UNIQUE(lead_id, field_key)

**`conversations`** — id, contact_id FK, inbox_id FK, lead_id FK, status (open/waiting_human/closed), ai_active, last_message_at, UNIQUE(contact_id, inbox_id)

**`messages`** — id, conversation_id FK, role (user/assistant/system), content, channel, metadata (jsonb), ai_tokens_used

**`pipelines`** — id, name, description, is_default

**`pipeline_stages`** — id, pipeline_id FK, name, position, color

**`lead_distribution_queue`** — id, pipeline_id FK, last_assigned_seller_id FK, seller_order (jsonb)

**`notifications`** — id, user_id FK, type, payload (jsonb), read

---

## RLS Policies

```sql
-- Sellers see only their assigned leads
CREATE POLICY "sellers_own_leads" ON leads
  FOR SELECT USING (
    auth.jwt() ->> 'role' = 'manager'
    OR assigned_seller_id = auth.uid()
  );

-- Messages visible if user can see the conversation's lead
CREATE POLICY "sellers_own_messages" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversations c
      JOIN leads l ON c.lead_id = l.id
      WHERE c.id = messages.conversation_id
        AND (auth.jwt() ->> 'role' = 'manager' OR l.assigned_seller_id = auth.uid())
    )
  );
```

**Role claim in JWT:** Set `role` as custom claim in `auth.users.raw_app_meta_data`.

**Edge Functions use service role:** Bypasses RLS entirely. Only in server-side Edge Functions.

---

## Supabase Realtime Channels

**1. Conversation messages** — per conversation, filtered INSERT on messages table
**2. Leads pipeline** — per seller (or all for manager), filtered on leads table
**3. Notifications** — per user, INSERT on notifications table

---

## Edge Function Patterns

### Webhook Handler (async decoupling)

```typescript
// webhook-whatsapp: acknowledge fast, process later
Deno.serve(async (req) => {
  const isValid = await validateSignature(req)
  if (!isValid) return new Response('Unauthorized', { status: 401 })

  const message = normalizeWhatsAppPayload(await req.json())
  const { conversationId, leadId } = await upsertConversationContext(message)
  await supabaseAdmin.from('messages').insert({ ...message, conversation_id: conversationId })

  // Fire-and-forget orchestrator
  EdgeRuntime.waitUntil(
    fetch(`${SUPABASE_URL}/functions/v1/agent-orchestrator`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${SERVICE_ROLE_KEY}` },
      body: JSON.stringify({ conversationId, leadId })
    })
  )

  return new Response('OK', { status: 200 })
})
```

### Agent Orchestrator (tool calling loop)

```typescript
// Load context → call OpenAI with tools → execute tools → reply
const openAIMessages = buildMessages(agent, messages, lead)
const response = await openai.chat.completions.create({
  model: agent.model,
  messages: openAIMessages,
  tools: getCRMTools(),
  temperature: agent.temperature
})

if (response.choices[0].message.tool_calls) {
  await executeCRMToolCalls(response.choices[0].message.tool_calls, lead)
  // Second call for final reply text after tool execution
}
```

---

## Suggested Build Order

| Phase | Goal | Dependencies |
|-------|------|-------------|
| 1. Foundation | Auth, DB schema, RLS, app shell, user management | None |
| 2. CRM Core | Pipelines, leads CRUD, kanban board, seller filtering | Phase 1 |
| 3. Inbox & Messaging UI | Inbox management, conversation list, message thread, Realtime | Phase 1 |
| 4. WhatsApp Integration | Evolution API + Meta Cloud API webhooks, send/receive messages | Phase 3 |
| 5. AI Agent | Agent config, orchestrator Edge Function, CRM tools, OpenAI calls | Phase 2, 4 |
| 6. Lead Distribution | Qualification rules, round-robin, notifications, human handoff | Phase 5 |
| 7. Instagram DMs | Instagram webhook handler, Graph API replies (submit Meta review early) | Phase 4 |
| 8. Dashboards | Monitoring + analytics dashboards with Recharts | Phase 5, 6 |
| 9. Hardening | Webhook validation audit, error handling, rate limiting, RLS audit, load test | All |

---

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| No separate application server | Edge Functions co-locate with DB, minimizing latency. Sufficient for 10-50 users |
| Async webhook + orchestrator decoupling | Webhook must respond in 5s, AI takes 10-30s. Prevents duplicate messages |
| Postgres as AI context store (not Assistants API) | Full control over context, SQL joins with CRM, RLS enforcement |
| Dual WhatsApp strategy | Evolution API for zero-cost dev/small volume, Meta Cloud API for compliance at scale |

---
*Architecture research for: Teto Locadora AI Agent Platform*
*Researched: 2026-03-11*
