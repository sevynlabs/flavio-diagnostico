# Features Research

**Domain:** AI Agent Platform — CRM, Multi-Channel Chat (WhatsApp + Instagram), SDR/Sales/Support Automation
**Researched:** 2026-03-11
**Confidence:** MEDIUM (based on analysis of platforms like Chatwoot, Respond.io, Intercom, HubSpot, and AI SDR tools)

---

## Feature Categories

### 1. AI Agent Management

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Create/edit/delete AI agents | Low | Auth, DB |
| Configure system prompt per agent | Low | Agent CRUD |
| Choose AI model per agent (GPT-4o / GPT-4o-mini) | Low | Agent CRUD |
| Assign agent to inbox/channel | Low | Inbox management |
| Enable/disable agent per inbox | Low | Agent CRUD |
| Agent conversation history and context | Medium | Messages DB |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Qualification rules engine (configurable required fields) | Medium | Agent config, CRM |
| Handoff rules (when to transfer to human) | Medium | Agent config |
| Agent personality/tone customization | Low | Agent config |
| Agent knowledge base (upload docs for RAG) | High | Storage, embeddings |
| A/B testing agent prompts | High | Analytics |

**Anti-features (don't build):**
- Visual flow builder (Botpress-style) — over-engineered for prompt-based agents
- Agent marketplace/templates store — internal platform, not SaaS
- Multi-model routing per message — adds latency and complexity for marginal benefit

---

### 2. Multi-Channel Chat / Inbox

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Unified inbox — all channels in one view | Medium | Messages, Conversations |
| WhatsApp send/receive messages | Medium | WhatsApp API integration |
| Real-time message updates | Medium | Supabase Realtime |
| Conversation list with search/filter | Medium | Messages DB |
| Message status indicators (sent, delivered, read) | Low | WhatsApp API |
| File/image attachments in chat | Medium | Storage |
| Conversation assignment to user | Low | Conversations DB |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Multi-inbox (multiple WhatsApp numbers, each separate) | Medium | Inbox management |
| Instagram DM integration | Medium | Meta Graph API |
| Internal notes on conversations (not visible to lead) | Low | Messages DB |
| Canned responses / quick replies | Low | Templates DB |
| Conversation tags/labels | Low | Conversations DB |
| Typing indicators | Low | Realtime |

**Anti-features:**
- Email channel — not requested, adds significant complexity
- Voice/video calls — different infrastructure entirely
- Chatbot flow builder — using AI agents instead

---

### 3. CRM

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Multiple pipelines | Medium | Pipelines DB |
| Kanban board (drag-and-drop stages) | Medium | UI + Realtime |
| Lead creation (manual + automatic from conversations) | Low | Leads DB |
| Lead editing (fields, notes, status) | Low | Leads CRUD |
| Lead detail view with conversation history | Medium | Leads + Messages |
| Stage management (create, rename, reorder) | Low | Pipeline stages |
| Lead search and filtering | Medium | DB queries |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| AI-managed pipeline (agent moves cards autonomously) | High | Agent + CRM tools |
| Custom fields per pipeline | Medium | Dynamic schema |
| Activity log per lead (all actions tracked) | Medium | Audit log |
| Lead scoring (manual or AI-based) | Medium | Scoring engine |
| Pipeline analytics (conversion rates per stage) | Medium | Analytics |
| Bulk actions on leads | Low | UI |

**Anti-features:**
- Deals/opportunities as separate entity — leads are sufficient for equipment rental
- Products catalog in CRM — not needed for rental quoting
- Invoice generation — use external tool

---

### 4. Lead Distribution

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Round-robin assignment to sellers | Medium | Distribution queue |
| Skip offline/unavailable sellers | Medium | User presence |
| Notification on lead assignment | Low | Notifications |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Weighted distribution (senior sellers get more) | Medium | Distribution config |
| Distribution by specialty/region | Medium | User metadata |
| AI qualification summary on handoff | Medium | Agent orchestrator |
| Manual reassignment by manager | Low | UI |
| Distribution analytics (load per seller) | Medium | Analytics |

**Anti-features:**
- Self-service lead claiming — contradicts automated distribution model
- Bidding/auction for leads — too complex, not needed internally

---

### 5. Multi-User & Permissions

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Manager role (full access) | Medium | Auth + RLS |
| Seller role (restricted to own leads) | Medium | Auth + RLS |
| Login/logout with email+password | Low | Supabase Auth |
| User management (invite, deactivate) | Low | Admin UI |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Team/group hierarchy | Medium | Org structure |
| Custom role permissions | High | Granular RBAC |
| Seller availability toggle (online/offline) | Low | User status |
| Activity log per user | Medium | Audit log |

**Anti-features:**
- SSO/SAML — internal platform with <50 users
- OAuth social login — email+password is sufficient
- Self-registration — users are invited by managers

---

### 6. Dashboards & Analytics

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Active agents overview | Low | Agents + Conversations |
| Open conversations count | Low | Conversations DB |
| Conversations by status (open, waiting, closed) | Low | Conversations DB |
| Lead pipeline summary | Low | Leads DB |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Real-time monitoring (live conversation feed) | Medium | Realtime |
| Agent performance metrics (response time, qualification rate) | Medium | Analytics queries |
| Seller performance (leads handled, conversion rate) | Medium | Analytics queries |
| Channel comparison (WhatsApp vs Instagram) | Low | Analytics queries |
| Time-based trends (daily/weekly/monthly) | Medium | Date aggregation |
| Export reports (CSV/PDF) | Medium | Export logic |

**Anti-features:**
- Predictive analytics / ML forecasting — premature for v1
- Custom dashboard builder — pre-built dashboards are sufficient

---

### 7. API & Webhooks

**Table Stakes:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| REST API for CRM data (leads, contacts, pipelines) | Medium | Edge Functions |
| API authentication (API keys) | Low | Auth |
| Webhook events on lead status changes | Medium | Event system |

**Differentiators:**
| Feature | Complexity | Dependencies |
|---------|-----------|-------------|
| Webhook configurator UI (choose events, set URL) | Medium | Webhooks config |
| API documentation (auto-generated) | Low | Docs |
| Rate limiting on API | Low | Edge Functions |

**Anti-features:**
- GraphQL API — REST is sufficient for internal use
- SDK/client libraries — internal platform
- API versioning — no external consumers initially

---

## Feature Dependencies Map

```
Auth & Users ──────► CRM Core ──────► Lead Distribution
     │                  │                    │
     │                  ▼                    ▼
     ├──────► Inbox/Chat ──────► AI Agent ──► Dashboards
     │            │                │
     │            ▼                ▼
     │      WhatsApp Integration   CRM Tools (AI writes to CRM)
     │            │
     │            ▼
     │      Instagram Integration
     │
     └──────► API & Webhooks
```

**Critical path:** Auth → CRM → Inbox → WhatsApp → AI Agent → Lead Distribution → Dashboards

---

## Complexity Summary

| Category | Table Stakes | Differentiators | Recommended for v1 |
|----------|-------------|-----------------|---------------------|
| AI Agent Management | 6 | 5 | All table stakes + qualification rules, handoff rules, personality |
| Multi-Channel Chat | 7 | 6 | All table stakes + multi-inbox, Instagram DMs, internal notes |
| CRM | 7 | 6 | All table stakes + AI-managed pipeline, activity log |
| Lead Distribution | 3 | 5 | All table stakes + qualification summary on handoff |
| Multi-User | 4 | 4 | All table stakes + seller availability toggle |
| Dashboards | 4 | 6 | All table stakes + real-time monitoring, agent/seller performance |
| API & Webhooks | 3 | 3 | All table stakes + webhook configurator |

---

## v1 vs v2 Recommendation

**v1 (must ship):**
- All table stakes across all categories
- AI qualification rules + handoff rules
- Multi-inbox
- AI-managed pipeline (core value)
- Lead qualification summary on handoff
- Real-time monitoring dashboard
- Basic analytics

**v2 (defer):**
- Agent knowledge base (RAG)
- A/B testing prompts
- Custom fields per pipeline
- Lead scoring
- Weighted distribution
- Export reports
- Custom role permissions

---
*Features research for: Teto Locadora AI Agent Platform*
*Researched: 2026-03-11*
