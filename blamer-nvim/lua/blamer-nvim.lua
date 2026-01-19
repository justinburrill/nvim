local M = {}

--- @type integer | nil
local POPUP_WINDOW = nil

local function log(s)
    vim.api.nvim_echo({ { s } }, true, {})
end

local function strip(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

--- @param strings string[] Strings
--- @return integer
local function max_line_length(strings)
    local max = 10
    for _i, s in ipairs(strings) do
        if #s > max then max = #s end
    end
    return max
end

function Focus_popup_window()
    if POPUP_WINDOW == nil then return end
    vim.api.nvim_set_current_win(POPUP_WINDOW)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

--- @param lines string[] The text to place in the window
function Open_popup_window(lines)
    local current_window_id = vim.api.nvim_get_current_win()
    local _bufnum, bufline, bufcol, _offset = unpack(vim.fn.getpos("."))
    local screenpos = vim.fn.screenpos(current_window_id, bufline, bufcol)
    if #screenpos == 0 then
        log(("Failed to get screenpos (invalid winid %s)"):format(current_window_id))
        return
    end
    local screenrow = screenpos["row"];
    local screencol = screenpos["col"]; -- first screen col (not "curscol")

    local newbuf = vim.api.nvim_create_buf(false, true)

    local win = vim.api.nvim_open_win(newbuf, false, {
        relative = "editor",
        row = screenrow,
        col = screencol,
        width = max_line_length(lines),
        height = #lines,
        style = "minimal",
        border = "rounded"
    })
    if 0 == win then
        log("Failed to create window")
        return
    end
    POPUP_WINDOW = win

    vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, lines)

    function Close_blame_window()
        vim.api.nvim_buf_delete(newbuf, { force = true })
        POPUP_WINDOW = nil
    end

    local close_window_autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
        -- TODO: uncomment?
        -- buffer = vim.api.nvim_get_current_buf(),
        callback = Close_blame_window,
        once = true,
    })

    vim.keymap.set("n", "q", function()
        Close_blame_window()
        vim.api.nvim_del_autocmd(close_window_autocmd_id)
    end, { buffer = newbuf })

    vim.api.nvim_set_option_value("modifiable", false, { buf = newbuf })
end

---@param line integer Line number for blame
---@return string[] | nil lines of output
function Get_blame_text(line)
    local cmd = { "git", "blame", vim.fn.expand("%"), "--color-lines", "--root", "-L", string.format("%d,%d", line, line) }

    local proc = vim.system(cmd):wait(500)
    if proc.code == 124 then
        log("Timeout waiting for command: " .. cmd)
        return nil
    end
    local output = vim.split(strip(proc.stdout) .. strip(proc.stderr), "\n")
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
