return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_auto_start = 1
        vim.g.mkdp_page_title = "${name} - Preview"
        vim.g.mkdp_combine_preview = 1
        vim.g.mkdp_auto_close = 0
    end,
    ft = { "markdown" },
    keys = {
        { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Enable markdown preview" },
    },
}
