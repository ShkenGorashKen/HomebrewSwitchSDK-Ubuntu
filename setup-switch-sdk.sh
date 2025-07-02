#!/bin/bash
set -e

echo "🚀 Iniciando instalación automática de HomebrewSwitchSDK para Ubuntu..."

# 🧭 Verificar sistema operativo
if [ -f /etc/os-release ]; then
    OS_ID=$(grep ^ID= /etc/os-release | cut -d'=' -f2 | tr -d '"')
    if [[ "$OS_ID" != "ubuntu" && "$OS_ID" != "debian" ]]; then
        echo "⚠️ Este script está diseñado para Ubuntu/Debian. Sistema detectado: $OS_ID"
        exit 1
    fi
else
    echo "❌ No se pudo detectar el sistema operativo."
    exit 1
fi

echo "📦 Actualizando sistema..."
sudo apt update

echo "📥 Instalando dependencias necesarias..."
sudo apt install -y \
  curl git build-essential autoconf automake libtool pkg-config \
  libglib2.0-dev libssl-dev zlib1g-dev libpng-dev libwebp-dev \
  libjpeg-dev libfreetype6-dev libopus-dev libdrm-dev libbz2-dev

# 🎯 Verificar toolchain
if ! command -v aarch64-none-elf-g++ &>/dev/null; then
  echo "❌ Toolchain para Switch no encontrado."
  echo "💡 Instalá devkitA64 manualmente desde https://devkitpro.org"
  exit 1
fi

echo "📁 Configurando estructura..."
SDK_DIR=~/HomebrewSwitchSDK
SDL_DIR=$SDK_DIR/SDL2-clean
BUILD_DIR=$SDL_DIR/build-switch
PREFIX=$SDK_DIR/local-switch
PROJECTS=$SDK_DIR/projects

mkdir -p "$SDK_DIR" "$PROJECTS"

echo "📦 Clonando SDL2..."
rm -rf "$SDL_DIR"
git clone --branch SDL2 https://github.com/libsdl-org/SDL.git "$SDL_DIR"
cd "$SDL_DIR"
./autogen.sh

echo "⚙️ Configurando SDL2 para Switch..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
../configure --host=aarch64-none-elf --prefix="$PREFIX" \
  --disable-shared --enable-static --enable-video --enable-audio \
  --enable-pthreads --enable-timers --disable-opengl --disable-x11 \
  --disable-libudev --disable-pulseaudio --disable-alsa

make -j$(nproc)
make install

echo "📥 Clonando Plutonium UI..."
cd "$SDK_DIR"
rm -rf Plutonium
git clone https://github.com/XorTroll/Plutonium.git
cd Plutonium
make -j$(nproc)

if [ ! -f "lib/libpu.a" ]; then
  echo "❌ Error al compilar Plutonium."
  exit 1
fi

echo "📛 Ingresá el nombre de tu proyecto:"
read PROJECT_NAME

DEMO_DIR="$PROJECTS/$PROJECT_NAME"
mkdir -p "$DEMO_DIR/source" "$DEMO_DIR/assets"

# 🧃 Código fuente demo
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
            "- SDL2 (libsdl-org)\\n"
            "- libnx (switchbrew)\\n"
            "- Plutonium UI (XorTroll)\\n"
            "- HomebrewSwitchSDK creado por ShkenGorashKen", 50, 180, 600, 200);

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

# 🎮 Makefile
cat > "$DEMO_DIR/Makefile" <<EOF
TARGET := $PROJECT_NAME
BUILD := build
SOURCE := source
CXX := aarch64-none-elf-g++
CXXFLAGS := -g -Wall -O2 -std=gnu++17 \\
    -I$PREFIX/include \\
    -I$SDK_DIR/Plutonium/include
LDFLAGS := -L$PREFIX/lib -L$SDK_DIR/Plutonium/lib -lSDL2 -lpu

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

# 📘 README del proyecto
cat > "$DEMO_DIR/README.md" <<EOF
# $PROJECT_NAME

Proyecto creado con **HomebrewSwitchSDK para Ubuntu**  
Creado por **ShkenGorashKen** → [github.com/ShkenGorashKen](https://github.com/ShkenGorashKen)

## 🧃 Librerías usadas

- SDL2 limpio y estático
- Plutonium UI para interfaz moderna
- Toolchain `devkitA64` para compilar para Nintendo Switch

## 🔧 Compilación

```bash
make
