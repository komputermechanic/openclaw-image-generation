---
name: openclaw-image-generation-setup
description: Set up OpenClaw image generation through a single installer script. Use when the user wants to configure OpenAI image generation, fal.ai image generation, or both with primary and fallback, and optionally install the flux2pro skill for fal.ai flux-2-pro.
---

# OpenClaw Image Generation Setup

Created by **Komputer Mechanic**  
Website: <https://komputermechanic.com/>

Use the single installer script in this repo:

- `install-image-generation.sh`

The script handles:
- provider selection
- API key collection
- `.env` updates
- `openclaw.json` updates
- optional `flux2pro` skill creation
- gateway restart
