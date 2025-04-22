-- Define a module named 'common' that will hold shared utility functions
local common = {}

-- Function to serialize a message into a standard format
-- This combines a command and content into a single string with a delimiter (`|`)
function common.serializeMessage(command, content)
    return command .. " |" .. content  -- Format: "COMMAND | CONTENT"
end

-- Function to deserialize a message back into its components
-- This splits a received message string into command and content based on the `|` delimiter
function common.deserializeMessage(message)
    local parts = {}  -- Table to store extracted parts
    for part in string.gmatch(message, "[^|]+") do  -- Extract substrings separated by `|`
        table.insert(parts, part)  -- Add each extracted part to the table
    end
    return { command = parts[1], content = parts[2] }  -- Return structured data
end

-- Return the module so other scripts can require and use its functions
return common