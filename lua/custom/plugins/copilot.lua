return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = '<C-a>',
        accept_word = '<C-w>',
        accept_line = '<C-W>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-e>',
      },
    },
    copilot_node_command = 'node', -- Node.js version must be > 18.x
    server_opts_overrides = {},
  },
}
