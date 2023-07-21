local Task = require("models.task")
local TaskRoutes = {}

-- POST: /task
function TaskRoutes.create_task(self)
  local res = Task:create(self.POST)
  -- add check if user exists
  if not res then
    error("Could not create a new task.")
  end

  return { json = res }
end

-- GET: /tasks
function TaskRoutes.retrieve_all_tasks(self)
  local res
  local userId = self.GET.userId
  if userId then
    res = Task:select('where "userId" = ?', userId)
  else
    res = Task:select()
  end
  if not res then
    error("There are no tasks available.")
  end

  return {json = res}
end

-- GET: /task/:id
function TaskRoutes.retrieve_specific_task(self)
  local task_id = self.params.id
  local res = Task:find(task_id)
  if not res then
    error("No such task exists with the id of: " .. task_id)
  end

  return {json = res}
end

-- PUT: /task/:id
function TaskRoutes.update_specific_task(self)
  local task_id = self.params.id
  
  local task = Task:find(task_id)
  if not task then
    error("No such task exists with the id of: " .. task_id)
  end

  task:update(self.POST)

  return { json = task }
end

-- DELETE: /task/:id
function TaskRoutes.delete_specific_task(self)
  local task_id = self.params.id
  
  local task = Task:find(task_id)
  if not task then
    error("No such task exists with the id of: " .. task_id)
  end

  task:delete()

  return { json = task }
end

return TaskRoutes