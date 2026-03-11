# Architecture

**Analysis Date:** 2026-03-11

## Pattern Overview

**Overall:** Single-page marketing/landing page application with monolithic component structure.

**Key Characteristics:**
- Client-side React application with no backend API
- Component-centric architecture with all state managed locally in parent component
- Inline styling approach with no CSS abstractions
- Scroll-triggered animations and interactive quiz component
- No routing or multi-page navigation

## Layers

**Presentation Layer:**
- Purpose: Render all UI sections and handle user interactions
- Location: `src/SistemaCaptacao.jsx` (main component), `src/App.jsx` (wrapper)
- Contains: React components, inline styles, SVG icons, animations
- Depends on: React hooks (useState, useEffect, useRef), Intersection Observer API
- Used by: `src/main.jsx` entry point

**Data/State Layer:**
- Purpose: Manage application state (quiz progress, counter animation state)
- Location: Embedded in `src/SistemaCaptacao.jsx` using React hooks
- Contains: useState calls, static data arrays (questions, testimonials, pain points, system steps)
- Depends on: React hooks API
- Used by: Presentation layer components

**Utility/Hook Layer:**
- Purpose: Encapsulate reusable logic for animations and UI behavior
- Location: `src/SistemaCaptacao.jsx` - custom hooks `useCounter()` and `Icon()` component
- Contains: Custom hooks for animated counters, icon rendering component
- Depends on: React hooks (useState, useEffect, useRef)
- Used by: Main SistemaCaptacao component

## Data Flow

**Page Load & Counter Animation:**

1. SistemaCaptacao component mounts with quizDone and showQuiz state
2. Three useCounter hooks initialize for stats section
3. Each counter's ref is attached to its DOM element
4. Intersection Observer triggers when stats section enters viewport (30% threshold)
5. Counter animation runs for 1500-2000ms, updating count state via setInterval
6. Animated values display with gradient text styling

**Quiz Interaction Flow:**

1. User clicks "FAZER MEU DIAGNÓSTICO" button → setShowQuiz(true)
2. QualificationQuiz component renders with step=0 (first question)
3. User selects answer → handleAnswer() called with qIndex and points
4. Answer stored in state object, step increments, setTimeout(300ms) for animation
5. After final question, total score calculated from all answers
6. Quiz result message determines level (critical/growth/scale) and displays result card
7. WhatsApp CTA button in result card triggers external link

**State Management:**

- No global state management (Context API, Redux, Zustand)
- All state contained in `SistemaCaptacao.jsx` parent component
- Quiz state and quiz completion passed via callback to parent
- Child components (QualificationQuiz, Icon) receive props but manage local state
- Static content (testimonials, pain points, system steps) as arrays in component

## Key Abstractions

**Icon Component:**
- Purpose: Centralized SVG icon library with consistent sizing and color props
- Examples: `src/SistemaCaptacao.jsx` lines 6-27
- Pattern: Function component accepting name, size, color props; returns SVG element from icons object

**useCounter Hook:**
- Purpose: Animate numeric counters on scroll, trigger animation when element enters viewport
- Examples: `src/SistemaCaptacao.jsx` lines 30-58, lines 219-221
- Pattern: Custom hook using IntersectionObserver and setInterval; returns count value and ref for attachment

**QualificationQuiz Component:**
- Purpose: Multi-step quiz with point-based scoring and dynamic result messaging
- Examples: `src/SistemaCaptacao.jsx` lines 60-212
- Pattern: Stateful component with multi-step progression, score calculation, result message mapping

## Entry Points

**main.jsx:**
- Location: `src/main.jsx`
- Triggers: Page load (vite dev server or built bundle)
- Responsibilities: Mount React app to DOM (#root), render App component with StrictMode

**App.jsx:**
- Location: `src/App.jsx`
- Triggers: Called by main.jsx
- Responsibilities: Simple wrapper component that renders SistemaCaptacao

**SistemaCaptacao.jsx:**
- Location: `src/SistemaCaptacao.jsx`
- Triggers: Rendered by App component
- Responsibilities: Main application logic - render all page sections, manage quiz and counter state, handle user interactions

**index.html:**
- Location: `index.html` (root)
- Triggers: Requested by browser
- Responsibilities: HTML entry point with div#root placeholder and module script reference

## Error Handling

**Strategy:** No explicit error handling; application assumes successful render and API availability.

**Patterns:**
- No try/catch blocks in components
- No error boundaries implemented
- Intersection Observer and external links (WhatsApp) have no error handling
- Counter animations clear intervals on unmount via cleanup function

## Cross-Cutting Concerns

**Logging:** None - no console.log or logging framework in use

**Validation:** No form validation - quiz simply accepts any answer, WhatsApp link is hardcoded

**Authentication:** Not applicable - no authentication or authorization logic needed

**Styling:** Inline style objects passed to React elements; no global CSS framework (no Tailwind, styled-components, etc.); Google Fonts imported via link tag in component JSX

**Animations:**
- CSS keyframes defined in style tag (pulse-glow, float-in)
- JavaScript-driven counter animations using setInterval
- CSS transitions on hover for interactive elements
- Intersection Observer for scroll-triggered animations

---

*Architecture analysis: 2026-03-11*
