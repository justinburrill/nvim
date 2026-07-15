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
    -- --- @type CommitData
    -- local orig_commit = {
    --     author = extracted_data["author"],
    --     author_email = extracted_data["author-email"],
    --     author_date = Convert_epoch_time(extracted_data["author-time"]),
    --     committer = extracted_data["committer"],
    --     committer_email = extracted_data["committer-email"],
    --     committer_date = Convert_epoch_time(extracted_data["committer-time"]),
    --     subject = extracted_data["summary"],
    --     hash = hash,
    -- }
    local orig_commit = Get_commit_data(hash)

    -- Log("Created orig_commit:\n" .. Stringit(orig_commit) .. "\nFrom extracted_data:\n" .. Stringit(extracted_data))

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
    -- Log("Made BlameData:\n" .. Stringit(blame_data) .. "\nFrom lines:\n" .. Stringit(blame_output_lines))
    return blame_data
end

---@param line_start integer
---@param line_end integer
---@param filename string
---@param opts table | nil
---@return string[], string?
function Run_git_blame(line_start, line_end, filename, opts)
    local log = opts ~= nil and opts.log == true
    --  "--date=human" does nothing with --porcelain
    local cmd = {
        "git", "blame", "--porcelain", "--abbrev=6", "--root",
        "-L", string.format("%d,%d", line_start, line_end),
        "--", vim.fs.abspath(filename),
    }
    local blame_output_lines, blame_rc = Run_command(cmd, vim.fs.dirname(filename))
    if log then
        Log("Using command: " .. vim.fn.join(cmd, " ") .. "\nGot output:\n" .. Stringit(blame_output_lines))
    end
    local error_msg = Handle_git_error({ cmd = cmd, code = blame_rc, lines = blame_output_lines, raise_error = false })
    return blame_output_lines, error_msg
end

---@class BlameTextDisplayData
---@field lines string[]
---@field green_hl_line_start number
---@field green_hl_line_end number
---@field red_hl_line_start number
---@field red_hl_line_end number

---@param line_num integer Which line to find the blame for
---@return BlameTextDisplayData
function Format_blame_popup(line_num)
    --- @param commit_data CommitData
    local function format_author_line(commit_data)
        local header_line
        if tonumber(commit_data.hash) ~= 0 then
            local date = commit_data.author_date or "<unknown date>"
            local author = commit_data.author or "<no author>"
            local hash = commit_data.hash:sub(1, 6) or "<no hash>"
            if date == "<unknown date>" then
                error("From blame_obj:\n" .. Stringit(commit_data) .. "\nMade date: " .. date)
            end
            header_line = ("%s by %s on %s"):format(hash, author, date)
            -- If the committer is not the same as the author, add extra line
            if commit_data.committer ~= nil and commit_data.committer ~= commit_data.author then
                header_line = header_line .. "\nCommitted by " .. commit_data.committer .. " on " .. commit_data.committer_date
            end
        else
            header_line = "~~~ Not yet committed ~~~"
        end

        return header_line
    end
    local relpath = vim.api.nvim_buf_get_name(0)
    local blame_output_lines, err_msg = Run_git_blame(line_num, line_num, relpath)
    if err_msg ~= nil then
        error(err_msg)
    end
    local blame_info = Extract_data_from_blame(blame_output_lines, relpath)

    local latest_commit_author_lines = vim.split(format_author_line(blame_info.commit), "\n")
    --- @type string[]
    local display_text = {
        unpack(latest_commit_author_lines),
        ('"' .. blame_info.commit.subject .. '"') or "<no summary>",
        blame_info.new_text or "<no text>",
    }
    local number_of_Before_lines = #display_text
    local red_hl_line_end
    if blame_info.previous_hash ~= nil then
        red_hl_line_end = number_of_Before_lines + 2
        local previous_commit_info = Get_commit_data(blame_info.previous_hash)
        table.insert(display_text, format_author_line(previous_commit_info))
        if previous_commit_info.subject then
            table.insert(display_text, '"' .. previous_commit_info.subject .. '"')
        else
            table.insert(display_text, "<no summary>")
        end
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

    return out
end

function Handle_blame()
    local _, bufline, _, _ = table.unpack(vim.fn.getpos("."))

    local blame_text = Format_blame_popup(bufline)
    if blame_text == nil then error("blame_data is nil...") end
    if POPUP_WINDOW == nil then
        local buf_id = Open_popup_window(blame_text.lines)
        if buf_id == nil then
            error("Failed to create buffer")
        else
            Highlight_line(
                buf_id, blame_text.green_hl_line_start, blame_text.green_hl_line_end, "tempgreen", "DiffAdd")
            Highlight_line(
                buf_id, blame_text.red_hl_line_start, blame_text.red_hl_line_end, "tempred", "DiffDelete")
        end
    else
        Focus_popup_window()
    end
end

---@param filepath string
function Git_add(filepath)
    error("Not yet implemented")
    local cmd = { "git", "add", filepath }
    local lines, rc = Run_command(cmd, { cwd = vim.fs.dirname(filepath), echo = true })
    -- TODO:
    -- vim.api.nvim_echo
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
