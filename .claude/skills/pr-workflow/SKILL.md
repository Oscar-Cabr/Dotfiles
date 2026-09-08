---
name: pr-workflow
description: Guides preparing, committing, describing, and self-reviewing a pull request following widely-used open-source conventions — Conventional Commits, focused PRs, structured PR descriptions, self-review checklists, review etiquette. Use on "open a PR", "submit a PR", "create a PR", "commit this for review", "stage this", "prepare a PR", "review my PR before I open it", "what should my PR description say", or any request to package local changes for review. Use ONLY for PR-level workflow; route implementation to fractal-slave / fractal-architect, code review of a finished PR to fractal-inspector, security audit to fractal-sentinel, docs to fractal-scribe, and plain git usage elsewhere.
---

# PR Workflow

A structured protocol for turning local changes into a pull request that reviewers can actually review. Applies the conventions used by major open-source projects: Conventional Commits for messages, focused diffs, structured PR descriptions, self-review before requesting review, and clear review etiquette on both sides.

This skill produces a complete PR package: a commit breakdown with messages, a PR description ready to paste into GitHub, and a self-review report. It can create local commits when asked. It does **not** push, open a remote PR, or merge — those stay human decisions.

## When to fire

Trigger on: "open a PR", "submit a PR", "create a PR", "prepare a PR"; "commit this", "stage this for review", "package my changes"; "what should my PR description say", "write the PR description"; "review my PR before I open it", "self-review my changes"; any request to summarize local uncommitted or branch-local changes for review.

Do NOT fire when the user wants implementation work (route to `fractal-slave` / `fractal-architect`), a code review of an already-submitted PR (`fractal-inspector`), a security audit (`fractal-sentinel`), documentation (`fractal-scribe`), or general git usage unrelated to PR preparation.

## Workflow

Run these phases in order. Stop and ask if any phase produces a blocker (mixed concerns, broken CI, missing tests) rather than guessing past it.

### Phase 1: Pre-flight

- Run `git status` and `git log --oneline -10` to see branch state and recent commit style.
- Identify the target base branch (typically `main` or `master`) — confirm with the user if ambiguous.
- Run `git diff <base>...HEAD` for branch-local changes; `git diff` for unstaged; `git diff --staged` for staged.
- Run `git diff --stat <base>...HEAD` for file-level change sizes.
- If the diff is larger than ~400 lines or spans more than ~10 files, flag it and ask whether to split into multiple PRs before proceeding.

### Phase 2: Commit hygiene

If the changes are uncommitted or in a single squashed commit, break them into logical units. For each: group related files (`git diff --name-only` by area), stage that group, draft a Conventional Commit subject, draft a body explaining *why* not *what*, create the commit.

If the user has already committed, audit with `git log <base>...HEAD`. Noisy commits (WIP, "fix typos", "address feedback" without context) — offer to squash or reword. Clean and focused — leave them alone.

### Phase 3: PR description

Fill every section from the diff and the user's stated intent — do not invent.

```markdown
## Summary
<1–3 sentences: what this PR does, in the user's own framing>

## Motivation
<Why this change is needed. Link the issue with "Fixes #N" / "Closes #N". State the user-visible problem.>

## What changed
- <area>: <what changed and why>
- <area>: <what changed and why>

## How it was tested
- Unit tests: <which, where>
- Integration tests: <which, where>
- Manual verification: <steps taken, observed result>

## Risk and rollback
- Risk: <description, likelihood, blast radius>
- Rollback: <revert this PR | disable flag | other>

## Screenshots / recordings
<Required for UI changes. Empty for non-UI.>
```

Output the description as a fenced block the user can paste directly.

### Phase 4: Self-review

Before declaring the PR ready, run a self-review pass. The specialist fan-out is issued from the main session (a skill cannot spawn subagents from within a subagent):

- Always: `Task(subagent_type: "fractal-inspector", prompt: "Review git diff <base>...HEAD. Files: <paths>. …")`. Treat any blocker or critical as fix-first.
- If the diff touches auth, input handling, secrets, crypto, network, or eval: also `Task(subagent_type: "fractal-sentinel", …)`.
- If the diff adds a public API, CLI flag, or new export: flag API-design concerns (naming, error shape, backward compat) for the user — there is no dedicated agent for this.

Then run this checklist. Any unchecked item is a finding to surface:

- [ ] Subject lines ≤72 chars, imperative mood, no trailing period.
- [ ] Conventional Commit prefix used where applicable.
- [ ] Commit body explains *why*, not *what*, when non-obvious.
- [ ] One logical change per commit.
- [ ] PR description has every required section filled.
- [ ] Linked issue (if any) referenced with Fixes/Closes.
- [ ] Tests added or updated for changed behavior.
- [ ] CI is green locally before requesting review.
- [ ] Diff size within target (<400 lines, <10 files when possible).
- [ ] No debug code, commented-out code, or stray prints left in.
- [ ] No secrets, credentials, or `.env` content in the diff.
- [ ] Branch name follows `type/short-kebab-description`.

Surface the self-review report:

```markdown
## PR Self-Review: <branch> → <base>

### Status
ready | needs-fix-first | needs-split

### Reviewer findings
<aggregated fractal-inspector + fractal-sentinel output, severity-ordered>

### Checklist
<completed items checked; remaining unchecked with a one-line note>

### Recommended next step
<open the PR with the description above | fix N items first | split into M PRs>
```

## Commit conventions

- Format: `<type>(<scope>): <subject>` where type is `feat | fix | refactor | perf | test | docs | build | ci | chore | style`.
- Subject: ≤72 chars, imperative mood ("add", not "added"), no trailing period, no capitalization of the first word after the type.
- Body: optional, wrap at 72 columns, explain *why*, link issues with `Fixes #N` / `Refs #N`.
- Footer: `BREAKING CHANGE: <description>` for breaking changes; co-authored trailers when pairing.

```text
feat(login): add rate limiting on password attempts

Mitigates brute-force attacks on the login endpoint. After 5 failed
attempts within 15 minutes from the same IP, further attempts return
429 with a Retry-After header.

Fixes #1234
```

## Review etiquette

Authors: read the diff cold before requesting review; CI green before the request; respond to every comment; force-push only for unfinished work, append fixups once review has started; keep the PR alive with status comments if blocked.

Reviewers: Approve = "comfortable if this merged now"; Request changes = blocker, be explicit about "must address" vs "nit, your call"; prefix nits with `nit:`; cite the line; review in time the author can use.

## Merge strategy

Squash merge for feature branches committed incrementally; rebase or merge commit where each commit is a meaningful reviewable unit; delete the source branch on merge unless there's a reason to keep it. Match the project's existing conventions; ask if unclear.

## Operating principles

- Produce the package, don't push. Local commits when asked; never push, open a remote PR, or merge.
- Surface size concerns early — a 1500-line PR is a "split this" problem, flagged in Phase 1.
- Cite the diff. Every claim about what changed comes from `git diff` output.
- One logical change per commit.
- Self-review is not optional. Phase 4 runs every time.
- Ask before splitting or rewriting history.
- Match the project's conventions. No emojis, no fluff.
