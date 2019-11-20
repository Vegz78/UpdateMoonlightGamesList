#!/bin/bash

# Global variables, leave empty if you don't want to use them
MOONLIGHT_PATH="/home/pi/RetroPie/roms/moonlight" #Full path to the location of the Moonlight roms folder
STREAMINGHOST="192.168.1.5" #Streaming host's IP adress or hostname
RESOLUTION="1080" #720/1080/4K
FPS="60" #30/60 etc.
BITRATE= #Bitrate in Kbps
REMOTE="Yes" #"Yes" or 1 for remote optimization, empty otherwise
AUDIO= #"local" for local audio, empty otherwise
PLATFORM="pi" #pi/imx/aml/rk/x11/x11_vdpau/sdl/fake/auto, empty otherwise
QUITAPPAFTER="Yes" #"Yes" or 1 for quitting app after ending streaming session, empty otherwise


#Check if game server is online AND Moonlight returns a game list from the game server, terminate script otherwise
sudo -u pi timeout 2 moonlight list $STREAMINGHOST | grep '^[0-9][0-9.]' | cut -d "." -f2 | sed 's/^ \(.*\)$/\1/' | if ! IFS= read -r
then
    echo "Game server unreachable or no games listed by Moonlight on the game server..."
    sleep 3
    exit 1


else


    # Set script variables
    _STREAMINGHOST=""
    if [ "$STREAMINGHOST" != "" ]
    then
    _STREAMINGHOST=" $STREAMINGHOST"
    fi
    _RESOLUTION=""
    if [ "$RESOLUTION" != "" ]
    then
        _RESOLUTION=" -$RESOLUTION"
    fi
    _FPS=""
    if [ "$FPS" != "" ]
    then
        _FPS=" -fps $FPS"
    fi
    _BITRATE=""
    if [ "$BITRATE" != "" ]
    then
        _BITRATE=" -bitrate $BITRATE"
    fi
    _REMOTE=""
    if [ "$REMOTE" = "YES" ] || [ "$REMOTE" = 1 ] || [ "$REMOTE" = "Yes" ] || [ "$REMOTE" = "yes" ]
    then
        _REMOTE=" -remote"
    fi
    _AUDIO=""
    if [ "$AUDIO" = "local" ]
    then
        _AUDIO=" -audio local"
    fi
    _PLATFORM=""
    if [ "$PLATFORM" = "pi" ] || [ "$PLATFORM" = "imx" ] || [ "$PLATFORM" = "aml" ] || [ "$PLATFORM" = "rk" ] || [ "$PLATFORM" = "x11" ] || [ "$PLATFORM" = "x11_vdpau" ] || [ "$PLATFORM" = "sdl" ] || [ "$PLATFORM" = "fake" ] || [ "$PLATFORM" = "auto" ]
    then
        _PLATFORM=" -platform $PLATFORM"
    fi
    _QUITAPPAFTER=""
    if [ "$QUITAPPAFTER" = "YES" ] || [ "$QUITAPPAFTER" = 1 ] || [ "$QUITAPPAFTER" = "Yes" ] || [ "$QUITAPPAFTER" = "yes" ]
    then
        _QUITAPPAFTER=" -quitappafter"
    fi


    #Delete old and existing script generated Moonlight game files
    OLD_IFS="$IFS"
    IFS=
    echo "Deleting...:"
    grep -l --exclude="_UpdateMoonlightGamesList.sh" "#Autocreated by UpdateMoonlightGamesList.sh" $MOONLIGHT_PATH/*.sh | while read -r LINE; do
        sudo rm $LINE
        echo $LINE
    done
    IFS="$OLD_IFS"
    echo ""

    #Make list of moonlight games borrowed from https://github.com/rpf16rj/moonlight_script_retropie
    # sudo -u pi moonlight list | grep '^[0-9][0-9.]' | cut -d "." -f2 | sed 's/^ \(.*\)$/\1/' >> gamesreal.txt
    # sudo -u pi moonlight list | grep '^[0-9][0-9.]' | cut -d "." -f2 | sed 's/[^a-z A-Z 0-9 -]//g' >> games.txt


    #Generate new script files from Moonlight listed games on game server
    OLD_IFS="$IFS"
    IFS= #Make read command reade entire lines and not divide into words
    CNTR=0
    CNTR2=0
    CNTR3=0
    ARR1[0]=""
    ARR2[0]=""
    while read -r LINE ;do
        echo $LINE".sh:"
        
        #Check if file already exists and exclude
        if IFS= read -r ;then 
            ARR1[$CNTR]=$LINE
            ((CNTR++))
            echo $LINE" already exists and was created from another source, will not overwrite."
        
        #If file doesn't exist, create new file
        else
            ARR2[$CNTR2]=$LINE
            echo "#!/bin/bash" | sudo tee -a $MOONLIGHT_PATH/$LINE.sh
            echo "#Autocreated by UpdateMoonlightGamesList.sh" | sudo tee -a $MOONLIGHT_PATH/$LINE.sh
            echo "moonlight stream"$_RESOLUTION$_FPS$_BITRATE$_REMOTE$_AUDIO$_PLATFORM$_QUITAPPAFTER" -app \"$LINE\""$_STREAMINGHOST | sudo tee -a $MOONLIGHT_PATH/$LINE.sh
            ((CNTR2++))
        fi< <(find $MOONLIGHT_PATH -name $LINE".sh")
        ((CNTR3++))
    #ProcessSubstitution to prevent subshell and thereby being able to use variables from while loop outside the loop
    done < <(sudo -u pi timeout 2 moonlight list $STREAMINGHOST | grep '^[0-9][0-9.]' | cut -d "." -f2 | sed 's/^ \(.*\)$/\1/') 
    
    
    #Sum up and print operations
    echo ""
    echo $CNTR"/"$CNTR3" game files were not created from Moonlight, because the files already existed or were created from another source:"
    for ITEM in ${ARR1[*]}
    do
        printf "   %s\n" $ITEM".sh"
    done
    echo ""
    echo $CNTR2"/"$CNTR3" game files were created from Moonlight:"
    for ITEM in ${ARR2[*]}
    do
        printf "   %s\n" $ITEM".sh"
    done
    IFS="$OLD_IFS"


    #Exit script and restart Emulationstation to update Moonlight games list
    echo""
    echo "Now restarting EmulationStation..."
    sudo -u pi touch /tmp/es-restart
    sudo -u pi kill $(pgrep -l -n emulationstatio | awk '!/grep/ {printf "%s ",$1}')
    sleep 3
    #sudo -u pi rm /tmp/es-restart

fi
