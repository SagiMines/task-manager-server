local User = require("models.user")
local bcrypt = require("bcrypt")
local jwt = require("utils.jwt")
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
    local username = self.POST.username
    local password = self.POST.password
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
                    error("Error creating JWT: ", err)
                    return
                end

                return {json = {token = token}}
            end
        else
            error("User does not exists.")
        end  
    end
    error("Invalid credentials")
end

return UserRoutes

