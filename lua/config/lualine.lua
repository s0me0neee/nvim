local opts = {
    options = {
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
    },

    sections = {
        -- lualine_a = { "mode" },
        lualine_a = {
            {
                "mode",
                fmt = function(str)
                    local map = {
                        ["NORMAL"] = "通常",
                        ["INSERT"] = "挿入",
                        ["VISUAL"] = "視覚",
                        ["V-LINE"] = "行視覚",
                        ["V-BLOCK"] = "矩形視覚",
                        ["REPLACE"] = "置換",
                        ["COMMAND"] = "命令",
                        ["TERMINAL"] = "端末",
                    }
                    return map[str] or str
                end,
            },
        },

        lualine_b = {
            "branch",
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                sections = { "error", "warn" },
            },
            { "filename", path = 1, file_status = false },
            {
                function()
                    return vim.bo.modified and "M" or (vim.bo.modifiable == false or vim.bo.readonly) and "R" or ""
                end,
                padding = { left = 0, right = 1 },
            },
            {
                "%w",
                cond = function()
                    return vim.wo.previewwindow
                end,
            },
            {
                "%r",
                cond = function()
                    return vim.bo.readonly
                end,
            },
            {
                "%q",
                cond = function()
                    return vim.bo.buftype == "quickfix"
                end,
            },
        },

        lualine_c = {},

        lualine_x = {},

        lualine_y = {
            -- Search result: /pattern (current/total)
            {
                function()
                    if vim.v.hlsearch == 0 then
                        return ""
                    end
                    local last_search = vim.fn.getreg("/")
                    if not last_search or last_search == "" then
                        return ""
                    end
                    local searchcount = vim.fn.searchcount({ recompute = 1, maxcount = 9999 })
                    if searchcount.total == 0 then
                        return last_search
                    end
                    return last_search .. " (" .. searchcount.current .. "/" .. searchcount.total .. ")"
                end,
                -- color = { fg = "#ff9e64" }, -- auto theme will override this to match your scheme
            },
            function()
                local reg = vim.fn.reg_recording()
                return reg ~= "" and "Recording @" .. reg or ""
            end,
            "filetype",
        },

        lualine_z = {
            "%l:%c",
            "%p%%/%L",
        },
    },

    inactive_sections = {
        lualine_c = { "%f %y %m" },
        lualine_x = {},
    },
}

-- lualine's auto theme with the a/z and b/y blocks recolored from each mode's color
local function theme()
    local t = require("lualine.utils.loader").load_theme("auto")
    for mode, sections in pairs(t) do
        local bg = mode ~= "inactive" and sections.a and sections.a.bg
        if type(bg) == "string" and bg:match("^#%x%x%x%x%x%x$") then
            local colors = require("word-gradient").statusline_colors(bg)
            sections.a = vim.tbl_extend("force", sections.a, colors.a)
            sections.b = vim.tbl_extend("force", sections.b or {}, colors.b)
        end
    end
    return t
end

local lualine = require("lualine")
opts.options.theme = theme()
lualine.setup(opts)

-- a table theme is fixed at setup, so rebuild it for each colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("lualine_theme", { clear = true }),
    callback = function()
        -- deferred: word-gradient's own ColorScheme hook must first update the hue grey modes fall back to
        vim.schedule(function()
            opts.options.theme = theme()
            lualine.setup(opts)
        end)
    end,
})

-- lualine's refresh events skip macro recording, so the indicator waited for a cursor move or its 1s timer
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = vim.api.nvim_create_augroup("lualine_macro", { clear = true }),
    callback = function()
        -- queued, so it renders after RecordingLeave returns and reg_recording() is cleared
        require("lualine").refresh({ place = { "statusline" } })
    end,
})
