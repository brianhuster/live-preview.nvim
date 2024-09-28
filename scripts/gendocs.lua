local docgen = require('docgen')

local docs = {}

docs.test = function()
  -- Filepaths that should generate docs
  local input_files = {
    "./lua/live-preview/init.lua",
    "./lua/live-preview/server.lua",
    "./lua/live-preview/utils.lua",
    "./lua/live-preview/health.lua",
    "./lua/telescope/previewers/spec.lua",
  }


  -- Output file
  local output_file = "./doc/live-preview.txt"
  local output_file_handle = io.open(output_file, "w")

  for _, input_file in ipairs(input_files) do
    docgen.write(input_file, output_file_handle)
  end

  output_file_handle:write(" vim:tw=78:ts=8:ft=help:norl:\n")
  output_file_handle:close()
  vim.cmd [[checktime]]
end

docs.test()

return docs
