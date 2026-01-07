local isVehicleSpawned = false
local spawnedVehicle = nil

local isVehicleSpawned2 = false
local spawnedVehicle2 = nil

function SpawnVehicle(vehicleName)
    if isVehicleSpawned then return end

    local vehicleConfig = Config.Vehicles
    if not vehicleConfig then
        print("Vehicle configuration not found for: " .. vehicleName)
        return
    end

    local pos = vehicleConfig.spawnPosition

    RequestModel(vehicleConfig.model)
    while not HasModelLoaded(vehicleConfig.model) do
        Citizen.Wait(500)
    end

    spawnedVehicle = CreateVehicle(vehicleConfig.model, pos.x, pos.y, pos.z, pos.heading, true, false)
    if DoesEntityExist(spawnedVehicle) then
        SetVehicleOnGroundProperly(spawnedVehicle)
        SetVehicleNumberPlateText(spawnedVehicle, vehicleConfig.plate or "FREECAR")
        SetEntityAsMissionEntity(spawnedVehicle, true, true)

        SetVehicleCustomPrimaryColour(spawnedVehicle, table.unpack(vehicleConfig.properties.color))
        if vehicleConfig.properties.isFrozen then FreezeVehicle(spawnedVehicle) end

        isVehicleSpawned = true
        print("Vehicle spawned successfully: " .. vehicleName)
    else
        print("Failed to create vehicle: " .. vehicleName)
    end
end

function SpawnVehicle2(vehicleName2)
    if isVehicleSpawned2 then return end

    local vehicleConfig = Config.Vehicles2
    if not vehicleConfig then
        print("Vehicle configuration not found for: " .. vehicleName2)
        return
    end

    local pos = vehicleConfig.spawnPosition2

    RequestModel(vehicleConfig.model2)
    while not HasModelLoaded(vehicleConfig.model2) do
        Citizen.Wait(500)
    end

    spawnedVehicle2 = CreateVehicle(vehicleConfig.model2, pos.x, pos.y, pos.z, pos.heading, true, false)
    if DoesEntityExist(spawnedVehicle2) then
        SetVehicleOnGroundProperly(spawnedVehicle2)
        SetVehicleNumberPlateText(spawnedVehicle2, vehicleConfig.plate2 or "FREECAR2")
        SetEntityAsMissionEntity(spawnedVehicle2, true, true)

        SetVehicleCustomPrimaryColour(spawnedVehicle2, table.unpack(vehicleConfig.properties.color))
        if vehicleConfig.properties.isFrozen then FreezeVehicle(spawnedVehicle2) end

        isVehicleSpawned2 = true
        print("Vehicle spawned successfully: " .. vehicleName2)
    else
        print("Failed to create vehicle: " .. vehicleName2)
    end
end




function FreezeVehicle(vehicle)
    if DoesEntityExist(vehicle) then
        SetVehicleForwardSpeed(vehicle, 0.0)
        SetVehicleEngineOn(vehicle, false, false, true)
        SetVehicleHandbrake(vehicle, true)
        FreezeEntityPosition(vehicle, true)
        
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleUndriveable(vehicle, true)
        SetVehicleLights(vehicle, 0)

        print("Vehicle is now frozen and undriveable.")
    end
end

-- Register events
RegisterNetEvent('spawnVehicle')
AddEventHandler('spawnVehicle', function(vehicleName)
    print("Received request to spawn vehicle: " .. vehicleName)
    SpawnVehicle(vehicleName)
end)

RegisterNetEvent('zaineee:vehicleAlreadyClaimed')
AddEventHandler('zaineee:vehicleAlreadyClaimed', function()
    print("Player has already claimed the vehicle, skipping spawn.")
    isVehicleSpawned = false
    spawnedVehicle = nil
end)

RegisterNetEvent('spawnVehicle2')
AddEventHandler('spawnVehicle2', function(vehicleName2)
    print("Received request to spawn vehicle: " .. vehicleName2)
    SpawnVehicle(vehicleName2)
end)

RegisterNetEvent('zaineee:vehicleAlreadyClaimed2')
AddEventHandler('zaineee:vehicleAlreadyClaimed2', function()
    print("Player has already claimed the vehicle, skipping spawn.")
    isVehicleSpawned2 = false
    spawnedVehicle2 = nil
end)


-- Vehicle spawning on startup
Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    local pos = Config.VehicleSpawnLocation
    local vehicleName = Config.Vehicles.type

    RequestModel(vehicleName)
    while not HasModelLoaded(vehicleName) do
        Citizen.Wait(500)
    end

    spawnedVehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, pos.heading, true, false)
    if DoesEntityExist(spawnedVehicle) then
        print("Vehicle spawned successfully at startup.")
        SetVehicleOnGroundProperly(spawnedVehicle)
        SetVehicleNumberPlateText(spawnedVehicle, "FREECAR")
        TriggerServerEvent('zaineee:giveFreeItems')
        SetEntityAsMissionEntity(spawnedVehicle, true, true)
        FreezeVehicle(spawnedVehicle)
        isVehicleSpawned = true
    else
        print("Failed to create vehicle.")
    end
end)



-- VEHICLE 1
Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    TriggerServerEvent('zaineee:claimVehicle')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if isVehicleSpawned and spawnedVehicle and DoesEntityExist(spawnedVehicle) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle == spawnedVehicle then
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == playerPed then
                    local plate = exports['cfx-hu-vehicleshop']:GeneratePlate()
                    SetVehicleNumberPlateText(spawnedVehicle, plate)
                    local vehicleProps = ESX.Game.GetVehicleProperties(spawnedVehicle)
                    TriggerServerEvent("zaineee:SetOwnedVehicle", plate, vehicleProps)
                    Citizen.Wait(100)
                    if DoesEntityExist(spawnedVehicle) then
                        DeleteVehicle(spawnedVehicle)
                        spawnedVehicle = nil
                        isVehicleSpawned = false
--   exports['Roda_Notifications']:showNotify('Vehicle claimed and deleted after player got into driver’s seat.', 'info', 4000)
                    else
                        exports['Roda_Notifications']:showNotify('Vehicle does not exist at deletion time.', 'info', 4000)
                    end
                else
                    exports['Roda_Notifications']:showNotify('Player is not in the driver’s seat.', 'info', 4000)
                end
            else
                TriggerServerEvent('zaineee:claimVehicle')
            end
        end
    end
end)

-- Vehicle 2
Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    local pos = Config.VehicleSpawnLocation2
    local vehicleName2 = Config.Vehicles2.type2

    RequestModel(vehicleName2)
    while not HasModelLoaded(vehicleName2) do
        Citizen.Wait(500)
    end

    spawnedVehicle2 = CreateVehicle(vehicleName2, pos.x, pos.y, pos.z, pos.heading, true, false)
    if DoesEntityExist(spawnedVehicle2) then
        print("Vehicle 2 spawned successfully at startup.")
        SetVehicleOnGroundProperly(spawnedVehicle2)
        SetVehicleNumberPlateText(spawnedVehicle2, "FREECAR2")
        SetEntityAsMissionEntity(spawnedVehicle2, true, true)
        FreezeVehicle(spawnedVehicle2)
        isVehicleSpawned2 = true
    else
        print("Failed to create vehicle 2.")
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000) 
    TriggerServerEvent('zaineee:claimVehicle2')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if isVehicleSpawned2 and spawnedVehicle2 and DoesEntityExist(spawnedVehicle2) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle == spawnedVehicle2 then
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == playerPed then
                    print("Player is in the driver’s seat.")
                    local plate = exports['cfx-hu-vehicleshop2']:GeneratePlate()
                    SetVehicleNumberPlateText(spawnedVehicle2, plate)
                    local vehicleProps = ESX.Game.GetVehicleProperties(spawnedVehicle2)
                    TriggerServerEvent("zaineee:SetOwnedVehicle2", plate, vehicleProps)
                    Citizen.Wait(100)
                    if DoesEntityExist(spawnedVehicle2) then
                        DeleteVehicle(spawnedVehicle2)
                        spawnedVehicle2 = nil
                        isVehicleSpawned2 = false
                        print("Vehicle 2 claimed and deleted after player got into driver’s seat.")
                    else
                        print("Vehicle 2 does not exist at deletion time.")
                    end
                else
                    print("Player 2 is not in the driver’s seat.")
                end
            else
                TriggerServerEvent('zaineee:claimVehicle2')
            end
        end
    end
end)
