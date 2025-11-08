require "utils"
require "mini.extra"
local commentapi = require("Comment.api")
local escape_key = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>m", ":messages<CR>", { desc = "Show messages" })
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Code format" })
vim.keymap.set("v", "<leader>cf", vim.lsp.buf.format, { desc = "Code format selection" })
vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover)
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>") -- omnifunc autocomplete
vim.keymap.set("i", "<C-z>", function()
    -- TODO:make this delete something i just pasted from "* or "+ with C-v
    -- if the text before my cursor isn't from the clipboard, then delete
    -- until punctuation or x many characters or something
end)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show all references" })
vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { desc = "Show signature" })
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Show signature" })
vim.keymap.set("n", "<leader>e", ":Oil<CR>", {desc="Oil explorer"})
vim.keymap.set("v", "<leader>o", ":Open<CR>", {desc="Open link"})
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", {desc="Hide / highlight"})
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>pf", ":Pick files<CR>", { desc = "Pick files" })
vim.keymap.set("n", "<leader>ph", ":Pick help<CR>", { desc = "Pick help" })
vim.keymap.set("n", "<leader>pH", ":Pick hl_groups<CR>", { desc = "Pick highlight groups" })
vim.keymap.set("n", "<leader>pb", ":Pick buffers<CR>", { desc = "Pick buffers" })
vim.keymap.set("n", "<leader>pd", ":Pick diagnostic<CR>", { desc = "Pick diagnostic" })
vim.keymap.set("n", "<leader>pe", ":Pick explorer<CR>", { desc = "Pick explorer" })
vim.keymap.set("n", "<leader>pc", ":Pick commands<CR>", { desc = "Pick commands" })
vim.keymap.set("n", "<leader>pg", ":Pick grep_live<CR>", { desc = "Pick grep" })
vim.keymap.set("n", "<leader>pG", ":Pick buf_lines scope='current'<CR>", { desc = "Pick grep in current buf" })
vim.keymap.set("n", "<leader>pr", function()
    MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Pick references" })
vim.keymap.set("n", "<leader>bq", ":bp|bd #<CR>", { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "View diagnostic" })
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Jump to previous diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Jump to next diagnostic" })
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
vim.keymap.set("i", "<C-H>", "<C-W>") -- delete word with ctrl+backspace

-- linewise COMMENTS with CTRL
-- TODO: cursor isn't placed correctly when I start a comment on an empty line
vim.keymap.set({ "i", "n" }, "<C-_>", commentapi.toggle.linewise.current)
vim.keymap.set("x", "<C-_>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.linewise(vim.fn.visualmode())
end)
-- blockwise comment with ALT
vim.keymap.set("n", "<M-/>", commentapi.toggle.blockwise.current)
vim.keymap.set("x", "<M-/>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.blockwise(vim.fn.visualmode()) -- once upon a time there was a lazy brown dog that jumped over a quick fox or something
end)
-- TODO: create comment at cursor if I do ALT while in insert mode
-- vim.keymap.set("i", "<M-/>", function() commentapi.
