local json = require('cjson')
local helper = {}
-- decodes the request body to a table
function helper.get_decoded_request_body(requestBody)
    local keys = {}
        for key, _ in pairs(requestBody) do
        table.insert(keys, key)
        end
        local decodedBody = json.decode(keys[1])
        return decodedBody
end

return helper