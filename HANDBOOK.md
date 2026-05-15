# HARNESS — Handbook

**The definitive Claude Code configuration guide for the top 1% of users.**

Authored 15 May 2026 by **Lars** (framing and rigour), **Theo** (engineering primitives), **Felix** (security review), **Rian** (positioning). Built from a curated practitioner reading set, then independently web-researched against Anthropic's docs, Böckeler's Guides vs Sensors framework, the OpenAI harness-engineering essay, HumanLayer's 12-factor agents corpus, and the December 2025 r/ClaudeAI incident set.

**Stress-tested the same day** against three independent deep-research passes (Anthropic, OpenAI, Google). Twelve corrections applied. Two factual errors fixed (a missing sixth permission mode; the full permission-control pipeline). Several overclaims qualified. The defensible core (harness frame, Guides vs Sensors, hooks-as-enforcement, deny-rule supremacy, progressive disclosure, subagent isolation, the catastrophe-prevention hooks, cross-session reset > summarise) survives intact.

For the conceptual foundation, read [`THEORY.md`](THEORY.md) first. For the six-week build path, read [`GETTING-STARTED.md`](GETTING-STARTED.md). For the public validation appendix, read [`VALIDATION.md`](VALIDATION.md). This document is the long-form *how*.

---

## 0. Why this exists, and why it is a harness

**Agent = Model + Harness.** The model is raw intelligence. The harness is everything wrapped around it that turns intelligence into reliable, repeatable work. Claude Code itself is a harness around Claude. What sits *inside* Claude Code (your `CLAUDE.md`, your skills, your hooks, your MCP servers, your subagents, your settings.json) is your personal harness, built on top of Anthropic's.

The single most important claim in the field, attributed to Addy Osmani:

> A decent model with a great harness beats a great model with a bad harness.

Corollary, from HumanLayer:

> It is not a model problem. It is a configuration problem.

What follows is the configuration. The framing is Birgitta Böckeler's Guides vs Sensors (see `README.md` section 4). The patterns are pulled from working practitioners in May 2026, not vendor marketing.

A note on vocabulary, since validation surfaced this: "harness engineering" has stabilised as practitioner shorthand by May 2026 but it has not displaced "context engineering". Leading practitioners (HumanLayer, Louis Bouchard, the arXiv "Context Engineering 2.0" line of work) explicitly position harness engineering as a *subset* of context engineering — prompt engineering → context engineering → harness engineering, as concentric layers. This guide uses the harness vocabulary throughout because it is the most useful frame for configuration work, but the discipline is layered, not consolidated.

**The test for every line below:** does this make the human more capable, or more dependent? If a configuration choice only works because Claude is running, it is dependency. If it leaves you, the user, with better systems, better instincts, and cleaner thinking when the agent is off, it is capability. Build for capability.

---

## 1. The five archetypes

The top 1% is not one user. It is at least five, and the right harness depends on which you are. Pick your primary; layer the others as you grow.

| Archetype | Primary work | What they actually need from Claude Code |
|---|---|---|
| **Knowledge worker** (analyst, researcher, consultant) | Synthesis, briefs, decks, internal memos | Reliable retrieval, citation discipline, document drafting, structured output. Light code. |
| **Solopreneur** (one-person business, IndieHacker, AE) | Shipping product + content + ops, alone | A multiplier across stacks: web, copy, ops, finance. Skills > heroics. |
| **SME** (5-50 people, no dedicated AI team) | Repeatable workflows that survive staff turnover | Governance, permissions, shared skills, human approval gates. |
| **Professional services** (lawyer, accountant, designer, doctor, architect, agency) | Client deliverables under quality + confidentiality constraints | Templates, citation integrity, audit trail, data containment. |
| **Creative / developer** (engineer, writer, designer, researcher) | Building things others use | Plan mode, subagents, hooks, plugins, headless mode, long-running runs. |

The harness primitives are the same. The dial settings differ. Where a section below splits by archetype, that is why.

---

## 2. The seven layers of a Claude Code harness

This is the anatomy. Everything in the rest of the guide attaches to one of these.

| # | Layer | Type | What it does | Where it lives |
|---|---|---|---|---|
| 1 | **Memory** (CLAUDE.md hierarchy) | Guide | Persistent context. Who you are, project conventions, hard rules. | `~/.claude/CLAUDE.md`, `./CLAUDE.md`, `CLAUDE.local.md` |
| 2 | **Skills** | Guide | Reusable recipes loaded on-demand by trigger phrase. | `~/.claude/skills/*/SKILL.md` |
| 3 | **Subagents** | Guide + Orchestration | Isolated, parallel sessions with their own context. | `~/.claude/agents/*.md` |
| 4 | **MCP servers** | Tools | External system integrations (Gmail, GitHub, Linear, Slack, Stripe). | Server config + auth |
| 5 | **Hooks** | Sensor | Deterministic scripts on lifecycle events. The only enforced layer. | `.claude/settings.json` + `hooks/*.sh` |
| 6 | **Permissions** | Sensor | Allow / ask / deny rules. Deny always wins. | `.claude/settings.json` |
| 7 | **Statusline + output styles** | Observability | What you see while it runs. Cost, model, context remaining. | `.claude/statusline.sh` |

A bare Claude Code install has none of these tuned. A top-1% setup tunes all seven. The order matters: do them in this sequence. Each one delivers value before you start the next.

*Note on the seven layers.* This decomposition is pedagogical, not exhaustive. By May 2026, three further load-bearing primitives exist that this guide does not give their own row: **plugins** (single-command installable bundles of slash commands + skills + hooks + agents, see `/plugin` and the official marketplace), **slash commands** (project-scoped command shortcuts in `.claude/commands/`), and **git worktrees** (isolated parallel agents working in separate git trees on the same repo). They compose with the seven layers; if you need them, they exist. The seven below are the architectural backbone.

**Critical distinction (burn it in):**
- Layers 1-4 are **guides**. They advise. The model decides whether to honour them.
- Layer 5 is the **sensor / enforcer**. Hooks bind. Hooks are the only place where you get deterministic behaviour.
- Layer 6 is the **gate**. Deny rules always run, even under `--dangerously-skip-permissions`.

Most setups are guide-heavy and sensor-light. That is the pattern of an immature harness. The leverage is in the sensors.

---

## 3. Layer 1: Memory. The CLAUDE.md hierarchy

Three files, three scopes, one loading order.

```
~/.claude/CLAUDE.md           Global. Loaded for every project on this machine.
./CLAUDE.md                   Project. Loaded for this repo. Source-controlled.
./CLAUDE.local.md             Personal. Loaded for this repo. Gitignored.
```

**Rules that hold across archetypes:**

1. **Keep global under 30 lines.** Everything you'd repeat across every project. Identity, hard prohibitions, path shortcuts, writing-style rules. If it belongs to a specific project, it does not belong here.
2. **Project file is the team contract.** Source-controlled. Reviewed in PRs. Conventions, coding style, deploy steps, the things a new teammate (or a new Claude session) needs on day one.
3. **`CLAUDE.local.md` is your personal layer.** Gitignored. Personal tone, your preferred shortcuts, paths only on your machine.
4. **CLAUDE.md is not configuration. It is context.** A rule here is read and *usually* honoured. If you need it enforced, write a hook (layer 5). Repeat this sentence to yourself until you stop being surprised when Claude ignores a CLAUDE.md instruction. The field calls this the *compact test*: an immature harness relies on the model remembering discipline; a mature harness makes discipline part of the environment.
5. **Length kills.** Files over ~60 effective lines degrade. The model reads everything, but its attention divides. Aggressive concision beats encyclopaedic coverage.

**Archetype dial:**

- *Knowledge worker / professional services:* CLAUDE.md is your style sheet. Voice rules, citation discipline, never-do list, output format defaults.
- *Solopreneur:* CLAUDE.md is your operating manual. Path shortcuts, brand voice, "I am one person, default to the minimum viable thing."
- *SME:* CLAUDE.md is shared culture. Source-controlled. Treated like a coding standard.
- *Developer:* CLAUDE.md is a `tldr` of the repo. Architecture in one paragraph, key commands, key gotchas.
- *Creative:* CLAUDE.md is a taste reference. What you find ugly, what you find clean, links to your reference projects.

**Concrete starter (paste into `~/.claude/CLAUDE.md`):**

```markdown
## Identity
I am [role], primary work is [domain]. Optimise for capability, not output.

## Writing style
- Never use em dashes. Use colons, semicolons, commas, parentheses.
- Default to succinct. No preamble. No trailing summary.

## Path shortcuts
- work = /Users/me/work
- archive = /Users/me/work/archive

## Behaviour
- Match scope. A bug fix does not need refactoring. A note does not need a doc.
- For exploratory questions, 2-3 sentences with a recommendation. Do not implement without agreement.
- Verify before claiming work is done. Evidence over assertion.
```

That is enough. Resist the urge to add more until you have actually felt the lack.

---

## 4. Layer 2: Skills. The system that prompts for you

Linas Beliūnas' framing, sharper than Anthropic's own marketing:

> The best AI users today don't prompt better. They build systems that prompt for them.

A skill is a folder containing a `SKILL.md` with a YAML header (a name, a description, optional trigger hints, optional tool allowlist). Claude auto-discovers all installed skills, and when a request matches a skill's description, that skill's instructions are loaded into context. This is **progressive disclosure**: only the relevant skill loads, so 80 installed skills do not bloat your context.

**Why this changes everything for top-1% users:**

Without skills, your best workflows live in your head. You explain them every time. With skills, your best workflows are reified. The marginal cost of a 15th-time-doing-it drops to near zero. **A skill is a workflow that earns interest.**

**Anatomy:**

```markdown
---
name: write-client-brief
description: Use when drafting a client engagement brief. Triggers on "brief for {client}", "write a brief", "scope this engagement".
---

# Write Client Brief

When invoked:
1. Ask for the client name if not given.
2. Read the client file at `clients/{name}.md`.
3. Use the template at `templates/brief.md`.
4. Sections: Context, Scope, Out of scope, Deliverables, Timeline, Investment, Next step.
5. Save to `engagements/{date}-{client}-brief.md`.
6. Never invent budget figures.
```

That is a skill. It is fifteen lines. It will save you the next 200 briefs.

**The build heuristic:**

After you finish any task, ask: *did I just walk through a process I will repeat?* If yes, turn it into a skill **the second time**, not the third. The cost of writing a skill is 15-30 minutes. The cost of explaining the workflow 50 more times is hours.

**Anthropic's own meta-skill** (`skill-creator`) builds skills from a description. Use it. It scaffolds the YAML header, suggests trigger phrases, and writes the first draft.

**Archetype starter sets:**

- *Knowledge worker:* `summarise-pdf`, `compare-positions`, `compile-bibliography`, `write-brief`, `draft-email`, `convert-to-deck`.
- *Solopreneur:* `pitch-page`, `linkedin-post`, `invoice`, `client-onboarding`, `social-card`, `weekly-review`.
- *SME:* `handle-customer-complaint`, `prep-monthly-numbers`, `onboard-new-hire`, `draft-supplier-email`, `compile-board-pack`.
- *Professional services:* `case-memo`, `client-letter`, `compliance-check`, `audit-trail-entry`. With strict citation rules in the skill body.
- *Developer:* `add-feature`, `fix-bug`, `migrate-schema`, `write-tests`, `pr-description`, `release-notes`.
- *Creative:* `mood-board`, `treatment`, `style-guide`, `pitch-deck`, `cover-brief`, `editorial-pass`.

**Rule of seven:** seven good skills outperform seventy half-finished ones. Build the seven that cover 80% of your week, then stop. New ones come from real friction, not anticipation.

**Skill > MCP, when in doubt.** The mantra from Beliūnas:

> MCP gives Claude the tools. Skills give it the recipe.

Skills compose tools you already have into a workflow. Skills are cheap. MCP servers are heavier (auth, scopes, network). Reach for a skill first.

---

## 5. Layer 3: Subagents. Isolated context, parallel work

A subagent is a markdown file at `~/.claude/agents/{name}.md` with YAML frontmatter (name, description, prompt, tools allowlist, model, permission mode). When you invoke a subagent, Claude Code spawns a new session with its own context window, runs the agent against your task, and returns a summary to your main session.

**Two uses, both important:**

1. **Context protection.** A research task that would otherwise read 50 files lives in the subagent. The main session gets a 200-word summary. Your context survives.
2. **Parallelism.** Three independent tasks dispatched as three concurrent subagents finish in roughly the time of one. The `dispatching-parallel-agents` superpower is the practitioner's discipline here.

**Default subagent set worth installing first day:**

- `Explore` — read-only search agent for "where is X defined / which files reference Y".
- `Plan` — software-architect agent that returns a step-by-step plan, never edits.
- `code-reviewer` — independent review against the plan + your standards.
- `general-purpose` — catch-all for multi-step research you don't want polluting main context.

These four cover 80% of subagent use. Add specialist agents (`marker`, `red-team`, `negotiator`) as you build skills around them.

**Model routing inside subagents** is the highest-leverage cost optimisation in Claude Code. From Abhisekh Kumar Sahoo:

> Spawn subagents and pick the cheapest model that can handle the job. Haiku for bulk mechanical work, Sonnet for research and synthesis, Opus exclusively for complex planning requiring tradeoffs. Haiku never spawns subagents. Maximum spawn depth: 2.

Configure this in your CLAUDE.md or in each agent's frontmatter. Reported savings on research and exploration tasks: typically 40-70% of main-thread tokens (ComputingForGeeks, ClaudeCodeLab, Product Compass all report figures in this range). On small mechanical tasks the subagent overhead can exceed the saving (KDnuggets: "subagents are not automatically cheaper"). The discipline: route to cheaper models when the task is genuinely token-heavy; use the main session for short tasks.

---

## 6. Layer 4: MCP servers. Tools, not recipes

MCP (Model Context Protocol) lets Claude Code call external systems: Gmail, GitHub, Linear, Slack, Stripe, Notion, your database, your CRM.

**The wrong question:** which MCP servers should I install? (Answer in 2026: there are 50+ official and 150+ community ones. You will install too many.)

**The right question:** what real friction in my week could a tool integration eliminate? Install MCP servers backwards from observed friction, never forward from a list.

**Practitioner consensus on the always-on set (4-6 servers):**

- **Filesystem** — read/write outside the working dir when you need it.
- **GitHub** (or your code host) — issues, PRs, code search, releases.
- **Git** — local git ops, often via Bash but the MCP is faster for review.
- **Fetch / WebFetch** — public web content. Cheap. Text-only.
- **One search server** — Perplexity, Brave Search, or similar.

Everything else goes behind a per-project enable flag. Mental model: the always-on set is your kitchen. Project-specific servers are the special tools you take out of the drawer.

**Archetype-specific picks (load only when relevant):**

- *Knowledge worker:* Gmail, Google Drive / Calendar, Notion, Slack.
- *Solopreneur:* Stripe, Linear, Resend / Cloudflare Email, GitHub, Vercel / Cloudflare.
- *SME:* QuickBooks, HubSpot, DocuSign, Microsoft 365 / Google Workspace.
- *Professional services:* DocuSign, your DMS, your case-management system, Outlook.
- *Developer:* Playwright (browser testing), Postgres / your database, Sentry, Vercel.
- *Creative:* Figma, Canva, YouTube, Notion, Drive.

**Two rules that prevent the common failure modes:**

1. **Auth scope minimisation.** Every MCP server gets the least privilege that does the job. If a server only needs read access, do not give it write. The default is too generous.
2. **Per-project enable.** Servers that touch billing, send emails, or move money should be off-by-default and explicitly enabled per project. The MCP install is fast; the regret is not.

---

## 7. Layer 5: Hooks. The only layer the model cannot ignore

Hooks are shell commands that run on lifecycle events. They run in the harness, not in the model. The model cannot skip them. This is the only place in Claude Code where you get **enforced** behaviour rather than advised behaviour.

The events you care about most:

| Event | When it fires | What it is for |
|---|---|---|
| `SessionStart` | New session | Load context, set environment, inject identity, sync inbox. |
| `UserPromptSubmit` | User hits enter | Inject persona, expand shortcuts, gate certain phrases. |
| `PreToolUse` | Before any tool call | Permission gates. Block dangerous paths. Scan for secrets. |
| `PostToolUse` | After a tool call | Auto-format, type-check, log to telemetry. |
| `Stop` | End of assistant turn | Mirror replies to chat, capture insights, commit. |

**Configure in `.claude/settings.json`:**

```json
{
  "hooks": {
    "PreToolUse": [
      { "match": { "tool": "Bash" }, "command": "~/.claude/hooks/fs-guard.sh" },
      { "match": { "tool": "Write" }, "command": "~/.claude/hooks/secret-scan.sh" }
    ],
    "PostToolUse": [
      { "match": { "tool": "Edit" }, "command": "~/.claude/hooks/format.sh" }
    ]
  }
}
```

**The two hooks worth writing on week one** (working versions ship with this kit at `starter-kit/hooks/`):

1. **`fs-guard.sh`** — blocks any Bash command that would `rm`, `chmod -R`, `xattr`, or `touch -r` inside critical paths (Dropbox, `~/Library`, `~/.dropbox`). Catches the cataclysmic mistake before it happens. Hook output: non-zero exit + a one-line reason. Claude reads the reason and explains itself.
2. **`secret-scan.sh`** — on `Write` and `Edit`, scans the new content for API keys, tokens, `.env` patterns. Blocks the write if found. Saves the inevitable "I accidentally committed a key" incident.

The principle the hooks community uses:

> Success is silent. Failures are verbose.

A hook that fires correctly should print nothing. A hook that blocks should print exactly why, in a sentence the model can act on. This is the same discipline as a clean test suite.

**Hooks for non-developer archetypes:**

- *Professional services:* a `PreToolUse` hook on `WebFetch` and `Write` that blocks any URL or path matching client-confidential markers without a confirmation file.
- *SME:* a `Stop` hook that logs every tool call to a SQLite file or Notion. Audit trail without effort.
- *Knowledge worker / creative:* a `PostToolUse` hook on `Write` that runs a linter (a markdown linter, a style checker) on every file written. Free quality control.

The Anubhav guide from April 2026, after six months of tuning, lands on the same conclusion: *hooks are the thing that changed everything*. The model can be steered, but only hooks make discipline part of the environment.

---

## 8. Layer 6: Permissions. The unbypassable safety net

Six modes. Six purposes. (Validation note 2026-05-15: the original draft listed five. The sixth, `auto`, shipped 2026-03-24 and was missed in the first pass. Corrected below.)

| Mode | What it does | When |
|---|---|---|
| `default` | Asks before every consequential action | New repo, unfamiliar work, anything client-facing. |
| `acceptEdits` | Auto-approves file edits; still asks for shell + network | Routine refactoring, long edits, you trust the plan. |
| `plan` | No edits at all. Returns a plan. | Exploration, design discussion, before any irreversible work. |
| `auto` *(added 2026-03-24, plan-gated: Max, Team, Enterprise, API)* | A Sonnet-class classifier judges each tool call. Approves the safe ones, asks on the consequential ones, blocks the dangerous ones. | The middle path between `acceptEdits` and `bypassPermissions`. Default choice if your plan supports it and you want to reduce prompt fatigue without going full YOLO. |
| `dontAsk` (`--dangerously-skip-permissions`) | Runs end-to-end | Isolated environments. Throwaway VMs. Never on prod. |
| `bypassPermissions` | Like above, deny rules still run | Containerised runs. CI. Headless. |

**Rules:**

1. **Deny → Ask → Allow.** First matching rule wins. Deny always beats everything else. This is the one safety control that fires even in `dontAsk` mode, which is what makes it the safety net rather than a suggestion. (Full control pipeline, for completeness: **Hooks → Deny → Allow → Ask → Mode**. PreToolUse hooks run earliest and can block before any permission rule fires. For day-to-day reasoning the deny → ask → allow shorthand is enough.)
2. **Build your deny list first.** Before any allow list, write the rules for what must never happen. Examples: `Bash(rm -rf *)`, `Bash(git push --force *)`, `Write(.env*)`, `Bash(*--no-verify*)`. The deny list is short, durable, and survives every refactor.
3. **Build your allow list from observation.** Every time Claude asks for permission for the same command twice, that is a candidate for the allow list. Use the `fewer-permission-prompts` skill (if installed) to scan transcripts and propose a prioritised allow set.
4. **Settings layering.** `~/.claude/settings.json` is your global rules. `.claude/settings.json` (project) is the team contract. `.claude/settings.local.json` is your local overrides (gitignored). Discipline: don't put project rules in global. Don't put personal rules in project.

**The `--dangerously-skip-permissions` rule** that the field has converged on:

> Use it only in environments you would not cry over. A throwaway VM, an empty repo, a sandbox. Never on your real machine, never on shared infra, never with a Dropbox folder you love.

The canonical case studies for why: the December 2025 r/ClaudeAI `rm -rf ~/` home-directory wipe (Simon Willison amplified, 197 HN points) and GitHub Issue #12637 from November 2025, a tilde-directory expansion bug that wiped a developer's home dir via `rm -rf *`. Thomas Wiegold catalogues both at thomas-wiegold.com.

**Anthropic ships an official devcontainer** specifically to make `--dangerously-skip-permissions` safe. Network-firewalled, filesystem-scoped, disposable. If you want autonomous runs without the catastrophe risk, use the devcontainer; do not run unsupervised on the host. The setup is in Anthropic's devcontainer docs and is the canonical Architect-level (level 5) sandbox.

The starter kit's `settings.json` ships with these deny rules pre-wired. Most setups have nothing here. Fix that on day one.

---

## 9. Layer 7: Statusline + output styles. What you see while it runs

A statusline is a custom one-liner shown at the bottom of your terminal during a Claude Code session. It is the dashboard.

The fields that earn their slot (from the Felipe Elias guide and the AKCodez fields catalogue):

- **Current model** — Opus / Sonnet / Haiku. Non-negotiable. Tells you how aggressively to ask.
- **Context remaining** — percentage left in the window. Lets you decide when to context-reset (see `HARNESS-PATTERNS.md` section 3).
- **Cost so far** — total spend this session. Calibrates your appetite for risk.
- **Working directory** — short form. Confirms you are where you think you are.
- **Mode** — `default` / `acceptEdits` / `plan` / `bypass`. The most common silent footgun is being in the wrong mode.

Implementation: a shell script that reads JSON on stdin (session state) and prints one line. Configured in `~/.claude/settings.json` under `statusline`.

**Output styles** are a sibling primitive: they shape *how* the assistant writes (terse, expansive, plain prose, with bullets, etc.). Most users do not need a custom one. Set the default to terse in your CLAUDE.md and move on.

---

## 10. The 80/20 hacks

These are the moves that deliver outsized value before you have built any of the seven layers properly. Cross-referenced from Ruben Hassid's 21 hacks, Abhisekh Kumar Sahoo's three, gceico's eight, and Anthropic's own power-user tips.

**Tier 1: the four no-brainers, do this week.**

1. **Convert PDFs to text or markdown before sending.** A 50-page PDF at 3,000 tokens/page is 150K tokens. The text equivalent is closer to 30K. Use `pdftotext path.pdf -` from Bash. Or markdown via a converter.
2. **Skill the second time you do something.** If you find yourself explaining a workflow you have explained before, stop, write the skill, then proceed. You will lose ten minutes once and save them every week thereafter.
3. **Move from autocompact to checkpoint reset.** Long sessions degrade. The `HARNESS-PATTERNS.md` evidence: at 20-30 minutes / few dozen tool calls, agents start repeating themselves. Solution: write a progress file, kill the context, start fresh. Do not summarise and continue.
4. **Run the cheapest model that can do the job.** Configure model routing in your CLAUDE.md so subagents default to Haiku for mechanical work, Sonnet for synthesis, Opus only for tradeoffs. 50% cost reduction is a conservative figure.

**Tier 2: the eight underrated config files (from gceico):**

1. `INDEX.md` at the repo root. Map of the codebase. Every package, every entry point, every owner.
2. `CLAUDE.local.md` for personal overrides, gitignored.
3. `specs/<feature>.md` for feature-specific requirements, design, tasks. Timestamp them like migrations.
4. `.claude/rules/` for path-scoped behaviour. Different rules in `/api/**` vs `/frontend/**`.
5. `.claude/settings.json` with a tight allow list of pre-approved bash commands. Kills the constant approval prompts.
6. `.claude/settings.local.json` for personal command pre-approvals. Promote from local to project as the team converges.
7. `.claude/hooks/` for deterministic pre-push gates. Replaces husky.
8. `tests/<file>.test.ts` because tests are the only sensor that catches behavioural regressions.

**Tier 3: the operational discipline (from the $20-plan playbook):**

- Concise prompts. 29 words beats 500. Use `AskUserQuestion` when you genuinely need info, not as filler.
- Targeted edits. "Only redo section 3" not "rewrite this".
- Batch tasks. Three related requests in one message; the model plans across them.
- Edit, don't stack. Re-run from an earlier message instead of piling on corrections.
- Topic separation. New chats for new topics. Context bleed is real.
- Feature toggles off by default. Connectors, web search, MCP servers: enable per task.
- Voice input for richer single prompts. The transcribed prompt carries more nuance than typed.

**Tier 4: the two settings.json env tweaks (Abhisekh):**

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_1M_CONTEXT": "1",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80"
  }
}
```

The first prevents loading the 1M context window when you do not need it (most sessions). The second triggers auto-compaction at 80% instead of waiting until the window is full and broken. Reported additive effect: another ~15-20% token reduction.

**Version-fragility caveat.** Neither environment-variable name was directly verifiable in Anthropic's current docs during validation. The Claude Code surface evolves quickly; settings names that worked in one minor version are sometimes renamed or removed in the next. Verify against your installed version (`claude --help`, the Anthropic settings docs, or `update-config` skill) before relying on these. The underlying principle (cap context size, force earlier compaction) is durable; the specific knobs may shift.

---

## 11. The five levels of Claude (Herkelman's framing)

Nate Herkelman's five-stage progression is widely shared and pedagogically useful. It is not community-canonical; competing taxonomies exist (Anthropic's "Claude Certified Architect" exam domains carve the space differently). Treat it as one practitioner's map, not consensus terminology. The recast below ties each level to a specific configuration milestone, so you know what to build next.

| Level | Name | Configuration milestone | Capability unlock |
|---|---|---|---|
| 1 | **Enthusiast** | Account + browser tab | Ask anything in chat. Stateless. |
| 2 | **Beginner** | Projects + connectors | Memory across sessions. Slack/Drive integration. Hours saved per week. |
| 3 | **Intermediate** | Claude Cowork (or Claude for Small Business) | File-system access. Workflow automation with human approval gates. |
| 4 | **Advanced** | Claude Code + tuned CLAUDE.md + skills | Parallel sessions. Multi-agent flows. Reported four- to low-five-figure project values per engagement, with wide variance; single-practitioner data, not a base rate. |
| 5 | **Architect** | Headless mode + hooks + scheduled routines + devcontainer sandbox | Autonomous overnight runs. Reviewing PRs at 2am. No human in the loop on the routine; humans only on exception. |

**The level-5 barrier has both technical and psychological components.** Validation surfaced the original "purely psychological" framing as overclaim. Building a robust autonomous setup (worktrees, hooks, sandboxing, devcontainers, progress files, telemetry) is non-trivially technical *and* trusting it requires earned confidence. Neither barrier alone is sufficient. The harness pattern that gets you across is the same one that lets you trust a junior staffer: a deny list that prevents catastrophe, hooks that audit every action, the Anthropic devcontainer for the sandboxed execution layer, and a clear exception path so you only get woken up when something genuinely needs you.

**Most professionals appear to stall at level 2 or 3** based on anecdote and forum reports, but this is not survey-supported and should be treated as plausible rather than measured. What is clear: they get value, but they stop before they have built the configuration that unlocks the rest. The harness is the difference between "I use Claude sometimes" and "Claude does my Tuesday".

---

## 12. The archetype quick-start

If you read nothing else, build this.

### Knowledge worker (analyst, researcher, consultant)

Week 1:
- Global CLAUDE.md with voice rules + citation discipline. <30 lines.
- Three skills: `write-brief`, `summarise-source`, `convert-to-deck`.
- MCP: Filesystem + Fetch + (Google Drive OR Notion).
- Subagent: `Explore` for find-and-cite work.

Sensor on day one: a `PreToolUse` hook on `WebFetch` that logs every URL fetched to a `~/.claude/sources.log`. Free citation audit trail.

### Solopreneur

Week 1:
- Global CLAUDE.md with brand voice + "I am one person" rule.
- Five skills: one for each repeatable: invoice, weekly review, social post, client email, pitch update.
- MCP: GitHub + Stripe + Resend (or Cloudflare Email).
- Statusline showing cost. You feel the spend.

Sensor on day one: a `Stop` hook that appends "what shipped today" to a daily log. End-of-week review writes itself.

### SME

Week 1:
- Project CLAUDE.md in source control. Approved by whoever owns standards.
- Shared `.claude/skills/` checked into the repo. The team's workflows are versioned.
- MCP: per-project enable. Nothing global except filesystem.
- Permissions: a deny list for anything financial, anything customer-facing without human approval.

Sensor on day one: `PreToolUse` hooks on any tool that sends email, moves money, or touches customer data. Each requires an out-of-band confirmation file. This is the *human approval before anything gets sent, paid, or posted* discipline that Claude for Small Business already encodes; you can build the same pattern yourself.

### Professional services

Week 1:
- CLAUDE.md with citation discipline as a hard rule.
- Skills: `case-memo`, `client-letter`, `compliance-check`, plus one templated per practice area.
- MCP: locked-down. Only what you need; nothing that can exfiltrate.
- Permissions: a deny list for any URL not on a client-approved domain list when working on matters.

Sensor on day one: a `PostToolUse` hook on `Write` that stamps every generated document with a hash + timestamp + matter number. Audit trail with zero overhead.

### Developer

Week 1:
- Project CLAUDE.md with arch in one paragraph, commands, gotchas.
- Skills: TDD discipline, `requesting-code-review`, `writing-plans`.
- Subagents: `Plan`, `code-reviewer`, `Explore`, plus one domain-specific (e.g. `migration-writer`).
- Hooks: typecheck + lint on `PostToolUse(Edit)`. Tests on pre-push. The traditional Husky stack moves into Claude Code.

Sensor on day one: a `PreToolUse` hook on `Bash` that blocks `--no-verify`, `--no-gpg-sign`, and `git push --force` to protected branches.

### Creative

Week 1:
- CLAUDE.md with taste reference: brands you love, brands you hate, the one sentence that describes your aesthetic.
- Skills: `mood-board`, `style-guide`, plus one per recurring deliverable.
- MCP: Figma + Drive + one image-gen tool.
- Output style: short prose, no bullet lists in creative drafts.

Sensor on day one: a `PostToolUse` hook on `Write` that runs your tone-of-voice linter. The model is fluent; it is rarely *yours* without a sensor.

---

## 13. Anti-patterns. What top-1% users do not do

1. **Bloated CLAUDE.md.** A 400-line CLAUDE.md is a wishlist, not a contract. Cut to <60 effective lines. Anthropic's own in-product warning fires at 40 KB (~400 lines), and Anthropic's best-practices doc explicitly names "the over-specified CLAUDE.md" as a top anti-pattern. Mohit Aggarwal's measured case: a 340-line CLAUDE.md, Claude missed a rule on line 287; cut to <60 effective lines and the same rule held.
2. **Skills that overlap.** Two skills that fire on similar triggers fight for attention. Pick one canonical skill per workflow.
3. **MCP server hoarding.** Installing every shiny server. Each one consumes context (tool definitions) and attention. Stay at 4-6 always-on.
4. **Subagents that aren't isolated.** If your subagent reads the same files as the main session, you have not protected context, you have only added latency. The whole point of a subagent is its private context.
5. **Hooks that print on success.** A hook that always prints is a hook that gets tuned out. Silent on success; verbose on failure.
6. **Permissions wide-open from day one.** `--dangerously-skip-permissions` everywhere because "the prompts are annoying". This is how the first catastrophe happens. Tune your allow list first; the prompts go away on their own.
7. **Treating CLAUDE.md as enforcement.** A rule in CLAUDE.md is *advice*. If you need enforcement, you need a hook. Refusing to internalise this is the single most common cause of "Claude keeps ignoring my rule".
8. **Building forward, not backward.** Designing for an imagined workflow instead of an observed friction. The harness should be a record of failures you fixed, not features you might want.
9. **Stalling at level 2.** Reaching for connectors and Projects and stopping there. The 100x leverage is on the other side of skills + hooks + subagents.
10. **No context reset protocol.** Long sessions are not endurance trials. Compaction is a fallback; a clean reset with a progress file outperforms it for tasks spanning sessions. Within a single coherent session, /compact remains the right tool. Treat context fill, not wall-clock time, as the variable to watch (~60-70% of the window is the practical degradation point; the original "20-30 minutes" figure was a misleading proxy).
11. **Trusting third-party skills and MCP servers blindly.** With 9,000+ MCP servers registered by April 2026 and a growing community-skills ecosystem, supply-chain risk is real. Anthropic's own skills docs warn that "malicious skills may introduce vulnerabilities". Read any skill or MCP server before installing. Apply auth-scope minimisation to every MCP server. The deny list and PreToolUse hooks are your defence-in-depth.

---

## 14. The capability test

This guide closes the way it opened. Lars's question:

> Is this system making humans more capable, or more dependent?

A configuration choice passes the capability test if, when you cannot run the agent (no power, no API access, no Anthropic, no Claude Code), you are still:

- A clearer thinker, because you wrote down your standards.
- A more disciplined operator, because your hooks taught you what discipline looks like.
- A better delegator, because you learned what to specify and what to leave open.
- A better systems designer, because you have practised it on a system that responds.

If the answer is yes, the harness is good. If the answer is no, you have built a crutch.

---

## 15. The minimum viable harness, in one screen

For the user who reads only this section.

```
~/.claude/
├── CLAUDE.md                    # <30 lines. Identity, style, paths, behaviour.
├── settings.json                # Deny list. Two PreToolUse hooks. Statusline.
├── skills/
│   ├── one-skill-per-recurring-workflow/
│   │   └── SKILL.md             # YAML header + 10-30 lines of instructions.
│   └── ... (aim for 5-7 total)
├── agents/
│   ├── Plan.md                  # Built-in.
│   ├── Explore.md               # Built-in.
│   ├── code-reviewer.md
│   └── general-purpose.md
└── hooks/
    ├── fs-guard.sh              # Blocks dangerous filesystem ops.
    └── secret-scan.sh           # Blocks committing secrets.

<project>/
├── CLAUDE.md                    # Project conventions. Source-controlled.
├── CLAUDE.local.md              # Your overrides. Gitignored.
├── .claude/
│   ├── settings.json            # Project allow list.
│   └── settings.local.json      # Your personal pre-approvals.
└── INDEX.md                     # Map of the repo.
```

That is the harness. Twelve files. One afternoon. The rest is iteration.

---

## 16. How to use this guide

This is a reference, not a tutorial. Read once. Apply one section per week. Treat each layer as a sprint:

- **Week 1:** memory (layer 1). Write your CLAUDE.md. <30 lines. Commit.
- **Week 2:** skills (layer 2). Build five. Stop. Use them for a week before adding more.
- **Week 3:** permissions + hooks (layers 5-6). Deny list. Two hooks. The hardest week, the highest leverage.
- **Week 4:** subagents + MCP (layers 3-4). Four subagents. Four-to-six MCP servers. Resist the urge to install more.
- **Week 5:** observability (layer 7). Statusline. One log hook. Watch your own usage for a week.
- **Week 6:** review. Read this guide again. Cut what is not pulling weight. Add what observation demands.

The capability test runs throughout. Every week, ask: am I a sharper operator than last week, or am I just leaning harder?

---

## Sources

**Curated practitioner reading set (processed 2026-05-15):**

- Dan Rosenthal — [Optimal GitHub repo structure for Claude Code](https://www.linkedin.com/posts/dan-m-rosenthal_were-a-20-person-ai-native-services-company-share-7459935567636525057-hXac)
- Hamna Aslam Kahn — [My engineering team has used Claude Code since it launched](https://www.linkedin.com/posts/hamna-aslam-kahn_my-engineering-team-has-used-claude-code-share-7460653786039115776-Q_s6)
- Aaron Levie via Platformer — [The best argument I've heard for why AI won't take your job](https://www.platformer.news/ai-job-loss-box-ceo-aaron-levie/)
- Gabriel Ceicoschi (gceico) — [Everyone posts about CLAUDE.md and SKILL.md; here are 8 underrated files](https://www.linkedin.com/posts/gceico_everyone-posts-about-claude-md-and-skill-share-7460004872218685440-cZeK)
- Linas Beliūnas — [Anthropic just launched Claude for Small Business](https://www.linkedin.com/posts/linasbeliunas_anthropic-just-launched-claude-for-small-ugcPost-7460678377218252800-il-n)
- Nate Herkelman — [Every level of Claude explained](https://www.linkedin.com/posts/nateherkelman_every-level-of-claude-explained-ugcPost-7459965635788259328-3FQt)
- Ruben Hassid — [Don't upgrade to the $100 Claude plan yet, these 21 hacks](https://www.linkedin.com/posts/ruben-hassid_dont-upgrade-to-the-100-claude-plan-yet-share-7459622969254809601-yGdy)
- Linas Beliūnas — [Anthropic's guide to Claude Skills](https://www.linkedin.com/posts/linasbeliunas_anthropics-guide-to-claude-skills-ugcPost-7459973840845041664-uoCR)
- Abhisekh Kumar Sahoo — [Cut Claude Code token usage by 50% with 3 simple tweaks](https://www.linkedin.com/posts/abhisekhkumarsahoo_i-cut-my-claude-code-token-usage-by-50-with-share-7458012868643508224-Ytw8)

**Independent research, May 2026:**

- Anthropic — [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices), [Configure permissions](https://code.claude.com/docs/en/permissions), [Customize Claude Code with plugins](https://www.anthropic.com/news/claude-code-plugins), [Introducing Claude for Small Business](https://www.anthropic.com/news/claude-for-small-business)
- Anubhav — [I spent 6 months tuning Claude Code](https://medium.com/data-science-collective/i-spent-6-months-tuning-claude-code-heres-the-exact-setup-that-finally-worked-b41c67628478)
- Bijit Ghosh — [The complete guide to CLAUDE.md](https://medium.com/@bijit211987/the-complete-guide-to-claude-md-memory-rules-loading-and-cross-tool-compression-97cc12ed037b)
- Owen Fox — [Claude Code: Hooks, Subagents, and Skills, complete guide](https://ofox.ai/blog/claude-code-hooks-subagents-skills-complete-guide-2026/)
- Felipe Elias — [claude-statusline: a configurable status line for Claude Code](https://felipeelias.github.io/2026/03/17/claude-statusline.html)
- ObviousWorks — [Designing CLAUDE.md correctly: the 2026 architecture](https://www.obviousworks.ch/en/designing-claude-md-right-the-2026-architecture-that-finally-makes-claude-code-work/)

**Foundational, in this directory:**

- `README.md` — what is a harness, with full citations (Trivedy, Böckeler, Osmani, Anthropic, Willison, Ashri).
- `HARNESS-PATTERNS.md` — long-running agent patterns from Anthropic Engineering.

---

**Closing.** The harness is the part you control. Build it deliberately, prune it ruthlessly, and let the agent inhabit a system that makes your discipline part of the environment. That is the difference between using AI and being amplified by it.

Lars, Theo, Felix, Rian
15 May 2026
Westport, Ireland
