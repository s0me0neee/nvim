return {
	"milanglacier/minuet-ai.nvim",
	opts = {
		provider = "claude",
		context_window = 512,
		provider_options = {
			claude = {
				model = "claude-haiku-4-5",
				api_key = "ANTHROPIC_API_KEY",
				max_tokens = 128,
				stream = true,
			},
		},
		request_timeout = 3,
		notify = "warn",
	},
}
