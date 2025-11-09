-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit insert mode faster
vim.keymap.set("i", "jk", "<Esc>")

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Better indenting (stay in visual mode)
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Better paste (don't lose clipboard)
vim.keymap.set("x", "<leader>p", '"_dP')

-- Quick save
vim.keymap.set("n", "<C-s>", "<cmd>w<cr>")

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG")

-- Better line beginning/end
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")
