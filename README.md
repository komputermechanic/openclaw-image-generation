# OpenClaw Image Generation Setup

Created by **Komputer Mechanic** — <https://komputermechanic.com/>

A single interactive installer that adds image generation to OpenClaw. Supports OpenAI and fal.ai, with model selection, key management, and a custom agent skill — all from one script.

---

## Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/komputermechanic/openclaw-image-generation/main/install-image-generation.sh)
```

---

## What the script does

On launch, the script asks you to choose one of three actions:

| Option | Description |
|--------|-------------|
| **1) Fresh setup** | Configure image generation from scratch |
| **2) Switch model** | Change your current fal.ai model |
| **3) Uninstall** | Remove image generation from OpenClaw |

---

## Supported providers

### OpenAI

| Model | Pricing | Capability |
|-------|---------|------------|
| `gpt-image-1` | ~$0.17 / image | Generation only |

### fal.ai

**Generation only:**

| # | Model | Model ID | Notes |
|---|-------|----------|-------|
| 1 | FLUX.1 Dev | `fal-ai/flux/dev` | General use, ~$0.025/image |
| 2 | FLUX.1 Schnell | `fal-ai/flux/schnell` | Ultra fast, cheapest |
| 3 | FLUX.1.1 Pro | `fal-ai/flux-pro/v1.1` | Enhanced quality |
| 4 | FLUX.2 Flex | `fal-ai/flux-2-flex` | Fine control, typography |

**Generation + Editing:**

| # | Model | Model ID | Notes |
|---|-------|----------|-------|
| 5 | FLUX.2 Pro | `fal-ai/flux-2-pro` | Best photorealism, ~$0.03/image |
| 6 | Nano Banana 2 | `fal-ai/nano-banana-2` | Google, fast + edit |
| 7 | Nano Banana Pro | `fal-ai/nano-banana-pro` | Google, highest quality |

---

## What gets configured

| Item | Location |
|------|----------|
| `imageGenerationModel` | `~/.openclaw/openclaw.json` |
| API keys | `~/.openclaw/.env` |
| fal_image agent skill | `~/.openclaw/skills/fal-image/SKILL.md` |

The script restarts OpenClaw Gateway automatically after any change.

---

## Flows

### Fresh setup

1. Choose provider — OpenAI, fal.ai, or both
2. If fal.ai — select a model from the list above
3. Enter API key(s) — stored securely in `.env`
4. If both providers — choose primary and fallback
5. Script updates `openclaw.json`, creates the `fal_image` skill, and restarts the gateway

### Switch model

1. Script shows your current model
2. Choose a new fal.ai model
3. `openclaw.json` and the `fal_image` skill are both updated
4. Gateway restarts

### Uninstall

1. Removes `imageGenerationModel` from `openclaw.json`
2. Deletes `~/.openclaw/skills/fal-image/`
3. Optionally removes `FAL_KEY` and/or `OPENAI_API_KEY` from `.env`
4. Gateway restarts

---

## The fal_image skill

When fal.ai is configured, the script creates a `fal_image` skill your OpenClaw agent uses automatically.

- Models 1–4 support **generation only** via `POST https://queue.fal.run/{model-id}`
- Models 5–7 support **generation and editing** via a second endpoint at `https://queue.fal.run/{model-id}/edit`

---

## After setup

The script outputs a ready-to-paste message to send to your agent. It instructs the agent to re-read the skill file, confirm the configuration, and run a smoke test.

---

## Requirements

- OpenClaw must be installed before running this script
- `~/.openclaw/openclaw.json` must exist (the script will exit if not found)
- `wget` must be available on your system
