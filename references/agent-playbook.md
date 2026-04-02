# Agent playbook for FAL setup

Use this repo when the goal is to enable OpenClaw image generation through FAL.

## Discovery checklist

1. Locate the active OpenClaw config file
2. Locate the environment file or service env source used by OpenClaw
3. Back up both before editing
4. Patch only the minimal image generation config needed
5. Tell the user to run the credential script locally with an explicit env-file path
6. Restart OpenClaw only if needed
7. Verify that image generation is available

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

- Never ask the user to paste `FAL_KEY` into chat
- Prefer explicit file paths over guessing
- Back up config before changing it
- Apply the smallest possible patch
- Explain what changed after setup
