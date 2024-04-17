return {
  'ggandor/leap.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('leap').create_default_mappings()

    -- TODO: enable ";" and "," repeats
  end,
  dependencies = {
    'tpope/vim-repeat',
  },
}
