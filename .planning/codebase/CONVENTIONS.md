# Coding Conventions

**Analysis Date:** 2026-03-11

## Naming Patterns

**Files:**
- Components: PascalCase with `.jsx` extension (e.g., `SistemaCaptacao.jsx`, `App.jsx`)
- Entry points: lowercase (e.g., `main.jsx`)
- Styles: lowercase with `.css` extension (e.g., `index.css`, `App.css`)

**Functions:**
- Function components: PascalCase (e.g., `QualificationQuiz`, `Icon`, `SistemaCaptacao`)
- Custom hooks: camelCase prefixed with `use` (e.g., `useCounter`)
- Event handlers: camelCase with action prefix (e.g., `handleAnswer`, `onComplete`, `onMouseEnter`, `onMouseLeave`)
- Icon lookup functions: camelCase with descriptive names (e.g., `renderIcon`)

**Variables:**
- State variables: camelCase (e.g., `step`, `answers`, `score`, `quizDone`, `showQuiz`)
- Constants (static data): camelCase (e.g., `WHATSAPP_LINK` for top-level constants, lowercase for inline objects like `questions`, `testimonials`, `painPoints`)
- DOM references: camelCase (e.g., `ref`, `stat1`, `stat2`, `stat3`)
- Temporary variables in loops: single letter or abbreviated (e.g., `i`, `t`, `s`, `p`, `opt`)

**Types:**
- No TypeScript used in this project (JSX only)
- Object properties use camelCase (e.g., `isIntersecting`, `threshold`, `flexDirection`)

## Code Style

**Formatting:**
- No Prettier configuration found - code uses standard JavaScript formatting
- Consistent spacing and indentation with 2-space indents
- Lines generally kept within reasonable width
- JSX spread across multiple lines when complex

**Linting:**
- ESLint configured with `eslint.config.js` (flat config format)
- Active rules:
  - `no-unused-vars`: Error level, but ignores uppercase/underscore-prefixed variables (^[A-Z_])
  - `react-hooks/rules-of-hooks`: Enforced (from eslint-plugin-react-hooks)
  - `react/jsx-no-target-blank`: Enforced (from eslint-plugin-react-refresh)
- Browser globals enabled in `languageOptions`
- JSX support configured with `ecmaVersion: 'latest'`

**Linting Commands:**
```bash
npm run lint              # Run ESLint on all files
```

## Import Organization

**Order:**
1. React core imports (e.g., `import { useState, useEffect, useRef } from "react"`)
2. Third-party libraries (none in main code currently)
3. Internal components/modules (e.g., `import App from './App.jsx'`)
4. Constants and configuration

**Path Aliases:**
- Not used in this project
- Relative paths used throughout (e.g., `./SistemaCaptacao`, `./App.jsx`)

**Pattern from `src/SistemaCaptacao.jsx` (lines 1-3):**
```javascript
import { useState, useEffect, useRef } from "react";

const WHATSAPP_LINK = "https://wa.me/5500000000000?text=...";
```

## Error Handling

**Patterns:**
- No explicit try-catch blocks in current code
- Conditional rendering based on state values (e.g., `if (score !== null)` in line 117)
- Null safety through state initialization with falsy defaults
- No error boundaries or error logging detected

## Logging

**Framework:** None - no logging infrastructure detected

**Patterns:**
- Console methods not used in current codebase
- Debugging would rely on React DevTools and browser dev tools
- No structured logging or analytics integration visible

## Comments

**When to Comment:**
- Professional SVG Icon component with descriptive comment (line 5: `// Professional SVG Icon component`)
- Hook documentation: brief descriptive comment above function (line 29: `// Animated counter hook`)
- Component section markers use HTML comment format for visual organization:
  ```javascript
  {/* ============ HERO ============ */}
  {/* ============ PAIN POINTS ============ */}
  ```
- Comments explain non-obvious logic or section purposes

**JSDoc/TSDoc:**
- Not used in this project
- Minimal documentation through comments
- Function purposes described in adjacent comment lines

## Function Design

**Size:**
- Functions are generally compact and focused
- Complex UI rendering functions separated into their own components
- Individual section components within the main export

**Parameters:**
- Props passed as destructured objects where possible
- Event handlers use standard React event signatures
- Custom hook parameters are explicit (e.g., `useCounter(end, duration = 2000, startOnView = true)`)

**Return Values:**
- React components return JSX
- Hooks return objects with named properties (e.g., `return { count, ref }` in `useCounter`)
- Event handlers return void (side effects via setState)

## Module Design

**Exports:**
- One default export per component file
- `export default App` pattern used in `App.jsx` (line 7)
- Main component exported as default function (line 215 in `SistemaCaptacao.jsx`)

**Barrel Files:**
- Not used in this project
- Direct imports from component files

**Code Example Pattern (from `SistemaCaptacao.jsx`):**

Custom hooks follow React conventions with state management:
```javascript
function useCounter(end, duration = 2000, startOnView = true) {
  const [count, setCount] = useState(0);
  const [started, setStarted] = useState(!startOnView);
  const ref = useRef(null);

  useEffect(() => {
    // effect logic
  }, [startOnView]);

  return { count, ref };
}
```

Inline component rendering with data arrays:
```javascript
{questions.map((_, i) => (
  <div key={i} style={{ /* styles */ }} />
))}
```

Inline styles heavily used:
```javascript
style={{
  padding: "24px 28px",
  borderRadius: 16,
  background: "rgba(255,255,255,0.02)",
  border: "1px solid rgba(255,255,255,0.06)",
}}
```

Event handler binding inline with mouse interactions:
```javascript
onMouseEnter={e => { e.target.style.transform = "scale(1.05)"; }}
onMouseLeave={e => { e.target.style.transform = "scale(1)"; }}
```

---

*Convention analysis: 2026-03-11*
