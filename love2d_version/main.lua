-- main.lua (Love2D version)
function love.load()
    -- Initialize player stats
    player = { money = 100, materials = 50, food = 50 }
    goal = 300

    message = "Welcome to the Resource Manager!"
end

function love.draw()
    -- Display resources
    love.graphics.print("Money: " .. player.money, 10, 10)
    love.graphics.print("Materials: " .. player.materials, 10, 30)
    love.graphics.print("Food: " .. player.food, 10, 50)
    love.graphics.print(message, 10, 90)

    -- Instructions
    love.graphics.print("Press 1 to Work | Press 2 to Trade | Press 3 to Collect", 10, 130)
end

function love.keypressed(key)
    if key == "1" then
        if player.food >= 10 and player.materials >= 10 then
            player.money = player.money + 30
            player.food = player.food - 10
            player.materials = player.materials - 10
            message = "You worked and earned money!"
        else
            message = "Not enough food or materials to work!"
        end
    elseif key == "2" then
        if player.money >= 20 then
            player.money = player.money - 20
            player.food = player.food + 15
            message = "You traded money for food!"
        else
            message = "Not enough money to trade!"
        end
    elseif key == "3" then
        if player.money >= 5 then
            player.money = player.money - 5
            player.materials = player.materials + 20
            message = "You collected materials!"
        else
            message = "Not enough money to collect materials!"
        end
    end
end