---
name: php-patterns
description: Design decision catalogue for PHP and Laravel - which situation calls for which pattern, where plain code is enough, and which constructs count as anti-patterns. Load when designing new functionality or refactoring, not during routine edits.
---

# Patterns: from situation to solution

Read the anti-patterns section first. Most of the time the right answer is to
add no abstraction at all.

**Entry rule:** before applying a pattern, name the problem it solves **here**.
"Cleaner" and "we might need it later" are not problems.

**Rule of two:** an abstraction appears on the second use. An interface appears
on the second implementation.

## Framework primitive first

Laravel already implements most classic patterns. Rolling your own is almost
always a mistake.

| Need | Built-in | Do not write |
|---|---|---|
| React to a fact, side effects | Events + Listeners | your own event dispatcher |
| Chain of request processing | Middleware | your own chain of responsibility |
| Object construction, wiring | Service Container | your own factory registry |
| Deferred work | Queued Job | your own worker daemon |
| Sequential transformation | Pipeline | a hand-chained sequence |
| Recurring query condition | Eloquent scope | a Repository method |
| Data access | Eloquent | a Repository over Eloquent |
| Extending a framework class | Macro | inheriting from the framework |

## Situation → solution

**Three or more branches on a type or mode, each with its own logic, and the set
keeps growing** → Strategy: an interface, one implementation per variant,
selection through the container or a `match`. While there are two branches of
three lines each, leave the `match`.

**An operation must trigger side effects that do not affect its success**
(mail, webhook, statistics recalculation) → Event + queued Listener. The main
path should not know its subscribers.

**Many steps, any of which can abort the operation** → a sequence of guards in
an Action with early throws. If the steps are reused across scenarios, a
Pipeline.

**Constructing an object takes more than four parameters, or some are optional**
→ a DTO with a named constructor. A Builder only if construction happens in
stages, in different places.

**One external service, but tests need a fake** → interface, implementation,
fake, bound in the container. A single implementation with no need for
substitution does not need an interface.

**Different shapes of the same response** (API, export, mail) → a separate
Resource/Transformer per shape, not flags inside one method.

**Behaviour depends on entity state and transitions are constrained** → a state
enum plus an explicit table of allowed transitions. A full State pattern with
classes only when each state has its own behaviour, not just its own name.

**The same code across several models** → a trait with one narrow responsibility
and a clear name. A trait that reaches into the host class's properties and
demands knowledge from it is hidden inheritance; do not do that.

**An expensive computation repeated within one request** → memoise in a
property. Across requests → a cache with an explicit key and an invalidation
strategy. A cache without a thought-through invalidation creates a bug, not a
speed-up.

## Anti-patterns

- **Repository over Eloquent.** Eloquent already is that layer. The wrapper adds
  files and takes away the builder. Reusable queries belong in scopes or a
  dedicated query class.
- **God controller, and `*Manager` / `*Helper` / `*Service` as a dumping
  ground.** A class with no clear responsibility grows forever. The name should
  state the operation.
- **An interface with one implementation "for later".** It adds indirection and
  gives nothing. Introduce it when the second one arrives.
- **Service locator:** `app(Foo::class)` inside a method. It hides dependencies
  and breaks testability. Inject through the constructor.
- **Static facades in domain logic.** An Action calling `Auth::user()` depends on
  the HTTP context and tests badly. Pass it as an argument.
- **Inheritance for reuse.** A `BaseService` that everything extends couples
  unrelated things. Use composition.
- **Logic in a model beyond its data.** A model that sends mail and calls APIs
  cannot be tested and fires inside seeders.
- **Premature event-driven architecture.** When everything goes through events,
  no one can follow a scenario. Events are for side effects, not for the main
  flow.
