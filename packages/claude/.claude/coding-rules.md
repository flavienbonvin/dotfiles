# Coding rules

Personal engineering principles to follow when writing code.

_Last updated: 2026-05-29_

1. When needing an object in tests, we should always use the whole object. Never use partial objects, as they only test today's code and don't protect against tomorrow's changes. The generator should support the creation of data for tests and update the object definition.

2. Never use union types for tier one objects. This always backfires and results in TypeScript errors because updating one object breaks the type inference in the codebase. Tier one objects (objects shared between API and clients) should never be mixed.

3. When using effects must express the real data dependency. We should not compute data in the effect, this should be done outside and used in the dependencies array. Being explicit in the dependencies array makes the code easier to understand.

4. Data that flows from an API request to storage to a subsequent API request must be kept in sync with the server value. Overriding this value with another value in the flow should result in a different API request. If the request remains the same, so does the data. Failing to do so will result in bugs.

5. Never spread props; each prop is defined when instantiating a component. This also applies to tests. Wanting to spread props for efficiency is a sign that the components need to be refactored. Spreading the props doesn't solve the problem; it hides it.

6. Keep the style simple; very few components need multiple lines of classes. This is also true for responsive classes. Too many styles make updates more difficult and make components fragile to changes.

7. Data flows down; shallow UI-event callbacks can flow up. A callback should signal that an event happened on a child component. It should never carry data or business logic. Callbacks make the code's mental model and debugging harder than necessary. Redux reducers, React Context, and JavaScript helpers are all tools to prevent this. If the callback cannot be avoided, it's because of poor application design, not a special case.

8. Never, duplicate or nest data, it must be stored in a central normalized store with a separate array for ordering. A single-keyed source makes all data-related operations easier, safer and faster. This completely removes the risk of drifting out of sync with the backend. Denormalize at the edge, not in storage.
