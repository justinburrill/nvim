vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.winborder = "rounded"
vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
    },
    paste = {
        ['+'] =
        'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] =
        'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
}

-- PLUGINS PACKAGES
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/vague2k/vague.nvim",             name = "vague" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/echasnovski/mini.pick" },
    { src = "https://github.com/echasnovski/mini.surround" },
    { src = "https://github.com/nvim-lua/plenary.nvim"},
    { src = "https://github.com/numToStr/Comment.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    -- { src = "https://github.com/folke/lazydev.nvim ", ft = "lua" }, -- using the one below until folke comes back from vacation
    { src = "https://github.com/Jari27/lazydev.nvim",            name = "lazydev", ft = "lua", version = "deprecate_client_notify" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/nvimtools/none-ls.nvim" },
})

local lspconfig = require("lspconfig")
local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
    }
})
require "lazydev".setup()
require "mini.pick".setup()
require "mini.surround".setup({
    n_lines = 50,
})
require "nvim-treesitter".setup()
require "oil".setup()
require "mason".setup()
require "mason-lspconfig".setup()
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
    }
end

-- LSPCONFIG
vim.lsp.enable({ "lua_ls", "clangd", "basedpyright", "rust_analyzer", "denols", "ts_ls", "bashls" })
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
                }
            }
        }
    }
})
vim.lsp.config("denols", {
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
})
vim.lsp.config("ts_ls", {
    root_dir = lspconfig.util.root_pattern("package.json"),
    single_file_support = false
})

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
local commentapi = require("Comment.api")
local escape_key = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Code format" })
vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover)
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>") -- omnifunc autocomplete
vim.keymap.set("i", "<C-z>", function()
    -- TODO make this delete something i just pasted from "* or "+ with C-v
    -- if the text before my cursor isn't from the clipboard, then delete
    -- until punctuation or x many characters or something
end)
vim.keymap.set("n", "<leader>e", ":Oil<CR>")
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>o", ":Pick files<CR>", { desc = ":Pick files" })
vim.keymap.set("n", "<leader>ph", ":Pick help<CR>", { desc = ":Pick help" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "View diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = "Jump to previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = "Jump to next diagnostic" })
vim.keymap.set("i", "<C-H>", "<C-W>") -- delete word with ctrl+backspace

-- linewise comment
vim.keymap.set({ "i", "n" }, "<C-_>", function() commentapi.toggle.linewise.current() end)
vim.keymap.set("x", "<C-_>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.linewise(vim.fn.visualmode())
end)
-- blockwise comment
vim.keymap.set({ "i", "n" }, "<M-/>", function() commentapi.toggle.blockwise.current() end)
vim.keymap.set("x", "<M-/>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.blockwise(vim.fn.visualmode())
end)


-- ACTIVATE COLOURSCHEME
require "vague".setup({
    style = {
        strings = "none",
        keywords = "bold",
    },
})
vim.cmd("colorscheme vague")
