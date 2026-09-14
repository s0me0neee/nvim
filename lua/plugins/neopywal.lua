-- Nudge pywal's palette away from the wallpaper that generated it, so the
-- colorscheme stays recognisably "the wallpaper's theme" while still reading as
-- distinct from the wallpaper showing through the transparent background.
-- Worked in HSLuv so the shift lands evenly across every color.
local HUE_SHIFT = 12 -- degrees to rotate the hue wheel
local SAT_BOOST = 22 -- percentage points of extra saturation
local LIGHT_SHIFT = 6 -- percentage points of extra lightness

-- Keys that sit *behind* text rather than in it. Lifting these would wash out
-- the panels that float over the wallpaper, so they get pushed down instead.
local BACKDROP = { background = true, color0 = true, dim_bg = true, cursorline = true }

local function clamp(v)
	return math.max(0, math.min(100, v))
end

return {
	"RedsXDD/neopywal.nvim",
	name = "neopywal",
	lazy = false,
	priority = 1000,
	config = function()
		local hsluv = require("neopywal.utils.hsluv")

		local function offset(hex)
			local h, s, l = unpack(hsluv.hex_to_hsluv(hex))
			-- Greys carry no meaningful hue, so only lift them off the wallpaper.
			if s < 5 then
				return hsluv.hsluv_to_hex({ h, s, clamp(l + LIGHT_SHIFT) })
			end
			return hsluv.hsluv_to_hex({
				(h + HUE_SHIFT) % 360,
				clamp(s + SAT_BOOST),
				clamp(l + LIGHT_SHIFT),
			})
		end

		local function sink(hex)
			local h, s, l = unpack(hsluv.hex_to_hsluv(hex))
			return hsluv.hsluv_to_hex({ h, s, clamp(l - 3) })
		end

		-- Neopywal builds its semantic colors (func, keyword, string, ...) from the
		-- raw palette before merging `custom_colors`, so overriding colorN there
		-- never reaches syntax highlighting. Shifting the finished palette catches
		-- every key, including ones a future version might add.
		local Palette = require("neopywal.lib.palette")
		local get_palette = Palette.get
		Palette.get = function(...)
			local colors = {}
			for key, value in pairs(get_palette(...)) do
				if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
					colors[key] = BACKDROP[key] and sink(value) or offset(value)
				else
					colors[key] = value
				end
			end
			return colors
		end

		require("neopywal").setup({
			-- Reads ~/.cache/wal/colors-wal.vim, written by the `wal -q -i $wallpaper`
			-- step in waypaper's post_command. The built-in reloader watches that file
			-- and only reapplies while neopywal is the active colorscheme, so themery
			-- stays in charge of everything else.
			use_palette = "pywal",

			-- Let the terminal/compositor background show through. Neopywal disables
			-- this automatically under Neovide, which does its own opacity above.
			transparent_background = true,

			-- Neopywal caches the compiled theme under a hash of this table, which
			-- can't see the knobs above. Folding them in makes edits recompile.
			custom_colors = {
				all = { offset_signature = ("%d/%d/%d"):format(HUE_SHIFT, SAT_BOOST, LIGHT_SHIFT) },
			},
		})
	end,
}
