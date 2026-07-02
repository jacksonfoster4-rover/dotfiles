return {
  {
    -- nvim-dap implements the Debug Adapter Protocol (DAP) client inside
    -- Neovim. DAP is the same protocol VS Code uses for debugging, so any
    -- debug adapter that works with VS Code (including debugpy for Python)
    -- works here too.
    --
    -- HOW THE DJANGO / DEBUGPY WORKFLOW WORKS:
    --
    --   0. Nothing to start manually. The Codespaces web container sets
    --      ENABLE_DEBUGPY=true (docker-compose.dev.codespaces.yml), so debugpy
    --      is ALWAYS listening whenever your normal dev server is running.
    --      There is no separate "debug container" or bin/debugpy.sh.
    --
    --   1. Set breakpoints with ;db on any line in the Django source.
    --
    --   2. Press ;da (attach to Django). This attaches to BOTH uwsgi workers
    --      at once — see the two-worker note below for why that matters.
    --      The DAP UI opens automatically.
    --
    --   3. Make a web request (browser, curl, etc.) to trigger the code path
    --      that hits your breakpoint. Execution pauses on whichever worker
    --      served the request and the DAP UI highlights the current line.
    --
    --   4. Use ;dn / ;di / ;do to step through code, ;dr to open the REPL,
    --      ;dc to continue to the next breakpoint.
    --
    --   5. When done: ;dt to terminate. The dev server keeps running normally.
    "mfussenegger/nvim-dap",

    config = function()
      local dap = require("dap")

      -- ── Adapter definition ──────────────────────────────────────────────
      -- "server" type = connect to an already-running debug adapter over TCP
      -- rather than launching one ourselves (debugpy is already listening
      -- inside the web container). Defined as a FUNCTION so each configuration
      -- can supply its own port via config.port — the Django dev server runs
      -- two uwsgi workers (config/wsgi/development.ini: processes = 2), each
      -- with its own debugpy listener, on 5678 and 5680.
      dap.adapters.python_remote = function(callback, config)
        callback({
          type = "server",
          host = "127.0.0.1",
          port = config.port,
          -- initialize_timeout_sec: how long to wait for debugpy to answer the
          -- initial DAP handshake. 20s is generous; it's usually up already.
          options = { initialize_timeout_sec = 20 },
        })
      end

      -- ── Path mappings ────────────────────────────────────────────────────
      -- The single most important setting for Docker debugging. debugpy runs
      -- INSIDE the container and reports file paths as they exist there
      -- (/web/...); Neovim runs on the Codespace HOST where the same files
      -- live under /workspaces/web/... . Without a mapping, a breakpoint's
      -- host path won't match any path debugpy knows, so it silently never
      -- fires. These entries mirror .vscode/launch.json's Django configs.
      --
      -- Order matters: the more specific venv → site-packages entry MUST come
      -- before the general repo entry, or the general one shadows it. The venv
      -- entry is what lets you step into installed packages (Django, DRF, …).
      local path_mappings = {
        {
          localRoot  = "/workspaces/web/venv/lib/python3.11/site-packages",
          remoteRoot = "/usr/local/lib/python3.11/site-packages",
        },
        {
          localRoot  = "/workspaces/web",
          remoteRoot = "/web",
        },
      }

      -- ── Configurations (one per uwsgi worker) ────────────────────────────
      -- uwsgi load-balances every web request across its two workers, so a
      -- breakpoint only fires reliably if you're attached to BOTH: attach to
      -- just 5678 and every request the 5680 worker happens to serve sails
      -- straight past your breakpoint (this is why debugging "randomly" didn't
      -- work before). Attaching to both is the nvim equivalent of VSCode's
      -- "Django Debug All Workers" compound in .vscode/launch.json.
      local function worker(name, port)
        return {
          type       = "python_remote",   -- must match the adapter name above
          request    = "attach",          -- connect to a running process
          name       = name,
          port       = port,              -- read by the adapter function above
          django     = true,              -- resolve Django template frames too
          justMyCode = false,             -- allow stepping into site-packages
          -- redirectOutput: stream the process's stdout/stderr into the DAP
          -- console so print()/log output shows without switching windows.
          redirectOutput = true,
          pathMappings = path_mappings,
        }
      end

      dap.configurations.python = {
        worker("Django worker 1 (5678)", 5678),
        worker("Django worker 2 (5680)", 5680),
      }

      -- Attach to BOTH workers in one keystroke (VSCode compound equivalent).
      -- nvim-dap supports concurrent sessions; dap-ui lists both and lets you
      -- switch between them. Exposed as :DjangoDebugAttach and bound to ;da
      -- (see keymaps.lua). Running ;dc instead lets you pick a single worker.
      vim.api.nvim_create_user_command("DjangoDebugAttach", function()
        for _, cfg in ipairs(dap.configurations.python) do
          dap.run(cfg)
        end
      end, { desc = "Attach the debugger to both Django uwsgi workers" })

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
