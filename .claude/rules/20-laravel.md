---
paths:
  - "app/**"
  - "routes/**"
  - "config/**"
  - "bootstrap/**"
  - "artisan"
---

# Laravel

## Getting your bearings

- Framework, PHP, and driver versions: `php artisan about`. Do not guess from
  memory.
- Routes: `php artisan route:list`. Do not infer a route from a controller name.
- Create files with `php artisan make:*` rather than by hand, so the namespace,
  location, and stub match the installed version.

## Layout

Group by domain **inside** the framework's own directories:
`app/Actions/Billing/`, `app/Http/Controllers/Billing/`, `app/Models/Billing/`.

Do not invent `app/Modules/` or a parallel `src/` hierarchy. It breaks
`artisan make:*`, the default autoload map, and every Laravel developer's
expectations.

## Framework primitive first, pattern second

Laravel already implements most of the classic patterns. Before writing your own
layer, check for the built-in one:

| Need | Built-in |
|---|---|
| React to something happening, side effects | Events + Listeners |
| Chain of request processing | Middleware |
| Object construction, dependency wiring | Service Container |
| Deferred work | Queued Job |
| Sequential transformation of a value | Pipeline |
| Reusable query condition | Eloquent scope |

A hand-rolled event dispatcher, DI container, or Eloquent wrapper is a sign the
design has gone wrong.

## Configuration

- `env()` is called only inside `config/` files. Everywhere else use `config()`,
  or config caching in production will silently return null.
- A new setting goes into `config/*.php` with a default and is added to
  `.env.example`.

## Slow and side-effecting work

- Anything slower than a couple hundred milliseconds — mail, third-party APIs,
  file generation, image processing — belongs on a queue, not in the request
  cycle.
- Side effects after a successful operation go through events, so the main path
  does not accumulate dependencies.
- Scheduling lives in `routes/console.php` or `bootstrap/app.php` depending on
  the version; check how this project does it.
