-- Custom format range command
vim.api.nvim_create_user_command('FormatRange', function(args)
  -- get range
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end

  -- format range
  require('conform').format { async = false, lsp_fallback = true, range = range }

  -- fix indentation after local format
  vim.api.nvim_command(args.line1 .. ',' .. args.line2 .. 'normal! ==')
end, { range = true })

return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      mode = 'v',
      '<leader>f',
      ':FormatRange<CR>',
      desc = 'Format range',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      javascript = { { 'prettierd', 'prettier' }, 'rustywind' },
      javascriptreact = { { 'prettierd', 'prettier' }, 'rustywind' },
      typescript = { 'prettierd', 'prettier' },
      'rustywind',
      typescriptreact = { 'prettierd', 'prettier' },
      'rustywind',
    },
  },
}
