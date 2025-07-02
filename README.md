# HomebrewSwitchSDK

Entorno profesional para desarrollar homebrew en Nintendo Switch con SDL2, libnx y Plutonium.  
Creado por **ShkenGorashKen** → [github.com/ShkenGorashKen](https://github.com/ShkenGorashKen)

---

## 🎮 ¿Qué hace este SDK?


- Instala automáticamente devkitPro, libnx y toolchains
- Compila SDL2 limpio y estático para Switch
- Clona y compila Plutonium UI
- Instala todas las dependencias gráficas y multimedia
- Genera proyectos interactivos con UI, botón, entrada de texto y créditos
- Crea un fingerprint con toda la configuración usada

---

## 📦 Dependencias instaladas


```bash
switch-sdl2 switch-sdl2_ttf switch-sdl2_image switch-sdl2_gfx switch-sdl2_mixer
switch-mesa switch-glad switch-glm switch-libdrm_nouveau
switch-libwebp switch-libpng switch-freetype switch-bzip2
switch-libjpeg-turbo switch-opusfile switch-libopus

🛠️ Cómo usar


Abrí MSYS2 (terminal "MSYS2 MSYS")

Cloná este repositorio y ejecutá:

bash
chmod +x setup-switch-sdk.sh verify-checksum.sh
./setup-switch-sdk.sh
Ingresá el nombre del proyecto cuando se te pida

Entrá en la carpeta generada y compilá con:

bash
make


📜 Créditos


SDL2

libnx

Plutonium

SDK creado por ShkenGorashKen


📘 Licencia


Este proyecto se publica bajo GPLv3. Todo código derivado debe seguir siendo libre, abierto y accesible.