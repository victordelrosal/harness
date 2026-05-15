# HARNESS

**The definitive Claude Code configuration kit for the top 1% of users.**

> *Agent = Model + Harness. The model is intelligence. The harness is everything else. Build the harness.*

HARNESS is an open kit of working configurations, hooks, skills, and documents for getting Claude Code to do reliable, repeatable work. It is opinionated, evidence-tested, and built backwards from real failures rather than forwards from wishful features.

The kit is for the user who has felt the gap between *Claude can do this* and *Claude does this for me every Tuesday*. It exists because that gap is a configuration problem, not a model problem, and configuration is the part you control.

## What is inside

| File | What it is | Read time |
|---|---|---|
| [`HANDBOOK.md`](HANDBOOK.md) | The full-length practitioner's guide. Seven layers, five archetypes, the 80/20 hacks. | 25 min |
| [`GETTING-STARTED.md`](GETTING-STARTED.md) | Six-week build path. One layer per week. | 8 min |
| [`CHEAT-SHEET.html`](CHEAT-SHEET.html) | Single-page printable. Pin to your wall. | 2 min |
| [`THEORY.md`](THEORY.md) | What a harness is and why it matters. Cross-checked against Böckeler, Osmani, Trivedy, Anthropic. | 12 min |
| [`VALIDATION.md`](VALIDATION.md) | How this kit was stress-tested against three independent deep-research passes. The disconfirming evidence we found. | 8 min |
| [`starter-kit/`](starter-kit/) | Working files. CLAUDE.md template, settings.json with deny-list, two PreToolUse hooks, four subagents. Drop into `~/.claude/`. | Drop-in |

## Five-minute version

1. **Memory.** Write a `~/.claude/CLAUDE.md` under 30 lines. Identity, style, paths, behaviour. *Context, not enforcement.*
2. **Skills.** Build seven skills for the workflows you run weekly. Skill the second time you do something, not the third.
3. **Hooks.** Install two PreToolUse hooks (`starter-kit/hooks/fs-guard.sh`, `starter-kit/hooks/secret-scan.sh`). These are the only enforced layer. The model cannot skip them.
4. **Permissions.** Build a deny list before any allow list. Deny rules survive `--dangerously-skip-permissions`. They are your safety net.
5. **Subagents.** Plan, Explore, code-reviewer, general-purpose. Four agents, ~80% coverage. Route to cheaper models inside them.
6. **MCP.** Four to six servers always-on. Per-project for anything touching money, email, or customer data.
7. **Statusline.** Show model, context-remaining, cost, mode. The dashboard.

Everything else in the handbook earns its place from one of these seven.

## How HARNESS was built

This kit is the production of a single working session on 15 May 2026, then stress-tested the same day. The process:

1. Read Victor del Rosal's last 10 bookmarked Claude Code articles (Dan Rosenthal, gceico, Linas Beliūnas, Nate Herkelman, Ruben Hassid, Abhisekh Kumar Sahoo, Hamna Aslam Kahn, Aaron Levie).
2. Independent web research on Anthropic's docs, Böckeler's Guides vs Sensors framework, the OpenAI harness-engineering essay, HumanLayer's 12-factor agents, the December 2025 r/ClaudeAI incident corpus.
3. Drafted the long-form handbook.
4. Wrote a 41-hypothesis adversarial-validation prompt.
5. Ran the prompt across three deep-research providers (Anthropic, OpenAI, Google).
6. Folded their disconfirming evidence back into the handbook. Twelve corrections applied. Two factual errors fixed. Several overclaims qualified.
7. Published.

Authoring: a team of AI agents working as a panel. **Lars** led the framing and academic rigour. **Theo** built the engineering primitives, hooks, and starter kit. **Felix** ran the security review and locked the deny list. **Rian** shaped the positioning and the landing-page copy. Human direction by Victor.

The full validation appendix is at [`VALIDATION.md`](VALIDATION.md).

## What this is not

- Not affiliated with Anthropic.
- Not a replacement for the Claude Code docs. Read them. This kit assumes you have.
- Not a course. You learn by configuring, not by reading.
- Not a one-size guide. Five archetypes are profiled (knowledge worker, solopreneur, SME, professional services, creative/developer). Pick yours.
- Not finished. PRs welcome; failures observed become rules in the deny list.

## Licence

MIT. Use it, fork it, ship better versions. Open issues for disconfirming evidence — the kit improves by being wrong about something specific.

## Credits

Built by Lars, Theo, Felix, and Rian, for Victor del Rosal.
Stress-tested against Anthropic, OpenAI, and Google deep-research passes.
Made in Westport, Ireland. May 2026.
