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
        if s:len() > max then max = s:len() end
    end
    return max
end

function focus_popup_window()
    if POPUP_WINDOW == nil then return end
    vim.api.nvim_set_current_win(POPUP_WINDOW)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

--- @param lines string[] The output
function open_popup_window(lines)
    local cursor_pos = vim.api.nvim_get_current_win()
    local screen_row, screen_col = unpack(vim.api.nvim_win_get_cursor(cursor_pos))

    local newbuf = vim.api.nvim_create_buf(false, true)

    local win = vim.api.nvim_open_win(newbuf, false, {
        relative = "editor",
        row = screen_row,
        col = screen_col + 5,
        width = max_line_length(lines),
        height = #lines,
        style = "minimal",
        border = "rounded"
    })
    if 0 == win then
        log("WINDOW FAIL")
        return
    end
    POPUP_WINDOW = win

    vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, lines)

    function close_blame_window()
        vim.api.nvim_buf_delete(newbuf, { force = true })
        POPUP_WINDOW = nil
    end

    local close_window_autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
        -- TODO: uncomment?
        -- buffer = vim.api.nvim_get_current_buf(),
        callback = close_blame_window,
        once = true,
    })

    vim.keymap.set("n", "q", function()
        close_blame_window()
        vim.api.nvim_del_autocmd(close_window_autocmd_id)
    end, { buffer = newbuf })

    vim.api.nvim_set_option_value("modifiable", false, { buf = newbuf })
end

function M.open_blame_window()
    local _bufnum, line, _column, _off = unpack(vim.fn.getpos("."))

    local cmd = { "git", "blame", vim.fn.expand("%"), "--root", "-L", string.format("%d,%d", line, line) }

    local proc = vim.system(cmd):wait(500)
    if proc.code == 124 then
        log("GIT FAIL")
        return
    end
    local output = vim.split(strip(proc.stdout) .. strip(proc.stderr), "\n")
    if POPUP_WINDOW == nil then
        open_popup_window(output)
    else
        focus_popup_window()
    end
end

function M.setup(opts)
    opts = opts or {}
    vim.api.nvim_create_user_command("Blame", M.open_blame_window, {})
    local keymap = opts.keymap or "<leader>gb"
    vim.keymap.set("n", keymap, M.open_blame_window, {
        desc = "Git blame",
        silent = true
    })
end

return M
