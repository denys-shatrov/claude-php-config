---
paths:
  - "app/Http/**"
  - "app/Actions/**"
  - "app/Policies/**"
  - "app/Data/**"
  - "app/DTO/**"
  - "routes/**"
---

# HTTP layer and business logic

## Flow

```
Route -> Controller -> FormRequest -> Action -> Eloquent
                            \-> Policy        \-> Resource (response)
```

## Controller

Orchestration only: take validated input, call an Action, return a response.
Aim for under ~20 lines per method.

A controller must not contain: validation rules, queries more involved than
`Model::find()`, calculations, mail sending, file handling, or `try/catch`
around business logic.

Prefer resource controllers, and single-action (`__invoke`) controllers where
there is one action. Inject dependencies via the constructor or method
signature.

## Validation and authorisation

- Rules live in a `FormRequest`, including input normalisation in
  `prepareForValidation()`. Inline `$request->validate()` is acceptable only for
  one or two trivial fields.
- Permission checks live in a Policy, invoked through `authorize()`. Do not
  write `if ($user->role === 'admin')` in a controller.
- Never pass `$request->all()` down the chain; pass `$request->validated()`.

## Action

- One class, one business operation. One public method, `handle()`.
- Name it as an imperative verb: `CreateInvoice`, `CancelSubscription`.
- An Action knows nothing about HTTP: it does not take a `Request`, return a
  `Response`, or call `redirect()` / `abort()`. Signal failure with domain
  exceptions.
- Multi-step writes are wrapped in a transaction inside the Action.
- An Action may call another Action.

**When an Action is not needed:** the operation fits in ~10 lines and is called
from one place. Leave it in the controller until a second caller appears. Do not
create a class for the sake of structure.

## DTO

Introduce one when an Action takes more than two related values, or when data
crosses a layer boundary. Immutable, typed properties, named constructor
(`fromRequest`). Below that threshold, plain arguments are better.

## Responses

- APIs return data through a Resource, not `->toArray()` on the model: a model
  must not define the public API contract.
- Use meaningful status codes: 201 on create, 204 on delete, 422 on validation.
- Keep one error response shape across the whole application.

## Never

- Repository classes on top of Eloquent — Eloquent already is that layer.
- `*Manager` / `*Helper` classes used as a dumping ground for unrelated methods.
- Business logic in middleware, in route files, or in a model constructor.
