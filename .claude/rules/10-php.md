---
paths:
  - "**/*.php"
---

# PHP

## Types and strictness

- New files get `declare(strict_types=1)` if that is the project convention
  (check a couple of existing files; do not introduce it alone in legacy code).
- Type your parameters, return values, and properties. Use `mixed` only when the
  type genuinely is open, not as a way to avoid deciding.
- Return a union type or throw instead of using magic values. `false` or `null`
  as an error signal is acceptable only if the surrounding code works that way.

## Style

- PSR-12 for formatting, PSR-4 for autoloading. One class per file.
- Prefer early `return` over nested `if`. More than three levels of nesting is a
  signal to extract a method.
- Naming: classes `PascalCase`, methods and variables `camelCase`, constants
  `UPPER_SNAKE`. A name states purpose, not type (`$users`, not `$arr`).
- Comments explain *why*, not *what*. Do not write a docblock that restates the
  signature; write one when it adds meaning: units, invariants, the reason
  behind a non-obvious decision.

## Language features follow the project's version

Constructor promotion, `readonly`, enums, `match`, named arguments, first-class
callables: use them if `composer.json` allows the corresponding version. Do not
raise the project's PHP requirement for syntactic sugar.

## Never

- Error suppression with `@`.
- `eval`, `extract`, variable variables, `global`.
- Mutable global state, or static properties used as data storage.
- Empty `catch`. If you catch it, handle it, log it, or rethrow it.

## Threshold for abstraction

- An abstraction appears on the **second** use, not the first.
- An interface is created when a second implementation exists, not "for later".
- Dependencies come through the constructor. No `new` and no service locator
  inside a method.
- Inheritance only for a genuine is-a hierarchy. Reuse code by composition or a
  trait.
- A class should change for one reason; a method takes exactly what it uses.

The full "which situation calls for which pattern" catalogue lives in the
`php-patterns` skill. Do not apply a pattern until you have named the problem it
solves here.
