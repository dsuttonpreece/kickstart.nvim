vim.api.nvim_create_augroup('lsp_attach', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    --  To jump back, press <C-t>.
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

    map('gr', function()
      require('telescope.builtin').lsp_references {
        layout_strategy = 'horizontal',
      }
    end, '[G]oto [R]eferences')

    --  Useful when your language has ways of declaring types without an actual implementation.
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

    -- Fuzzy find all the symbols in your current document.
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

    -- Fuzzy find all the symbols in your current workspace.
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    --  See `:help K` for why this keymap.
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = 'lsp_attach',
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = 'lsp_attach',
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

return { -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'yioneko/nvim-vtsls',
    { 'j-hui/fidget.nvim', opts = {} }, -- Useful status updates for LSP.
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`
    local capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities())

    -- Custom gleam lsp config
    require('lspconfig').gleam.setup {
      cmd = { 'gleam', 'lsp' },
      filetypes = { 'gleam' },
      root_dir = require('lspconfig').util.root_pattern('gleam.toml', '.git'),
      on_attach = function(client)
        if client.name == 'gleam' then
          client.server_capabilities.documentFormattingProvider = true
        end
        local status_ok, illuminate = pcall(require, 'illuminate')
        if not status_ok then
          return
        end
        illuminate.on_attach(client)
      end,
      capabilities = capabilities,
    }

    require('lspconfig.configs').vtsls = require('vtsls').lspconfig
    require('mason').setup()
    require('mason-lspconfig').setup {
      ensure_installed = {
        'ast_grep',
        'astro',
        'cssls',
        'cssmodules_ls',
        'docker_compose_language_service',
        'dockerls',
        'graphql',
        'html',
        'jsonls',
        'lua_ls',
        'ruff_lsp',
        'tailwindcss',
        'vtsls',
        'yamlls',
        -- WARN: Must be installed manually with Mason
        -- "css-variables-language-server",
        -- "rustywind",
        -- 'ruff'
        -- "stylua",
        -- WARN: use Homebrew instead of Mason install
        -- "eslint_d",
        -- "prettierd",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
          }
        end,

        ['lua_ls'] = function()
          require('lspconfig').lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
              },
            },
          }
        end,
      },
    }
  end,
}
