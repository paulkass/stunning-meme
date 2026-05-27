-- Every mapping carries a `desc`. That description is what shows up in the
-- which-key popup (press <leader> and pause) and the `:Telescope keymaps`
-- fuzzy finder (<leader>sk). Keep descriptions short and verb-first.
local map = vim.keymap.set

-- Editing
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Folds
map("n", "<leader>z", "za", { desc = "Toggle fold under cursor" })
map("n", "<leader>Z", "zA", { desc = "Toggle all nested folds" })

-- Search
map({ "n", "v" }, "<leader>F", "/\\v", { desc = "Search (very magic)" })
map("n", "<leader>C", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Config
map("n", "<leader>nv", "<cmd>vsplit $MYVIMRC<cr>", { desc = "Edit config (init.lua)" })
