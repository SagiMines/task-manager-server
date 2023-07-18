package.path = package.path .. ";./routes/?.lua"
local lapis = require("lapis")
local app = lapis.Application()
local task_routes = require("routes.task_routes")

app:post("/task", task_routes.create_task)
app:get("/tasks", task_routes.retrieve_all_tasks)
app:get("/task/:id", task_routes.retrieve_specific_task)
app:put("/task/:id", task_routes.update_specific_task)
app:delete("/task/:id", task_routes.delete_specific_task)

return app
