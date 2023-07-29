local User = require("models.user")
local bcrypt = require("bcrypt")
local jwt = require("utils.jwt")
local helper_functions = require("utils.helper_functions")
local UserRoutes = {}

-- POST: /users
function UserRoutes.create_user(self)
    local decodedBody = helper_functions.get_decoded_request_body(self.POST)
    local username = decodedBody.username
    local password = decodedBody.password
    local confirmPassword = decodedBody.password
    if type(username) == "string" and type(password) == "string" and type(confirmPassword) == 'string' then
        
        -- Check if password and cofirm password are equal
         if(password ~= confirmPassword) then
            return {status = 400, json = {error = "The 'Confirm Password' section is not equal to the 'Password' section"}}
        end

        -- check if there isn't another user with the same username
        local isUserExists = User:find({username = username})
        if isUserExists then
            return {status = 400, json = {error = "A user with the same username already exists."}}
        end
        
        -- hash the password
        decodedBody.password = bcrypt.digest(password, os.getenv("HASH_ROUNDS"))

        local res = User:create({username = decodedBody.username, password = decodedBody.password})
        if not res then
          return {status = 409, json = {error = "Could not create a new user."}}
        end

        -- JWT payload
        local payload = {
            id = res.id,
            username = res.username 
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
        if(verify_jwt[1]) then
            return {status = 200, json = res } 
        end
        return {status = 409, json = {error = verify_jwt[2]}}
        
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
        return {status = 200, json = {userId = 0}}
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


function UserRoutes.logout(self) 
    local verify_jwt = jwt.verify_token(self.cookies.token,os.getenv("JWT_SECRET"))
    
    if(verify_jwt[1]) then
        ngx.header['Set-Cookie'] = 'token=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT'
        return {status = 200, json = {done = true}} 
    end
    return {status = 400, json = {error = "No token was found."}} 

end


return UserRoutes

