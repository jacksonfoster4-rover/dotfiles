local dap = require("dap")
dap.adapters.python = { type = "executable", command = "python3", args = { "-m", "debugpy.adapter" } }
dap.configurations.python = {
    {
        type = "python", request = "launch", name = "Launch file",
        program = "${file}",
        pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then return venv .. "/bin/python" end
            return "python3"
        end
    }
}
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
