local Model = require("lapis.db.model").Model

-- Define the 'user' model
local User = Model:extend("users", {
  primary_key = "id",
  fields = {
    { "username", "text" },
    { "password", "text" },
  },

  relations = {
    -- Define any relations if needed
  }
})

return User