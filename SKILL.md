---
name: fal-image-generation-setup
description: Set up FAL image generation for OpenClaw in an agent-assisted way. Use when the user wants to enable the image_generate tool with fal, configure imageGenerationModel, locate the active OpenClaw config and environment files, and keep the FAL API key out of chat by storing it through a local terminal step.
---

# FAL Image Generation Setup

Created by **Komputer Mechanic**  
Website: <https://komputermechanic.com/>

Use this package when a user wants to enable FAL-based image generation in OpenClaw.

## Core workflow

1. Discover the active OpenClaw config file.
2. Discover where OpenClaw loads environment variables from.
3. Back up files before editing.
4. Patch only the minimum config needed to enable FAL image generation.
5. Tell the user to run the credential script locally in the terminal.
6. Verify setup after the credential step is complete.

## Minimum config target

Set:

```json5
{
  agents: {
    defaults: {
      imageGenerationModel: "fal/fal-ai/flux/dev"
    }
  }
}
```

## Safety rules

- Never ask the user to paste `FAL_KEY` into chat.
- Prefer explicit file paths over guessing.
- Back up config before changing it.
- Apply the smallest possible patch.
- Explain what changed after setup.

## References

- Read `references/agent-playbook.md` for the agent setup flow.
