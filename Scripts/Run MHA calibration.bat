@echo off
setlocal

:: Get the directory where the batch file is located
set "SCRIPT_DIR=%~dp0"

:: Check if the file exists in the script directory
if exist "%SCRIPT_DIR%hmc_config.json" (
    set "CONFIG_FILE=%SCRIPT_DIR%d4_hmc_config.json"
) else (
    echo Error: hmc_config.json not found in the script directory.
    pause
    exit /b 1
)

:: Check if a folder was provided
if "%~1"=="" (
    echo Usage: Drag and drop a folder onto this script.
    pause
    exit /b 1
)

:: Set the folder path
set "FOLDER_PATH=%~1"

:: Define the command with dynamic folder path and config file
set "CALIBRATION_APP_COMMAND=CalibrationApp -f "%FOLDER_PATH%" -e "%FOLDER_PATH%\calib.json" -n 30 -c "%CONFIG_FILE%"

:: Execute the command
echo Executing: %CALIBRATION_APP_COMMAND%
%CALIBRATION_APP_COMMAND%

echo Command executed.
pause
