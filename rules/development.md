# Development Rules

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- If the design is complex, present it - don't decide silently.

## 2. Read Before You Write

**Understand surrounding code before adding to it.**

Before writing new code:

- Read the file's exports and immediate callers.
- Check shared utilities - don't reinvent what already exists.
- If you can't explain why code is structured a certain way, ask.

"Looks orthogonal" is the famous last words of an unintended regression.

## 3. SOLID: Structure What You Build

**YAGNI decides WHAT you build. SOLID decides HOW you structure it. Where they collide, SOLID wins.**

Where they collide - rule 4 (Simplicity First) would veto as speculative an abstraction a SOLID principle demands - SOLID wins. This is not a license for interface sprawl: every abstraction must name the SOLID failure it prevents; "might need it later" stays banned. Scope is the code you're already writing or changing - rule 6 still bars drive-by restructuring.

### S - Single Responsibility

- LLM failure mode: piling every new concern into the class or component already in context - the god-unit that fetches, computes, persists, and notifies in one 400-line block.
- One reason to change per unit - function, hook, class, or module. If describing it honestly requires "and", split it.

```tsx
// Bad: fetches AND transforms AND renders - three reasons to change
function UserDashboard() {
  const [users, setUsers] = useState<User[]>([]);
  useEffect(() => { fetch("/api/users").then(/* parse, sort, filter */); }, []);
  const csv = users.map(u => `${u.name},${u.email}`).join("\n");
  return <div>{/* table + filters + export button */}</div>;
}

// Good: data hook, pure transform, render-only component
function useUsers(): User[] { /* fetch + state */ }
function toCsv(users: User[]): string { /* pure */ }
function UserTable({ users }: { users: User[] }) { /* render only */ }
```

```kotlin
// Bad: validates AND computes tax AND persists AND emails - four reasons to change
class InvoiceService {
  fun issue(inv: Invoice) { /* field checks, tax math, SQL insert, SMTP send */ }
}

// Good: one reason to change each
class InvoiceValidator { fun validate(inv: Invoice) { /* field checks */ } }
class TaxCalculator { fun taxFor(inv: Invoice): Money { /* tax math */ } }
class InvoiceRepository { fun save(inv: Invoice) { /* SQL insert */ } }
class InvoiceMailer { fun send(inv: Invoice) { /* smtp */ } }
```

The test: describe the unit in one sentence without "and".

### O - Open/Closed

- LLM failure mode: one more flag, one more case - every new variant edits the same shared component and the same scattered switches.
- Extend by adding code - a new class, entry, or composed call site - not by editing working code. Unavoidable edits converge to one declarative registration point.
- A single exhaustive switch is fine - the smell is the same dispatch scattered across sites, or a default that swallows new cases. Props for the component's own bounded states (loading, disabled, variant) are fine too - the smell is a new flag per caller.

```tsx
// Bad: every new use case adds a flag - the shared component is edited each time
function Button({ label, isDanger, withIcon, iconPosition, asLink, isCompactInToolbar }: Props) {
  /* if-forest over six flags */
}

// Good: closed core - intrinsic states stay props, everything else composes at the call site
function Button({ variant, isLoading, children }: ButtonProps) { /* stable core */ }
<Button variant="danger"><Icon name="trash" /> Delete</Button>
<Button isLoading>Saving...</Button>
// variant dispatch? one registry - Record<Kind, FC> - where a missing key is a compile error
```

```kotlin
// Bad: string dispatch - a new shape fails only at runtime
fun area(s: Shape): Double = when (s.type) {
  "circle" -> PI * s.r * s.r
  "rect" -> s.w * s.h
  else -> throw IllegalArgumentException(s.type)
}

// Good: new shape = new class; a missing area() is a compile error
sealed interface Shape { fun area(): Double }
class Circle(val r: Double) : Shape { override fun area() = PI * r * r }
class Rect(val w: Double, val h: Double) : Shape { override fun area() = w * h }
```

### L - Liskov Substitution

- LLM failure mode: compiler-appeasing subtypes - an inherited member stubbed with a throw or no-op, or a wrapper that accepts the base type's props and silently drops some.
- A subtype must honor the base type's full contract - no strengthened preconditions, no weakened postconditions, no surprise throws or no-ops. If it can't honor the contract, it isn't that type.

```tsx
// Bad: typed as a button, but onClick/disabled never reach the DOM - not substitutable
function IconButton({ icon, children }: ButtonProps & { icon: IconName }) {
  return <button><Icon name={icon} />{children}</button>;
}

// Good: forward the whole contract - drops in anywhere a button is expected
function IconButton({ icon, children, ...rest }: ButtonProps & { icon: IconName }) {
  return <button {...rest}><Icon name={icon} />{children}</button>;
}
```

```kotlin
// Bad: implements Storage but refuses half the contract - crashes every generic caller
class ReadOnlyCache : Storage {
  override fun load(key: String): ByteArray? { /* disk read */ }
  override fun save(key: String, data: ByteArray) { throw UnsupportedOperationException("read-only") }
}

// Good: implement only the contract the type can honor
interface ReadableStorage { fun load(key: String): ByteArray? }
interface Storage : ReadableStorage { fun save(key: String, data: ByteArray) }
class ReadOnlyCache : ReadableStorage { override fun load(key: String): ByteArray? { /* disk read */ } }
```

The test: every caller of the base type works, unchanged, with the subtype.

### I - Interface Segregation

- LLM failure mode: typing a leaf against the widest object in scope - god-props, fat interfaces, mocks forced to stub methods they never use.
- Depend only on what you use. Contracts belong to consumers - define what the consumer needs; don't reuse the provider's widest type.

```tsx
// Bad: Avatar depends on the 40-field User but reads two fields - every User change ripples here
function Avatar({ user }: { user: User }) {
  return <img src={user.avatarUrl} alt={user.name} />;
}
// (Pick<User, "name" | "avatarUrl"> is a half-fix - still coupled to User's shape)

// Good: a different concern gets its own contract, defined by the consumer
interface AvatarProps { name: string; imageUrl: string; }
function Avatar({ name, imageUrl }: AvatarProps) {
  return <img src={imageUrl} alt={name} />;
}
// caller maps: <Avatar name={user.name} imageUrl={user.avatarUrl} />
```

```kotlin
// Bad: every implementation and test mock must stub all of it
interface UserService {
  fun login(c: Credentials): Session
  fun profile(id: Long): Profile
  fun bill(id: Long): Invoice
  fun notify(id: Long, msg: String)
}

// Good: role interfaces - each consumer depends only on its role
interface Authenticator { fun login(c: Credentials): Session }
interface ProfileReader { fun profile(id: Long): Profile }
```

### D - Dependency Inversion

- LLM failure mode: importing or constructing concrete infrastructure inline (axios, the DB client) - untestable without the real thing, unswappable without editing the caller.
- High-level policy defines the interface it needs; low-level detail implements it. Source dependencies point from infra to domain - never the reverse. A fake must be injectable in tests.

```tsx
// Bad: hard-wired to axios - no test without HTTP, no swap without editing the component
function UserList() {
  useEffect(() => { axios.get("/api/users").then(/* setState */); }, []);
  return <ul>{/* rows */}</ul>;
}

// Good: the component depends on a contract; wiring lives at the edge
interface UserApi { list(): Promise<User[]> }
function useUsers(api: UserApi): User[] { /* fetch via api.list() */ }
// app wires the real impl once (provider/context); tests inject a fake - no HTTP anywhere
```

```kotlin
// Bad: the service builds its own dependency - Postgres is now part of the domain
class OrderService {
  private val db = PostgresClient()
  fun place(order: Order) { /* db.insert(...) */ }
}

// Good: the domain owns the contract; infra implements it at the edge
interface OrderStore { fun save(order: Order) }  // lives in the domain package
class OrderService(private val store: OrderStore) { fun place(order: Order) { /* store.save */ } }
class PostgresOrderStore : OrderStore { /* infra edge */ }
```

Ask yourself: "Which principle demands this abstraction?" No answer means rule 4 applies - delete it.

## 4. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code - unless a SOLID principle demands one (rule 3).
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 5. Match the Codebase, Even If You Disagree

**Conformance over taste. Surface disagreements, don't fork silently.**

When working in an existing codebase:

- Match existing style, naming, and patterns.
- Don't introduce a "better" convention as a side effect.
- If a convention seems genuinely harmful, raise it - don't quietly do it your way.

The test: A reader can't tell which lines you wrote vs. the original author.

## 6. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 7. Surface Conflicts, Don't Average Them

**Pick one. Explain why. Flag the other for cleanup.**

When two patterns contradict:

- Pick the more recent or more tested. Don't blend.
- State why you picked it - don't choose silently.
- Flag the loser for cleanup. Don't "fix" it as a side effect.
- If you can't tell which is canonical, ask.

Two contradictory patterns merged into one usually breaks both.

## 8. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 9. Tests Verify Intent, Not Just Behavior

**A test should fail when intent breaks, not just when implementation changes.**

- Settle the public contract - signatures, input/output types, error behavior, invariants - before writing tests. A test written against a pictured implementation freezes an accidental shape.
- Encode the WHY, not just the WHAT.
- A test that can't fail when business logic changes is worthless.
- If a test mirrors implementation line-by-line, it's a copy, not a test.

Ask yourself: "If the requirement changed, would this test fail?" If no, rewrite it.

## 10. Fail Loud

**Surface skips, errors, and uncertainty - don't bury them.**

When reporting status:

- "Completed" is wrong if anything was skipped silently.
- "Tests pass" is wrong if any were skipped or stubbed.
- "Works" is wrong if you didn't actually run it.

Default to surfacing uncertainty. Loud failures are cheaper than silent ones.

## 11. Debug by Root Cause

**No fixes before the root cause is understood. Symptom patches are failures.**

When something breaks (bug, failing test, unexpected behavior):

- Read the full error and stack trace first. Reproduce reliably. Check what changed recently (git diff, deps, config). Can't reproduce → gather more evidence, don't guess.
- In multi-component paths, instrument the boundaries to locate WHICH layer fails before theorizing about why.
- Trace the bad value to its origin. Fix at the source, not where it surfaced.
- One explicit hypothesis at a time ("X causes this because Y"), tested with the smallest possible change. Never stack a second fix on an unverified first.
- Reproduce with a failing test before fixing (rule 8), then verify nothing else broke.
- After 3 failed fix attempts, stop - the problem is likely the design, not the spot. Present the pattern to the user instead of attempting fix #4.

Red flags meaning "return to investigation": "quick fix now, investigate later", "just try changing X", "it's probably X", bundling multiple changes into one attempt.
