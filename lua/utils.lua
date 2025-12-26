

-- function os.capture(cmd)
--     local f = assert(io.popen(cmd, 'r'))
--     local s = assert(f:read('*a'))
--     f:close()
--     -- if raw then return s end
--     s = string.gsub(s, '^%s+', '')
--     s = string.gsub(s, '%s+$', '')
--     s = string.gsub(s, '[\n\r]+', ' ')
--     return s
-- end



-- --- @return string
-- function Abspath(path)
--     local lfs = require("lfs")
--     return lfs.currentdir() .. "/" .. path
-- end


---Specialized root pattern that allows for an exclusion
---@param opt { root: string[], exclude: string[] }
---@return fun(file_name: string): string | nil
function Root_pattern_exclude(opt)
  local lsputil = require('lspconfig.util')

  return function(fname)
    local excluded_root = lsputil.root_pattern(opt.exclude)(fname)
    local included_root = lsputil.root_pattern(opt.root)(fname)

    if excluded_root then
      return nil
    else
      return included_root
    end
  end
end
