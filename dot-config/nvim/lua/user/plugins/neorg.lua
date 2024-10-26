return {
    "nvim-neorg/neorg",
    ft = { "norg" },
    version = "*",
    dependencies = {
        "3rd/image.nvim",
    },
    keys = {
        { "<leader>an", "<cmd>Neorg workspace notes<cr>", desc = "Open notes" },
    },
    opts = {
        load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {},
            ["core.dirman"] = {
                config = {
                    workspaces = {
                        notes = "~/notes",
                    },
                    default_workspace = "notes",
                },
            },
            ["core.tangle"] = {
                config = {
                    tangle_on_write = true,
                    report_on_empty = false,
                },
            },
            ["core.completion"] = {
                config = {
                    name = "neorg",
                    engine = "nvim-cmp",
                }
            },
            ["core.latex.renderer"] = {},
        },
    },
    config = function(_, opts)
        require("neorg").setup(opts)

        vim.wo.foldlevel = 99
        vim.wo.conceallevel = 2
    end
}