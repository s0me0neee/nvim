-- Jump from grep/rg output in a :terminal buffer to the matched file:line.

local M = {}

-- the term:// name only records where the shell *started*, so ask the process
local function shell_cwd()
	local pid = vim.b.terminal_job_pid
	if not pid or vim.fn.executable("lsof") == 0 then
		return nil
	end
	local res = vim.system({ "lsof", "-a", "-d", "cwd", "-p", tostring(pid), "-Fn" }):wait(1000)
	local dir = res.code == 0 and res.stdout:match("\nn(/[^\n]*)")
	return dir and vim.fn.isdirectory(dir) == 1 and dir or nil
end

-- nvim's own cwd never follows the shell's, so resolve against the terminal's
local function term_cwd()
	if vim.b.osc7_dir then
		return vim.b.osc7_dir
	end
	local dir = shell_cwd() or vim.api.nvim_buf_get_name(0):match("^term://(.-)//%d+:")
	return dir and vim.fn.expand(dir) or vim.fn.getcwd()
end

local function resolve(cwd, file)
	local path = vim.fs.normalize(vim.trim(file))
	if not vim.startswith(path, "/") then
		path = vim.fs.joinpath(cwd, path)
	end
	return vim.fn.filereadable(path) == 1 and path or nil
end

-- rg prints matches as `NN:text` (`NN-text` for context) under a bare path header
local function is_match_line(s)
	return s:match("^%s*%d+[:%-]") ~= nil
end

local function parse(cwd)
	local line = vim.api.nvim_get_current_line()

	-- one-line forms first: `path:line:col:text` (--vimgrep) and `path:line:text`
	if not is_match_line(line) then
		local file, l, c = line:match("^%s*(.-):(%d+):(%d+):")
		if file then
			local path = resolve(cwd, file)
			if path then
				return path, tonumber(l), tonumber(c)
			end
		end
		file, l = line:match("^%s*(.-):(%d+):")
		if file then
			local path = resolve(cwd, file)
			if path then
				return path, tonumber(l), 1
			end
		end
		-- cursor sits on the header itself
		local path = resolve(cwd, line)
		return path, 1, 1
	end

	-- grouped form: walk up for the header, skipping prompts and other noise
	local lnum = tonumber(line:match("^%s*(%d+)[:%-]"))
	local cur = vim.fn.line(".")
	for i = cur - 1, math.max(cur - 500, 1), -1 do
		local prev = vim.fn.getline(i)
		if not (prev:match("^%s*$") or prev:match("^%s*%-%-%s*$")) then
			local path = resolve(cwd, prev)
			if path then
				return path, lnum, 1
			end
		end
	end
end

-- a window holding a normal file buffer: not the terminal, not neo-tree, not a float
local function target_win()
	local cur = vim.api.nvim_get_current_win()
	local function usable(win)
		if win == 0 or win == cur or not vim.api.nvim_win_is_valid(win) then
			return false
		end
		if vim.api.nvim_win_get_config(win).relative ~= "" then
			return false
		end
		return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
	end

	local prev = vim.fn.win_getid(vim.fn.winnr("#"))
	if usable(prev) then
		return prev
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if usable(win) then
			return win
		end
	end
end

function M.goto_file()
	local cwd = term_cwd()
	local path, lnum, col = parse(cwd)
	if not path then
		vim.notify("term-jump: nothing readable for this line under " .. cwd, vim.log.levels.WARN)
		return
	end

	local float = vim.api.nvim_win_get_config(0).relative ~= ""
	local win = target_win()
	if float then
		vim.api.nvim_win_close(0, false)
	end
	if win then
		vim.api.nvim_set_current_win(win)
	elseif not float then
		vim.cmd.split()
	end

	local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(path))
	if not ok then
		vim.notify("term-jump: " .. tostring(err), vim.log.levels.ERROR)
		return
	end
	-- clamp: a column past end-of-line makes set_cursor fail and lose the line jump too
	lnum = math.min(lnum, vim.api.nvim_buf_line_count(0))
	local width = #vim.fn.getline(lnum)
	vim.api.nvim_win_set_cursor(0, { lnum, math.min(math.max(col - 1, 0), math.max(width - 1, 0)) })
	vim.cmd.normal({ "zz", bang = true })
end

function M.setup()
	local group = vim.api.nvim_create_augroup("term_jump", { clear = true })

	vim.api.nvim_create_autocmd("TermRequest", {
		group = group,
		desc = "Record the shell's cwd announced via OSC 7",
		callback = function(ev)
			local dir, n = ev.data.sequence:gsub("\027]7;file://[^/]*", "")
			if n > 0 and vim.fn.isdirectory(dir) == 1 then
				vim.b[ev.buf].osc7_dir = dir
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		group = group,
		callback = function(ev)
			-- buffer-local, and only gf: <leader>gf keeps LazyVim's git file history
			-- and gF the builtin, while the builtin gf's cwd-based guess is always
			-- wrong in a terminal buffer anyway
			vim.keymap.set("n", "gf", M.goto_file, {
				buffer = ev.buf,
				desc = "Goto file:line under cursor",
			})
		end,
	})

	vim.api.nvim_create_user_command("TermJumpDebug", function()
		local cwd = term_cwd()
		local path, lnum, col = parse(cwd)
		vim.print({
			buffer = vim.api.nvim_buf_get_name(0),
			osc7_dir = vim.b.osc7_dir,
			lsof_cwd = shell_cwd(),
			cwd_used = cwd,
			cursor_line = vim.api.nvim_get_current_line(),
			resolved = path,
			lnum = lnum,
			col = col,
			mapping = vim.fn.maparg("<leader>gf", "n"),
			target_win_buf = target_win() and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(target_win())),
		})
	end, { desc = "Diagnose term-jump on the current line" })
end

return M
