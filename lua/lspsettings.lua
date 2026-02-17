require "utils"
local lspconfig_util = require("lspconfig.util")
vim.lsp.enable({ "lua_ls", "clangd", "basedpyright", "rust_analyzer", "ts_ls", "bashls", "jsonls", "vue_ls", "hls",
    "neocmake", "zls" })


local lspconfig = require("lspconfig")

lspconfig.opts = {
    servers = {
        clangd = {
            mason = false
        }
    }
}

vim.lsp.config('lua_ls', {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath('config')
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Tell the language server how to find Lua modules same way as Neovim (see `:h lua-module-load`)
                path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
        })
    end,
    settings = {
        Lua = {},
        telemetry = { enable = false }
    },
})

-- TODO: merge with above
-- vim.lsp.config("lua_ls", {
--     settings = {
--         -- diagnostics = { globals = { "vim" }, },
--         -- workspace = { library = vim.api.nvim_get_runtime_file("", true), },
--         telemetry = { enable = false }
--     }
-- })

vim.lsp.config("neocmake", {
    cmd = { "neocmakelsp", "stdio" }
})

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
    cmd = { "clangd", "--background-index" },
    filetypes = { "c", "cpp", "cuda", "objcpp", "objc" },
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
                ignore = { "[Deno]" },
            },
        },
        typescript = {
            suggest = {
                autoImports = true,
            },
            diagnostics = {
                ignore = { "[Deno]" },
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
