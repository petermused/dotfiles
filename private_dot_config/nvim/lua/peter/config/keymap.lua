local lib = require("peter.lib")

-- Space is the leader key, so remove the default behaviour
vim.keymap.set("n", "<Space>", "<Nop>")

-- Make j and k take line wrapping into account
-- If we supply a count beforehand, use default behaviour
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Bri'ish version of # key
vim.keymap.set("n", "£", "#")

-- Make <Esc> clear search highlights
vim.keymap.set("n", "<Esc>", "<Cmd>nohl<CR>")

vim.keymap.set({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

-- Backspace in select mode changes instead of deletes
vim.keymap.set("s", "<BS>", "<C-g>c")

-- Repeatable indenting
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("x", "<", "<gv")

-- Recenter screen after certain movements
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Create undo points in insert mode
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", "!", "!<C-g>u")
vim.keymap.set("i", "?", "?<C-g>u")

-- TODO: Keybind to see all the definitions? e.g. 1gd?
-- Go to definition should always jump to the first definition
vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition {
        on_list = function(options)
            ---@type vim.quickfix.entry
            local first_item = options.items[1]
            -- The `user_data` is an lsp.LocationLink, since `on_list` calls vim.lsp.util.locations_to_items() beforehand for us
            vim.lsp.util.show_document(first_item.user_data, "utf-8", { focus = true })
        end,
    }
end, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

vim.keymap.set("n", "<leader>ul", "<Cmd>Lazy<CR>", { desc = "Open Lazy" })

vim.keymap.set("n", "<leader>hi", "<Cmd>Inspect<CR>", { desc = "Inspect at cursor" })
vim.keymap.set("n", "<leader>ht", "<Cmd>InspectTree<CR>", { desc = "Treesitter syntax tree" })

-- Toggle soft (i.e. UI only) word wrapping
-- stylua: ignore start
vim.keymap.set("n", "<leader>tw", function() lib.toggle_option("wrap") end, { desc = "Toggle word wrap" })
-- stylua: ignore end

-- Toggle diagnostics
vim.keymap.set("n", "<leader>td", function()
    local diagnostics_enabled = vim.diagnostic.is_enabled()
    diagnostics_enabled = not diagnostics_enabled

    vim.diagnostic.enable(diagnostics_enabled)

    if diagnostics_enabled then
        lib.info("Enabled diagnostics", { title = "Diagnostics" })
    else
        lib.info("Disabled diagnostics", { title = "Diagnostics" })
    end
end, { desc = "Toggle diagnostics" })

-- Toggle LSP inlay hints
vim.keymap.set("n", "<leader>th", function()
    local inlay_hints_enabled = vim.lsp.inlay_hint.is_enabled()
    inlay_hints_enabled = not inlay_hints_enabled

    vim.lsp.inlay_hint.enable(inlay_hints_enabled)

    if inlay_hints_enabled then
        lib.info("Enabled inlay hints", { title = "Inlay hints" })
    else
        lib.info("Disabled inlay hints", { title = "Inlay hints" })
    end
end, { desc = "Toggle inlay hints" })

-- TODO: Toggle treesitter using vim.treesitter.stop(), in case it goes haywire

-- TODO: dd in quickfix list (quickfix reflector)
