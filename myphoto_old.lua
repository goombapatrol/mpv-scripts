-- photosensitivity controls, by goom
local msg = require 'mp.msg'

-- check if using CS mpv build (may have different options etc)
if string.find(mp.get_property("mpv-configuration"), "vladimir") then
	mp.msg.debug("thanks CyberShadow!")
end

--[[ Default options
-- https://github.com/CyberShadow/FFmpeg/blob/epilepsy/libavfilter/vf_photosensitivity.c
-- "frames",    "set how many frames to use"                        ,  OFFSET(nb_frames           ), AV_OPT_TYPE_INT  , {.i64=30}, 2, MAX_FRAMES, FLAGS },
-- "f",         "set how many frames to use"                        ,  OFFSET(nb_frames           ), AV_OPT_TYPE_INT  , {.i64=30}, 2, MAX_FRAMES, FLAGS },
-- "threshold", "set detection threshold factor (lower is stricter)",  OFFSET(threshold_multiplier), AV_OPT_TYPE_FLOAT, {.dbl= 1}, 0, FLT_MAX   , FLAGS },
-- "t"        , "set detection threshold factor (lower is stricter)",  OFFSET(threshold_multiplier), AV_OPT_TYPE_FLOAT, {.dbl= 1}, 0, FLT_MAX   , FLAGS },
-- "skip"     , "set pixels to skip when sampling frames"           ,  OFFSET(skip                ), AV_OPT_TYPE_INT  , {.i64= 1}, 1, 1024      , FLAGS },
-- "bypass"   , "leave frames unchanged"                            ,  OFFSET(bypass              ), AV_OPT_TYPE_BOOL , {.i64= 0}, 0, 1         , FLAGS },
--]]

-- detection threshold factor (lower is stricter)
local t = {}
	t[1] = "0.1"
	t[2] = "0.2"
	t[3] = "0.3"
	t[4] = "0.4"
	t[5] = "0.5"
	t[6] = "0.6"
	t[7] = "0.7"
	t[8] = "0.8"
	t[9] = "0.9"
	t[10] = "1.0"
	t[11] = "1.1"
	t[12] = "1.2"
	t[13] = "1.5"
	t[14] = "1.7"
	t[15] = "2.0"

-- frames to use
local f = {}
	f[1] = "15"
	f[2] = "30"
	f[3] = "60"
	f[4] = "90"
	f[5] = "120"
	f[6] = "150"

-- skipped pixels when sampling frames
s = {}
	s[1] = "1"
	s[2] = "2"
	s[3] = "3"
	s[4] = "4"
	s[5] = "5"
	s[6] = "6"
	s[7] = "7"
	s[8] = "8"
	s[9] = "9"
	
-- resolution downscale height (better performance)
r = {}
	r[1] = "999999"
	r[2] = "720"
	r[3] = "576"
	r[4] = "480"
	r[5] = "360"
	r[6] = "240"

-- my baseline	"photosensitivity=f=60:t=0.5:skip=1:bypass=0"
val = {}
	val["t"] = 5
	val["f"] = 3
	val["s"] = 1
	val["r"] = 1

-- initialize
local thresh = (t[val["t"]])
local frames = (f[val["f"]])
local skip = (s[val["s"]])
local bypass = 0
local height = (r[val["r"]])

-- graph
local graph_enabled = 0
local graph_compare = 0

-- log check (session count bad, session count total, sequential bad count)
local cmdlog = 0
local logchk = 0
local logtype = 0
local badcount = 0
local framecount = 0
local badstreak = 0
local badrecord = 0

local initiated = false
-- https://stackoverflow.com/questions/12291203/lua-how-to-call-a-function-prior-to-it-being-defined
local extraMap

function getSettings()
	if mp.get_opt("myphoto-active") == "true" then
		startPaused = true
		f_disabled = false
		log_enabled = true
		extraMap()
	else
		-- disable filter at start
		startPaused = false
		f_disabled = true
		log_enabled = false
	end
end

function devMapStuff()
	-- alternate sequence mappings
	mp.add_forced_key_binding("'-l", "vToggle1", function() photoEvent(1); end)
	mp.add_forced_key_binding("'-k", "vToggle2", function() photoEvent(2); end)
	mp.add_forced_key_binding("'-j", "vToggle3", function() photoEvent(3); end)
	mp.add_forced_key_binding("'-h", "vToggle4", function() photoEvent(4); end)

	-- graph (alt+f6 'disable' for side by side)
	mp.add_forced_key_binding("'-g", "graph", function() graph_enabled = 1 - graph_enabled; updateFilter("graph"); end)
	-- mp.msg.debug("Debug keys enabled ('-l '-k '-j '-h '-g)")
	mp.msg.info("Debug keys enabled ('-l '-k '-j '-h '-g)")
end

-- don't use 'on_preloaded' to pause
mp.add_hook("on_load", 50, function ()
	-- runonce
	if initiated == true then return end
	-- extra check for auto_profile
	getSettings()
	if startPaused == true then mp.set_property("pause", "yes") end
	if f_disabled ~= true then updateFilter("all", 0) end
	if log_enabled == true then devMapStuff() end
	initiated = true
end)

function panic()
	-- make it black
	if mp.get_property("contrast") ~= "-100" then
		contrast = mp.get_property("contrast")
		-- mp.commandv("set", "contrast", "-20")
		mp.set_property("contrast", "-100")
	else
		mp.set_property("contrast", contrast)
	end
end

function log_check(event)
if string.find(event["text"], "photosensitivity: badness:") then
	if event["text"]:gsub("([^!]*)", "%1") == eventText then return end
		if mp.get_property("time-pos") == timePos then return end
		eventText = event["text"]:gsub("([^!]*)\r?\n", "%1")
		for i in string.gmatch(eventText, ".-%)") do badness=i end
		percent = badness:gsub("^.-(..%d%%).*", "%1")
		timePos = mp.get_property("time-pos")
		framecount = framecount + 1
		
		exceeded = badness:gsub(".*(.)..%% -.*", "%1")
		exceeded = exceeded:gsub(" ", ".")
		exceeded = exceeded:gsub("%d", "#")

		-- (single symbol)
		if logtype == 1 then io.write("" .. exceeded .. "") end
		-- (filter single line)
		if logtype == 2 then io.write("\r" .. eventText .. "        ") end
		-- (filter multi line)
		if logtype == 3 then io.write("\r\n" .. eventText .. "        ") end
		-- custom output later, cutoff for non-4's for now
		if logtype ~= 4 then do return end end
		
		-- show this info:
		--	percent	badstreak, worststreak, bad , total, total
		-- bad total is impt (too hard to tell % changing), total count less so (seeking etc not actual frame)
		
		if string.find(badness, "OK") then
			-- record highest streak (maybe do this for percent too)
			if badrecord < badstreak then badrecord = badstreak end
			badstreak = 0
			io.write("\r " .. percent .. "\t".. badcount .. "/" .. framecount .. "\t\t" .. badstreak .. "\t" .. badrecord)
		elseif string.find(badness, "EXCEEDED") then
			badcount = badcount + 1
			badstreak = badstreak + 1
			-- io.write("\r" .. percent .. "\t" .. badcount .. "/" .. framecount)
			io.write("\r" .. percent .. "\t" .. badcount .. "/" .. framecount .. "\t\t" .. badstreak .. "\t" .. badrecord)
		end
	end
end

function photoEvent(logchk)
	if logchk ~= logtype and logtype ~= 0 then
		-- skip the below if not disabling or enabling logger
		-- need to clean up possibly longer lines
		io.write(string.format("\r                                                                                                                       \r"))
		logtype = logchk
		return
	end
	toggleMsg("statusline=no,autoconvert=no")
	logtype = logchk
	cmdlog = 1 - cmdlog
	if cmdlog == 1 then
		framecount = 0
		io.write(string.format("\r                                                                                \r"))
		mp.register_event("log-message", log_check)
		mp.enable_messages("debug")
	else
		logtype = 0
		mp.unregister_event("log-message")
		mp.enable_messages("info")
	end
end

function graph_nable()
	graph_compare = 1 - graph_compare
	if graph_compare == 1 then mp.commandv("no-osd", "set", "pause", "yes") end
	apply("t", 0)
end

function filter_nable()
    if f_disabled == true then
		f_disabled = false
		-- auto unpause?
		-- if mp.get_property("pause") == "yes" then mp.commandv("no-osd", "set", "pause", "no") end
		apply("t", 0)
	else
	f_disabled = true
	-- desync if you disable and hit 'fkey', so keys locked
		mp.commandv("show-text", "Filters disabled")
		mp.commandv("no-osd", "vf", "remove", "@photo")
		-- pause for safety reasons
		mp.commandv("no-osd", "set", "pause", "yes")
	end
end

function apply(ftype, adjust)
	-- (don't) prevent filter adjust when 'disabled'
	if f_disabled == true then
		f_disabled = false
			apply("t", 0)
		-- using 'return' eats the first press at start, but allows any key to 're-enable' without changing values.
		return
	end
	-- if f_disabled == true then mp.commandv("show-text", "Press Alt+F6 to enable"); return; end
	if ftype == "reset" then
	val = {}
		val["t"] = 5; thresh = (t[val["t"]])
		val["f"] = 3; frames = (f[val["f"]])
		val["s"] = 1; skip = (s[val["s"]])
		val["r"] = 1; height = (r[val["r"]])
	elseif ftype == "bypass" then
		-- bypass = 1 - bypass
	else
		chk = val[ftype] + adjust
		-- stay within range
		-- (FIXED) needed to check separate, array size of eq[6] doesn't allow ds[10]
		if (ftype == "f" and f[chk] == nil) or (ftype == "t" and t[chk] == nil) or (ftype == "s" and s[chk] == nil) or
			(ftype == "r" and r[chk] == nil) then return end
		val[ftype] = chk
		
		if ftype == "t" then thresh	= (t[val["t"]]) ; updateFilter("photo")
		elseif ftype == "f" then frames	= (f[val["f"]]) ; updateFilter("photo")
		elseif ftype == "s" then skip	= (s[val["s"]]) ; updateFilter("photo")
		elseif ftype == "r" then
			height = (r[val["r"]])
			while adjust == 1 and tonumber(height) >= tonumber(mp.get_property("height")) and (val[ftype] + adjust) do
				val[ftype] = val[ftype] + adjust
				height = (r[val["r"]])
			end
			height = (r[val["r"]])
			-- -- jump to start
			if adjust == -1 and tonumber(height) >= tonumber(mp.get_property("height")) then val[ftype] = 1; height = "999999" end
			updateFilter("scale")
		end
	end
end

function updateFilter(filter, duration)
	if not duration then duration = 1000 end
	toggleMsg("vf=no", 1)
	local photo = "@photo:photosensitivity=t=" .. thresh .. ":f=" .. frames .. ":skip=" .. skip
	-- '[aid1]anull[ao];' was breaking videos with no audio, removed
	if graph_compare == 0 then
		graph = "[vid1]scale=w=960:h=-2,photosensitivity=t=" .. thresh .. ":f=" .. frames .. ":skip=" .. skip .. ",split[P][I]; [I]drawgraph=fg1=0x00FFFF:m1=lavfi.photosensitivity.fixed-badness:fg2=0x0000FF:m2=lavfi.photosensitivity.badness:fg3=0xFF00FF:m3=lavfi.photosensitivity.frame-badness:fg4=0x00FF00:m4=lavfi.photosensitivity.factor:min=0:max=2:slide=scroll:bg=0x000000:mode=line:size=960x100[G]; [P][G]vstack[vo]"
	else
		graph = "[vid1]scale=w=640:h=-2, split[A][B]; [B]photosensitivity=t=" .. thresh .. ":f=" .. frames .. ":skip=" .. skip .. "[P]; [P]split[R][I]; [A][R]hstack[C]; [I]drawgraph=fg1=0x00FFFF:m1=lavfi.photosensitivity.fixed-badness:fg2=0x0000FF:m2=lavfi.photosensitivity.badness:fg3=0xFF00FF:m3=lavfi.photosensitivity.frame-badness:fg4=0x00FF00:m4=lavfi.photosensitivity.factor:min=0:max=2:slide=scroll:bg=0x000000:mode=line:size=1280x100[G]; [C][G]vstack[vo]"
	end

	scale = "@scale:lavfi=[scale=w=-2:" .. height .. ":flags=bicubic]"
	
	if filter == "all" then
		-- prepend, scale needs to always be first
		if height ~= "999999" then mp.commandv("no-osd", "vf", "pre", scale) end
		mp.commandv("no-osd", "vf", "add", photo)
	elseif filter == "scale" then
	-- else mp.commandv("no-osd", "vf", "del", "scale=w=640:h=-2") end
	-- "This filter will be replaced by using libavfilter option syntax directly. Parts of the old syntax will stop working"
		if height ~= "999999" then
			mp.commandv("no-osd", "vf", "pre", scale)
			mp.commandv("show-text", "height:" .. height)
		else
			-- mp.commandv("no-osd", "vf", "toggle", scale)
			mp.commandv("no-osd", "vf", "del", scale)
			mp.commandv("show-text", "original: " .. mp.get_property("height"))
		end
	elseif filter == "photo" then
		if graph_enabled == 0 then
			mp.commandv("no-osd", "vf", "add", photo)
		else
			mp.set_property("lavfi-complex", graph)
		end
		mp.commandv("show-text", "photo:" .. photo:gsub("@photo:photosensitivity=", ""), duration)
	elseif filter == "perfCrop" then
		--- use separate key to control crop/scale for performance
		mp.commandv("no-osd", "vf", "add", "@perfCrop:lavfi=[crop=640:480]")
		mp.commandv("show-text", "cropping", duration)
	elseif filter == "graph" then
		if graph_enabled == 1 then
			mp.commandv("no-osd", "vf", "remove", "@photo")
			-- (optional) disable SeekConditional.lua from kicking in
			mp.commandv("script-message", "seekc-disable")
			-- cycle between these depending on graph_enabled
			mp.commandv("no-osd", "script-message", "osc-visibility", "never")
			mp.set_property("lavfi-complex", graph)
		else
			mp.commandv("no-osd", "vf", "add", photo)
			mp.commandv("no-osd", "script-message", "osc-visibility", "auto")
			mp.set_property("lavfi-complex", "[aid1]anull[ao];[vid1]null[vo]")
		end
	end
	toggleMsg("vf=no")
end

function toggleMsg(module, force)
	local msgLevel = mp.get_property("msg-level")
	if string.find(msgLevel, module) then
		-- remove it (unless forcing apply to sync)
		if not force then
			msgLevel = msgLevel:gsub("^" .. module .. ",*", "")
		end
	else
		-- add it
		msgLevel = msgLevel:gsub("^", module .. ",")
	end
	
	mp.set_property("msg-level", msgLevel)

end

-- hide this for good (audio desync warnings)
--- try hiding with 'myphoto-active' (mpvs) only, keep visible otherwise
toggleMsg("ao/wasapi=fatal,ao/alsa=warn,cplayer=fatal,lavf=fatal,osd/libass=fatal", 1)

-- and unneeded video stuff
toggleMsg("autoconvert=fatal,ffmpeg/video=fatal", 1)
-- and unmapped key binding
toggleMsg("input=fatal", 1)

if string.find(mp.get_property("mpv-configuration"), "vladimir") then
	-- toggle verbose output (and hide status during)
	mp.add_forced_key_binding("alt+p", "vToggle", function() toggleMsg("ffmpeg=v,statusline=no"); end)
end

-- frame window and skip are niche
-- map scale to other fkey, remap them to other modifiers
-- maybe flip threshold key (no modifier decreases)
mp.add_forced_key_binding("alt+F5", "defaults", function()	apply("reset"); end)
mp.add_forced_key_binding("alt+F6", "filter", function() if graph_enabled == 1 then graph_nable() else filter_nable() end; end)
-- show current settings
mp.add_forced_key_binding("ctrl+F6", "info", function()	apply("t", 0); end)
mp.add_forced_key_binding("F5", "tLower", function()		apply("t", -1); end)
mp.add_forced_key_binding("shift+F5", "tHigher", function()	apply("t", 1); end)
mp.add_forced_key_binding("shift+F6", "fDecr", function()	apply("f", -1); end)
mp.add_forced_key_binding("F6", "fIncr", function()			apply("f", 1); end)
mp.add_forced_key_binding("shift+F6", "fDecr", function()	apply("f", -1); end)

-- extra keys only used with option
-- if mp.get_opt("myphoto-active") == "true" then
function extraMap()
-- if skip not proven useful, use F7 for something else (logging/graphs?)
mp.add_forced_key_binding("shift+F7", "sDecr" , function()	apply("s", -1); end)
mp.add_forced_key_binding("F7", "sIncr" , function()		apply("s", 1); end)
-- (if bypass needed)
-- mp.add_forced_key_binding("alt+F7", "bp" , function()	apply("bypass"); end)

-- downscale (for performance)
mp.add_forced_key_binding("shift+F8", "resU" , function()	apply("r", -1); end)
mp.add_forced_key_binding("F8", "resD" , function()			apply("r", 1); end)

-- panic toggle (black screen), reminder 'b' boss key also exists
mp.add_forced_key_binding("n", "panic", function() panic(); end)

end
