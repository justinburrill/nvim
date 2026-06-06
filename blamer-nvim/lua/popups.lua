--- Store the window id for the currently open popup window (only one at a time)
--- @type integer | nil
POPUP_WINDOW = nil

function Focus_popup_window()
    if POPUP_WINDOW == nil then return end
    vim.api.nvim_set_current_win(POPUP_WINDOW)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

--- @param text_lines string[] The text to place in the window
--- @return number | nil newbuf The buffer id
function Open_popup_window(text_lines)
    if text_lines == nil then
        error("Passed nil instead of string[] for param text_lines")
    end
    local current_window_id = vim.api.nvim_get_current_win()
    local _, bufline, bufcol, _ = table.unpack(vim.fn.getpos("."))
    local screenpos = vim.fn.screenpos(current_window_id, bufline, bufcol)
    if screenpos == {} then
        error(("Failed to get screenpos (invalid winid %s)"):format(current_window_id))
        return nil
    end
    local screenrow = screenpos["row"];

    local newbuf = vim.api.nvim_create_buf(false, true)
    if newbuf == 0 then
        error("Failed to create a buffer")
        return nil
    end

    local win = vim.api.nvim_open_win(newbuf, false, {
        relative = "editor",
        row = screenrow,
        col = 5,
        width = Max_line_length(text_lines, 10),
        height = #text_lines,
        style = "minimal",
        border = "rounded"
    })
    if 0 == win then
        error("Failed to create window")
        return nil
    end
    POPUP_WINDOW = win

    -- Log("Creating window with lines: " .. Stringit(text_lines))
    vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, text_lines)

    function Close_blame_buffer()
        if vim.api.nvim_buf_is_loaded(newbuf) then
            vim.api.nvim_buf_delete(newbuf, { force = true })
            POPUP_WINDOW = nil
        end
    end

    local cursor_move_autocmd = vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        buffer = vim.api.nvim_get_current_buf(),
        callback = Close_blame_buffer,
        once = true,
    })

    -- IMPROVE: 
    -- local buf_leave_autocmd = vim.api.nvim_create_autocmd({ "BufLeave" }, {
    --     buffer = newbuf,
    --     callback = Close_blame_buffer,
    --     once = true,
    -- })

    vim.keymap.set("n", "q", function()
        Close_blame_buffer()
        vim.api.nvim_del_autocmd(cursor_move_autocmd)
        -- vim.api.nvim_del_autocmd(buf_leave_autocmd)
    end, { buffer = newbuf })

    vim.api.nvim_set_option_value("modifiable", false, { buf = newbuf })
    return newbuf
end
