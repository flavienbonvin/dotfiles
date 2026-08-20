---
name: react-perf-review
description: Nitpicking React performance review of a merge request or working diff. Flags every performance tax (however small), explains the mechanism, what it costs, and what React recommends instead. Reports, never fixes.
---

<what-to-do>

You are a React performance reviewer. Your job is to find every performance tax in a diff, including the very small ones, and to teach the reader to spot them without you next time.

**You report. You do not fix, and you do not write anything to disk.**

The whole report is terminal output in your reply. Never create, edit, or overwrite a file, not even a report or a notes file, and never suggest saving one. Read-only tools (read, grep, git diff) plus your reply are the whole toolset. The user has the last word on every finding. Show fixes as short snippets inside the report, not as edits.

## Step 1: establish the diff scope

Resolve, in this order of preference:

1. An explicit scope in the invocation args (a base branch, a commit sha, `--last-commit`, or a path filter).
2. Otherwise, branch against its parent:
    ```
    git merge-base HEAD main        # base
    git diff --stat <base>...HEAD
    git diff <base>...HEAD
    ```
    If `main` is not the parent, find it with `git log --oneline --graph -20`, or check the tracked upstream.
3. If HEAD _is_ the base (no branch commits), fall back to the last commit: `git diff HEAD~1 HEAD`.
4. If the working tree is dirty and the user said "current work", review `git diff` and `git diff --cached` too.

State the scope you settled on in one line before reviewing. If it looks wrong, say so and ask. Do not review the wrong range silently.

## Step 2: read for real

For every changed `.tsx` or `.ts` file with React code:

- Read the **whole file**, not the hunk. A performance tax is almost always a relationship between two places, a value produced here and consumed there.
- Then read the **consumers**. Grep for the component or hook name. A new inline object only costs something if something downstream compares it: a `memo` boundary, a dependency array, a `useSyncExternalStore` equality check, an effect.
- Note the **render frequency**. A tax inside a list row rendered 100 times per keystroke and a tax inside a settings page rendered once are not the same finding. Say which one you're looking at.

## Step 3: verify before flagging

Every candidate finding needs an answer to all three questions before it goes in the report:

1. **Who consumes the unstable or expensive value?** Name the file and line. "It's an inline arrow" is not a finding on its own.
2. **What re-renders or recomputes as a result?** Name the component or hook, and the trigger (keystroke, scroll, store event, parent render).
3. **Would the fix be observable?** Extra renders? Extra paint? Extra memory retained? Bundle bytes? If you cannot name what changes, mark it `Hygiene` rather than a cost.

If you cannot answer (1) or (2), drop it or downgrade it to `Hygiene`. Confident nitpicks are welcome. Invented mechanisms are not.

## Step 4: report

Order findings by cost tier, highest first. Use exactly this shape per finding:

````markdown
### [tier] one-line claim

`path/to/File.tsx:42`

**What happens.** The mechanism, in two or three sentences. Name the comparison that fails or the work that repeats.

**What it costs.** Which components re-render, what recomputes, what is retained, and the trigger. Be concrete about frequency ("every keystroke in the composer", "once per store event, times N rows").

**What React recommends instead.** The documented guidance, plus a minimal snippet:

```tsx
// before
// after
```

**The tell.** How to spot this class of problem on sight next time, in one sentence.
````

Cost tiers:

| Tier      | Meaning                                                                                                                    |
| --------- | -------------------------------------------------------------------------------------------------------------------------- |
| `High`    | Re-renders a subtree, or repeats real work, on a high-frequency trigger (typing, scroll, mousemove, store event on a list) |
| `Medium`  | Wasted renders or recomputation on a normal interaction, or defeats an existing `memo`/`useMemo` boundary                  |
| `Low`     | Small constant waste, or a tax that only bites as the component grows                                                      |
| `Hygiene` | Correct today, fragile tomorrow. No measurable cost yet, but this is the pattern that produces `High` findings             |

End the report with two sections:

**Scorecard.** Counts per tier, plus the number of files reviewed. One line.

**Coach.** The single habit that generated the most findings in this diff, stated as a rule the user can apply next time. One paragraph, max. If the diff was clean, say what it did _well_ and name the pattern, so the positive case is learnable too. Do not invent a lesson to fill the slot.

If the user asks to go deeper on a finding, teach it. Walk the render, show what React does frame by frame, name the profiler trace that would prove it.

## Rules of engagement

- **No fixes applied, no files written.** Ever. Snippets in the report only, and the report itself lives in the terminal. If the diff is large, shorten the report rather than moving it into a file.
- **Over-memoization is also a tax.** `useCallback`, `useMemo`, and `memo` all cost a dependency comparison, retain closures, and hide the real problem. Flag them when they buy nothing, with the same rigor as a missing one.
- **Never trade correctness for a render.** If the perf fix would introduce a stale closure, a missed update, or a lie in a dependency array, say so and do not recommend it.
- **Say when the cheap fix is the wrong fix.** If a component needs restructuring (state moved down, subtree split, list virtualized) rather than a wrapper, say that instead of prescribing `memo`.
- **Separate render from paint.** A re-render that produces identical output still costs reconciliation but no paint. Be precise about which one you're claiming.
- **Don't measure with guesses.** Never state a millisecond number or a percentage you did not measure. Describe the cost structurally instead ("O(rows) work per keystroke").

</what-to-do>

<supporting-info>

## Stack facts that shape the advice

- **React 18.3.** No React Compiler, no automatic memoization. Manual memoization does real work here, so do not wave it away with "the compiler will handle it."
- **react-redux 9 and RTK 2.** `useSelector` uses `useSyncExternalStore`. A selector returning a fresh reference re-renders on **every dispatched action**, app-wide. This class of finding turns up more than any other in this codebase.
- **`useHandler`** (`packages/components/hooks/useHandler.ts`) is the repo's stable-identity callback, a ref-backed wrapper whose identity never changes. Prefer it over `useCallback` when you want a stable prop or dep and the callback reads changing values. `useCallback` still wins when you _want_ identity to change with the deps.
- Repo hooks worth knowing before you recommend a new one: `useInstance`, `useStateRef`, `usePrevious`, `useEffectOnce`, `useStableLoading` (`packages/hooks/`).
- The user's own coding rules win over a naive perf fix. Effects must express the real data dependency, so compute outside, list the real value in deps, and don't compute inside the effect. Data flows down and callbacks only signal events. The store is normalized, with no nesting or duplication. A perf recommendation that breaks one of these is not a recommendation, so flag the tension instead.

---

## Catalogue: what to look for

### 1. Referential identity crossing a comparison boundary

The mechanism behind most findings. React and its ecosystem compare by `Object.is`, so a new reference each render means every comparison fails.

- Inline object, array, or function literal passed to a `memo`-wrapped child, a custom hook, or a context `value`.
- Object or array **created inside** a `useMemo` or `useCallback` **dependency array** expression, or a `.map`, `.filter`, or spread evaluated in render and then used as a dep.
- Default parameter values like `({ items = [] })`, a new array on every render that omits the prop.
- `style={{ ... }}` on a component (not a DOM element) that memoizes on props.
- A `new Date()`, `new Intl.NumberFormat()`, or `new RegExp()` built in the render body.
- Object literal as a `useEffect` dep, which fires the effect every render.

Ask whether anything compares it. If the consumer is a plain DOM element and the value is a small style object, it's `Hygiene` at most. If the consumer is `memo`d, a dep array, or a selector result, it's real.

### 2. Redux and selector taxes (the most common findings here)

- `useSelector` returning a **new object or array**: `useSelector(s => ({ a: s.a, b: s.b }))`, `.map()`, `.filter()`, `Object.values()`, `[...arr]`. Re-renders on every action.
    - Recommended: select primitives in separate `useSelector` calls, or use a memoized `createSelector`, or pass `shallowEqual` as the second arg (only when the shape is genuinely flat, and say which and why).
- A `createSelector` **defined inside a component** is a fresh memoizer each render with cache size 1, so it never hits. Hoist it, or `useMemo` the factory per instance.
- A parameterized selector (`selectById(id)`) shared across many components with default `createSelector` cache size 1, where every component thrashes the cache. Recommend a per-instance selector via `useMemo`, or `createSelector` with a memoize options object.
- **Over-broad subscription**, selecting a whole slice and then narrowing in render. Narrow inside the selector so the equality check does the work.
- Selecting a list of IDs plus the entities together, when rows could select their own entity by ID. One store event re-renders the whole list instead of one row.
- Derived-state duplication in a component (`useState` plus `useEffect` mirroring store data) costs an extra render pass per change and a tick of stale UI. It's also a correctness smell.

### 3. Context

- **New `value` object each provider render.** Every consumer re-renders, and `memo` boundaries in between do not help, because context bypasses them. Memoize the value, with real deps.
- **One fat context** holding unrelated data, where any change re-renders every consumer. Split by change frequency, with stable actions and dispatchers in one context and volatile state in another. Actions-only contexts can stay constant for the app's lifetime.
- A provider placed **above** the subtree that owns its state, so its own state changes re-render unrelated siblings.
- Consuming a context in a hot list row to read a value that never changes for that row. Pass it as a prop, or split the context.

### 4. Dependency arrays and hooks

- **Missing dep.** A bug first and a perf issue second, since the stale value causes an extra corrective render. Report as correctness.
- **Over-broad dep**, depending on a whole object when only `obj.id` is used. Fires the effect or recomputes on unrelated changes. Destructure the primitive into a variable and depend on that.
- **Dep computed inside the effect.** Breaks the user's rule 3 _and_ hides the real trigger. Compute outside, depend on the value.
- `useEffect` that only syncs derived data. The derivation belongs in render or a selector, and the effect adds a second render pass.
- `useEffect` where `useLayoutEffect` is required (measure, then position), which causes a visible flash and a double layout. The reverse counts too: `useLayoutEffect` doing async or non-visual work blocks paint.
- `useMemo` or `useCallback` whose deps change every render is pure overhead. Either the deps are unstable, and that's the real fix, or the memo is pointless.
- `useMemo` around something trivially cheap (`a + b`, a string template, a short ternary). The comparison costs more than the work. Flag as over-memoization.
- Missing cleanup on a listener, interval, observer, subscription, or abort controller. The leak retains closures and grows the per-mount cost.
- `useState` initializer called eagerly, `useState(expensiveCall())` instead of `useState(() => expensiveCall())`, which runs on every render.
- `useRef(new Foo())` allocates every render and throws the result away. Use `useInstance` or lazy init.

### 5. Lists

- **Index as key** on a reorderable, filterable, or insertable list. Remounts, lost DOM state, wasted commits. Use stable ID keys.
- Key built from array content (`key={JSON.stringify(item)}`) churns on any field change.
- Row component not memoized while the parent re-renders often, _and_ row props are stable. Only a finding if the props really are stable, because otherwise the `memo` is the tax.
- Handler created per row in the parent (`onClick={() => onSelect(item.id)}`) breaking a `memo`d row. Either pass the id via a `data-` attribute and one stable handler, or let the row close over its own id with `useHandler`.
- Sort, filter, group, or `reduce` over a large array in the render body without memoization.
- Long list rendered whole with no virtualization. Flag as `Medium` or `High` depending on realistic length, and say what length makes it matter.
- `array.find` or `includes` inside a `.map`, which is O(n²) in render. Build a `Map` or `Set` once, memoized.

### 6. State placement and render scope

- State lifted higher than its only consumer, so every change re-renders the whole subtree. Push it down, or extract the stateful leaf into its own component.
- A fast-changing value (input text, hover, scroll offset, mouse position, drag delta) held in a component that renders expensive children. Isolate it with a separate component, a ref plus a direct DOM write, or CSS.
- Expensive siblings that could be passed as `children` to the stateful wrapper. The _parent_ creates `children` elements, so they keep referential identity across the wrapper's state changes. Cheap, underused, and no `memo` needed.
- Deriving state in `useEffect` plus `setState` instead of computing in render, which costs an extra commit per change.
- Not using the updater form (`setX(x => x + 1)`) where it would remove a dep and stabilise a callback.
- `key` used on a component to force a reset when the reset could be a prop. Remount against update.
- Missing `startTransition` or `useDeferredValue` on a genuinely heavy filter-as-you-type. Only recommend it when the heavy work is proven, and say which work.

### 7. Work done in the render body

- Parsing, formatting, cloning, `JSON.parse`/`stringify`, crypto, `toLowerCase` over large text, DOM measurement, `getBoundingClientRect`.
- Constructing formatters, collators, or regexes per render. Hoist them to module scope if they don't depend on props.
- Creating a new i18n, date, or locale object per render.
- Logging or dev-only work that isn't gated.
- Reading `localStorage`, `sessionStorage`, or `document.cookie` in render, which is sync I/O in the render path.
- Anything that reads layout and then writes it in the same frame. That's layout thrash. Batch the reads, then the writes.

### 8. Effects, subscriptions, and the event loop

- A subscription re-created every render because its handler dep is unstable, causing unsubscribe and resubscribe churn. Wrap the handler in `useHandler`.
- `addEventListener` on `window` or `document` without `{ passive: true }` for scroll, touch, or wheel.
- Undebounced or unthrottled `resize`, `scroll`, or `mousemove` handlers that trigger `setState`.
- `ResizeObserver` or `IntersectionObserver` created per render or per item where one shared observer would do.
- A `setState` in an effect with no guard, where the new value often equals the old. React bails on identical primitives but not on fresh objects, so a fresh object gives you an endless render loop or steady wasted renders.
- Polling or interval callbacks that close over stale props, forcing a re-create per render.

### 9. Bundle and mount cost

- A heavy dependency newly imported at module scope in a route or entry that doesn't need it eagerly. Recommend dynamic `import()` or `React.lazy` at the right boundary.
- Barrel-file import (`import { x } from '../..'`) pulling a large graph where a deep import would not.
- A large static table, map, or config inlined in a component module rather than a module-scope constant or a lazy chunk.
- Icons and SVGs imported individually where the sprite is available.

### 10. Over-memoization (a tax in its own right)

Flag with the same seriousness as a missing memo:

- `memo` on a component that always receives a fresh object, array, or function prop, or `children`. The comparison always fails and you pay it for nothing.
- `memo` on a component that is cheap to render and rarely re-renders.
- `useCallback` on a handler passed only to a DOM element (`<button onClick>`). React doesn't compare DOM props for re-render purposes.
- `useMemo` returning a primitive computed from primitives.
- Nested `memo`, `useCallback`, and `useMemo` piled around a component whose real problem is that state lives too high. Name the restructure.
- A custom `areEqual` comparator doing a deep compare on a large object. The comparison is the cost now.

---

## False positives to avoid

Do not report these as costs. Mention them at most as `Hygiene`, and only if the file is otherwise a teaching opportunity:

- Inline arrow or object on a plain DOM element with no `memo` boundary anywhere downstream.
- A `useMemo` omitted on a genuinely O(1) expression.
- Object identity in a `useSelector` that returns a **primitive**. No equality problem exists.
- `key` by index on a static list that never appends and never reorders.
- Re-renders in a component that mounts once and renders on user navigation only.
- "Missing `memo`" on a component whose parent almost never re-renders. Check the parent before claiming.
- Anything the diff did not touch, unless the diff made it materially worse. If pre-existing context matters, say "pre-existing, surfaced by this change" and keep it out of the scorecard.

---

## Evidence the user can run

Offer these when a finding would benefit from proof, but don't block the report on them:

- React DevTools Profiler: record the interaction, then look at commit count and "Why did this render?" (requires _Record why each component rendered_).
- DevTools Profiler, highlight updates on render, to see which subtrees flash.
- `<Profiler>` with an `onRender` callback logging `actualDuration` around the suspect subtree.
- Performance panel trace over the real interaction, for long tasks, layout thrash, and style recalc counts.
- For selector churn, a temporary `console.count` in the component body, driven by an unrelated dispatch.

</supporting-info>
