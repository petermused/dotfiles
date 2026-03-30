---@module "lazy"
---@type LazySpec
return {
    {
        "pmizio/typescript-tools.nvim",
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        opts = {
            on_attach = function(_client, buf)
                vim.keymap.set(
                    "n",
                    "grs",
                    "<Cmd>TSToolsGoToSourceDefinition<CR>",
                    { buffer = buf, desc = "Go to source definition" }
                )

                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("peter.organize_typescript_imports", { clear = true }),
                    command = "TSToolsOrganizeImports",
                    desc = "Organize TypeScript imports",
                })
            end,
        },
        config = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
}
