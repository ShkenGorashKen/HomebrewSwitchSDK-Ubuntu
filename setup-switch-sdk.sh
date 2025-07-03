#!/usr/bin/env bash

set -e

# Detecta usuario real y directorio home
USER_REAL=$(logname 2>/dev/null || echo "$SUDO_USER")
HOME_REAL=$(eval echo "~$USER_REAL")

# Detectar carpeta donde está este script (setup-switch-sdk.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detectar idioma
LANGSHORT=$(echo $LANG | cut -c1-2)
if [[ "$LANGSHORT" == "es" ]]; then
  MSG_INSTALL="🚀 Instalando toolchain, libs y SDL2 desde devkitPro pacman..."
else
  MSG_INSTALL="🚀 Installing toolchain, libs and SDL2 from devkitPro pacman..."
fi

# === Función para instalar paquetes ===
function install_packages {
  echo "$MSG_INSTALL"
  apt update
  apt install -y git cmake make gcc g++ pkg-config unzip zip curl

  # Instalar devkitPro pacman si no está
  if ! command -v dkp-pacman &>/dev/null; then
    bash <(curl -fsSL https://downloads.devkitpro.org/devkitpro-pacman/install-devkitpro-pacman.sh)
  fi

  dkp-pacman -Syu --noconfirm

  dkp-pacman -S --noconfirm devkitA64 libnx switch-tools switch-cmake switch-pkg-config \
  switch-sdl2 switch-sdl2_ttf switch-sdl2_gfx switch-sdl2_mixer
}

# === SCRIPT PRINCIPAL ===

if [ "$EUID" -ne 0 ]; then
  echo "⚠️ Por favor, ejecuta este script como root con sudo para instalar paquetes."
  echo "Ejemplo: sudo $0"
  exit 1
fi

install_packages

# Exportar variables para entorno usuario real (muy importante para devkitpro)
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=$DEVKITPRO/devkitARM
export DEVKITA64=$DEVKITPRO/devkitA64
export DEVKITPPC=$DEVKITPRO/devkitPPC
export DEVKITSH=$DEVKITPRO/devkitSH
export DEVKITSF=$DEVKITPRO/devkitSF
export DEVKITNDS=$DEVKITPRO/devkitNDS
export DEVKITFLEX=$DEVKITPRO/devkitFlex
export DEVKITGBA=$DEVKITPRO/devkitGBA
export DEVKITMSP430=$DEVKITPRO/devkitMSP430
export DEVKITPOWERPC=$DEVKITPRO/devkitPowerPC
export DEVKITPSP2=$DEVKITPRO/devkitPSP2
export DEVKITVITA=$DEVKITPRO/devkitVita
export DEVKITXENON=$DEVKITPRO/devkitXenon
export DEVKITLPC11UXX=$DEVKITPRO/devkitLPC11UXX
export DEVKITARM64=$DEVKITPRO/devkitARM64
export DEVKITZ80=$DEVKITPRO/devkitZ80
export DEVKITRISCV=$DEVKITPRO/devkitRISC
export DEVKITFREERTOS=$DEVKITPRO/devkitFreeRTOS
export DEVKITNITRO=$DEVKITPRO/devkitNitro
export DEVKITN3DS=$DEVKITPRO/devkitN3DS
export DEVKITNX=$DEVKITPRO/devkitNX

export PATH=$PATH:$DEVKITPRO/tools/bin:$DEVKITA64/bin:$DEVKITARM/bin

# Ejecutar el segundo script (create-project.sh) como usuario real
sudo -u "$USER_REAL" env DEVKITPRO="$DEVKITPRO" DEVKITA64="$DEVKITA64" DEVKITNX="$DEVKITNX" PATH="$PATH" bash "$SCRIPT_DIR/create-project.sh"
>>>>>>> 7d52999 (Agrego nuevos scripts y actualizo setup)
