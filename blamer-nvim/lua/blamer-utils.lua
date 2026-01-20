--- @param s string
function Log(s)
    vim.api.nvim_echo({ { s } }, true, {})
end

--- @param s string
--- @return string
function Strip(s)
    local r = s:gsub("^%s+", ""):gsub("%s+$", "")
    return r
end

--- @param input string
--- @param seperator string | nil
--- @return string[]
function Split(input, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local out = {}
    for match in string.gmatch(input, "([^"..seperator.."]+)") do
        table.insert(out, match)
    end
    return out
end

--- @param strings string[] Strings
--- @return integer
function Max_line_length(strings)
    local max = 10
    for _i, s in ipairs(strings) do
        if #s > max then max = #s end
    end
    return max
end
