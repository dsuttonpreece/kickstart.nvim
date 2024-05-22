return {
  'shortcuts/no-neck-pain.nvim',
  version = '*',

  opts = {
    window = {
      width = 130,
    },
  },
  keys = {
    {
      mode = 'n',
      '<leader>z',
      ':NoNeckPain<CR>',
      desc = 'Toggle [Z]en mode',
    },
  },
}
