
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
    local cmd = { "git", "show", "-s", "--abbrev=6", "--pretty=format:" .. formatstr, hash }
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

    Log("Get_commit_data: (code " .. tostring(code) .. ") for hash " .. hash .. "\n" .. Stringit(out))
    return out
end

--- @param lines string[]
--- @return table
function Extract_data_from_git_output(lines)
    local extracted_data = {}
    for _, line in ipairs(lines) do
        if vim.startswith(line, "\t") then
            extracted_data["indented"] = Remove_prefix(line, "\t")
        else
            local parts = Split_count(line, nil, 1)
            local key_name = parts[1]
            extracted_data[key_name] = parts[#parts] or ("<no " .. key_name .. ">")
        end
    end

    Log("Extract_data_from_git_output: Extracted: \n" ..
        Stringit(extracted_data) .. "\nFrom lines: \n" .. Stringit(lines))
    return extracted_data
end

--- @param filepath string Should be relative to the git root, not the absolute path
--- @param line_num integer
--- @param commit_hash string
--- @return string
function Get_line_at_commit(filepath, line_num, commit_hash)
    local location = commit_hash .. ":" .. filepath
    Log("Get_line_at_commit: line " .. tostring(line_num) .. " at " .. location)
    local cmd = table.concat({ "git", "show", location, "|", "sed", "-n", tostring(line_num) .. "p" }, " ")
    local proc = io.popen(cmd, "r")
    if proc == nil then
        error("Failed to run cmd (proc is nil): " .. cmd)
    end
    local line = proc:read("*l")
    local success = proc:close()
    if success ~= true then
        error("Failed to get line at commit: command returned non-zero: " .. line)
    end
    return line
    -- local _ = Handle_git_error({
    --     cmd = cmd,
    --     lines = lines,
    --     code = code,
    --     raise_error = true,
    --     msg = "Couldn't get line at commit"
    -- })
    -- return lines[1]
end

