local socket = require("socket")  -- Import LuaSocket library for networking

-- Initialize the server
local server = socket.bind("0.0.0.0", 8080)  -- Bind the server to localhost on port 8080
server:settimeout(0)  -- Set the server to non-blocking mode to handle multiple clients efficiently
print("Server started on port 8080...")  -- Notify that the server is running

local clients = {}  -- Store connected clients in a table
local chat = {} -- Store all past messages

-- Function to accept new client connections
function acceptConnection()
    local client = server:accept()  -- Accept a new client connection
    if client then
        client:settimeout(0)  -- Set the client to non-blocking mode for smooth communication
        table.insert(clients, client)  -- Add the client to the list of active connections
        print("New client connected!")  -- Notify that a new client has joined
        printAllClients(clients)
    end
end

-- Function to print all connected clients
function printAllClients(clients)
    print("\n_______Online Clients_______")
    for i, client in ipairs(clients) do
        local ip, port = client:getpeername()
        print("Client " .. i .."\tIP:" .. tostring(ip) .. "\nPort:" .. tostring(port))
    end
end

-- Function to handle communication with connected clients
function handleClients()
    for i, client in ipairs(clients) do
        local input, err = client:receive()  -- Try to receive a message from the client
        if input then
            print("Received: " .. input)  -- Print received message to server console
            broadcastMessage(client, input)  -- Forward the message to all other clients
        elseif err == "closed" then  -- Handle client disconnection
            print("Client disconnected.")  -- Notify that a client has left
            table.remove(clients, i)  -- Remove the client from the active connections list
        end
    end
end

-- Function to send a broadcast message to all connected clients
function broadcastMessage(sender, message)
    for _, client in ipairs(clients) do
        if client ~= sender then  -- Ensure sender doesn’t receive their own message
            client:send("Broadcast: " .. message .. "\n")  -- Send the message to other clients
        end
    end
end

-- Main loop: continuously accept new connections and process client messages
while true do
    acceptConnection()  -- Check for new client connections
    handleClients()  -- Process incoming messages from connected clients
    socket.sleep(0.01)  -- Prevent excessive CPU usage with a short delay
end
