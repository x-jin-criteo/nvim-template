return {
  {
    "scalameta/nvim-metals",
    lazy = true, -- Keep lazy loading as intended
    ft = { "scala", "sbt", "java" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      vim.api.nvim_create_user_command("MetalsInstall", function() require("metals").install() end, {})
      vim.api.nvim_create_user_command("MetalsLogsToggle", function() require("metals").toggle_logs() end, {})

      -- Check if metals or coursier is installed
      local function check_metals_dependency()
        local metals_installed = vim.fn.executable "metals" == 1
        local coursier_installed = vim.fn.executable "cs" == 1 or vim.fn.executable "coursier" == 1

        if not (metals_installed or coursier_installed) then
          vim.notify(
            "Metals requires either 'metals' or 'coursier' to be installed. "
              .. "Please install one of these and add to your PATH, then restart Neovim.",
            vim.log.levels.WARN
          )
        elseif not metals_installed and coursier_installed then
          vim.notify(
            "Metals not found but coursier is available. Run :MetalsInstall to install Metals.",
            vim.log.levels.INFO
          )
        end
      end

      -- Run the check after Neovim starts
      vim.defer_fn(check_metals_dependency, 1000)
    end,
    opts = function()
      local metals_config = require("metals").bare_config()
      local java17_home = "/Users/x.jin/devtools/sdkman/candidates/java/17.0.13-zulu"

      metals_config.root_patterns = {
        "settings.gradle",
        ".bloop",
        ".metals",
        "build.gradle",
        "build.sbt",
        "build.sc",
        "build.mill",
        "build.gradle.kts",
        "pom.xml",
        ".scala-build",
        ".git",
      }
      metals_config.find_root_dir_max_project_nesting = 10
      -- Override the default root directory finder with a custom one
      metals_config.find_root_dir = function(patterns, bufname, max_project_nesting)
        local Path = require "plenary.path"
        local path = Path:new(bufname)

        -- Check for .metals or .bloop directories to prioritize them
        for _, parent in ipairs(path:parents()) do
          local metals_dir = Path:new(parent, ".metals")
          local bloop_dir = Path:new(parent, ".bloop")

          if metals_dir:exists() and bloop_dir:exists() then return parent end

          -- Stop at filesystem root
          if parent == "/" then break end
        end

        -- Fall back to the default finder
        return require("metals.rootdir").find_root_dir(patterns, bufname, max_project_nesting)
      end

      -- Enhanced settings for better Scala development experience
      metals_config.settings = {
        showImplicitArguments = true,
        showImplicitConversionsAndClasses = true,
        showInferredType = true,
        excludedPackages = {
          "akka.actor.typed.javadsl",
          "com.github.swagger.akka.javadsl",
        },
        enableSemanticHighlighting = true,
        metals = {
          javaHome = java17_home,
        },
      }

      -- Add environment variables for Metals
      metals_config.init_options = {
        statusBarProvider = "on",
        -- Add any other init options here
      }

      metals_config.cmd = {
        "env",
        "JAVA_HOME=" .. java17_home,
        metals_config.metals_bin or vim.fn.expand "~/.cache/nvim/nvim-metals/metals",
      }

      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Set up key mappings when metals attaches
      metals_config.on_attach = function(client, bufnr)
        local map = vim.keymap.set
        require("metals").setup_dap()

        -- LSP mappings
        map("n", "gD", vim.lsp.buf.definition)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "gi", vim.lsp.buf.implementation)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "gds", vim.lsp.buf.document_symbol)
        map("n", "gws", vim.lsp.buf.workspace_symbol)
        map("n", "<leader>cl", vim.lsp.codelens.run)
        map("n", "<leader>sh", vim.lsp.buf.signature_help)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>f", vim.lsp.buf.format)
        map("n", "<leader>ca", vim.lsp.buf.code_action)

        map("n", "<leader>ws", function() require("metals").hover_worksheet() end)

        -- all workspace diagnostics
        map("n", "<leader>aa", vim.diagnostic.setqflist)

        -- all workspace errors
        map("n", "<leader>ae", function() vim.diagnostic.setqflist { severity = "E" } end)

        -- all workspace warnings
        map("n", "<leader>aw", function() vim.diagnostic.setqflist { severity = "W" } end)

        -- buffer diagnostics only
        map("n", "<leader>d", vim.diagnostic.setloclist)

        map("n", "[c", function() vim.diagnostic.goto_prev { wrap = false } end)

        map("n", "]c", function() vim.diagnostic.goto_next { wrap = false } end)

        -- Debug and test mappings with nvim-dap
        -- General DAP mappings
        map("n", "<leader>dc", function() require("dap").continue() end)
        map("n", "<leader>dr", function() require("dap").repl.toggle() end)
        map("n", "<leader>dK", function() require("dap.ui.widgets").hover() end)
        map("n", "<leader>dt", function() require("dap").toggle_breakpoint() end)
        map("n", "<leader>dso", function() require("dap").step_over() end)
        map("n", "<leader>dsi", function() require("dap").step_into() end)
        map("n", "<leader>dl", function() require("dap").run_last() end)
      end

      return metals_config
    end,

    config = function(_, opts)
      local metals = require "metals"
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      metals.initialize_or_attach(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function() require("metals").initialize_or_attach(opts) end,
        group = nvim_metals_group,
      })
    end,
  },
}
