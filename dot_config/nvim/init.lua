-- Set <space> as the leader key
-- See `:h mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

-- OPTIONS
--
-- See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:h option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

vim.o.number = true -- Show line numbers in a column.

-- Show line numbers relative to where the cursor is.
-- Affects the 'number' option above, see `:h number_relativenumber`.
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UIEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:h 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.o.clipboard = 'unnamedplus'
	end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true -- Highlight the line where the cursor is on.
vim.o.scrolloff = 10    -- Keep this many screen lines above/below the cursor.
vim.o.list = true       -- Show <tab> and trailing spaces.

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldtext = ""

vim.o.foldcolumn = "1"


-- don't show parse errors in a separate window
vim.g.zig_fmt_parse_errors = 0
-- disable format-on-save from `ziglang/zig.vim`
vim.g.zig_fmt_autosave = 0


-- rust quick build test thingy
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.cmd.compiler("cargo")
	end,
})

vim.keymap.set("n", "<leader>cb", "<cmd>make build<cr>", { desc = "cargo build" })
vim.keymap.set("n", "<leader>cc", "<cmd>make clippy<cr>", { desc = "cargo clippy" })
vim.keymap.set("n", "<leader>ct", "<cmd>make test<cr>", { desc = "cargo test" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>")
vim.keymap.set("n", "[q", "<cmd>cprev<cr>")

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s). See `:h 'confirm'`
vim.o.confirm = true


-- Terminal render
local term_buf, term_win
local function toggle_terminal()
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_win_hide(term_win)
		term_win = nil
		return
	end
	vim.cmd("botright 15split")
	term_win = vim.api.nvim_get_current_win()
	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		vim.api.nvim_win_set_buf(term_win, term_buf)
	else
		vim.cmd.terminal()
		term_buf = vim.api.nvim_get_current_buf()
	end
	vim.cmd.startinsert()
end

-- KEYMAPS
--
-- See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- stop highlighting on escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- to use shift + H and shift + L to go to start and end of line
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')

-- get my old terminal keybind back
vim.keymap.set("n", '<leader>t', toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<A-t>", toggle_terminal, { desc = "Toggle terminal" })

-- move lines up and down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")

-- make missing ':' less irritating
vim.keymap.set('n', ';', ':')

-- Easier save
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>')

-- stole from https://github.com/jonhoo/configs/tree/master/editor/.config/nvim
vim.o.undofile = true    -- undo survives closing the file
vim.o.signcolumn = "yes" -- no layout jump when diagnostics/git signs appear
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.wrap = false
vim.o.colorcolumn = "80"
vim.api.nvim_create_autocmd("FileType", { pattern = "rust", command = "setlocal colorcolumn=100" })
vim.o.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"

-- AUTOCOMMANDS (EVENT HANDLERS)
--
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	callback = function()
		vim.hl.on_yank()
	end,
})

-- USER COMMANDS: DEFINE CUSTOM COMMANDS
--
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
	local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
	local filename = vim.api.nvim_buf_get_name(0)
	print(vim.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }):wait().stdout)
end, { desc = 'Print the git blame for the current line' })

-- PLUGINS
--
-- See `:h :packadd`, `:h vim.pack`

-- Add the "nohlsearch" package to automatically disable search highlighting after
-- 'updatetime' and when going to insert mode.
vim.cmd('packadd! nohlsearch')

-- Install third-party plugins via "vim.pack.add()".
vim.pack.add({
	-- Quickstart configs for LSP
	'https://github.com/neovim/nvim-lspconfig',
	-- Fuzzy picker
	'https://github.com/ibhagwan/fzf-lua',
	-- Autocompletion
	'https://github.com/nvim-mini/mini.completion',
	-- Enhanced quickfix/loclist
	'https://github.com/stevearc/quicker.nvim',
	-- Git integration
	'https://github.com/lewis6991/gitsigns.nvim',
	-- gruvbox theme
	"https://github.com/sainnhe/gruvbox-material",
	-- the wakatime for hackatime
	"https://github.com/wakatime/vim-wakatime",
	-- lualine
	'https://github.com/nvim-tree/nvim-web-devicons',
	'https://github.com/nvim-lualine/lualine.nvim',
	-- which-key for info
	"https://github.com/folke/which-key.nvim",
	--to automatically end starting parenthesis with ending one
	"https://github.com/nvim-mini/mini.pairs",
	-- to add surrounding brackets when needed
	"https://github.com/nvim-mini/mini.surround",
	-- for diff:
	'https://github.com/sindrets/diffview.nvim',
	-- zig stuff
	'https://codeberg.org/ziglang/zig.vim',
	"https://github.com/nvim-treesitter/nvim-treesitter",
})

vim.o.background = "dark"
vim.g.gruvbox_material_background = "medium" -- 'hard', 'medium', or 'soft'
vim.g.gruvbox_material_transparent_background = 1
vim.cmd.colorscheme("gruvbox-material")
vim.cmd.colorscheme("gruvbox-material")

-- ALL settings for FZF picker are here
require('fzf-lua').setup { fzf_colors = true }
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>ff', fzf.files, { desc = "Find Files" })
vim.keymap.set('n', '<leader><leader>', fzf.files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = "Find Buffers" })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = "Search Keybinds" })


require('mini.completion').setup {}
require('quicker').setup {}
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation: Jump between git changes
		map("n", "]h", function() gs.nav_hunk("next") end, { desc = "Next Git Hunk" })
		map("n", "[h", function() gs.nav_hunk("prev") end, { desc = "Prev Git Hunk" })

		-- Actions: Stage or Preview the single hunk under cursor
		map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
	end,
})

require('mini.surround').setup {}
require('mini.pairs').setup {}

require('which-key').setup {}
require("which-key").add({
	{ "<leader>f", group = "find" },
	{ "<leader>c", group = "cargo / code" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>s", group = "search" },
	{ "s",         group = "surround" },
})

-- the bottom status line
-- plain bar: same background for every section, no colored mode block
local theme = require("lualine.themes.auto")
for _, m in pairs(theme) do
	m.a, m.b = m.c, m.c
end

local function modified_buffers()
	local n = 0
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[b].buflisted and vim.bo[b].modified then
			n = n + 1
		end
	end
	return n > 0 and ("● " .. n .. " unsaved") or ""
end

require("lualine").setup({
	options = {
		theme = theme,
		globalstatus = true,
		section_separators = "",
		component_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "filename" },
		lualine_c = { "lsp_status", "branch", modified_buffers },
		lualine_x = { "diff", "diagnostics" },
		lualine_y = {
			function()
				return os.date("%H:%M")
			end,
		},
		lualine_z = { "progress", "location" },
	},
})



-- LSP settings

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = { library = { vim.env.VIMRUNTIME } },
		},
	},
})

vim.lsp.config("rust_analyzer", {
	settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})

vim.lsp.config("zls", {
	settings = {
		zls = {
			enable_build_on_save = true,
			-- build_on_save_step = "check", -- optional: if your build.zig defines a "check" step
		},
	},
})

vim.lsp.enable({ "rust_analyzer", "clangd", "zls", "lua_ls" })

vim.lsp.inlay_hint.enable()
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

fzf.register_ui_select()

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
--
-- format on save, only for the languages you work in
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.rs", "*.c", "*.cpp", "*.h", "*.zig", "*.zon", "*.lua" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function map(lhs, fn, desc)
			vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gr", fzf.lsp_references, "Find references")  -- Crucial for refactoring
		map("<leader>cr", vim.lsp.buf.rename, "Rename symbol") -- Rename everywhere
		map("<leader>ss", fzf.lsp_document_symbols, "Document symbols") -- Jump to any func/struct in file

		-- Jump between compiler errors
		map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
		map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
	end,
})
