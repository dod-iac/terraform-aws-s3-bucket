@echo off

rem # =================================================================
rem #
rem # Work of the U.S. Department of Defense, Defense Digital Service.
rem # Released as open source under the MIT License.  See LICENSE file.
rem #
rem # =================================================================

rem isolate changes to local environment
setlocal

where go >nul 2>&1 || (
  echo|set /p="go is missing."
  exit /B 1
)

where terraform >nul 2>&1 || (
  echo|set /p="terraform is missing."
  exit /B 1
)

echo|set /p="Verifying AWS credentials"
echo.

aws sts get-caller-identity >nul
IF %ERRORLEVEL% NEQ 0 (
  goto:eof
)

echo|set /p="Running tests"
echo.

go test -short -count 1 -timeout 15m .\test\...

:eof
