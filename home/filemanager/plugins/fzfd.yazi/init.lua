-- local state = ya.sync(function()
-- 	return cx.active.current.cwd
-- end)
--
local function fail(s, ...)
	ya.notify({ title = "fzfd", content = string.format(s, ...), timeout = 5, level = "error" })
end

local function entry()
	local permit = ya.hide()
	-- local cwd = tostring(state())
	local handle = io.popen(
		"FZF_DEFAULT_COMMAND=\"find . -not \\( -path '*/node_modules*' -type d -prune \\) -not \\( -path '*/.git*' -type d -prune \\) -maxdepth 5\" fzf"
	)
	if not handle then
		return fail("Spawn fzfd failed, handle is nil")
	end

	local result = handle:read("*a")
	handle:close()
	if result == nil or result == "" then
		return
	end
	result = result:gsub("\n$", "")
	local cha, err = fs.cha(Url(result))
	if not cha then
		return fail("cannot read file's characteristics, ", err)
	end
	ya.manager_emit(cha.is_dir and "cd" or "reveal", { result })
	permit:drop()
end

return { entry = entry }
