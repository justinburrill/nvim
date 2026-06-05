local M = {}

-- deprecation fix
table.unpack = table.unpack or unpack

require "blamer-nvim.lua.popups"
require "blamer-nvim.lua.blamer-utils"

--- @class BlameData
--- @field author string?
--- @field author_email string?
--- @field committer string?
--- @field committer_email string?
--- @field hash string?
--- @field summary string?
--- @field new_text string?
--- @field filename string?
--- @field original_line_num number?
--- @field final_line_num number?
--- @field previous_hash string?
--- @field previous_filename string?

--- @param blame_output_lines string[]
--- @return BlameData
-- TODO: fix this func
function Extract_data_from_blame(blame_output_lines)
    --- @type BlameData
    local commit_data = {}
    local text_line = Get_line_starting_with(blame_output_lines, "\t")
    if text_line ~= nil then
        -- the line starting with a tab is the text
        commit_data.new_text = Remove_prefix(text_line, "\t", false)
    end
    local hash, orig_line_num, final_line_num = table.unpack(Split_fast(blame_output_lines[1]))
    commit_data.hash = string.sub(hash, 1, 8)
    commit_data.original_line_num = tonumber(orig_line_num)
    commit_data.final_line_num = tonumber(final_line_num)
    local auto_extract_keys = { "summary", "author", "previous", "committer", "author-email", "committer-email" }
    local auto_copy_keys = { "summary", "author" } -- don't need extra handling
    local auto_extracted_data = {}
    for _, key_name in ipairs(auto_extract_keys) do
        local line = Get_line_starting_with(blame_output_lines, key_name:gsub("_", "-"))
        if line == nil then
            auto_extracted_data[key_name] = nil
        else
            local parts = Split_count(line, nil, 1)
            auto_extracted_data[key_name] = parts[#parts] or ("<no " .. key_name .. ">")
        end
    end
    for _, key_name in ipairs(auto_copy_keys) do
        commit_data[key_name] = auto_extracted_data[key_name]
    end
    if auto_extracted_data.previous ~= nil then
        local prev_hash, prev_filename = table.unpack(Split_fast(auto_extracted_data.previous))
        commit_data.previous_hash = prev_hash
        commit_data.previous_filename = prev_filename
    end

    -- Log("from lines: " .. Stringit(blame_output_lines) .. "\nmade this data: " .. Stringit(commit_data))
    return commit_data
end

---@param line_start integer
---@param line_end integer
---@param filename string
---@return string[]
function Run_git_blame(line_start, line_end, filename)
    local cmd = {
        "git", "blame", "--porcelain", "--abbrev=6", "--root",
        "-L", string.format("%d,%d", line_start, line_end),
        "--", filename,
    }
    local blame_output_lines, blame_rc = Run_command(cmd)
    local errmsg = Get_line_containing(blame_output_lines, "error: ") or
        Get_line_containing(blame_output_lines, "fatal: ")
    if errmsg ~= nil and blame_rc ~= 0 then
        error("Got error message from git: '" ..
            errmsg .. "'" .. ", with command: " .. table.concat(cmd, " "))
    end
    return blame_output_lines
end

---@class BlameTextDisplayData
---@field lines string[]
---@field green_hl_line_start number
---@field green_hl_line_end number
---@field red_hl_line_start number
---@field red_hl_line_end number

---@param line_num integer Line number for blame
---@return BlameTextDisplayData
function Format_blame_popup(line_num)
    local function format_author_line(blame_obj)
        local author_line
        if tonumber(blame_obj.hash) ~= 0 then
            author_line = ("%s by %s"):format(blame_obj.hash or "<no hash>", blame_obj.author or "<no author>")
        else
            author_line = "~~~ Not yet committed ~~~"
        end

        if blame_obj.committer ~= nil and blame_obj.committer ~= blame_obj.author then
            author_line = author_line .. " committed by " .. blame_obj.committer
        end
        return author_line
    end
    local blame_output_lines = Run_git_blame(line_num, line_num, vim.fn.expand("%"))
    local blame_info = Extract_data_from_blame(blame_output_lines)

    local latest_commit_author_line = format_author_line(blame_info)
    --- @type string[]
    local display_text = {
        latest_commit_author_line,
        ('"' .. blame_info.summary .. '"') or "<no summary>",
        blame_info.new_text or "<no text>",
    }
    local number_of_Before_lines = #display_text
    local red_hl_line_end = number_of_Before_lines + 2
    if blame_info.previous_hash ~= nil then
        local prev_blame_output = Run_git_blame(blame_info.original_line_num, blame_info.original_line_num, blame_info.previous_filename)
        local previous_blame_info = Extract_data_from_blame(prev_blame_output)
        table.insert(display_text,
            ("%s %s"):format(previous_blame_info.hash or "<no hash>",
                previous_blame_info.author or "<no author>"))
        if previous_blame_info.summary ~= nil then
            table.insert(display_text, Strip('"' .. previous_blame_info.summary .. '"'))
        else
            table.insert(display_text, "<no summary>")
        end
        table.insert(display_text, Strip(previous_blame_info.new_text) or "<no text>")
    else
        table.insert(display_text, "No previous commit")
        red_hl_line_end = number_of_Before_lines + 1
    end


    ---@type BlameTextDisplayData
    local out = {
        lines = display_text,
        green_hl_line_start = 1,
        green_hl_line_end = 2,
        red_hl_line_start = number_of_Before_lines + 1,
        red_hl_line_end = red_hl_line_end,
    }

    return out
end

function Open_blame_window()
    local _, bufline, _, _ = table.unpack(vim.fn.getpos("."))

    local blame_data = Format_blame_popup(bufline)
    if blame_data == nil then error("blame_data is nil...") end
    if POPUP_WINDOW == nil then
        local buf_id = Open_popup_window(blame_data.lines)
        if buf_id == nil then
            error("Failed to create buffer")
        else
            Highlight_line(
                buf_id, blame_data.green_hl_line_start, blame_data.green_hl_line_end, "tempgreen", "DiffAdd")
            Highlight_line(
                buf_id, blame_data.red_hl_line_start, blame_data.red_hl_line_end, "tempred", "DiffDelete")
        end
    else
        Focus_popup_window()
    end
end

--- @class (exact) BlamerOpts
--- @field keymap string

---@param opts BlamerOpts | nil
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
