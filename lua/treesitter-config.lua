Config = {
    ensure_installed = { "c", "cpp", "lua", "python", "typescript",
        "vim", "rust", "vue", "sql", "html", "css", "bash" },
    sync_install = true,
    ignore_install = {},
    auto_install = true,
    highlight = {
        enable = true,
    },
    modules = {},
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 10000,
        -- colors = {},
    },
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = { query = "@function.outer", desc = "Select outer function" },
                ["if"] = { query = "@function.inner", desc = "Select inner function" },
                ["ac"] = { query = "@class.outer", desc = "Select outer class" },
                ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                ["aa"] = { query = "@parameter.outer", desc = "Select outer argument" },
                ["ia"] = { query = "@parameter.inner", desc = "Select inner argument" },
                ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
                ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },
            },
            selection_modes = {
                ["@function.inner"] = "V",
                ["@function.outer"] = "V",
                ["@class.inner"] = "V",
                ["@class.outer"] = "V",
                ["@conditional.inner"] = "v",
                ["@conditional.outer"] = "V",
            }
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]f"] = { query = "@function.outer", desc = "Next function" },
                ["]c"] = { query = "@class.outer", desc = "Next class" },
                ["]a"] = { query = "@parameter.outer", desc = "Next argument" },
                ["]i"] = { query = "@conditional.outer", desc = "Next conditional" },
            },
            goto_previous_start = {
                ["[f"] = { query = "@function.outer", desc = "Previous function" },
                ["[c"] = { query = "@class.outer", desc = "Previous class" },
                ["[a"] = { query = "@parameter.outer", desc = "Previous argument" },
                ["[i"] = { query = "@conditional.outer", desc = "Previous conditional" },
            }
        }
    }
}
return Config
