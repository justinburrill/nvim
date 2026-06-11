--- @param t any[]
--- @return string
local function table_to_str(t)
    local out = ""
    local sep = ", "
    for k, v in pairs(t) do
        local display = ("[%s]=%s"):format(Stringit(k), Stringit(v))
        if #out > 0 then
            out = out .. sep .. display
        else
            out = display
        end
    end
    return "{" .. out .. "}"
end

--- @param e any
--- @return string
function Stringit(e)
    --- @type string
    local display
    if type(e) == "string" then
        display = '"' .. e .. '"'
    elseif type(e) == "table" then
        display = table_to_str(e)
    else
        display = tostring(e)
    end
    return display
end

--- @param cmd string[]
--- @param cwd string | nil
--- @param timeout number | nil
--- @return string[] lines
--- @return number code
function Run_command(cmd, cwd, timeout)
    if timeout == nil then
        timeout = 10000
    end
    if cwd ~= nil and not (vim.fn.isdirectory(cwd) == 1) then
        error("Can't run command in cwd '" .. cwd .. "' as it doesn't exist.")
    end
    local proc = vim.system(cmd, { text = true, cwd = cwd }):wait(timeout)
    if proc.code == 124 then
        error("Timeout waiting for command (" .. tostring(timeout) .. "ms): " .. table.concat(cmd, " "))
    else
        return Split_fast(Strip(proc.stdout) .. Strip(proc.stderr), "\n"), proc.code
    end
end

--- @param str string
function Log(str)
    vim.api.nvim_echo({ { str } }, true, {})
end

--- @param lines string[] Lines to search
--- @param prefix string Prefix to search for
--- @return string | nil
function Get_line_starting_with(lines, prefix)
    for _, line in ipairs(lines) do
        if vim.startswith(line, prefix) then
            return line
        end
    end
    return nil
end

--- @param lines string[] Lines to search inside
--- @param q string Text to look for (regex)
--- @return string | nil
function Get_line_containing(lines, q)
    for _, line in ipairs(lines) do
        if line:match(".*" .. q .. ".*") then
            return line
        end
    end
    return nil
end

--- @param s string
--- @param prefix string
--- @param force boolean | nil
--- @return string
function Remove_prefix(s, prefix, force)
    if force == nil then
        force = false
    end
    if vim.startswith(s, prefix) then
        return s:sub(#prefix + 1)
    else
        if force == true then
            error("Tried to remove prefix '" .. prefix .. "' from string '" .. s .. "' when force=true")
        end
        return s
    end
end

--- @param s string
--- @param suffix string
--- @param force boolean | nil
--- @return string
function Remove_suffix(s, suffix, force)
    if force == nil then
        force = false
    end
    if vim.endswith(s, suffix) then
        return s:sub(1, #s - #suffix)
    else
        if force == true then
            error("Tried to remove suffix '" .. suffix .. "' from string '" .. s .. "' when force=true")
        end
        return s
    end
end

--- @param s string
--- @return string
function Strip(s)
    if (s == nil) then return nil end ---@diagnostic disable-line: return-type-mismatch
    local r = s:gsub("^%s+", ""):gsub("%s+$", "")
    return r
end

--- @param input string
--- @param seperator string | nil Any whitespace by default
--- @return string[]
function Split_fast(input, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local out = {}

    for match in string.gmatch(input, "([^" .. seperator .. "]+)") do
        table.insert(out, match)
    end
    return out
end

--- @param input string
--- @param seperator string | nil
--- @param max_count number | nil
--- @return string[]
function Split_count(input, seperator, max_count)
    if seperator == nil then
        seperator = "%s"
    end
    local current_word = ""
    local count = 0
    local out = {}
    for i = 1, #input do
        local char = input:sub(i, i)
        if not char:match("%s") then
            current_word = current_word .. char
        else
            count = count + 1
            table.insert(out, current_word)
            current_word = ""
            if max_count ~= nil and count >= max_count then
                table.insert(out, input:sub(i + 1))
                break
            end
        end
    end
    if #current_word > 0 then
        table.insert(out, current_word)
    end
    return out
end

--- @param strings string[] Strings
--- @param minimum number | nil Minimum line length
--- @return integer
function Max_line_length(strings, minimum)
    if minimum == nil then
        minimum = 10
    end
    local max = minimum
    for _, s in ipairs(strings) do
        if #s > max then max = #s end
    end
    return max
end

--- @param buffer_id number
--- @param line_num number
--- @param namespace_name string
--- @param highlight_group string
--- @param end_line_num number
function Highlight_line(buffer_id, line_num, end_line_num, namespace_name, highlight_group)
    local namespace_id = vim.api.nvim_create_namespace(namespace_name)
    -- Log("Highlighting: " ..
    --     Stringit(buffer_id) ..
    --     " " .. Stringit(line_num) .. " " .. Stringit(end_line_num) .. " " .. namespace_name .. " " .. highlight_group)
    vim.api.nvim_buf_set_extmark(
        buffer_id, namespace_id, line_num - 1, 0, { hl_group = highlight_group, end_row = end_line_num })
end

--- @param filename string The file in the git repo
--- @return string
function Get_git_root_path(filename)
    local abspath = vim.fs.abspath(vim.fs.normalize(filename))
    local dirname = vim.fs.dirname(abspath)
    local cmd = { "git", "rev-parse", "--show-toplevel" }
    local output, rc = Run_command(cmd, dirname)
    Handle_git_error({ cmd = cmd, lines = output, msg = "Failed to get git root path", code = rc })
    local path = table.remove(output, 1)
    return path
end

--- @class HandleGitErrorOpts
--- @field msg string?
--- @field lines string[]
--- @field code integer
--- @field cmd string[]
--- @field raise_error boolean?

--- @param opts HandleGitErrorOpts
--- @return string | nil message
function Handle_git_error(opts)
    local raw_msg = Get_line_containing(opts.lines, "error: ") or Get_line_containing(opts.lines, "fatal: ")
    if raw_msg == nil and opts.code == 0 then
        return
    end
    --- @type string
    local err_msg
    if opts.msg == nil then
        err_msg = "Got error message from git (code " .. tostring(opts.code) .. "):\n" .. raw_msg
    else
        err_msg = opts.msg .. ":" .. "\n" .. raw_msg
    end

    if opts.cmd ~= nil then
        err_msg = err_msg .. "\nCommand used: " .. table.concat(opts.cmd, " ")
    end

    if (opts.code ~= 0) and (opts.raise_error == true) then
        error(err_msg)
    else
        return err_msg
    end
end

--- @param hash string
--- @return CommitData
function Get_commit_data(hash)
    local fields = {
        "author %an",
        "author_mail %ae",
        "author_date %ah",
        "committer %cn",
        "committer_mail %ce",
        "committer_date %ch",
        "subject %s",
    }
    local formatstr = table.concat(fields, "%n")
    local cmd = { "git", "show", "--abbrev=6", "--pretty=format:" .. formatstr, hash }
    local lines, code = Run_command(cmd)
    local _ = Handle_git_error({ cmd = cmd, lines = lines, code = code, raise_error = true })
    local extracted_data = Extract_data_from_git_output(lines)
    --- @type CommitData
    local out = {
        author = extracted_data["author"],
        author_email = extracted_data["author-email"],
        author_date = extracted_data["author-date"],
        committer = extracted_data["author"],
        committer_email = extracted_data["author-email"],
        committer_date = extracted_data["author-date"],
        subject = extracted_data["subject"],
        hash = hash,
    }

    Log("Got commit data (code " .. tostring(code) .. ") for hash " .. hash .. "\n" .. Stringit(out))
    return out
end

--- @param lines string[]
--- @return table
function Extract_data_from_git_output(lines)
    local extracted_data = {}
    for _, line in ipairs(lines) do
        local parts = Split_count(line, nil, 1)
        local key_name = parts[1]
        extracted_data[key_name] = parts[#parts] or ("<no " .. key_name .. ">")
    end

    Log("Extracted: \n" .. Stringit(extracted_data) .. "\nFrom lines: \n" .. Stringit(lines))
    return extracted_data
end

--- @param filepath string
--- @param line_num integer
--- @param commit_hash string
--- @return string
function Get_line_at_commit(filepath, line_num, commit_hash)
    local location = commit_hash .. ":" .. filepath
    Log("Getting line " .. tostring(line_num) .. " at " .. location)
    local cmd = { "git", "show", location, "|", "sed", "-n", tostring(line_num) .. "p" }
    local lines, code = Run_command(cmd)
    local _ = Handle_git_error({
        cmd = cmd,
        lines = lines,
        code = code,
        raise_error = true,
        msg =
        "Couldn't get line at commit"
    })
    return lines[1]
end
