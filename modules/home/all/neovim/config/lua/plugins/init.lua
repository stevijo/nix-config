return {
    
    {
        "folke/tokyonight.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('tokyonight').setup({
                style = 'storm',
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false }
                }
            })
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end,
      },
      {
        "nvim-lua/plenary.nvim",
        name = "plenary"
      },   
}