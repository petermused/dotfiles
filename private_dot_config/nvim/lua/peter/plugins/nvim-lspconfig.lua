---@module "lazy"
---@type LazySpec
return {
    {
        "neovim/nvim-lspconfig",
        version = "*",
        event = "BufReadPre",
    },
}
