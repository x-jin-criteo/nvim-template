return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"

      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "RunOrTest",
          metals = {
            runType = "runOrTestFile",
          },
        },
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = {
            runType = "testTarget",
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
