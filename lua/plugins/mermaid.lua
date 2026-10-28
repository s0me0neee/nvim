-- :MermaidView shows a live-rendered preview in a normal buffer, so it can sit in any
-- window/split/tab; takes modifiers like :vert MermaidView or :tab MermaidView
local views = {} -- source bufnr -> { pbuf, png, img, job, dirty, timer }

local function preview_win(pbuf)
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(win) == pbuf then
			return win
		end
	end
end

-- image.nvim pins an image to one window, so rebuild it whenever the buffer moves
local function place(v)
	local win = preview_win(v.pbuf)
	if v.img and v.img.window ~= win then
		v.img:clear()
		v.img = nil
	end
	if not win or not v.png then
		return
	end
	if not v.img then
		v.img = require("image").from_file(v.png, {
			window = win,
			buffer = v.pbuf,
			max_width_window_percentage = 100,
			max_height_window_percentage = 100,
		})
	end
	if v.img then
		v.img:render()
	end
end

local function render(src)
	local v = views[src]
	if not v then
		return
	end
	if v.job then
		v.dirty = true
		return
	end
	local input = vim.fn.tempname() .. ".mmd"
	local out = vim.fn.tempname() .. ".png"
	vim.fn.writefile(vim.api.nvim_buf_get_lines(src, 0, -1, false), input)
	local theme = require("mermaid").config.preview.theme
	v.job = vim.system(
		{ "mmdc", "-q", "-i", input, "-o", out, "-t", theme, "-b", "transparent", "-s", "2" },
		{},
		vim.schedule_wrap(function(res)
			os.remove(input)
			v.job = nil
			if views[src] ~= v or res.code ~= 0 then
				-- parse errors keep the last good image; mermaid.nvim's linter reports them
				os.remove(out)
			else
				if v.img then
					v.img:clear()
					v.img = nil
				end
				if v.png then
					os.remove(v.png)
				end
				v.png = out
				place(v)
			end
			if v.dirty and views[src] == v then
				v.dirty = false
				render(src)
			end
		end)
	)
end

local function close(src)
	local v = views[src]
	if not v then
		return
	end
	views[src] = nil
	v.timer:stop()
	v.timer:close()
	if v.img then
		v.img:clear()
	end
	if v.png then
		os.remove(v.png)
	end
	pcall(vim.api.nvim_del_augroup_by_name, "mermaid_view_" .. src)
	if vim.api.nvim_buf_is_valid(v.pbuf) then
		vim.api.nvim_buf_delete(v.pbuf, { force = true })
	end
end

local function open(src)
	local pbuf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(pbuf, "mermaid://" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(src), ":t"))
	local v = { pbuf = pbuf, timer = vim.uv.new_timer() }
	views[src] = v

	local group = vim.api.nvim_create_augroup("mermaid_view_" .. src, { clear = true })
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
		group = group,
		buffer = src,
		callback = function()
			v.timer:stop()
			v.timer:start(300, 0, vim.schedule_wrap(function()
				render(src)
			end))
		end,
	})
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = group,
		buffer = pbuf,
		callback = function()
			-- image.nvim positions from the text area, so keep the gutter empty
			for opt, val in pairs({ number = false, relativenumber = false, signcolumn = "no", foldcolumn = "0", statuscolumn = "", cursorline = false }) do
				vim.api.nvim_set_option_value(opt, val, { scope = "local", win = 0 })
			end
			vim.schedule(function()
				place(v)
			end)
		end,
	})
	vim.api.nvim_create_autocmd({ "WinClosed", "TabEnter", "BufWinLeave" }, {
		group = group,
		callback = function()
			vim.schedule(function()
				place(v)
			end)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		buffer = src,
		callback = function()
			close(src)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		buffer = pbuf,
		callback = function()
			vim.schedule(function()
				close(src)
			end)
		end,
	})
	render(src)
	return v
end

local function view(cmd)
	local src = vim.api.nvim_get_current_buf()
	if vim.bo[src].filetype ~= "mermaid" then
		vim.notify("MermaidView: not a mermaid buffer", vim.log.levels.WARN)
		return
	end
	if vim.fn.executable("mmdc") == 0 then
		vim.notify("MermaidView: mmdc not found (npm i -g @mermaid-js/mermaid-cli)", vim.log.levels.ERROR)
		return
	end
	local v = views[src] or open(src)
	if cmd.mods ~= "" then
		vim.cmd(cmd.mods .. " sbuffer " .. v.pbuf)
	else
		vim.cmd.buffer(v.pbuf)
	end
end

return {
	{
		"kevalin/mermaid.nvim",
		ft = "mermaid",
		dependencies = { "nvim-treesitter/nvim-treesitter", "3rd/image.nvim" },
		config = function()
			require("mermaid").setup({ preview = { theme = "redux-dark-color" } })
			-- no option to disable the floating status panel :MermaidPreview opens
			local panel = require("mermaid.panel")
			panel.open = function() end
			panel.start_auto_refresh = function() end
			vim.api.nvim_create_user_command("MermaidView", view, { desc = "Live mermaid preview buffer" })
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "mermaid" } },
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = { mermaid = { "mermaid" } },
			formatters = {
				mermaid = {
					-- MermaidFormat only edits buffer 0, so run it on a scratch copy and hand back the lines
					format = function(_, _, lines, callback)
						local scratch = vim.api.nvim_create_buf(false, true)
						vim.bo[scratch].expandtab = true
						vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
						local notify = vim.notify
						vim.notify = function() end -- it announces "Formatted" on every run
						local ok, err = pcall(vim.api.nvim_buf_call, scratch, require("mermaid.format").format)
						vim.notify = notify
						local out = vim.api.nvim_buf_get_lines(scratch, 0, -1, false)
						vim.api.nvim_buf_delete(scratch, { force = true })
						if ok then
							callback(nil, out)
						else
							callback(tostring(err))
						end
					end,
				},
			},
		},
	},
}
