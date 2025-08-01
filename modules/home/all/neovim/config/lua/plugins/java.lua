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
                                name = "JavaSE-21",
                                path = vim.g.javapath,
                                default = true,
                            }
                        }
                    }
                }
            }
        })
    end
}
