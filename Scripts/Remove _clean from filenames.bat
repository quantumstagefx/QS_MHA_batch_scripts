@echo off
setlocal enabledelayedexpansion

:: Loop through each file passed to the script
for %%F in (%*) do (
    :: Extract the full filename
    set "filename=%%~nF"
    :: Extract the file extension
    set "extension=%%~xF"
    
    :: Check if the filename ends with _clean
    if "!filename:~-6!"=="_clean" (
        :: Remove _clean from the filename
        set "newname=!filename:~0,-6!"
        
        :: Rename the file
        ren "%%F" "!newname!!extension!"
        echo Renamed: %%F to !newname!!extension!
    ) else (
        echo File does not contain '_clean' in its name: %%F
    )
)

echo All files processed.
pause
