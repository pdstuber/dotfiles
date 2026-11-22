vim.g.mapleader = ' '

-- From ~/.vimrc; hidden, hlsearch and most of defaults.vim are already Neovim defaults.
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.clipboard = 'unnamedplus'
vim.o.scrolloff = 5
vim.keymap.set('x', 'p', 'P')

vim.o.undofile = true
vim.o.signcolumn = 'yes'
vim.o.completeopt = 'menuone,noselect,popup'

vim.pack.add({
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/neovim/nvim-lspconfig',
})

-- Follows 'background', which Neovim reads from the terminal, so it tracks kitty's light/dark switch.
vim.cmd.colorscheme('modus')
-- shortcut: re-asks kitty for its background only on focus; an nvim focused at the macOS switch flips on the next focus.
vim.api.nvim_create_autocmd('FocusGained', {
  callback = function() vim.api.nvim_ui_send('\027]11;?\007') end,
})

vim.keymap.set('n', '<leader>f', '<cmd>FzfLua files<cr>')
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<cr>')
vim.keymap.set('n', '<leader>b', '<cmd>FzfLua buffers<cr>')

-- Server configs come from nvim-lspconfig, the servers from the Brewfile. Keymaps: :help lsp-defaults
vim.lsp.config('lua_ls', {
  settings = { Lua = { runtime = { version = 'LuaJIT' }, workspace = { library = { vim.env.VIMRUNTIME } } } },
})
-- Homebrew's cask ships intellij-server in a versioned folder; kotlin-lsp is the stable link to it.
vim.lsp.config('kotlin_lsp', { cmd = { 'kotlin-lsp', '--stdio' } })
vim.lsp.enable({ 'lua_ls', 'bashls', 'rust_analyzer', 'gopls', 'basedpyright', 'ts_ls', 'kotlin_lsp', 'gdscript' })

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
