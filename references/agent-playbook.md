# Agent playbook for FAL setup

Use the simple two-command setup flow:

1. Tell the user to add `FAL_KEY` to `~/.bashrc`
2. Tell the user to patch `/root/.openclaw/openclaw.json`

Target config:

```json
{
  "agents": {
    "defaults": {
      "imageGenerationModel": "fal/fal-ai/flux/dev"
    }
  }
}
```
