# OpenClaw Image Generation Setup

Created by **Komputer Mechanic**  
Website: <https://komputermechanic.com/>

This repo is intentionally simple.

It uses a single script to set up image generation for OpenClaw with:
- OpenAI only
- fal.ai only
- or both with primary + fallback

## Main script

- `install-image-generation.sh`

## What the script does

The script:
- checks that OpenClaw is installed
- ensures `~/.openclaw/.env` exists
- asks which provider(s) you want to set up
- stores your API key(s) in `~/.openclaw/.env`
- updates `~/.openclaw/openclaw.json`
- creates the `flux2pro` skill when fal.ai is selected
- restarts OpenClaw Gateway

## Run it

### Cautious path

```bash
wget -O install-image-generation.sh https://raw.githubusercontent.com/komputermechanic/falai-openclaw-integration/main/install-image-generation.sh
bash install-image-generation.sh
```

### Fast path

```bash
curl -fsSL https://raw.githubusercontent.com/komputermechanic/falai-openclaw-integration/main/install-image-generation.sh | bash
```

## What users should expect

During setup, the script will:
- ask which provider(s) to configure
- ask for the relevant API key(s)
- ask which provider should be primary if both are selected
- restart OpenClaw Gateway

## OpenClaw agent prompt example

```text
Help me set up image generation for OpenClaw using this GitHub repo:

https://github.com/komputermechanic/falai-openclaw-integration

Guide me step by step. If needed, tell me to run the install script from the repo.
```

## Notes

- If you select fal.ai, the script also creates the `flux2pro` skill intentionally.
- This repo is built around the single setup script as the primary setup method.
