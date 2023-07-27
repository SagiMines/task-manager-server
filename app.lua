require("utils.lua_paths")
local jwt = require("utils.jwt")
local lapis = require("lapis")
local app = lapis.Application()
local respond_to = require("lapis.application").respond_to

-- setting up the JWT's cookie attributes
app.cookie_attributes = jwt.set_jwt_cookie

-- routes functions
local task_routes = require("routes.task_routes")
local user_routes = require("routes.user_routes")

-- tasks routes
app:post("/task", task_routes.create_task)
app:get("/tasks", task_routes.retrieve_all_tasks)
app:match("/task/:id", respond_to({
  OPTIONS = function(self)
      self.res.headers["Access-Control-Allow-Origin"] = "http://localhost:3000"
  end,
  GET = task_routes.retrieve_specific_task,
  PUT = task_routes.update_specific_task,
  DELETE = task_routes.delete_specific_task
}))

-- users routes
app:post("/users", user_routes.create_user)
app:post("/auth",user_routes.authenticate_user)
app:get("/check-token", user_routes.check_token)

return app
