local socket = require("socket")

-- Connect to the server
local client = socket.tcp()
client:connect("127.0.0.1", 8080)

function processInput(input)
    if string.sub(input, 1, 5) == "/send" then
        local message = string.sub(input, 7)
        if message == "" then
            print("Error: Message cannot be empty.")
        else
            return { command = "send", message = message }
        end
    elseif input == "/exit" then
        return { command = "exit" }
    else
        print("Error: Invalid command. Use /send <message> or /exit.")
    end
end

print("Connected to server. Type /send <message> to chat.")
while true do
    local input = io.read()
    local result = processInput(input)
    if result then
        if result.command == "send" then
            client:send(result.message .. "\n")
        elseif result.command == "exit" then
            print("Closing connection...")
            client:close()
            break
        end
    end
end