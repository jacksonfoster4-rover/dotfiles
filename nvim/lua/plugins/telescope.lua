return {
{
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        path_display = { "smart" },

        -- These args are passed to ripgrep for every search (;ff and ;fc).
        -- The defaults already include --color=never etc; we extend them here
        -- to skip directories that are never worth searching through.
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--glob=!node_modules/**",   -- JS/TS dependencies
          "--glob=!.git/**",           -- git internals
          "--glob=!**/*.min.js",       -- minified bundles
          "--glob=!static/dist/**",    -- compiled frontend assets
          "--glob=!venv/**",           -- Python virtualenv
          "--glob=!**/__pycache__/**", -- Python bytecode
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("live_grep_args")
  end,
},
}
