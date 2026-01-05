return {
    "nvim-java/nvim-java", 
    version = "^4.0.0",
    config = function()
        require('java').setup({
            jdk = {
                auto_install = false
            },
            jdtls = {
                version = '1.43.0'
            },
            java_test = {
                version = '0.40.1'
            },
            java_debug_adapter = {
                version = '0.58.2'
            }
        })

        vim.lsp.config('jdtls', {
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
        vim.lsp.enable('jdtls')
    end
}
