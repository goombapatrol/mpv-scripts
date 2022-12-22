utils = require 'mp.utils'

mp.add_hook("on_load", 9, function ()
    local currFile = mp.get_property("stream-open-filename")
	if not io.open(currFile,"r") then
		mp.msg.debug("invalid file")
		return
	end
	currExt = currFile:match("^.+(%..+)$")
	if currExt == ".lnk" then
		local lnkFile = mp.get_property("path")
		lnkFile = lnkFile:gsub("'", "''")
		lnkFile = "'" .. lnkFile .. "'"
		-- Deadcode to the rescue
		local foo = utils.subprocess({args = {"powershell \" $WScript = New-Object -ComObject WScript.Shell; Get-ChildItem -LiteralPath \"" .. lnkFile .. "\" | ForEach-Object {$WScript.CreateShortcut($_.FullName).TargetPath}\""},})
		local lnkDest = string.gsub(foo.stdout, '^%s*(.-)%s*$', '%1')
		lnkDest = lnkDest:gsub("[\r\n]", "")
		mp.set_property("stream-open-filename", lnkDest)
		-- mp.msg.fatal(lnkFile)
		-- mp.msg.fatal(lnkDest)
	end
end)

-- Notes --
-- handle single quotes by doubling up, see: https://social.technet.microsoft.com/Forums/office/en-US/38e6c1a8-9259-4d7b-bec6-fb3712a43fd4/single-quotation-in-powershell?forum=winserverpowershell
-- handle []'s with -LiteralPath not -Path
