local M = {}


require "blamer-nvim.lua.popups"
require "blamer-nvim.lua.blamer-utils"


---@param line integer Line number for blame
---@return string[] | nil lines of output
function Get_blame_text(line)
    local cmd = { "git", "blame", vim.fn.expand("%"), "--color-lines", "--root", "-L", string.format("%d,%d", line, line) }

    local proc = vim.system(cmd):wait(500)
    if proc.code == 124 then
        Log("Timeout waiting for command: " .. cmd)
        return nil
    end
    local output = vim.split(Strip(proc.stdout) .. Strip(proc.stderr), "\n")
    return output
end

function Open_blame_window()
    local _bufnum, bufline, _bufcol, _offset = unpack(vim.fn.getpos("."))

    local output = Get_blame_text(bufline)
    if output == nil then return end
    if POPUP_WINDOW == nil then
        Open_popup_window(output)
    else
        Focus_popup_window()
    end
end

function M.setup(opts)
    opts = opts or {}
    vim.api.nvim_create_user_command("Blame", Open_blame_window, {})
    local keymap = opts.keymap or "<leader>gb"
    vim.keymap.set("n", keymap, Open_blame_window, {
        desc = "Git blame",
        silent = true
    })
end

return M
