local User = require("models.user")
local bcrypt = require("bcrypt")
local jwt = require("utils.jwt")
local helper_functions = require("utils.helper_functions")
local UserRoutes = {}

-- POST: /users
function UserRoutes.create_user(self)
    local username = self.POST.username
    local password = self.POST.password
    if type(username) == "string" and type(password) == "string" then
        -- check if there isn't another user with the same username
        local isUserExists = User:find({username = username})
        if isUserExists then
            return {status = 400, json = {"A user with the same username already exists."}}
        end

        -- hash the password
        self.POST.password = bcrypt.digest(password, os.getenv("HASH_ROUNDS"))

        local res = User:create(self.POST)

        if not res then
          return {status = 409, json = {error = "Could not create a new user."}}
        end
      
        return {status = 200, json = res } 
    end
    return {status = 401, json = {error = "Invalid credentials"}}
end

-- POST: /check-token
function UserRoutes.check_token(self)
    local res
    if(self.cookies.token) then
        res = jwt.verify_token(self.cookies.token,os.getenv("JWT_SECRET"))
        return {status = 200, json = {userId = res[2].payload.id}}
    else
        return {status = 404, json = {userId = nil}}
    end
end

-- POST: /auth
function UserRoutes.authenticate_user(self)
    local decodedBody = helper_functions.get_decoded_request_body(self.POST)
    local username = decodedBody.username
    local password = decodedBody.password
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
                
                -- setting a secure http only cookie
                self.cookies.token = token
                local verify_jwt = jwt.verify_token(token,os.getenv("JWT_SECRET"))
                return {status = 200, json = {userId = verify_jwt[2].payload.id}}
            end
        else
            return {status = 404, json = {error = "Invalid username or password"}}
        end  
    end
    return {status = 400, json = {error = "Invalid credentials"}}
end

return UserRoutes

