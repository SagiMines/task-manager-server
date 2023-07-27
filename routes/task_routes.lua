local Task = require("models.task")
local jwt = require("utils.jwt")
local helper_functions = require("utils.helper_functions")
local json = require('cjson')
local TaskRoutes = {}

-- POST: /task
function TaskRoutes.create_task(self)
  local verify_user = jwt.verify_token(self.cookies.token, os.getenv("JWT_SECRET"))
  if(verify_user[1]) then
    local decodedBody = helper_functions.get_decoded_request_body(self.POST)
    local title = decodedBody.title
    local description = decodedBody.description
    local completed = decodedBody.completed
    local userId = decodedBody.userId
    if(verify_user[2].payload.id == userId) then
      if(type(title) == "string" and type(description) == 'string' and type(completed) == "boolean") then
        
        local res = Task:create(decodedBody)
        if not res then
          return {status = 409, json = {error = "Could not create a new task."}}
        end
    
        return {status = 200, json = res }

      end
      return {status = 400, json = {error = "Invalid credentials."}}
    end
  end
  return {status = 401, json = {error = "Unauthorized request."}}
end

-- GET: /tasks
function TaskRoutes.retrieve_all_tasks(self)
  local res = {}
  local userId = self.GET.userId

  -- verify the JWT
  local verify_user = jwt.verify_token(self.cookies.token, os.getenv("JWT_SECRET"))
  if(verify_user[1]) then
    if userId then
      if(verify_user[2].payload.id == tonumber(userId)) then
        res = Task:select('where "userId" = ?', userId)
      end
    else
      res = Task:select()
    end
  else 
    return {status = 401, json = {error = "Unauthorized request."}}
  end

  return {status = 200, json = res}
end

-- GET: /task/:id
function TaskRoutes.retrieve_specific_task(self)
  local verify_user = jwt.verify_token(self.cookies.token, os.getenv("JWT_SECRET"))
  if(verify_user[1]) then

    local task_id = self.params.id
    local res = Task:find(task_id)
    if not res then
      return {status = 404, json = {error = "No such task exists with the id of: " .. task_id}}
    end

    return {status = 200, json = res}
  else
    return {status = 401, json = {error = "Unauthorized request."}}
  end
end

-- PUT: /task/:id
function TaskRoutes.update_specific_task(self)
  local task_id = self.params.id
  local verify_user = jwt.verify_token(self.cookies.token, os.getenv("JWT_SECRET"))
  if(verify_user[1]) then
    local task = Task:find(task_id)
    if not task then
      return {status = 404, json = {error = "No such task exists with the id of: " .. task_id}}
    end
    local decodedBody = helper_functions.get_decoded_request_body(self.POST)

    local title = decodedBody.title
    local description = decodedBody.description
    local completed = decodedBody.completed
    local userId = decodedBody.userId
    local id = decodedBody.id

    if(verify_user[2].payload.id == task.userId and task.userId == userId) then

      if(type(title) == "string" and type(description) == 'string' and type(completed) == "boolean" and type(id) == "number") then 
        task:update(decodedBody)
        return {status = 200, json = task }
      end
      return {status = 400, json = {error = "Invalid credentials."}}
    end
  end
  return {status = 401, json = {error = "Unauthenticated request"}}
end

-- DELETE: /task/:id
function TaskRoutes.delete_specific_task(self)
  local task_id = self.params.id
  local task = Task:find(task_id)
  local verify_user = jwt.verify_token(self.cookies.token, os.getenv("JWT_SECRET"))
  if not task then
    return {status = 404, json = {error = "No such task exists with the id of: " .. task_id}}
  end

  if(verify_user[2].payload.id == task.userId) then
    task:delete()
    return {status = 200, json = task }
  end

  return {status = 401, json = { error = "Unauthorized user."}}

end

return TaskRoutes