# Phase 1: Foundation & CRM - Research

**Researched:** 2026-03-11
**Domain:** Supabase Auth + RLS, React CRM Kanban, Email Invite Flow, Role-based Access
**Confidence:** HIGH (derived from fixed stack constraints + established Supabase/shadcn patterns)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Kanban & Lead Cards
- HubSpot-style pipeline kanban: columns with colored headers, cards with more detail
- Lead card shows: name + phone, assigned seller (avatar), channel icon (WhatsApp/Instagram), time in stage
- Drag-and-drop between stages with optimistic updates
- All 4 info fields visible on every card — no collapsed state

#### User Management
- Manager invites sellers via email — seller receives link to create password
- No self-registration — all users are invited
- User management page for manager: list users, invite new, deactivate/reactivate
- Seller availability toggle (online/offline) visible in user list and profile

#### Seller Experience
- Seller sees both kanban and list views — can toggle between them
- Kanban is filtered to only their assigned leads (RLS enforces this)
- No access to: agent config, user management, pipeline settings
- Seller can: view their leads, edit lead fields, add notes, see activity log

#### Navigation & Layout
- Collapsible sidebar — minimizes to icon-only mode
- Sidebar items: Dashboard, Inbox/Chat, CRM/Pipelines, Agentes IA
- Inbox/Chat and Agentes IA are placeholder items in Phase 1 (disabled/coming soon)
- Manager sees all sidebar items; seller sees Dashboard + CRM only

#### Theme
- Light + dark mode with user toggle (next-themes already in dependencies)
- Default to light mode

### Claude's Discretion
- Exact card dimensions and spacing
- Loading skeletons and empty states design
- Activity log visual format (timeline vs list)
- Pipeline selector UI (tabs, dropdown, or sidebar sub-nav)
- Exact sidebar icon choices

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| AUTH-01 | User can log in with email and password | Supabase Auth `signInWithPassword` — standard pattern |
| AUTH-02 | User session persists across browser refresh | Supabase Auth session auto-refresh via `onAuthStateChange` listener in root |
| AUTH-03 | Manager can invite new users with role assignment (manager/seller) | Supabase Admin `inviteUserByEmail` + custom claim in `raw_app_meta_data` |
| AUTH-04 | Manager can deactivate/reactivate user accounts | Supabase Admin `updateUserById` sets `ban_duration`; RLS rejects banned users |
| AUTH-05 | Manager has full access to all data (leads, conversations, pipelines, agents) | RLS policy: `auth.jwt() ->> 'role' = 'manager'` bypasses row restriction |
| AUTH-06 | Seller can only see leads and conversations assigned to them | RLS policy: `assigned_seller_id = auth.uid()` enforces at DB layer |
| AUTH-07 | Seller can toggle their availability status (online/offline) | `profiles` table `availability` column; seller updates own row via RLS UPDATE policy |
| CRM-01 | Manager can create multiple pipelines with named stages | `pipelines` + `pipeline_stages` tables; CRUD via supabase-js |
| CRM-02 | Manager can add, rename, reorder, and delete pipeline stages | `position` column on `pipeline_stages`; reorder via batch UPDATE; delete with FK cascade check |
| CRM-03 | User can view leads in kanban board with drag-and-drop between stages | Framer Motion drag + React Query optimistic update + Supabase PATCH on `leads.stage_id` |
| CRM-04 | User can create leads manually with contact info and notes | Lead creation form with React Hook Form + Zod; INSERT into `leads` + `contacts` |
| CRM-05 | User can edit lead fields, notes, and status | Lead detail sheet/modal; UPDATE via React Query mutation |
| CRM-06 | User can delete leads (soft-delete with recovery) | `deleted_at` timestamp column; UI shows recover action for 24h |
| CRM-07 | Leads are created automatically from new WhatsApp/Instagram conversations | Phase 1: stub only — `source` field on leads table to support this later; no webhook in Phase 1 |
| CRM-08 | AI agent can create, edit, and move leads between stages autonomously | Phase 1: stub only — schema supports it; AI logic is Phase 3 |
| CRM-09 | Every action on a lead is logged (who/what/when) in activity history | `lead_activity_log` table: lead_id, actor_id, actor_type (human/agent), action, payload (jsonb), created_at |
| CRM-10 | User can view full activity log per lead | Activity log UI within lead detail view; query `lead_activity_log` filtered by lead_id |
| CRM-11 | Lead detail view shows conversation history alongside CRM data | Phase 1: placeholder panel — conversation query stub; full data in Phase 2 |
</phase_requirements>

---

## Summary

Phase 1 delivers the full auth and CRM foundation: login, user invitation, role-based access, pipeline management, and a kanban board. The stack is entirely fixed by Lovable (React + Supabase), so no library selection decisions are required. The work is primarily schema design, RLS policies, and UI components using already-available shadcn/ui, React Query, and Framer Motion.

The two most architecturally sensitive areas are: (1) custom JWT role claims — the role claim must be set in `raw_app_meta_data` at invite time and verified with a Postgres function to make RLS work correctly, and (2) drag-and-drop kanban with optimistic updates — stage moves must update the DB, log activity, and reflect in other sessions via Realtime, all atomically or with correct rollback on failure.

CRM-07 (auto-create from WhatsApp), CRM-08 (AI agent CRM writes), and CRM-11 (conversation history) are listed in Phase 1 requirements but their implementation belongs to later phases. Phase 1 must create the schema that supports these (correct FKs, `source` field, `ai_active` flag) without building the runtime logic.

**Primary recommendation:** Build in sequence — DB schema + RLS first, auth flows second, app shell/navigation third, pipeline management fourth, kanban board fifth, lead detail + activity log sixth.

---

## Standard Stack

### Core (All fixed by Lovable — no choices to make)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| React | 18.3.1 | UI framework | Fixed by Lovable |
| TypeScript | 5.8.3 | Type safety | Fixed by Lovable |
| Supabase JS | 2.96.0 | Auth, DB, Realtime client | Fixed by Lovable |
| Vite | 5.4.19 | Build tool | Fixed by Lovable |
| Tailwind CSS | 3.4.17 | Styling | Fixed by Lovable |
| shadcn/ui | latest | Component primitives (Radix UI) | Fixed by Lovable |

### Supporting (Already in dependencies)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| TanStack React Query | 5.83.0 | Server state, caching, optimistic updates | All data fetching; mutations with rollback |
| React Hook Form | 7.61.1 | Form handling | Lead editor, invite modal, pipeline config |
| Zod | 3.25.76 | Schema validation | Form validation, type-safe DB inserts |
| Framer Motion | 12.34.0 | Drag-and-drop animations | Kanban card dragging between stages |
| Sonner | 1.7.4 | Toast notifications | Action confirmations, error feedback |
| next-themes | latest | Light/dark mode | Theme toggle in sidebar/profile |
| React Router DOM | latest | Page navigation | Route protection, role-based routing |
| Zustand | ~4.5 | Client UI state (modals, sidebar collapsed) | Ephemeral UI state only; not server state |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Framer Motion drag | @dnd-kit/core | dnd-kit is purpose-built for kanban DnD with keyboard accessibility; Framer Motion is already in dependencies, simpler to use for this scope |
| React Query mutations | Zustand for optimistic UI | React Query has built-in `onMutate`/`onError` rollback — don't duplicate with Zustand |

**Installation:** No new packages needed — all libraries already in Lovable dependencies.

---

## Architecture Patterns

### Recommended Project Structure

```
src/
├── components/
│   ├── ui/              # shadcn/ui primitives (auto-generated)
│   ├── auth/            # LoginForm, InviteModal, ProtectedRoute
│   ├── layout/          # AppShell, Sidebar, ThemeToggle
│   ├── crm/             # KanbanBoard, KanbanColumn, LeadCard, LeadDetail
│   ├── pipelines/       # PipelineManager, StageEditor
│   └── users/           # UserList, UserInviteForm, AvailabilityToggle
├── pages/
│   ├── Login.tsx
│   ├── Dashboard.tsx
│   ├── CRM.tsx
│   ├── Settings/
│   │   ├── Users.tsx
│   │   └── Pipelines.tsx
│   └── NotFound.tsx
├── hooks/
│   ├── useAuth.ts       # Current user, role, session
│   ├── useLeads.ts      # React Query hooks for leads
│   ├── usePipelines.ts  # React Query hooks for pipelines
│   └── useUsers.ts      # React Query hooks for user management
├── lib/
│   ├── supabase.ts      # Supabase client singleton
│   ├── supabase-admin.ts  # Admin client (ONLY in Edge Functions)
│   └── validations.ts   # Zod schemas
├── store/
│   └── ui.ts            # Zustand: sidebar state, active modal
└── types/
    └── database.ts      # Generated Supabase types
```

### Pattern 1: Role Claim in JWT for RLS

**What:** Store the user's role (`manager`/`seller`) in `raw_app_meta_data` so it's available in RLS policies via `auth.jwt() ->> 'role'`.

**When to use:** Any RLS policy that needs to differentiate manager vs. seller access.

**How it works:**
```sql
-- Set role at invite time via service role (Edge Function or admin call)
-- This goes into raw_app_meta_data, which Supabase Auth includes in the JWT
UPDATE auth.users
SET raw_app_meta_data = raw_app_meta_data || '{"role": "seller"}'::jsonb
WHERE id = '{user_id}';

-- RLS policy using the claim
CREATE POLICY "managers_see_all_leads" ON leads
  FOR SELECT USING (
    auth.jwt() ->> 'role' = 'manager'
    OR assigned_seller_id = auth.uid()
  );
```

**Critical:** `raw_app_meta_data` is set server-side only (service role). Never trust client-supplied role values.

### Pattern 2: Optimistic Kanban Stage Move

**What:** Update lead stage in UI immediately, then persist to DB, roll back on failure.

**When to use:** Any drag-and-drop lead move between kanban stages.

```typescript
const moveLeadMutation = useMutation({
  mutationFn: async ({ leadId, newStageId }: { leadId: string; newStageId: string }) => {
    const { error } = await supabase
      .from('leads')
      .update({ stage_id: newStageId, updated_at: new Date().toISOString() })
      .eq('id', leadId);
    if (error) throw error;
  },
  onMutate: async ({ leadId, newStageId }) => {
    await queryClient.cancelQueries({ queryKey: ['leads'] });
    const previous = queryClient.getQueryData(['leads']);
    // Optimistically update local cache
    queryClient.setQueryData(['leads'], (old: Lead[]) =>
      old.map(l => l.id === leadId ? { ...l, stage_id: newStageId } : l)
    );
    return { previous };
  },
  onError: (_err, _vars, context) => {
    queryClient.setQueryData(['leads'], context?.previous);
    toast.error('Failed to move lead');
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['leads'] });
  }
});
```

### Pattern 3: Activity Log Insert on Every Lead Mutation

**What:** Every lead change (create, edit, move, soft-delete) inserts a row in `lead_activity_log`.

**When to use:** All lead-modifying operations.

**Recommended approach:** Postgres trigger on `leads` table catches `INSERT`/`UPDATE` and inserts to `lead_activity_log` automatically. Avoids relying on client to remember to log.

```sql
CREATE OR REPLACE FUNCTION log_lead_activity()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO lead_activity_log (lead_id, actor_id, actor_type, action, payload)
  VALUES (
    NEW.id,
    auth.uid(),       -- null for AI/service calls; use actor_type to distinguish
    'human',
    TG_OP,            -- 'INSERT' | 'UPDATE'
    jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER lead_activity_trigger
AFTER INSERT OR UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION log_lead_activity();
```

### Pattern 4: Supabase Email Invite Flow

**What:** Manager triggers an email invite; Supabase sends a magic link; seller clicks, sets password, lands in app.

**How it works:**
1. Manager fills invite form (email + role)
2. Frontend calls an Edge Function (never call admin API from client)
3. Edge Function calls `supabaseAdmin.auth.admin.inviteUserByEmail(email, { data: { role } })`
4. Supabase sends email with invite link
5. Seller clicks link, lands on password-creation page in the app
6. On signup completion, a `profiles` row is created via `auth.users` trigger

```typescript
// Edge Function: invite-user
const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(
  email,
  {
    data: { role: 'seller' },  // stored in raw_user_meta_data initially
    redirectTo: `${APP_URL}/auth/set-password`
  }
);
// After invite accepted, a trigger sets raw_app_meta_data.role from data.role
```

### Pattern 5: Collapsible Sidebar with Zustand

**What:** Sidebar collapsed state stored in Zustand (client UI state — not server).

```typescript
// store/ui.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface UIStore {
  sidebarCollapsed: boolean;
  toggleSidebar: () => void;
}

export const useUIStore = create<UIStore>()(
  persist(
    (set) => ({
      sidebarCollapsed: false,
      toggleSidebar: () => set(s => ({ sidebarCollapsed: !s.sidebarCollapsed }))
    }),
    { name: 'teto-ui' }
  )
);
```

### Anti-Patterns to Avoid

- **Calling Supabase admin API from the client:** The admin API (inviteUserByEmail, updateUserById) requires the service role key. Never expose it client-side. Always proxy through an Edge Function.
- **Storing role in localStorage and trusting it for access control:** RLS enforces access at DB layer. Client-side role checks are for UX only.
- **Fetching all leads and filtering in React:** Use Supabase RLS + `eq()` filters server-side. React filtering defeats the purpose of RLS and leaks data.
- **Mutation without activity log:** Any lead change without a log entry violates CRM-09. Use a Postgres trigger to make this impossible to forget.
- **Single pipeline assumed:** Schema must support multiple pipelines from day one (CRM-01). Do not hardcode a pipeline_id.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Drag-and-drop kanban | Custom mouse event handlers | Framer Motion `drag` + layout animations | Edge cases: touch support, scroll containers, accessibility |
| Email invite with magic link | Custom SMTP + token system | `supabaseAdmin.auth.admin.inviteUserByEmail` | Supabase handles token generation, expiry, email delivery |
| User session persistence | Custom JWT storage + refresh | Supabase Auth `onAuthStateChange` + auto-refresh | Handles token expiry, tab sync, storage adapters |
| Role-based route protection | Manual `if (role !== 'manager') redirect()` scattered everywhere | `ProtectedRoute` wrapper component + RLS | Single source of truth for access control at DB layer |
| Activity log | Custom event bus | Postgres trigger on `leads` table | Triggers fire on ALL mutations (including future AI writes) — client code cannot be trusted to always log |
| Light/dark mode | Manual CSS variable toggling | next-themes (already installed) | Handles SSR flash, system preference, persistence |

**Key insight:** Supabase provides the auth, invite, and session infrastructure. Do not re-implement any of it. The only custom code needed is UI wiring and database schema.

---

## Common Pitfalls

### Pitfall 1: Role Not in JWT — RLS Breaks at Runtime

**What goes wrong:** Developer sets role in `profiles` table but NOT in `raw_app_meta_data`. RLS policy `auth.jwt() ->> 'role'` returns null. All sellers see all leads.

**Why it happens:** Supabase JWT includes `raw_app_meta_data` but NOT arbitrary Postgres table data. You cannot reference `profiles.role` in RLS without a custom function.

**How to avoid:** Set role in `raw_app_meta_data` at invite time via service role. Add a trigger on `auth.users` insert to also create `profiles` row with the same role.

**Warning signs:** Seller can see leads they're not assigned to. `SELECT auth.jwt() ->> 'role'` returns null in SQL editor when logged in as seller.

### Pitfall 2: Deactivated Users Can Still Log In

**What goes wrong:** Developer sets `profiles.is_active = false` but doesn't block the Supabase auth session. The user's existing session continues working; existing JWT is still valid.

**How to avoid:** Use Supabase's built-in ban mechanism: `supabaseAdmin.auth.admin.updateUserById(id, { ban_duration: 'none' })` bans the user and invalidates existing sessions. Also add an RLS check: `AND (SELECT is_active FROM profiles WHERE id = auth.uid())`.

**Warning signs:** Deactivated user can still fetch data from Supabase after deactivation.

### Pitfall 3: Kanban Realtime Broadcasts to Wrong Users

**What goes wrong:** Supabase Realtime channel is subscribed to the entire `leads` table. Sellers receive updates for leads they're not assigned to. Realtime bypasses RLS by default for `postgres_changes`.

**Why it happens:** Realtime `postgres_changes` respects RLS only when using Realtime RLS (requires specific configuration). By default it broadcasts all changes.

**How to avoid:** Filter subscriptions by `assigned_seller_id`:
```typescript
supabase
  .channel('leads-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'leads',
    filter: `assigned_seller_id=eq.${currentUserId}`  // manager omits this filter
  }, handler)
  .subscribe()
```

**Warning signs:** Seller's kanban shows leads from other sellers when another user moves a card.

### Pitfall 4: Kanban Stage Reorder Breaks on Position Conflicts

**What goes wrong:** Stage positions are integers (1, 2, 3). After many reorders, positions collide or require massive updates.

**How to avoid:** Use float positions or rewrite all positions on each reorder (acceptable at < 50 stages). On drag-end, compute new positions for all stages in the pipeline and batch-update.

### Pitfall 5: Supabase Admin Client Initialized in Browser Bundle

**What goes wrong:** Developer imports `supabaseAdmin` (initialized with service role key) in a component. The key is exposed in the client bundle and can be extracted.

**How to avoid:** The admin client must ONLY exist in Edge Functions. Create a separate file `lib/supabase-admin.ts` that is never imported from `src/components/` or `src/pages/`. All admin operations go through Edge Functions.

**Warning signs:** `SUPABASE_SERVICE_ROLE_KEY` appears in browser DevTools network requests or in the JavaScript bundle.

### Pitfall 6: Activity Log Missing AI-Authored Changes

**What goes wrong:** Activity log trigger uses `auth.uid()` as actor. When an Edge Function (Phase 3 AI agent) writes to `leads` using the service role, `auth.uid()` is null. All AI actions appear as anonymous.

**How to avoid from Phase 1:** Design `lead_activity_log` with:
- `actor_id UUID NULL` — null for system/AI writes
- `actor_type TEXT NOT NULL CHECK (actor_type IN ('human', 'agent', 'system'))`
- When Edge Functions write leads, they should also write an explicit activity log row with `actor_type = 'agent'` and the agent's ID

---

## Code Examples

### Database Schema (Core Tables for Phase 1)

```sql
-- Profiles (synced from auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL CHECK (role IN ('manager', 'seller')),
  availability TEXT NOT NULL DEFAULT 'offline' CHECK (availability IN ('online', 'offline')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pipelines
CREATE TABLE pipelines (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pipeline Stages
CREATE TABLE pipeline_stages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  pipeline_id UUID REFERENCES pipelines(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  position FLOAT NOT NULL,  -- float for easy reordering
  color TEXT DEFAULT '#6366f1',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Contacts (phone/IG user — deduplicated)
CREATE TABLE contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  channel TEXT NOT NULL CHECK (channel IN ('whatsapp', 'instagram', 'manual')),
  external_id TEXT,  -- phone or IG user ID; null for manual
  name TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE NULLS NOT DISTINCT (channel, external_id)
);

-- Leads
CREATE TABLE leads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  contact_id UUID REFERENCES contacts(id) NOT NULL,
  pipeline_id UUID REFERENCES pipelines(id) NOT NULL,
  stage_id UUID REFERENCES pipeline_stages(id) NOT NULL,
  assigned_seller_id UUID REFERENCES profiles(id),
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','in_progress','qualified','distributed','closed_won','closed_lost')),
  source TEXT CHECK (source IN ('whatsapp','instagram','manual')) DEFAULT 'manual',
  ai_active BOOLEAN DEFAULT false,
  notes TEXT,
  deleted_at TIMESTAMPTZ,  -- soft delete
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lead Activity Log
CREATE TABLE lead_activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE NOT NULL,
  actor_id UUID REFERENCES profiles(id),  -- null for agent/system
  actor_type TEXT NOT NULL CHECK (actor_type IN ('human', 'agent', 'system')),
  action TEXT NOT NULL,  -- 'created', 'stage_moved', 'field_updated', 'note_added', 'deleted', 'restored'
  payload JSONB,  -- { old: {}, new: {} } or { note: "..." }
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_leads_pipeline ON leads(pipeline_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_stage ON leads(stage_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_seller ON leads(assigned_seller_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_activity_log_lead ON lead_activity_log(lead_id, created_at DESC);
```

### RLS Policies (Core)

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE pipeline_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_activity_log ENABLE ROW LEVEL SECURITY;

-- Profiles: users see own profile; managers see all
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (
  id = auth.uid() OR auth.jwt() ->> 'role' = 'manager'
);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "profiles_manager_all" ON profiles FOR ALL USING (auth.jwt() ->> 'role' = 'manager');

-- Leads: sellers see only assigned; managers see all; soft-deletes hidden
CREATE POLICY "leads_select" ON leads FOR SELECT USING (
  deleted_at IS NULL AND (
    auth.jwt() ->> 'role' = 'manager'
    OR assigned_seller_id = auth.uid()
  )
);
CREATE POLICY "leads_insert" ON leads FOR INSERT WITH CHECK (
  auth.jwt() ->> 'role' = 'manager' OR assigned_seller_id = auth.uid()
);
CREATE POLICY "leads_update" ON leads FOR UPDATE USING (
  auth.jwt() ->> 'role' = 'manager' OR assigned_seller_id = auth.uid()
);

-- Pipelines + Stages: managers manage; sellers read
CREATE POLICY "pipelines_read_all" ON pipelines FOR SELECT USING (true);
CREATE POLICY "pipelines_manager_write" ON pipelines FOR ALL USING (auth.jwt() ->> 'role' = 'manager');
CREATE POLICY "stages_read_all" ON pipeline_stages FOR SELECT USING (true);
CREATE POLICY "stages_manager_write" ON pipeline_stages FOR ALL USING (auth.jwt() ->> 'role' = 'manager');

-- Activity log: accessible if user can see the lead
CREATE POLICY "activity_log_select" ON lead_activity_log FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM leads l WHERE l.id = lead_id
    AND (auth.jwt() ->> 'role' = 'manager' OR l.assigned_seller_id = auth.uid())
  )
);
```

### Auth Session Setup (Root Component)

```typescript
// App.tsx — session initialization
import { useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/store/auth';

export default function App() {
  const setSession = useAuthStore(s => s.setSession);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });
    return () => subscription.unsubscribe();
  }, []);

  // ... routes
}
```

### Supabase Realtime Subscription (Kanban)

```typescript
// hooks/useLeadsRealtime.ts
useEffect(() => {
  const filter = isManager ? undefined : `assigned_seller_id=eq.${userId}`;

  const channel = supabase
    .channel('leads-realtime')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'leads',
      ...(filter ? { filter } : {})
    }, () => {
      queryClient.invalidateQueries({ queryKey: ['leads'] });
    })
    .subscribe();

  return () => supabase.removeChannel(channel);
}, [userId, isManager]);
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Storing role in `profiles` table, queried in app | Role in `raw_app_meta_data` → available in JWT → RLS uses `auth.jwt()` | RLS works at DB layer without extra joins |
| Custom drag-and-drop with HTML5 drag events | Framer Motion `drag` with layout animations | Touch support, spring physics, simpler code |
| Polling for updates | Supabase Realtime `postgres_changes` | Real-time without WebSocket server overhead |
| `banned` boolean column + manual check | `supabaseAdmin.auth.admin.updateUserById` ban_duration | Invalidates existing sessions immediately |

---

## Open Questions

1. **Supabase Realtime RLS enforcement on postgres_changes**
   - What we know: By default, `postgres_changes` does not respect RLS — all changes broadcast to all subscribers of that table.
   - What's unclear: Whether Supabase's "Realtime RLS" feature (introduced ~2023) is enabled on this project and reliable.
   - Recommendation: Use client-side filter (`filter: assigned_seller_id=eq.${userId}`) as the safe default. Do not rely on Realtime RLS in Phase 1.

2. **Email invite customization**
   - What we know: Supabase sends a default invite email template.
   - What's unclear: Whether the email template has been customized in this project's Supabase dashboard.
   - Recommendation: Check Supabase dashboard Authentication > Email Templates before Phase 1 delivery. Plan for a task to customize invite email copy.

3. **`time in stage` computation for lead cards**
   - What we know: Lead cards must show "time in stage" (CRM-03 UI detail).
   - What's unclear: Whether this is tracked as a column on leads (`stage_entered_at`) or derived from activity log.
   - Recommendation: Add `stage_entered_at TIMESTAMPTZ` column to `leads`. Update it via trigger when `stage_id` changes. Simpler than deriving from activity log at query time.

---

## Validation Architecture

_nyquist_validation not found in config.json — skipping this section._

---

## Sources

### Primary (HIGH confidence)
- Project CONTEXT.md — locked decisions for this phase
- Project ARCHITECTURE.md — schema design, RLS patterns, component map
- Project STACK.md — library versions and fixed dependencies
- Project PITFALLS.md — known failure modes

### Secondary (MEDIUM confidence)
- Supabase Auth docs (training knowledge) — `inviteUserByEmail`, `onAuthStateChange`, JWT custom claims
- Supabase RLS patterns (training knowledge) — `auth.jwt()`, `auth.uid()`, service role behavior
- Framer Motion drag API (training knowledge) — `drag` prop, layout animations, optimistic update integration

### Tertiary (LOW confidence — flag for validation)
- Supabase Realtime RLS behavior with `postgres_changes` filter — verify in official Supabase docs before implementation
- Ban mechanism session invalidation behavior — test empirically: create user, ban, verify existing token rejected

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all versions confirmed from existing codebase (STACK.md)
- Architecture: HIGH — derived from ARCHITECTURE.md which was researched against fixed constraints
- Pitfalls: HIGH — based on PITFALLS.md + Phase 1-specific additions (role claim, Realtime RLS)
- Validation: N/A — nyquist_validation not enabled

**Research date:** 2026-03-11
**Valid until:** 2026-04-11 (Supabase API stable; 30-day window)
