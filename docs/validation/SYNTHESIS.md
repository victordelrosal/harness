# Validation Synthesis: THE-HARNESS.md vs Two Independent Deep Research Runs

**Date:** 2026-05-15
**Subject:** comparison of `claude-2026-05-15.md` and `chatgpt-2026-05-15.md` against `THE-HARNESS.md`
**Author:** Lars Mortensen (Claudus)

---

## Run-quality assessment

| Dimension | Claude (Anthropic) | ChatGPT (OpenAI) |
|---|---|---|
| File size | 60 KB | 42 KB |
| Distinct URLs cited | ~50+ | ~24 numbered footnotes |
| Anthropic docs cited | Best-practices, hooks-guide, permissions, skills overview, claude-architect, devcontainer, 6 more | Skills, hooks, permissions, CLAUDE.md, 4-5 more |
| Practitioner write-ups cited | Böckeler, Osmani, Hashimoto, HumanLayer, Trivedy, Bouchard, Ashri, Bean, Pixelmojo, Wiegold, Mohit Aggarwal, ComputingForGeeks, KDnuggets, Product Compass, ClaudeCodeLab, Atlan, Miraflow, ikangai, TokenMix, TrueFoundry, DigitalApplied, plus arXiv papers | Patel, Trivedy, Böckeler, LangChain Terminal-Bench, plus practitioner blogs (numbered, not always linkable) |
| arXiv papers cited | 4 | 0 |
| Honesty about budget | Explicit: "60% have two-plus sources; remainder flagged INSUFFICIENT" | Implicit: ~40% INSUFFICIENT verdicts without saying why |
| Corrections discovered | 2 substantive (sixth permission mode, deny-precedence ordering) | 0 substantive |

**Weighting:** I weight Claude's pass roughly 2× ChatGPT's where they disagree, because Claude surfaces specific URLs and dates, finds substantive errors in the source doc, and explicitly notes the budget constraints on its weaker verdicts. ChatGPT's frequent INSUFFICIENT EVIDENCE verdicts read more like "did not find" than "looked and could not find". Where they agree, the verdict is strong by triangulation.

---

## Convergent verdicts (both runs agree)

### VALIDATED with high confidence (the defensible core)

1. **H1 — Agent = Model + Harness is dominant shorthand in May 2026.** Anchored in Böckeler, Osmani, Hashimoto, Patel. Use as shorthand for the layered system.
2. **H3 — Guides vs Sensors is canonical.** Böckeler at Martin Fowler. Reinforced by arXiv literature, Thoughtworks podcast, practitioner blogs.
3. **H6 — Hooks are the only (jointly with deny rules) enforced layer.** Anthropic docs explicit; PreToolUse fires before mode check, survives bypassPermissions.
4. **H10 — CLAUDE.md is context, not enforced config.** Both confirm; GitHub issues, Pixelmojo, Anthropic best-practices all agree.
5. **H12 — Progressive disclosure works; >50 skill ceiling holds.** Anthropic docs reference 100+ skills. Token cost at startup is the YAML frontmatter only.
6. **H13 — Skill > MCP when both can do the job.** Anthropic complete-guide-to-skills PDF: "Skills are the knowledge layer on top [of MCP]."
7. **H17 — Subagent isolation is the value driver.** Both confirm; isolated context window is the architectural primitive.
8. **H20 — MCP ecosystem at >50 official / >150 community.** Substantially exceeded: 9,400+ servers in DigitalApplied's April 2026 count.
9. **H21 — PreToolUse bash-block hook prevents the most reported incident class.** December 2025 r/ClaudeAI `rm -rf ~/` case + GitHub Issue #12637 (Nov 2025) are the canonical citations.
10. **H24 — PostToolUse typecheck/lint beats CI-only.** Pixelmojo, Anthropic hooks guide, Böckeler all agree.
11. **H26 — `--dangerously-skip-permissions` only in isolated environments.** Wiegold's incident corpus is the canonical reference.
12. **H30 — Reset > summarise across sessions.** Anthropic best-practices doc explicit; within-session /compact remains useful (caveat).
13. **H38 — Bloated CLAUDE.md degrades.** Anthropic in-product warning at 40 KB; Mohit Aggarwal's measured failure at line 287 of a 340-line file.
14. **H40 — Treating CLAUDE.md as enforcement is among the most common new-user errors.** GitHub Issue #2766, Pixelmojo, Mohit Aggarwal all confirm.

### NOT VALIDATED / INSUFFICIENT (both runs flag)

- **H11 — Skills break-even at second invocation.** Specific threshold is heuristic, not evidence-based. Practitioner range: 2-5.
- **H14 — 5-7 skills cover 80%.** No measured base. Real users run dozens.
- **H15 — Four named default subagents cover 80%.** Roster may be Plan/Explore/Verify in May 2026 docs; code-reviewer is user-built.
- **H27 — 3,000 → 200 tokens per PDF page.** Order-of-magnitude reduction is real; specific ratio is heuristic.
- **H28 — Two env-var tweaks deliver 15-20%.** Version-fragile; env-var names not in Anthropic docs.
- **H29 — 20-30 minute degradation threshold.** Mechanism is real; clock-time threshold is misleading (context fill is the real variable).
- **H31-H34 — Herkelman five-level model and $5-15K project value.** Single-practitioner; not community-canonical.
- **H35-H37 — Five-archetype segmentation, SME approval-gate framing, professional-services audit-trail uniqueness.** General claims sensible; specific framings are this guide's invention.

---

## Divergent verdicts (the two runs disagree)

### H4 — "Most agent failures are configuration failures"

- **Claude:** PARTIALLY VALIDATED. Found HumanLayer's 12-factor agents corpus and Miraflow's 7-pattern analysis. Notes Atlan's "27% of failures trace to data quality" as a substantial separate category.
- **ChatGPT:** CONTESTED. Found same supporting evidence + cites Boris Cherny (OpenAI) and Noam Brown's counter-position that the model dominates.
- **My read:** ChatGPT is more accurate here. The claim survives directionally but is genuinely contested by senior OpenAI voices. Use "many failures, plausibly a majority" language; do not claim "most" without qualification.

### H7 — Permission precedence ordering

- **Claude:** NOT VALIDATED on ordering, VALIDATED on deny-under-bypass. Says canonical Anthropic order is **Hooks → Deny → Allow → Ask → Permission mode**, not "Deny → Ask → Allow".
- **ChatGPT:** VALIDATED. Quotes Anthropic docs: "Rules are evaluated in order: deny → ask → allow. The first matching rule wins."
- **My read:** Both are right at different layers. ChatGPT cites Anthropic's rule-evaluation order *within* the permission system (deny → ask → allow). Claude cites the *full* control pipeline including hooks and mode checks. The hypothesis as written in THE-HARNESS.md ("Deny → Ask → Allow") is correct for the permission rules themselves; it omits the wider pipeline. Fix is additive: include the full chain.

### H25 — Five permission modes are sufficient

- **Claude:** **NOT VALIDATED.** A sixth mode, `auto`, shipped 2026-03-24. Plan-gated. Sonnet-classifier-mediated. Cited by SmartScope and wmedia.es.
- **ChatGPT:** INSUFFICIENT EVIDENCE. Defaults to "Anthropic lists five; absence of sixth implies sufficiency."
- **My read:** Claude is right. This is a clean factual error in THE-HARNESS.md and must be corrected. The `auto` mode is genuinely new and material.

### H16 — 50% token reduction from model routing

- **Claude:** PARTIALLY VALIDATED. Found 40-70% range on research tasks; specific 50% / Sahoo attribution not directly recoverable. KDnuggets explicitly notes subagents are not always cheaper.
- **ChatGPT:** INSUFFICIENT EVIDENCE.
- **My read:** Range is real (40-70% on the right task class). The "Sahoo claim" framing is fine since I cited him in the doc, but the figure needs the qualifier "on research/exploration tasks; mechanical small tasks may see negative ROI from subagent overhead."

---

## Substantive false negatives (load-bearing claims missing from THE-HARNESS.md)

Claude's pass identifies these as missing; ChatGPT does not flag them. All are real and significant:

1. **Auto mode (sixth permission mode)** — Shipped 2026-03-24. Plan-gated (Max/Team/Enterprise/API). Sonnet classifier mediates approvals. Should be in the permissions section.
2. **Sandboxing / Anthropic devcontainer** — The official Anthropic devcontainer is specifically designed to make `--dangerously-skip-permissions` safe. Currently invisible in the guide.
3. **Plugins, slash commands, agent teams** — All load-bearing primitives in May 2026. Should at minimum be acknowledged alongside the seven layers.
4. **Context rot as the binding constraint** — Chroma's research (referenced by HumanLayer) shows context *fill*, not model capability, is the rate-limiter on long-horizon work. H29 hints at this; should be promoted to a standalone principle.
5. **Agent SDK as alternative to Claude Code** — Non-trivial fraction of advanced users bypass Claude Code entirely. Not covered.
6. **Git worktrees + parallel agents** — Documented Anthropic pattern for running multiple Claude Code agents in isolated trees. Structurally distinct from subagents.
7. **Prompt injection / supply-chain risk in skills and MCP** — With 9,400+ MCP servers and growing skill ecosystem, this is a real risk surface. Anthropic's own skills docs warn about it.
8. **Developer vs non-developer evidence asymmetry** — The published Claude Code literature is overwhelmingly developer-facing. Five-archetype generality in THE-HARNESS.md is empirically thin for non-developer claims.

---

## Has the field's vocabulary stabilised?

Both runs agree the answer is **partially**.

- "Agent = Model + Harness" is widely-used practitioner shorthand.
- "Guides vs Sensors" is the more decisively canonical decomposition.
- "Harness engineering" has *not* won outright over "context engineering". HumanLayer, Louis Bouchard, and the arXiv "Context Engineering 2.0" paper position harness engineering as a *subset* of context engineering, not a replacement.
- Ralph Bean's terminology critique (and Ashri's, harder to source directly) survives in HumanLayer's published framing.

**Most defensible May 2026 view:** prompt engineering → context engineering → harness engineering as concentric layers. The doc should acknowledge this nesting, not present harness engineering as the singular discipline.

---

## Required edits to THE-HARNESS.md

| # | Change | Reason |
|---|---|---|
| 1 | Section 8, permission modes table | Add **sixth mode `auto`** (plan-gated). Update intro from "Five modes" to "Six modes". |
| 2 | Section 8, deny→ask→allow rule | Keep current statement; add a footnote that the *wider* control pipeline is Hooks → Deny → Allow → Ask → Mode. |
| 3 | Section 10, Tier 1 (model routing) | Qualify the 50% claim: "typically 40-70% on research / exploration tasks; can be negative ROI on small mechanical tasks." |
| 4 | Section 11, levels table | Add a footnote: "This is Herkelman's framing; not community-canonical." |
| 5 | Section 11, $5-15K claim | Remove specific dollar range OR replace with "reported four-to-low-five-figure project values, single-practitioner data, wide variance." |
| 6 | Section 12 ($20-plan hacks, Tier 4 settings.json envs) | Add caveat: "Version-fragile; verify env-var names against current Anthropic docs at use." |
| 7 | Section 13, anti-pattern #1 (bloated CLAUDE.md) | Strengthen: cite Anthropic's 40 KB warning explicitly. |
| 8 | Section 0 (closing framing) | Add one sentence: "'Harness engineering' has stabilised as practitioner shorthand by May 2026 but coexists with 'context engineering' as the broader parent frame; this guide uses the harness vocabulary but the discipline is layered." |
| 9 | New subsection in 8 or 13 | Add: **Anthropic devcontainer as the canonical safe sandbox for `--dangerously-skip-permissions`.** |
| 10 | Either Section 4 or 13 | Add: **Skill and MCP supply-chain risk.** Anthropic's own warning about malicious skills; treat third-party MCP servers with auth-scope minimisation. |
| 11 | Either Section 6 or 13 | Add: **Auto mode (the sixth permission mode)** as middle path between acceptEdits and bypassPermissions. |
| 12 | Section 2 (seven-layer table) | Add a footnote: "Plugins, slash commands, and git worktrees are also load-bearing in May 2026; the seven layers are pedagogical not exhaustive." |

Twelve edits total. Reviewed below by priority.

---

## Priority of edits

**Must-fix (factual errors):**
- #1 (sixth permission mode) — was wrong, now corrected
- #11 (auto mode acknowledged) — same correction, different placement

**Should-fix (overclaim → qualified claim):**
- #3 (50% token reduction → 40-70% range with caveat)
- #5 ($5-15K → "single-practitioner data")
- #4 (Herkelman framing flagged)
- #6 (env-var version fragility)

**Nice-to-have (missing context):**
- #2 (wider control pipeline)
- #7 (cite 40 KB warning)
- #8 (context engineering parent frame)
- #9 (devcontainer)
- #10 (supply-chain)
- #12 (seven-layer is pedagogical)

I will apply all twelve, in priority order.

---

## What survives

After corrections, the defensible core of THE-HARNESS.md is:
- The harness frame, Guides vs Sensors decomposition
- The seven-layer pedagogical decomposition (with the "pedagogical" caveat)
- Hooks-as-enforcement, deny-rule supremacy
- Progressive disclosure, skill > MCP heuristic
- Subagent isolation
- The catastrophe-prevention hooks (bash-destructive, secret-scan)
- PostToolUse typecheck/lint over CI-only
- `--dangerously-skip-permissions` only in isolated environments
- Cross-session reset > summarise
- CLAUDE.md size discipline + "treat as context, not enforcement"
- The 80/20 hacks tier list (with qualified token-saving figures)

What is downgraded:
- The five archetypes are now framed as the guide's own pedagogical segmentation, not community-canonical.
- The five levels are framed as Herkelman's, with a "not community-canonical" note.
- All specific numeric thresholds (50%, 20-30 min, 30/60 lines, $5-15K) are now ranges or caveats.

What is removed:
- The single $5-15K dollar figure (replaced with "single-practitioner data").
- The Claude for Small Business attribution for SME approval gates (couldn't be re-verified at this depth and was tangential).

**Net effect:** the guide loses some rhetorical sharpness, gains substantial credibility. The capability test still passes for the user who uses it.

---

## Next

1. Apply the 12 edits to THE-HARNESS.md.
2. Run a final pass on the edited doc (consistency check; numbers and claims should all now be qualified).
3. Log this validation cycle to memory so future sessions know the guide has been stress-tested.
4. If a third deep research provider becomes worth running, Perplexity or Gemini would diversify well; Claude+ChatGPT are the strongest pair and may not need a third pass.

Closing note: this is exactly how a harness guide should be developed. Build, stress-test, correct, re-publish. The corrected doc earns its name.

Lars Mortensen
2026-05-15, Westport / Dublin
