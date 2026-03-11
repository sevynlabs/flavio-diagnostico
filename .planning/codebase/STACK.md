# Technology Stack

**Analysis Date:** 2026-03-11

## Languages

**Primary:**
- TypeScript 5.8.3 - All source code (`src/**/*.ts`, `src/**/*.tsx`)

**Secondary:**
- JavaScript - Build configuration files, ESLint config

## Runtime

**Environment:**
- Node.js (via nvm)

**Package Manager:**
- npm - Managed via package-lock.json
- Lockfile: present (package-lock.json)

## Frameworks

**Core:**
- React 18.3.1 - UI framework, primary development focus
- React DOM 18.3.1 - React rendering to DOM
- React Router DOM 6.30.1 - Client-side routing (`src/App.tsx`)

**State & Data Management:**
- TanStack React Query 5.83.0 - Server state management and data fetching
- Framer Motion 12.34.0 - Animation library

**UI Components:**
- Radix UI 1.1-1.2 (multiple) - Headless UI component primitives
  - Components: accordion, alert-dialog, dialog, dropdown-menu, popover, select, slider, tabs, toast, tooltip, and 10+ others
- shadcn/ui - Component library built on Radix UI (configured via `components.json`)
- Lucide React 0.462.0 - Icon library

**Form & Validation:**
- React Hook Form 7.61.1 - Form state management
- @hookform/resolvers 3.10.0 - Form resolver library
- Zod 3.25.76 - TypeScript-first schema validation

**Styling:**
- Tailwind CSS 3.4.17 - Utility-first CSS framework
- PostCSS 8.5.6 - CSS processing
- Autoprefixer 10.4.21 - CSS vendor prefix handling
- tailwindcss-animate 1.0.7 - Animation utilities for Tailwind
- class-variance-authority 0.7.1 - Variant management for styled components
- clsx 2.1.1 - Conditional class names

**Utilities:**
- Date-fns 3.6.0 - Date manipulation and formatting
- React Day Picker 8.10.1 - Date picker UI component
- React Markdown 10.1.0 - Markdown rendering
- React Resizable Panels 2.1.9 - Resizable layout panels
- Recharts 2.15.4 - Chart/graph library
- Embla Carousel 8.6.0 - Carousel component
- Sonner 1.7.4 - Toast notifications
- next-themes 0.3.0 - Theme management (light/dark)
- input-otp 1.4.2 - OTP input component
- vaul 0.9.9 - Drawer component
- tailwind-merge 2.6.0 - Merge Tailwind class names intelligently

**Testing:**
- Vitest 3.2.4 - Test runner (configured via `vitest.config.ts`)
- @testing-library/react 16.0.0 - React component testing utilities
- @testing-library/jest-dom 6.6.0 - DOM matchers for assertions
- jsdom 20.0.3 - DOM implementation for Node.js

**Build/Dev:**
- Vite 5.4.19 - Build tool and dev server (configured via `vite.config.ts`)
- @vitejs/plugin-react-swc 3.11.0 - React plugin using SWC compiler
- lovable-tagger 1.1.13 - Development tool for component tagging
- TypeScript ESLint 8.38.0 - TypeScript linting rules
- @eslint/js 9.32.0 - ESLint base configuration
- eslint 9.32.0 - Code linting
- eslint-plugin-react-hooks 5.2.0 - React hooks linting rules
- eslint-plugin-react-refresh 0.4.20 - React fast refresh rules

**Type Definitions:**
- @types/react 18.3.23 - React type definitions
- @types/react-dom 18.3.7 - React DOM type definitions
- @types/node 22.16.5 - Node.js type definitions
- globals 15.15.0 - Global type definitions

## Key Dependencies

**Critical:**
- @supabase/supabase-js 2.96.0 - Why it matters: Core backend service for auth, data, and functions

**Infrastructure:**
- Node.js tooling - Platform for development and build processes

## Configuration

**Environment:**
- Vite-based environment variables using `import.meta.env`
- Required environment variables:
  - `VITE_SUPABASE_URL` - Supabase project URL (e.g., `https://mkbsaitjqwxlpiurbibm.supabase.co`)
  - `VITE_SUPABASE_PUBLISHABLE_KEY` - Supabase anonymous key for client-side auth

**Build:**
- `vite.config.ts` - Main Vite configuration with React SWC plugin
- `tsconfig.json` - Base TypeScript configuration with path aliases (`@/*` → `./src/*`)
- `tsconfig.app.json` - App-specific TypeScript configuration
- `tsconfig.node.json` - Build tool TypeScript configuration
- `.eslintrc` (implicit via `eslint.config.js`) - ESLint configuration
- `postcss.config.js` - PostCSS configuration for Tailwind
- `tailwind.config.ts` - Tailwind CSS configuration with custom theme (colors, fonts, animations)
- `components.json` - shadcn/ui component configuration

## Platform Requirements

**Development:**
- Node.js (managed via nvm)
- npm (or compatible package manager)
- Modern browser (ES2020+ JavaScript support)

**Production:**
- Static hosting (SPA deployment)
- HTTPS support (for Supabase auth)
- Browser JavaScript enabled

---

*Stack analysis: 2026-03-11*
