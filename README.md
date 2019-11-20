# UpdateMoonlightGamesList
A script to automatically update the RetroPie Moonlight games list with the contents of the Moonlight list command to the desired game stream server.

This script can be run directly from RetroPie on from the Moonlight/Steam games list menu to automatically update/sync the games list with the contents from the "moonlight list" command on a desired chosen game stream server. 

What this script does is to pull available games from the desired game stream server through the "moonlight list" command, delete game entries made previously from the script, create a new the list of games in the Emulationstation Retropie and restart Emulationstation to relaod the game list.

The script, specifically the "grep"-part for fetching the games list from Moonlight is loosely inspired by https://github.com/rpf16rj/moonlight_script_retropie and too many other blogs/forum posts to mention.
Pardon any bugs, as I'm still noob in bash scripts.

# Features
- Automatically update the RetroPie Moonlight games list with the contents of the Moonlight list command to the desired game stream server.
- Can be run directly from the RetroPie Moonlight/Steam games list.
- Restarts EmulationStation to update the games list with new entries.
- Game files already present and not previously created by this script are not overwritten.

# Usage: 

1 - Download and copy the script into your RetroPie Moonlight/Steam roms folder, typically "/home/pi/RetroPie/roms/moonlight". Make sure it's executable. <br>
    Alternatively, in same folder, run:
    git clone https://github.com/Vegz78/UpdateMoonlightGamesList && sudo chmod +x _UpdateMoonlightGamesList.sh

2 - Edit _UpdateMoonlightGamesList.sh with the desired global variables correct for your setup(server IP/Hostname, roms folder path etc.)

3 - Start RetroPie and navigate to the Moonlight/Steam games list menu.

4 - Run the _UpdateMoonlightGamesList entry.