local socket = require("socket")  -- Import LuaSocket for networking

-- Establish connection to the server
local client = socket.tcp()  -- Create a TCP client socket
client:connect("127.0.0.1", 8080)  -- Connect to the server at localhost, port 8080

-- Function to process user input commands
function processInput(input)
    -- Check if input starts with "/send" (indicating a message)
    if string.sub(input, 1, 5) == "/send" then
        local message = string.sub(input, 7)  -- Extract the message after "/send"
        if message == "" then
            print("Error: Message cannot be empty.")  -- Prevent sending empty messages
        else
            return { command = "send", message = message }  -- Return structured message
        end
    elseif input == "/exit" then
        return { command = "exit" }  -- Handle client disconnect request
    else
        print("Error: Invalid command. Use /send <message> or /exit.")  -- Notify of invalid input
    end
end

-- Inform user of chat usage
print("Connected to server. Type /send <message> to chat.")

-- Main loop to handle user input and interaction
while true do
    local input = io.read()  -- Read user input from console
    local result = processInput(input)  -- Process input command

    if result then
        if result.command == "send" then
            client:send(result.message .. "\n")  -- Send formatted message to server
        elseif result.command == "exit" then
            print("Closing connection...")  -- Notify of disconnect
            client:close()  -- Close client connection
            break  -- Exit the loop
        end
    end
end