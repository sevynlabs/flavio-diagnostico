# Phase 1: Foundation & CRM - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Auth with roles (manager/seller), user management with email invites, and full CRM with multiple pipelines, kanban board, lead CRUD, and activity logging. No messaging, no AI agents, no dashboards analytics — those are later phases.

</domain>

<decisions>
## Implementation Decisions

### Kanban & Lead Cards
- HubSpot-style pipeline kanban: columns with colored headers, cards with more detail
- Lead card shows: name + phone, assigned seller (avatar), channel icon (WhatsApp/Instagram), time in stage
- Drag-and-drop between stages with optimistic updates
- All 4 info fields visible on every card — no collapsed state

### User Management
- Manager invites sellers via email — seller receives link to create password
- No self-registration — all users are invited
- User management page for manager: list users, invite new, deactivate/reactivate
- Seller availability toggle (online/offline) visible in user list and profile

### Seller Experience
- Seller sees both kanban and list views — can toggle between them
- Kanban is filtered to only their assigned leads (RLS enforces this)
- No access to: agent config, user management, pipeline settings
- Seller can: view their leads, edit lead fields, add notes, see activity log

### Navigation & Layout
- Collapsible sidebar — minimizes to icon-only mode
- Sidebar items: Dashboard, Inbox/Chat, CRM/Pipelines, Agentes IA
- Inbox/Chat and Agentes IA are placeholder items in Phase 1 (disabled/coming soon)
- Manager sees all sidebar items; seller sees Dashboard + CRM only

### Theme
- Light + dark mode with user toggle (next-themes already in dependencies)
- Default to light mode

### Claude's Discretion
- Exact card dimensions and spacing
- Loading skeletons and empty states design
- Activity log visual format (timeline vs list)
- Pipeline selector UI (tabs, dropdown, or sidebar sub-nav)
- Exact sidebar icon choices

</decisions>

<specifics>
## Specific Ideas

- Pipeline kanban visual reference: HubSpot CRM pipeline board
- Sidebar reference: Intercom/Chatwoot style — icon + text, collapsible to icons only
- Lead cards should feel informative at a glance — seller sees name, phone, origin channel, and how long the lead has been in that stage without clicking

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- shadcn/ui components (Radix UI): dialogs, dropdowns, tabs, toast — all available for CRM UI
- React Hook Form + Zod: form handling for lead editing, user invites, pipeline config
- TanStack React Query: server state for leads, pipelines, users
- Framer Motion: drag-and-drop animations for kanban
- Sonner: toast notifications for actions
- Recharts: available for future dashboard phase
- next-themes: light/dark toggle already in dependencies

### Established Patterns
- Vite + React SWC for build
- Path alias @/* → ./src/*
- Supabase JS 2.96.0 for auth, DB, realtime

### Integration Points
- Supabase Auth for login/invite flow
- Supabase Postgres with RLS for role-based data access
- Supabase Realtime for live kanban updates across users
- React Router DOM for page navigation

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation-crm*
*Context gathered: 2026-03-11*
