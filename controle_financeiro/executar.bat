@echo off
title Controle Financeiro - Flutter App
cls

echo.
echo ========================================
echo       CONTROLE FINANCEIRO 
echo         Flutter Web App
echo ========================================
echo.

cd /d "%~dp0"

:: Verificar se Flutter está instalado
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERRO: Flutter nao encontrado no PATH!
    echo Instale o Flutter e adicione ao PATH do sistema.
    pause
    exit /b 1
)

:: Parar servidores anteriores
echo [1/3] Parando servidores anteriores...
taskkill /f /im "dart.exe" >nul 2>&1

:: Instalar dependencias
echo [2/3] Instalando dependencias...
flutter pub get
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependencias!
    echo Verifique sua conexao com a internet e tente novamente.
    pause
    exit /b 1
)

:: Iniciar servidor
echo [3/3] Iniciando servidor web...
echo.
echo ========================================
echo  App disponivel em: http://localhost:8095
echo  Para parar: Ctrl+C
echo ========================================
echo.

:: Abrir navegador automaticamente após 3 segundos
timeout /t 3 /nobreak >nul
start "" "http://localhost:8095"

flutter run -d web-server --web-port=8095

pause
