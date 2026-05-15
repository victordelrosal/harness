# Getting Started with HARNESS

**Six weeks. Seven layers. One configured agent.**

The full handbook is 600 lines. This is the build path: one layer per week, in order. Each week leaves you measurably more capable than the last.

Resist the urge to do it all in a weekend. The point is to *feel* each layer before adding the next. A harness configured in fifteen minutes is a wishlist, not a contract.

---

## Before week one — Install

```bash
# Install the Claude Code CLI (follow Anthropic's instructions for your platform)
# https://code.claude.com/

# Clone this kit
git clone https://github.com/victordelrosal/harness.git
cd harness

# Inspect the starter kit
ls starter-kit/
```

Read [`HANDBOOK.md`](HANDBOOK.md) and [`THEORY.md`](THEORY.md) once. Skim, don't memorise.

---

## Week 1 — Memory

**Goal:** a `~/.claude/CLAUDE.md` you would not be embarrassed to show another senior practitioner.

1. Copy `starter-kit/CLAUDE.md.template` to `~/.claude/CLAUDE.md`.
2. Fill in your role, your style rules, your path shortcuts, your hard prohibitions.
3. **Cap at 30 lines.** If you cannot fit it, your scope is too broad. Move project-specific rules into `<project>/CLAUDE.md`. Move personal preferences into `<project>/CLAUDE.local.md`.
4. Use it for a week. Notice when Claude ignores a rule. That is the rule that needs a hook, not a longer CLAUDE.md.

**Capability test for week 1:** can you describe in one sentence what your CLAUDE.md is for? If not, it is too long.

---

## Week 2 — Skills

**Goal:** five skills, one per recurring workflow.

1. Look at last week's work. Identify five tasks you did more than once.
2. For each, run `/skill-creator` in Claude Code (or write the YAML header manually) and draft a `~/.claude/skills/<name>/SKILL.md`. Aim for 10-30 lines per skill.
3. Test each by triggering it in a fresh session. Refine the description until activation is reliable.
4. **Stop at five.** Six and seven come from observation, not anticipation.

**Capability test for week 2:** invoke each of your five skills at least once. If a skill fires by accident on the wrong task, tighten its description.

---

## Week 3 — Permissions and hooks

**Goal:** the only enforced layer. Tightest discipline of the six weeks.

1. Copy `starter-kit/settings.json` to `~/.claude/settings.json`. Adapt the deny list to your work.
2. Copy `starter-kit/hooks/fs-guard.sh` and `starter-kit/hooks/secret-scan.sh` to `~/.claude/hooks/`. `chmod +x` both.
3. Restart Claude Code. Test each hook by trying to run something it should block (`rm -rf /tmp/test-dir-only`, then a deliberately-fake secret in a write).
4. Watch your prompts for a week. Every time Claude asks for permission for the same command twice, add it to the allow list. Every time you cringe at a command Claude proposed, add the pattern to the deny list.

**Capability test for week 3:** your permission prompts should drop ~50% by end of week, your near-misses to zero.

---

## Week 4 — Subagents and MCP

**Goal:** isolation as a habit.

1. Copy the four subagent files from `starter-kit/agents/` to `~/.claude/agents/`. Plan, Explore, code-reviewer, general-purpose.
2. Install 4-6 MCP servers, no more. Suggested baseline: filesystem, GitHub (or your code host), git, fetch, one search server (Perplexity / Brave). Add one domain-specific server only if you have an immediate use for it.
3. For every research task this week, ask yourself: should this go in a subagent so the main session stays clean? Practise until it is automatic.
4. For every workflow you build: configure model routing in the subagent frontmatter. Haiku for mechanical tasks; Sonnet for synthesis; Opus only for genuine tradeoffs.

**Capability test for week 4:** can you give a 12-step research task to `general-purpose` and get back a 200-word summary, while your main context stays under 30% used?

---

## Week 5 — Observability

**Goal:** see what you are doing.

1. Set up a custom statusline. Show: model, context-remaining, cost, working directory, mode. The reference `starter-kit/statusline.sh` (coming in v0.2; for now, see Anthropic's docs) is a starting point.
2. Add one `Stop` hook that appends "what shipped" to a daily log. End-of-week review writes itself.
3. Watch your usage for a week. Notice when context fills, when you switched modes, when cost spiked. Calibrate.

**Capability test for week 5:** you can quote your context-remaining at any moment without looking. You feel a spike in cost the way you feel a brake-pad warning in a car.

---

## Week 6 — Review and prune

**Goal:** kill what is not pulling weight.

1. Read your CLAUDE.md, your skills, your hooks, your settings.json. Ask of each line: is this still earning its place?
2. Delete what is not.
3. Re-read the [`HANDBOOK.md`](HANDBOOK.md). Pick the two or three anti-patterns you are guilty of and fix them.
4. Write down three failures you have observed this month. Each becomes a rule in the deny list, a skill, or a hook. **The Ratchet Principle:** every failure becomes a permanent constraint. The harness only tightens.

**Capability test for week 6:** explain your harness to a friend in under three minutes. If you cannot, it is too complex.

---

## After week 6

You are at Level 4 in the Herkelman taxonomy ([`HANDBOOK.md`](HANDBOOK.md) §11). The gap from here to Level 5 (autonomous, headless, scheduled runs in a sandbox) is psychological and technical in roughly equal measure. The handbook has the playbook. The starter kit has the working parts.

What stops most professionals here is not skill. It is the trust barrier. The path through that barrier is the same path through any other trust barrier: a deny list that prevents catastrophe, hooks that audit every action, an exception path that wakes you only when something needs you. Build those, sleep on the autonomous run for a week, then loosen the leash one notch at a time.

---

## When you get stuck

- Read the failure carefully before forming a hypothesis. One hypothesis at a time. Smallest test first.
- If Claude is ignoring a rule, the rule probably needs to be a hook, not a longer CLAUDE.md.
- If a skill fires on the wrong task, the description is too broad.
- If your context fills fast, the answer is usually subagents, not bigger summaries.
- If you have a deeply weird incident, open an issue on this repo with the reproduction. The kit gets better when it is wrong about something specific.

---

The handbook is the theory. The starter kit is the practice. The capability test is the only thing that matters: are you sharper for using this, or are you leaning harder?

Lars, Theo, Felix, Rian
15 May 2026
