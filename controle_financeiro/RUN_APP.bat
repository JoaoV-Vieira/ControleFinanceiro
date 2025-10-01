@echo off
title Controle Financeiro - Flutter App
cls

echo  ╔══════════════════════════════════════════════╗
echo  ║           CONTROLE FINANCEIRO                ║
echo  ║              Flutter App                     ║
echo  ╚══════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

:: Verificar Flutter
echo [1/4] Verificando Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERRO: Flutter nao encontrado no PATH!
    echo.
    echo Solucoes:
    echo 1. Instale o Flutter SDK
    echo 2. Adicione Flutter ao PATH do sistema
    echo 3. Reinicie o terminal
    echo.
    pause
    exit /b 1
)
echo ✅ Flutter encontrado!

:: Parar servidores anteriores
echo [2/4] Limpando servidores anteriores...
taskkill /f /im "dart.exe" >nul 2>&1
timeout /t 1 >nul

:: Instalar dependências
echo [3/4] Instalando dependencias...
flutter pub get >nul 2>&1

:: Iniciar servidor
echo [4/4] Iniciando servidor web...
echo.
echo ╔══════════════════════════════════════════════╗
echo ║  🌐 SERVIDOR ATIVO                           ║
echo ║  📱 URL: http://localhost:8095               ║
echo ║  🔄 Hot Reload: Habilitado                   ║
echo ║  ⏹️  Para parar: Ctrl+C                      ║
echo ╚══════════════════════════════════════════════╝
echo.

:: Abrir navegador automaticamente após 3 segundos
echo Abrindo navegador automaticamente...
start /min powershell -Command "Start-Sleep -Seconds 3; Start-Process 'http://localhost:8095'"

flutter run -d web-server --web-port=8095

echo.
echo App finalizado. Pressione qualquer tecla para sair...
pause >nul
