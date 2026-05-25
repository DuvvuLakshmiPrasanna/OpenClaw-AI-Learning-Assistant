# Skill: daily-quiz

## Trigger

This skill is invoked by the `nightly-tech-brief` cron job at 21:00 in the user's
configured timezone. It runs in an isolated session with no prior conversation history.
It can also be triggered on demand when the user sends `/quiz`.

## Objective

Generate and deliver a personalised daily technical brief to the user on Telegram.
The brief must contain exactly 5 interview questions and between 3 and 5 technical
tidbits. All content must be fresh, sourced from the live web, and calibrated to the
user's saved profile.

## Instructions

### Step 1 — Load user profile

Read the value stored at `user_profile_{{user.id}}` from persistent memory.
Extract: `domains`, `level`, `goals`, `timezone`.

If no profile is found, send this message and stop:

```
⚠️ I don't have a profile for you yet. Send me any message to start onboarding.
```

### Step 2 — Load topic history

Read the value stored at `recent_topics_{{user.id}}` from persistent memory.
This is a list of topic strings used in previous briefs. Use it to avoid repeating
the same topics as the last 5 briefs.

### Step 3 — Web search for each domain

For each domain in the user's profile, run a `web_search` query in this format:

```
<domain> interview questions <current year>
<domain> latest developments <current year>
```

Then use `web_fetch` on the top 2 results per domain to retrieve the full article text.
Extract concrete, specific technical facts — not generic summaries.

### Step 4 — Generate 5 interview questions

Based on the fetched content and the user's profile, generate exactly 5 questions.
Distribute question types across this set:

| Type | Description |
|---|---|
| Conceptual | Tests understanding of a concept |
| Problem-solving | Apply knowledge to a scenario |
| System design | Design or architecture question |
| Debugging | Identify what is wrong in a scenario |
| Behavioural/situational | How would you handle a real situation |

Calibrate difficulty to the user's `level`:
- Junior: focus on fundamentals and common patterns
- Mid-level: include design trade-offs and debugging
- Senior/Staff: include system design, scalability, and cross-cutting concerns

Each question must be labelled with its type and domain. Format:

```
Q1 [Conceptual — Python]
Question text here
```

### Step 5 — Generate 3–5 tidbits

Based on the fetched articles, write 3 to 5 short tidbits (2–3 sentences each).
Each tidbit must contain a concrete technical insight — a new API, a pattern shift,
a benchmark result, a tool update. Do not write generic advice.

### Step 6 — Update topic history

Extract the main topic keywords from this brief (domains + question subjects).
Update `recent_topics_{{user.id}}` in memory with the new topics prepended.
Keep only the 25 most recent entries.

### Step 7 — Format and send the Telegram message

Format the entire brief in Telegram MarkdownV2. Use this exact structure:

```
🦞 *Your Daily Tech Brief — {date}*

━━━━━━━━━━━━━━━━━━━━
🧠 *Interview Questions*
━━━━━━━━━━━━━━━━━━━━

*Q1 \[Type — Domain\]*
Question text

*Q2 \[Type — Domain\]*
Question text

*Q3 \[Type — Domain\]*
Question text

*Q4 \[Type — Domain\]*
Question text

*Q5 \[Type — Domain\]*
Question text

━━━━━━━━━━━━━━━━━━━━
💡 *Today's Tidbits*
━━━━━━━━━━━━━━━━━━━━

Tidbit one text here\.

Tidbit two text here\.

Tidbit three text here\.

━━━━━━━━━━━━━━━━━━━━
_Reply with your answers to get feedback, or send /quiz for more\._
```

In MarkdownV2, escape all special characters: `.`, `!`, `-`, `(`, `)`, `[`, `]`, `{`, `}`, `>`, `#`, `+`, `=`, `|` must all be preceded by `\`.

Send the formatted message to the user via the Telegram plugin.

## Memory schema

| Key | Type | Description |
|---|---|---|
| `user_profile_{{user.id}}` | JSON object | Read-only in this skill |
| `recent_topics_{{user.id}}` | JSON array of strings | Updated after each brief |

## Output constraints

- Exactly 5 questions. Never 4, never 6.
- Between 3 and 5 tidbits.
- No repeated topics from the last 5 briefs.
- Content must come from web search results, not from training data alone.
- Message must be sent via Telegram using MarkdownV2 formatting.
