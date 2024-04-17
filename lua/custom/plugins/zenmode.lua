return {
  'folke/zen-mode.nvim',
  opts = {
    window = {
      width = 100,
    },
  },
  keys = {
    {
      mode = 'n',
      '<leader>z',
      ':ZenMode<CR>',
      desc = 'Toggle [Z]en mode',
    },
  },
}
