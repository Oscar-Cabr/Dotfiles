return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  config = function()
    require("blink.cmp").setup({
      enabled = function()
        return vim.b.blink_cmp_enabled ~= false
      end,
    })
  end,
}
