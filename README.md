# HomebrewSwitchSDK-Ubuntu 🎮🐧

Entorno de desarrollo automatizado para crear homebrew para Nintendo Switch desde Ubuntu/Linux. Ideal para desarrolladores de todos los niveles — incluso sin experiencia previa.

## 🧃 Características

- ✅ Instalación automática de dependencias vía `apt`
- ✅ Compilación limpia de SDL2 con flags personalizados
- ✅ Plutonium UI lista para usar con C++ moderno
- ✅ Proyecto demo generado con interfaz gráfica
- ✅ Compatible con `devkitA64`, `libnx`, y `nxlink`

## 🚀 Instalación

1. Cloná el repositorio:

   ```bash
   git clone https://github.com/ShkenGorashKen/HomebrewSwitchSDK-Ubuntu.git
   cd HomebrewSwitchSDK-Ubuntu

chmod +x setup-switch-sdk.sh
./setup-switch-sdk.sh

Ingresá el nombre de tu proyecto cuando se te pida 📦 Se generará automáticamente en /projects/ junto con su código fuente, Makefile, y README propio

🧰 Requisitos técnicos
Ubuntu 20.04+ o Debian 11+

Toolchain para Nintendo Switch (aarch64-none-elf-gcc)

💡 Podés instalar devkitA64 desde devkitpro.org

Git, curl, y acceso a internet

📁 Estructura de proyecto
HomebrewSwitchSDK-Ubuntu/
├── setup-switch-sdk.sh              # Instalador principal
├── verify-checksum.sh              # Fingerprint de SDL2
├── .gitignore                      # Ignora archivos temporales
├── SDL2-clean/                     # Código fuente SDL2
├── Plutonium/                      # Interfaz gráfica para Switch
└── projects/
    └── MiProyecto/
        ├── source/main.cpp         # Código base del homebrew
        ├── Makefile                # Reglas de compilación
        ├── assets/                 # Archivos del usuario
        └── README.md               # Info de tu proyecto
🔧 Compilación y envío
Dentro de tu proyecto generado:

bash
cd projects/MiProyecto
make
⚙️ Esto genera un archivo .nro para ser enviado vía nxlink.

🎮 Créditos
Este SDK fue creado por ShkenGorashKen

🔗 GitHub: github.com/ShkenGorashKen

Incluye herramientas y librerías de:

📦 SDL2 → libsdl-org/SDL

📦 libnx → switchbrew/libnx

🎨 Plutonium UI → XorTroll/Plutonium

🛠️ Toolchain → devkitPro/devkitA64

🧪 Versión actual
HomebrewSwitchSDK v1.0 – Ubuntu Edition 📅 Publicado: Julio 2025

✅ Preparado para recibir mejoras, ejemplos adicionales y opciones gráficas.

