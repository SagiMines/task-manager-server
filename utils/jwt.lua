local jwt = require("resty.jwt")

local _M = {}

-- Function to create a JWT
function _M.create_token(payload, secret_key, algorithm, expiration)
    -- Set the default algorithm to "HS256" (HMAC-SHA256)
    algorithm = algorithm or "HS256"

    -- Create the JWT
    local token, err = jwt:sign(secret_key, {
        header = { typ = "JWT", alg = algorithm },
        payload = payload,
        exp = expiration,
    })

    if err then
        return nil, err
    end

    return token
end

-- Function to verify a JWT
function _M.verify_token(token, secret_key)
    local claims, err = jwt:verify(secret_key, token)

    if not claims then
        return false, err
    end

    return true, claims
end

return _M
