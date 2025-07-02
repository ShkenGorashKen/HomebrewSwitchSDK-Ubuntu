@echo off
SETLOCAL
SET SDK_DIR=%~dp0
SET MSYS_BASH=C:\msys64\usr\bin\bash.exe

IF EXIST "%MSYS_BASH%" (
    echo 🟢 MSYS2 detectado. Ejecutando HomebrewSwitchSDK...
    START "" "%MSYS_BASH%" -lc "cd '%SDK_DIR%' && ./setup-switch-sdk.sh"
) ELSE (
    echo ❌ MSYS2 no está instalado.
    echo 💡 Descárgalo desde https://www.msys2.org/
    echo Luego abrí 'MSYS2 MSYS' y ejecutá ./setup-switch-sdk.sh
    pause
)
ENDLOCAL
