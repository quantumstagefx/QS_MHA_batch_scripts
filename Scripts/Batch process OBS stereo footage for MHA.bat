@echo off
setlocal enabledelayedexpansion

:: Define the additional string here
set "ADDITIONAL_STRING="

:: Set the path to the Metahuman Animator Python ingestion script:
set "PYTHON_SCRIPT=D:\Epic Games\UE_5.3\Engine\Plugins\Marketplace\MetaHuman\Content\StereoCaptureTools\stereo_capture_tools\mh_ingest_convert.py"


:: Loop through each file dropped onto the script
for %%F in (%*) do (
    set "INPUT_FILE=%%F"
    
    :: Extract the filename without extension and remove "_clean" if present
    set "FILENAME=%%~nF"
    :: Incorporate ADDITIONAL_STRING into CLEAN_FILENAME
    set "CLEAN_FILENAME=!FILENAME:_clean=!!ADDITIONAL_STRING!"

    :: Define the directory to store processed files, including ADDITIONAL_STRING in the directory name
    set "OUTPUT_DIR=%%~dpF!CLEAN_FILENAME!"

    :: Create the directory if it does not exist
    if not exist "!OUTPUT_DIR!" mkdir "!OUTPUT_DIR!"

    :: Define the output filenames
    set "OUTPUT_FILE_TOP=!OUTPUT_DIR!\top.mov"
    set "OUTPUT_FILE_BOT=!OUTPUT_DIR!\bot.mov"
    set "OUTPUT_FILE_AUDIO=!OUTPUT_DIR!\audio.wav"

    :: Define the prepared output directory
    set "PREPARED_DIR=!OUTPUT_DIR!_prepared"
    if not exist "!PREPARED_DIR!" mkdir "!PREPARED_DIR!"
    
    :: Execute ffmpeg command to split the video into top and bottom parts
    :: Assuming a horizontal stereo alignment where bottom camera is on the left and top camera is on the right.
    ffmpeg -y -i "!INPUT_FILE!" -filter_complex "[0:v]crop=w=1080:h=1920:x=0:y=0[left];[0:v]crop=w=1080:h=1920:x=1080:y=0[right]" -map "[left]" -c:v prores_ks -profile:v 5 -c:a copy "!OUTPUT_FILE_BOT!" -map "[right]" -c:v prores_ks -profile:v 5 -c:a copy "!OUTPUT_FILE_TOP!"

    :: uncomment this line and comment the above line out in order to try with contrast enhancement:
    ::ffmpeg -y -i "!INPUT_FILE!" -filter_complex "[0:v]crop=w=1080:h=1920:x=0:y=0,eq=brightness=0.2:contrast=1.4[left];[0:v]crop=w=1080:h=1920:x=1080:y=0,eq=brightness=0.2:contrast=1.4[right]" -map "[left]" -c:v prores_ks -profile:v 5 -c:a copy "!OUTPUT_FILE_BOT!" -map "[right]" -c:v prores_ks -profile:v 5 -c:a copy "!OUTPUT_FILE_TOP!"

    :: Extract audio from the source video file
    ffmpeg -y -i "!INPUT_FILE!" -vn -acodec pcm_s16le -ar 44100 -ac 2 "!OUTPUT_FILE_AUDIO!"

    :: Define the Python script command with the new paths and use CLEAN_FILENAME as slate-name
    set "COMMAND=python "%PYTHON_SCRIPT%" --audio-path "!OUTPUT_FILE_AUDIO!" bot "!OUTPUT_FILE_BOT!" top "!OUTPUT_FILE_TOP!" png_gray "!PREPARED_DIR!" --slate-name "!CLEAN_FILENAME!" --overwrite --video1-timecode 00:00:00:00 --video2-timecode 00:00:00:00"

    :: Execute the command
    echo Executing: %COMMAND%
    %COMMAND%
    
    echo Processed: !CLEAN_FILENAME!
)

echo All files processed.
pause