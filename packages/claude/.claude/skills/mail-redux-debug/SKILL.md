---
name: mail-redux-debug
description: Guided debugging session for Redux bugs in the Proton Mail application. Covers elements store, optimistic update systems, context-aware counts, event-loop race conditions, and the re-fetch bug loop.
---

<what-to-do>

You are debugging a Redux bug in the Proton Mail application. Follow this process:

1. **Classify the bug** — ask the user to describe the symptom. Map it to one of the known bug categories below.
2. **Locate the fault** — use the architecture map to identify which slice, reducer, selector, or action is implicated.
3. **Form a hypothesis** — state one specific hypothesis about the root cause before reading any code.
4. **Verify** — read the relevant files to confirm or refute the hypothesis. Read only what is needed.
5. **Fix** — propose a minimal, targeted fix. Do not refactor beyond what the bug requires.
6. **Confirm invariants** — after fixing, state which invariants the fix must preserve (see Supporting Info).

For each step, show your reasoning before acting.

</what-to-do>

<supporting-info>

## Store location

The store is split across two locations:

**Package** (`packages/mail/store/`) — generic, reusable slices:
| Slice | Purpose |
|-------|---------|
| `counts/` | Canonical unread/total counts from the server, kept live via events and optimistic actions |
| `labels/` | Label and folder metadata |
| `mailSettings/` | User mail preferences |
| `messages/` | Message metadata cache |

**App** (`applications/mail/src/app/store/`) — mail-UI-specific slices:
| Slice | Purpose |
|-------|---------|
| `elements/` | Paginated list, context-aware totals, optimistic updates |
| `conversations/` | Conversation metadata + optimistic updates |
| `messages/` | Message state (read, draft, images, optimistic, scheduled) |
| `composers/` | Draft composition state |
| `attachments/` | Attachment metadata |
| `newsletterSubscriptions/` | Newsletter subscription metadata |

Key app-side files:
| File | Role |
|------|------|
| `elements/elementsSlice.ts` | State shape, reducer wiring |
| `elements/elementsReducers.ts` | All elements reducers (~1100 lines) |
| `elements/elementsActions.ts` | Optimistic actions |
| `elements/elementsSelectors.ts` | All selectors including `shouldLoadElements`, `dynamicTotal`, `contextTotal` |
| `elements/helpers/elementContextCount.ts` | `computeContextTotals`, `updateContextTotals` |
| `elements/helpers/elementTotal.ts` | `getTotal` — category-aware count with filter compensation |
| `conversations/conversationsSlice.ts` | Conversation state + optimistic |
| `messages/optimistic/` | Message-level optimistic label, mark-as, delete |
| `mailbox/mailboxActions.tsx` | Chunked backend ops, undo, event manager pause/resume |
| `hooks/mailbox/useElements.ts` | Main orchestration hook — complex, effect-heavy, main source of re-fetch bugs |
| `hooks/usePaging.ts` | Pagination — uses local state (`useState`) out of sync with Redux |

---

## Architecture: counts vs elements.total

These are **not connected** and can drift. Neither reconciles the other.

|             | `counts` slice (package)                                              | `elements.total` (app)                                                        |
| ----------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Source      | Separate API fetch; kept live via event loop + optimistic actions     | Set from API response when fetching a context (`Total` field)                 |
| Scope       | All label totals (unread + total)                                     | One entry per context identifier (labelID + filter + sort + categories + ...) |
| Use         | Badge counts, sidebar; `dynamicTotal` selector bridges it to the list | Drives `shouldLoadElements` gap detection and pagination                      |
| Updates     | Events + optimistic actions keep it current                           | Only updated via delta mechanism after optimistic actions or event loop       |
| Known issue | Drift between the two is not handled                                  | New elements from server events only update if already in store               |

**`dynamicTotal` selector** (L341–362 in `elementsSelectors.ts`) is the bridge: it reads from `counts` for display, falling back to `elements.total`. It is **not used consistently** — some reducers read `total` directly, so unifying them is non-trivial.

**Long-term plan**: remove `elements.total` entirely; have the backend return attachment counts so everything centralizes into the `counts` slice. Store consolidation into one package planned for 2026.

---

## Architecture: data duplication

Three slices hold overlapping data — this is a known problem:

- **`elements` slice** — holds conversations (each with an embedded message list) and messages.
- **`conversations` slice** — holds conversations again, each with an embedded message list.
- **`messages` slice** — holds messages only. This slice is "clean."

Any action that mutates label state or read/unread state must update **all three** consistently. Bugs appear when one slice is missed. Long-term goal: remove the elements slice; conversations keep only a list of message IDs as references.

---

## The re-fetch bug loop (most common bug pattern)

```
optimistic action dispatched
    → context total updated incorrectly (delta wrong or missed)
    → shouldLoadElements sees a gap (page looks incomplete)
    → API fetch triggered
    → stale server data arrives
    → overwrites optimistic state
    → element reappears / count resets
```

**`shouldLoadElements`** (L267–280 in `elementsSelectors.ts`) is a gap detector. It fires when the currently visible page cannot be filled from the cache. For example: deleting an element on page 2 when there is no page 3 in cache creates a gap that triggers a fetch. A wrong context total after an optimistic action is the most common way to open this door.

---

## Context identifier

A context is uniquely identified by a JSON-stringified object:

```typescript
{
    labelID: string;
    categoryIDs: CategoryLabelID[];   // Only set when labelID === INBOX; [] elsewhere
    conversationMode: boolean;
    filter?: Filter;                  // e.g. { Unread: 1 }
    sort?: Sort;                      // { sort: 'Time', desc: true }
    from?: string;
    to?: string;
    address?: string;
    begin?: number;
    end?: number;
    keyword?: string;
    newsletterSubscriptionID?: string; // Excluded when searching
}
```

Same view parameters → same key, always. A key mismatch means counts are read from the wrong bucket.

Note: sort is part of the context identifier, but it does not change which elements are present — only their order. Context totals should only differ across dimensions that change element membership (location, filter, category). Storing sort variants is over-specified and a known inefficiency.

---

## Context total: delta mechanism

**Why all contexts at once**: one element can be in multiple contexts simultaneously (e.g., a message in Inbox is in both the "all" context and the "unread filter" context). Moving it must decrement every matching context in one pass.

**Pattern** (used in `elementsReducers.ts` after every optimistic action):

```typescript
const countsBeforeAction = computeContextTotals(state);
// apply state mutation
const countsAfterAction = computeContextTotals(state);
updateContextTotals({ state, countsBeforeAction, countsAfterAction });
// result: state.total[ctx] = state.total[ctx] - (before[ctx] - after[ctx])
```

**Known limitation**: `computeContextTotals` only counts elements already in `state.elements`. Elements not yet in the store (e.g., new arrivals via server event) are invisible to the delta — causing drift.

---

## Category view

Categories are only relevant when `labelID === INBOX`. `categoryIDs` is `[]` for all other labels.

**To appear in a category context, an element must have BOTH**:

1. The Inbox label
2. At least one of the `categoryIDs`

The filter in `filterElementsInState`:

```typescript
if (labelID === MAILBOX_LABEL_IDS.INBOX && categoryIDs.length > 0) {
    if (!categoryIDs.some((id) => labelIDsSet.has(id))) return false;
}
```

**Categories are never stripped from elements.** An element moved out of Inbox keeps its category label. When moved back, it reappears in the correct tab without a server round-trip.

**Primary tab (ID 24)** — `categoryIDs = [24, ...selectDisabledCategoriesIDs]`.

- `selectDisabledCategoriesIDs` comes from the `labels` slice.
- `aggregateCategoryCounts` sums across all those IDs so disabled-category elements appear under Primary.

---

## Conversation mode

`conversationMode: boolean` is part of the context identifier. Inbox with conversations on and Inbox with conversations off are two separate contexts with independent totals and page caches.

**1-n constraint**: there is a 1-to-many relationship between a Conversation and its Messages. Any action that affects the whole conversation (mark-as-read, label change) can only be partially predicted when you only have a Message. The code does best-effort optimistic updates + POST/GET to reconcile, but cannot guarantee full accuracy.

**bypassFilter in conversation mode**: when marking a message as unread while in conversation mode with an unread filter active, the conversation ID (not the message ID) is added to `bypassFilter` — keeping the whole conversation visible.

---

## bypassFilter

Purpose: keep elements visible after an action that would cause them to drop out of the current filter (e.g., reading a message while the unread filter is on).

- **Does not affect the count.** The total is frozen; it is only recalculated when the filter is toggled off and back on.
- Elements stay in `bypassFilter` until the filter is removed/changed. There is no per-element timeout.
- In conversation mode, the bypass key is `ConversationID`. In message mode, it is `element.ID`.

---

## Known bug categories

### 1. Element reappears after delete or move

**Cause**: the re-fetch bug loop (see above). The context total is wrong after the optimistic action, `shouldLoadElements` triggers a fetch, stale server data overwrites the optimistic state.

**Checklist**:

1. Identify which optimistic action was dispatched (`optimisticDelete`, `optimisticApplyLabels`, etc.).
2. Check `elementsReducers.ts`: does the reducer call `computeContextTotals` before and after, then `updateContextTotals`? Is the delta correct?
3. Check that the action updates all three slices: `elements`, `conversations`, `messages`.
4. Check `pendingActions`: is it incremented before and decremented after (including error paths)?
5. If `pendingActions` is positive, `shouldLoadElements` is suppressed — a leak here can also hide the symptom temporarily.

---

### 2. Wrong badge count or context total

**Cause**: context identifier mismatch, delta computed on wrong slice of state, or drift between `counts` and `elements.total`.

**Checklist**:

1. Log `selectCurrentContextIdentifier` — compare the key before and after the action.
2. Check `computeContextTotals`: does `filterElementsInState` receive the correct `labelID`, `categoryIDs`, and `filter`?
3. Check `getTotal` in `elementTotal.ts`: does it aggregate category counts correctly for Primary tab? Does it apply filter compensation?
4. For badge count specifically: check `dynamicTotal` — it reads from `counts`, not `elements.total`. If `counts` is stale, look at the event loop update path.

---

### 3. Wrong count on Primary category tab

**Cause**: `aggregateCategoryCounts` not receiving the correct `categoryIDs`, or `selectDisabledCategoriesIDs` returning a stale list.

**Checklist**:

1. Verify `categoryIDs` in the context identifier includes both `24` and all disabled category IDs.
2. Verify `selectDisabledCategoriesIDs` (from `labels` slice) returns the current disabled set.
3. Check `aggregateCategoryCounts` in `elementTotal.ts`: it must sum `isCategoryLabel` entries that match `categoryIDs`.

---

### 4. Stale list / list not refreshing

**Cause**: `pendingActions` counter stuck above zero, or `taskRunning` flag not cleared.

**Checklist**:

1. Find the action in `mailboxActions.tsx` — confirm there is a `try/finally` or `.finally()` that always decrements `pendingActions`.
2. Check `taskRunning` timeout — if it fires before the backend responds, the next poll may over-refresh.

**Invariant**: every `pendingActions++` must have a guaranteed `pendingActions--`, even on error paths.

---

### 5. Event-loop race: element reappears only under slow network

**Cause**: the event manager delivers server state while an optimistic update is still in flight; the event handler overwrites the optimistic state, then the backend confirmation arrives as a no-op.

**Checklist**:

1. In `mailboxActions.tsx`: find `stopEventManager` / `resumeEventManager` calls — confirm they bracket **all chunks**, not just the first.
2. Check that no early-return or abort path skips `resumeEventManager`.

**Invariant**: event manager pause/resume is always symmetric, including on error paths.

---

### 6. Pagination shows wrong page count or jumps

**Cause**: `usePaging.ts` uses local `useState` for `total` and `page`, synced via a `useEffect`. The effect runs a tick after the Redux state changes, causing a transient mismatch.

**Checklist**:

1. Check whether the component re-renders with stale `currentTotalPages` before the effect fires.
2. Check `dynamicTotal` — the value passed to `usePaging` as `currentTotalPages`. If it reads from `counts` and `counts` is stale, the local state will lag by two ticks.

---

## Invariants to preserve in any fix

- `pendingActions` is always non-negative; never decrement below zero.
- Context identifier is deterministic: same view parameters → same key.
- Every optimistic action must update all three slices consistently: `elements`, `conversations`, `messages`.
- `computeContextTotals` → mutate state → `computeContextTotals` → `updateContextTotals`: this sequence must not be split.
- Event manager pause/resume is always symmetric, even on error paths.
- Category labels are never stripped from elements.
- `bypassFilter` uses `ConversationID` in conversation mode, `element.ID` in message mode.

</supporting-info>
