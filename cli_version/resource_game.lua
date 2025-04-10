-- Resource Management Simulator
math.randomseed(os.time())

-- Initialize player stats
local player = {
    money = 100,
    materials = 50,
    food = 50,
    goal = 300 -- Goal: accumulate 300 money
}

-- Function to show player stats
local function showStats()
    print("\n--- Current Stats ---")
    print("Money: " .. player.money)
    print("Materials: " .. player.materials)
    print("Food: " .. player.food)
    print("---------------------\n")
end

-- Function to handle random events
local function randomEvent()
    local event = math.random(1, 3)
    if event == 1 then
        print("You found extra materials! Gain 10 materials.")
        player.materials = player.materials + 10
    elseif event == 2 then
        print("A storm damaged your food supply! Lose 10 food.")
        player.food = player.food - 10
    elseif event == 3 then
        print("You sold goods for profit! Gain 20 money.")
        player.money = player.money + 20
    end
end

-- Game loop
local function gameLoop()
    while player.money < player.goal and player.food > 0 and player.materials > 0 do
        showStats()
        print("Choose an action:")
        print("1. Work (Spend 10 food and materials, Gain 30 money)")
        print("2. Trade (Spend 20 money, Gain 15 food)")
        print("3. Collect (Spend 5 money, Gain 20 materials)")
        local choice = io.read("*n") -- Read player choice

        if choice == 1 then
            print("\nYou worked hard and earned money.")
            player.money = player.money + 30
            player.food = player.food - 10
            player.materials = player.materials - 10
        elseif choice == 2 then
            print("\nYou traded money for food.")
            if player.money >= 20 then
                player.money = player.money - 20
                player.food = player.food + 15
            else
                print("Not enough money to trade!")
            end
        elseif choice == 3 then
            print("\nYou collected extra materials.")
            if player.money >= 5 then
                player.money = player.money - 5
                player.materials = player.materials + 20
            else
                print("Not enough money to collect materials!")
            end
        else
            print("\nInvalid choice! Try again.")
        end

        randomEvent() -- Trigger a random event
    end

    -- Game ending conditions
    if player.money >= player.goal then
        print("\nCongratulations! You've achieved your goal!")
    elseif player.food <= 0 or player.materials <= 0 then
        print("\nGame Over. You ran out of resources.")
    end
end

-- Start the game
print("Welcome to the Resource Management Simulator!")
gameLoop()