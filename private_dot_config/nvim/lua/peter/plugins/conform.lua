local lib = require("peter.lib")

---@module "lazy"
---@type LazySpec
return {
    {
        "stevearc/conform.nvim",
        version = "*",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format()
                end,
                desc = "Format document",
                mode = { "n" },
            },
            {
                "<leader>cf",
                function()
                    require("conform").format()
                end,
                desc = "Format range",
                mode = { "v" },
            },
            {
                "<leader>tf",
                function()
                    vim.g.enable_format_on_save = not vim.g.enable_format_on_save

                    if vim.g.enable_format_on_save then
                        lib.info("Enabled format on save", { title = "Formatting" })
                    else
                        lib.info("Disabled format on save", { title = "Formatting" })
                    end
                end,
                desc = "Toggle format on save",
                mode = { "n" },
            },
        },
        ---@type conform.setupOpts
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                python = { "ruff_format", "ruff_organize_imports" },
                nix = { "nixfmt" },
            },
            format_on_save = function(_buf)
                if not vim.g.enable_format_on_save then
                    return
                end

                return {
                    timeout_ms = 500,
                }
            end,
        },
        init = function()
            vim.g.enable_format_on_save = true
        end,
    },
}
