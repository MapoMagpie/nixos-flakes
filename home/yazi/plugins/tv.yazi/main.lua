local M = {}

local state = ya.sync(function()
	return cx.active.current.cwd
end)

function M:entry()
	ya.emit("escape", { visual = true })

	local cwd = state()
	if cwd.scheme.is_virtual then
		return ya.notify { title = "Television", content = "Not supported under virtual filesystems", timeout = 5, level = "warn" }
	end

	local permit = ui.hide()
	local output, err = M.run_with(cwd)

	permit:drop()
	if not output then
		return ya.notify { title = "Television", content = tostring(err), timeout = 5, level = "error" }
	end

	local urls = M.split_urls(cwd, output)
	if #urls == 1 then
		local cha = fs.cha(urls[1])
		ya.emit(cha and cha.is_dir and "cd" or "reveal", { urls[1], raw = true })
	elseif #urls > 1 then
		urls.state = "on"
		ya.emit("toggle_all", urls)
	end
end

---@param cwd Url
---@return string?, Error?
function M.run_with(cwd)

	local child, err = Command("tv")
		:cwd(tostring(cwd))
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT) -- 重要: 如果设置为PIPED就会卡住
		:spawn()

	if not child then
		return nil, Err("Failed to start `tv files`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `tv files` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`tv files` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

function M.split_urls(cwd, output)
	local t = {}
	for line in output:gmatch("[^\r\n]+") do
		local u = Url(line)
		if u.is_absolute then
			t[#t + 1] = u
		else
			t[#t + 1] = cwd:join(u)
		end
	end
	return t
end

return M

