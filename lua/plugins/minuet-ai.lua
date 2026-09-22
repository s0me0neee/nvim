return {
	"milanglacier/minuet-ai.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	enabled = false,
	opts = {
		context_window = 1024,
		context_ratio = 0.75,
		-- DeepSeek FIM has no `n`, so each completion is a separate request that
		-- redraws the suggestion when it lands. There's no prev/next key to cycle
		-- them anyway.
		n_completions = 1,
		-- The default 1000ms throttle skips the request after you stop typing if
		-- one was sent less than a second earlier, leaving an old suggestion.
		throttle = 100,
		debounce = 100,
		add_single_line_entry = true,
		provider = "openai_fim_compatible",
		provider_options = {
			openai_fim_compatible = {
				api_key = "DEEPSEEK_API_KEY",
				name = "deepseek",
				optional = {
					max_tokens = 256,
					top_p = 0.8,
				},
			},
		},

		virtualtext = {
			auto_trigger_ft = { "*" },
			show_on_completion_menu = true,
			keymap = {
				accept = "<Tab>",
				accept_line = "<S-Tab>",
				accept_n_lines = nil,
				prev = nil,
				next = nil,
				dismiss = nil,
			},
		},
	},
	config = function(_, opts)
		require("minuet").setup(opts)

		-- Minuet shows a response even if you kept typing while it was in flight,
		-- which puts a suggestion meant for an earlier cursor position at the
		-- current one. Drop responses once the buffer or cursor has changed.
		local backend = require("minuet.backends." .. opts.provider)
		local complete = backend.complete
		backend.complete = function(context, callback)
			local buf = vim.api.nvim_get_current_buf()
			local tick = vim.api.nvim_buf_get_changedtick(buf)
			local cursor = vim.api.nvim_win_get_cursor(0)
			complete(context, function(data)
				if
					vim.api.nvim_get_current_buf() ~= buf
					or vim.api.nvim_buf_get_changedtick(buf) ~= tick
					or not vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor)
				then
					return
				end
				callback(data)
			end)
		end
	end,
}
