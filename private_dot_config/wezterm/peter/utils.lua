local wezterm = require("wezterm") --[[@as Wezterm]]

local M = {}

---Returns the platform wezterm is running on, such as `"linux"`, `"windows"`, or `"mac"`.
---Returns an empty string if the platform cannot be determined.
---@return ""|"linux"|"windows"|"mac"|
function M.platform()
    if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
        return "linux"
    elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
        return "windows"
    elseif wezterm.target_triple == "aarch64-apple-darwin" or wezterm.target_triple == "x86_64-apple-darwin" then
        return "mac"
    end

    return ""
end

M.string = {}

---Returns `true` if `s` starts with `prefix`.
---@param s string
---@param prefix string
---@return boolean
function M.string.starts_with(s, prefix)
    return string.sub(s, 1, string.len(prefix)) == prefix
end

return M
