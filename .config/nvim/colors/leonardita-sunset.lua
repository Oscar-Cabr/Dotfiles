vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "leonardita-sunset"

local palette = {
  bg = "#1e1e1e",
  fg = "#d4d4d4",
  red = "#f44747",
  orange = "#ff8800",
  yellow = "#ffcc00",
  green = "#6a9955",
  cyan = "#4ec9b0",
  blue = "#569cd6",
  purple = "#c586c0",
  gray = "#808080",
  comment = "#6a9955",
}

-- Helper
local hl = vim.api.nvim_set_hl

local groups = {
  -- UI Elements
  Normal = { fg = palette.fg, bg = "NONE" },
  NormalFloat = { fg = palette.fg, bg = "NONE" },
  CursorLine = { bg = "#2a2a2a" },
  LineNr = { fg = palette.gray },
  CursorLineNr = { fg = palette.yellow, bold = true },
  Visual = { bg = "#252526", fg = palette.fg },
  Pmenu = { bg = "#252526", fg = palette.bg },
  PmenuSel = { bg = palette.blue, fg = palette.bg, bold = true },
  Search = { bg = palette.yellow, fg = palette.bg },

  -- Standard Syntax (Fallback)
  Comment = { fg = palette.comment, italic = true },
  Constant = { fg = palette.blue },
  String = { fg = palette.orange },
  Identifier = { fg = palette.blue },
  Function = { fg = palette.yellow },
  Statement = { fg = palette.purple },
  PreProc = { fg = palette.purple },
  Type = { fg = palette.cyan },
  Special = { fg = palette.orange },

  -- Treesitter
  ["@variable"] = { fg = palette.fg },
  ["@function"] = { fg = palette.yellow },
  ["@keyword"] = { fg = palette.purple },
  ["@operator"] = { fg = palette.fg },
  ["@type"] = { fg = palette.cyan },
  ["@constant"] = { fg = palette.blue },
  ["@comment"] = { fg = palette.comment, italic = true },
  ["@string"] = { fg = palette.orange },
  ["@parameter"] = { fg = palette.blue },
  ["@tag"] = { fg = palette.blue },
  ["@tag.delimiter"] = { fg = palette.gray },
  ["@tag.attribute"] = { fg = palette.cyan },
  ["@attribute"] = { fg = palette.cyan },
  ["@string.special"] = { fg = palette.orange },
  ["@string.special.url"] = { fg = palette.blue, underline = true },

  -- LSP Diagnostics
  DiagnosticError = { fg = palette.red },
  DiagnosticWarn = { fg = palette.orange },
  DiagnosticInfo = { fg = palette.blue },
  DiagnosticHint = { fg = palette.cyan },

  -- Window Splits and Borders
  WinSeparator = { fg = palette.gray },
  FloatBorder = { fg = palette.blue },

  -- blink.cmp
  BlinkCmpMenu = { fg = palette.fg, bg = "#252526" },
  BlinkCmpMenuSelection = { fg = palette.bg, bg = palette.blue, bold = true },
  BlinkCmpLabel = { fg = palette.yellow },
  BlinkCmpSource = { fg = palette.gray, italic = true },
  BlinkCmpDocumentation = { fg = palette.fg, bg = "NONE" },
  BlinkCmpDocumentationBorder = { fg = palette.blue },
}

for group, settings in pairs(groups) do
  hl(0, group, settings)
end
