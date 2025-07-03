#!/usr/bin/env bash

# =======================
# Script: create-project.sh
# =======================
# Autor: ShkenGorashKen
# Este script debe ejecutarse como USUARIO normal,
# después de correr setup-switch-sdk.sh

set -e

# Detectar idioma
LANG_SHORT=$(echo "$LANG" | cut -c1-2)
if [[ "$LANG_SHORT" == "es" ]]; then
    MSG_PROJECT="📁 Creando proyecto en:"
    MSG_CLONE="🎵 Clonando o actualizando Plutonium..."
    MSG_BUILD="🔧 Compilando Plutonium..."
    MSG_DONE="✅ Proyecto creado y Plutonium compilado correctamente."
    MSG_NXLINK="📤 Usa nxlink para enviar tu .nro con sphaira abierto en la consola."
    MSG_NXLINK_CMD="nxlink -a <IP_DE_TU_SWITCH> tu_app.nro"
    MSG_NXLINK_NOTE="Asegúrate de tener sphaira abierto en tu Nintendo Switch."
else
    MSG_PROJECT="📁 Creating project in:"
    MSG_CLONE="🎵 Cloning or updating Plutonium..."
    MSG_BUILD="🔧 Building Plutonium..."
    MSG_DONE="✅ Project created and Plutonium compiled successfully."
    MSG_NXLINK="📤 Use nxlink to send your .nro with sphaira open on your console."
    MSG_NXLINK_CMD="nxlink -a <YOUR_SWITCH_IP> your_app.nro"
    MSG_NXLINK_NOTE="Make sure sphaira is running on your Nintendo Switch."
fi

# Nombre del proyecto
read -p "💻 Nombre del proyecto: " PROJECT_NAME
PROJECT_DIR="$HOME/Documentos/$PROJECT_NAME"

echo "$MSG_PROJECT $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "$MSG_CLONE"
if [ -d Plutonium ]; then
    cd Plutonium
    if [ -d .git ]; then
        git pull
    else
        cd ..
        rm -rf Plutonium
        git clone https://github.com/XorTroll/Plutonium.git Plutonium
    fi
else
    git clone https://github.com/XorTroll/Plutonium.git Plutonium
fi

echo "$MSG_BUILD"
make -C Plutonium/Plutonium

# Crear carpetas necesarias
mkdir -p source include

# Validar que 'include' sea carpeta
if [ -e include ] && [ ! -d include ]; then
    echo "⚠️ 'include' existe pero no es un directorio. Eliminando..."
    rm -f include
    mkdir include
fi

# Copiar headers y libpu.a
cp -ru Plutonium/Plutonium/include/* include/

# Copiar libpu.a al directorio raíz del proyecto (o una carpeta lib/ que crees)
mkdir -p lib
cp Plutonium/Plutonium/lib/libpu.a lib/

# Crear main.cpp
cat << EOF > source/main.cpp
#include <pu/Plutonium>
using namespace pu;
using namespace pu::ui;

class MyLayout : public Layout {
    private:
        std::shared_ptr<TextBlock> text;

    public:
        MyLayout() {
            this->text = std::make_shared<TextBlock>("Pulsa un botón...", 50);
            this->text->SetX(50);
            this->text->SetY(50);
            this->Add(this->text);
        }

        void OnInput(u64 keys_down, u64, u64) override {
            if(keys_down & KEY_A) this->text->SetText("Botón A presionado");
            else if(keys_down & KEY_B) this->text->SetText("Botón B presionado");
            else if(keys_down & KEY_X) this->text->SetText("Botón X presionado");
            else if(keys_down & KEY_Y) this->text->SetText("Botón Y presionado");
        }
};

int main() {
    pu::Initialize();
    auto app = Application::New(std::make_shared<MyLayout>());
    app->Run();
    pu::Exit();
    return 0;
}
EOF

# Crear Makefile
cat << 'EOF' > Makefile
TARGET := $(notdir $(CURDIR))
BUILD := build
SRC := source
INCLUDE := include
DATA := data

LIBS := -lpu -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_gfx -lSDL2 -lbz2 -lz -lm

CXXFLAGS := -g -Wall -O2 -std=gnu++17
CFLAGS := -g -Wall -O2

include /opt/devkitpro/devkitA64/base_rules
EOF

# Crear archivos auxiliares
touch icon.jpg meta.xml nacp.txt

# Crear README
cat << EOF > README.md
# $PROJECT_NAME

Este es un proyecto Homebrew para Nintendo Switch usando Plutonium.

## Compilar

\`\`\`bash
make
\`\`\`

## Ejecutar en la consola

$MSG_NXLINK
$MSG_NXLINK_CMD

$MSG_NXLINK_NOTE
EOF

echo "$MSG_DONE"
echo "$MSG_NXLINK"
echo "$MSG_NXLINK_CMD"
echo "$MSG_NXLINK_NOTE"
