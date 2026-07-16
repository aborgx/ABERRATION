@echo off
REM ============================================================
REM Full Pipeline — Installazione + Generazione 13 Nemici
REM ============================================================

echo.
echo ========================================
echo  ABERRATION — Full Enemy Mesh Pipeline
echo ========================================
echo.
echo Questo script:
echo   1. Installa Hunyuan3D-2.1 (se non presente)
echo   2. Avvia il server
echo   3. Genera i 13 modelli nemici
echo   4. Esegue post-processing (retopology, rigging)
echo.

set INSTALL_DIR=E:\Applicazioni\Hunyuan3D2
set PIPELINE_DIR=E:\Giochini\Giuseppe\pipeline

REM ========================================
REM STEP 1: Installazione Hunyuan3D
REM ========================================

if not exist "%INSTALL_DIR%\RUN.bat" (
    echo [STEP 1] Installazione Hunyuan3D-2.1...
    echo.
    call "%PIPELINE_DIR%\setup_hunyuan3d.bat"
    
    if not exist "%INSTALL_DIR%\RUN.bat" (
        echo ERRORE: Installazione fallita.
        pause
        exit /b 1
    )
) else (
    echo [STEP 1] Hunyuan3D già installato.
)

REM ========================================
REM STEP 2: Avvio Server
REM ========================================

echo.
echo [STEP 2] Avvio server Hunyuan3D...
echo.

cd /d "%INSTALL_DIR%"
start "Hunyuan3D Server" RUN.bat

echo Attesa avvio server (60 secondi)...
timeout /t 60 /nobreak >nul

REM Verifica server
curl -s http://localhost:8080 >nul 2>&1
if %errorlevel% neq 0 (
    echo ATTENDI: Server potrebbe non essere ancora pronto.
    echo Se vedi errori, controlla la finestra del server.
    echo.
    pause
)

REM ========================================
REM STEP 3: Generazione Modelli
REM ========================================

echo.
echo [STEP 3] Generazione 13 modelli nemici...
echo.

cd /d "%PIPELINE_DIR%"
python batch_hunyuan3d.py

REM ========================================
REM STEP 4: Post-Processing
REM ========================================

echo.
echo [STEP 4] Post-processing...
echo.
echo Dopo aver generato i modelli, esegui:
echo   - Retopology: pipeline\remesh.py
echo   - Rigging: Mixamo (https://www.mixamo.com)
echo   - Animazioni: Mixamo o Blender
echo.

echo.
echo ========================================
echo  PIPELINE COMPLETATA
echo ========================================
echo.
echo Output: %PIPELINE_DIR%\raw_enemies\
echo.
pause
