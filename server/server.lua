-- ESX = exports["es_extended"]:getSharedObject()

-- --[[RegisterServerEvent('giveFreeCarToNewPlayer')
-- AddEventHandler('giveFreeCarToNewPlayer', function()
--  --   local playerId = source
--  --   if IsPlayerNew(playerId) then
--         local xPlayer = ESX.GetPlayerFromId(playerId)
--         if xPlayer then
--             -- Trigger client event to spawn the vehicle
--             TriggerClientEvent('spawnVehicle', playerId, Config.FreeCar)
--             TriggerEvent('zaineee:claimVehicle')
--             TriggerEvent('zaineee:SetOwnedVehicle', 'FREECAR', {model = Config.FreeCar})
--         end
--     end
--     else
--        -- Player is not new or cannot be found
--     end
-- end)

-- function IsPlayerNew(playerId)
--     local xPlayer = ESX.GetPlayerFromId(playerId)
--     if xPlayer then
--         return xPlayer.get('is_new')
--     end
--     return false
-- end]]



-- RegisterNetEvent('zaineee:claimVehicle')
-- AddEventHandler('zaineee:claimVehicle', function(plate)
--     local src = source
--     local xPlayer = ESX.GetPlayerFromId(source)


--     MySQL.Async.execute('SELECT identifier FROM zaineee_freecar WHERE identifier = @identifier', { ['identifier'] = xPlayer.getIdentifier()}, function(result)
--         if result then
--             TriggerClientEvent('Roda_Notifications:showNotification', src, "You've claimed the FREECAR!", 'info', 3000)
--             TriggerClientEvent('zaineee:vehicleAlreadyClaimed', src)
--         end
--     end)
-- end)
-- RegisterNetEvent('zaineee:SetOwnedVehicle')
-- AddEventHandler('zaineee:SetOwnedVehicle', function(plate, vehicleProps)
--     local src = source
--     local xPlayer = ESX.GetPlayerFromId(src)

--     MySQL.Async.fetchScalar('SELECT identifier FROM zaineee_freecar WHERE identifier = @identifier', { ['identifier'] = xPlayer.getIdentifier()}, function(result)
--         if result then
--            -- NOTIFY for Claimed Car
--            TriggerClientEvent('Roda_Notifications:showNotification', src, "Bobo kaba? You've already claimed a free car!", 'success', 3000)
--         else

--             MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, garage) VALUES (@owner, @plate, @vehicle, @type, @stored, @garage)", {
--                 ['@owner'] = xPlayer.identifier,
--                 ['@plate'] = plate,
--                 ['@vehicle'] = json.encode(vehicleProps),
--                 ['@type'] = Config.Vehicles["model"], 
--                 ['@stored'] = 1,
--                 ['@garage'] = 'Mechanic'
--             }, function(rowsChanged)
--                 if rowsChanged > 0 then

--                     TriggerClientEvent('Roda_Notifications:showNotification', src, "You've claimed a free car!", 'success', 3000)


--                     MySQL.Async.execute("INSERT INTO zaineee_freecar (identifier, plate) VALUES (@identifier, @plate)", {
--                         ['@identifier'] = xPlayer.identifier,
--                         ['@plate'] = plate
--                     })
--                 else

--                     TriggerClientEvent('Roda_Notifications:showNotification', src, "Failed to claim the car. Please try again.", 'error', 3000)
--                 end
--             end)
--         end
--     end)
-- end)

-- --- Car 2

-- RegisterNetEvent('zaineee:claimVehicle2')
-- AddEventHandler('zaineee:claimVehicle2', function(plate)
--     local src = source
--     local xPlayer = ESX.GetPlayerFromId(source)

--     -- Check if the player has already claimed a vehicle
--     MySQL.Async.execute('SELECT identifier FROM zaineee_freecar WHERE identifier = @identifier', { ['identifier'] = xPlayer.getIdentifier()}, function(result)
--         if result then
--             TriggerClientEvent('Roda_Notifications:showNotification', src, "You've claimed the FREECAR!", 'info', 3000)
--             TriggerClientEvent('zaineee:vehicleAlreadyClaimed2', src) -- Notify client to prevent spawning
--         end
--     end)
-- end)
-- RegisterNetEvent('zaineee:SetOwnedVehicle2')
-- AddEventHandler('zaineee:SetOwnedVehicle2', function(plate, vehicleProps)
--     local src = source
--     local xPlayer = ESX.GetPlayerFromId(src)


--     MySQL.Async.fetchScalar('SELECT identifier FROM zaineee_freecar WHERE identifier = @identifier', { ['identifier'] = xPlayer.getIdentifier() }, function(result)
--         if result then

--             TriggerClientEvent('Roda_Notifications:showNotification', src, "You already have a free car.", 'error', 3000)
--         else

--             MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, garage) VALUES (@owner, @plate, @vehicle, @type, @stored, @garage)", {
--                 ['@owner'] = xPlayer.identifier,
--                 ['@plate'] = plate,
--                 ['@vehicle'] = json.encode(vehicleProps),
--                 ['@type'] = Config.Vehicles2["model2"], 
--                 ['@stored'] = 1,
--                 ['@garage'] = 'Mechanic'
--             }, function(rowsChanged)
--                 if rowsChanged > 0 then

--                     TriggerClientEvent('Roda_Notifications:showNotification', src, "You've claimed a free car!", 'success', 3000)

   
--                     MySQL.Async.execute("INSERT INTO zaineee_freecar (identifier, plate) VALUES (@identifier, @plate)", {
--                         ['@identifier'] = xPlayer.identifier,
--                         ['@plate'] = plate
--                     })
--                 else
 
--                     TriggerClientEvent('Roda_Notifications:showNotification', src, "Failed to claim the car. Please try again.", 'error', 3000)
--                 end
--             end)
--         end
--     end)
-- end)

ESX = exports["es_extended"]:getSharedObject()


ESX.RegisterServerCallback('zaineee-freecar:hasClaimedCar', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        print("[FREECAR] No xPlayer found for source " .. source)
        cb(false)
        return
    end

    MySQL.Async.fetchScalar('SELECT claimed FROM zaineee_freecar WHERE identifier = ?', {xPlayer.identifier}, function(claimed)
        if claimed == 1 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

-- Claim a free car
RegisterNetEvent('zaineee-freecar:claimCar')
AddEventHandler('zaineee-freecar:claimCar', function(vehicleModel)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Check if already claimed
    MySQL.Async.fetchScalar('SELECT claimed FROM zaineee_freecar WHERE identifier = ?', {xPlayer.identifier}, function(claimed)
        if claimed == 1 then
            -- Already claimed
            TriggerClientEvent('zaineee-freecar:notify', src, 'You have already claimed a free car!')
            return
        end

        -- Generate random plate like "FREE123"
        local plate = "FREE"..tostring(math.random(100,999))

        -- Insert or update claim
        MySQL.Async.execute([[
            INSERT INTO zaineee_freecar (identifier, plate, claimed, claimed_at) 
            VALUES (@identifier, @plate, 1, NOW()) 
            ON DUPLICATE KEY UPDATE claimed = 1, plate = @plate, claimed_at = NOW()
        ]], {
            ['@identifier'] = xPlayer.identifier,
            ['@plate'] = plate
        }, function(rowsChanged)
            print("[FREECAR] Player " .. xPlayer.identifier .. " claimed a car: " .. vehicleModel .. " with plate " .. plate)

            -- Insert into owned_vehicles
            local vehicleProps = json.encode({
                model = vehicleModel,
                plate = plate,
            })
            MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {
                xPlayer.identifier,
                plate,
                vehicleProps,
                true
            }, function()
                TriggerClientEvent('zaineee-freecar:notify', src, 'You have claimed your free car: '..vehicleModel..' with plate '..plate)
                TriggerClientEvent('zaineee-freecar:closeUI', src)
            end)
        end)
    end)
end)

-- ESX = exports["es_extended"]:getSharedObject()

-- local function generatePlate()
--     local plate
--     local exists = true

--     while exists do
--         plate = "FREE" .. tostring(math.random(1000, 9999))
--         local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate})
--         if #result == 0 then
--             exists = false
--         end
--     end

--     return plate
-- end

-- -- Check if player already claimed a freecar
-- ESX.RegisterServerCallback('zaineee-freecar:hasClaimedCar', function(source, cb)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     if not xPlayer then cb(false) return end

--     MySQL.Async.fetchScalar('SELECT claimed FROM zaineee_freecar WHERE identifier = ?', {xPlayer.identifier}, function(claimed)
--         if claimed == 1 then
--             cb(true) -- already claimed
--         else
--             cb(false) -- not claimed yet
--         end
--     end)
-- end)

-- RegisterNetEvent('zaineee-freecar:giveVehicleAndPack')
-- AddEventHandler('zaineee-freecar:giveVehicleAndPack', function(vehicleData)
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)
--     if not xPlayer then return end

--     -- Check again if player already claimed to avoid exploits
--     MySQL.Async.fetchScalar('SELECT claimed FROM zaineee_freecar WHERE identifier = ?', {xPlayer.identifier}, function(claimed)
--         if claimed == 1 then
--             TriggerClientEvent('esx:showNotification', _source, 'You have already claimed your free car!')
--             return
--         end

--         local plate = generatePlate()
--         local model = vehicleData.name or "adder"
--         local vehicleProps = {
--             model = model,
--             plate = plate,
--         }

--         MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (@owner, @plate, @vehicle, @stored)', {
--             ['@owner'] = xPlayer.identifier,
--             ['@plate'] = plate,
--             ['@vehicle'] = json.encode(vehicleProps),
--             ['@stored'] = true
--         }, function(rowsChanged)
--             if rowsChanged > 0 then
--                 -- Mark player as claimed in your freecar table
--                 MySQL.Async.execute([[
--                     INSERT INTO zaineee_freecar (identifier, plate, claimed_at, claimed)
--                     VALUES (@identifier, @plate, NOW(), 1)
--                     ON DUPLICATE KEY UPDATE
--                         plate = VALUES(plate),
--                         claimed_at = NOW(),
--                         claimed = 1
--                 ]], {
--                     ['@identifier'] = xPlayer.identifier,
--                     ['@plate'] = plate
--                 })

--                 -- Give starter pack
--                 xPlayer.addInventoryItem('bread', 5)
--                 xPlayer.addInventoryItem('water', 5)
--                 xPlayer.addMoney(500)

--                 TriggerClientEvent('esx:showNotification', _source, 'Vehicle received and starter pack given!')
--             else
--                 TriggerClientEvent('esx:showNotification', _source, 'Failed to add vehicle, try again.')
--             end
--         end)
--     end)
-- end)