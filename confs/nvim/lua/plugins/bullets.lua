return {
    "dkarter/bullets.vim",
    ft = "markdown",
    config = function()
        vim.g.bullets_enabled_file_types = {'markdown'}
        vim.g.bullets_enable = 1
        vim.g.bullets_checkbox_markers = ' ~x' -- Recognize [ ], [~], [x] 
        vim.g.bullets_outline_levels = {'std-', 'std*', 'std+', 'num', 'rom', 'abc', 'ROM'} -- Bullet types
        vim.g.bullets_set_mappings = 0
        -- vim.g.bullets_custom_mappings = { {'imap', '<CR>', '<Plug>(bullets-newline)'} }
    end,
}
