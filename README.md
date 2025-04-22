# **Chat Service (Lua 5.3)**
A simple chat service implemented in **Lua 5.3** using **LuaSocket** for client-server communication.

## **Dependencies**
- **Lua 5.3**
- **LuaSocket** (`lua5.3-socket` for Ubuntu/Linux)

## **Installation**
### **Install Lua 5.3**
```bash
sudo apt update
sudo apt install lua5.3
```

### **Install LuaSocket**
```bash
sudo apt install lua-socket
```

## **Usage**
### **Start the Server**
**All of the following commands must be down in the `chat-service` dir**
In one terminal start the server with:
```bash
lua server.lua
```
Now start a couple clients with:
### **Start the Client**
```bash
lua client.lua
```

Then send messages back and forth.
### **Send Messages**
- Use `/send <message>` to send a message.
- Type `/exit` to disconnect from the server.

