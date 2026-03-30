---@module "lazy"
---@type LazySpec
return {
    {
        "folke/lazydev.nvim",
        ft = { "lua" },
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "wezterm-types", mods = { "wezterm" } },
            },
        },
        config = true,
        dependencies = {
            "Bilal2453/luvit-meta",
            "DrKJeff16/wezterm-types",
        },
    },
}
