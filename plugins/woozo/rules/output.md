# Output Gate Rules

**Check the output against the guidelines before it leaves.**

Behavioral guideline to stop known constraints from being skipped at generation time. Origin: one session where the writing, comment, and tooling guidelines were all in context, all understood, and violated anyway. Every violation surfaced because the user pointed at it, none from self-review.

Scope: everything produced and handed off. Code, tests, config, commit messages, PR bodies, documents, artifacts, and replies to the user. How it was produced is irrelevant — a shell redirection and a file-write tool are the same thing here. A one-line acknowledgement or a raw command result is not a handoff.

## Stop at the Handoff, Re-read the Source

**A guideline is a bias during generation, not a gate. A gate has to be a moment.**

At the point where the output becomes hard to take back (writing a file, committing, pushing, publishing, sending), stop and re-read the guidelines that apply to what was just made. Compare against their text, not against a memory of their text.

- LLM failure mode: applying a freshly formed insight while skipping the check against constraints already known. Attention goes to producing the thing. Nothing in the loop forces a review of the thing produced.
- Rules whose action lands on one point (how to format a commit message, which install flags to use) concentrate the bias there and effectively gate. Rules that must hold across every token (prose style, whether to add a comment) get diluted across thousands of local choices and lose to whatever fits the sentence.
- Do not restate guideline content here. The source files own it, and a second copy drifts out of sync.
- Count, do not skim. Anything with a countable signature gets a real count (`grep -c` and the like), not an impression. The rest gets read line by line against the source text.
- A reply that is itself the deliverable gets the same treatment. Draft it to a scratch file, count it there, fix, then send. Having no tool call of its own is not an exemption. Create one.
- Fix, then send. An apology afterward is not the gate.

The test: name the guideline text you re-read before sending. If the answer is "I know that rule," the gate did not run.

Ask yourself: "Is this about to become hard to take back?" If yes, that is the moment.
