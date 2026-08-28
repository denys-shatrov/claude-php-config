---
paths:
  - "app/Models/**"
  - "app/Observers/**"
  - "app/Jobs/**"
  - "database/migrations/**"
  - "database/factories/**"
  - "database/seeders/**"
---

# Models, queries, migrations

## Model

- Declare `$fillable` (preferred) or `$guarded` explicitly, plus `$casts` —
  including dates, enums, `boolean`, `decimal`, and encrypted fields.
- A model holds relationships, casts, scopes, accessors. It does not hold HTTP
  logic, mail sending, or third-party API calls.
- Type relationship return values (`HasMany`, `BelongsTo`).
- Move heavy logic out of `booted()` into an Observer, otherwise it fires
  invisibly in seeders and tests.

## Queries

- **N+1 is a defect.** Any query whose relations are used afterwards gets
  `with()`. Mentally check every loop over a collection.
- A condition that appears twice becomes a scope with a descriptive name.
- Large result sets use `chunkById()` or `lazy()`, never `all()`.
- Aggregate in the database (`withCount`, `sum`), not in PHP over a loaded
  collection.
- Raw SQL only with bindings, and with a comment on why the builder was not
  enough.

## Transactions

Several related writes go inside `DB::transaction()`. Inside a transaction, do
not make HTTP calls and do not dispatch jobs directly: use
`dispatch()->afterCommit()` or an after-commit event.

## Migrations

- A migration that has already run is never edited. Write a new one.
- `down()` is filled in and reversible. If an operation cannot be reversed, say
  so explicitly.
- Foreign keys get indexes; so do columns used for lookup and sorting.
- Changing or dropping a column that holds data is a separate step with a
  migration plan, not a rider on an add-column migration.
- Seed data with seeders or a dedicated data migration, never mixed into a
  schema migration.

## Factories

Every model has a factory with sensible defaults and states (`->cancelled()`)
for the cases that matter. Tests use factories, not hand-built arrays.
