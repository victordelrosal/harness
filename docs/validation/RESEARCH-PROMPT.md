# Deep Research Prompt: Validate the Hypotheses in THE-HARNESS.md

**Purpose:** independent stress-test of the claims in `sBs/harness/THE-HARNESS.md` (Claude Code configuration guide for top-1% users), commissioned by Victor del Rosal, drafted by Lars Mortensen 2026-05-15.

**How to use:** paste the full prompt below into ChatGPT Deep Research, Claude's research mode, Perplexity Deep Research, or Gemini Deep Research. Run unedited. Run twice across different providers to triangulate. Compare verdicts.

---

## START OF PROMPT (paste from here)

You are a senior research analyst with deep expertise in AI agent systems, developer tooling, and configuration management. You are doing an adversarial, evidence-first validation pass on a claimed best-practices document for Claude Code (Anthropic's terminal coding agent). I want disconfirming evidence as eagerly as confirming evidence. A hypothesis is **validated** only if you can produce two or more independent, primary, dated sources from the last 12 months that support it, **and** you can find no credible counter-evidence that overturns it.

**Time horizon:** prioritise sources from November 2025 through May 2026. Older sources are admissible as context, not as evidence of current best practice.

**Source quality hierarchy** (use in this order):
1. Anthropic's own engineering blog, Claude Code docs, and public talks.
2. Practitioner write-ups with quantitative results (token counts, dollar amounts, time saved, error rates), ideally with reproducible setup notes.
3. Substantive engineering essays from named authors with credentials (Trivedy at LangChain, Böckeler at Thoughtworks, Osmani, Willison, Ashri, plus equivalents).
4. Peer-discussed posts (LinkedIn, X, Reddit r/ClaudeAI, HackerNews) where the discussion itself contains substantive counter-arguments.
5. Vendor marketing **only** as a tertiary anchor, never as the sole source.

**Disqualifiers:** anonymous Medium reposts of other people's content; AI-generated listicles with no first-hand experience signal; pre-November-2025 material treated as current; speculation about features that do not exist.

**Output format:** for each hypothesis, return a card with these fields:

```
Hypothesis: [verbatim]
Verdict: VALIDATED | PARTIALLY VALIDATED | NOT VALIDATED | CONTESTED | INSUFFICIENT EVIDENCE
Confidence: HIGH | MEDIUM | LOW
Supporting evidence: [bullet list with source + one-line quote/finding + URL + date]
Disconfirming evidence: [same format]
Caveats and edge cases: [where the hypothesis breaks]
Recommended revision: [if the hypothesis should change, draft the corrected version]
```

End with a **synthesis section** addressing:
- Which hypotheses, taken together, form the most defensible core?
- Which are weakest, and what is the highest-priority follow-up research?
- Are there hypotheses I missed (false negatives in the list)?
- Is the framing (Agent = Model + Harness, Guides vs Sensors) the canonical one in May 2026, or has the field's terminology moved on?

---

## The hypotheses to test

### A. Foundational framing

1. **"Agent = Model + Harness" is the dominant conceptual frame in May 2026.** The model is intelligence; the harness is everything around it (instructions, tools, memory, orchestration, hooks, observability).
2. **"A decent model with a great harness beats a great model with a bad harness"** is empirically defensible, not just rhetoric. Specifically: holding model fixed and tuning harness produces larger productivity / accuracy gains than holding harness fixed and upgrading the model, for typical knowledge-work and engineering tasks.
3. **The Guides vs Sensors distinction (Böckeler) is the right primary decomposition.** Guides are feedforward (CLAUDE.md, skills, plans); sensors are feedback (linters, tests, hooks, code-review agents). Effective harnesses need both; one without the other fails.
4. **Most agent failures are configuration failures, not model failures.** HumanLayer's "it's not a model problem, it's a configuration problem" is supported by case studies.

### B. The seven-layer architecture for Claude Code

5. **The seven layers (memory, skills, subagents, MCP servers, hooks, permissions, statusline) are the right decomposition of a Claude Code harness.** No major primitive is missing; none of the seven is dispensable.
6. **Layers 1-4 are advisory; layer 5 (hooks) is the only enforced layer.** A rule in CLAUDE.md is read and usually honoured, never guaranteed. Hooks execute deterministically and cannot be skipped by the model.
7. **Deny → Ask → Allow is the canonical permission precedence**, and deny rules fire even under `--dangerously-skip-permissions` / `bypassPermissions`.

### C. Memory (CLAUDE.md)

8. **CLAUDE.md should be kept under ~30 lines globally and under ~60 effective lines at the project level.** Longer files degrade attention.
9. **The three-tier hierarchy (`~/.claude/CLAUDE.md` → `./CLAUDE.md` → `CLAUDE.local.md`) is the correct pattern**, with local overrides gitignored and project file source-controlled.
10. **CLAUDE.md is read as context, not enforced as configuration.** The implication: anyone relying on CLAUDE.md alone for compliance, safety, or hard rules is mis-configured.

### D. Skills

11. **Skills outperform ad-hoc prompting for any workflow done more than twice.** The break-even point is the second invocation, not the third or fifth.
12. **Anthropic's progressive disclosure model (only the matched skill loads) prevents context bloat from large skill libraries**, so the practical ceiling for installed skills is well above 50.
13. **"Skill > MCP, when in doubt" is correct guidance**: skills compose tools you have into recipes, while MCP adds new tools at the cost of auth, scopes, and context overhead.
14. **Five to seven well-built skills cover ~80% of the recurring workflows of a typical knowledge worker or solopreneur.**

### E. Subagents

15. **Four default subagents (Plan, Explore, code-reviewer, general-purpose) cover ~80% of subagent use** for a developer or technical solopreneur.
16. **Model routing inside subagents (Haiku for mechanical, Sonnet for synthesis, Opus for tradeoffs) produces a real-terms ~50% token reduction on otherwise comparable tasks** (the Abhisekh Kumar Sahoo claim).
17. **Subagent isolation is the actual value-add.** Subagents that share file reads or context with the main session deliver latency cost without context protection benefit.

### F. MCP servers

18. **The optimal always-on MCP server set is 4-6 servers**, typically including filesystem, GitHub/code-host, git, fetch, and one search server. More than 8 degrades performance and attention.
19. **Per-project MCP enablement (rather than always-on) is the right discipline for servers that touch money, send emails, or move customer data.**
20. **By May 2026 there are 50+ official MCP servers and 150+ community implementations**, with adoption embedded in every major AI coding assistant.

### G. Hooks (the critical sensor layer)

21. **A `PreToolUse` hook on Bash that blocks destructive filesystem operations (rm -rf, chmod -R, recursive xattr) prevents the single most common catastrophic incident in autonomous Claude Code sessions.**
22. **A `PreToolUse` hook scanning `Write` and `Edit` content for secrets (API keys, tokens, .env patterns) prevents the single most common credential-leak incident.**
23. **"Success is silent, failures are verbose"** is the canonical hook discipline. Hooks that print on success degrade signal-to-noise and get ignored.
24. **PostToolUse hooks running typecheck/lint after every Edit are higher-leverage than CI-only checks** for catching errors before they propagate into multiple files.

### H. Permissions

25. **The five permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions) are sufficient for all typical workflows; no sixth mode is missing.**
26. **`--dangerously-skip-permissions` should never be used outside isolated environments** (throwaway VMs, empty repos, containerised CI). Using it on a developer's main machine produces a measurable rate of regret incidents.

### I. Token economics and operational discipline

27. **Converting PDFs to text/markdown before sending reduces token usage by roughly an order of magnitude** (3,000 tokens/page → 200/page, give or take).
28. **The two settings.json env tweaks (`CLAUDE_CODE_DISABLE_1M_CONTEXT=1` and `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80`) deliver an additional ~15-20% token reduction** beyond model routing.
29. **Long Claude Code sessions degrade after 20-30 minutes or a few dozen tool calls.** Context reset with a progress file outperforms autocompact.
30. **A clean reset (kill the context, restart with a progress file) outperforms summarisation-and-continue** on tasks longer than one session.

### J. Adoption levels and progression

31. **Nate Herkelman's five-level model (Enthusiast, Beginner, Intermediate, Advanced, Architect) captures the actual capability progression of Claude users in May 2026.** No level is missing or redundant.
32. **The level-5 (Architect) barrier is psychological, not technical.** The friction is trusting unsupervised autonomous runs, not building them.
33. **Most professional users stall at level 2 or 3** despite having access to all level-5 primitives.
34. **The $5K-15K project value attached to Level 4 (Claude Code with tuned CLAUDE.md and skills) is empirically supported** by reported solopreneur and freelancer revenue, not just Herkelman's claim.

### K. Archetype targeting

35. **The five archetypes used in the guide (knowledge worker, solopreneur, SME, professional services, creative/developer) are a more useful segmentation for harness design than the more common "developer vs non-developer" split.**
36. **SMEs benefit most from a hook-based "human approval before anything sent/paid/posted" gate**, which is the same discipline Anthropic encodes in Claude for Small Business.
37. **Professional services users (lawyers, accountants, doctors, agencies) have a citation-integrity / audit-trail requirement that is qualitatively different from other archetypes**, and CLAUDE.md alone is insufficient to meet it.

### L. Anti-patterns (negative claims to validate)

38. **Bloated CLAUDE.md (400+ lines) measurably degrades model behaviour** compared to a focused 60-line version.
39. **Hoarding MCP servers (>10 always-on) measurably degrades attention** and increases token spend without proportional value.
40. **The most common failure mode for new Claude Code users is treating CLAUDE.md as enforcement**, expecting the model to obey rules deterministically.

### M. Meta-question

41. **By May 2026, has the field's vocabulary for this discipline stabilised on "harness engineering"** (Trivedy, OpenAI, Böckeler), or has Ashri's critique that the term is redundant prevailed?

---

## What I specifically want you to look for

- **Counter-cases.** Anywhere you can find a respected practitioner saying the opposite, surface it.
- **Quantitative claims that don't reproduce.** If the 50% token reduction figure (hypothesis 16) is widely repeated but only one primary source exists, say so.
- **Hypotheses that depend on Claude Code's current implementation** and would break with a future release. Flag these.
- **Hypotheses that are true for developers but not for non-developers**, or vice versa. The doc claims general applicability across five archetypes; test that.
- **Missing hypotheses.** What load-bearing claim should be in the list and isn't?

## What I do not want

- Generic AI safety commentary unrelated to Claude Code configuration.
- Restatement of the hypotheses in different words.
- Listicles of "X tips for Claude Code" without analysis of whether the tips withstand scrutiny.
- Sources behind paywalls cited without a substantive quote.

## END OF PROMPT

---

## After running the research

Save the output to `sBs/harness/validation-runs/{provider}-{YYYY-MM-DD}.md`.

If two providers disagree on a hypothesis's verdict, that hypothesis goes to a tiebreaker pass: a `red-blue-team` round in this repo with Lars + Theo + Felix + the relevant domain agent.

Hypotheses that come back NOT VALIDATED get a strikethrough in `THE-HARNESS.md` plus a footnote with the reason. Hypotheses that come back CONTESTED get a "contested" callout in the relevant section, with a link to the validation run.

The goal is not a clean win. The goal is a guide that survives an honest examination.

Lars Mortensen
For Victor del Rosal
2026-05-15, Westport / Dublin
