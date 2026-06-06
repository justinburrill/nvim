--- @param p1 string
--- @param p2 string
function Join_paths(p1, p2)
    if #p1 > 0 then
        return vim.fn.resolve(p1 .. "/" .. p2)
    else
        return p2
    end
end

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
--- @return string[], number
function Run_command(cmd, cwd, timeout)
    if timeout == nil then
        timeout = 10000
    end
    local proc = vim.system(cmd, { text = true, cwd = cwd }):wait(timeout)
    if proc.code == 124 then
        error("Timeout waiting for command (" .. tostring(timeout) .. "ms): " .. table.concat(cmd, " "))
    else
        return Split_fast(Strip(proc.stdout) .. Strip(proc.stderr), "\n"), proc.code
    end
end

--- @param s string
function Log(s)
    vim.api.nvim_echo({ { s } }, true, {})
end

--- @param s string
--- @param prefix string
--- @return boolean
function Has_prefix(s, prefix)
    return s:sub(1, #prefix) == prefix
end


--- @param s string
--- @param suffix string
--- @return boolean
function Has_suffix(s, suffix)
    return s:sub(#s - #suffix, #s) == suffix
end

--- @param lines string[] Lines to search
--- @param prefix string Prefix to search for
--- @return string | nil
function Get_line_starting_with(lines, prefix)
    for _, line in ipairs(lines) do
        if Has_prefix(line, prefix) then
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
    if Has_prefix(s, prefix) then
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
    if Has_suffix(s, suffix) then
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
    local cmd = { "git", "rev-parse", "--show-toplevel" }
    local output, rc = Run_command(cmd, Get_dirname(filename))
    if rc ~= 0 then
        error("Failed to get git root path with cmd: " .. Stringit(cmd) .. "\nGot output: " .. output)
    end
    local path = Remove_prefix(Remove_suffix(table.remove(cmd, 1), "git"), "/")
    -- Log("Returned git root path: ".. path)
    return path
end

--- @param filepath string
--- @return string
function Get_dirname(filepath)
    local ret = Get_abspath(filepath):match("(.*[/\\])")
    -- Log("Dirname of ".. filepath .. " is " .. ret)
    return ret
end

-- TODO: fixme
--- @param filepath string
--- @return string
function Get_abspath(filepath)
    if Has_prefix(filepath, "/") then
        return filepath
    else
        return vim.fn.resolve(Join_paths(vim.fn.getcwd(), filepath))
    end
end
