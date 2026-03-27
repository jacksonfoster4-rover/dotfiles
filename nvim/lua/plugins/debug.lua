return {
  {
    -- nvim-dap implements the Debug Adapter Protocol (DAP) client inside
    -- Neovim. DAP is the same protocol VS Code uses for debugging, so any
    -- debug adapter that works with VS Code (including debugpy for Python)
    -- works here too.
    --
    -- HOW THE DJANGO / DEBUGPY WORKFLOW WORKS:
    --
    --   1. In a terminal (;sh), run:  cd ~/projects/web && ./bin/debugpy.sh
    --      This starts an ephemeral Docker container that:
    --        - runs  manage.py runserver 0.0.0.0:8000
    --        - with  ENABLE_DEBUGPY=true  which causes manage.py to call
    --          debugpy.listen(("0.0.0.0", 5678)) before the server loop
    --        - publishes port 5678 → localhost:5678  (the DAP port)
    --        - publishes port 8000 → localhost:8000  (the web port)
    --
    --   2. Wait until you see "Starting development server" in the terminal.
    --      debugpy is now listening and waiting for a DAP client to attach.
    --
    --   3. In Neovim, press ;dc  (DapContinue / attach).
    --      nvim-dap connects to localhost:5678, completes the DAP handshake,
    --      and Django resumes serving requests in debug mode.
    --
    --   4. Set breakpoints with ;db on any line in the Django source.
    --
    --   5. Make a web request (browser, curl, etc.) to trigger the code path
    --      that hits your breakpoint. Execution pauses and the DAP UI opens.
    --
    --   6. Use ;dn / ;di / ;do to step through code, ;dr to open the REPL,
    --      ;dc to continue to the next breakpoint.
    --
    --   7. When done: ;dt to terminate the session, then Ctrl-C in the
    --      terminal to shut down debugpy.sh and restore the normal container.
    "mfussenegger/nvim-dap",

    config = function()
      local dap = require("dap")

      -- ── Adapter definition ──────────────────────────────────────────────
      -- "server" type means we connect to an already-running debug adapter
      -- over TCP rather than launching a new one ourselves. debugpy.sh has
      -- already started debugpy inside the container; we just attach.
      dap.adapters.python_remote = {
        type = "server",
        host = "127.0.0.1",
        port = 5678,
        -- options.initialize_timeout_sec: how long to wait for debugpy to
        -- respond to the initial DAP handshake. 20s is generous; the
        -- container is usually up well before this.
        options = {
          initialize_timeout_sec = 20,
        },
      }

      -- ── Configuration ───────────────────────────────────────────────────
      -- A "configuration" describes a specific debug scenario. You pick one
      -- when you run ;dc (DapContinue). We define one for the Django container.
      dap.configurations.python = {
        {
          -- Must match the adapter name defined above.
          type    = "python_remote",

          -- "attach" = connect to an already-running process.
          -- The alternative is "launch" (start a new process), but Django
          -- lives inside Docker so we always attach.
          request = "attach",
          name    = "Attach to Django container (debugpy.sh)",

          -- pathMappings is the most important setting for Docker debugging.
          -- debugpy runs INSIDE the container and knows file paths as they
          -- exist there (e.g. /web/src/aplaceforrover/users/views.py).
          -- Neovim runs on the HOST and has the same files at a different
          -- path (~/projects/web/src/aplaceforrover/users/views.py).
          --
          -- Without this mapping, when you set a breakpoint in Neovim the
          -- path Neovim sends to debugpy won't match any file it knows about,
          -- so the breakpoint will silently never fire.
          --
          -- The mapping tells debugpy: "any path that starts with
          -- /web/src/aplaceforrover in the container corresponds to
          -- ~/projects/web/src/aplaceforrover on the host."
          pathMappings = {
            {
              localRoot  = vim.fn.expand("~/projects/web/src/aplaceforrover"),
              remoteRoot = "/web/src/aplaceforrover",
            },
          },

          -- justMyCode = true: only pause on breakpoints in YOUR code.
          -- Set to false if you need to step into Django internals or
          -- third-party libraries to understand what's happening.
          justMyCode = true,

          -- redirectOutput: stream stdout/stderr from the Django process
          -- into the DAP console panel so you can see print() output and
          -- Django log messages without switching to the terminal.
          redirectOutput = true,
        },
      }

      -- ── Signs (gutter indicators) ───────────────────────────────────────
      -- Show clear symbols in the sign column so you can see at a glance
      -- where breakpoints are set and which line execution is paused on.
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError"   })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DiagnosticWarning" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk"      })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DiagnosticHint"    })
    end,
  },

  {
    -- nvim-dap-ui adds the visual debugging panels: variables, watch,
    -- call stack, breakpoints list, and an interactive REPL. It opens
    -- automatically when a debug session starts and closes when it ends.
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      -- nvim-nio is a Neovim async I/O library required by nvim-dap-ui
      -- to run UI updates without blocking the editor.
      "nvim-neotest/nvim-nio",
    },
    config = function()
      -- dap must be required here — it is NOT inherited from the nvim-dap
      -- plugin's config block above. Each plugin's config function has its
      -- own scope.
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        -- Layout: two side panels (variables/watch on left, REPL/console
        -- on bottom) plus a floating element for expression evaluation.
        layouts = {
          {
            -- Left sidebar: variables, scopes, watches, call stack
            position = "left",
            size = 40,
            elements = {
              { id = "scopes",      size = 0.40 },
              { id = "watches",     size = 0.20 },
              { id = "stacks",      size = 0.25 },
              { id = "breakpoints", size = 0.15 },
            },
          },
          {
            -- Bottom panel: REPL + console output
            position = "bottom",
            size = 12,
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
          },
        },
      })

      -- Auto-open the UI when a debug session starts, auto-close when it ends.
      -- Without these hooks you'd have to run :lua require("dapui").open()
      -- manually every time.
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
  },
}
