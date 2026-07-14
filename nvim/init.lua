-- docs:  https://lazy.folke.io/installation
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to configre `mapleader` and `maplocalleader` before
-- loadwng lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- options
local opt = vim.opt -- for conciseness
-- clipboard
opt.clipboard:append("unnamedplus")
-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
-- NEW: Ensure this is in your Neovim config (LazyVim usually has this by default)
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "terminal", "folds" }

local keymap = vim.keymap -- for conciseness
---------------------
-- General Keymaps -------------------
-- Disable cursor movement with the space key
keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
-- normally ctrl and and esc behave the same, but in some special scenarios in visual block mode they behave different.
keymap.set("i", "<C-c>", "<Esc>")

-- better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move in visual mode selected line up" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move in visual mode selected line down" })

-- prevent overwriting the clipboard when deleting single character
keymap.set("n", "x", [["_x]])
-- delete without overwriting the clipboard
keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete and keep clipboard" })

-- copy content to the system clipboard (currently makes issues on mac when copying somtehing in the system clipboard, it overwrites also the vim specific clipboard, when p
--keymap.set({"n", "v"}, "<leader>y", [["+y]])
--keymap.set("n", "<leader>Y", [["+Y]])

-- prevent overwriting the clipboard when pasting marked stuff in visual mode
-- currently there is a better version in place. so the following keymap is commented out
--keymap.set("x", "<leader>p", [["_dP]])

-- prevent overwriting the clipboard when changing the rest of the line
keymap.set("n", "C", [["_d$a]], { desc = "change rest of the line and keep clipboard" })
keymap.set("v", "c", [["_di]], { desc = "change and keep clipboard" })
keymap.set("n", "c", [["_c]], { desc = "change and keep clipboard" })
keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting register" })

keymap.set({ "n", "v" }, "s", [["_s]], { desc = "change single char and keep clipboard" })

-- keymap.set({"n", "v"}, "<leader>y", [["+y]])
-- Y and y is the same but when hoding shift in a rush it will lead to the same and copy also to the system clipboard
--keymap.set("n", "<leader>Y", [["+Y]])

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement
keymap.set("n", "<leader>nx", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>wx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<M-l>", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<M-h>", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

keymap.set("n", "<C-s>", ":w<CR>", { desc = "save current file" })

local function clear_all_registers()
	local regs = vim.split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', "")
	for _, r in ipairs(regs) do
		vim.fn.setreg(r, {})
	end
end
keymap.set("n", "<leader>rx", clear_all_registers, { desc = "Clear all registers" })

-- keybindings not used in vscode in order to prevent conflicting issues
if not vim.g.vscode then
	-- scrolling up/down and center
	keymap.set("n", "<C-d>", "<C-d>zz")
	keymap.set("n", "<C-u>", "<C-u>zz")
	-- redo
	keymap.set("n", "U", "<C-r>")
	-- search and replace current current curosor word
	keymap.set(
		"n",
		"<leader>ss",
		[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
		{ desc = "Replace current word on the cursor with..." }
	)
end

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"echasnovski/mini.nvim",
			version = false,
			config = function()
				-- Existing operators configuration
				require("mini.operators").setup()

				-- New surround configuration
				require("mini.surround").setup({
					mappings = {
						add = "sa", -- Add surrounding
						delete = "sd", -- Delete surrounding
						replace = "cs", -- Replace surrounding (vim-surround style)
						find = "sf", -- Find surrounding (left)
						find_left = "sF", -- Find surrounding (right)
						highlight = "sh", -- Highlight surrounding
					},

					-- Custom surroundings (optional)
					-- custom_surroundings = nil,
					-- Duration of highlight (ms)
					highlight_duration = 300,
				})
			end,
		},
	},
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically cherk for plugin updates
	checker = { enabled = true },
})

-- Replace existing visual mode mapping
vim.keymap.set(
	"x",
	"S",
	[[:<C-u>lua MiniSurround.add('visual')<CR>]],
	{ silent = true, desc = "Surround visual selection" }
)
