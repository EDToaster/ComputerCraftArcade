os.loadAPI("point_api")

local config = {
    drive_name="drive_0",
    monitor_name="monitor_0",
    host_storage="refinedstorage:interface_1",
    user_storage="minecraft:barrel_2",
}

function write_to_mon(d, mon)
    mon.setCursorPos(1, 1)
    mon.clear()
    mon.write("d: "..d.read("minecraft:diamond"))
end

local user_storage = peripheral.wrap(config.user_storage)
local host_storage = peripheral.wrap(config.host_storage)


local point_types = { "minecraft:diamond", }

local mon = peripheral.wrap(config.monitor_name)
function clear_mon(mon) 
    mon.setBackgroundColor(colors.black)
    mon.setTextScale(.75)
    mon.setCursorPos(1, 1)
    mon.clear()
end 

function loop()
    clear_mon(mon)
    mon.write("Waiting")
    mon.setCursorPos(1, 2)
    mon.write("for")
    mon.setCursorPos(1, 3)
    mon.write("card")

    -- wait for the disk
    local d = point_api.wait_for_disk(config.drive_name, point_types)
    
    -- ask deposit or withdraw
    clear_mon(mon)
    mon.write("Balance: "..d.read(point_types[1]))
    mon.setCursorPos(1, 3)
    mon.setBackgroundColor(colors.green)
    mon.write("Deposit?")
    mon.setCursorPos(1, 7)
    mon.setBackgroundColor(colors.green)
    mon.write("Withdraw?")
    
    -- wait for click
    local event, button, x, y = os.pullEvent("monitor_touch")
    local do_deposit = y <= 5
    
    -- deposit
    if do_deposit then
        for i, item in pairs(user_storage.list()) do
            for j, type in ipairs(point_types) do
                if type == item.name then
                    user_storage.pushItems(config.host_storage, i)
                    d.add(type, item.count)
                    break
                end
            end
        end
        clear_mon(mon)
        mon.write("Balance: ")
        mon.setCursorPos(1, 2)
        mon.write(""..d.read("minecraft:diamond"))
    else
        for i, item in ipairs(point_types) do
            local num_to_pull = d.read(item)
            while num_to_pull > 0 do
                local items_pulled = 
                    host_storage.pushItems(
                        config.user_storage,
                        i+9, num_to_pull)
                d.add(item, -items_pulled)
                print("Pulled "..items_pulled.." items")
                num_to_pull = d.read(item)
            end
        end
    
        clear_mon(mon)
        mon.write("Finished!")
    end
    
    -- wait for disk_empty event
    os.pullEvent("disk_eject")
    
end




while true do loop() end
