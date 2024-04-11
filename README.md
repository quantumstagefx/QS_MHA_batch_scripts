# Batch scripts for easy data preparation of stereo footage for Metahuman Animator
A collection of scripts to batch convert captured stereo data into a format suitable for the MetaHuman ingestion process. Works with simple drag and drop of one or more files in Windows.

## Overview & purpose

**Batch process Facegood Streamer footage for MHA.bat**
For use with footage recorded using Facegood's D4 stereo HMC using Avatary Streamer software. Expects pairs of two files as input and will match pairs when multiple takes are used. Will run ffmpeg to extract the audio to a wav file from the top camera footage and then run the Metahuman ingestion Python script.

**Batch process OBS stereo footage for MHA.bat**
Except a single video file containing both stereo feeds recorded in horizontal layout where bottom camera is left and top camera is right in the following resolution: 2160x1920. Will use ffmpeg to split the video into two separate video files along with extracting the audio to a wav file. Then runs the Metahuman Python ingestion script with these files. Works with any number of video files and will process one after the other.

**Run MHA calibration.bat**
Used to run the calibration app by drag and dropping a prepared calibration take. Expects a 'hmc_config.json' file containing the calibration board parameters inside the scripts folder. Only works with a single folder/take.

**Remove _clean from filenames.bat**
Used for removing _clean the end of filenames generated using the denoising scripts. Mostly in pair with Streamer recordings as otherwise the batch script wont work,


## Setup & prerequisites
These scripts assume you installed all the prequisits of the official Metahuman Animator stereo ingestion pipeline.  These are mainly ffmpeg, Python and the stereo calibration app along with setting the correct environment path variables in Windows. See the official Metahuman guidelines for more details. 

#### Set the path to the mh_ingest_convert.cs Python script
Find the full path of your Metahuman stereo capture tools and replace the path definition of PYTHON_SCRIPT variable in the following two batch scripts on line 8:

    Batch process Facegood Streamer footage for MHA.bat
    Batch process OBS stereo footage for MHA.bat

The final variable value should include the full path and python script name with file ending. Typically this is found inside your Unreal Engine Plugins folder. For example:

`UE_5.3\Engine\Plugins\Marketplace\MetaHuman\Content\StereoCaptureTools\stereo_capture_tools`

#### Setup the windows shortcuts
Because the batch script only works via a Windows shortcut we need to create one for each script that we want to use. This can easily be done by right-clicking the batch script file, dragging into an empty Windows Explorer area and then selecting "Create shortcuts here" from the menu that will pop up. 

#### Add an additional identifier string (optional)
Both batch scripts allow you to specify an additional string parameter which can used to further identify processed takes if needed. You can set it on line 5:

`set "ADDITIONAL_STRING="`

This string will both be appended at the end of the filenames as well as at the end of the slate name.

## Using the batch scripts

In order to make use of the batch script, simply drag and drop your footage video files onto the shortcut for the relevant script. You can drag as many files as you want and the script will go through all of them. 

For Facegood Streamer recordings, or other stereo footage pairs, the script expects pairs of two video files. In this case .mov files ending in **_CH_0** for the top camera footage and **_CH_1** for the bottom camera footage. You can modify the batch script yourself to fit your capture format and naming convetion. 

By default the Python command will set a timecode value for the stereo pair footage. The script should work fine with footage that contains timecode data but you should remove the following lines from the Python command in this case:

    --video1-timecode 00:00:00:00 --video2-timecode 00:00:00:00

By default the Python command uses png_gray as the image extraction method. Please adjust this in the same line to your own prefered extraction method. 

The scripts will also use the filename of the recording as the slate name of the generated ingestion ready json file.

## Denoiser setup

Should you want to use the image denoiser for your footage then you need to download it seperatly. You can find more info and a download link here: https://www.dpreview.com/forums/thread/4461481

For my own process of using the D4 stereo footage, I've used the denoiser before running the batch ingestion scripts.

### Using the denoiser

You can find the denoising batch scripts inside the Denoiser folder of the script collection. Then there are multiple sub folders for each video codec. 

The denoiser scripts will generate a new file with the used denoising parameters at the end of the filename. Because this new filename is not compatible with the rest of the batch scripts we must adjust their code as follows:

**First:** Find the denoiser you want to use. For example: Prores Very High
**Then:** Change the copy parameter of the ffmpeg command at the end of line 30, just below "encoding:" to copy "%~dp1%newdir%\%~n1_clean.mov"

For example, change line 30: 

`apps\ffmpeg\ffmpeg.exe -y -i "%~dp1%newdir%\%~nx1.avs" -i "%~f1" -map 0:v:0 -map 1:a? -metadata:s "encoder=Apple ProRes 422" -vendor apl0 -movflags write_colr -chunk_duration 500K -c:v prores_ks -profile:v 2 -qscale:v 4 -c:a copy "%~dp1%newdir%\%~n1_[%flt%,prores].mov"`

to: 

`apps\ffmpeg\ffmpeg.exe -y -i "%~dp1%newdir%\%~nx1.avs" -i "%~f1" -map 0:v:0 -map 1:a? -metadata:s "encoder=Apple ProRes 422" -vendor apl0 -movflags write_colr -chunk_duration 500K -c:v prores_ks -profile:v 2 -qscale:v 4 -c:a copy "%~dp1%newdir%\%~n1_clean.mov"`

This will make it so that the new filename of the denoised video clip will contain its original filename plus _clean at the end.

The denoising script works the same way as the other batch scripts via creating a shortcut and then drag and dropping the files onto the shortcut. It will work with multiple files so its very convenient to batch process multiple clips.

## Using the calibration batch script

This script was done for the lazy and simple runs the Metahuman stereo calibration app with whatever ingestion prepared folder was dropped onto the shortcut. It will require a calibration board configuration file called `hmc_config.json` in the same folder as the batch script in order to work. 

You can find the one for the official Epic calibration board config inside  the calibration app folder usually at `C:\Program Files\Epic Games\Calibration App\default_hmc_config.json`.

The config file for the calibration board shipped with Facegood's D4 HMC can be found on their Wiki or on this download link: https://resource.avatary.com/wiki_online/%2825%29default_hmc_config.rar

As always check the official Metahuman documentation for further info regarding the use of the calibration board and its settings. 

Last but not least: don't forget to copy your calib json file to each prepared take folder once you're happy with the calibration. 

# Disclaimer

All these batch scripts were generated for the most part with the help of ChatGPT. If you see any errors, weird code structure or see any other way to improve them, then please reach out to me. Also reach out if you find any odd behaviour or if the scripts don't work with your footage. I'm happy to make this more compatible with other hardware.  

# Contact
E-Mail: tobias@quantum-stage.com
Github: @judasbenhur

#License
QS_MHA_batch_scripts is released under the terms of the MIT license. See COPYING for more information or see https://opensource.org/licenses/MIT.


