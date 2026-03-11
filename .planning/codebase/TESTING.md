# Testing Patterns

**Analysis Date:** 2026-03-11

## Test Framework

**Runner:**
- No test runner currently configured
- No test dependencies in `package.json`

**Assertion Library:**
- Not installed

**Run Commands:**
```bash
# No testing infrastructure present
# Testing would need to be set up
```

## Test File Organization

**Location:**
- No test files found in the codebase
- Current project structure has no `__tests__`, `tests/`, or `.test.` files

**Naming:**
- N/A - no test files exist

**Structure:**
- N/A - no test files exist

## Test Structure

**Current State:**
- No test suites present in the codebase

## Mocking

**Framework:**
- Not applicable - no testing setup

**What to Mock (if testing were added):**
- React hooks (`useState`, `useEffect`, `useRef`)
- IntersectionObserver API (used in `useCounter` hook at line 37)
- DOM event handlers and mouse events
- External services (WhatsApp links)

**What NOT to Mock:**
- React component rendering
- State transitions (test actual behavior instead)
- Styled components' style calculations

## Fixtures and Factories

**Test Data:**
- No fixtures currently exist
- Candidate data structures for testing if framework added:
  - `questions` array in `QualificationQuiz` (lines 66-103) - quiz questions
  - `testimonials` array in main component (lines 223-242) - user testimonials
  - `painPoints` array (lines 244-251) - pain point cards
  - `systemSteps` array (lines 253-259) - system pillar descriptions

**Location:**
- Would belong in `src/__tests__/fixtures/` or `src/fixtures/`

## Coverage

**Requirements:**
- No coverage enforced or configured

**View Coverage:**
- Not applicable

## Test Types

**Unit Tests (Would need to test):**
- `useCounter` hook: verify count animation, intersection observer triggering
- `QualificationQuiz` component: question progression, score calculation, message selection based on score
- Icon component: SVG rendering based on icon name
- Event handlers: button clicks and state transitions

**Integration Tests (Would need to test):**
- Quiz flow: from question 1 through final CTA
- Statistics counter section: Intersection Observer triggers animations
- Navigation and WhatsApp link functionality
- Data binding between components (quiz results displaying correct message)

**E2E Tests:**
- Not implemented
- Would use Cypress or Playwright if added
- Key user flows: complete quiz, view results, click CTAs

## Recommended Testing Setup

**Framework Choice:**
```bash
# Recommended: Vitest for fast unit testing with Vite
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom

# Or: Jest for compatibility
npm install --save-dev jest @babel/preset-react @testing-library/react @testing-library/jest-dom
```

**Configuration (vitest.config.js would look like):**
```javascript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.js'],
  },
})
```

**Test Commands to Add to package.json:**
```json
{
  "test": "vitest",
  "test:ui": "vitest --ui",
  "test:coverage": "vitest --coverage"
}
```

## Example Test Patterns (Recommended Structure)

**Hook Testing Pattern:**
```javascript
// src/__tests__/hooks/useCounter.test.jsx
import { renderHook, act } from '@testing-library/react'
import { useCounter } from '../../hooks/useCounter'

describe('useCounter', () => {
  it('should animate from 0 to end value', () => {
    const { result } = renderHook(() => useCounter(100, 500, false))
    expect(result.current.count).toBe(0)

    act(() => {
      // animation trigger logic
    })
  })

  it('should trigger on intersection when startOnView is true', () => {
    const { result } = renderHook(() => useCounter(100, 500, true))
    // Mock IntersectionObserver
  })
})
```

**Component Testing Pattern:**
```javascript
// src/__tests__/components/QualificationQuiz.test.jsx
import { render, screen, fireEvent } from '@testing-library/react'
import { QualificationQuiz } from '../../SistemaCaptacao'

describe('QualificationQuiz', () => {
  it('should render first question on mount', () => {
    render(<QualificationQuiz onComplete={vi.fn()} />)
    expect(screen.getByText(/Qual é o seu faturamento/i)).toBeInTheDocument()
  })

  it('should advance to next question on answer click', () => {
    const { container } = render(<QualificationQuiz onComplete={vi.fn()} />)
    const button = screen.getAllByRole('button')[0]

    fireEvent.click(button)
    expect(screen.getByText(/Quantos clientes novos/i)).toBeInTheDocument()
  })

  it('should calculate score and show result message', () => {
    const onComplete = vi.fn()
    const { container } = render(<QualificationQuiz onComplete={onComplete} />)

    // Answer all questions
    const buttons = screen.getAllByRole('button')
    buttons.forEach(btn => fireEvent.click(btn))

    expect(onComplete).toHaveBeenCalledWith(expect.any(Number))
  })

  it('should show "critical" level message for low scores', () => {
    // Mock score path
  })
})
```

**Async Testing Pattern:**
```javascript
// For hooks with useEffect
import { renderHook, waitFor } from '@testing-library/react'

it('should update count after duration', async () => {
  const { result } = renderHook(() => useCounter(100, 1000, false))

  await waitFor(() => {
    expect(result.current.count).toBe(100)
  }, { timeout: 2000 })
})
```

## Current Testing Status

**Coverage Gaps:**
- `useCounter` hook logic untested (lines 30-58 in `SistemaCaptacao.jsx`)
- `QualificationQuiz` component logic untested (lines 61-212)
- Icon component rendering untested (lines 6-27)
- State transitions in main component untested
- Event handler logic (mouse events) untested
- Intersection Observer integration untested

**Priority Areas for Testing:**
1. **High**: Quiz scoring logic and message selection (business-critical)
2. **High**: Counter animation trigger on scroll
3. **Medium**: Component rendering and data flow
4. **Medium**: Event handler interactions
5. **Low**: Styling edge cases

---

*Testing analysis: 2026-03-11*
