return {
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        java = { "palantir" }
    },
    default_format_opts = {
        lsp_format = "fallback",
    },
    formatters = {
        palantir = {
            command = "java",
            args = { "-jar", vim.g.palantirformat, "--palantir", "-" } 
        }
    }
  }
}
