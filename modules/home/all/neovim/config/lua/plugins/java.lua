return {
    "nvim-java/nvim-java", 
    version = "^2.0.0",
    config = function()
        require('java').setup({
            jdk = {
                auto_install = false
            },
            java_debug_adapter = {
                version = '0.58.2'
            }
        })

        require('lspconfig').jdtls.setup({
            settings = {
                java = {
                    codeGeneration = {
                        hashCodeEquals = {
                            useInstanceof = true,
                            useJava7Objects = true,
                        }
                    },
                    configuration = {
                        runtimes = {
                            {
                                name = vim.env.JAVA_VERSION,
                                path = vim.env.JAVA_HOME,
                                default = true,
                            }
                        }
                    }
                }
            }
        })
    end
}
