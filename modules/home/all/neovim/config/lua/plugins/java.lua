return {
    "nvim-java/nvim-java",
    config = function()
        require('java').setup({
            jdk = {
                auto_install = false
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
                                path = "/usr/lib/jvm/temurin-21-jdk-amd64",
                                default = true,
                            }
                        }
                    }
                }
            }
        })
    end
}
