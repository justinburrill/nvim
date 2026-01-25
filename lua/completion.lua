require "blink.cmp".setup({
    sources = {
        default = { "lsp", "path", "snippets", "buffer" }
    },
    completion = {
        keyword = { range = "full" },
        accept = { auto_brackets = { enabled = true } },
        trigger = { show_on_backspace_after_accept = true, show_in_snippet = false },
        menu = {
            max_height = 25,
            auto_show = false,
            draw = { treesitter = { "lsp" } },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        -- not used if completion.list.selection.auto_insert = true
        ghost_text = { enabled = false, show_with_selection = false, show_without_menu = false },
        list = {
            -- preselect doesn't matter because C-Space is bound to select the first menu item
            selection = { auto_insert = true, preselect = false },
            max_items = 100,
        }
    },
    fuzzy = {
        implementation = "rust",
        sorts = { "exact", "score", "kind", "sort_text" },
        frecency = { enabled = true },
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

        ["<C-Space>"] = { "show_and_insert", "select_and_accept", "fallback" },
        -- no return true in the function so the fallback behaviour is used as well (exit to normal mode)
        ["<Esc>"] = { function(cmp)
            cmp.hide()
            return false
        end, "fallback" },
        ["<Enter>"] = { "select_and_accept", "fallback" },
        ["<C-E>"] = { "cancel", "fallback" },
        ["<C-S>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-K>"] = { "show_documentation", "hide_documentation", "fallback" },
        ["<C-U>"] = { "scroll_signature_up", "scroll_documentation_up", "fallback" },
        ["<C-D>"] = { "scroll_signature_down", "scroll_documentation_down", "fallback" },
    },
    signature = {
        enabled = true,
        trigger = {
            enabled = true,
            show_on_accept = true,
            show_on_accept_on_trigger_character = true,
            show_on_insert = true,
            show_on_insert_on_trigger_character = true,
            show_on_trigger_character = true,
        },
        window = {
            min_width = 10,
            max_height = 20,
            direction_priority = { "n", "s" },
            treesitter_highlighting = true,
            show_documentation = true,
        }
    },
    cmdline = {
        keymap = {
            preset = "inherit",
            ["<Tab>"] = { "show_and_insert", "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            ["<Enter>"] = { "accept_and_enter", "fallback" },
            ["<Esc>"] = { "fallback" },
        }
    },
    term = { keymap = { preset = "inherit" } }
})
