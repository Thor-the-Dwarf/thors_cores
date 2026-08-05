@echo off
setlocal
chcp 65001 >nul

pushd "%~dp0" >nul || (
  echo Fehler: Der Toolordner konnte nicht geöffnet werden.
  exit /b 1
)

if "%~1"=="" goto :usage
if /I "%~1"=="start-chrome" goto :start_chrome
if /I "%~1"=="check" goto :check
if /I "%~1"=="dry-run" goto :dry_run
if /I "%~1"=="once" goto :once
if /I "%~1"=="run" goto :run
if /I "%~1"=="propose-html" goto :propose_html
goto :usage

:require_node
where node >nul 2>nul
if errorlevel 1 (
  echo Fehler: Node.js wurde nicht gefunden. Bitte Node.js LTS installieren.
  popd
  exit /b 1
)
exit /b 0

:start_chrome
set "BT_PORT=%~2"
if not defined BT_PORT set "BT_PORT=9222"
set "BT_CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%BT_CHROME%" set "BT_CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%BT_CHROME%" set "BT_CHROME=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if not exist "%BT_CHROME%" (
  echo Fehler: Google Chrome wurde an den üblichen Windows-Pfaden nicht gefunden.
  popd
  exit /b 1
)
start "" "%BT_CHROME%" --remote-debugging-port=%BT_PORT% --user-data-dir="%LocalAppData%\Thors-Cores-Bilder-Tool\ChromeProfile" https://chatgpt.com/
echo Chrome wurde mit einem lokalen, separaten DevTools-Profil auf Port %BT_PORT% gestartet.
echo Bitte in diesem Chrome-Profil bei ChatGPT anmelden und den gewünschten Chat öffnen.
popd
exit /b 0

:check
call :require_node
if errorlevel 1 exit /b 1
set "BT_PORT=%~2"
if not defined BT_PORT set "BT_PORT=9222"
node --check "core\devtools.mjs" || goto :failed
node --check "workflows\infographics\agenda-jobs.mjs" || goto :failed
node --check "workflows\infographics\run-infographics.mjs" || goto :failed
node --check "workflows\html-context-images\propose-images.mjs" || goto :failed
node --check "tools\check-environment.mjs" || goto :failed
node "tools\check-environment.mjs" "%BT_PORT%" || goto :failed
popd
exit /b 0

:dry_run
call :require_node
if errorlevel 1 exit /b 1
if "%~3"=="" goto :usage
set "BT_PORT=%~4"
if not defined BT_PORT set "BT_PORT=9222"
node "workflows\infographics\run-infographics.mjs" --agenda "%~2" --source-root "%~3" --dry-run --port "%BT_PORT%"
set "BT_EXIT=%ERRORLEVEL%"
popd
exit /b %BT_EXIT%

:once
call :require_node
if errorlevel 1 exit /b 1
if "%~4"=="" goto :usage
set "BT_PORT=%~5"
if not defined BT_PORT set "BT_PORT=9222"
node "workflows\infographics\run-infographics.mjs" --agenda "%~2" --source-root "%~3" --chat-url "%~4" --once --port "%BT_PORT%"
set "BT_EXIT=%ERRORLEVEL%"
popd
exit /b %BT_EXIT%

:run
call :require_node
if errorlevel 1 exit /b 1
if "%~4"=="" goto :usage
set "BT_PORT=%~5"
if not defined BT_PORT set "BT_PORT=9222"
node "workflows\infographics\run-infographics.mjs" --agenda "%~2" --source-root "%~3" --chat-url "%~4" --port "%BT_PORT%"
set "BT_EXIT=%ERRORLEVEL%"
popd
exit /b %BT_EXIT%

:propose_html
call :require_node
if errorlevel 1 exit /b 1
if "%~2"=="" goto :usage
if "%~3"=="" (
  node "workflows\html-context-images\propose-images.mjs" --html "%~2"
) else (
  node "workflows\html-context-images\propose-images.mjs" --html "%~2" --out "%~3"
)
set "BT_EXIT=%ERRORLEVEL%"
popd
exit /b %BT_EXIT%

:failed
echo Prüfung fehlgeschlagen.
popd
exit /b 1

:usage
echo.
echo Bilder-Tool für Windows
echo.
echo   bilder-tool.cmd start-chrome [Port]
echo   bilder-tool.cmd check [Port]
echo   bilder-tool.cmd dry-run "Agenda.md" "Quellordner" [Port]
echo   bilder-tool.cmd once "Agenda.md" "Quellordner" "https://chatgpt.com/c/..." [Port]
echo   bilder-tool.cmd run "Agenda.md" "Quellordner" "https://chatgpt.com/c/..." [Port]
echo   bilder-tool.cmd propose-html "Übung.html" [Vorschläge.json]
echo.
popd
exit /b 2
