require("utils.lua_paths")
local lapis = require("lapis")
local app = lapis.Application()

-- routes functions
local task_routes = require("routes.task_routes")
local user_routes = require("routes.user_routes")

-- tasks routes
app:post("/task", task_routes.create_task)
app:get("/tasks", task_routes.retrieve_all_tasks)
app:get("/task/:id", task_routes.retrieve_specific_task)
app:put("/task/:id", task_routes.update_specific_task)
app:delete("/task/:id", task_routes.delete_specific_task)

-- users routes
app:post("/users", user_routes.create_user)
app:post("/auth", user_routes.authenticate_user)

return app
