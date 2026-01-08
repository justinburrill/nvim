
require "utils"
local lspconfig_util = require("lspconfig.util")
vim.lsp.enable({ "lua_ls", "clangd", "basedpyright", "rust_analyzer", "ts_ls", "bashls", "jsonls", "vue_ls" })
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
vim.lsp.config("clangd", {
    cmd = { "clangd", "--compile-commands-dir=/home/justin" },
    filetypes = { "c", "cpp", "cc", "ixx", "cuda", "cu", "objcpp", "objc" },
})
vim.lsp.config("rust_analyzer", {})


vim.lsp.config("ts_ls", {
    root_dir = Root_pattern_exclude({
        root = { "package.json" },
        exclude = { "deno.json", "deno.jsonc" }
    }),
    single_file_support = false,
    settings = {
        javascript = {
            suggest = {
                autoImports = true,
            },
            diagnostics = {
                ignore = {"[Deno]"},
            },
        },
        typescript = {
            suggest = {
                autoImports = true,
            },
            diagnostics = {
                ignore = {"[Deno]"},
            },
            tsserverFilePaths = { "path/to/deno" },
        },
    },
})


vim.lsp.config("denols", {
    root_dir = lspconfig_util.root_pattern("deno.json", "deno.jsonc", "deno.lock"),
    init_options = {
        lint = true,
        suggest = {
            imports = {
                hosts = {
                    ["https://deno.land"] = true,
                },
            },
        },
    },
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
