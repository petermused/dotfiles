---@module "lazy"
---@type LazySpec
return {
    {
        "folke/lazydev.nvim",
        ft = { "lua" },
        opts = {
            library = {
                { path = "wezterm-types", mods = { "wezterm" } },
            },
        },
        config = true,
        dependencies = {
            "DrKJeff16/wezterm-types",
        },
    },
}
