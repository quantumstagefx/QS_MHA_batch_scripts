@echo off
setlocal enabledelayedexpansion

:: Define the additional string here
set "ADDITIONAL_STRING="

:: Set the path to the Metahuman Animator Python ingestion script:
set "PYTHON_SCRIPT=D:\Epic Games\UE_5.3\Engine\Plugins\Marketplace\MetaHuman\Content\StereoCaptureTools\stereo_capture_tools\mh_ingest_convert.py"


:: Loop through each file dropped onto the script and store paths temporarily
for %%F in (%*) do (
    echo %%F

    set "file=%%F"
    :: Check if the file ends with _CH_0.mov or _CH_1.mov
    if "!file:~-9!"=="_CH_0.mov" (
        set "pair[!file:~0,-9!_CH_1.mov]=%%F"
    )
    if "!file:~-9!"=="_CH_1.mov" (
        set "pair[%%F]=!file:~0,-9!_CH_0.mov"
    )
)

:: Process each pair
for /F "tokens=2 delims==" %%i in ('set pair[') do (
    set "top_file=%%i"
    set "bot_file=%%i"
    set "bot_file=!bot_file:_CH_0.mov=_CH_1.mov!"
    
    :: Ensure both files of the pair exist
    if exist "!top_file!" if exist "!bot_file!" (
        call :processPair "!top_file!" "!bot_file!"
    ) else (
        echo Missing pair for file: %%i
    )
)

echo All files processed.
pause
goto :eof

:processPair
set "top_file=%~1"
set "bot_file=%~2"

:: Extract just the filename from the full path (without extension)
for %%A in ("!top_file!") do set "file_name=%%~nA"
set "file_name=!file_name:_CH_0=!"

:: Extract base name without _CH_0 or _CH_1 and the extension
set "base_name=!top_file:_CH_0.mov=!"

:: Incorporate ADDITIONAL_STRING into CLEAN_FILENAME
set "CLEAN_FILENAME=!file_name!!ADDITIONAL_STRING!"

:: Define the directory to store processed files, including ADDITIONAL_STRING in the directory name
set "OUTPUT_DIR=!base_name!!ADDITIONAL_STRING!"

:: Create the directory if it does not exist
if not exist "!OUTPUT_DIR!" mkdir "!OUTPUT_DIR!"

:: Define the output filenames
set "OUTPUT_FILE_TOP=!top_file!"
set "OUTPUT_FILE_BOT=!bot_file!"
set "OUTPUT_FILE_AUDIO=!OUTPUT_DIR!\audio.wav"

:: Define the prepared output directory
set "PREPARED_DIR=!OUTPUT_DIR!_prepared"
if not exist "!PREPARED_DIR!" mkdir "!PREPARED_DIR!"

:: Extract audio from the top source video file
ffmpeg -y -i "!top_file!" -vn -acodec pcm_s16le -ar 44100 -ac 2 "!OUTPUT_FILE_AUDIO!"

:: Example placeholder echos
echo Processing with ffmpeg: "!top_file!" and "!bot_file!"
echo Running Python script with: "!CLEAN_FILENAME!"

:: Define the Python script command with the new paths and use CLEAN_FILENAME as slate-name
set "COMMAND=python "%PYTHON_SCRIPT%" --audio-path "!OUTPUT_FILE_AUDIO!" bot "!OUTPUT_FILE_BOT!" top "!OUTPUT_FILE_TOP!" png_gray "!PREPARED_DIR!" --slate-name "!CLEAN_FILENAME!" --overwrite --video1-timecode 00:00:00:00 --video2-timecode 00:00:00:00"

:: Execute the command
echo Executing: %COMMAND%
%COMMAND%


echo Processed: !CLEAN_FILENAME!
goto :eof
