-- walk.lua: Markdown ベースのソース解説ウォークスルー
--
-- .walk.md 記法:
--   # 章見出し（複数可、最初の # は全体タイトルとしても使われる）
--
--   ## ステップ見出し
--   @ path:start-end   または @ path:line
--
--   Markdown 本文...
--
-- コマンド:
--   :WalkStart <file.walk.md>    ウォークスルー開始
--   :WalkNext / :WalkPrev        次/前のステップ
--   :WalkGoto <n>                指定ステップへ
--   :WalkToc                     目次（TOC）表示/切替
--   :WalkFocus                   解説ウィンドウにフォーカス
--   :WalkQuit                    終了
--
-- デフォルトキーマップ（ウォーク中のみ有効）:
--   ]w  次
--   [w  前
--   <leader>wt  TOC 切替
--   <leader>wq  終了
--   <leader>wf  解説にフォーカス

local M = {}

M.steps = {}
M.current = 0
M.float_win = nil
M.float_buf = nil
M.source_buf = nil
M.toc_win = nil
M.toc_buf = nil
M.toc_line_map = {}  -- TOC buffer行 → ステップindex
M.title = nil
M.ns = vim.api.nvim_create_namespace('walk')
M.ns_toc = vim.api.nvim_create_namespace('walk_toc')
M.active = false

-- ハイライト色（カラースキーム側で上書き可）
vim.api.nvim_set_hl(0, 'WalkRange', { bg = '#3a3a5a', default = true })
vim.api.nvim_set_hl(0, 'WalkTocCurrent', { bg = '#4a4a6a', bold = true, default = true })
vim.api.nvim_set_hl(0, 'WalkTocChapter', { fg = '#88aadd', bold = true, default = true })

local function clear_highlight()
  if M.source_buf and vim.api.nvim_buf_is_valid(M.source_buf) then
    vim.api.nvim_buf_clear_namespace(M.source_buf, M.ns, 0, -1)
  end
end

local function close_float()
  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.api.nvim_win_close(M.float_win, true)
  end
  M.float_win = nil
  M.float_buf = nil
end

local function close_toc()
  if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
    vim.api.nvim_win_close(M.toc_win, true)
  end
  M.toc_win = nil
  M.toc_buf = nil
  M.toc_line_map = {}
end

local function parse_walk(file)
  local steps = {}
  local current = nil
  local chapter = nil    -- 現在の章（# 見出し）
  local title = nil      -- 最初の # を walk 全体のタイトルとして扱う
  local f = io.open(file, 'r')
  if not f then
    return nil, 'cannot open: ' .. file
  end
  for line in f:lines() do
    if line:match('^## ') then
      -- ステップ開始
      if current then table.insert(steps, current) end
      current = {
        title = line:sub(4),
        chapter = chapter,
        ref = nil,
        body = {},
      }
    elseif line:match('^#%s') or line:match('^#$') then
      -- 章見出し（# foo or lone #）
      local h = vim.trim(line:sub(2))
      if not title then
        -- 最初の # はタイトルとしても記憶
        title = h
        -- 最初の # も章として扱うかは運用次第だが、シンプルに章として採用
        chapter = h
      else
        chapter = h
      end
      -- ステップ収集中なら確定（章は ## を含まない位置でも切る）
      if current then
        table.insert(steps, current)
        current = nil
      end
    elseif current and line:match('^@ ') then
      current.ref = vim.trim(line:sub(3))
    elseif current then
      table.insert(current.body, line)
    end
  end
  f:close()
  if current then table.insert(steps, current) end
  -- 末尾の空行を削除
  for _, step in ipairs(steps) do
    while #step.body > 0 and step.body[#step.body]:match('^%s*$') do
      table.remove(step.body)
    end
  end
  return steps, nil, title
end

local function parse_ref(ref)
  -- "path:start-end" または "path:line" を返す → path, start, end
  local path, range = ref:match('^(.-):(.+)$')
  if not path then
    return ref, nil, nil
  end
  local s, e = range:match('^(%d+)%-(%d+)$')
  if s and e then
    return path, tonumber(s), tonumber(e)
  end
  local line = tonumber(range)
  if line then
    return path, line, line
  end
  return path, nil, nil
end

local function open_source(path, s, e)
  -- パスを展開（~ や相対パス対応）
  path = vim.fn.expand(path)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  M.source_buf = vim.api.nvim_get_current_buf()

  if s and e then
    -- 行番号がファイル末尾を超えていたらクランプ
    local line_count = vim.api.nvim_buf_line_count(M.source_buf)
    if s > line_count then s = line_count end
    if e > line_count then e = line_count end
    if s < 1 then s = 1 end
    if e < s then e = s end

    -- 範囲ハイライト（行単位）
    for lnum = s, e do
      pcall(vim.api.nvim_buf_set_extmark, M.source_buf, M.ns, lnum - 1, 0, {
        line_hl_group = 'WalkRange',
      })
    end
    -- レイアウトは「上部 2/3 ソース、下部 1/3 解説」固定
    -- 範囲先頭をソースエリア上端に固定（zt）すれば常に範囲先頭は見える
    pcall(vim.api.nvim_win_set_cursor, 0, { s, 0 })
    vim.cmd('normal! zt')
  end
end

local function format_ref(path, s, e)
  if not path then return nil end
  -- ホーム短縮＋可能なら cwd 相対
  local short = vim.fn.fnamemodify(path, ':~:.')
  if s and e then
    if s == e then
      return string.format('%s:%d', short, s)
    else
      return string.format('%s:%d-%d', short, s, e)
    end
  end
  return short
end

-- レイアウト設計: 上部 2/3 がソース表示用、下部 1/3 が TOC + 解説用
-- 戻り値: 下部領域の top 行 / 高さ / 幅
local function compute_regions()
  local h = vim.o.lines - 2  -- statusline + cmdline 除外
  local w = vim.o.columns
  local bottom_h = math.max(8, math.floor(h / 3))
  local bottom_top = h - bottom_h
  return {
    bottom_top = bottom_top,
    bottom_h = bottom_h,
    editor_w = w,
    editor_h = h,
  }
end

local TOC_WIDTH = 38

local function open_float(step, idx, total, s, e, path)
  close_float()

  M.float_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(M.float_buf, 0, -1, false, step.body)
  vim.bo[M.float_buf].filetype = 'markdown'
  vim.bo[M.float_buf].modifiable = false
  vim.bo[M.float_buf].buftype = 'nofile'

  local r = compute_regions()
  -- TOC が開いていればその右側、閉じていれば左端から
  local toc_open = M.toc_win and vim.api.nvim_win_is_valid(M.toc_win)
  local left = toc_open and (TOC_WIDTH + 4) or 0  -- TOC 幅 + border + 隙間
  local width = r.editor_w - left - 2  -- 右端マージン
  local height = r.bottom_h - 2  -- border 分

  local opts = {
    relative = 'editor',
    row = r.bottom_top,
    col = left,
    width = math.max(20, width),
    height = math.max(4, height),
  }

  opts.border = 'rounded'
  if step.chapter then
    opts.title = string.format(' %d/%d · %s · %s ',
      idx, total, step.chapter, step.title)
  else
    opts.title = string.format(' Step %d/%d: %s ', idx, total, step.title)
  end
  opts.title_pos = 'center'
  opts.style = 'minimal'
  opts.focusable = true

  -- フッターに file:range を表示（幅を超える場合は末尾優先で切詰め）
  local ref = format_ref(path, s, e)
  if ref then
    local max = (opts.width or 60) - 4
    if #ref > max then
      ref = '…' .. ref:sub(-(max - 1))
    end
    opts.footer = ' ' .. ref .. ' '
    opts.footer_pos = 'right'
  end

  M.float_win = vim.api.nvim_open_win(M.float_buf, false, opts)
  vim.wo[M.float_win].wrap = true
  vim.wo[M.float_win].conceallevel = 2
  vim.wo[M.float_win].linebreak = true

  -- フロート内 q でソースに戻る
  vim.keymap.set('n', 'q', function()
    local src = vim.fn.bufwinid(M.source_buf or 0)
    if src ~= -1 then vim.api.nvim_set_current_win(src) end
  end, { buffer = M.float_buf, nowait = true, silent = true })
end

-- show_step は open_toc から呼ぶので前方宣言
local show_step

local function refresh_toc_highlight()
  if not (M.toc_buf and vim.api.nvim_buf_is_valid(M.toc_buf)) then return end

  -- バッファ書き換えはせず、extmark の付け替えだけで現在ステップを示す
  -- （バッファ更新による redraw アーティファクトを完全回避）
  vim.api.nvim_buf_clear_namespace(M.toc_buf, M.ns_toc, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(M.toc_buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:match('^▾ ') then
      vim.api.nvim_buf_set_extmark(M.toc_buf, M.ns_toc, i - 1, 0, {
        line_hl_group = 'WalkTocChapter',
      })
    end
  end

  for toc_line, step_idx in pairs(M.toc_line_map) do
    if step_idx == M.current then
      -- 行全体に背景色
      vim.api.nvim_buf_set_extmark(M.toc_buf, M.ns_toc, toc_line - 1, 0, {
        line_hl_group = 'WalkTocCurrent',
      })
      -- ▶ マーカーを 1 列目に上書き表示（バッファ自体は変えない）
      vim.api.nvim_buf_set_extmark(M.toc_buf, M.ns_toc, toc_line - 1, 1, {
        virt_text = { { '▶', 'WalkTocCurrent' } },
        virt_text_pos = 'overlay',
      })
      break
    end
  end
end

local function build_toc_lines()
  local lines = {}
  local line_map = {}
  if M.title then
    table.insert(lines, M.title)
    table.insert(lines, string.rep('─', math.min(#M.title + 4, 40)))
  end
  local cur_chapter = nil
  for i, step in ipairs(M.steps) do
    if step.chapter and step.chapter ~= cur_chapter then
      cur_chapter = step.chapter
      if #lines > 0 and lines[#lines] ~= '' then
        table.insert(lines, '')
      end
      table.insert(lines, '▾ ' .. cur_chapter)
    end
    -- マーカー位置は常に空白（現在ステップは extmark overlay で ▶ を表示）
    local entry = string.format('   %d. %s', i, step.title)
    table.insert(lines, entry)
    line_map[#lines] = i
  end
  return lines, line_map
end

local function open_toc()
  if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
    return  -- 既に開いている
  end

  local lines, line_map = build_toc_lines()
  M.toc_line_map = line_map

  M.toc_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(M.toc_buf, 0, -1, false, lines)
  vim.bo[M.toc_buf].modifiable = false
  vim.bo[M.toc_buf].buftype = 'nofile'
  vim.bo[M.toc_buf].filetype = 'walktoc'

  local r = compute_regions()
  local height = r.bottom_h - 2  -- border 分

  M.toc_win = vim.api.nvim_open_win(M.toc_buf, false, {
    relative = 'editor',
    row = r.bottom_top,
    col = 0,
    width = TOC_WIDTH,
    height = height,
    border = 'rounded',
    title = ' TOC ',
    title_pos = 'center',
    style = 'minimal',
    focusable = true,
  })
  vim.wo[M.toc_win].wrap = false
  vim.wo[M.toc_win].cursorline = false

  -- TOC 内のキーマップ
  -- <CR>: ステップへジャンプ（TOC にフォーカスを残して連続操作可能に）
  vim.keymap.set('n', '<CR>', function()
    local cur = vim.api.nvim_win_get_cursor(M.toc_win)[1]
    local idx = M.toc_line_map[cur]
    if idx then
      M.current = idx
      show_step(idx)
      -- show_step 後はソースウィンドウにフォーカスがあるので TOC に戻す
      if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
        vim.api.nvim_set_current_win(M.toc_win)
      end
    end
  end, { buffer = M.toc_buf, nowait = true, silent = true })

  -- o: ジャンプしてフロートにフォーカス（じっくり読む用）
  vim.keymap.set('n', 'o', function()
    local cur = vim.api.nvim_win_get_cursor(M.toc_win)[1]
    local idx = M.toc_line_map[cur]
    if idx then
      M.current = idx
      show_step(idx)
      if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
        vim.api.nvim_set_current_win(M.float_win)
      end
    end
  end, { buffer = M.toc_buf, nowait = true, silent = true })

  -- q: TOC を閉じて解説 float を広い領域に再配置
  vim.keymap.set('n', 'q', function()
    close_toc()
    show_step(M.current)
  end, { buffer = M.toc_buf, nowait = true, silent = true })

  -- 左クリック: クリックしたステップへジャンプ
  vim.keymap.set('n', '<LeftMouse>', function()
    local pos = vim.fn.getmousepos()
    if pos.winid ~= M.toc_win then return end
    if pos.line < 1 then return end
    pcall(vim.api.nvim_win_set_cursor, M.toc_win, { pos.line, 0 })
    local idx = M.toc_line_map[pos.line]
    if idx then
      M.current = idx
      show_step(idx)
      if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
        vim.api.nvim_set_current_win(M.toc_win)
      end
    end
  end, { buffer = M.toc_buf, nowait = true, silent = true })

  refresh_toc_highlight()

  -- 初回オープン時のみ現在ステップへカーソルを置く
  for toc_line, step_idx in pairs(M.toc_line_map) do
    if step_idx == M.current then
      pcall(vim.api.nvim_win_set_cursor, M.toc_win, { toc_line, 0 })
      break
    end
  end
end

-- TOC やフロート以外の「通常ウィンドウ」を探して、そこへフォーカスを移す
local function focus_source_window()
  local target = nil
  -- 既存の source_buf が出ているウィンドウを優先
  if M.source_buf and vim.api.nvim_buf_is_valid(M.source_buf) then
    local wid = vim.fn.bufwinid(M.source_buf)
    if wid ~= -1 then target = wid end
  end
  -- なければ最初の非フロートウィンドウ
  if not target then
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(w)
      if cfg.relative == '' then
        target = w
        break
      end
    end
  end
  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
    return true
  end
  return false
end

show_step = function(idx)
  local step = M.steps[idx]
  if not step then return end

  -- バッファ・ウィンドウ操作の前に必ずソース側ウィンドウへ移動
  -- （TOC や他のフロート上から呼ばれた場合の :edit 暴発を防ぐ）
  focus_source_window()

  clear_highlight()

  local s, e, path
  if step.ref and step.ref ~= '' then
    path, s, e = parse_ref(step.ref)
    open_source(path, s, e)
  end

  open_float(step, idx, #M.steps, s, e, path)
  refresh_toc_highlight()

  -- TOC は固定位置（bottom-left）なので追従処理は不要

  vim.notify(string.format('Walk %d/%d: %s', idx, #M.steps, step.title),
    vim.log.levels.INFO)
end

local function set_walk_keymaps(enable)
  if enable then
    vim.keymap.set('n', ']w', M.next,
      { desc = 'Walk: next', silent = true })
    vim.keymap.set('n', '[w', M.prev,
      { desc = 'Walk: prev', silent = true })
    vim.keymap.set('n', '<leader>wq', M.quit,
      { desc = 'Walk: quit', silent = true })
    vim.keymap.set('n', '<leader>wf', M.focus,
      { desc = 'Walk: focus float', silent = true })
    vim.keymap.set('n', '<leader>wt', M.toc,
      { desc = 'Walk: toggle TOC', silent = true })
  else
    pcall(vim.keymap.del, 'n', ']w')
    pcall(vim.keymap.del, 'n', '[w')
    pcall(vim.keymap.del, 'n', '<leader>wq')
    pcall(vim.keymap.del, 'n', '<leader>wf')
    pcall(vim.keymap.del, 'n', '<leader>wt')
  end
end

function M.start(file)
  file = vim.fn.expand(file)
  local steps, err, title = parse_walk(file)
  if not steps then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  if #steps == 0 then
    vim.notify('No ## steps in ' .. file, vim.log.levels.WARN)
    return
  end
  M.steps = steps
  M.title = title
  M.current = 1
  M.active = true
  set_walk_keymaps(true)
  show_step(1)
end

function M.toc()
  if not M.active then return end
  if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
    close_toc()
    -- TOC を閉じたら解説 float を再配置（広く使えるようになる）
    show_step(M.current)
  else
    open_toc()
    -- TOC を開いたら解説 float を再配置（TOC を避ける）
    show_step(M.current)
    -- 解説は再配置されてフォーカスがソース側に行くので TOC に戻す
    if M.toc_win and vim.api.nvim_win_is_valid(M.toc_win) then
      vim.api.nvim_set_current_win(M.toc_win)
    end
  end
end

function M.next()
  if not M.active then return end
  if M.current < #M.steps then
    M.current = M.current + 1
    show_step(M.current)
  else
    vim.notify('Walk: last step', vim.log.levels.INFO)
  end
end

function M.prev()
  if not M.active then return end
  if M.current > 1 then
    M.current = M.current - 1
    show_step(M.current)
  else
    vim.notify('Walk: first step', vim.log.levels.INFO)
  end
end

function M.goto(idx)
  if not M.active then return end
  idx = tonumber(idx)
  if idx and idx >= 1 and idx <= #M.steps then
    M.current = idx
    show_step(idx)
  end
end

function M.focus()
  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.api.nvim_set_current_win(M.float_win)
  end
end

function M.quit()
  close_float()
  close_toc()
  clear_highlight()
  set_walk_keymaps(false)
  M.steps = {}
  M.current = 0
  M.title = nil
  M.active = false
  vim.notify('Walk: ended', vim.log.levels.INFO)
end

-- ユーザコマンド登録
vim.api.nvim_create_user_command('WalkStart', function(opts)
  M.start(opts.args)
end, { nargs = 1, complete = 'file' })

vim.api.nvim_create_user_command('WalkNext', M.next, {})
vim.api.nvim_create_user_command('WalkPrev', M.prev, {})
vim.api.nvim_create_user_command('WalkGoto', function(opts)
  M.goto(opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command('WalkFocus', M.focus, {})
vim.api.nvim_create_user_command('WalkToc', M.toc, {})
vim.api.nvim_create_user_command('WalkQuit', M.quit, {})

return M
