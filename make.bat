@echo off

rem # =================================================================
rem #
rem # Work of the U.S. Department of Defense, Defense Digital Service.
rem # Released as open source under the MIT License.  See LICENSE file.
rem #
rem # =================================================================

rem isolate changes to local environment
setlocal

rem create local bin folder if it doesn't exist
if not exist "%~dp0bin" (
  mkdir %~dp0bin
)

rem update PATH to include local bin folder
PATH=%~dp0bin;%PATH%

rem set common variables for targets

set "USAGE=Usage: %~n0 [clean|format_terraform|fmt|help|imports|staticcheck|tidy|update_docs]"

rem if no target, then print usage and exit
if [%1]==[] (
  echo|set /p="%USAGE%"
  exit /B 1
)

REM remove bin directory

if %1%==clean (

  if exist %~dp0bin (
    rd /s /q %~dp0bin
  )

  exit /B 0
)

if %1%==format_terraform (

  where terraform >nul 2>&1 || (
    echo|set /p="terraform is missing."
    exit /B 1
  )

  terraform fmt

  for /R "%~dp0examples" %%e in (.) do (
    if exist %%e\main.tf (
      pushd %%e
      terraform fmt
      popd
    )
  )

  exit /B 0
)

if %1%==fmt (

  go fmt ./test ./pkg/tools

  exit /B 0
)

if %1%==help (
  echo|set /p="%USAGE%"
  exit /B 1
)

if %1%==imports (

  if not exist "%~dp0bin\goimports.exe" (
    go build -o bin/goimports.exe golang.org/x/tools/cmd/goimports
  )

  .\bin\goimports.exe -w -local github.com/gruntwork-io/terratest,github.com/aws/aws-sdk-go,github.com/dod-iac ./test ./pkg/tools

  exit /B 0
)

if %1%==staticcheck (

  if not exist "%~dp0bin\staticcheck.exe" (
    go build -o bin/staticcheck.exe honnef.co/go/tools/cmd/staticcheck
  )

  .\bin\staticcheck.exe -checks all ./test

  exit /B 0
)

if %1%==terratest (

  call "%~dp0env.bat"

  call "%~dp0terratest.bat"
  
  exit /B 0
)

if %1%==tidy (

  go mod tidy

  exit /B 0
)

if %1%==update_docs (

  where terraform-docs >nul 2>&1 || (
    echo|set /p="terraform-docs is missing/"
    exit /B 1
  )

  powershell "%~dp0scripts\update-readme-windows.ps1"

  for /R "%~dp0examples" %%e in (.) do (
    if exist %%e\main.tf (
      pushd %%e
      powershell "%~dp0scripts\update-readme-windows.ps1"
      popd
    )
  )

  exit /B 0
)

echo|set /p="%USAGE%"
exit /B 1
