local selected = ya.sync(function()
	local list = {}
	local sel = cx.active.selected
	if #sel == 0 then
		local hovered = cx.active.current.hovered
		if not hovered.cha.is_dir then
			list[1] = hovered.url
		end
	else
		for _, se in pairs(sel) do
			-- local cha, _ = fs.cha(se)
			-- print("cha: ", cha.is_dir)
			table.insert(list, se)
		end
	end
	return list
end)

return {
	entry = function()
		local files = selected()
		if #files == 0 then
			return
		end
		local all = ""
		for _, f in pairs(files) do
			local cha, _ = fs.cha(f)
			if cha and not cha.is_dir then
				all = all .. "'" .. f .. "' "
			end
		end
		-- cut last space
		all = all:gsub("%s+$", "")
		if all == "" then
			return
		end
		local _ = os.execute("dragon -x -a -T  " .. all)
	end,
}
