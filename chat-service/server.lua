local socket = require("socket")

-- Start server
local server = socket.bind("127.0.0.1", 8080)
server:settimeout(0) -- Non-blocking mode
print("Server started on port 8080...")

local clients = {}

function acceptConnection()
    local client = server:accept()
    if client then
        client:settimeout(0)
        table.insert(clients, client)
        print("New client connected!")
    end
end

function handleClients()
    for i, client in ipairs(clients) do
        local input, err = client:receive()
        if input then
            print("Received: " .. input)
            broadcastMessage(client, input)
        elseif err == "closed" then
            print("Client disconnected.")
            table.remove(clients, i)
        end
    end
end

function broadcastMessage(sender, message)
    for _, client in ipairs(clients) do
        if client ~= sender then
            client:send("Broadcast: " .. message .. "\n")
        end
    end
end

while true do
    acceptConnection()
    handleClients()
    socket.sleep(0.01) -- Reduce CPU usage
end