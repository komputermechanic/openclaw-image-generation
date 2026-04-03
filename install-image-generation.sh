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
echo -e "${CYAN}  OpenClaw Image Generation Setup${NC}"
echo -e "${CYAN}  By Komputer Mechanic${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "${YELLOW}Disclaimer:${NC}"
echo "Use this setup script at your own risk."
echo "Komputer Mechanic is not liable for mistakes, misconfiguration,"
echo "downtime, or any errors caused by using this script."
echo "For help and tutorials, visit: https://komputermechanic.com/"
echo ""
read -p "Do you want to proceed? (y/n): " PROCEED_SETUP
echo ""
if [ "$PROCEED_SETUP" != "y" ]; then
  echo -e "${YELLOW}Setup cancelled.${NC}"
  exit 0
fi

# ── Check openclaw.json exists ───────────────────────────────────────────────
CONFIG="$HOME/.openclaw/openclaw.json"
if [ ! -f "$CONFIG" ]; then
  echo -e "${RED}❌ openclaw.json not found at $CONFIG${NC}"
  echo "Make sure OpenClaw is installed before running this script."
  exit 1
fi

mkdir -p "$HOME/.openclaw"
touch "$HOME/.openclaw/.env"

# ============================================
# FAL MODEL SELECTION FUNCTION
# ============================================
select_fal_model() {
  echo -e "${BOLD}Which fal.ai model do you want to use?${NC}"
  echo ""
  echo "  Generate only:"
  echo "    1) FLUX.1 Dev       (fal-ai/flux/dev)          — General use, ~\$0.025/image"
  echo "    2) FLUX.1 Schnell   (fal-ai/flux/schnell)      — Ultra fast, cheapest"
  echo "    3) FLUX.1.1 Pro     (fal-ai/flux-pro/v1.1)     — Enhanced quality"
  echo "    4) FLUX.2 Flex      (fal-ai/flux-2-flex)       — Fine control, typography"
  echo ""
  echo "  Generate + Edit:"
  echo "    5) FLUX.2 Pro       (fal-ai/flux-2-pro)        — Best photorealism, ~\$0.03/image"
  echo "    6) Nano Banana 2    (fal-ai/nano-banana-2)     — Google, fast + edit"
  echo "    7) Nano Banana Pro  (fal-ai/nano-banana-pro)   — Google, highest quality"
  echo ""
  read -p "Enter 1-7: " FAL_MODEL_CHOICE
  echo ""

  case "$FAL_MODEL_CHOICE" in
    1) FAL_MODEL_ID="fal-ai/flux/dev";        FAL_MODEL_NAME="FLUX.1 Dev";       FAL_SUPPORTS_EDIT=false ;;
    2) FAL_MODEL_ID="fal-ai/flux/schnell";    FAL_MODEL_NAME="FLUX.1 Schnell";   FAL_SUPPORTS_EDIT=false ;;
    3) FAL_MODEL_ID="fal-ai/flux-pro/v1.1";  FAL_MODEL_NAME="FLUX.1.1 Pro";     FAL_SUPPORTS_EDIT=false ;;
    4) FAL_MODEL_ID="fal-ai/flux-2-flex";     FAL_MODEL_NAME="FLUX.2 Flex";      FAL_SUPPORTS_EDIT=false ;;
    5) FAL_MODEL_ID="fal-ai/flux-2-pro";      FAL_MODEL_NAME="FLUX.2 Pro";       FAL_SUPPORTS_EDIT=true ;;
    6) FAL_MODEL_ID="fal-ai/nano-banana-2";   FAL_MODEL_NAME="Nano Banana 2";    FAL_SUPPORTS_EDIT=true ;;
    7) FAL_MODEL_ID="fal-ai/nano-banana-pro"; FAL_MODEL_NAME="Nano Banana Pro";  FAL_SUPPORTS_EDIT=true ;;
    *)
      echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
      exit 1
      ;;
  esac

  echo -e "${GREEN}✅ Selected: $FAL_MODEL_NAME ($FAL_MODEL_ID)${NC}"
  echo ""
}

# ============================================
# CREATE FAL SKILL FUNCTION
# ============================================
create_fal_skill() {
  SKILL_DIR="$HOME/.openclaw/skills/fal-image"
  mkdir -p "$SKILL_DIR"

  if [ "$FAL_SUPPORTS_EDIT" = true ]; then
    EDIT_ENDPOINT="${FAL_MODEL_ID}/edit"
    cat > "$SKILL_DIR/SKILL.md" << SKILLEOF
---
name: fal_image
description: Generate or edit a high-quality image using fal.ai $FAL_MODEL_NAME. Use this when the user asks to generate an image, create a thumbnail, visualize something, or edit/modify an existing image.
---

# fal.ai $FAL_MODEL_NAME — Image Generation & Editing

This skill supports two modes:
1. **Generate** — create a new image from a prompt
2. **Edit** — modify an existing image using a prompt and an image URL

---

## Mode 1: Generate a new image

When the user asks to generate or create an image, use the \`exec\` tool to run this curl command:

\`\`\`bash
curl --silent --request POST \\
  --url https://queue.fal.run/$FAL_MODEL_ID \\
  --header "Authorization: Key \$FAL_KEY" \\
  --header "Content-Type: application/json" \\
  --data '{
    "prompt": "USER_PROMPT_HERE",
    "image_size": "landscape_4_3",
    "safety_tolerance": "2",
    "enable_safety_checker": true,
    "output_format": "jpeg"
  }'
\`\`\`

After getting the response, extract the image URL from the JSON and share it with the user.

---

## Mode 2: Edit an existing image

When the user asks to edit or modify an existing image and provides an image URL, use the \`exec\` tool:

\`\`\`bash
curl --silent --request POST \\
  --url https://queue.fal.run/$EDIT_ENDPOINT \\
  --header "Authorization: Key \$FAL_KEY" \\
  --header "Content-Type: application/json" \\
  --data '{
    "prompt": "EDIT_INSTRUCTION_HERE",
    "image_urls": ["IMAGE_URL_HERE"],
    "image_size": "auto",
    "safety_tolerance": "2",
    "enable_safety_checker": true,
    "output_format": "jpeg"
  }'
\`\`\`

Replace EDIT_INSTRUCTION_HERE with what the user wants changed and IMAGE_URL_HERE with the image URL.

After getting the response, extract the image URL from the JSON and share it with the user.

---

## Notes
- For editing, the user must provide a publicly accessible image URL
- Generation pricing: ~\$0.03 per megapixel
- Edit pricing: \$0.03 first megapixel, \$0.015 per additional megapixel
SKILLEOF

  else
    cat > "$SKILL_DIR/SKILL.md" << SKILLEOF
---
name: fal_image
description: Generate a high-quality image using fal.ai $FAL_MODEL_NAME. Use this when the user asks to generate an image, create a thumbnail, or visualize something.
---

# fal.ai $FAL_MODEL_NAME — Image Generation

When the user asks to generate or create an image, use the \`exec\` tool to run this curl command:

\`\`\`bash
curl --silent --request POST \\
  --url https://queue.fal.run/$FAL_MODEL_ID \\
  --header "Authorization: Key \$FAL_KEY" \\
  --header "Content-Type: application/json" \\
  --data '{
    "prompt": "USER_PROMPT_HERE",
    "image_size": "landscape_4_3",
    "safety_tolerance": "2",
    "enable_safety_checker": true,
    "output_format": "jpeg"
  }'
\`\`\`

After getting the response, extract the image URL from the JSON and share it with the user.

---

## Notes
- This model supports generation only — editing is not available
- For image editing, consider switching to FLUX.2 Pro or Nano Banana 2
SKILLEOF
  fi

  echo -e "${GREEN}✅ fal.ai skill created at $SKILL_DIR/SKILL.md${NC}"
}

# ============================================
# WHAT DO YOU WANT TO DO?
# ============================================
echo -e "${BOLD}What do you want to do?${NC}"
echo ""
echo "  1) Fresh setup    — Configure image generation from scratch"
echo "  2) Switch model   — Change your current fal.ai model"
echo "  3) Update keys    — Replace your OpenAI or fal.ai API key"
echo "  4) Uninstall      — Remove image generation from OpenClaw"
echo ""
read -p "Enter 1, 2, 3 or 4: " ACTION_CHOICE
echo ""

# ============================================
# UNINSTALL FLOW
# ============================================
if [ "$ACTION_CHOICE" = "4" ]; then

  echo -e "${YELLOW}This will:${NC}"
  echo "  - Remove imageGenerationModel from openclaw.json"
  echo "  - Delete the fal-image skill folder"
  echo "  - Optionally remove your API keys from .env"
  echo ""
  read -p "Are you sure you want to uninstall? (y/n): " CONFIRM_UNINSTALL
  echo ""
  if [ "$CONFIRM_UNINSTALL" != "y" ]; then
    echo -e "${YELLOW}Uninstall cancelled.${NC}"
    exit 0
  fi

  # Remove imageGenerationModel from openclaw.json
  echo -e "${YELLOW}Removing imageGenerationModel from openclaw.json...${NC}"
  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
    if (cfg.agents && cfg.agents.defaults) {
      delete cfg.agents.defaults.imageGenerationModel;
    }
    fs.writeFileSync('$CONFIG', JSON.stringify(cfg, null, 2));
    console.log('✅ imageGenerationModel removed from openclaw.json');
  "

  # Delete skill folder
  SKILL_DIR="$HOME/.openclaw/skills/fal-image"
  if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    echo -e "${GREEN}✅ fal-image skill folder deleted${NC}"
  else
    echo -e "${YELLOW}⚠️  No fal-image skill folder found — skipping${NC}"
  fi

  # Ask about API keys
  echo ""
  read -p "Do you also want to remove your API keys from .env? (y/n): " REMOVE_KEYS
  echo ""
  if [ "$REMOVE_KEYS" = "y" ]; then
    read -p "Remove FAL_KEY? (y/n): " REMOVE_FAL_KEY
    if [ "$REMOVE_FAL_KEY" = "y" ]; then
      sed -i '/^FAL_KEY/d' "$HOME/.openclaw/.env"
      echo -e "${GREEN}✅ FAL_KEY removed${NC}"
    fi

    read -p "Remove OPENAI_API_KEY? (y/n): " REMOVE_OPENAI_KEY
    if [ "$REMOVE_OPENAI_KEY" = "y" ]; then
      sed -i '/^OPENAI_API_KEY/d' "$HOME/.openclaw/.env"
      echo -e "${GREEN}✅ OPENAI_API_KEY removed${NC}"
    fi
  fi

  # Restart gateway
  echo ""
  echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
  openclaw gateway restart
  echo -e "${GREEN}✅ Gateway restarted${NC}"

  echo ""
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}  Uninstall complete!${NC}"
  echo -e "${GREEN}============================================${NC}"
  echo ""
  echo "Image generation has been removed from your OpenClaw setup."
  echo "Run this script again anytime to set it up again."
  echo ""
  exit 0
fi

# ============================================
# UPDATE KEYS FLOW
# ============================================
if [ "$ACTION_CHOICE" = "3" ]; then

  echo -e "${BOLD}Which API key do you want to update?${NC}"
  echo ""
  echo "  1) fal.ai key     (FAL_KEY)          — Used by all fal.ai models"
  echo "  2) OpenAI key     (OPENAI_API_KEY)   — Used by gpt-image-1 only"
  echo "  3) Both keys"
  echo ""
  echo -e "${YELLOW}Note: fal.ai and OpenAI use separate keys. Make sure you paste the correct key for each provider.${NC}"
  echo ""
  read -p "Enter 1, 2 or 3: " KEY_CHOICE
  echo ""

  if [ "$KEY_CHOICE" != "1" ] && [ "$KEY_CHOICE" != "2" ] && [ "$KEY_CHOICE" != "3" ]; then
    echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
    exit 1
  fi

  if [ "$KEY_CHOICE" = "1" ] || [ "$KEY_CHOICE" = "3" ]; then
    echo -e "${BOLD}Updating fal.ai key (FAL_KEY)${NC}"
    echo "This key is used by ALL fal.ai models (FLUX, Nano Banana, etc.)"
    echo "Get your key at: https://fal.ai/dashboard/keys"
    echo ""
    read -r -s -p "Paste your fal.ai API key: " NEW_FAL_KEY; echo
    echo ""
    if [ -z "$NEW_FAL_KEY" ]; then
      echo -e "${RED}❌ No fal.ai key entered. Exiting.${NC}"
      exit 1
    fi
    sed -i '/^FAL_KEY/d' "$HOME/.openclaw/.env"
    echo "FAL_KEY=$NEW_FAL_KEY" >> "$HOME/.openclaw/.env"
    echo -e "${GREEN}✅ fal.ai key updated${NC}"
    echo ""
  fi

  if [ "$KEY_CHOICE" = "2" ] || [ "$KEY_CHOICE" = "3" ]; then
    echo -e "${BOLD}Updating OpenAI key (OPENAI_API_KEY)${NC}"
    echo "This key is used ONLY by the OpenAI provider (gpt-image-1)."
    echo "Get your key at: https://platform.openai.com/api-keys"
    echo ""
    read -r -s -p "Paste your OpenAI API key: " NEW_OPENAI_KEY; echo
    echo ""
    if [ -z "$NEW_OPENAI_KEY" ]; then
      echo -e "${RED}❌ No OpenAI key entered. Exiting.${NC}"
      exit 1
    fi
    sed -i '/^OPENAI_API_KEY/d' "$HOME/.openclaw/.env"
    echo "OPENAI_API_KEY=$NEW_OPENAI_KEY" >> "$HOME/.openclaw/.env"
    echo -e "${GREEN}✅ OpenAI key updated${NC}"
    echo ""
  fi

  echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
  openclaw gateway restart
  echo -e "${GREEN}✅ Gateway restarted${NC}"

  echo ""
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}  API key(s) updated successfully!${NC}"
  echo -e "${GREEN}============================================${NC}"
  echo ""
  echo "Your new key(s) are saved and the gateway has been restarted."
  echo "Run a quick image generation test to confirm everything is working."
  echo ""
  exit 0
fi

# ============================================
# SWITCH MODEL FLOW
# ============================================
if [ "$ACTION_CHOICE" = "2" ]; then

  CURRENT_MODEL=$(node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
    const m = cfg.agents && cfg.agents.defaults && cfg.agents.defaults.imageGenerationModel;
    if (!m) { console.log('none'); }
    else if (typeof m === 'string') { console.log(m); }
    else { console.log(m.primary + ' (fallback: ' + (m.fallbacks || []).join(', ') + ')'); }
  " 2>/dev/null)

  echo -e "Current model: ${BOLD}$CURRENT_MODEL${NC}"
  echo ""

  select_fal_model

  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG', 'utf8'));
    cfg.agents = cfg.agents || {};
    cfg.agents.defaults = cfg.agents.defaults || {};
    const current = cfg.agents.defaults.imageGenerationModel;

    if (current && typeof current === 'object') {
      if (current.primary && current.primary.startsWith('fal/')) {
        current.primary = 'fal/$FAL_MODEL_ID';
      }
      if (current.fallbacks) {
        current.fallbacks = current.fallbacks.map(f =>
          f.startsWith('fal/') ? 'fal/$FAL_MODEL_ID' : f
        );
      }
      cfg.agents.defaults.imageGenerationModel = current;
    } else {
      cfg.agents.defaults.imageGenerationModel = 'fal/$FAL_MODEL_ID';
    }

    fs.writeFileSync('$CONFIG', JSON.stringify(cfg, null, 2));
    console.log('✅ openclaw.json updated with new fal model');
  "

  create_fal_skill

  echo ""
  echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
  openclaw gateway restart
  echo -e "${GREEN}✅ Gateway restarted${NC}"

  echo ""
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}  Model switched successfully!${NC}"
  echo -e "${GREEN}============================================${NC}"
  echo ""
  echo -e "New fal.ai model: ${BOLD}$FAL_MODEL_NAME${NC}"
  if [ "$FAL_SUPPORTS_EDIT" = true ]; then
    echo -e "Edit support:     ${GREEN}✅ Yes${NC}"
  else
    echo -e "Edit support:     ${YELLOW}❌ No${NC}"
  fi
  echo ""
  echo ""
  echo -e "${CYAN}============================================${NC}"
  echo -e "${CYAN}  Copy and send this to your agent:${NC}"
  echo -e "${CYAN}============================================${NC}"
  echo ""
  echo "Hey! I just updated your image generation skill fal_image to use $FAL_MODEL_NAME."
  echo "The updated skill file is located at ~/.openclaw/skills/fal-image/SKILL.md"
  echo ""
  echo "Please do the following:"
  echo "1. Re-read the skill file at that location"
  echo "2. Confirm you understand the updated configuration"
  echo "3. Run a smoke test by generating this image:"
  echo "   A futuristic African city skyline at sunset, cinematic lighting"
  echo "4. Return the image URL to confirm everything is working"
  echo ""
  echo -e "${CYAN}============================================${NC}"
  echo ""
  exit 0
fi

# ============================================
# FRESH SETUP FLOW
# ============================================
if [ "$ACTION_CHOICE" != "1" ]; then
  echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
  exit 1
fi

echo -e "${BOLD}Which providers do you want to set up?${NC}"
echo ""
echo "  1) OpenAI only       (gpt-image-1)     — Best quality, ~\$0.17/image"
echo "  2) fal.ai only       (choose model)    — Multiple models available"
echo "  3) Both              (OpenAI + fal.ai) — Set primary and fallback"
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

if [ "$SETUP_OPENAI" = true ]; then
  if grep -q "OPENAI_API_KEY" "$HOME/.openclaw/.env" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  An existing OpenAI key was found in your .env file.${NC}"
    read -p "Do you want to replace it? (y/n): " REPLACE_OPENAI
    echo ""
    if [ "$REPLACE_OPENAI" != "y" ]; then
      echo "Keeping existing OpenAI key."
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

FAL_MODEL_ID=""
FAL_MODEL_NAME=""
FAL_SUPPORTS_EDIT=false

if [ "$SETUP_FAL" = true ]; then
  select_fal_model

  if grep -q "FAL_KEY" "$HOME/.openclaw/.env" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  An existing fal.ai key was found in your .env file.${NC}"
    read -p "Do you want to replace it? (y/n): " REPLACE_FAL
    echo ""
    if [ "$REPLACE_FAL" = "y" ]; then
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
  else
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

PRIMARY=""
FALLBACK=""

if [ "$SETUP_OPENAI" = true ] && [ "$SETUP_FAL" = true ]; then
  echo -e "${BOLD}Which one do you want as your primary provider?${NC}"
  echo ""
  echo "  1) OpenAI (gpt-image-1)"
  echo "  2) fal.ai ($FAL_MODEL_NAME)"
  echo ""
  read -p "Enter 1 or 2: " PRIMARY_CHOICE
  echo ""

  if [ "$PRIMARY_CHOICE" = "1" ]; then
    PRIMARY="openai/gpt-image-1"
    FALLBACK="fal/$FAL_MODEL_ID"
    echo -e "${GREEN}✅ Primary: OpenAI | Fallback: fal.ai ($FAL_MODEL_NAME)${NC}"
  elif [ "$PRIMARY_CHOICE" = "2" ]; then
    PRIMARY="fal/$FAL_MODEL_ID"
    FALLBACK="openai/gpt-image-1"
    echo -e "${GREEN}✅ Primary: fal.ai ($FAL_MODEL_NAME) | Fallback: OpenAI${NC}"
  else
    echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
    exit 1
  fi
  echo ""

elif [ "$SETUP_OPENAI" = true ]; then
  PRIMARY="openai/gpt-image-1"
elif [ "$SETUP_FAL" = true ]; then
  PRIMARY="fal/$FAL_MODEL_ID"
else
  echo -e "${RED}❌ No providers were configured. Exiting.${NC}"
  exit 1
fi

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

if [ "$SETUP_FAL" = true ]; then
  echo ""
  echo -e "${YELLOW}Creating fal.ai skill...${NC}"
  create_fal_skill
fi

echo ""
echo -e "${YELLOW}Restarting OpenClaw gateway...${NC}"
openclaw gateway restart
echo -e "${GREEN}✅ Gateway restarted${NC}"

if [ "$SETUP_FAL" = true ]; then
  echo ""
  echo -e "${YELLOW}Verifying fal.ai skill...${NC}"
  openclaw skills list | grep fal_image && echo -e "${GREEN}✅ fal_image skill is active${NC}" || echo -e "${YELLOW}⚠️  Tell your agent: 'I installed a new skill called fal_image at ~/.openclaw/skills/fal-image/SKILL.md'${NC}"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Primary provider:  ${BOLD}$PRIMARY${NC}"
[ -n "$FALLBACK" ] && echo -e "Fallback provider: ${BOLD}$FALLBACK${NC}"
if [ "$SETUP_FAL" = true ]; then
  echo -e "fal.ai model:      ${BOLD}$FAL_MODEL_NAME${NC}"
  if [ "$FAL_SUPPORTS_EDIT" = true ]; then
    echo -e "Edit support:      ${GREEN}✅ Yes${NC}"
  else
    echo -e "Edit support:      ${YELLOW}❌ No${NC}"
  fi
fi
echo ""
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  Copy and send this to your agent:${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Hey! I just configured a new image generation skill for you called fal_image."
echo "The skill file is located at ~/.openclaw/skills/fal-image/SKILL.md"
echo ""
echo "Please do the following:"
echo "1. Read the skill file at that location"
echo "2. Confirm you understand how to use it"
echo "3. Run a smoke test by generating this image:"
echo "   A futuristic African city skyline at sunset, cinematic lighting"
echo "4. Return the image URL to confirm everything is working"
echo ""
echo -e "${CYAN}============================================${NC}"
echo ""
