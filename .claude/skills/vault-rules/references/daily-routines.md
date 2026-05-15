## Pipeline + per-(date, category) data dir

Every routine writes pipeline stage files to `coilyco-ai/lib/my/.data/<date>/<category>/`:

```
01-cache.yaml      fetcher cache (only present when @cached fetchers ran)
02-raw.yaml        full normalized records, post-fetch (regenerable source of truth)
03-digested.yaml   filtered/capped sections, pre-render (what build_digest consumes)
04-run.yaml        per-stage telemetry (fetch / digest / render blocks + overall)
```

The numbered ordering surfaces the lifecycle as a walkable sequence. Each file is YAML so any of them can be hand-edited. The `lib/my/data.py` helper provides the path + atomic-write/read API; `data.pointer_block(today, CATEGORY)` lands as a blockquote in the inbox body so a reader can jump from the digest to the full data dir.

The inbox file carries compressed views (counts tables, top-N samples, per-host/per-actor histograms); per-item walls live in `02-raw.yaml`.

**Why:** verbose discord/git-log/feed walls were drowning the synthesis on Kai's phone but still occasionally need to be readable; phone-vs-laptop access pattern doesn't match noise-level tolerance, so split into separate files. Re-runs benefit from the split too: re-rendering with different caps reads `02-raw.yaml`, not the network.

**Rotation:** `data.rotate(today)` keeps today's date dir and the most-recent-prior date dir; older drops. Same rule as memory's trace cascade. Runs at the start of every routine's `cmd_all`.

**How to apply:** when adding a new daily routine, follow the operational pattern (`.claude/skills/daily-operational/script.py`): `cmd_fetch` writes 02-raw, `cmd_digest` writes 03-digested via a pure `digest()` function that consumes WEIGHTS, `cmd_render` writes the inbox from 03-digested. Skip writing 02-raw only when the data is inherently <30 records and already tabular (k3s nodes, grafana ping). The `.data/` dir is in `.gitignore` because the contents include URLs, message bodies, and other PII that should not leave the local machine.

## Subcommands + replay

Every daily-* script accepts a stage subcommand:

```sh
python3 script.py [all]      # full pipeline (default)
python3 script.py fetch      # fetch -> 02-raw.yaml
python3 script.py digest     # 02-raw.yaml -> 03-digested.yaml
python3 script.py render     # 03-digested.yaml -> inbox markdown
```

Each subcommand reads from its prior stage's file and writes its own output. Stage idempotency: re-running a stage N times produces the same output (modulo network jitter on fetch).

Replay flows the layout enables:

- **Loosen / tighten caps:** edit `lib/my/config.yaml`, then `python3 script.py digest && python3 script.py render`. No re-fetch.
- **Hand-edit raw to test alternate fetcher output:** `vim .data/<date>/<cat>/02-raw.yaml`, then digest+render.
- **Hand-edit digested to test renderer change:** `vim .data/<date>/<cat>/03-digested.yaml`, then render.
- **Clear cache to force re-fetch:** `rm .data/<date>/<cat>/01-cache.yaml`, then `python3 script.py fetch`.
- **Drop a single stale cache entry:** `vim 01-cache.yaml`, delete the offending block, run fetch.

## SDI-style memory merge (daily-memory distinction)

The routine doesn't just promote inbox items into `Notes/`. It greedily merges new info into both the chosen target note AND the existing content of that note - free to create, update, or delete (only on contradictions / false facts / hallucinations / negations / conceptual expirations like calendar events).

It leaves a *trace* in `inbox/<date>-memory.md` describing what got merged or dropped that day. **The trace itself merges in prior days' traces** so the trace doesn't grow unbounded - it evolves and decays the same way Notes/ does.

## Token budget + o11y

Per-routine `llm_input_token_budget` lives at `lib/my/config.yaml`. The budget drives section caps via `lib/my/budget.py`: each routine's `digest()` step splits the budget across body sections by WEIGHTS and converts each slice into a top-N cap by per-item token width. Adjust the budget and every section flexes proportionally on the next digest run.

Three properties land in inbox frontmatter every run: `token_budget`, `pre_compression_tokens` (estimate if every per-item record were dumped verbatim), `utilization_ratio` (pre / budget). >1 means caps are doing real work; <0.3 means the budget is over-provisioned.

Per-run o11y lives in `04-run.yaml` per category: `stages.{fetch,digest,render}` with `started_at`, `finished_at`, `duration_s`, `status`, plus stage-specific payload (sources for fetch, weights for digest, inbox info for render). `overall.status` recomputes on every stage write. The whole file rotates with `.data/` (today + most-recent-prior).

## Sanitization

After [Ruggieri/obsidian-daily-digest](https://github.com/brianruggieri/obsidian-daily-digest): regex scrubber for tokens / API keys / credentials runs on every digest before inbox write. Even though the vault is local-first, Obsidian Sync ships to phone and the coilyco-ai bundle goes into Claude.ai project knowledge. Defense in depth.

## Preserved sections (synthesis + notes)

Two preserved blocks survive re-runs, both via sentinel pairs that `inbox.merge_*` helpers splice through:

- **`## Synthesis`** wraps with `<!-- llm-synthesis:start -->` / `<!-- llm-synthesis:end -->`. The python tier writes a placeholder; whatever the LLM tier (or Kai) writes between the sentinels survives every subsequent re-run, including format-change backfills via `DAILY_FORCE=1`. **Filling synthesis is mandatory on every cron run, every routine, no exceptions.** The cron prompt fires a Claude session that loads the SKILL.md, runs the script, then reads `lib/my/.data/<date>/<category>/03-digested.yaml` and rewrites the synthesis block. No API key needed - the surrounding Claude session is the LLM tier. A leftover placeholder synthesis in any inbox file is a routine bug, not an empty-data signal.
- **`## Notes`** wraps with `<!-- user-notes:start -->` / `<!-- user-notes:end -->` at the foot of the file. After [Ruggieri/obsidian-daily-digest](https://github.com/brianruggieri/obsidian-daily-digest). If Kai annotates during her lunch read, the annotation survives a same-day re-run.

## Caching

After [Karlicoss/cachew](https://github.com/karlicoss/cachew): slow source fetchers (gh API, opengraph fetches, gmail body pulls) decorated with `@cache.cached(ttl_hours=N)`. YAML-backed at `.data/<date>/<category>/01-cache.yaml`, hand-editable. `cache.set_context(date, category)` is mandatory before any `@cached` call; calling without raises `RuntimeError` so missing context fails fast. Cache rotates with `.data/`, so each new day starts cold (acceptable - 7-day lookback windows mean most data overlaps anyway).

## End-of-run chat summary

After every daily-* routine completes (Claude tier finished, inbox written), emit a chat summary as a markdown unordered list, not a single pipe-delimited line. Items in order:

- `routine: daily-<category>`
- `counts: <key>=<n> <key>=<n> ...` (the per-source tallies the routine produced, e.g. `gmail=20 gh-feed=10 trending=7 ranked=20`)
- `top: <one-phrase synthesis hook>` (what the day converged on)
- `status: <complete|partial|error>`
- `files:` followed by a nested UL, one entry per newly-written or newly-overwritten file (the inbox `.md` plus each `.data/<date>/<category>/*.yaml`), each entry as `<path> - <size> - ~<tokens> tok`. Byte size from `wc -c` or `stat`; token count from `lib/my/budget.estimate_tokens` (chars/4 is fine).

Skip the pipe-delimited one-liner format. The UL renders better in chat and the per-file size+token columns make it obvious when a routine bloats unexpectedly.

Example:

- routine: daily-educational
- counts: gmail=20 gh-feed=10 trending=7 ranked=20
- top: harness-engineering convergence
- status: complete
- files:
    - `inbox/2026-05-04-educational.md` - 8.2 KB - ~2050 tok
    - `lib/my/.data/2026-05-04/educational/02-raw.yaml` - 184 KB - ~46k tok
    - `lib/my/.data/2026-05-04/educational/03-digested.yaml` - 41 KB - ~10k tok
    - `lib/my/.data/2026-05-04/educational/04-run.yaml` - 1.1 KB - ~280 tok

## Format change → backfill today's output

When Kai asks to update a daily-* skill's output format and today's `inbox/YYYY-MM-DD-<category>.md` already exists, update that file in the same change to match the new format. Hand-patch if the change is mechanical; re-run with `DAILY_FORCE=1` (env var that bypasses the already-complete guard in `schedule.py`) if the format shift is structural (frontmatter schema, section reordering).

For renderer-only changes, you don't even need to re-fetch: edit the renderer, then `python3 script.py render` reads `03-digested.yaml` and re-emits the inbox.

**If the skill is currently in flight when the request arrives, flag it** ("daily-<cat> is in flight") and ask Kai whether to wait + re-render, kill + restart, or let it finish + fix-forward. Don't silently edit a file another process is writing.

Flagged 2026-04-30.

**How to apply:** check for today's inbox file before/after editing the skill; check `.data/<date>/<category>/04-run.yaml` and any running process for in-flight state.

## "Daily routines" requests apply to all 9 by default

When Kai says "update daily routines so that they..." (or any variant that names the routines collectively without naming a subset), apply the change across all 9 daily-* skills.

**Why:** each routine lives in its own skill dir, so collective requests would otherwise need disambiguation every time. Flagged 2026-04-30.

**How to apply:** sweep all 9 `.claude/skills/daily-*/` dirs (and `lib/my/` if the change is in shared code). If a subset is intended, Kai will name them. The layer (SKILL.md vs Python helper vs `lib/my/` vs config.yaml) still needs to be clear from context - ask if ambiguous.

## Absorbed legacy skills

`log-sessions` (folded into daily-productive), `session-rollup` (folded into daily-productive's cross-stream synthesis), `reading-list` (folded into daily-educational), `pulse` (umbrella that runs all 9 now).
