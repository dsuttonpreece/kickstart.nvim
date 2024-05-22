return {
  'NTBBloodbath/color-converter.nvim',
  config = function()
    vim.keymap.set('n', '<leader>cc', '<Plug>ColorConvertCycle<CR>', { desc = 'Show Color [C]onverter [C]ycle' })
  end,
}
