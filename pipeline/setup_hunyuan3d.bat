@echo off
REM ============================================================
REM Hunyuan3D-2.1 WinPortable — Setup Automatico
REM Installazione in E:\Applicazioni\Hunyuan3D2\
REM ============================================================

set INSTALL_DIR=E:\Applicazioni\Hunyuan3D2
set DOWNLOAD_URL=https://github.com/YanWenKun/Hunyuan3D-2-WinPortable/releases/download/v2025.07.01
set PART1=Hunyuan3D2_WinPortable_cu126.7z.001
set PART2=Hunyuan3D2_WinPortable_cu126.7z.002

echo.
echo ========================================
echo  Hunyuan3D-2.1 — Setup Automatico
echo ========================================
echo.

REM Crea cartella installazione
if not exist "%INSTALL_DIR%" (
    echo [1/4] Creazione cartella %INSTALL_DIR%...
    mkdir "%INSTALL_DIR%"
) else (
    echo [1/4] Cartella %INSTALL_DIR% già esistente.
)

REM Vai alla cartella installazione
cd /d "%INSTALL_DIR%"

REM Download parti
echo.
echo [2/4] Download pacchetti (~19GB)...
echo.

if not exist "%PART1%" (
    echo Download parte 1/2...
    powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%/%PART1%' -OutFile '%PART1%'"
) else (
    echo Parte 1 già scaricata.
)

if not exist "%PART2%" (
    echo Download parte 2/2...
    powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%/%PART2%' -OutFile '%PART2%'"
) else (
    echo Parte 2 già scaricata.
)

REM Estrai con 7-Zip
echo.
echo [3/4] Estrazione pacchetti...
echo.

where 7z >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: 7-Zip non trovato nel PATH.
    echo Installa 7-Zip da: https://7-zip.org/
    echo Oppure aggiungi 7z al PATH di sistema.
    echo.
    pause
    exit /b 1
)

REM Estrai solo la parte .001 (7-Zip gestisce automaticamente la .002)
7z x "%PART1%" -o"%INSTALL_DIR%" -y

if %errorlevel% neq 0 (
    echo ERRORE durante l'estrazione.
    pause
    exit /b 1
)

REM Pulisci file di download (opzionale)
echo.
echo [4/4] Pulizia...
del /q "%PART1%" "%PART2%" 2>nul

echo.
echo ========================================
echo  Setup completato!
echo ========================================
echo.
echo Per avviare Hunyuan3D-2.1:
echo   1. Vai in: %INSTALL_DIR%
echo   2. Esegui: RUN.bat
echo   3. Apri browser: http://localhost:8080
echo.
echo Primo avvio: scarica modelli (~19GB) — attendi!
echo.
pause
