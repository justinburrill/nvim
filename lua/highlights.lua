vim.cmd("highlight @function.builtin gui=bold")
vim.cmd("highlight @keyword.exception gui=bold")
vim.cmd("highlight @lsp.type.enum guifg=#3e9f75")
vim.cmd("highlight @lsp.type.interface guifg=#d1adad")
vim.cmd("highlight @lsp.type.namespace guifg=#4f7ea5")
vim.cmd("highlight @lsp.type.typeparameter gui=bold")
vim.cmd("highlight @string cterm=NONE gui=NONE guifg=#e8b589")
vim.cmd("highlight @variable guifg=#aeaed1")
vim.cmd("highlight CursorLine guibg=#353540")
vim.cmd("highlight CursorLineNr cterm=bold guifg=#cdcdcd")
vim.cmd("highlight DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guisp=#f3be7c")
vim.cmd("highlight LspInlayHint gui=underline,italic guifg=#606079")
vim.cmd("highlight Macro guifg=#8c6eb2")
vim.cmd("highlight StatusLine guifg=#e8f3ff")
vim.cmd("highlight StatusLineNC guifg=#544f61")
vim.cmd("highlight lineNrAbove guifg=#764646") -- red
vim.cmd("highlight lineNrBelow guifg=#5c7351")
vim.cmd("highlight lineNrBelow guifg=#5c7351") -- green
vim.cmd("highlight @keyword.exception gui=bold guifg=#6e94b2")

vim.cmd("highlight! link String @string")
vim.cmd("highlight! link @lsp.type.macro Macro")
vim.cmd("highlight! link @lsp.type.function @function")
vim.cmd("highlight! link @lsp.typemod.function @function")
vim.cmd("highlight! link @function.call @function")
vim.cmd("highlight! link @lsp.typemod.function.builtin @function.builtin")
vim.cmd("highlight! link pythonConstant @constant.builtin")
vim.cmd("highlight! link pythonEscape Keyword")
vim.cmd("highlight! link pythonFStringDelimiter Keyword")
vim.cmd("highlight! link pythonEllipsis Keyword")
vim.cmd("highlight! link @keyword.import.python Keyword")
vim.cmd("highlight! link @lsp.type.class.python Type")
vim.cmd("highlight! link @lsp.type.class.c Type")

-- copied from DiagnosticUnderlineInfo
vim.cmd("highlight! DiagnosticUnnecessary cterm=underline gui=undercurl guisp=#aeaed1 guifg=#606079")


-- TODO:
-- adjust priorities for LSP tokens
-- vim.api.nvim_create_autocmd("LspTokenUpdate", {
--     callback = function(args)
--         local token = args.data.token
--     end
-- })
