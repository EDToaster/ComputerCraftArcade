os.loadAPI("logger")
os.loadAPI("point_api")

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
    mon.setTextScale(.75)
    mon.setCursorPos(1, 1)
    mon.clear()
end 

local d

local function state_insert_card()
    clear_mon(mon)
    
    mon.write("Please Insert")
    mon.setCursorPos(1, 2)
    mon.write("an arcade card")

    d = point_api.wait_for_disk(config.drive_name, point_types)
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

    local event, button, x, y = os.pullEvent("monitor_touch")

    if event == "monitor_touch" then
        return 2
    elseif event == "disk_eject" then
        return 1
    end
end

local state_functions = { state_insert_card, state_ask_operation }

--[[
    State Machine

    1. Wait for Card to be inserted.    On disk event, goto 2
    2. Ask operation type
    3. Print balance
    4. Deposit
    5. Withdraw
--]]

-- initial state is 1
local state = 2

function loop()

    local state_function = state_functions[state]
    state = state_function()


    
    -- -- ask deposit or withdraw
    -- -- wait for click
    -- local do_deposit = y <= 5
    -- -- deposit
    -- if do_deposit then
    --     for i, item in pairs(user_storage.list()) do
    --         for j, type in ipairs(point_types) do
    --             if type == item.name then
    --                 user_storage.pushItems(config.host_storage, i)
    --                 d.add(type, item.count)
    --                 break
    --             end
    --         end
    --     end
    --     clear_mon(mon)
    --     mon.write("Balance: ")
    --     mon.setCursorPos(1, 2)
    --     mon.write(""..d.read("minecraft:diamond"))
    -- else
    --     for i, item in ipairs(point_types) do
    --         local num_to_pull = d.read(item)
    --         while num_to_pull > 0 do
    --             local items_pulled = 
    --                 host_storage.pushItems(
    --                     config.user_storage,
    --                     i+9, num_to_pull)
    --             d.add(item, -items_pulled)
    --             print("Pulled "..items_pulled.." items")
    --             num_to_pull = d.read(item)
    --         end
    --     end
    --     clear_mon(mon)
    --     mon.write("Finished!")
    -- end
    -- -- wait for disk_empty event
    -- os.pullEvent("disk_eject")
    
end


while true do loop() end
