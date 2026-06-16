local M = {}

-- deprecation fix
table.unpack = table.unpack or unpack

require "git-helper-nvim.lua.popups"
require "git-helper-nvim.lua.git-helper-utils"
require "git-helper-nvim.lua.string-utils"

--- @class BlameData
--- @field commit CommitData
--- @field filepath string
--- @field new_text string?
--- @field original_line_num number?
--- @field final_line_num number?
--- @field previous_hash string?
--- @field previous_filepath string?

--- @class CommitData
--- @field author string
--- @field author_email string
--- @field author_date string
--- @field committer string
--- @field committer_email string
--- @field committer_date string
--- @field hash string
--- @field subject string


--- @param blame_output_lines string[]
--- @param path_to_orig_file string
--- @return BlameData
function Extract_data_from_blame(blame_output_lines, path_to_orig_file)
    local text_line = Get_line_starting_with(blame_output_lines, "\t")
    --- @type string?
    local new_text = nil
    if text_line ~= nil then
        -- the line starting with a tab is the text
        new_text = Remove_prefix(text_line, "\t", false)
    end
    local hash, orig_line_num_str, final_line_num_str = table.unpack(Split_fast(blame_output_lines[1]))
    local extracted_data = Extract_data_from_git_output(blame_output_lines)
    local previous_hash = nil
    local previous_filepath = nil
    local orig_commit = {
        author = extracted_data["author"],
        author_email = extracted_data["author-email"],
        author_date = extracted_data["author-date"],
        committer = extracted_data["author"],
        committer_email = extracted_data["author-email"],
        committer_date = extracted_data["author-date"],
        subject = extracted_data["summary"],
        hash = hash,
    }

    if extracted_data.previous ~= nil then
        local prev_hash_raw, prev_filepath_raw = table.unpack(Split_fast(extracted_data.previous))
        previous_hash = prev_hash_raw
        previous_filepath = prev_filepath_raw
    end

    --- @type BlameData
    local blame_data = {
        filepath = path_to_orig_file,
        original_line_num = tonumber(orig_line_num_str),
        final_line_num = tonumber(final_line_num_str),
        commit = orig_commit,
        new_text = new_text,
        previous_filepath = previous_filepath,
        previous_hash = previous_hash,
    }
    Log("Extract_data_from_blame: from lines: " .. Stringit(blame_output_lines) .. "\nmade this data: " .. Stringit(blame_data))
    return blame_data
end

---@param line_start integer
---@param line_end integer
---@param filename string
---@return string[], string?
function Run_git_blame(line_start, line_end, filename)
    local cmd = {
        "git", "blame", "--porcelain", "--abbrev=6", "--root",
        "-L", string.format("%d,%d", line_start, line_end),
        "--", vim.fs.abspath(filename),
    }
    local blame_output_lines, blame_rc = Run_command(cmd, vim.fs.dirname(filename))
    local error_msg = Handle_git_error({ cmd = cmd, code = blame_rc, lines = blame_output_lines, raise_error = false })
    return blame_output_lines, error_msg
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
    local relpath = vim.api.nvim_buf_get_name(0)
    local blame_output_lines, err_msg = Run_git_blame(line_num, line_num, relpath)
    if err_msg ~= nil then
        error(err_msg)
    end
    local blame_info = Extract_data_from_blame(blame_output_lines, relpath)

    local latest_commit_author_line = format_author_line(blame_info)
    --- @type string[]
    local display_text = {
        latest_commit_author_line,
        ('"' .. blame_info.commit.subject .. '"') or "<no summary>",
        blame_info.new_text or "<no text>",
    }
    local number_of_Before_lines = #display_text
    local red_hl_line_end = number_of_Before_lines + 2
    if blame_info.previous_hash ~= nil then
        local previous_commit_info = Get_commit_data(blame_info.previous_hash)
        table.insert(display_text, format_author_line(previous_commit_info))
        table.insert(display_text, Get_line_at_commit(blame_info.previous_filepath, line_num, blame_info.previous_hash))
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
    Log("Format_blame_popup at line " .. tostring(line_num) .. ":\n" .. Stringit(out))

    return out
end

function Handle_blame()
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

---@param filepath string
function Git_add(filepath)
    local cmd = { "git", "add", filepath }
    local lines, rc = Run_command(cmd, vim.fs.dirname(filepath))
    Handle_git_error({ cmd = cmd, lines = lines, code = rc, msg = "Failed to run git add", raise_error = true })
end

function Handle_add()
    local filepath = vim.api.nvim_buf_get_name(0)
    Git_add(filepath)
end

--- @class (exact) GitHelperKeymaps
--- @field blame string
--- @field add string


--- @class (exact) GitHelperOps
--- @field keymaps GitHelperKeymaps

---@param opts GitHelperOps | nil
function M.setup(opts)
    opts = opts or {}
    ---@type GitHelperKeymaps
    local default_keymaps = { blame = "<leader>gb", add = "<leader>ga" }
    local keymaps = opts.keymaps or default_keymaps
    vim.api.nvim_create_user_command("GitBlame", Handle_blame, {})
    vim.keymap.set("n", keymaps["blame"], Handle_blame, {
        desc = "Git blame",
        silent = true
    })
    vim.api.nvim_create_user_command("GitAdd", Handle_add, {})
    vim.keymap.set("n", keymaps["add"], Handle_add, {
        desc = "Git add",
        silent = true
    })
    pcall(function() return require "which-key" end)
end

return M
