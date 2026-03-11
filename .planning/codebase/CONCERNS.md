# Codebase Concerns

**Analysis Date:** 2026-03-11

## Tech Debt

**Monolithic Component Structure:**
- Issue: Entire application logic (UI, state, hooks, static data) is consolidated in `src/SistemaCaptacao.jsx` (710 lines)
- Files: `src/SistemaCaptacao.jsx`
- Impact: Single point of failure; difficult to test; impossible to reuse components; component bloat makes changes risky and hard to review
- Fix approach: Extract components (`QualificationQuiz`, `Icon`, `StatCard`, `TestimonialCard`, `PainPointCard`, `SystemStepCard`) into separate files. Create custom hooks file (`src/hooks.js` or `src/hooks/useCounter.js`). Extract static data to `src/constants.js`

**Inline Styling Throughout:**
- Issue: 99% of styling via inline `style` objects in JSX; no CSS framework, no component-level styling, no reusable style definitions
- Files: `src/SistemaCaptacao.jsx` (lines 145-687)
- Impact: Style duplication (e.g., dark background colors repeated 20+ times); zero consistency; hard to maintain theme colors; style props difficult to read in JSX; performance impact from dynamic style creation
- Fix approach: Adopt Tailwind CSS (already in the STACK.md as intended), extract color/spacing constants to `src/theme.js`, or move styles to `src/App.css`

**Manual IntersectionObserver + setInterval Counter Animation:**
- Issue: `useCounter` hook at lines 30-58 uses raw IntersectionObserver API and setInterval with manual interval management
- Files: `src/SistemaCaptacao.jsx` lines 30-58
- Impact: Performance concern with repeated setInterval calls; IntersectionObserver not cleaned up properly in unmount; animation timing inconsistent across browsers; memory leak risk if component unmounts mid-animation
- Fix approach: Use Framer Motion (already in STACK.md) for animation instead of raw setInterval. Ensure cleanup function always runs.

**Hardcoded WhatsApp Link:**
- Issue: Single WhatsApp number hardcoded in `WHATSAPP_LINK` constant with placeholder number `5500000000000`
- Files: `src/SistemaCaptacao.jsx` line 3
- Impact: Not functional; needs manual update for each deployment; no configuration management; makes testing difficult
- Fix approach: Move to environment variable: `VITE_WHATSAPP_NUMBER` in `.env`, construct link dynamically

**Static Data Embedded in Component:**
- Issue: Quiz questions (lines 66-103), testimonials (lines 223-242), pain points (lines 244-251), system steps (lines 253-259) hardcoded as component variables
- Files: `src/SistemaCaptacao.jsx`
- Impact: Data changes require component edits; no separation of concerns; difficult to add data-driven features; quiz data not easily testable
- Fix approach: Extract to `src/data/quiz.js`, `src/data/testimonials.js`, `src/data/painPoints.js`, `src/data/systemSteps.js`

**Google Fonts Imported in JSX:**
- Issue: Google Fonts link tag injected into JSX at line 269 with inline style tag
- Files: `src/SistemaCaptacao.jsx` lines 269-283
- Impact: Font loading blocks render; fonts not pre-optimized; CSS injected globally in component; style tag with hardcoded CSS not maintainable
- Fix approach: Move font import to `index.html` `<head>`, extract CSS to `src/App.css` or separate stylesheet

## Known Bugs

**Quiz Score Calculation Off-by-one Risk:**
- Symptoms: Quiz answers at question index `qIndex` but checks `qIndex < questions.length - 1` in line 108; edge case at final question
- Files: `src/SistemaCaptacao.jsx` lines 105-115
- Trigger: Completing quiz by answering the last (4th) question
- Workaround: Works as intended because setScore runs in else block, but logic is fragile

**Counter Animation Doesn't Respect Component Unmount:**
- Symptoms: If user navigates away or component unmounts during counter animation, setInterval may continue running
- Files: `src/SistemaCaptacao.jsx` lines 45-55
- Cause: Cleanup function clears interval, but if component unmounts before `started` state becomes true, observer cleanup may not trigger properly
- Workaround: None currently; component doesn't unmount in current app design but would be problematic if App component adds routing

**Font Family Override Loses Fallbacks:**
- Symptoms: All text uses `fontFamily: "'Outfit', 'Helvetica Neue', sans-serif"` in inline style (line 266)
- Files: `src/SistemaCaptacao.jsx` line 266
- Cause: Single override in root div doesn't cascade; child elements inherit but don't include fallback chain for safety
- Workaround: Fonts actually load, so fallback not triggered, but no safety net if Outfit fails to load

## Security Considerations

**Hardcoded WhatsApp Contact Info:**
- Risk: Phone number visible in client-side JavaScript (line 3); scraping for spam, no privacy protection
- Files: `src/SistemaCaptacao.jsx` line 3
- Current mitigation: WhatsApp link redirects to wa.me service, which masks the actual phone internationally
- Recommendations: Keep phone in environment variable; consider hiding behind environment check (dev vs prod numbers)

**External CDN Dependency (Google Fonts):**
- Risk: Outage of Google Fonts CDN blocks page render; no fallback fonts loaded; potential privacy concern (Google tracks font requests)
- Files: `src/SistemaCaptacao.jsx` line 269
- Current mitigation: Browser fallback fonts in style definition (Helvetica)
- Recommendations: Self-host fonts or use system fonts; add font-display: swap to Google Fonts import

**Inline SVG Security:**
- Risk: SVGs are hardcoded in Icon component (lines 7-25) and testimonials section (line 537); no sanitization
- Files: `src/SistemaCaptacao.jsx`
- Current mitigation: SVGs come from trusted internal code, no user-generated content
- Recommendations: Continue restricting SVGs to trusted sources; consider moving to separate icon library if data-driven

**No Input Validation in Quiz:**
- Risk: Quiz form doesn't validate selections; assumes answers object always contains all questions; no error handling
- Files: `src/SistemaCaptacao.jsx` lines 61-212
- Current mitigation: Form has fixed 4 questions, buttons always fire `handleAnswer()`, doesn't submit to server
- Recommendations: Add assertion that all answers exist before score calculation; validate `score` is number before checking level

## Performance Bottlenecks

**Counter Animation Calculation Inefficiency:**
- Problem: setInterval fires every 16ms (line 49) with full state update and re-render, even if counter value hasn't changed
- Files: `src/SistemaCaptacao.jsx` lines 45-55
- Cause: `start += step` can produce fractional values; `Math.floor()` keeps same value multiple frames in a row; still causes re-render
- Improvement path: Use `requestAnimationFrame` instead of setInterval; batch updates; only setState when value actually changes

**Inline Style Object Recreation on Every Render:**
- Problem: Every inline `style={{...}}` object is created fresh on each render, causing React to skip optimizations
- Files: `src/SistemaCaptacao.jsx` throughout
- Cause: No memoization of style objects; objects always compared by reference as different
- Improvement path: Use `useMemo()` for styles; extract to constants; switch to CSS-in-JS or Tailwind

**No Code Splitting or Lazy Loading:**
- Problem: Entire page bundled as single JS file; all sections load at once even if user never scrolls to them
- Files: All in single SPA bundle
- Cause: Single-page monolithic component; no route-based code splitting; no lazy import
- Improvement path: Add route-based splitting if navigation added; lazy-load below-fold sections with `React.lazy()`

**IntersectionObserver Threshold Performance:**
- Problem: Three counter sections each create separate IntersectionObserver with `threshold: 0.3`; no batching
- Files: `src/SistemaCaptacao.jsx` lines 37-42 (instantiated 3 times in component)
- Cause: Each useCounter hook creates its own observer; no observer pooling or reuse
- Improvement path: Create single shared IntersectionObserver for all counters; batch observations

## Fragile Areas

**Quiz Result Message Mapping:**
- Files: `src/SistemaCaptacao.jsx` lines 118-141
- Why fragile: Message selection depends on exact score thresholds (≤6, ≤10, else); no error state for unexpected scores; if logic changes, must update both scoring and messaging
- Safe modification:
  1. Add constants for threshold values: `SCORE_CRITICAL = 6, SCORE_GROWTH = 10`
  2. Add fallback message if score doesn't match any level
  3. Add tests for boundary conditions (score=6, 7, 10, 11, 16)
- Test coverage: None; no tests for score calculation or message selection

**useCounter Hook with Intersection Observer:**
- Files: `src/SistemaCaptacao.jsx` lines 30-58
- Why fragile: Cleanup function may not run if effect dependencies change; `started` state couples observer logic with animation logic; hardcoded `threshold: 0.3` not configurable
- Safe modification:
  1. Separate observer setup from animation logic into different effects
  2. Make threshold configurable as parameter
  3. Add explicit cleanup for observer on unmount
  4. Test with different viewport sizes and scroll speeds
- Test coverage: None; no tests for intersection observer or animation timing

**Event Handler Style Mutations:**
- Files: `src/SistemaCaptacao.jsx` lines 167-168, 203-204, 338-339, 377-378, 424-425, 517-518, 586-587, 666-667
- Why fragile: Direct DOM manipulation via `e.target.style.X = Y` bypasses React; if element changes type or structure, selectors break; no cleanup if handler fires multiple times
- Safe modification:
  1. Switch to CSS classes with `:hover` pseudo-class
  2. Use React state for interactive states instead of DOM mutation
  3. Use `onMouseLeave` to always reset styles
  4. Add guards to check element exists before mutating
- Test coverage: None; no tests for mouse interactions

**Icon Component Lookup:**
- Files: `src/SistemaCaptacao.jsx` lines 6-27
- Why fragile: Returns `null` if icon name doesn't exist (line 26); no error logging; silent failure; if typo in icon name prop, renders nothing
- Safe modification:
  1. Add fallback icon (e.g., `alert-circle`)
  2. Log warning if icon not found: `console.warn('Icon not found:', name)`
  3. Type check with TypeScript or prop validation
  4. List available icons in JSDoc
- Test coverage: None; no tests for icon rendering

## Scaling Limits

**Single Component Scaling:**
- Current capacity: 710 lines in single JSX file; maintainable up to ~1000 lines with difficulty
- Limit: Adding more sections, quizzes, or data sources will exceed comfortable component size
- Scaling path:
  1. Extract to multiple component files immediately
  2. Consider headless CMS or API for content if more landing pages needed
  3. Switch to builder/template system if landing page variations required

**Static Data Limit:**
- Current capacity: 4 quiz questions, 3 testimonials, 6 pain points, 5 system steps hardcoded
- Limit: Adding >20 data items across all arrays becomes unmaintainable in component code
- Scaling path:
  1. Extract data to separate `.js` files
  2. Connect to CMS or JSON API for dynamic content
  3. Implement admin panel for non-developers to edit content

**Browser Performance (Inline Styles):**
- Current capacity: ~40 inline style objects; style engine handles, but slows re-renders
- Limit: +100 inline styles or complex responsive logic will degrade animation performance
- Scaling path: Migrate to Tailwind CSS or CSS modules; use `useMemo()` to prevent style recreation

## Dependencies at Risk

**None Critical Identified:**
- React 19.2.0: Latest major version; frequent updates but well-maintained; low risk
- Vite 7.3.1: Latest version; stable; no known risks
- ESLint 9.39.1: Latest version; no risks

**Risk Areas:**
- No automated testing framework → Cannot verify compatibility on upgrades
- No lock file best practices (package-lock.json present but not verified in docs)
- Single-dependency architecture (React only) is actually safe; no version conflicts possible

## Missing Critical Features

**No Error Boundary:**
- Problem: If any component errors, entire page crashes with white screen; no fallback UI
- Blocks: Graceful error handling; user-friendly error messages
- Implementation: Wrap entire app in ErrorBoundary component that catches render errors

**No Analytics or Conversion Tracking:**
- Problem: No way to track quiz completion, CTA clicks, or user engagement
- Blocks: Measuring campaign effectiveness; A/B testing; understanding user behavior
- Implementation: Add Segment/Mixpanel or Google Analytics tracking

**No Form Validation:**
- Problem: Quiz just collects answers without validation; no feedback if submission fails
- Blocks: Server-side submission; email capture; lead qualification automation
- Implementation: Add React Hook Form + Zod for validation and submission

**No Responsive Images:**
- Problem: All styling responsive via `clamp()` and viewport units, but no actual image assets exist (yet)
- Blocks: Adding case study images, testimonial photos, product demos
- Implementation: Use `<img srcSet>` with responsive images or webp format

**No Mobile Navigation:**
- Problem: No hamburger menu or mobile-optimized navigation; scrolling only
- Blocks: Desktop/tablet UX for long pages (user scrolls far for CTA)
- Implementation: Add sticky mobile CTA button; add table-of-contents nav for long sections

## Test Coverage Gaps

**useCounter Hook - Not Tested:**
- What's not tested: Intersection observer triggering, animation frame timing, cleanup on unmount, multiple counters interference
- Files: `src/SistemaCaptacao.jsx` lines 30-58
- Risk: Animation may not trigger correctly; observers leak memory if unmounted; timing varies across browsers
- Priority: High - Used in 3 critical stat cards

**QualificationQuiz Component - Not Tested:**
- What's not tested: Question progression, score calculation, result message selection, edge cases (no answer, skip question)
- Files: `src/SistemaCaptacao.jsx` lines 61-212
- Risk: Quiz may break on unexpected user input; wrong message displayed for score; score calculation has silent bugs
- Priority: High - Business-critical conversion funnel

**Icon Component - Not Tested:**
- What's not tested: Icon name lookup, fallback for missing icons, SVG rendering
- Files: `src/SistemaCaptacao.jsx` lines 6-27
- Risk: Typos in icon names cause silent failures; misleading UI
- Priority: Medium - Many icon references scattered

**Event Handler Interactions - Not Tested:**
- What's not tested: Mouse enter/leave style updates, button hover states, link clicks
- Files: `src/SistemaCaptacao.jsx` lines 167-168, 203-204, 338-339, etc.
- Risk: Interactive elements may not respond to user input; styles may not reset
- Priority: Medium - Critical for UX

**Static Data Rendering - Not Tested:**
- What's not tested: Testimonials rendering, pain points cards, system steps display
- Files: `src/SistemaCaptacao.jsx` lines 223-259
- Risk: Data changes may break layout; map functions may not handle edge cases
- Priority: Low - Mostly static UI

**Responsive Behavior - Not Tested:**
- What's not tested: Layout on mobile, tablet, desktop; clamp() calculations; grid breakpoints
- Files: Entire component
- Risk: Layout breaks on certain viewport sizes; text unreadable on mobile
- Priority: High - Mobile users likely significant

## Recommendations for Next Phase

1. **Immediate (High Impact):**
   - Extract components to separate files to reduce monolith
   - Add error boundary for graceful error handling
   - Migrate inline styles to Tailwind CSS for consistency

2. **Short-term (Medium Impact):**
   - Add test framework (Vitest + React Testing Library)
   - Write tests for quiz logic and counter hook
   - Move WhatsApp number to environment variable
   - Extract static data to separate files

3. **Medium-term (Nice to Have):**
   - Add analytics tracking
   - Implement mobile-optimized navigation
   - Switch to requestAnimationFrame for counter animations
   - Add responsive image support

---

*Concerns audit: 2026-03-11*
