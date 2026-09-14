-- Async replacement for `:!{cmd}`.
--
-- `:!{cmd}` is synchronous by design: it hands the controlling terminal to the
-- child process and blocks the UI until it exits, which is why `:!ping
-- google.com` locks up Neovim until you interrupt it. There is no option to
-- change that -- the fix is to run the job somewhere else.
--
--   :Run {cmd}   stream {cmd} in a terminal buffer in a bottom split, without
--                stealing focus. Full terminal behaviour: colors, ANSI escapes,
--                progress bars. Press q in that window to kill it and close.
--   :Run! {cmd}  run with no window at all and notify when it exits. For
--                commands you only care about the result of.
--
-- `:!` is left alone on purpose -- `:{range}!{cmd}` filters buffer text through
-- a command (`:%!sort`), which is a genuinely different feature worth keeping.

local HEIGHT = 15
local MAX_NOTIFY = 2000

local function run_windowed(cmd)
	local prev = vim.api.nvim_get_current_win()

	vim.cmd("botright " .. HEIGHT .. "split")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, buf)

	for _, opt in ipairs({ "number", "relativenumber", "list", "spell" }) do
		vim.api.nvim_set_option_value(opt, false, { win = win })
	end
	vim.api.nvim_set_option_value("signcolumn", "no", { win = win })

	-- term = true turns buf into a terminal buffer, so output streams live
	-- instead of arriving in one lump at exit.
	local job = vim.fn.jobstart(cmd, { term = true })
	if job <= 0 then
		vim.api.nvim_win_close(win, true)
		vim.notify("Run: failed to start: " .. cmd, vim.log.levels.ERROR)
		return
	end

	-- Killing the job on wipe means closing the window also stops the command,
	-- rather than leaving it running against an invisible buffer.
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			pcall(vim.fn.jobstop, job)
		end,
	})

	vim.keymap.set("n", "q", function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, { buffer = buf, nowait = true, desc = "Kill command and close" })

	-- Stay where you were: the point is to keep editing while it runs.
	if vim.api.nvim_win_is_valid(prev) then
		vim.api.nvim_set_current_win(prev)
	end
end

local function run_headless(cmd)
	local chunks = {}
	local function collect(_, data)
		if data then
			chunks[#chunks + 1] = data
		end
	end

	vim.system({ vim.o.shell, vim.o.shellcmdflag, cmd }, {
		text = true,
		stdout = collect,
		stderr = collect,
	}, function(res)
		vim.schedule(function()
			local out = table.concat(chunks)
			if #out > MAX_NOTIFY then
				out = out:sub(1, MAX_NOTIFY) .. "\n…(truncated)"
			end
			vim.notify(
				("%s (exit %d)%s"):format(cmd, res.code, out ~= "" and "\n" .. out or ""),
				res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			)
		end)
	end)
end

vim.api.nvim_create_user_command("Run", function(o)
	if o.bang then
		run_headless(o.args)
	else
		run_windowed(o.args)
	end
end, {
	nargs = "+",
	bang = true,
	complete = "shellcmd",
	desc = "Run a shell command asynchronously",
})
