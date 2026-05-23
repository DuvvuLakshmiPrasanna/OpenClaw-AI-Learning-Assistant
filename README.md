# 🦞 Personalized AI Learning Assistant — OpenClaw + Telegram

This project builds a self-hosted Telegram learning assistant with OpenClaw. It onboards new users, stores their technical preferences in persistent memory, and sends a daily 9 PM brief with exactly 5 interview questions and 3 to 5 technical tidbits tailored to their interests.

## What’s Included

- `skills/user-onboarding/SKILL.md` for the first-time onboarding flow
- `skills/daily-quiz/SKILL.md` for the nightly brief generation flow
- `config/openclaw.json` for model, Telegram, web search, cron, and memory setup
- `Dockerfile` and `docker-compose.yml` for containerized local deployment
- `.env.example` for the required environment variables

## How It Works

1. A new Telegram user sends the bot a message.
2. A standing order checks whether `user_profile_{{user.id}}` exists in memory.
3. If no profile exists, the onboarding skill asks for domains, level, goals, and timezone.
4. The profile is saved to OpenClaw persistent memory.
5. A cron job named `nightly-tech-brief` runs every day at 9 PM in the user’s timezone.
6. The daily quiz skill reads memory, uses `web_search` for fresh content, formats the message in Telegram MarkdownV2, and sends it through Telegram.

## Setup

### Prerequisites

- Docker and Docker Compose v2
- Node.js 20+ if you want to run OpenClaw locally outside Docker
- A Telegram bot token from @BotFather
- Ollama installed locally if you want to run the assistant with a local model

### 1. Configure Environment Variables

Copy the example file and fill in your token:

```bash
cp .env.example .env
```

Set your Telegram token in `.env`:

```env
TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN_HERE
```

If you use Ollama locally, keep `OLLAMA_BASE_URL=http://ollama:11434` for Docker Compose.

### 2. Review the OpenClaw Configuration

The submission includes a non-secret configuration snippet at `config/openclaw.json`. It already defines:

- the model provider setup
- the Telegram plugin
- `web_search` and `web_fetch`
- the onboarding standing order
- the `nightly-tech-brief` cron job

### 3. Start the Stack with Docker

```bash
docker compose up -d --build
```

Then check the services:

```bash
docker compose ps
docker compose logs -f openclaw
```

### 4. Test the Bot

1. Open Telegram and send a message to your bot.
2. Complete the onboarding questions.
3. Confirm the saved profile with:

```bash
openclaw memory get "user_profile_USER_ID"
```

4. Trigger the nightly brief manually if needed:

```bash
openclaw cron trigger "nightly-tech-brief"
```

## Design Choice: Standing Order for Onboarding

I used a standing order rather than a webhook because the onboarding trigger is already internal to OpenClaw and depends only on memory state. That keeps the implementation simpler, avoids public endpoint and TLS setup, and matches the project goal of running everything locally in a containerized environment.

## Configuration Snippet

```json
{
  "models": {
    "providers": {
      "ollama": {
        "enabled": true,
        "baseUrl": "${env.OLLAMA_BASE_URL}"
      }
    }
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true,
        "package": "@openclaw/plugin-telegram",
        "config": {
          "botToken": "YOUR_TELEGRAM_BOT_TOKEN_HERE"
        }
      }
    }
  },
  "tools": {
    "web_search": {
      "enabled": true,
      "provider": "duckduckgo"
    }
  }
}
```

## File Structure

```text
.
├── skills/
│   ├── user-onboarding/SKILL.md
│   └── daily-quiz/SKILL.md
├── config/openclaw.json
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── README.md
```

## Notes

- The Telegram bot token is intentionally left as a placeholder.
- The nightly brief must always contain exactly 5 questions and 3 to 5 tidbits.
- The daily skill uses recent web search results to keep the brief fresh and relevant.
