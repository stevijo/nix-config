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
                    'emmet_ls',
                },
            })

            local mason_registry = require("mason-registry")
            local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
                .. "/node_modules/@vue/language-server"

            require('lspconfig').cssls.setup {

            }

            require('lspconfig').emmet_ls.setup {

            }

            require('lspconfig').cssmodules_ls.setup {

            }

            require('lspconfig').nil_ls.setup {
                settings = {
                    ["nil"] = {
                        formatting = { command = { "nixpkgs-fmt" } }
                    },
                },
            }

            local on_attach = function(client, bufnr)
                if client.name == 'ruff' then
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                end
            end

            require('lspconfig').ruff.setup {
                on_attach = on_attach,
            }

            require('lspconfig').pyright.setup {

            }

            require('lspconfig').gopls.setup {

            }

            require('lspconfig').ts_ls.setup {
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
            }

            require('lspconfig').angularls.setup {
                filetypes = { "htmlangular" }
            }

            require('lspconfig').eslint.setup {

            }

            require('lspconfig').volar.setup {
                init_options = {
                    vue = {
                        hybridMode = true,
                    },
                    typescript = {
                        tsdk = vim.fn.stdpath "data" .. "/mason/packages/vue-language-server/node_modules/typescript/lib",
                    },
                },
            }

            require('lspconfig').helm_ls.setup({
                settings = {
                    ['helm-ls'] = {
                        yamlls = {
                            path = "yaml-language-server",
                        }
                    }
                }
            })

            require('lspconfig').tailwindcss.setup({
                settings = {
                    tailwindCSS = {
                        classAttributes = { "class", "className", "ngClass" }
                    }
                }
            })

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

