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

vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/vague2k/vague.nvim",             name = "vague" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/echasnovski/mini.pick" },
    { src = "https://github.com/echasnovski/mini.surround" },
    { src = "https://github.com/numToStr/Comment.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    -- { src = "https://github.com/folke/lazydev.nvim ", ft = "lua" }, -- using the one below until folke comes back from vacation
    { src = "https://github.com/Jari27/lazydev.nvim",            name = "lazydev", ft = "lua", version = "deprecate_client_notify" },
})
local commentapi = require("Comment.api")
local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

require "lazydev".setup()
require "mini.pick".setup()
require "mini.surround".setup()
require "oil".setup()

require("vague").setup({
    style = {
        strings = "none",
        keywords = "bold",
    },
})
vim.cmd("colorscheme vague")

vim.lsp.enable({ "lua_ls", "clangd", "basedpyright" })
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportUnknownParameterType = false,
                    reportUnknownVariableType = false,
                    reportMissingParameterType = false
                }
            }
        }
    }
})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover)
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>")
vim.keymap.set("n", "<leader>e", ":Oil<CR>")
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>o", ":Pick files<CR>")
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)

-- linewise comment
vim.keymap.set({ "i", "n" }, "<C-_>", function() commentapi.toggle.linewise.current() end)
vim.keymap.set("x", "<C-_>", function()
    vim.api.nvim_feedkeys(esc, "nx", false)
    commentapi.toggle.linewise(vim.fn.visualmode())
end)
-- blockwise comment
vim.keymap.set({ "i", "n" }, "<M-/>", function() commentapi.toggle.blockwise.current() end)
vim.keymap.set("x", "<M-/>", function()
    vim.api.nvim_feedkeys(esc, "nx", false)
    commentapi.toggle.blockwise(vim.fn.visualmode())
end)

-- tell autocomplete about neovim lsp completion
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})
