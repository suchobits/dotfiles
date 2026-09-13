# Agent instructions

These are common instructions for Luis's agents across all scenarios.

## General Guidelines

- Never use the em dash "—". Use plan dash "-" instead.
- When writing commit messages, NEVER auto-add your agent name as coauthor.
- When writing commit messages, NEVER auto-add the chat session url.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user experiences it.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

## Docs and comments

Be concise. This applies to every README, Markdown file, code comment, and commit message.
The reader is technical and busy: write the shortest version that still lets them act, then stop.
Terseness is the default; length must be earned.

- Match length to weight.
  A code comment is one line unless it is preventing a specific footgun.
  A README section is a short paragraph, not an essay.
  If a doc runs longer than a screen, it is probably restating what the code, `--help`, or upstream docs already say - cut it back.
- Explain the what and the why. The code already shows the how.
  A comment that paraphrases the line beneath it is noise; delete it.
- Cut words that carry no information: hedges ("basically", "essentially", "of course"), throat-clearing ("note that", "it is worth mentioning", "as you can see"), intensifiers ("very", "really", "quite"), and filler like "just", "simply".
  One sentence beats three, one word beats two.
- Do not write a sentence whose only job is to prove you did research (a forum link justifying a road not taken), unless the file is explicitly a decisions log.
- Describe the current state, never the journey.
  No "used to be X", no "fixed in <commit>", no "we tried X and it broke".
  If a sentence is not true of the code as it stands, delete it.
- Never reference a commit hash in prose. A reader who cares runs `git log`.
- One home per fact.
  A caveat or rationale lives in the single file closest to what it constrains; everywhere else gets a one-line pointer at most, never a copy.
  Before adding an explanation, grep for it - if it already exists elsewhere, link instead of repeating.
- "today", "currently", "for now", "recently", "new" all rot. Write the durable statement instead.
- Assume every repo is or will be public.
  No machine names, no secret values, no internal URLs, no usernames beyond the git identity.
  Do not narrate security-sensitive setup in more detail than a reader needs to reproduce it.
