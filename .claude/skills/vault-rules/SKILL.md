---
name: vault-rules
description: Obsidian vault rules (layout, vault-pass workflow, cross-repo capture) and daily-routines context (nine cron-scheduled inbox-writing skills, per-(date, category) .data/ pipeline, fetch/digest/render subcommands, synthesis preservation, sanitization, caching, format-change backfill). Triggers - vault, obsidian, inbox, second brain, notes/, people/, orgs/, daily routines, daily-operational, daily-activity, daily-social, daily-productive, daily-educational, daily-recruiting, daily-memory.
---

# Second brain (Obsidian vault)

Vault at `~/projects/coilysiren/coilyco-vault/Obsidian Vault/` (both hosts). **Not in git - intentional.** Don't `git init`, don't offer to commit/push, don't treat missing git as an error.

## Layout (don't invent new top-level folders)

- `Home.md`
- `Notes/` (main durable, including merged bio / career / health / social)
- `Notes/seeds/` (durable raw substrate from inbox `keep` decisions, awaiting per-concept promote into a parent Notes/ file - filenames stay date-prefixed)
- `People/`
- `Orgs/`
- `inbox/` (ephemeral, gitignored)

The former `Self/` folder was merged into `Notes/` on 2026-04-30 - identity / contact / resume / LinkedIn live in `Notes/bio.md`, the resume PDF body sits inside `<!-- resume:start --> ... <!-- resume:end -->` markers inside that file.

## Shaping

One idea per note; link only when meaningful; synthesis lives inline in the relevant folder and says something stronger than any input; concise high-signal markdown, no rigid templates; nav/map notes only when they reduce rediscovery cost.

## Vault pass workflow

Always starts with a session log. If Kai asks without one, assume she wants both.

1. `log-sessions` skill (or `daily-productive`) flushes today's transcripts to `inbox/`.
2. Read `inbox/`.
3. Promote durable ideas to `Notes/` (or `People/Orgs/` by topic); update existing over creating near-duplicates.
4. Drop clutter.
5. Clear processed inbox items.
6. Link related notes when it reduces rediscovery cost.

## Cross-repo capture

Durable insight → `~/projects/coilysiren/coilyco-vault/Obsidian Vault/inbox/YYYY-MM-DD-slug.md` and keep moving. Full promotion happens in a vault pass.

## Ad-hoc inbox entry shape (reading pulls, post summaries, anything not a daily routine)

Default to **action-keyed sections**, not Thesis / Key-points / Takeaway. Kai retrofitted a Thesis-shape draft on 2026-05-04 because the action-keyed shape is what she actually skims for.

Sections, in order, omit any that are empty:

- Frontmatter: `source`, `author` or `publisher`, `published`, `pulled`.
- Title + bare URL line.
- One-line orientation (who, why this matters, companion-piece pointers).
- **Adopt** - rules / reframes Kai is taking on.
- **Try cheaply** - low-cost experiments.
- **Watch for** - patterns to notice in own work.
- **Concepts worth the vocabulary** - named ideas that earn dictionary space.
- **Skip** - explicitly noting what's real-but-not-actionable, so future-Kai doesn't re-evaluate.
- **Open questions** - what the source itself didn't close.

**Why:** Thesis / Key-points / Takeaway preserves the source author's structure. Action-keyed sections preserve Kai's decision structure - the way she will actually re-encounter the material. The latter survives a vault pass intact.

**How to apply:** when summarizing an external piece (blog post, PDF, talk, paper) to inbox, lead with this shape. Old-shape summaries are acceptable in flight, but match the new shape for anything fresh.

# Daily routines

Nine cron-scheduled skills that pull data from external sources daily and write digests to the vault inbox. Skills live at `~/projects/coilysiren/coilyco-ai/.claude/skills/daily-<category>/`. Shared Python sits at `~/projects/coilysiren/coilyco-ai/lib/my/` (HPI-style `from my import gmail, github, ...` namespace, after [Karlicoss/HPI](https://github.com/karlicoss/HPI)).

## The nine categories

- `daily-operational` (07:00) - sentry, k3s, reachability pings, grafana
- `daily-activity` (07:15) - chrome history with opengraph metadata
- `daily-social` (07:30) - bluesky, sirens discord
- `daily-productive` (07:45) - github / git log / claude sessions / repo-recall
- `daily-educational` (08:00) - gmail newsletters + github feeds (atom + received_events + trending)
- `daily-recruiting` (08:15) - gmail recruiting + gcal + trello
- `daily-memory` (08:30) - greedy SDI-style merge of inbox items >7d into `Notes/`
- `daily-backlog` (09:47) - org-wide gh issue sweep, syncs the [coilysiren backlog Project](https://github.com/users/coilysiren/projects/2), flags stale + silent + cross-repo dupes
- `daily-errors` (10:05) - meta scan of the day's other 8 inbox files for failures (runs last)

## Inbox file pattern

`inbox/YYYY-MM-DD-<category>.md`. Frontmatter holds `status` (complete | partial | error), per-source dedup keys, and the lookback window. Re-runs are idempotent on `status: complete`. Lookback is 7 days; routines stop when they hit data already captured in prior inbox files.

## Daily routines pipeline

The full daily-routines pipeline (per-(date, category) .data/ dir, fetch/digest/render subcommands, SDI-style memory merge, token budget, sanitization, synthesis preservation, caching, end-of-run chat summary, format-change backfill, "daily routines" applies-to-all rule, absorbed legacy skills) lives in [`references/daily-routines.md`](references/daily-routines.md). Read it when editing any daily-* skill or reasoning about replay shape.
