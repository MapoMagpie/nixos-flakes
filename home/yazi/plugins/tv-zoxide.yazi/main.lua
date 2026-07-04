local M = {}

function M:setup(opts)
	opts = opts or {}

	if opts.update_db then
		ps.sub("cd", function()
			local cwd = cx.active.current.cwd
			ya.async(function() Command("zoxide"):arg({ "add", tostring(cwd) }):status() end)
		end)
	end
end

function M:entry()
	local permit = ui.hide()
	local target, err = M.run_with()
	permit:drop()

	if not target then
		ya.notify { title = "Zoxide", content = tostring(err), timeout = 5, level = "error" }
	elseif target ~= "" then
		ya.emit("cd", { target, raw = true })
	end
end

---@return string?, Error?
function M.run_with()
	local child, err = Command("tv")
		:arg({ "zoxide"})
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return nil, Err("Failed to start `zoxide`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `zoxide` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`zoxide` exited with code %s: %s", output.status.code, output.stderr:gsub("^zoxide:%s*", ""))
	end
	return output.stdout:gsub("\n$", ""), nil
end

return M
