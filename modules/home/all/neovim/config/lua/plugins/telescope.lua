return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.5",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-tree/nvim-web-devicons"
    },

    config = function()
        require('telescope').setup({
            defaults = {
                path_display = { "smart" }
            }
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > "), use_regex = true });
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

        require("telescope").load_extension("file_browser")
    end
}

