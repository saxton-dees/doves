local common = {}

function common.serializeMessage(command, content)
    return command .. " |" .. content -- Example delimiter-based format
end

function common.deserializeMessage(message)
    local parts = {}
    for part in string.gmatch(message, "[^|]+") do
        table.insert(parts, part)
    end
    return { command = parts[1], content = parts[2] }
end

return common