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
            auto_extracted_data[key_name] = parts[#parts]
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

---@class BlameTextDisplayData
---@field lines string[]
---@field green_hl_line_start number
---@field green_hl_line_end number
---@field red_hl_line_start number
---@field red_hl_line_end number

---@param line_num integer Line number for blame
---@return BlameTextDisplayData
function Get_blame_text(line_num)
    local function format_author_line(hash, author)
        -- TODO: ...
    end
    local first_blame_cmd = {
        "git", "blame", "--porcelain", "--abbrev=6", "--root",
        "-L", string.format("%d,%d", line_num, line_num),
        "--", vim.fn.expand("%"),
    }
    local blame_output_lines = Run_command(first_blame_cmd)
    local errmsg = Get_line_containing(blame_output_lines, "error") or Get_line_containing(blame_output_lines, "fatal")
    if errmsg ~= nil then
        error(errmsg)
    end
    local blame_info = Extract_data_from_blame(blame_output_lines)

    -- Log("got blame info: " .. Stringit(blame_info))
    local author_line
    if tonumber(blame_info.hash) ~= 0 then
        author_line = ("%s by %s"):format(blame_info.hash or "<no hash>", blame_info.author or "<no author>")
    else
        author_line = "~~~ Not yet committed ~~~"
    end

    if blame_info.committer ~= nil and blame_info.committer ~= blame_info.author then
        author_line = author_line .. " committed by " .. blame_info.committer
    end
    --- @type string[]
    local display_text = {
        author_line,
        ('"' .. blame_info.summary .. '"') or "<no summary>",
        blame_info.new_text or "<no text>",
    }
    local green_line_count = #display_text
    if blame_info.previous_hash ~= nil then
        local previous_blame_cmd = {
            "git", "blame", "--porcelain", "--abbrev=6", "--root",
            "-L", string.format("%d,%d", blame_info.original_line_num, blame_info.original_line_num),
            blame_info.previous_hash,
            "--", blame_info.previous_filename,
        }
        local prev_blame_output = Run_command(previous_blame_cmd)
        local previous_blame_info = Extract_data_from_blame(prev_blame_output)
        table.insert(display_text,
            ("%s %s"):format(previous_blame_info.hash or "<no hash>",
                previous_blame_info.author or "<no author>"))
        table.insert(display_text, Strip('"' .. previous_blame_info.summary .. '"') or "<no summary>")
        table.insert(display_text, Strip(previous_blame_info.new_text) or "<no text>")
    else
        table.insert(display_text, "No previous commit")
    end

    ---@type BlameTextDisplayData
    local out = {
        lines = display_text,
        green_hl_line_start = 1,
        green_hl_line_end = green_line_count,
        red_hl_line_start = green_line_count + 1,
        red_hl_line_end = #display_text,
    }

    return out
end

function Open_blame_window()
    local _, bufline, _, _ = table.unpack(vim.fn.getpos("."))

    local blame_data = Get_blame_text(bufline)
    if blame_data == nil then return end
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
