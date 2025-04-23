-- Import the LuaSocket library for networking functionality
local socket = require("socket")

-- Import a custom Lua module for process management (assumes a C wrapper for `fork`)
local lua_pid = require("lua_pid")

-- Create a TCP client socket
local client = socket.tcp()

-- Connect the client to the server at IP address 127.0.0.0 and port 8080
client:connect("127.0.0.0", 8080)

-- Print instructions for the user on how to interact with the chat application
print("Connection to server successful!\nType a message and hit ENTER to chat!\nType /exit to disconnect.\n")

-- Initialize a global variable to store the client's IP and port, defaulting to "Unknown"
local prompt_prefix = "Unknown"

-- Attempt to receive a message from the server (expected to contain the client's IP and port)
local server_message, err = client:receive()
if server_message then
    -- If a message is received, store it in the global variable `prompt_prefix`
    prompt_prefix = server_message
end

-- Fork the current process into a parent and child process
local pid = tonumber(lua_pid.lua_fork())

-- Define a function to process user input and determine the appropriate action
function processInput(input)
    if input == "/exit" then
        -- If the user types "/exit", return a command to disconnect
        return { command = "exit" }
    elseif input ~= "" then
        -- If the input is not empty, return a command to send the message
        return { command = "send", message = input }
    else
        -- If the input is empty, print an error message
        print("Error: Message cannot be empty.")
    end
end

-- Check if the current process is the child process
if pid == 0 then
    -- CHILD PROCESS: Responsible for handling user input
    while true do
        -- Display a prompt using the client's IP and port (stored in `prompt_prefix`)
        io.write("[" .. prompt_prefix .. "]: ")
        -- Read user input from the console
        local input = io.read()
        -- Process the input to determine the action
        local result = processInput(input)

        if result then
            if result.command == "send" then
                -- If the command is "send", send the message to the server
                client:send(result.message .. "\n")
            elseif result.command == "exit" then
                -- If the command is "exit", close the connection and terminate the process
                print("Exiting...")
                client:close()
                os.exit(0)
            end
        end
    end
else
    -- PARENT PROCESS: Responsible for handling messages from the server
    print("Child PID", pid) -- Print the PID of the child process for debugging purposes
    while true do
        -- Wait for the child process to terminate
        local waitpid_result = lua_pid.lua_waitpid(pid)
        if waitpid_result == pid then
            -- If the child process has terminated, exit the loop
            break
        end

        -- Use `socket.select` to check if the server has sent any messages
        local clients = socket.select({client}, nil, 0.1)
        for _, client in ipairs(clients) do
            -- Attempt to receive a message from the server
            local message, err = client:receive()
            if not err then
                -- If a message is received, print it to the console
                io.write("\n" .. message .. "\n")
                -- Reprint the prompt for the user
                io.write("[" .. prompt_prefix .. "]: ")
                io.flush()
            else
                -- If an error occurs (e.g., server disconnects), handle it
                print("Server connection lost.")
                -- Kill the child process to clean up
                os.execute(string.format("kill -9 %d", pid))
                -- Exit the parent process with an error code
                os.exit(1)
            end
        end
    end
end