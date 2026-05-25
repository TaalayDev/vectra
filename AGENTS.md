# Agent Coding Rules

Rules for AI agents working in this codebase. Follow them unconditionally.

---

## General

- Write code that is obvious to read, not clever.
- Do not over-engineer. Solve the problem at hand, not imagined future problems.
- Delete dead code instead of commenting it out.
- Prefer immutability. Use `final` and `const` wherever possible.
- Never leave `TODO`, `FIXME`, or `HACK` comments — fix it now or open a tracked issue.

---

## Comments

- Write no comments by default.
- Only add a comment when the **why** is non-obvious: a subtle invariant, a non-obvious workaround, a hidden constraint, or behavior that would surprise a reader.
- Never describe what the code does — well-named identifiers already do that.
- Never reference the current task, ticket, or PR in a comment.
- No multi-line comment blocks. One short line max.

Bad:
```dart
// Increment counter by 1
counter++;

// Added for ticket VEC-42
void _handleTap() { ... }
```

Good:
```dart
// Flutter layout requires a non-zero size here or hit testing silently breaks
SizedBox(width: 1, height: 1, child: ...),
```

---

## Shared Widgets and Logic

- **Before creating any widget or utility, search the codebase for an existing one that does the same or similar thing.** Check `lib/widgets/`, `lib/shared/`, and `lib/ui/` first.
- If you find a widget that is close but not quite right, extend or parameterize it — do not duplicate it.
- If the same widget structure or logic appears (or will appear) in two or more places, extract it to a shared location immediately. Do not wait for a third use.
- Shared widgets live in `lib/widgets/` (or `lib/shared/widgets/`). Shared logic, helpers, and utilities live in `lib/utils/` or `lib/shared/`.
- When extracting a shared widget, make it general enough for its known uses — not more. Do not prematurely generalize for hypothetical future callers.
- Name shared widgets clearly so they are discoverable: `IconButton`, `SectionHeader`, `EmptyState`, `LoadingOverlay` — not `MyButton`, `CustomHeader`, `Widget1`.
- When in doubt whether something belongs in shared, ask: "would another screen or feature naturally reach for this?" If yes, share it.

---

## Flutter Widgets

- **Prefer class widgets over inline widgets.** Extract any widget with meaningful state, size, or logic into its own `StatelessWidget` or `StatefulWidget`.
- Use `const` constructors everywhere they are allowed.
- Keep `build()` methods short. If it scrolls more than one screen, extract parts into private widget classes.
- Do not nest callbacks and builders more than two levels deep — extract them.
- Name widgets by what they **are**, not what they **do** (`LayerTile`, not `BuildLayerRow`).

Bad:
```dart
// Inline anonymous widget tree buried in build()
Column(
  children: [
    GestureDetector(
      onTap: () { ... },
      child: Container(
        decoration: BoxDecoration(...),
        child: Row(
          children: [
            Icon(...),
            Text(label),
          ],
        ),
      ),
    ),
  ],
)
```

Good:
```dart
Column(
  children: [
    _LayerItem(label: label, onTap: _handleTap),
  ],
)

class _LayerItem extends StatelessWidget {
  const _LayerItem({required this.label, required this.onTap});
  ...
}
```

---

## Naming

- Classes: `UpperCamelCase`.
- Variables, methods, parameters: `lowerCamelCase`.
- Constants: `lowerCamelCase` (Dart convention, not `SCREAMING_SNAKE`).
- Private members: prefix with `_`.
- Boolean variables and methods: use `is`, `has`, `can`, `should` prefixes.
- Avoid abbreviations unless universally understood (`ctx`, `id`, `url` are fine; `mgr`, `proc`, `btn` are not).

---

## Architecture

- Keep business logic out of widgets. Widgets render state; they do not compute it.
- One responsibility per class. If a class name contains "And", split it.
- Depend on abstractions, not concrete implementations, when the dependency is likely to change.
- Avoid god objects. A class that knows about everything is a bug waiting to happen.
- Keep layers separate: UI → State/ViewModel → Domain → Data. Do not skip layers or reach across them.
- Do not put API calls or file I/O inside widget `build()` methods or `initState()` without delegation to a service/provider.

---

## State Management

- Lift state only as high as it needs to go — no higher.
- Derive values instead of duplicating them across state objects.
- Do not store state that can be computed from other state.
- Side effects (network, file, navigation) belong in controllers or services, not in widgets.

---

## Error Handling

- Only validate at system boundaries (user input, external APIs, file I/O).
- Do not add try/catch around code that cannot throw.
- Propagate errors to where they can be meaningfully handled. Do not silently swallow exceptions.
- Use typed exceptions or result types for expected failure paths, not generic `catch (e)`.

---

## Functions and Methods

- A function does one thing. If it needs a comment to explain its sections, split it.
- Keep functions short. Aim for under 30 lines; treat over 50 as a code smell.
- Avoid boolean parameters that toggle behavior — split into two named methods instead.
- Return early to reduce nesting. Avoid deeply nested `if/else` chains.

Bad:
```dart
void process(bool isNew) {
  if (isNew) {
    // new path
  } else {
    // existing path
  }
}
```

Good:
```dart
void processNew() { ... }
void processExisting() { ... }
```

---

## Files and Structure

- One primary public class per file.
- File name matches the class name in `snake_case`.
- Group related files by feature, not by type.
- Do not create barrel `index.dart` files unless the package surface genuinely needs it.

---

## Do Not

- Do not add feature flags or backwards-compatibility shims when you can just change the code.
- Do not introduce abstractions for a single use case.
- Do not add error handling for scenarios that cannot happen.
- Do not write code "just in case" — write code for what is actually needed.
- Do not add logging unless it serves a clear operational purpose.
- Do not use `dynamic` unless interacting with truly untyped external data.
