-- Import LuaSocket library for networking
local socket = require("socket")

-- Initialize the server
local server = socket.bind("0.0.0.0", 8080)  -- Bind the server to all network interfaces on port 8080
server:settimeout(0)  -- Set the server to non-blocking mode to handle multiple clients efficiently
print("Server started on port 8080...")  -- Notify that the server is running

-- Table to store connected clients
local clients = {}

-- Table to store all past messages (not currently used in the code)
local chat = {}

-- Function to accept new client connections
function acceptConnection()
    local client = server:accept()  -- Accept a new client connection
    if client then
        client:settimeout(0)  -- Set the client to non-blocking mode for smooth communication
        table.insert(clients, client)  -- Add the client to the list of active connections
        print("New client connected!")  -- Notify that a new client has joined
        printAllClients(clients)  -- Print the list of all connected clients

        -- Send the client's IP and port back to them
        local client_ip, client_port = client:getpeername()
        client:send(tostring(client_ip) .. ":" .. tostring(client_port) .. "\n")  -- Inform the client of their IP and port
    end
end

-- Function to print all connected clients
function printAllClients(clients)
    print("\n_______Online Clients_______")  -- Header for the list of connected clients
    for i, client in ipairs(clients) do
        local ip, port = client:getpeername()  -- Get the IP and port of each client
        print("Client " .. i .. "\tIP:" .. tostring(ip) .. "\nPort:" .. tostring(port))  -- Print client details
    end
end

-- Function to handle communication with connected clients
function handleClients()
    for i, client in ipairs(clients) do
        local input, err = client:receive()  -- Try to receive a message from the client
        if input then
            print("Received: " .. input)  -- Print the received message to the server console
            broadcastMessage(client, input)  -- Forward the message to all other connected clients
        elseif err == "closed" then  -- Handle client disconnection
            print("Client disconnected.")  -- Notify that a client has disconnected
            table.remove(clients, i)  -- Remove the client from the list of active connections
        end
    end
end

-- Function to send a broadcast message to all connected clients
function broadcastMessage(sender, message)
    local sender_ip, sender_port = sender:getpeername()  -- Get the sender's IP and port
    local formatted_message = "[" .. tostring(sender_ip) .. ":" .. tostring(sender_port) .. "]: " .. message  -- Format the message with sender's info

    for _, client in ipairs(clients) do
        if client ~= sender then  -- Ensure the sender doesn’t receive their own message
            client:send(formatted_message .. "\n")  -- Send the formatted message to other clients
        end
    end
end

-- Main loop: continuously accept new connections and process client messages
while true do
    acceptConnection()  -- Check for new client connections
    handleClients()  -- Process incoming messages from connected clients
    socket.sleep(0.01)  -- Prevent excessive CPU usage with a short delay
end