# FAL Image Generation Setup for OpenClaw

Created by **Komputer Mechanic**  
Website: <https://komputermechanic.com/>

This setup uses a very simple approach.

## Step 1: add your FAL key

Run this in your terminal:

```bash
echo "export FAL_KEY=your_actual_fal_key_here" >> ~/.bashrc && source ~/.bashrc
```

## Step 2: set OpenClaw to use FAL for image generation

Run this in your terminal:

```bash
node -e "
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('/root/.openclaw/openclaw.json', 'utf8'));
cfg.agents.defaults.imageGenerationModel = 'fal/fal-ai/flux/dev';
fs.writeFileSync('/root/.openclaw/openclaw.json', JSON.stringify(cfg, null, 2));
console.log('Done');
"
```

## What this does

- stores `FAL_KEY` in your shell profile
- updates OpenClaw config to use `fal/fal-ai/flux/dev`

## Important note

This simple method is intended for environments where this setup pattern works for the running OpenClaw instance.

## Test

After setup, ask OpenClaw to generate an image.
