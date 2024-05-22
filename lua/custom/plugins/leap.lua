return {
  'ggandor/leap.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    -- Default mappins cause weird conflicts on `gs` mappings
    -- require('leap').create_default_mappings()
    require 'leap'

    vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
    vim.keymap.set('n', 'S', '<Plug>(leap-backward)')
    vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')

    -- TODO: enable ";" and "," repeats
  end,
  dependencies = {
    'tpope/vim-repeat',
  },
}
