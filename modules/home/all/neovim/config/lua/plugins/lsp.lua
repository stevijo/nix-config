return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "j-hui/fidget.nvim",
        },

        config = function()
            local cmp = require('cmp')
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities())

            require("fidget").setup({})
            require('mason').setup({
                registries = {
                    'github:nvim-java/mason-registry',
                    'github:mason-org/mason-registry',
                },
            })
            require('mason-lspconfig').setup({
                -- Replace the language servers listed here
                -- with the ones you want to install
                ensure_installed = {
                    'lua_ls',
                    'rust_analyzer',
                    'gopls',
                    'volar',
                    'tailwindcss',
                    'nil_ls',
                    'helm_ls',
                    'ruff',
                    'pyright',
                    'angularls',
                    'ts_ls',
                    'eslint',
                    'cssls',
                    'cssmodules_ls',
                    'emmet_ls'
                },
            })

            local vue_language_server_path = vim.fn.expand("$MASON/packages/vue-language-server"
                .. "/node_modules/@vue/language-server")

            vim.lsp.config('cssls', {

            })

            vim.lsp.config('emmet_ls', {

            })

            vim.lsp.config('cssmodules_ls', {

            })

            vim.lsp.config('nil_ls', {
                settings = {
                    ["nil"] = {
                        formatting = { command = { "nixpkgs-fmt" } }
                    },
                },
            })

            local on_attach = function(client, bufnr)
                if client.name == 'ruff' then
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                end
            end

            vim.lsp.config('ruff', {
                on_attach = on_attach,
            })

            vim.lsp.config('pyright', {

            })

            vim.lsp.config('gopls', {

            })

            vim.lsp.config('ts_ls', {
                filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
                init_options = {
                    plugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = vue_language_server_path,
                            languages = { "vue" },
                        },
                    },
                },
            })

            vim.lsp.config('angularls', {
                filetypes = { "htmlangular" }
            })

            vim.lsp.config('eslint', {

            })

            vim.lsp.config('volar', {
                init_options = {
                    vue = {
                        hybridMode = true,
                    },
                    typescript = {
                        tsdk = vim.fn.stdpath "data" .. "/mason/packages/vue-language-server/node_modules/typescript/lib",
                    },
                },
            })

            vim.lsp.config('helm_ls', {
                settings = {
                    ['helm-ls'] = {
                        yamlls = {
                            path = "yaml-language-server",
                        }
                    }
                }
            })

            vim.lsp.config('tailwindcss', {
                settings = {
                    tailwindCSS = {
                        classAttributes = { "class", "className", "ngClass" }
                    }
                }
            })

            vim.lsp.enable({ 'cssls', 'emmet_ls', 'cssmodules_ls', 'nil_ls', 'ruff', 'pyright', 'gopls', 'ts_ls', 'angularls', 'eslint', 'volar', 'helm_ls', 'tailwindcss' })

            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-space>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-z>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'copilot', priority = 100 },
                    { name = 'buffer' },
                })
            })

            vim.diagnostic.config({
                visual_text = false,
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    }
}

