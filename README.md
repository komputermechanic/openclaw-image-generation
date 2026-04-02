# FAL Image Generation Setup for OpenClaw

This repo is designed for **agent-assisted setup**.

The idea is simple:
- the OpenClaw agent discovers where your active OpenClaw config and environment files live
- the agent applies the minimum required config changes safely
- you enter your `FAL_KEY` locally in the terminal only
- your secret never needs to be pasted into chat

## Recommended user prompt

```text
Help me set up FAL image generation for OpenClaw on this machine using this GitHub repo.

First discover where the active OpenClaw config and environment files are stored.
Do not ask me to paste my FAL API key into chat.
Instead, tell me the exact local terminal command to run so I can store the key securely outside chat.
Back up any config before changing it, apply the minimum necessary changes, and then verify the setup.
```

## What the agent should do

1. Discover the active OpenClaw config file
2. Discover where environment variables for OpenClaw are loaded from
3. Back up files before editing
4. Add or update:

```json5
{
  agents: {
    defaults: {
      imageGenerationModel: "fal/fal-ai/flux/dev"
    }
  }
}
```

5. Tell the user the exact command to run for local credential setup
6. Restart OpenClaw if needed
7. Verify by testing image generation availability

## Local credential step

The agent should pass an explicit env-file path to the credential script.

Example:

```bash
FAL_ENV_FILE=/path/to/your/openclaw.env bash configure-fal-credentials.sh
```

## Why this repo is agent-assisted

A static script cannot safely guess where every OpenClaw deployment stores:
- its active config file
- its environment file
- its service-level variables

So discovery should be done by the agent, while secret entry should be done locally in the terminal.
