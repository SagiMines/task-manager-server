local User = require("models.user")
local bcrypt = require("bcrypt")
local jwt = require("utils.jwt")
local json = require('cjson')
local UserRoutes = {}

-- POST: /users
function UserRoutes.create_user(self)
    local username = self.POST.username
    local password = self.POST.password
    if type(username) == "string" and type(password) == "string" then
        -- check if there is not another user with the same username
        local isUserExists = User:find({username = username})
        if isUserExists then
            error("A user with the same username already exists.")
        end

        -- hash the password
        self.POST.password = bcrypt.digest(password, os.getenv("HASH_ROUNDS"))

        local res = User:create(self.POST)

        if not res then
          error("Could not create a new user.")
        end
      
        return { json = res } 
    end
    error("Invalid credentials")
end

-- POST: /auth
function UserRoutes.authenticate_user(self)
    local keys = {}
    for key, _ in pairs(self.POST) do
    table.insert(keys, key)
    end
    local decodedBody = json.decode(keys[1])
    local username = decodedBody.username
    local password = decodedBody.password
    print(username)
    print(password)
    if type(username) == "string" and type(password) == "string" then
        local isUserExists = User:find({username = username})
        if isUserExists then
            local isPasswordTheSame = bcrypt.verify( password, isUserExists.password )
            if isPasswordTheSame then
                -- JWT payload
                local payload = {
                    id = isUserExists.id,
                    username = isUserExists.username 
                }
                -- 1 year expiration time
                local expiration = ngx.time() + (365 * 24 * 60 * 60)
                -- Create the JWT
                local token, err = jwt.create_token(payload, os.getenv("JWT_SECRET"), "HS256", expiration)

                if err then
                    -- Failed to create the JWT
                    return {status = 400, json = {error = "Bad Request: " .. err}}
                end

                return {json = {token = token}}
            end
        else
            return {status = 404, json = {error = "Invalid username or password"}}
        end  
    end
    return {status = 400, json = {error = "Invalid credentials"}}
end

return UserRoutes

