# mpv-scripts
These are a couple of scripts i've made along my journey of using MPV. <sub>My edits of others' scripts are also included, with credit given.</sub>

## LnkHandler
This script resolves ".lnk" files and directories (uses Powershell) https://github.com/mpv-player/mpv/issues/8424

## show-in-explorer
This script allows you to show the currently playing file in directory. I've seen a couple of [basic solutions](https://github.com/mpv-player/mpv/issues/6565#issuecomment-473816919), but this handles some more cases such as when playing with **--merge-files**, archives, or URLs.

Add to input.conf: **alt+e script-message show-in-explorer**

## myphoto
This script is for use with the [ffmpeg 'Photosensitivity' filter](https://ffmpeg.org/ffmpeg-filters.html#toc-photosensitivity) (filter developed by my friend [CyberShadow](https://github.com/CyberShadow)). It's been a wonderful utility at making videos tolerable for epileptics and the visually sensitive alike.

* Default mappings: (w/shift to decrease)
  * F5 Threshold
  * F6 Frame window
  * alt+F6 Enable/Disable filter
  * ctrl+F6 Show current filter values
* Extra mappings: (enable for testing via 'script-opts-add=myphoto-active=true')
  * F7 Frame Skip
  * F8 Downscale (for performance)
  * F9 Blend
  * -l -k -j -h (various cmd log formats)
  * -g Graph (subsequently pressing alt+F6 will switch to a side-by-side graph)
  * n Pa**n**ic button (blacken video, contrast -100)
  
Note: the latest public version of MPV is not yet compatible with 'blend', so i've included a second version (myphoto_old.lua) for compatiblity.

## Autoload-manual
This script is a modification of [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua), but uses a hotkey (ctrl+l) to load (instead of running all the time); you can press it a second time to reverse the loaded playlist order. If a manual playlist is detected active, it will prompt first.

## Todo
- [ ] Add even more

----

Feel free to let me know if you have any suggestions or find a bug.
