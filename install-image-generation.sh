#!/bin/bash

# ============================================
# OpenClaw Image Generation Setup Script
# By Komputer Mechanic
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} OpenClaw Image Generation Setup${NC}"
echo -e "${CYAN} By Komputer Mechanic${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ── Check openclaw.json exists ───────────────────────────────────────────────
CONFIG="$HOME/.openclaw/openclaw.json"
if [ ! -f "$CONFIG" ]; then
 echo -e "${RED}❌ openclaw.json not found at $CONFIG${NC}"
 echo "Make sure OpenClaw is installed before running this script."
 exit 1
fi

# ── Ensure .env exists ───────────────────────────────────────────────────────
mkdir -p "$HOME/.openclaw"
touch "$HOME/.openclaw/.env"

# ── Ask which providers to set up ────────────────────────────────────────────
echo -e "${BOLD}Which providers do you want to set up?${NC}"
echo ""
echo " 1) OpenAI only (gpt-image-1) — Best quality, ~\$0.17/image"
echo " 2) fal.ai only (flux-2-pro) — Good quality, ~\$0.03/image"
echo " 3) Both (OpenAI + fal.ai) — Set primary and fallback"
echo ""
read -p "Enter 1, 2 or 3: " PROVIDER_CHOICE
echo ""

SETUP_OPENAI=false
SETUP_FAL=false

case "$PROVIDER_CHOICE" in
 1) SETUP_OPENAI=true ;;
 2) SETUP_FAL=true ;;
 3) SETUP_OPENAI=true; SETUP_FAL=true ;;
 *)
 echo -e "${RED}❌ Invalid choice. Please enter 1, 2 or 3.${NC}"
 exit 1
 ;;
esac

# ── Collect OpenAI key ────────────────────────────────────────────────────────
if [ "$SETUP_OPENAI" = true ]; then

 # Warn if key already exists
 if grep -q "OPENAI_API_KEY" "$HOME/.openclaw/.env" 2>/dev/null; then
 echo -e "${YELLOW}⚠️ An existing OpenAI key was found in your .env file.${NC}"
 read -p "Do you want to replace it? (y/n): " REPLACE_OPENAI
 echo ""
 if [ "$REPLACE_OPENAI" != "y" ]; then
 echo "Keeping existing OpenAI key. Skipping OpenAI setup."
 SETUP_OPENAI=false
 fi
 fi

 if [ "$SETUP_OPENAI" = true ]; then
 read -r -s -p "Paste your OpenAI API key: " OPENAI_KEY; echo
 echo ""
 if [ -z "$OPENAI_KEY" ]; then
 echo -e "${RED}❌ No OpenAI key entered. Exiting.${NC}"
 exit 1
 fi
 sed -i '/^OPENAI_API_KEY/d' "$HOME/.openclaw/.env"
 echo "OPENAI_API_KEY=$OPENAI_KEY" >> "$HOME/.openclaw/.env"
 echo -e "${GREEN}✅ OpenAI key saved${NC}"
 echo ""
 fi
fi

# ── Collect fal.ai key ────────────────────────────────────────────────────────
if [ "$SETUP_FAL" = true ]; then

 # Warn if key already exists
 if grep -q "FAL_KEY" "$HOME/.openclaw/.env" 2>/dev/null; then
 echo -e "${YELLOW}⚠️ An existing fal.ai key was found in your .env file.${NC}"
 read -p "Do you want to replace it? (y/n): " REPLACE_FAL
 echo ""
 if [ "$REPLACE_FAL" != "y" ]; then
 echo "Keeping existing fal.ai key. Skipping fal.ai setup."
 SETUP_FAL=false
 fi
 fi

 if [ "$SETUP_FAL" = true ]; then
 read -r -s -p "Paste your fal.ai API key: " FAL_KEY; echo
 echo ""
 if [ -z "$FAL_KEY" ]; then
 echo -e "${RED}❌ No fal.ai key entered. Exiting.${NC}"
 exit 1
 fi
 sed -i '/^FAL_KEY/d' "$HOME/.openclaw/.env"
 echo "FAL_KEY=$FAL_KEY" >> "$HOME/.openclaw/.env"
 echo -e "${GREEN}✅ fal.ai key saved${NC}"
 echo ""
 fi
fi

# ── Ask for primary if both selected ─────────────────────────────────────────
PRIMARY=""
FALLBACK=""

if [ "$SETUP_OPENAI" = true ] && [ "$SETUP_FAL" = true ]; then
 echo -e "${BOLD}Which one do you want as your primary provider?${NC}"
echo ""
echo " 1) OpenAI (gpt-image-1) — Best quality"
echo " 2) fal.ai (flux-2-pro) — Cheaper"
echo ""
 read -p "Enter 1 or 2: " PRIMARY_CHOICE
 echo ""

 if [ "$PRIMARY_CHOICE" = "1" ]; then
 PRIMARY="openai/gpt-image-1"
 FALLBACK="fal/fal-ai/flux-2-pro"
 echo -e "${GREEN}✅ Primary: OpenAI | Fallback: fal.ai${NC}"
 elif [ "$PRIMARY_CHOICE" = "2" ]; then
 PRIMARY="fal/fal-ai/flux-2-pro"
 FALLBACK="openai/gpt-image-1"
 echo -e "${GREEN}✅ Primary: fal.ai | Fallback: OpenAI${NC}"
 else
 echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
 exit 1
 fi
 echo ""

elif [ "$SETUP_OPENAI" = true ]; then
 PRIMARY="openai/gpt-image-1"
elif [ "$SETUP_FAL" = true ]; then
 PRIMARY="fal/fal-ai/flux-2-pro"
else
 echo -e "${RED}❌ No providers were configured. Exiting.${NC}"
 exit 1
fi

# ── Update openclaw.json ──────────────────────────────────────────────────────
echo -e "${YELLOW}Updating openclaw.json...${NC}"

if [ -n "$FALLBACK" ]; then
 node -e "
 const fs = require('fs');
 const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
 cfg.agents = cfg.agents || {};
 cfg.agents.defaults = cfg.agents.defaults || {};
 cfg.agents.defaults.imageGenerationModel = {
 primary: '$PRIMARY',
 fallbacks: ['$FALLBACK']
 };
 fs.writeFileSync('$CONFIG', JSON.stringify(cfg, null, 2));
 console.log('✅ openclaw.json updated with primary + fallback');
 "
else
 node -e "
 const fs = require('fs');
 const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
 cfg.agents = cfg.agents || {};
 cfg.agents.defaults = cfg.agents.defaults || {};
 cfg.agents.defaults.imageGenerationModel = '$PRIMARY';
 fs.writeFileSync('$CONFIG', JSON.stringify(cfg, null, 2));
 console.log('✅ openclaw.json updated');
 "
fi

# ── Create flux2pro skill if fal selected ────────────────────────────────────
if [ "$SETUP_FAL" = true ]; then
 echo ""
 echo -e "${YELLOW}Creating flux2pro skill...${NC}"

 SKILL_DIR="$HOME/.openclaw/skills/flux2pro"
 mkdir -p "$SKILL_DIR"

 cat > "$SKILL_DIR/SKILL.md" << 'SKILLEOF'
---
name: flux2pro
description: Generate a high-quality image using fal.ai flux-2-pro. Use this when the user asks to generate an image, create a thumbnail, or visualize something.
---

# Flux 2 Pro Image Generation

When the user asks to generate an image, use the `exec` tool to run this curl command, replacing the prompt with what the user asked for:

```bash
curl --silent --request POST \
 --url https://queue.fal.run/fal-ai/flux-2-pro \
 --header "Authorization: Key $FAL_KEY" \
 --header "Content-Type: application/json" \
 --data '{
 "prompt": "USER_PROMPT_HERE",
 "image_size": "landscape_4_3",
 "safety_tolerance": "2",
 "enable_safety_checker": true,
 "output_format": "jpeg"
 }'
```

After getting the response, extract the image URL from the JSON and share it with the user.
SKILLEOF

 echo -e "${GREEN}✅ flux2pro skill created at $SKILL_DIR/SKILL.md${NC}"
fi

# ── Restart gateway ───────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
openclaw gateway restart
echo -e "${GREEN}✅ Gateway restarted${NC}"

# ── Verify skill if fal selected ─────────────────────────────────────────────
if [ "$SETUP_FAL" = true ]; then
 echo ""
 echo -e "${YELLOW}Verifying flux2pro skill...${NC}"
 openclaw skills list | grep flux2pro && echo -e "${GREEN}✅ flux2pro skill is active${NC}" || echo -e "${YELLOW}⚠️ Tell your agent: 'I installed a new skill called flux2pro at ~/.openclaw/skills/flux2pro/SKILL.md'${NC}"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN} Setup complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Primary provider: ${BOLD}$PRIMARY${NC}"
[ -n "$FALLBACK" ] && echo -e "Fallback provider: ${BOLD}$FALLBACK${NC}"
echo ""
echo "Test it by asking your agent:"
echo " Generate an image of a futuristic African city skyline at sunset"
echo ""
