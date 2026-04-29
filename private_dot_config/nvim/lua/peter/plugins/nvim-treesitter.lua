local lib = require("peter.lib")

---@module "lazy"
---@type LazySpec
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main", -- FIXME: Remove once main is the default
        lazy = false, -- This plugin does not support lazy loading
        build = ":TSUpdate",
        config = function()
            local nvim_treesitter = require("nvim-treesitter")

            local ensure_installed = {
                -- These are built-in to Neovim but we install the nvim-treesitter ones so that the indentexpr works for these filetypes
                "lua",
                "vimdoc",
                "markdown",

                "bash",
                "css",
                "diff",
                "dockerfile",
                "fish",
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "html",
                "javascript",
                "jjdescription",
                "jsdoc",
                "json",
                "just",
                "nix",
                "powershell",
                "regex",
                "rust",
                "sql",
                "toml",
                "tsx",
                "typescript",
                "xml",
                "yaml",
            }

            local already_installed = nvim_treesitter.get_installed()
            local parsers_to_install = vim.iter(ensure_installed)
                :filter(function(parser)
                    return not vim.tbl_contains(already_installed, parser)
                end)
                :totable()

            if #parsers_to_install > 0 then
                nvim_treesitter.install(parsers_to_install)
            end

            -- Attempt to start treesitter for every file type
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("peter.start_treesitter", { clear = true }),
                callback = function()
                    -- Will be false for filetypes with no treesitter parser installed
                    local has_started = pcall(vim.treesitter.start)
                    if has_started then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
                desc = "Attempt to call vim.treesitter.start() and set indentexpr",
            })
        end,
        cond = lib.is_executable("tree-sitter"),
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        version = "*",
        module = false,
        event = "BufReadPre",
        config = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        config = true,
    },
}
