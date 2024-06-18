-- redirect output of command to scratch buffer
function Scratch()
  vim.ui.input({ prompt = 'enter command: ', completion = 'command' }, function(input)
    if input == nil then
      return
    elseif input == 'scratch' then
      input = "echo('')"
    end
    local cmd = vim.api.nvim_exec2(':lua ' .. input, { output = true })
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cmd.output })
    vim.api.nvim_win_set_buf(0, buf)
  end)
end

vim.keymap.set('n', '<leader>sc', Scratch, { desc = 'Command to scratch buffer' })
