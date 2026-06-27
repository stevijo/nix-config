return {
    "nvim-java/nvim-java", 
    version = "^4.1.0",
    config = function()
        -- require('java').setup({
        --     jdk = {
        --         auto_install = false
        --     },
        -- })

        -- vim.lsp.config('jdtls', {
        --     settings = {
        --         java = {
        --             codeGeneration = {
        --                 hashCodeEquals = {
        --                     useInstanceof = true,
        --                     useJava7Objects = true,
        --                 }
        --             },
        --             configuration = {
        --                 runtimes = {
        --                     {
        --                         name = vim.env.JAVA_VERSION,
        --                         path = vim.env.JAVA_HOME,
        --                         default = true,
        --                     }
        --                 }
        --             }
        --         }
        --     }
        -- })
        -- vim.lsp.enable('jdtls')
    end
}
