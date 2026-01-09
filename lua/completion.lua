require "blink.cmp".setup({
    sources = {
        default = { "lsp", "path", "buffer" }
    },
    completion = {
        keyword = { range = "full" },
        accept = { auto_brackets = { enabled = true } },
        trigger = {
            show_on_backspace_after_accept = true,
        },
        menu = {
            max_height = 25,
            auto_show = false,
            draw = {
                treesitter = { "lsp" },
            },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        list = {
            max_items = 50,
        }
    },
    fuzzy = {
        implementation = "rust",
        sorts = {
            "exact",
            "score",
            "kind",
            "sort_text",
        },
        frecency = {
            enabled = true,
        },
        use_proximity = true,
    },
    keymap = {
        preset = "default",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<S-Up>"] = { function(cmp) return cmp.select_prev({ count = 10 }) end, "fallback" },
        ["<S-Down>"] = { function(cmp) return cmp.select_next({ count = 10 }) end, "fallback" },

        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
        -- no return true in the function so the fallback behaviour is used as well (exit to normal mode)
        ["<Esc>"] = { function(cmp)
            cmp.hide()
            return false
        end, "fallback" },
        ["<Enter>"] = { "select_and_accept", "fallback" },
        ["<C-E>"] = { "cancel", "fallback" },
        ["<C-S>"] = { "show_signature", "hide_signature", "fallback" },
    },
    signature = { enabled = true },
})
