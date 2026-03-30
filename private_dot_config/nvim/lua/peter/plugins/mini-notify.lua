---@module "lazy"
---@type LazySpec
return {
    {
        "nvim-mini/mini.notify",
        version = "*",
        lazy = false,
        -- stylua: ignore
        keys = {
            { "<leader>un", function() require("mini.notify").clear() end, desc = "Dismiss all notifications", },
            { "<leader>hn", function() require("mini.notify").show_history() end, desc = "Notifications", },
        },
        opts = {
            content = {
                sort = function(notifs)
                    -- Filter out some of the LSP progress notifications from lua_ls
                    local function predicate(notif)
                        if notif.data.source == "lsp_progress" and notif.data.client_name == "lua_ls" then
                            return string.find(notif.msg, "Diagnosing") == nil
                        end

                        return true
                    end

                    local filtered_notifs = vim.iter(notifs):filter(predicate):totable()
                    return require("mini.notify").default_sort(filtered_notifs)
                end,
            },
            window = {
                config = {
                    border = "rounded",
                },
                winblend = 0,
            },
        },
        config = true,
    },
}
