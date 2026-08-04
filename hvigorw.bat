@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "PROJECT_ROOT=%~dp0"
set "PROJECT_CLI=%PROJECT_ROOT%node_modules\@ohos\hvigor\bin\hvigor.js"
if exist "%PROJECT_CLI%" (
  node "%PROJECT_CLI%" %*
  exit /b !ERRORLEVEL!
)

if defined DEVECO_STUDIO_HOME if exist "%DEVECO_STUDIO_HOME%\tools\hvigor\bin\hvigorw.bat" (
  call "%DEVECO_STUDIO_HOME%\tools\hvigor\bin\hvigorw.bat" %*
  exit /b !ERRORLEVEL!
)

if exist "%ProgramFiles%\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" (
  call "%ProgramFiles%\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" %*
  exit /b !ERRORLEVEL!
)

if exist "%LOCALAPPDATA%\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" (
  call "%LOCALAPPDATA%\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" %*
  exit /b !ERRORLEVEL!
)

>&2 echo ERROR: Hvigor was not found in node_modules or DevEco Studio.
>&2 echo Set DEVECO_STUDIO_HOME to the DevEco Studio installation directory.
exit /b 1
