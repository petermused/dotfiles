local wezterm = require("wezterm") ---@type Wezterm

local splits = require("peter.splits")
local tabbar = require("peter.tabbar")
local utils = require("peter.utils")

local config = wezterm.config_builder() ---@type Config

-- Appearance

local font = wezterm.font_with_fallback {
    {
        family = "CommitMono Nerd Font",
        -- See the "Features" section in the docs for Commit Mono
        harfbuzz_features = { "calt=1", "liga=1" },
    },
    { family = "CommitMono" },
    { family = "JetBrains Mono" },
    { family = "Noto Color Emoji" },
    { family = "Symbols Nerd Font Mono" },
}

config.font = font
config.font_size = 12
config.color_scheme = "Catppuccin Macchiato"

config.visual_bell = {
    fade_in_function = "Constant",
    fade_in_duration_ms = 0,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 300,
}
config.audible_bell = "Disabled"

-- Window

config.window_close_confirmation = "NeverPrompt"
config.initial_rows = 30
config.initial_cols = 120
config.scrollback_lines = 100000

config.window_frame = {
    font = font,
}

-- Focus window on startup
wezterm.on("gui-startup", function(cmd)
    local _tab, _pane, window = wezterm.mux.spawn_window(cmd or {})

    window:gui_window():focus()
end)

-- Tab Bar

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 48

wezterm.on("format-tab-title", tabbar.format_tab_title)
wezterm.on("update-status", tabbar.update_status)

-- Keybinds

config.leader = { key = "m", mods = "ALT", timeout_milliseconds = 1000 }
config.keys = {
    {
        key = "v",
        mods = "LEADER",
        action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
    },
    {
        key = "s",
        mods = "LEADER",
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
    },
    {
        key = "z",
        mods = "LEADER",
        action = wezterm.action.TogglePaneZoomState,
    },
    {
        key = "w",
        mods = "LEADER",
        action = wezterm.action.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" },
    },

    -- In case we ever want to type Alt-m
    {
        key = "m",
        mods = "LEADER|ALT",
        action = wezterm.action.SendKey { key = "m", mods = "ALT" },
    },

    {
        key = ",",
        mods = "CTRL",
        action = wezterm.action_callback(function(window, pane)
            -- We can't just use "~", since it doesn't work for PowerShell 😒
            local domain_home_dir = wezterm.home_dir

            -- If this isn't the local domain, use "~", as we cannot determine the domain's home directory ourselves
            if pane:get_domain_name() ~= "local" then
                domain_home_dir = "~"
            end

            window:perform_action(
                wezterm.action.SwitchToWorkspace {
                    name = "dotfiles",
                    spawn = {
                        cwd = domain_home_dir .. "/.local/share/chezmoi",
                    },
                },
                pane
            )
        end),
    },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = wezterm.action.ActivateTab(i - 1),
    })
end

for _, key in ipairs(splits.keys) do
    table.insert(config.keys, key)
end

-- Windows specific settings

if utils.platform() == "windows" then
    -- Set the default shell for the local domain to be PowerShell
    local pwsh_exists = pcall(function()
        wezterm.run_child_process { "pwsh.exe", "--version" }
    end)

    -- Use Windows' SSH Agent for `wezterm ssh`
    -- See https://github.com/wezterm/wezterm/discussions/3772
    config.ssh_backend = "Ssh2"
    -- Don't modify SSH_AUTH_SOCK for the SSH agent on the local domain (i.e. PowerShell)
    config.mux_enable_ssh_agent = false

    if pwsh_exists then
        config.default_prog = { "pwsh.exe" }
    else
        config.default_prog = { "powershell.exe" }
    end

    -- Remove Docker Desktop's WSL from the list of WSL domains
    local default_wsl_domains = wezterm.default_wsl_domains()
    local wsl_domains = {}

    for _, wsl_domain in ipairs(default_wsl_domains) do
        if string.find(wsl_domain.distribution, "docker%-desktop") == nil then
            table.insert(wsl_domains, wsl_domain)
        end
    end

    config.wsl_domains = wsl_domains

    -- Make the WSL domain the default, if available
    if #wsl_domains > 0 then
        config.default_domain = wsl_domains[1].name
    end
end

return config
