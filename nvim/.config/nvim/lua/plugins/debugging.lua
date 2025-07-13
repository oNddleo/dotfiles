return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text",
        "williamboman/mason.nvim",
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")
        vim.fn.sign_define("DapBreakpoint", {
            text = "🔴",
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = "",
        })

        vim.fn.sign_define("DapBreakpointCondition", {
            text = "🟡",
            texthl = "DapBreakpointCondition",
            linehl = "",
            numhl = "",
        })

        vim.fn.sign_define("DapLogPoint", {
            text = "🔵",
            texthl = "DapLogPoint",
            linehl = "",
            numhl = "",
        })

        vim.fn.sign_define("DapStopped", {
            text = "→",
            texthl = "DapStopped",
            linehl = "DapStoppedLine",
            numhl = "DapStoppedLine",
        })
        require("dap-go").setup()
        require("dapui").setup()
        require("nvim-dap-virtual-text").setup({
            -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
            display_callback = function(variable)
                local name = string.lower(variable.name)
                local value = string.lower(variable.value)
                if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
                    return "*****"
                end

                if #variable.value > 15 then
                    return " " .. string.sub(variable.value, 1, 15) .. "... "
                end

                return " " .. variable.value
            end,
        })
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
        vim.keymap.set("n", "<Leader>db", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, {})
        vim.keymap.set("n", "<Leader>dr", dap.repl.open, {})
        vim.keymap.set("n", "<Leader>dl", dap.run_last, {})
        vim.keymap.set("n", "<F5>", dap.continue, {})
        vim.keymap.set("n", "<F10>", dap.step_over, {})
        vim.keymap.set("n", "<F11>", dap.step_into, {})
        vim.keymap.set("n", "<F12>", dap.step_out, {})
    end,
}

-- dont for get to install debugger here: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
-- eg: go... brew install delve, then add go dependencies
