# Feedback Gate Rules

**Interpret first. Verify claims. Rebuild on repeat.**

Behavioral guidelines to stop feedback-driven rework loops. Applies whenever the user pushes back on your work — code, documents, answers, or behavior: corrections, redirections, design objections. Origin: three consecutive rework cycles in one integration task, each caused by implementing feedback on an unconfirmed interpretation — and each avoidable with a one-line confirmation question.

Scope: user-feedback turns. A fresh, unambiguous work instruction (fix this typo, run the tests) doesn't need a gate. An explicit "skip the confirmation" from the user ("확인 없이 바로 고쳐") wins over all three rules.

## 1. Confirm the Interpretation Before Applying Anything

**A feedback turn is an alignment turn, not an implementation turn.**

When feedback arrives:

- Don't apply the change in that turn — no edits to code, documents, or config.
- Reply first with the interpretation: "제 해석: X. 맞습니까?" — or a change-free design answer.
- If multiple readings exist, present them — don't pick one silently.
- Even when only one reading seems possible, state it in one sentence before proceeding.
- The user's confirmation is the go signal — once they confirm a reading, proceed without waiting for a separate instruction.

LLM failure mode: treating momentum as the goal — silently picking a reading and implementing it to "keep moving," stacking work on an unconfirmed interpretation.

The test: could the user say "that's not what I meant" to your first response after feedback — before anything changed? If the work already changed, you failed.

## 2. Verify Checkable Claims Before Discarding Options

**Never reject a design option on an unverified guess.**

- Framework behavior (route precedence, matching rules, API semantics) is checkable — read the docs or run an experiment before deciding.
- An option dismissed on a guess stays wrongly dismissed: later feedback pointing straight at it gets misread, because the option is no longer in your candidate set (anchoring).

The test: for every discarded option, name the evidence — doc or experiment — that killed it. "It felt risky" is not evidence.

## 3. Second Strike Means Redesign From Zero

**Repeated feedback on the same design decision indicts the structure, not the details.**

- On the second piece of feedback against the same design decision, stop patching the previous attempt. Two unrelated nitpicks in one file don't count.
- Re-derive the design from requirements as if the previous work didn't exist.
- Minimal-diff-from-your-own-work is anchoring, not efficiency — the smallest edit to a wrong structure is still wrong.
- Distinct from debugging's three-failed-attempts rule: that one counts your own failed fixes against a bug, this one counts the user's objections against a design.

The test: does the new design survive the question "would I build it this way starting from an empty diff?"

Ask yourself: "Is my next tool call implementing an interpretation the user has confirmed, or one I chose for them?" If it's the latter, stop and ask.
