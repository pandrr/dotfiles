function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end


-- function Status:name()
-- 	local h = self._tab.current.hovered
-- 	if not h then
-- 		return ui.Line({})
-- 	end

-- 	return ui.Line(" " .. tostring(h.url))
-- end
 
require("folder-rules"):setup()
