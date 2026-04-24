@echo off
REM ============================================
REM Serveur Local Workshop Website (Windows)
REM ============================================

echo.
echo ===========================================
echo   Workshop Event-Driven - Serveur Local
echo ===========================================
echo.

cd /d %~dp0static

REM Vérifier Python
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [*] Demarrage avec Python...
    echo [*] URL: http://localhost:8000
    echo.
    python -m http.server 8000
    goto :end
)

REM Vérifier Node.js
where npx >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [*] Demarrage avec Node.js...
    echo [*] URL: http://localhost:8000
    echo.
    npx http-server -p 8000
    goto :end
)

REM Aucun serveur disponible
echo [!] Erreur: Python ou Node.js requis
echo.
echo Installez l'un des deux:
echo   - Python: https://www.python.org/downloads/
echo   - Node.js: https://nodejs.org/
echo.
pause
goto :end

:end
