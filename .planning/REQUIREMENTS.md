# Requirements: Teto Locadora — Plataforma de Agentes de IA

**Defined:** 2026-03-11
**Core Value:** O agente SDR qualifica leads automaticamente via WhatsApp, gerencia o CRM de forma autônoma e distribui leads prontos para vendedores na fila rotativa.

## v1 Requirements

### Authentication & Users

- [ ] **AUTH-01**: User can log in with email and password
- [ ] **AUTH-02**: User session persists across browser refresh
- [ ] **AUTH-03**: Manager can invite new users with role assignment (manager/seller)
- [ ] **AUTH-04**: Manager can deactivate/reactivate user accounts
- [ ] **AUTH-05**: Manager has full access to all data (leads, conversations, pipelines, agents)
- [ ] **AUTH-06**: Seller can only see leads and conversations assigned to them
- [ ] **AUTH-07**: Seller can toggle their availability status (online/offline)

### CRM

- [ ] **CRM-01**: Manager can create multiple pipelines with named stages
- [ ] **CRM-02**: Manager can add, rename, reorder, and delete pipeline stages
- [ ] **CRM-03**: User can view leads in kanban board with drag-and-drop between stages
- [ ] **CRM-04**: User can create leads manually with contact info and notes
- [ ] **CRM-05**: User can edit lead fields, notes, and status
- [ ] **CRM-06**: User can delete leads (soft-delete with recovery)
- [ ] **CRM-07**: Leads are created automatically from new WhatsApp/Instagram conversations
- [ ] **CRM-08**: AI agent can create, edit, and move leads between stages autonomously
- [ ] **CRM-09**: Every action on a lead is logged (who/what/when) in activity history
- [ ] **CRM-10**: User can view full activity log per lead (AI actions, stage changes, assignments)
- [ ] **CRM-11**: Lead detail view shows conversation history alongside CRM data

### Multi-Channel Chat

- [ ] **CHAT-01**: User can connect multiple WhatsApp numbers (multi-inbox)
- [ ] **CHAT-02**: Each WhatsApp number has its own separate inbox/chat view
- [ ] **CHAT-03**: User can send and receive WhatsApp messages via Evolution API
- [ ] **CHAT-04**: User can send and receive WhatsApp messages via Meta Cloud API (Official)
- [ ] **CHAT-05**: User can receive and reply to Instagram DMs
- [ ] **CHAT-06**: Messages update in real-time across all connected users
- [ ] **CHAT-07**: User can view conversation list filtered by inbox, status, and assignment
- [ ] **CHAT-08**: User can add internal notes to conversations (not visible to lead)
- [ ] **CHAT-09**: Conversation shows message status indicators (sent, delivered, read)
- [ ] **CHAT-10**: User can send/receive file and image attachments

### AI Agents

- [ ] **AGENT-01**: Manager can create AI agents with name, type (SDR/Sales/Support), and system prompt
- [ ] **AGENT-02**: Manager can configure agent personality, tone, and response rules
- [ ] **AGENT-03**: Manager can choose AI model per agent (GPT-4o or GPT-4o-mini)
- [ ] **AGENT-04**: Manager can assign an agent to one or more inboxes
- [ ] **AGENT-05**: Manager can enable/disable agent per inbox
- [ ] **AGENT-06**: Manager can configure qualification rules (required fields the agent must collect)
- [ ] **AGENT-07**: Manager can configure handoff rules (conditions that trigger transfer to human)
- [ ] **AGENT-08**: Agent responds autonomously to incoming messages using configured prompt and rules
- [ ] **AGENT-09**: Agent uses OpenAI function calling to execute CRM actions (create/edit/move leads)
- [ ] **AGENT-10**: Seller can take over a conversation — AI stops responding for that thread
- [ ] **AGENT-11**: Manager can re-enable AI on a conversation after human takeover
- [ ] **AGENT-12**: All AI actions are logged and recoverable (soft-delete, 24h recovery)

### Lead Distribution

- [ ] **DIST-01**: Qualified leads are automatically distributed to sellers in round-robin rotation
- [ ] **DIST-02**: Offline/unavailable sellers are skipped in the distribution queue
- [ ] **DIST-03**: AI generates a qualification summary when distributing lead to seller (name, need, budget, timeline)
- [ ] **DIST-04**: Seller receives real-time notification when a new lead is assigned
- [ ] **DIST-05**: Manager can manually reassign a lead to a different seller

### Dashboards

- [ ] **DASH-01**: Real-time monitoring: active agents, open conversations, conversations in progress, handoff queue
- [ ] **DASH-02**: Pipeline analytics: lead funnel visualization, conversion rates per stage
- [ ] **DASH-03**: Seller performance: leads handled, conversion rate, response time per seller
- [ ] **DASH-04**: Agent performance: response time, qualification rate, messages per conversation

### API & Webhooks

- [ ] **API-01**: REST API for reading/writing leads, contacts, and pipeline data
- [ ] **API-02**: API authentication via API keys
- [ ] **API-03**: Webhook events fired on lead status changes (qualified, distributed, closed)
- [ ] **API-04**: Webhook configuration UI (select events, set destination URL)

## v2 Requirements

### AI Agents (v2)

- **AGENT-V2-01**: Agent knowledge base — upload documents for RAG-based answers
- **AGENT-V2-02**: A/B testing agent prompts with performance comparison

### CRM (v2)

- **CRM-V2-01**: Custom fields per pipeline (configurable field schema)
- **CRM-V2-02**: AI-based lead scoring
- **CRM-V2-03**: Bulk actions on leads (mass reassign, mass stage move)

### Distribution (v2)

- **DIST-V2-01**: Weighted distribution (senior sellers get more leads)
- **DIST-V2-02**: Distribution by specialty or region

### Dashboards (v2)

- **DASH-V2-01**: Export reports as CSV/PDF
- **DASH-V2-02**: Time-based trend analysis (daily/weekly/monthly)

### Users (v2)

- **AUTH-V2-01**: Custom role permissions (granular RBAC)
- **AUTH-V2-02**: Team/group hierarchy

## Out of Scope

| Feature | Reason |
|---------|--------|
| Multi-tenant / SaaS | Plataforma interna para Teto Locadora apenas |
| Email channel | Não solicitado, WhatsApp e Instagram são canais prioritários |
| Voice/video calls | Infraestrutura diferente, não faz parte do escopo |
| Visual flow builder (tipo Botpress) | Agentes usam prompts, não fluxos visuais |
| App mobile nativo | Web-first, responsivo |
| OAuth / social login | Email+senha é suficiente para uso interno |
| Self-registration | Usuários são convidados por gerentes |
| Instagram comentários | Foco em DMs apenas |
| CRM externo (Hubspot, Pipedrive) | CRM é interno, API permite integração futura |
| Predictive analytics / ML | Prematuro para v1, dados insuficientes |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 1 | Pending |
| AUTH-05 | Phase 1 | Pending |
| AUTH-06 | Phase 1 | Pending |
| AUTH-07 | Phase 1 | Pending |
| CRM-01 | Phase 1 | Pending |
| CRM-02 | Phase 1 | Pending |
| CRM-03 | Phase 1 | Pending |
| CRM-04 | Phase 1 | Pending |
| CRM-05 | Phase 1 | Pending |
| CRM-06 | Phase 1 | Pending |
| CRM-07 | Phase 1 | Pending |
| CRM-08 | Phase 1 | Pending |
| CRM-09 | Phase 1 | Pending |
| CRM-10 | Phase 1 | Pending |
| CRM-11 | Phase 1 | Pending |
| CHAT-01 | Phase 2 | Pending |
| CHAT-02 | Phase 2 | Pending |
| CHAT-03 | Phase 2 | Pending |
| CHAT-04 | Phase 2 | Pending |
| CHAT-05 | Phase 4 | Pending |
| CHAT-06 | Phase 2 | Pending |
| CHAT-07 | Phase 2 | Pending |
| CHAT-08 | Phase 2 | Pending |
| CHAT-09 | Phase 2 | Pending |
| CHAT-10 | Phase 2 | Pending |
| AGENT-01 | Phase 3 | Pending |
| AGENT-02 | Phase 3 | Pending |
| AGENT-03 | Phase 3 | Pending |
| AGENT-04 | Phase 3 | Pending |
| AGENT-05 | Phase 3 | Pending |
| AGENT-06 | Phase 3 | Pending |
| AGENT-07 | Phase 3 | Pending |
| AGENT-08 | Phase 3 | Pending |
| AGENT-09 | Phase 3 | Pending |
| AGENT-10 | Phase 3 | Pending |
| AGENT-11 | Phase 3 | Pending |
| AGENT-12 | Phase 3 | Pending |
| DIST-01 | Phase 3 | Pending |
| DIST-02 | Phase 3 | Pending |
| DIST-03 | Phase 3 | Pending |
| DIST-04 | Phase 3 | Pending |
| DIST-05 | Phase 3 | Pending |
| DASH-01 | Phase 4 | Pending |
| DASH-02 | Phase 4 | Pending |
| DASH-03 | Phase 4 | Pending |
| DASH-04 | Phase 4 | Pending |
| API-01 | Phase 4 | Pending |
| API-02 | Phase 4 | Pending |
| API-03 | Phase 4 | Pending |
| API-04 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 53 total
- Mapped to phases: 53
- Unmapped: 0

---
*Requirements defined: 2026-03-11*
*Last updated: 2026-03-11 after roadmap creation — all requirements mapped*
