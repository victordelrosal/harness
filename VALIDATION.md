# VALIDATION — How this kit was stress-tested

A short public summary of the methodology and the corrections that were folded back into the handbook.

The principle: a guide that has not been adversarially tested is a guess. Three independent deep-research providers were given a 41-hypothesis validation prompt and asked to verdict each one as VALIDATED / PARTIALLY VALIDATED / NOT VALIDATED / CONTESTED / INSUFFICIENT EVIDENCE, with disconfirming evidence weighted equally with confirming evidence.

---

## The methodology

1. **Drafted the handbook.** Built from a curated practitioner reading set (Dan Rosenthal, gceico, Linas Beliūnas, Nate Herkelman, Ruben Hassid, Abhisekh Kumar Sahoo, Hamna Aslam Kahn, Aaron Levie via Platformer) plus independent web research on Anthropic's docs, Böckeler's framework, OpenAI's case study, HumanLayer's 12-factor agents, the December 2025 r/ClaudeAI incident corpus.
2. **Wrote a 41-hypothesis adversarial-validation prompt.** Each hypothesis falsifiable. Required two-plus primary sources from the November 2025 – May 2026 window for VALIDATED status. Disqualified anonymous Medium reposts, AI-generated listicles, vendor marketing as sole evidence.
3. **Ran the prompt across three providers** (Anthropic, OpenAI, Google), in parallel, on the same day.
4. **Compared verdicts.** Where two-plus providers agreed, the verdict held. Where they disagreed, looked at primary sources directly.
5. **Folded corrections back.** Twelve edits applied. Two factual errors fixed. Several overclaims qualified.

---

## What survived (the defensible core)

These hypotheses came back VALIDATED with high confidence across all three providers:

- **Agent = Model + Harness** is dominant practitioner shorthand in May 2026 (Böckeler, Osmani, Trivedy, Hashimoto, OpenAI, HumanLayer).
- **Guides vs Sensors** is the canonical decomposition (Böckeler at Martin Fowler; arXiv literature; Thoughtworks).
- **CLAUDE.md is context, not enforced configuration.** Anthropic docs explicit; widely-known new-user failure mode.
- **Hooks are the only enforced layer** (jointly with `settings.json` deny rules). PreToolUse fires before the permission check; survives `bypassPermissions`.
- **Progressive disclosure works.** Skill libraries above 50 are practical because only the matched skill loads.
- **Skill > MCP when both can do the job.** Anthropic's own complete-guide-to-skills: "Skills are the knowledge layer on top of MCP."
- **Subagent isolation is the value driver.** Subagents that share file reads with the main session deliver no benefit.
- **MCP scale.** The public registry expanded from 1,200 (Q1 2025) to 9,400+ (April 2026). Adoption universal across major AI coding assistants.
- **The catastrophe-prevention hooks** (PreToolUse on Bash to block destructive ops; PreToolUse on Write/Edit to scan for secrets). December 2025 r/ClaudeAI `rm -rf ~/` incident is the canonical reference.
- **PostToolUse typecheck/lint > CI-only.** Anthropic best-practices doc: "the single highest-leverage thing you can do" is give Claude a way to verify its own work.
- **`--dangerously-skip-permissions` only in isolated environments.** Anthropic ships a devcontainer specifically for this.
- **Cross-session reset > summarise.** `/clear` with a progress file outperforms autocompact for tasks spanning sessions.
- **CLAUDE.md size discipline.** Anthropic's in-product warning fires at 40 KB (~400 lines).
- **Treating CLAUDE.md as enforcement is the most common new-user failure.** Pixelmojo, Mohit Aggarwal, GitHub issues.
- **MCP hoarding (>10 always-on) degrades attention and increases token spend.** Quantified by MindStudio at 18,000 token overhead for a standard 5-server stack.

---

## What was corrected

### Factual error 1: a missing sixth permission mode

The original draft listed five permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions). Anthropic shipped a **sixth mode, `auto`**, on 2026-03-24. Sonnet-class classifier mediates approvals. Plan-gated (Max, Team, Enterprise, API). Positioned as the middle path between `acceptEdits` and `bypassPermissions`.

**Found by:** Anthropic and Google passes (independent).
**Fix:** the handbook now lists six modes.

### Factual error 2: the full permission-control pipeline

The handbook said "Deny → Ask → Allow is the canonical permission precedence." That is right for the permission rules themselves, but it is not the full control pipeline.

The full pipeline is **Hooks → Deny → Allow → Ask → Mode.** PreToolUse hooks run first and can block before any permission rule fires.

**Found by:** Anthropic pass.
**Fix:** the handbook now states the deny-ask-allow shorthand for the permission system and the full pipeline as a footnote.

### Overclaims qualified

- **50% token reduction from model routing.** Qualified to **40-70% on research/exploration tasks; can be negative ROI on small mechanical tasks** (KDnuggets: "subagents are not automatically cheaper").
- **$5K-15K project value at Level 4.** Replaced with **"reported four- to low-five-figure project values per engagement, with wide variance; single-practitioner data, not a base rate."**
- **Herkelman five-level model captures user progression.** Qualified as **"Herkelman's framing, useful but not community-canonical."**
- **The two env-var tweaks.** Qualified as **"version-fragile; verify against current docs before relying on them."**
- **20-30 minute session degradation.** Replaced with **"context fill at ~60-70% is the practical degradation point; time is a proxy."**
- **Five archetypes more useful than developer/non-developer.** Framed as the **kit's own pedagogical segmentation, not community-canonical**, though WorkOS and Dua Asif independently distinguish Marketing/Dev and PM/Engineer stacks.

### Missing hypotheses surfaced

Hypotheses that the handbook should add or strengthen, surfaced by the validation passes:

1. **Sandboxing via Anthropic devcontainer.** The single most consequential safety decision. Added.
2. **Auto mode (the sixth permission mode).** Added.
3. **Plugins, slash commands, git worktrees** as load-bearing primitives. Added as a footnote to the seven-layer table.
4. **Context rot as the binding constraint.** Strengthened; chosen as the framing for the 20-30 minute correction.
5. **Skill and MCP supply-chain risk.** Added as anti-pattern #11. Anthropic's own skills docs warn about malicious skills.
6. **Attention budget per tool call.** Surfaced by the Google pass: modular rules get re-injected on every tool result, creating a hidden token tax. Acknowledged in the discussion of MCP overhead; deserves a fuller treatment in v0.2 of this kit.

---

## How disagreement was handled

Where the providers disagreed, the higher-evidence verdict won. The Anthropic pass was the most rigorous (24+ distinct URLs cited, four arXiv papers, explicit budget honesty). The Google pass was second (numbered footnote system, strong tables, fewer counter-cases). The OpenAI pass was thinnest (24 numbered footnotes, frequent "INSUFFICIENT EVIDENCE" verdicts that read more like "did not look hard" than "looked and could not find").

This is not a fixed ranking. It is one day's observation. Re-run the prompt next quarter; rotate providers; see what shifts.

---

## What this means for you, the reader

Use the handbook. The defensible core is real. The corrections are folded in. But assume the kit will be wrong about something specific the day you use it: a tool-name will have changed, a flag will have been deprecated, a deny rule will have been improved by Anthropic. Read with a sceptical eye. Open an issue when you find a real divergence between this kit and your live experience. The Ratchet Principle applies to this kit too: every reported failure becomes a tighter rule next release.

The validation prompt itself is reproducible. The full prompt, the three raw outputs, and the synthesis are in the [`docs/validation/`](docs/validation/) folder if you want to run your own pass.

---

Lars
15 May 2026
