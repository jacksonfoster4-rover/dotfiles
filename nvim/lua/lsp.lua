local lspconfig = require("lspconfig")

-- === Python ===
lspconfig.pyright.setup{}

-- Formatters: black & isort
lspconfig.efm.setup{
    init_options = { documentFormatting = true },
    filetypes = { "python" },
    settings = {
        rootMarkers = { ".git/", ".pylintrc", "isort.cfg", "pyproject.toml" },
        languages = {
            python = {
                { formatCommand = "black --quiet -", formatStdin = true },
                { formatCommand = "isort --quiet -", formatStdin = true },
                { lintCommand = "pylint --from-stdin --output-format=text --score=no ${INPUT}", lintStdin = true, lintFormats = { "%f:%l:%c: %m" } },
            },
        },
    },
}

-- === JavaScript / TypeScript ===
lspconfig.ts_ls.setup{}

-- Eslint
lspconfig.eslint.setup{
    settings = {
        -- this makes it pick up your project’s eslint config
        workingDirectories = { mode = "auto" },
    },
}
