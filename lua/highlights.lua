vim.cmd("highlight @keyword.exception gui=bold")
vim.cmd("highlight @lsp.type.enum guifg=#3e9f75")
vim.cmd("highlight @lsp.type.interface guifg=#4a4063")
vim.cmd("highlight @lsp.type.namespace guifg=#4f7ea5")
vim.cmd("highlight @lsp.type.typeparameter gui=bold")
vim.cmd("highlight @function.builtin gui=bold")
vim.cmd("highlight CursorLineNr cterm=bold guifg=#cdcdcd")
vim.cmd("highlight CursorLine guibg=#353540")
vim.cmd("highlight LspInlayHint gui=underline,italic guifg=#606079")
vim.cmd("highlight Macro guifg=#783f8e")
vim.cmd("highlight StatusLine guifg=#e8f3ff")
vim.cmd("highlight StatusLineNC guifg=#544f61")
vim.cmd("highlight lineNrAbove guifg=#764646") -- red
vim.cmd("highlight lineNrBelow guifg=#5c7351") -- green

vim.cmd("highlight! link @lsp.type.macro Macro")
vim.cmd("highlight! link @lsp.type.function @function")
vim.cmd("highlight! link @lsp.typemod.function @function")
vim.cmd("highlight! link @function.call @function")
vim.cmd("highlight! link @lsp.typemod.function.builtin @function.builtin")
-- copied from DiagnosticUnderlineInfo
vim.cmd("highlight! DiagnosticUnnecessary cterm=underline gui=undercurl guisp=#aeaed1 guifg=#606079")
