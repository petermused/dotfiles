---@module "lazy"
---@type LazySpec
return {
    {
        "linux-cultist/venv-selector.nvim",
        ft = "python",
        cmd = { "VenvSelect" },
        opts = {
            options = {
                notify_user_on_venv_activation = true,
            },
        },
        -- TODO
        -- dependencies = {
        --     "mfussenegger/nvim-dap",
        --     "mfussenegger/nvim-dap-python",
        -- },
    },
}
