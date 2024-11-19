return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>dd", "<cmd>lua require('dap').continue()<cr>",          desc = "Continue or start debugging" },
            { "<leader>dr", "<cmd>lua require('dap').restart()<cr>",           desc = "Restart debugging session" },
            { "<leader>dq", "<cmd>lua require('dap').terminate()<cr>",         desc = "Terminate debugging session" },
            { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle breakpoint" },
            { "<leader>di", "<cmd>lua require('dap').step_into()<cr>",         desc = "Step into" },
            { "<leader>do", "<cmd>lua require('dap').step_over()<cr>",         desc = "Step over" },
            { "<leader>du", "<cmd>lua require('dap').step_out()<cr>",          desc = "Step out" },
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        keys = {
            { "<leader>dt", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },
        },
        opts = {},
    },
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = {},
    }
}
