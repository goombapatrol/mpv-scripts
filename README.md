# mpv-scripts
These are a couple of scripts i've made along my journey of using MPV. <sub>My edits of others' scripts are also included, with credit given.</sub>

## LnkHandler
This script resolves ".lnk" files and directories (uses Powershell) https://github.com/mpv-player/mpv/issues/8424

## show-in-explorer
This script allows you to show the currently playing file in directory. I've seen a couple of [basic solutions](https://github.com/mpv-player/mpv/issues/6565#issuecomment-473816919), but this handles some more cases such as when playing with **--merge-files**, archives, or URLs.

Add to input.conf: **alt+e script-message show-in-explorer**

## Autoload-manual
This script is a modification of [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua), but uses a hotkey to load (instead of running all the time).

## Todo
- [ ] Add more

----

Feel free to let me know if you have any suggestions or find a bug.
