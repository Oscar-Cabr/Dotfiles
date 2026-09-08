---
name: fractal-cock
description: Dual-lens judgment on a plan or code change — one reviewer audits the spec (does it solve the right problem, are requirements complete and testable, are alternatives weighed) and a second audits quality (scalability, bugs, error handling, reliability, performance, concurrency, resource management, test gaps) — then returns a single ACCEPTED, WARNING, or FAIL verdict with a deduplicated concern list. Use on "fractal cock", "verdict on this", "judge this plan", "give me a go / no-go", a dual spec-and-quality review, or a blocker / scalability / bug audit on a plan or diff. Do NOT use for a routine single-lens code review — use fractal-inspector for that. Read-only: it does not edit, run code, or commit.
---

# Fractal Cock

A two-reviewer judgment on a plan or implementation. One reviewer judges whether the work solves the right problem; the other judges whether the work is well built. The synthesis produces a single go / conditional-go / no-go verdict.

Read-only. It does not edit files, run code, or commit. The output is a verdict and a list of concerns for the human or a follow-up agent to act on.

_(Ported from a personal Pi skill, "the cock of justice"; same behavior, carried into the fractal-* family.)_

## When to fire

Trigger on: "fractal cock", "fractal verdict", "verdict on this diff/plan", "judge this plan", "give me the verdict", "go / no-go on this"; a plan or diff needs a hard go / conditional-go / no-go before further work; the user asks for blockers, scalability issues, bugs, or other errors to be surfaced; the user wants a spec review AND a quality review in a single pass.

Do not fire when a routine single-lens review is enough (`fractal-inspector`), the user only wants security review (`fractal-sentinel`), the user only wants documentation (`fractal-scribe`), or the work is to write code rather than judge it (`fractal-slave` / `fractal-architect`).

## Reviewers

Spawn exactly two reviewers **in parallel, from the main session**, in a single turn (a skill running inside a subagent cannot fan out; the main session issues both `Task` calls together). Use `fractal-inspector` as the chassis for both — override its prompt in each call so it knows which lens it is wearing. If `fractal-inspector` is unavailable, fall back to two `Explore` or generic agents with the same role override.

### Roles

**Spec reviewer** — wears the spec lens:

- Does this solve the actual problem the user described, or just its surface?
- Are the requirements complete, testable, and unambiguous? Anything left implicit that should be explicit?
- Is the scope correct — too narrow (misses a real edge case), too wide (solves problems nobody asked for), or right?
- Are the assumptions stated and reasonable?
- Were at least two approaches considered? Was the rejected one recorded with a reason?
- Has the plan drifted from the user's stated intent toward the implementer's preference?
- If this is a code change, does it do what was asked and only what was asked?

**Quality reviewer** — wears the quality lens: correctness (logic errors, off-by-one, null handling, contract mismatches); scalability (complexity, N+1, unbounded growth, missing pagination); reliability (uncaught exceptions, swallowed errors, missing timeouts, retry storms, partial-failure cleanup, idempotency, transaction boundaries); performance (blocking I/O on async paths, hot-path allocations, missing indexes, deep call chains); concurrency (shared mutable state, lock ordering, TOCTOU, races); resource management (leaks, unbounded caches); API and contract design (breaking changes, status codes, error shape, undocumented side effects); observability (structured logs, correlation IDs, failure-mode metrics); test coverage (gaps for the changed behavior, untested error paths); maintainability (dead code, duplication, magic numbers, complexity hotspots, comment accuracy); security only where it intersects shipping (input validation, secret handling, dependency hygiene) — not a full audit.

The quality reviewer is NOT doing a full security audit. If the user wants that, run `fractal-sentinel` separately after this skill returns.

## Spawning

Both `Task` calls in the same turn. Each brief is self-contained: the change or plan being reviewed; the files in scope (paths); the role (spec or quality); the severity scheme `blocker | critical | major | minor | nit`; the instruction to use the output format below. Do not give either reviewer context that depends on the other.

### Reviewer output format

```
# <Spec | Quality> review: <scope>

## Summary
<2-4 sentences: what was reviewed, overall assessment, severity counts>

## Findings
For each finding, ordered by severity (blocker first):
- **[severity] file_path:line — title**
  Category: <which spec / quality sub-category above>
  What: <the defect in one sentence>
  Why it matters: <concrete user or system impact>
  Suggested fix: <specific change, not a vague hint>

Severity: blocker | critical | major | minor | nit
```

Omit a category with no findings. Do not pad.

## Synthesis

1. **Collect findings.** Keep each reviewer's original severity, category, and citation.
2. **Deduplicate.** If both flagged the same issue from different angles, merge into one finding and cite both lenses.
3. **Apply the verdict rubric.** This is the only place severity drives a verdict.
4. **Write the output** in the exact format below.

Do not paper over conflicts. If spec and quality disagree on whether an issue is shippable, surface the disagreement and pick the stricter reading.

## Verdict rubric

- **ACCEPTED** — zero blockers, zero criticals, zero majors in either review. Sound and ready to proceed.
- **WARNING** — zero blockers, but at least one critical, or at least one major the user has not acknowledged. Proceed with documented awareness, or fix in a follow-up before merging.
- **FAIL** — at least one blocker in either review, OR so many criticals/majors that the work cannot ship without rework.

When in doubt, pick the stricter verdict.

## Output format

```
# Fractal Cock: <change scope>

## Verdict
ACCEPTED | WARNING | FAIL

## Summary
<2-4 sentences: what was reviewed, the two lenses, the headline reason for the verdict.>

## Concerns
For each finding, ordered by severity (blocker first), then by file:
- **[severity] file_path:line — title**
  Source: spec | quality | both
  Category: <sub-category>
  What: <one sentence>
  Why it matters: <one sentence>
  Suggested fix: <one sentence>

Severity: blocker | critical | major | minor | nit

## Open questions
- <things the reviewers could not determine from the artifact alone>
```

No separate "ship verdict" line — the verdict already encodes it. No emoji. Plain prose.

## Operating principles

- **Two reviewers, in parallel, in one turn.** Serialization wastes time and anchors the second reviewer on the first.
- **Self-contained briefs.** No "see the other report".
- **Strict verdict rubric.** Do not soften a FAIL because the change is small; do not promote a WARNING because the user is in a hurry.
- **Cite, do not paraphrase.** Every finding references `file_path:line`.
- **Read-only.** The verdict is the deliverable. Route revision to `fractal-slave` / `fractal-architect` afterward.
- **Surface disagreement. No emojis, no fluff.**
