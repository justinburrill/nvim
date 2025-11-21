package.path = "/home/justin/.config/nvim/?.lua;" .. package.path
package.path = "/home/justin/.config/nvim/?/?.lua;" .. package.path
vim.o.ignorecase = true
vim.o.smartcase = true -- for case-insensitive finding/searching
-- Directly setting format options doesn't work because it is overwritten later (default is jncroql)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufWinEnter" }, {
    pattern = { "*" },
    callback = function() vim.o.formatoptions = "tjn" end,
})
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.winborder = "rounded"
vim.o.showbreak = '↪'
vim.o.fillchars = "stl: ,stlnc: "
vim.o.listchars = 'trail:·,nbsp:+,tab:⟶ ,leadmultispace:\u{258F}   ,extends:▶,precedes:◀,nbsp:⏑'
vim.o.list = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 10
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 10 -- don't create folds after X levels deep

local get_text_from_powershell =
'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw -TextFormatType UnicodeText).tostring().replace("`r", ""))'
vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
    },
    paste = {
        ['+'] = get_text_from_powershell,
        ['*'] = get_text_from_powershell,
    },
    cache_enabled = 0,
}

-- PLUGINS PACKAGES
vim.pack.add({
    { src = "https://github.com/echasnovski/mini.pick" },
    { src = "https://github.com/echasnovski/mini.extra" },
    { src = "https://github.com/echasnovski/mini.surround" },
    { src = "https://github.com/echasnovski/mini.pairs" },
    { src = "https://github.com/folke/lazydev.nvim",                         ft = "lua" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/folke/todo-comments.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/numToStr/Comment.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
    { src = "https://github.com/nvimtools/none-ls.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/mawkler/demicolon.nvim" },
    { src = "https://github.com/mawkler/refjump.nvim" },
    { src = "https://github.com/vague2k/vague.nvim",                         name = "vague" },
})

local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black.with {
            command = "black",
            extra_args = { "--line-length", "100" }
        }
    }
})

require "lazydev".setup()
require "mini.pick".setup()
require "mini.extra".setup()
require "mini.pairs".setup()
require "mini.surround".setup({
    n_lines = 50,
})
require "nvim-treesitter".setup()
require "oil".setup()
require "mason".setup()
require "mason-lspconfig".setup()
require "todo-comments".setup()
require "demicolon".setup({
    keymaps = {
        repeat_motions = "stateful"
    }
})
require "refjump".setup()
require "which-key".setup({
    notify = true,
    preset = "helix",
    delay = 500,
    plugins = {
        marks = true,
        registers = true,
    },
    win = {
        width = { max = 100 },
        no_overlap = false,
        height = { min = 10, max = 30 },
        wo = {
            winblend = 0,
        }
    },
    layout = {
        width = { max = 50 }
    }
})

-- TREESITTER
local treesitter_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if treesitter_ok then
    treesitter_configs.setup {
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
                },
                selection_modes = {
                    ["@function.inner"] = "V",
                    ["@class.inner"] = "V",
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "V",
                }
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]f"] = { query = "@function.outer", desc = "Next function" },
                    ["]c"] = { query = "@class.outer", desc = "Next class" },
                    ["]a"] = { query = "@parameter.outer", desc = "Next argument" },
                },
                goto_previous_start = {
                    ["[f"] = { query = "@function.outer", desc = "Previous function" },
                    ["[c"] = { query = "@class.outer", desc = "Previous class" },
                    ["[a"] = { query = "@parameter.outer", desc = "Previous argument" },
                }
            }
        }
    }
end

-- LSPCONFIG
vim.lsp.enable({ "lua_ls", "clangd", "basedpyright", "rust_analyzer", "denols", "ts_ls", "bashls", "jsonls" })
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportUnknownParameterType = false,
                    reportUnknownVariableType = false,
                    reportUnknownLambdaType = false,
                    reportUnknownMemberType = false,
                    reportUnknownArgumentType = false,
                    reportMissingParameterType = false,
                    reportUnusedCallResult = false,
                    reportAny = false,
                    reportExplicitAny = false,
                    reportUnusedExpression = false,
                    reportMissingTypeArgument = false,
                    reportUntypedFunctionDecorator = false,
                }
            }
        }
    }
})
vim.lsp.config("black", {
    args = { "--line-length", "120" }
})
vim.lsp.config("denols", {
    --root_dir = vim.lsp.util.root_pattern("deno.json", "deno.jsonc"),
})
vim.lsp.config("ts_ls", {
    --root_dir = vim.lsp.util.root_pattern("package.json"),
    single_file_support = false
})
vim.lsp.config("rust_analyzer", {})
vim.lsp.inlay_hint.enable(true)


-- tell autocomplete about neovim lsp completion
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client ~= nil and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
        end
    end,
})

-- KEYBINDS KEYMAPS
require "keymaps"
require "blamer-nvim.lua.blamer-nvim".setup()

-- ACTIVATE COLOURSCHEME
require "vague".setup({
    style = {
        strings = "none",
        keywords = "bold",
    },
})
vim.cmd("colorscheme vague")

-- REMEMBER WITH AUTO-VIEWS AND VIEWOPTIONS
vim.o.viewoptions = "folds,cursor"
-- TODO:
-- vim.api.nvim_create_augroup

-- CUSTOM COMMANDS
vim.api.nvim_create_user_command("Jq", ":%!jq", {})

-- HIGHLIGHTING
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.cmd("highlight StatusLine guifg=#e8f3ff")
vim.cmd("highlight lineNrAbove guifg=#764646") -- red
vim.cmd("highlight lineNrBelow guifg=#5c7351") -- green
vim.cmd("highlight CursorLineNr cterm=bold guifg=#cdcdcd")
vim.cmd("highlight StatusLineNC guifg=#544f61")
