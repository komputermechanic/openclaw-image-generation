---
name: openclaw-image-generation-setup
description: Install or manage image generation for OpenClaw. Use when the user wants to set up image generation (OpenAI or fal.ai), switch their fal.ai model, update API keys, or uninstall image generation. The installer handles API key collection, openclaw.json configuration, skill creation, and gateway restart.
---

# OpenClaw Image Generation Setup

Created by **Komputer Mechanic** — <https://komputermechanic.com/>

## When to use this skill

Use this when the user says things like:
- "set up image generation"
- "I want to generate images with OpenClaw"
- "configure fal.ai for OpenClaw"
- "switch my fal.ai model"
- "update my API key"
- "uninstall image generation"

---

## How to help the user

Tell them to run the installer:

```bash
wget -O install-image-generation.sh https://raw.githubusercontent.com/komputermechanic/openclaw-image-generation/main/install-image-generation.sh && bash install-image-generation.sh
```

---

## What the script will ask

1. Whether to proceed (disclaimer shown first)
2. Which action: fresh setup, switch model, update keys, uninstall, or cancel
3. For fresh setup: which provider — OpenAI, fal.ai, or both
4. For OpenAI: which model (3 options)
5. For fal.ai: which model (7 options)
6. API key(s), entered securely and saved to `~/.openclaw/.env`
7. If both providers: which is primary and which is fallback

---

## Supported providers and models

**OpenAI — Generation only:**
- `gpt-image-1.5` — Latest, 4x faster, best text rendering, ~$0.14/image *(recommended)*
- `gpt-image-1` — Standard quality, ~$0.17/image
- `gpt-image-1-mini` — Budget option, ~$0.07/image

**fal.ai — Generation only:**
- FLUX.1 Dev (`fal-ai/flux/dev`) — ~$0.025/image
- FLUX.1 Schnell (`fal-ai/flux/schnell`) — cheapest, ultra fast
- FLUX.1.1 Pro (`fal-ai/flux-pro/v1.1`) — enhanced quality
- FLUX.2 Flex (`fal-ai/flux-2-flex`) — fine control, typography

**fal.ai — Generation + Editing:**
- FLUX.2 Pro (`fal-ai/flux-2-pro`) — best photorealism, ~$0.03/image
- Nano Banana 2 (`fal-ai/nano-banana-2`) — Google, fast + edit
- Nano Banana Pro (`fal-ai/nano-banana-pro`) — Google, highest quality

---

## Skills created by the installer

- `openai_image` — at `~/.openclaw/skills/openai-image/SKILL.md` (when OpenAI is configured)
- `fal_image` — at `~/.openclaw/skills/fal-image/SKILL.md` (when fal.ai is configured)

## After setup

The script outputs a message for the user to send to their agent. If the user pastes that message to you, follow the instructions — re-read the relevant skill file(s), confirm the configuration, and run the smoke test.

---

## Notes

- OpenClaw must be installed before running the script
- fal.ai models 5–7 (FLUX.2 Pro, Nano Banana 2, Nano Banana Pro) support generation and editing
- fal.ai models 1–4 support generation only
- OpenAI models support generation only
