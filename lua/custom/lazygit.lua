local function check_tmux_session()
  if not os.getenv 'TMUX' then
    error 'This script must be run inside an active tmux session.'
  end
end

local function window_exists(name)
  local handle = io.popen("tmux list-windows -F '#W' | grep -w " .. name)
  if handle == nil then
    return false
  end
  local result = handle:read '*a'
  handle:close()
  return result ~= ''
end

local function get_window_id(name)
  local handle = io.popen("tmux list-windows -F '#I:#W' | grep -w " .. name .. ' | cut -d: -f1')
  if handle == nil then
    return nil
  end
  local result = handle:read('*a'):gsub('\n', '')
  handle:close()
  return result
end

local function is_process_running(window_id)
  local handle = io.popen('tmux list-panes -t ' .. window_id .. " -F '#{pane_pid}' | xargs ps -p | grep -v '^s*PID' | wc -l")
  if handle == nil then
    return false
  end
  local result = tonumber(handle:read '*a')
  handle:close()
  return result > 0
end

local function switch_to_window(window_id)
  os.execute('tmux select-window -t ' .. window_id)
end

local function create_and_run(name, command)
  os.execute('tmux new-window -n ' .. name)
  os.execute('tmux send-keys -t ' .. name .. " '" .. command .. "' C-m")
end

-- Main workflow
function TmuxLazygit()
  local window_name = 'lazygit'

  check_tmux_session()

  if window_exists(window_name) then
    local window_id = get_window_id(window_name)
    if is_process_running(window_id) then
      switch_to_window(window_id)
    else
      os.execute('tmux send-keys -t ' .. window_id .. " 'lazygit' C-m")
    end
  else
    create_and_run(window_name, 'lazygit')
  end
end

vim.api.nvim_create_user_command('TmuxLazyGit', TmuxLazygit, {})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = vim.api.nvim_create_namespace 'lazygit',
  callback = function()
    vim.keymap.set('n', '<leader>lg', TmuxLazygit, { desc = '[L]azy[G]it' })
  end,
})
