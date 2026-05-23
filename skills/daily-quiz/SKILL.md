# SKILL: Daily Tech Brief and Quiz Generation

## GOAL

Generate a high-quality, personalized daily tech brief for a specific user and deliver it via Telegram. The brief must contain exactly 5 interview questions and 3 to 5 technical tidbits, all tailored to the user's stored profile.

## CONTEXT

This skill is triggered automatically every evening at 9:00 PM in the user's local timezone, via a configured cron job named `nightly-tech-brief`. The agent is provided with the user's Telegram ID and must autonomously complete the full pipeline: retrieve profile, search the web, synthesize content, format the message, and send it.

## GENERATION WORKFLOW

### Step 1 — Retrieve User Profile

Use the `memory_store` tool to fetch the user's profile with the key `user_profile_{{user.id}}`.

### Step 2 — Retrieve Recently Asked Topics

Use `memory_store` to fetch `recent_topics_{{user.id}}` and avoid repeating the same themes from the last 7 days.

### Step 3 — Conduct Web Search for Fresh Content

For each domain in the user's profile, perform a `web_search` query. Always include the domain and add a recency signal such as latest, recent, or 2025. If a result seems stale or unhelpful, use `web_fetch` to read the most promising source in full.

### Step 4 — Synthesize Technical Tidbits

Based on the aggregated search results, extract and synthesize 3 to 5 tidbits. Each tidbit must be specific, insightful, concise, and directly relevant to at least one of the user's domains.

### Step 5 — Generate 5 Interview Questions

Generate exactly 5 interview questions. They must be relevant to the user's domains, appropriate for the user's level, and cover a mix of conceptual, coding, system design, behavioral, and deep dive or debugging styles. Avoid topics already covered in the last 7 days.

### Step 6 — Format the Telegram Message

Assemble the final message using Telegram MarkdownV2 formatting. The message must follow this structure:

```
🦞 *Your Daily Tech Brief* — [Day, DD Month YYYY]

━━━━━━━━━━━━━━━━━━━━
🧠 *Interview Questions*
━━━━━━━━━━━━━━━━━━━━

*Q1 \[Conceptual — Domain\]*
[Question text here]

*Q2 \[Coding — Domain\]*
[Question text here]

*Q3 \[System Design — Domain\]*
[Question text here]

*Q4 \[Behavioral — Domain\]*
[Question text here]

*Q5 \[Deep Dive — Domain\]*
[Question text here]

━━━━━━━━━━━━━━━━━━━━
💡 *Today's Tidbits*
━━━━━━━━━━━━━━━━━━━━

• [Tidbit 1]

• [Tidbit 2]

• [Tidbit 3]

━━━━━━━━━━━━━━━━━━━━
Reply *answers* to get feedback, or *more* for extra questions\.
```

### Step 7 — Send the Message

Use the Telegram channel to send the formatted message to `{{user.id}}`. After sending, log the delivery in memory under `last_brief_sent_{{user.id}}`.

## ERROR HANDLING

- If web search returns no results for a domain, fall back to the LLM's own knowledge and log the fallback.
- If memory read fails, abort and log.
- If Telegram send fails, retry once and then stop if it still fails.
- Never send a partial or malformed message.

## CONSTRAINTS

- The entire pipeline must run autonomously.
- The output message must always contain exactly 5 questions and between 3 and 5 tidbits.
- Content quality is paramount.
- Never include internal system details, memory keys, or error messages in the Telegram output.
