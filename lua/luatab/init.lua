local M = {}

M.title = function(bufnr)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")

  if buftype == "help" then
    return "help:" .. vim.fn.fnamemodify(file, ":t:r")
  elseif buftype == "quickfix" then
    return nil
  elseif filetype == "TelescopePrompt" then
    return nil
  elseif filetype == "git" then
    return nil
  elseif filetype == "fugitive" then
    return nil
  elseif file:sub(file:len() - 2, file:len()) == "FZF" then
    return nil
  elseif buftype == "terminal" then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ":t")
  elseif file == "" then
    return nil
  else
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ":p:~:t"))
  end
end

M.modified = function(bufnr)
  return vim.fn.getbufvar(bufnr, "&modified") == 1 and "[+] " or ""
end

M.windowCount = function(index)
  local nwins = vim.fn.tabpagewinnr(index, "$")
  return nwins > 1 and "(" .. nwins .. ") " or ""
end

M.devicon = function(bufnr)
  local icon
  local file = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")
  local devicons = require "nvim-web-devicons"
  if filetype == "TelescopePrompt" then
    icon = devicons.get_icon("telescope")
  elseif filetype == "fugitive" then
    icon = devicons.get_icon("git")
  elseif filetype == "vimwiki" then
    icon = devicons.get_icon("markdown")
  elseif buftype == "terminal" then
    icon = devicons.get_icon("zsh")
  else
    icon = devicons.get_icon(file, vim.fn.expand("#" .. bufnr .. ":e"))
  end
  if icon then
    return icon .. " "
  end
  return ""
end

M.separator = function(index)
  return (index < vim.fn.tabpagenr("$") and "%#TabLine#|" or "")
end

M.cell = function(index)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local hl = (isSelected and "%#TabLineSel#" or "%#TabLine#")
  local title = M.title(bufnr)

  if not title then
    return ""
  end

  return hl .. "%" .. index .. "T" .. " " ..
      M.devicon(bufnr) ..
      title .. " " ..
      M.modified(bufnr) ..
      M.separator(index)
end

M.tabline = function()
  local line = "%#TabLineFill#%="
  for i = 1, vim.fn.tabpagenr("$"), 1 do
    local cell = M.cell(i)
    if cell == "" then
      return ""
    end
    line = line .. M.cell(i)
  end
  line = line .. "%#TabLineFill#%="
  return line
end

local setup = function(opts)
  opts = opts or {}
  if opts.title then M.title = opts.title end
  if opts.modified then M.modified = opts.modified end
  if opts.windowCount then M.windowCount = opts.windowCount end
  if opts.devicon then M.devicon = opts.devicon end
  if opts.separator then M.separator = opts.separator end
  if opts.cell then M.cell = opts.cell end
  if opts.tabline then M.tabline = opts.tabline end

  vim.opt.tabline = "%!v:lua.require\'luatab\'.helpers.tabline()"
end

local warning = function()
  error [[
Hi, I"ve updated luatab.nvim to allow some proper configuration. As a result, I need to make a breaking change to the config. Apologies for the inconvinence.
If you had:
    vim.o.tabline = "%!v:lua.require\"luatab\".tabline()"
please replace it with
    require("luatab").setup({})
]]
end

return {
  helpers = M,
  setup = setup,
  tabline = warning,
}
