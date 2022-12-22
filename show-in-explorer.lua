--[[

https://github.com/mpv-player/mpv/issues/6560
https://github.com/mpv-player/mpv/issues/6565

${path} DOES NOT WORK with folder (drag or cmd), just direct file
it has a '/' appended, and wrongly opens up either 'User' or internet explorer

input.conf
	alt+e script-message show-in-explorer
--]]

mp.register_script_message("show-in-explorer", function()
	local filepath = mp.get_property("path")
	
	-- fix for '--merge-files', which uses semicolon delimited format (e.g. edl://folder\01_file.flac;folder\02_file.flac)
	if string.match(filepath, "^edl://") then
		-- append semicolon just in case only one file specified
		filepath = filepath .. ";"
		filepath = filepath:gsub('^edl://(.-);.*$', '%1')
	end

	-- archives .zip .rar .7z etc
	if string.match(filepath, "^archive://") then
		filepath = filepath:gsub('^archive://(.-)|.*', '%1')
	end
	
	-- website, open page
	if string.match(filepath, "https?:") then
		filepath = filepath:gsub('/', '\\')
		-- thanks CyberShadow, /d disables Autorun error popup
		mp.commandv("run", "cmd", "/d", "/C", "start " .. filepath)
		filepath = ""
	end
	
	-- correct the slashes
	filepath = filepath:gsub('/', '\\')
	-- mp.commandv("show-text", filepath)
	-- mp.msg.fatal(filepath)
	
	if filepath ~= "" then
		mp.commandv("run", "explorer", "/select,", filepath)
	end
end)
