local dir = shell.dir()
os.loadAPI(dir.."/api/point")


--[[
    Computer Craft Arcade points loader
    Author: EDToaster


    Made for a 29x5 monitor
--]]

local config = {
    drive_name="drive_0",
    monitor_name="monitor_1",
    host_storage="refinedstorage:interface_1",
    user_storage="minecraft:barrel_2",
}

local point_types = { "minecraft:diamond", }

local user_storage = peripheral.wrap(config.user_storage)
local host_storage = peripheral.wrap(config.host_storage)
local mon = peripheral.wrap(config.monitor_name)

function clear_mon(mon) 
    mon.setBackgroundColor(colors.black)
    mon.setTextScale(1)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, 1)
    mon.clear()
end 

local d

local function state_insert_card()
    clear_mon(mon)
    
    mon.write("Please Insert")
    mon.setCursorPos(1, 2)
    mon.write("an arcade card")

    d = point.wait_for_disk(config.drive_name, point_types)
    return 2
end

local function state_ask_operation()
    clear_mon(mon)

    -- draw backgrounds
    for x=1,29 do
        for y=1,5 do
            local col
            mon.setCursorPos(x, y)

            if x == 1 or x == 10 or x == 20 or x == 29 or y == 1 or y == 5 then 
                col = colors.black
            else 
                col = colors.green
            end

            mon.setBackgroundColor(col)
            mon.write(" ")
        end
    end

    mon.setBackgroundColor(colors.green)
    mon.setTextColor(colors.white)

    -- draw text
    mon.setCursorPos(2, 3)
    mon.write("Balance")
    mon.setCursorPos(12, 3)
    mon.write("Deposit")
    mon.setCursorPos(21, 3)
    mon.write("Withdraw")

    local event, button, x, y = os.pullEvent()

    if event == "monitor_touch" then
        -- check for x position to get which button was pressed
        if x < 10 then
            return 3
        elseif x < 20 then
            return 4
        else 
            return 5
        end
    elseif event == "disk_eject" then
        return 1
    end
end

local function state_balance()
    clear_mon(mon)
    mon.write("Balance: ")

    local y = 2
    for i, type in ipairs(point_types) do
        mon.setCursorPos(1, y)
        mon.setTextColor(colors.lightBlue)
        mon.write(type..": "..d.read(type))
        y = y + 1
    end

    mon.setTextColor(colors.white)
    mon.setCursorPos(1, y)
    mon.write("Please withdraw your card")
    os.pullEvent("disk_eject")
    return 1
end

local function state_deposit()
    clear_mon(mon)
    mon.write("Depositing ...")

    local finished = false
    while not finished do
        local pulled_items = false
        for i, item in pairs(user_storage.list()) do
            for j, type in ipairs(point_types) do
                if type == item.name then
                    user_storage.pushItems(config.host_storage, i)
                    d.add(type, item.count)
                    pulled_items = true
                    break
                end
            end
        end

        finished = not pulled_items
    end

    clear_mon(mon)
    mon.write("Finished Depositing")
    mon.setCursorPos(1, 2)
    mon.write("Please withdraw your card")
    os.pullEvent("disk_eject")
    return 1
end

local function state_withdraw()
    clear_mon(mon)
    mon.write("Withdrawing ...")

    for i, item in ipairs(point_types) do
        local num_to_pull = d.read(item)
        while num_to_pull > 0 do
            local items_pulled = 
                host_storage.pushItems(
                    config.user_storage,
                    i+9, num_to_pull)
            d.add(item, -items_pulled)
            num_to_pull = d.read(item)
        end
    end
    clear_mon(mon)
    mon.write("Finished Withdrawing")
    mon.setCursorPos(1, 2)
    mon.write("Please withdraw your card")
    os.pullEvent("disk_eject")
    return 1
end

local state_functions = { state_insert_card, state_ask_operation, state_balance, state_deposit, state_withdraw }

--[[
    State Machine

    1. Wait for Card to be inserted.    On disk event, goto 2
    2. Ask operation type
    3. Print balance
    4. Deposit
    5. Withdraw
--]]

-- initial state is 1
local state = 1

function loop()
    local state_function = state_functions[state]
    state = state_function()
end


while true do loop() end
