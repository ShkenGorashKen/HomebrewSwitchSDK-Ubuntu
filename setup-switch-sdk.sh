#!/bin/bash
set -e

echo "🚀 Iniciando entorno HomebrewSwitchSDK..."

REPO=https://github.com/libsdl-org/SDL.git
BRANCH=SDL2
SDK_DIR=~/HomebrewSwitchSDK
SDL_DIR=$SDK_DIR/SDL2-clean
BUILD_DIR=$SDL_DIR/build-switch
PREFIX=/opt/devkitpro/portlibs/switch

if [ "$MSYSTEM" != "MSYS" ]; then
  echo "❌ Este script debe ejecutarse desde 'MSYS2 MSYS'."
  exit 1
fi

echo "📦 Instalando paquetes base..."
pacman -S --noconfirm git curl autoconf automake libtool pkgconf m4 make gcc g++ patch grep

if [ ! -d "/opt/devkitpro/devkitA64" ]; then
  echo "🧭 Instalando devkitPro..."
  curl -fsSL https://apt.devkitpro.org/install-devkitpro-pacman | bash
  pacman -S --noconfirm devkitA64 libnx switch-tools
fi

export DEVKITPRO=/opt/devkitpro
export DEVKITA64=$DEVKITPRO/devkitA64
export PATH=$DEVKITPRO/tools/bin:$PATH

mkdir -p "$SDK_DIR/config-history"
rm -rf "$SDL_DIR"
git clone --branch $BRANCH $REPO "$SDL_DIR"
cd "$SDL_DIR"
cp configure.ac configure.ac.bak

if ! grep -q "aarch64-none-elf" configure.ac; then
  awk '
  BEGIN {inserted=0}
  {
    if (!inserted && /^\s*\*\)/ && /AC_MSG_ERROR/) {
      print "  *aarch64-none-elf*)";
      print "    ARCH=switch";
      print "    SDL_CFLAGS=\"$SDL_CFLAGS -D__SWITCH__\"";
      print "    EXTRA_CFLAGS=\"$EXTRA_CFLAGS\"";
      print "    EXTRA_LDFLAGS=\"$EXTRA_LDFLAGS\"";
      print "    CheckDummyAudio";
      print "    CheckDummyVideo";
      print "    CheckPTHREAD";
      print "    have_audio=yes";
      print "    have_video=yes";
      print "    SUMMARY_audio=\"${SUMMARY_audio} switch\"";
      print "    SUMMARY_video=\"${SUMMARY_video} switch\"";
      print "    ;;";
      inserted=1;
    }
    print $0;
  }' configure.ac > configure.ac.patched && mv configure.ac.patched configure.ac
fi

echo "⚙️ Generando configure..."
./autogen.sh

if ! grep -q "aarch64-none-elf" configure; then
  echo "❌ configure no reconoce aarch64-none-elf."
  exit 1
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

../configure --host=aarch64-none-elf --prefix="$PREFIX" \
  --disable-shared --enable-static \
  --enable-video --enable-audio \
  --enable-cpuinfo --enable-pthreads --enable-timers \
  --disable-video-opengles --disable-video-opengles2 --disable-video-egl \
  --disable-video-vulkan --disable-video-x11 --disable-video-wayland \
  --disable-render-metal --disable-render-d3d \
  --disable-libudev --disable-pulseaudio --disable-alsa --disable-filesystem

if [ ! -f Makefile ]; then
  echo "❌ Makefile no generado."
  exit 1
fi

make -j$(nproc)
make install

cd "$SDK_DIR"

echo "📦 Instalando dependencias de Plutonium..."
pacman -S --noconfirm \
  switch-sdl2 switch-sdl2_ttf switch-sdl2_image switch-sdl2_gfx switch-sdl2_mixer \
  switch-mesa switch-glad switch-glm switch-libdrm_nouveau \
  switch-libwebp switch-libpng switch-freetype switch-bzip2 \
  switch-libjpeg-turbo switch-opusfile switch-libopus

echo "📥 Clonando Plutonium..."
rm -rf Plutonium
git clone https://github.com/XorTroll/Plutonium.git
cd Plutonium
make -j$(nproc)

if [ ! -f "lib/libpu.a" ]; then
    echo "❌ Plutonium no compilado."
    exit 1
fi

cd "$SDK_DIR"
./verify-checksum.sh

echo "📛 Ingrese el nombre del proyecto:"
read PROJECT_NAME

DEMO_DIR="$SDK_DIR/$PROJECT_NAME"
mkdir -p "$DEMO_DIR/source"
mkdir -p "$DEMO_DIR/assets"

cat > "$DEMO_DIR/source/main.cpp" <<EOF
#include <pu/Plutonium>
#include <SDL2/SDL.h>
using namespace pu;
using namespace pu::ui;
using namespace pu::ui::elm;

class MainLayout : public Layout {
public:
    Label *title;
    TextEdit *input;
    Button *btn;
    TextBlock *credits;

    MainLayout() {
        title = new Label("title", "Proyecto: $PROJECT_NAME", 50, 40, 35);
        input = new TextEdit("input", "", 50, 100, 400, 50);
        btn = new Button("btn", "¡Saludar!", 470, 100, 150, 50);
        credits = new TextBlock("credits", "📜 Créditos:\\n"
            "- SDL2 (libsdl-org/SDL)\\n"
            "- libnx (switchbrew/libnx)\\n"
            "- Plutonium UI (XorTroll/Plutonium)\\n"
            "- HomebrewSwitchSDK creado por ShkenGorashKen\\n"
            "- GitHub: github.com/ShkenGorashKen", 50, 180, 600, 200);

        Add(title);
        Add(input);
        Add(btn);
        Add(credits);

        btn->OnClick([]() {
            Result::ShowOk("¡Hola desde Switch Homebrew!");
        });
    }
};

int main() {
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    Plutonium::Initialize();
    auto layout = new MainLayout();
    Window *win = new Window("Homebrew UI", 1280, 720);
    win->SetBaseLayout(layout);
    win->StartRenderLoop();
    SDL_Quit();
    return 0;
}
EOF

cat > "$DEMO_DIR/Makefile" <<EOF
TARGET := $PROJECT_NAME
BUILD := build
SOURCE := source
CXX := aarch64-none-elf-g++
CXXFLAGS := -g -Wall -O2 -std=gnu++17 -I/opt/devkitpro/libnx/include -I/opt/devkitpro/portlibs/switch/include -I../../Plutonium/include
LDFLAGS := -L/opt/devkitpro/portlibs/switch/lib -lSDL2 -lpu -lnx
OBJ := \$(patsubst \$(SOURCE)/%.cpp,\$(BUILD)/%.o,\$(wildcard \$(SOURCE)/*.cpp))

all: \$(BUILD) \$(TARGET).nro

\$(BUILD):
    mkdir -p \$(BUILD)

\$(BUILD)/%.o: \$(SOURCE)/%.cpp
    \$(CXX) \$(CXXFLAGS) -c -o \$@ \$<

\$(TARGET).nro: \$(OBJ)
    \$(CXX) -o \$(TARGET).elf \$^ \$(LDFLAGS)
    nxlink \$(TARGET).elf

clean:
    rm -rf \$(BUILD) \$(TARGET).elf \$(TARGET).nro
EOF

cat > "$DEMO_DIR/README.md" <<EOF
# $PROJECT_NAME

Proyecto homebrew creado con **HomebrewSwitchSDK**  
Desarrollado por **ShkenGorashKen** → [github.com/ShkenGorashKen](https://github.com/ShkenGorashKen)

## 🔧 Librerías instaladas

- devkitPro / devkitA64 / libnx / switch-tools
- SDL2 compilado con flags personalizados
- Plutonium UI
- Dependencias vía pacman:

\`\`\`bash
switch-sdl2 switch-sdl2_ttf switch-sdl2_image switch-sdl2_gfx switch-sdl2_mixer
switch-mesa switch-glad switch-glm switch-libdrm_nouveau
switch-libwebp switch-libpng switch-freetype switch-bzip2
switch-libjpeg-turbo switch-opusfile switch-libopus
\`\`\`

## 🖥️ Créditos

- SDL2 (libsdl-org)
- libnx (switchbrew)
- Plutonium (XorTroll)
- HomebrewSwitchSDK creado por ShkenGorashKen
EOF

echo "✅ Proyecto creado: $PROJECT_NAME"
