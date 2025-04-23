local socket = require("socket")
local lua_pid = require("lua_pid")  -- Your C wrapper for fork

-- Connect to the server
local client = socket.tcp()
client:connect("127.0.0.1", 8080)

print("Connected to server. Type /send <message> to chat.")

-- Fork the process
local pid = tonumber(lua_pid.lua_fork())

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


if pid == 0 then
    -- CHILD PROCESS: Handle user input
    while true do
        io.write("> ")  -- Optional: prompt symbol
        local input = io.read()
        local result = processInput(input)

        if result then
            if result.command == "send" then
                client:send(result.message .. "\n")
            elseif result.command == "exit" then
                print("Exiting...")
                client:close()
                os.exit(0)
            end
        end
    end
else
    -- PARENT PROCESS: Handle server messages
    print("Child PID", pid)
    while true do
        local waitpid_result = lua_pid.lua_waitpid(pid)
        if waitpid_result == pid then
            break
        end
        local clients = socket.select({client}, nil, 0.1)
        for _, client in ipairs(clients) do
            local message, err = client:receive()
            if not err then
                io.write("\nBroadcast: " .. message .. "\n> ")  -- Print message, prompt again
                io.flush()
            else
                -- You can handle disconnection errors here
                print("Server connection lost.")
                os.exit(1)
            end
        end
    end
end
