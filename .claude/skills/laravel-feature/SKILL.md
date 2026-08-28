---
name: laravel-feature
description: End-to-end recipe for adding functionality to Laravel in the right order - migration, model, factory, validation, Action, controller, route, resource, tests. Use for a new feature, CRUD, or endpoint request.
---

# New functionality in Laravel

The order matters: each step builds on the previous one, and each has a
checkpoint. Do not skip ahead intending to "finish it later".

## 0. Agree on the boundaries

Before creating files, state in two or three lines: what the operation is, who
is allowed to perform it, and what happens when it fails. Find a comparable
existing feature and mirror how it is built — consistency beats your
preferences.

If anything ambiguous affects the database schema or an API contract, ask now,
not after the implementation.

## 1. Data

```
php artisan make:migration create_x_table
```
Precise types, deliberate `nullable`, foreign keys with indexes, `down()` filled
in.

```
php artisan make:model X -f
```
`$fillable`, `$casts`, relationships with typed returns. Factory with sensible
defaults and states for the variants that matter.

**Checkpoint:** `php artisan migrate` runs, and rollback works.

## 2. Input

```
php artisan make:request StoreXRequest
```
Validation rules, `authorize()`, normalisation in `prepareForValidation()`.
Error messages in the same style as neighbouring requests.

```
php artisan make:policy XPolicy --model=X
```
Permission on the specific object, not just on a role.

## 3. Logic

An Action in `app/Actions/<Domain>/`: one public `handle()`, typed arguments or
a DTO, returning a result or throwing a domain exception. It knows nothing about
HTTP. Multi-step writes go in a transaction.

**If the operation fits in ~10 lines and has one caller, skip the Action** and
write it in the controller. Do not create a class for the sake of structure.

## 4. Entry point

```
php artisan make:controller XController --resource
```
Orchestration only: `authorize()`, `$request->validated()`, call the Action,
return the response.

Add the route to `routes/web.php` or `api.php` next to its relatives, with the
middleware and naming scheme the project already uses.

For APIs, `php artisan make:resource XResource`: the model must not define the
response contract.

**Checkpoint:** `php artisan route:list --path=x` shows what you expect.

## 5. Tests

Feature test: happy path, rejection for an unauthenticated user, rejection for
another user's object, validation failure. Unit test for the Action if it
branches.

Assert substance: status code plus `assertDatabaseHas` or the response body.

## 6. Finishing

- `vendor/bin/pint --dirty`
- the affected tests, then the full suite
- run `/ship` before committing

In your report, list the files created, what is covered by tests, and what was
left out of scope (UI, permissions for other roles, and so on).
