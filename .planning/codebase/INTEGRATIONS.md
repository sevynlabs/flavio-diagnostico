# External Integrations

**Analysis Date:** 2026-03-11

## APIs & External Services

**Authentication & Backend:**
- Supabase - Complete backend-as-a-service platform
  - SDK/Client: `@supabase/supabase-js` 2.96.0
  - Auth: Uses Supabase authentication with JWT tokens stored in localStorage
  - Implementation: `src/integrations/supabase/client.ts` exposes global `supabase` client

**Payment Processing:**
- Stripe - Payment processing platform
  - Function endpoint: `{SUPABASE_URL}/functions/v1/stripe-checkout`
  - Auth: Bearer token (user's JWT from Supabase session)
  - Usage: `src/hooks/useCheckout.ts` handles plan checkout via Stripe

**Advertising & Social Media:**
- Meta/Facebook Ads API - Ad account management and synchronization
  - Function endpoint: `{SUPABASE_URL}/functions/v1/meta-ads-proxy`
  - Auth: Bearer token (Supabase anonymous key)
  - Actions supported:
    - `get_connection_status` - Check Meta connection status
    - `save_connection` - Store Meta ad account credentials
    - `disconnect` - Revoke Meta integration
  - Client library: `src/components/MetaAdsConnect.tsx`
  - Credentials required:
    - `access_token` - User or System User token from Meta
    - `ad_account_id` - Facebook ad account ID
    - `page_id` - Facebook page ID (optional)
    - `pixel_id` - Facebook pixel ID (optional)
    - `instagram_account_id` - Instagram account ID (optional)

## Data Storage

**Databases:**
- Supabase PostgreSQL (default Supabase database)
  - Connection: Managed by `@supabase/supabase-js` client
  - Client: Supabase JS SDK with automatic PostGrest ORM
  - Tables defined in `src/integrations/supabase/types.ts` (auto-generated)
  - Key tables:
    - `agent_demands` - Agent-to-agent requests and demands
    - `agent_outputs` - Agent output artifacts
    - Other tables: project management, user data, subscriptions, financial records

**File Storage:**
- Supabase Storage - Project galleries and document storage
  - Implementation: Used via Supabase client for image/document retrieval
  - Accessed in: `src/pages/Gallery.tsx`, `src/pages/Documents.tsx`

**Caching:**
- React Query (TanStack) - Client-side query caching and synchronization
  - Configuration: `QueryClient` initialized in `src/App.tsx`
  - Used throughout for managing async data fetching

## Authentication & Identity

**Auth Provider:**
- Supabase Auth
  - Implementation: Custom implementation in `src/contexts/AuthContext.tsx`
  - Features:
    - Session management via `supabase.auth.onAuthStateChange()`
    - JWT token extraction for API calls
    - localStorage-based session persistence
    - Automatic token refresh via Supabase client config
  - Entry point: `src/pages/Auth.tsx` for login/signup
  - Password reset: `src/pages/ResetPassword.tsx` via Supabase

## Monitoring & Observability

**Error Tracking:**
- None detected - Console logging only

**Logs:**
- Browser console - Client-side error logging via `console.error()`

## CI/CD & Deployment

**Hosting:**
- Static SPA deployment (architecture suggests Vercel, Netlify, or similar)

**CI Pipeline:**
- None detected in codebase

## Environment Configuration

**Required env vars:**
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_PUBLISHABLE_KEY` - Supabase anonymous key

**Secrets location:**
- `.env` file present (contains environment configuration)
- Supabase keys embedded in `src/integrations/supabase/client.ts` (public anon key only)
- Runtime token secrets: User JWT tokens obtained from Supabase auth session

## Webhooks & Callbacks

**Incoming:**
- Supabase Functions - Server-side functions handling:
  - `agent-chat` - AI agent communication endpoint
  - `stripe-checkout` - Payment session creation
  - `meta-ads-proxy` - Meta/Facebook Ads integration handler
  - `kb-import` - Knowledge base import processing
  - `orchestrator-run` - Orchestrator agent execution
  - `admin-test-api` - Admin testing endpoint

**Outgoing:**
- Stripe - Redirects to Stripe Checkout URL for payment processing
- Meta/Facebook - API calls to manage ad accounts and retrieve analytics

## Realtime Capabilities

**Supabase Realtime:**
- Implementation: `src/hooks/useRealtimeNotifications.ts`
- Purpose: Real-time notification system for collaborative features
- Pattern: Supabase broadcast channels for push notifications

---

*Integration audit: 2026-03-11*
