#!/usr/bin/env bash
# compile-doom-config.sh - Byte-compile and native-compile Doom config
#
# Usage: ./scripts/compile-doom-config.sh [clean]
#        clean - Remove all .elc files before compiling

set -e

DOOM_DIR="${HOME}/.doom.d"
SCRIPT_DIR="${DOOM_DIR}/scripts"

echo "🚀 Doom Emacs Config Compilation"
echo "=================================="

# Check if clean flag is passed
if [[ "$1" == "clean" ]]; then
    echo "🧹 Cleaning old compiled files..."
    find "${DOOM_DIR}" -name "*.elc" -type f -delete
    echo "✅ Cleaned!"
    echo ""
fi

# Run compilation
echo "⚙️  Compiling config files..."
emacs --batch \
      --eval "(setq doom-dir \"${DOOM_DIR}\")" \
      -l "${SCRIPT_DIR}/compile-config.el"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS: All config files compiled!"
    echo ""
    echo "📝 Note: Restart Emacs to use compiled config."
    echo "   If you encounter issues, run: ./scripts/compile-doom-config.sh clean"
else
    echo ""
    echo "❌ ERROR: Compilation failed with exit code ${EXIT_CODE}"
    echo "   Check the output above for details."
    exit $EXIT_CODE
fi
