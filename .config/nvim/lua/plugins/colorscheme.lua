return {
  {
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme leonardita-sunset]])
    end,
  },
}
