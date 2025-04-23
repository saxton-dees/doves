local socket = require("socket")
local lua_pid = require("lua_pid")  -- Your C wrapper for fork

-- Connect to the server
local client = socket.tcp()
client:connect("127.0.0.0", 8080)

print("Connection to server successful!\nType a message and hit ENTER to chat!\nType /exit to disconnect.\n")

-- Global variable to store the client's IP and port
local prompt_prefix = "Unknown"

-- Read the server's message containing the client's IP and port
local server_message, err = client:receive()
if server_message then
    prompt_prefix = server_message  -- Save the IP and port to the global variable
end

-- Fork the process
local pid = tonumber(lua_pid.lua_fork())

-- Function to process user input commands
function processInput(input)
    if input == "/exit" then
        return { command = "exit" }  -- Handle client disconnect request
    elseif input ~= "" then
        return { command = "send", message = input }  -- Treat any non-empty input as a message
    else
        print("Error: Message cannot be empty.")  -- Prevent sending empty messages
    end
end

if pid == 0 then
    -- CHILD PROCESS: Handle user input
    while true do
        io.write("[" .. prompt_prefix .. "]: ")  -- Use the global prompt_prefix
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
                io.write("\n" .. message .. "\n")  -- Print the received message
                io.write("[" .. prompt_prefix .. "]: ")  -- Reprint the prompt using the global prompt_prefix
                io.flush()
            else
                -- Handle disconnection errors
                print("Server connection lost.")
                os.execute(string.format("kill -9 %d", pid))
                os.exit(1)
            end
        end
    end
end