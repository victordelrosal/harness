# THEORY — What is a harness, and why does it matter?

A short reference. The handbook is the *how*; this is the *what* and the *why*. Read once. Refer back when the abstraction is doing real work in a decision.

---

## The one-line definition

> A harness is everything in an AI agent except the model itself.
>
> Agent = Model + Harness. If you are not the model, you are the harness.

The word *harness* predates LLMs: software engineering has used "test harness" for decades to describe the system that runs and observes code under test. The new use is applying it to LLM agents. The formula and the named discipline emerged across several players in early 2026:

- **OpenAI**, February 2026, *Harness engineering: leveraging Codex in an agent-first world.*
- **Birgitta Böckeler** (Thoughtworks), 2 April 2026, *Harness engineering for coding agent users*, published on Martin Fowler's site.
- **Vivek Trivedy** (LangChain), 10 March 2026, *The Anatomy of an Agent Harness*.

Simon Willison frames the same idea from the runtime side: a coding agent is "a piece of software that acts as a harness for an LLM," managing the tool-calling loop. His compact definition: "an LLM agent runs tools in a loop to achieve a goal."

So: the model is raw intelligence. The harness is every wire, rule, tool, file, and feedback loop wrapped around it that turns that intelligence into something reliable. **Claude Code is a harness around Claude.** What sits inside Claude Code (your CLAUDE.md, your skills, your hooks, your MCP servers) is *your* harness, built on top of Anthropic's.

---

## Why the harness matters more than people expect

The single most important claim in the literature, from Addy Osmani:

> A decent model with a great harness beats a great model with a bad harness.

And the corollary, from HumanLayer:

> It is not a model problem. It is a configuration problem.

Most agent failures are not the model being stupid. They are the harness being thin: missing context, missing tools, missing feedback, missing guardrails. That is good news. The harness is the part you control. You cannot retrain Opus. You can rebuild its harness in an afternoon.

The strongest single piece of evidence is OpenAI's February 2026 case study: a three-person team built and shipped an internal product from an empty repository over five months. Zero manually-written lines. Around one million lines of production code across 1,500 merged pull requests. The team's job was not writing code. It was engineering the harness that let the agent write it reliably.

A co-evolution loop is worth knowing: modern models are post-trained with specific harness primitives in mind (tool use, file editing, sub-agents). Better models do not remove harness complexity; they shift it toward new capabilities and new failure modes.

---

## The anatomy of a harness

Pulling the component lists together (Osmani, Böckeler, Anthropic), a harness is made of:

- **Instructions.** System prompt, `CLAUDE.md` / `AGENTS.md`, skill definitions, coding conventions.
- **Knowledge.** Memory stores, context compression / compaction, retrieval, progress files.
- **Tools.** The callable functions: file read/write, shell, search, MCP integrations.
- **Infrastructure.** Filesystem, sandbox, browser, the execution environment itself.
- **Orchestration.** Sub-agent spawning, model routing, handoffs, context firewalls, permission gates.
- **Hooks / middleware.** Deterministic lifecycle scripts the harness runs, not the model.
- **Observability.** Logs, traces, cost metering, event buses.

The `HANDBOOK.md` decomposes this into seven concrete layers for Claude Code. The decomposition is pedagogical, not exhaustive (plugins, slash commands, git worktrees compose with it). The principle is that you can debug agent behaviour by walking the layers in order, asking which one failed.

---

## The core framework: Guides vs Sensors

This is Böckeler's central contribution and the most useful mental model in the field. A harness regulates the agent through two complementary control types:

**Guides — feedforward control.** Steer the agent *before* it acts. They raise the odds of a good first attempt. Examples: `CLAUDE.md`, architecture docs, skill instructions, bootstrap scripts, code mods, LSP integration, planning structures.

**Sensors — feedback control.** Observe *after* the agent acts, and enable self-correction. Most powerful when their output is shaped for an LLM to read. Examples: linters, type checkers, tests, structural tests, code-review agents, mutation testing, LLM-as-judge.

Böckeler:

> Separately, you get either an agent that keeps repeating the same mistakes (feedback-only) or an agent that encodes rules but never finds out whether they worked (feed-forward-only).

Guides without sensors is hope. Sensors without guides is thrashing. A real harness is a closed loop.

### Computational vs Inferential

Both guides and sensors come in two flavours:

| Type | Nature | Speed / cost | Examples |
|---|---|---|---|
| **Computational** | Deterministic, CPU-based, reliable | Milliseconds to seconds, cheap | Tests, linters, type checkers, regex guards |
| **Inferential** | Non-deterministic, GPU/NPU-based, judgement | Slower, expensive | Semantic analysis, AI code review, LLM-as-judge |

Design rule: run cheap **computational** controls on every change; reserve expensive **inferential** controls for checkpoints. A harness with only inferential controls is slow and costly. One with only computational controls misses what needs judgement.

---

## Why CLAUDE.md is not enough

The most consequential operational fact about Claude Code:

> CLAUDE.md is loaded as context, not enforced as configuration.

This is in Anthropic's own docs. A rule in CLAUDE.md is read by the model and *usually* honoured. It is never *guaranteed*. The model can ignore it, and at large context-window fills, it routinely does.

The corollary is that any compliance, safety, or hard-rule need cannot rely on CLAUDE.md alone. It needs a hook. The handbook calls this the **compact test:** an immature harness relies on the model remembering discipline; a mature harness makes discipline part of the environment.

The defensive primitive that solves this in Claude Code is hooks. PreToolUse hooks fire before any permission check. They are shell scripts. They cannot be hallucinated past. They are the one place where you get deterministic behaviour.

---

## The vocabulary is layered, not consolidated

"Harness engineering" stabilised as practitioner shorthand by May 2026. Every major writer in the space uses it (Böckeler, Osmani, Trivedy, OpenAI, HumanLayer, Hashimoto). The Guides vs Sensors decomposition has become the canonical taxonomy.

But "harness engineering" has not displaced "context engineering" as the broader frame. HumanLayer publicly positions harness engineering as a *subset* of context engineering. Louis Bouchard and the arXiv "Context Engineering 2.0" line of work do the same. Ronald Ashri's critique that the term is redundant survives in spirit.

The most accurate way to hold the vocabulary today:

> Prompt engineering → context engineering → harness engineering, as concentric layers.
> Harness engineering is the configuration-and-control subset of context engineering.
> Agent = Model + Harness with Guides and Sensors is the most widely-shared mental model within that subset.

This kit uses the harness vocabulary throughout because it is the most useful frame for *configuration work*. The discipline is layered, not consolidated.

---

## The Ratchet Principle

From Osmani, and the principle that makes a harness improve over time:

> Every agent failure becomes a permanent constraint. The agent never makes that mistake again because you encode the fix into a rule. The harness only tightens.

The implication for your daily practice: every near-miss is a deposit. Add the deny rule. Update the hook. Tighten the skill description. Over a year, your harness becomes a record of your failures, and a system that has internalised them.

---

## Further reading (primary sources)

- Vivek Trivedy, *The Anatomy of an Agent Harness*, LangChain, 10 March 2026.
- OpenAI, *Harness engineering: leveraging Codex in an agent-first world*, February 2026.
- Birgitta Böckeler, *Harness engineering for coding agent users*, Martin Fowler / Thoughtworks, 2 April 2026.
- Addy Osmani, *Agent Harness Engineering*.
- Anthropic Engineering, *Effective harnesses for long-running agents*, November 2025.
- Anthropic Engineering, *Harness design for long-running application development*, March 2026.
- Simon Willison, *How coding agents work*.
- Ronald Ashri, *Harness Engineering: a new term for...*, Agents Decoded.

The full bibliography (with URLs) is in `HANDBOOK.md`.

---

Lars
15 May 2026
