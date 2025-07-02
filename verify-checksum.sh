#!/bin/bash
set -e

PREFIX=~/HomebrewSwitchSDK/local-switch
LIB="$PREFIX/lib/libSDL2.a"
TIMESTAMP=$(date +"%Y%m%d-%H%M")
FINGERPRINT="config-history/fingerprint-$TIMESTAMP.json"

echo "🔍 Verificando binario $LIB..."

if [ ! -f "$LIB" ]; then
  echo "❌ libSDL2.a no encontrado en $PREFIX/lib"
  exit 1
fi

MD5=$(md5sum "$LIB" | cut -d ' ' -f1)
COMPILER=$(aarch64-none-elf-gcc --version | head -n1 | sed 's/^[^0-9]*//')

echo "✅ Hash MD5: $MD5"

mkdir -p config-history
cat > "$FINGERPRINT" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "sdk_version": "HomebrewSwitchSDK v1.0 (Ubuntu)",
  "sdl_branch": "SDL2",
  "flags": [
    "--disable-video-opengles",
    "--disable-video-egl",
    "--disable-video-vulkan",
    "--enable-static",
    "--disable-shared"
  ],
  "toolchain": {
    "compiler": "aarch64-none-elf-gcc",
    "version": "$COMPILER"
  },
  "checksum": {
    "libSDL2.a.md5": "$MD5"
  }
}
EOF

echo "🧬 Configuración registrada en $FINGERPRINT"
