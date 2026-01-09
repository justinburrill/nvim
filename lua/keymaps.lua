require "utils"
require "mini.extra"
local commentapi = require("Comment.api")
local escape_key = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>m", ":messages<CR>", { desc = "Show messages" })
vim.keymap.set("n", "<leader>M", ":Mason<CR>", { desc = "Mason" })
vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover)

-- completion popup interaction
local function is_pumvisible()
    return tonumber(vim.fn.pumvisible()) ~= 0
end
local function is_preinserted()
    return vim.fn.preinserted() ~= 0
end
local function popupaction(visible, not_visible)
    if is_pumvisible() then
        return visible
    else
        return not_visible
    end
end
local function accept_current_complete()
    if is_preinserted() then
        return "<C-Y>"
    else
        -- <C-X><C-Z> is like <C-Y> but it works even if no completion choices were selected
        return "<C-X><C-Z>"
    end
end

-- completion interaction
vim.keymap.set("i", "<C-Space>", "<C-X><C-O>", { desc = "omnifunc completion", silent = true })
vim.keymap.set("i", "<Tab>", function() return popupaction("<C-N>", "<Tab>") end,
    { silent = true, expr = true, remap = true })
vim.keymap.set("i", "<S-Tab>", function() return popupaction("<C-P>", "<S-Tab>") end,
    { silent = true, expr = true, remap = true })
vim.keymap.set("i", "<Down>", function() return popupaction("<C-N>", "<Down>") end, { silent = true, expr = true })
vim.keymap.set("i", "<Up>", function() return popupaction("<C-P>", "<Up>") end, { silent = true, expr = true })
vim.keymap.set("i", "<Esc>", function() return popupaction(accept_current_complete() .. "<Esc>", "<Esc>") end,
    { silent = true, expr = true })
vim.keymap.set("i", "<CR>", function() return popupaction(accept_current_complete(), "<CR>") end,
    { silent = true, expr = true })

-- TODO: figure out why I can't jump in snippets

-- basic LSP stuff

vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ timeout_ms = 2500 }) end, { desc = "Code format" })
vim.keymap.set("v", "<leader>cf", function() vim.lsp.buf.format({ timeout_ms = 2500 }) end,
    { desc = "Code format selection" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show all references" })
vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { desc = "Show signature" })
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Show signature" })

vim.keymap.set("n", "gp", "`[v`]", { desc = "Reselect paste" })
vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Oil explorer" })
vim.keymap.set("n", "<leader>E", ":Oil<CR>_", { desc = "Oil explorer at CWD" })
vim.keymap.set("n", "<leader>I", ":Inspect<CR>", { desc = "Inspect" })
vim.keymap.set("n", "<leader>s", ":w | so<CR>", { desc = "Save and source" })
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Hide / highlight", silent = true })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "View diagnostic" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>ch", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = "Enable inlay hints" })

-- mini.pick pickers

vim.keymap.set("n", "<leader>pf", ":Pick files<CR>", { desc = "Pick files" })
vim.keymap.set("n", "<leader>ph", ":Pick help<CR>", { desc = "Pick help" })
vim.keymap.set("n", "<leader>pH", ":Pick hl_groups<CR>", { desc = "Pick highlight groups" })
vim.keymap.set("n", "<leader>pb", ":Pick buffers<CR>", { desc = "Pick buffers" })
vim.keymap.set("n", "<leader>pd", ":Pick diagnostic<CR>", { desc = "Pick diagnostic" })
vim.keymap.set("n", "<leader>pe", ":Pick explorer<CR>", { desc = "Pick explorer" })
vim.keymap.set("n", "<leader>pc", ":Pick commands<CR>", { desc = "Pick commands" })
vim.keymap.set("n", "<leader>pg", ":Pick grep_live<CR>", { desc = "Pick grep" })
vim.keymap.set("n", "<leader>pG", ":Pick buf_lines scope='current'<CR>", { desc = "Pick grep in current buf" })
vim.keymap.set("n", "<leader>P", ":Pick resume<CR>", { desc = "Resume Pick" })
vim.keymap.set("n", "<leader>pr", function()
    MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Pick references" })

-- my keybinds !!

vim.keymap.set("i", "<C-H>", "<C-W>")            -- delete word with ctrl+backspace
vim.keymap.set("i", "<C-Del>", "<space><esc>ce") -- delete word with ctrl+del
vim.keymap.set("n", "<leader>q", ":bp|bd #<CR>", { desc = "Quit buffer" })
--[[ vim.keymap.set("i", "<C-z>", function()
    -- TODO:make this delete something i just pasted from "* or "+ with C-v
    -- if the text before my cursor isn't from the clipboard, then delete
    -- until punctuation or x many characters or something
end) ]]

-- jumping through

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

vim.keymap.set("n", "]T", ":tabNext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "[T", ":tabprevious<CR>", { desc = "Previous tab" })

-- comments


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

-- vscode motions
vim.keymap.set({ "i", "n" }, "<S-Up>", "Vk")
vim.keymap.set({ "i", "n" }, "<S-Down>", "Vj")
vim.keymap.set("x", "<S-Up>", "k")
vim.keymap.set("x", "<S-Down>", "j")

vim.keymap.set("x", "<M-Up>", function() vim.cmd("normal! dkP`[V`]") end)
vim.keymap.set("x", "<M-Down>", function() vim.cmd("normal! dp`[V`]") end)
vim.keymap.set({ "i", "n" }, "<M-Up>", function() vim.cmd("normal! ddkP") end)
vim.keymap.set({ "i", "n" }, "<M-Down>", function() vim.cmd("normal! ddp") end)
