local wezterm = require("wezterm") --[[@as Wezterm]]

local utils = require("peter.utils")

local M = {}

---@param effective_config Config
---@return table<string, string>
local function tab_bar_color_scheme(effective_config)
    local color_scheme = effective_config.resolved_palette
    local tab_bar = color_scheme.tab_bar

    return {
        bg_a = tab_bar.active_tab.bg_color,
        fg_a = tab_bar.active_tab.fg_color,
        bg_b = tab_bar.new_tab.bg_color,
        fg_b = tab_bar.new_tab.fg_color,
        bg_c = tab_bar.background,
        fg_c = color_scheme.foreground,
    }
end

---@param tab TabInformation
---@return string
local function tab_title(tab)
    local title = tab.tab_title

    -- If the tab title is explicitly set, return that
    if title and string.len(title) > 0 then
        return title
    end

    -- Otherwise, use the title from the active pane in that tab
    return tab.active_pane.title
end

---@param tab TabInformation
---@return string
local function tab_domain_icon(tab)
    -- TODO: Show bell icon in tab title using "bell" event

    local title = tab_title(tab)
    if title == "wezterm" then
        return ""
    elseif title == "Debug" then
        return "󰃤 "
    elseif title == "Launcher" then
        return "󰌧 "
    elseif title == "Tab Navigator" then
        return "󱦞 "
    elseif utils.string.starts_with(title, "Copy mode") then
        return "󰆏 "
    end

    local active_pane_id = tab.active_pane.pane_id
    local active_pane = wezterm.mux.get_pane(active_pane_id)
    local domain_name = active_pane:get_domain_name()

    if utils.string.starts_with(domain_name, "SSH") then
        return "󰣀 "
    end

    -- Show WSL/PowerShell tabs on windows
    if utils.platform() == "windows" then
        if domain_name == "local" then
            return "󰨊 "
        elseif utils.string.starts_with(domain_name, "WSL") then
            if string.find(domain_name, "[Uu]buntu") ~= nil then
                return " "
            elseif string.find(domain_name, "[Nn]ix[Oo][Ss]") ~= nil then
                return " "
            else
                return "󰌽 "
            end
        end
    end

    return " " -- Default domain icon if we can't determine the domain type
end

---@param tab TabInformation
---@param tabs TabInformation[]
---@param panes PaneInformation[]
---@param effective_config Config
---@param hover boolean
---@param max_width number
---@return string|FormatItem
function M.format_tab_title(tab, tabs, panes, effective_config, hover, max_width)
    local _tabs = tabs
    local _panes = panes

    local title = tab_title(tab)

    local num_active_domains = 0
    for _, domain in ipairs(wezterm.mux.all_domains()) do
        if domain:has_any_panes() then
            num_active_domains = num_active_domains + 1
        end
    end

    -- If there is more than one domain active, display domain icons
    -- On Windows, always display domain icons to differentiate between PowerShell and WSL
    local domain_icon = ""
    if num_active_domains > 1 or utils.platform() == "windows" then
        domain_icon = tab_domain_icon(tab)
    end

    local is_zoomed = false
    for _, pane in ipairs(tab.panes) do
        if pane.is_zoomed then
            is_zoomed = true
        end
    end

    local zoom_icon = is_zoomed and " 󰊓" or ""

    local separator_width = 2
    local domain_icon_width = wezterm.column_width(domain_icon)
    local zoom_icon_width = wezterm.column_width(zoom_icon)

    title = wezterm.truncate_right(title, max_width - (separator_width + domain_icon_width + zoom_icon_width))

    local tab_bar_colors = tab_bar_color_scheme(effective_config)

    local bg = tab_bar_colors.bg_c
    local fg = tab_bar_colors.fg_c
    if tab.is_active then
        bg = tab_bar_colors.bg_a
        fg = tab_bar_colors.fg_a
    elseif hover then
        bg = tab_bar_colors.bg_b
        fg = tab_bar_colors.fg_b
    end

    return {
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = " " .. domain_icon .. title .. zoom_icon .. " " },
    }
end

---@type CallbackWindowPane
function M.update_status(window, pane)
    local _pane = pane

    local tab_bar_colors = tab_bar_color_scheme(window:effective_config())

    local workspace_or_leader = wezterm.mux.get_active_workspace()
    if window:leader_is_active() then
        workspace_or_leader = "LEADER"
    end

    window:set_right_status(wezterm.format {
        { Background = { Color = tab_bar_colors.bg_a } },
        { Foreground = { Color = tab_bar_colors.fg_a } },
        { Text = " " .. workspace_or_leader .. " " },
    })
end

return M
