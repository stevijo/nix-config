return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            {
                "zbirenbaum/copilot.lua",
                cmd = "Copilot",
                build = ":Copilot auth",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                    filetypes = {
                        markdown = true,
                        help = true,
                    },
                },
            },
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            -- See Configuration section for options
        },
        -- See Commands section for default commands if you want to lazy load on them
    },

    {
        "zbirenbaum/copilot-cmp",
        dependencies = "copilot.lua",
        opts = {},
        config = function(_, opts)
            local monkeypatch = require("copilot_cmp.source")
            monkeypatch.is_available = function(self)
              -- client is stopped.
              if self.client:is_stopped() or not self.client.name == "copilot" then
                return false
              end

              local get_source_client = function()
                if vim.lsp.get_clients == nil then
                  return vim.lsp.get_active_clients({
                    bufnr = vim.api.nvim_get_current_buf(),
                    id = self.client.id,
                  })
                end
                return vim.lsp.get_clients({
                  bufnr = vim.api.nvim_get_current_buf(),
                  id = self.client.id,
                })
              end

              return next(get_source_client()) ~= nil
            end

            local copilot_cmp = require("copilot_cmp")
            copilot_cmp.setup(opts)
        end,
    }

}
