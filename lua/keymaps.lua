require "utils"
require "mini.extra"
local commentapi = require("Comment.api")
local escape_key = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
local oA_space_keys = vim.api.nvim_replace_termcodes("<C-o>A ", true, false, true)
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>m", ":messages<CR>", { desc = "Show messages" })
vim.keymap.set("n", "<leader>M", ":Mason<CR>", { desc = "Mason" })
vim.keymap.set({ "n", "x" }, "<C-Space>", vim.lsp.buf.hover)

vim.api.nvim_create_user_command("LspLog", function(_)
    local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "logs/lsp.log")
    vim.cmd(string.format("edit %s", log_path))
end, { desc = "Show LSP log" })
vim.keymap.set("n", "<leader>LL", ":LspLog<CR>") -- TODO: what's the new version of this? read https://jdhao.github.io/2026/04/02/nvim-v012-release/
vim.keymap.set("n", "<leader>LI", ":checkhealth vim.lsp<CR>")
vim.keymap.set("n", "<leader>LR", ":lsp restart<CR>")

-- Jump between splits
vim.keymap.set("n", "<C-J>", "<C-W>j")
vim.keymap.set("n", "<C-K>", "<C-W>k")
vim.keymap.set("n", "<C-H>", "<C-W>h")
vim.keymap.set("n", "<C-L>", "<C-W>l")

vim.keymap.set("n", "<M-j>", "<C-E>", { desc = "Scroll down one line" })
vim.keymap.set("n", "<M-k>", "<C-Y>", { desc = "Scroll up one line" })
vim.keymap.set("i", "<M-j>", "<C-o><C-E>", { desc = "Scroll down one line" })
vim.keymap.set("i", "<M-k>", "<C-o><C-Y>", { desc = "Scroll up one line" })

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
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>:<CR>", { desc = "Hide / highlight" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "View diagnostic" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>ch", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = "Enable inlay hints", silent = false })

-- mini.pick pickers

vim.keymap.set("n", "<leader>pf", ":Pick files<CR>", { desc = "Pick files" })
vim.keymap.set("n", "<leader>ph", ":Pick help<CR>", { desc = "Pick help" })
vim.keymap.set("n", "<leader>pH", ":Pick hl_groups<CR>", { desc = "Pick highlight groups" })
vim.keymap.set("n", "<leader>pb", ":Pick buffers<CR>", { desc = "Pick buffers" })
vim.keymap.set("n", "<leader>pd", ":Pick diagnostic<CR>", { desc = "Pick diagnostic" })
vim.keymap.set("n", "<leader>pe", ":Pick explorer<CR>", { desc = "Pick explorer" })
vim.keymap.set("n", "<leader>pc", ":Pick commands<CR>", { desc = "Pick commands" })
vim.keymap.set("n", "<leader>pg", ":Pick grep_live<CR>", { desc = "Pick grep" })
vim.keymap.set("n", "<leader>ps", ":Pick lsp scope='document_symbol'<CR>", { desc = "Pick document symbols" })
vim.keymap.set("n", "<leader>pS", ":Pick lsp scope='workspace_symbol'<CR>", { desc = "Pick workspace symbols" })
vim.keymap.set("n", "<leader>pl", ":Pick buf_lines scope='current'<CR>", { desc = "Pick lines in current buffer" })
vim.keymap.set("n", "<leader>pL", ":Pick buf_lines scope='all'<CR>", { desc = "Pick lines in all buffers" })
vim.keymap.set("n", "<leader>pCu", ":Pick git_hunks scope='unstaged'<CR>", { desc = "Pick unstaged changes" })
vim.keymap.set("n", "<leader>pCs", ":Pick git_hunks scope='staged'<CR>", { desc = "Pick staged changes" })
vim.keymap.set("n", "<leader>P", ":Pick resume<CR>", { desc = "Resume Pick" })
vim.keymap.set("n", "<leader>pr", function()
    MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Pick references" })

-- my keybinds !!
vim.keymap.set("n", "<leader>rc", ":let @\"=@+<CR>", { desc = "Re-copy (\"+)" })
vim.keymap.set("i", "<C-H>", "<C-W>")                                      -- delete word with ctrl+backspace
vim.keymap.set("i", "<C-Del>", "<space><esc>ce")                           -- delete word with ctrl+del
vim.keymap.set("n", "<leader>q", ":bp|bd #<CR>", { desc = "Quit buffer" }) -- IMPROVE: 'bp' isn't what i want here...

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

vim.keymap.set("n", "]T", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "[T", ":tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>t", ":tabnext #<CR>", { desc = "Last tab" })

-- comments

-- linewise COMMENTS with CTRL (C-_ for CTRL+/, don't know why)
vim.keymap.set("n", "<C-_>", commentapi.toggle.linewise.current, { desc = "Toggle line comment" })
vim.keymap.set("i", "<C-_>", function()
    local line_txt = vim.api.nvim_get_current_line():gsub("%s+.*", "")
    if #line_txt ~= 0 then
        commentapi.toggle.linewise.current()
    else
        commentapi.toggle.linewise.current()
        vim.api.nvim_feedkeys(oA_space_keys, "n", false)
    end
end)

vim.keymap.set("x", "<C-_>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.linewise(vim.fn.visualmode())
end)
-- blockwise comment with ALT
vim.keymap.set("n", "<M-/>", commentapi.toggle.blockwise.current)
vim.keymap.set("x", "<M-/>", function()
    vim.api.nvim_feedkeys(escape_key, "nx", false)
    commentapi.toggle.blockwise(vim.fn.visualmode())
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


-- terminal
vim.keymap.set("n", "<leader>T", ":tabnew<CR>:term<CR>A", { desc = "Terminal" })
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { desc = "Esc" })


-- treesitter textobjects
local ts_select = require "nvim-treesitter-textobjects.select"
local ts_move = require "nvim-treesitter-textobjects.move"
local ts_swap = require "nvim-treesitter-textobjects.swap"

vim.keymap.set({ "x", "o" }, "af", function() ts_select.select_textobject("@function.outer", "textobjects") end,
    { desc = "Select around function" })
vim.keymap.set({ "x", "o", }, "af", function() ts_select.select_textobject("@function.outer", "textobjects") end,
    { desc = "Select outer function" })
vim.keymap.set({ "x", "o" }, "if", function() ts_select.select_textobject("@function.inner", "textobjects") end,
    { desc = "Select inside function" })
vim.keymap.set({ "x", "o" }, "ac", function() ts_select.select_textobject("@class.outer", "textobjects") end,
    { desc = "Select around class" })
vim.keymap.set({ "x", "o" }, "ic", function() ts_select.select_textobject("@class.inner", "textobjects") end,
    { desc = "Select inside class" })
vim.keymap.set({ "x", "o" }, "aa", function() ts_select.select_textobject("@parameter.outer", "textobjects") end,
    { desc = "Select around argument" })
vim.keymap.set({ "x", "o" }, "ia", function() ts_select.select_textobject("@parameter.inner", "textobjects") end,
    { desc = "Select inside argument" })
vim.keymap.set({ "x", "o" }, "ai", function() ts_select.select_textobject("@conditional.outer", "textobjects") end,
    { desc = "Select around conditional" })
vim.keymap.set({ "x", "o" }, "ii", function() ts_select.select_textobject("@conditional.inner", "textobjects") end,
    { desc = "Select inside conditional" })

vim.keymap.set({ "n", "x", "o" }, "]f", function() ts_move.goto_next_start("@function.outer", "textobjects") end,
    { desc = "Next function" })
vim.keymap.set({ "n", "x", "o" }, "]c", function() ts_move.goto_next_start("@class.outer", "textobjects") end,
    { desc = "Next class" })
vim.keymap.set({ "n", "x", "o" }, "]a", function() ts_move.goto_next_start("@parameter.outer", "textobjects") end,
    { desc = "Next parameter" })
vim.keymap.set({ "n", "x", "o" }, "]i", function() ts_move.goto_next_start("@conditional.outer", "textobjects") end,
    { desc = "Next conditional" })

vim.keymap.set({ "n", "x", "o" }, "[f", function() ts_move.goto_previous_start("@function.outer", "textobjects") end,
    { desc = "Previous function" })
vim.keymap.set({ "n", "x", "o" }, "[c", function() ts_move.goto_previous_start("@class.outer", "textobjects") end,
    { desc = "Previous class" })
vim.keymap.set({ "n", "x", "o" }, "[a", function() ts_move.goto_previous_start("@parameter.outer", "textobjects") end,
    { desc = "Previous parameter" })
vim.keymap.set({ "n", "x", "o" }, "[i", function() ts_move.goto_previous_start("@conditional.outer", "textobjects") end,
    { desc = "Previous conditional" })

vim.keymap.set({ "n", "x", "o" }, "]F", function() ts_swap.swap_next("@function.outer", "textobjects") end,
    { desc = "Swap next function" })
vim.keymap.set({ "n", "x", "o" }, "]C", function() ts_swap.swap_next("@class.outer", "textobjects") end,
    { desc = "Swap next class" })
vim.keymap.set({ "n", "x", "o" }, "]A", function() ts_swap.swap_next("@parameter.outer", "textobjects") end,
    { desc = "Swap next parameter" })
vim.keymap.set({ "n", "x", "o" }, "]I", function() ts_swap.swap_next("@conditional.outer", "textobjects") end,
    { desc = "Swap next conditional" })

vim.keymap.set({ "n", "x", "o" }, "[F", function() ts_swap.swap_previous("@function.outer", "textobjects") end,
    { desc = "Swap prev function" })
vim.keymap.set({ "n", "x", "o" }, "[C", function() ts_swap.swap_previous("@class.outer", "textobjects") end,
    { desc = "Swap prev class" })
vim.keymap.set({ "n", "x", "o" }, "[A", function() ts_swap.swap_previous("@parameter.outer", "textobjects") end,
    { desc = "Swap prev parameter" })
vim.keymap.set({ "n", "x", "o" }, "[I", function() ts_swap.swap_previous("@conditional.outer", "textobjects") end,
    { desc = "Swap prev conditional" })
