local function trigger_workspace_diagnostics(client, bufnr)
  local command = 'rg --files --hidden --ignore-file .gitignore'

  -- TODO: derive extensions from client config
  -- add file extensions to grep
  -- for _, ext in ipairs(extensions) do
  --   command = command .. ' --glob "*.' .. ext .. '"'
  -- end

  local workspace_files = vim.fn.systemlist(command)

  -- convert paths to absolute
  for i, path in ipairs(workspace_files) do
    workspace_files[i] = vim.fn.fnamemodify(path, ':p')
  end

  local loaded_clients = {}

  if vim.tbl_contains(loaded_clients, client.id) then
    return
  end
  table.insert(loaded_clients, client.id)

  if not vim.tbl_get(client.server_capabilities, 'textDocumentSync', 'openClose') then
    return
  end

  for _, path in ipairs(workspace_files) do
    -- skip current buffer
    if path == vim.api.nvim_buf_get_name(bufnr) then
      goto continue
    end

    local filetype = vim.filetype.match { filename = path }

    if not filetype or not client.config.filetypes or not vim.tbl_contains(client.config.filetypes, filetype) then
      goto continue
    end

    local params = {
      textDocument = {
        uri = vim.uri_from_fname(path),
        version = 0,
        text = vim.fn.join(vim.fn.readfile(path), '\n'),
        languageId = filetype,
      },
    }
    client.notify('textDocument/didOpen', params)

    ::continue::
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('workspace-diagnostics', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.name == 'vtsls' then
      vim.api.nvim_create_user_command('WorkspaceDiagnosticsTS', function()
        trigger_workspace_diagnostics(client, bufnr)
      end, {})
    end
  end,
})

return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile', 'InsertLeave' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
  },
}
