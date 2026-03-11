# Pitfalls Research

**Domain:** AI Agent Platform / CRM / Multi-channel Chat (WhatsApp + Instagram)
**Stack:** Lovable (React + Supabase), OpenAI GPT, WhatsApp Official API + Evolution API, Instagram DMs
**Researched:** 2026-03-11
**Confidence:** MEDIUM (training data + well-established community patterns)

---

## Critical Pitfalls

### Pitfall 1: WhatsApp 24-Hour Session Window Not Architected In From Day One

**What goes wrong:**
The WhatsApp Cloud API (Official/Meta) enforces a strict 24-hour "customer service window": you can only send free-form messages within 24 hours of the customer's last inbound message. After that, you must use a pre-approved Message Template (HSM) — which requires Meta approval, can take days/weeks, and costs per-message.

**How to avoid:**
- Store the timestamp of every inbound message per conversation in Supabase.
- Before every AI-generated outgoing message, check: `now() - last_inbound_at < 24h`.
- If outside window: queue a Template message (not free-form). Design 2-3 approved re-engagement templates before launch.
- Build a `message_session_state` field on each conversation: `active` / `expired` / `template_only`.

**Warning signs:**
- AI tries to send a follow-up and receives error code `131047` or `131026` from Meta API.
- Messages silently fail or return `400` with "outside of allowed window."

**Severity:** Critical
**Phase to address:** WhatsApp integration phase

---

### Pitfall 2: Evolution API Phone Number Bans From Unofficial Usage Patterns

**What goes wrong:**
Evolution API runs on the WhatsApp Web/Multi-Device protocol (unofficial). WhatsApp's anti-spam systems monitor for bot-like behavior. Numbers get soft-banned or hard-banned. A business-critical WhatsApp number being banned destroys the entire lead pipeline.

**How to avoid:**
- Add randomized delays between AI messages (1-4 seconds), never fire messages in rapid bursts.
- Limit outbound messages per number per day (< 50-100/day for new numbers).
- Reserve Evolution API numbers for lower-stakes conversations or testing; use Official API for primary business numbers.
- Never send the same message text to multiple different contacts.
- Have a fallback: if Evolution API number is banned, route through Official API.

**Warning signs:**
- Evolution API returns `401` or connection drops repeatedly.
- QR code re-authentication required more frequently than expected.
- WhatsApp Web session disconnects without user action.

**Severity:** Critical
**Phase to address:** WhatsApp integration phase

---

### Pitfall 3: AI Agent Goes Rogue — No Human Takeover / Guardrail System

**What goes wrong:**
The AI agent has full CRM write access. Without a human-takeover mechanism, the agent will inevitably: (a) delete or corrupt CRM records, (b) send inappropriate messages, (c) lock a lead in a re-qualification loop, or (d) misclassify and misroute a high-value lead.

**How to avoid:**
- Human takeover flag per conversation: when a human responds, pause AI for that thread.
- Add confidence scoring: low-confidence actions create a human review task instead of executing.
- Log every AI action with a revert trail: soft-delete only, with 24h recovery window.
- Define "no-fly zones": AI cannot delete leads, cannot close deals.
- Alert on anomalies: if AI sends > N messages to same contact in 1 hour, alert supervisor.

**Warning signs:**
- AI sends conflicting messages to the same lead within minutes.
- CRM records show bulk edits with no human author at off-hours.
- Agent enters infinite re-qualification loop (same questions repeated).

**Severity:** Critical
**Phase to address:** AI agent core phase — guardrails must be built before CRM write-access is granted.

---

### Pitfall 4: Supabase RLS Not Designed for Agent/User Dual Access Pattern

**What goes wrong:**
Two actors access the database: human users and the AI agent. RLS policies written for humans break when the AI tries to write. The common fix — using service role key everywhere — removes all security.

**How to avoid:**
- Design a `user_type` concept from day one: `human` vs `agent` vs `service`.
- Use Supabase Edge Functions as the agent's only database access point.
- Never expose service key to client-side code.
- Audit RLS coverage before launch.

**Warning signs:**
- Any code that imports `supabaseAdmin` in the browser bundle.
- RLS policies with `USING (true)` on sensitive tables.

**Severity:** Critical
**Phase to address:** Foundation/database schema phase

---

### Pitfall 5: OpenAI API Costs Spiral Out of Control

**What goes wrong:**
Every message triggers an OpenAI call. With 100+ active leads, each with 10+ turns, and full conversation history sent as context, GPT-4o costs reach $50-200/day.

**How to avoid:**
- Use GPT-4o-mini for SDR/qualification; reserve GPT-4o for complex decisions only.
- Implement conversation summarization: after N turns, use summary + last 3 messages as context.
- Set a per-conversation token budget.
- Add a monthly cost cap in OpenAI dashboard; alert at 80%.

**Warning signs:**
- Token usage growing linearly with conversation count.
- API response times increasing (large contexts).

**Severity:** High
**Phase to address:** AI agent core phase

---

### Pitfall 6: Webhook Reliability — Missed WhatsApp/Instagram Events

**What goes wrong:**
If the webhook endpoint is down, slow (> 20s timeout), or returns non-200, Meta stops sending events. Missed webhooks = missed messages = leads that never get a response.

**How to avoid:**
- Webhook endpoint must respond `200 OK` within 5 seconds — acknowledge only, process async.
- Use a dedicated webhook ingestion table: insert raw event to `webhook_events`, process from there.
- Implement Meta webhook verification token correctly from day one.
- Store all raw webhook payloads for replay.

**Warning signs:**
- Meta Webhook dashboard shows failed deliveries.
- Conversations where AI doesn't respond despite lead sending messages.

**Severity:** Critical
**Phase to address:** Channel integration phase — webhook ingestion architecture must be the first thing built.

---

### Pitfall 7: Instagram DM API Requires Meta Business Verification + Approval

**What goes wrong:**
Instagram DM API requires: (1) Facebook Business Manager, (2) Instagram connected to Facebook Page, (3) app reviewed and approved for `instagram_manage_messages`. Approval takes 1-4 weeks and is commonly rejected on first submission.

**How to avoid:**
- Submit the Instagram API access request to Meta on day 1, before any development.
- Prepare a demo video showing the use case — required for review.
- Build Instagram integration last — it will take the longest to approve.
- Design the system so WhatsApp is fully functional independently.

**Severity:** High
**Phase to address:** Project kickoff — submit Meta app review before writing any Instagram integration code.

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Full conversation history in every OpenAI call | Slow responses, high cost | Conversation summarization after N turns | At ~20+ turns |
| Supabase Realtime on unfiltered tables | High WebSocket traffic, client lag | Filter by user_id or inbox_id | At ~50+ concurrent users |
| Synchronous webhook processing | Timeout errors, dropped messages | Webhook queue pattern | At > 10 simultaneous inbound messages |
| No DB indexes on CRM query columns | Slow CRM list/filter | Index lead_id, stage_id, assigned_to, created_at | At ~5000+ CRM records |
| Round-robin query without locking | Two salespeople assigned same lead | SELECT FOR UPDATE SKIP LOCKED | At > 3 concurrent salespeople |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| OpenAI API key in client-side code | Key theft, unlimited charges | All OpenAI calls via Edge Functions only |
| Meta webhook verify token exposed | Attacker sends fake events | Store in Supabase Vault; validate signature |
| Service role key in client-side code | Full database access if leaked | Service key only in Edge Functions |
| No webhook signature verification | Fake events trigger AI actions | Verify X-Hub-Signature-256 on all Meta webhooks |
| Salesperson sees other leads | Privacy violation | RLS: salespeople see only assigned_to = auth.uid() |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No AI status indicator | Salespeople don't know if AI is working | Show: AI Active, AI Processing, Human Takeover, Waiting |
| No AI message history visible | Salesperson takes over blind | Full history visible; AI messages labeled |
| No way to pause AI | Salesperson watches AI do the wrong thing | One-click "Take Over" per conversation |
| Round-robin assigns to offline salesperson | Lead goes cold | Skip offline salespeople; track availability |
| No qualification summary on handoff | Salesperson receives lead with no context | AI generates summary: name, need, budget, timeline |

---

## "Looks Done But Isn't" Checklist

- [ ] WhatsApp 24-hour session window checked before every free-form message; template fallback exists
- [ ] Human takeover flag pauses AI immediately — tested with race condition
- [ ] All AI-initiated CRM changes logged with performed_by: 'agent' and are recoverable
- [ ] Round-robin uses database-level locking to prevent double-assignment
- [ ] Each WhatsApp number is isolated — events from number A cannot appear in number B's inbox
- [ ] Meta app review approved for Instagram before Instagram development
- [ ] No RLS policy has USING (true) on tables containing lead or customer data
- [ ] OpenAI key in Supabase Vault; not in any committed .env or client bundle
- [ ] Meta webhook signature validated on every inbound call
- [ ] OpenAI calls use conversation summarization beyond 10 turns
- [ ] Webhook handler returns 200 OK within 3 seconds; all processing is async

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| WhatsApp 24h session window | Channel setup phase | Send test after 25h idle; verify template fallback |
| Evolution API ban risk | Channel setup phase | Rate limiting test; delay injection verified |
| AI agent guardrails | AI agent core phase | Human takeover test; soft-delete verified |
| Supabase RLS dual access | Database schema phase | RLS test suite: human can't see others' leads |
| OpenAI cost spiral | AI agent core phase | Token usage dashboard; summarization at turn 10 |
| Webhook reliability | Channel integration phase | Load test: 20 simultaneous inbound messages |
| Instagram approval delay | Project kickoff (Phase 0) | Meta approval confirmed before dev begins |
| Round-robin double assignment | CRM/lead management phase | Concurrent test: 5 agents claim simultaneously |

---
*Pitfalls research for: Teto Locadora AI Agent Platform*
*Researched: 2026-03-11*
