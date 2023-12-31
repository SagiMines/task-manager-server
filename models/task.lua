local Model = require("lapis.db.model").Model

-- Define the 'task' model
local Task = Model:extend("tasks", {
  primary_key = "id",
  fields = {
    { "id", "number" },
    { "title", "text" },
    { "description", "text" },
    { "completed", "boolean" },
    { "userId", "number" },
  },

  relations = {
    {"userId", belongs_to = "User"}
  }
})

return Task