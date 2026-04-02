---
name: fal-image-generation-setup
description: Set up FAL image generation for OpenClaw using a simple terminal-based flow that stores FAL_KEY in the shell profile and sets imageGenerationModel to fal/fal-ai/flux/dev in /root/.openclaw/openclaw.json.
---

# FAL Image Generation Setup

Created by **Komputer Mechanic**  
Website: <https://komputermechanic.com/>

Use this package when the user wants a simple setup flow for FAL image generation on an OpenClaw instance.

## Setup steps

1. Add `FAL_KEY` to `~/.bashrc`.
2. Update `/root/.openclaw/openclaw.json` to set:
   - `agents.defaults.imageGenerationModel = "fal/fal-ai/flux/dev"`

## Notes

- This package intentionally uses a simple direct setup path.
- It assumes the OpenClaw instance uses the shell environment and config path described above.
