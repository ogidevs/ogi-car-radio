if Config.Framework == "auto-detect" then
    Config.Framework = AutoDetectFramework()
end

local function AutoDetectFramework()
    if GetResourceState("es_extended") == "started" then
        return "ESX"
    else
        return "qbcore"
    end
end

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports['qb-core']:GetCoreObject()
end

local vehiclesRadio = {}

xSound = exports.xsound

RegisterNetEvent('ogi-car-radio:server:saveAudio', function(vehNetId, radio, volume, url)
    vehiclesRadio[vehNetId] = {
        radio = radio,
        volume = volume,
        url = url
    }
    -- youtube logic
    if url ~= nil then
        xSound:Destroy(-1, 'id_' .. vehNetId)
        xSound:Destroy(-1, 'idyt_' .. vehNetId)
        local musicId = 'idyt_'.. vehNetId
        xSound:PlayUrlPos(-1, musicId, url, volume, GetEntityCoords(NetworkGetEntityFromNetworkId(vehNetId)))
        xSound:Distance(-1, musicId, volume*20)
        TriggerClientEvent('ogi-car-radio:client:syncAudio', -1, vehNetId, musicId)
    -- normal radio logic
    else
        local musicId = 'id_'.. vehNetId

        xSound:Destroy(-1, 'idyt_' .. vehNetId)
        xSound:Destroy(-1, musicId)

        if radio == nil then
            TriggerClientEvent('ogi-car-radio:client:syncAudio', -1, vehNetId, nil)
            return
        else
            xSound:PlayUrlPos(-1, musicId, radio, volume, GetEntityCoords(NetworkGetEntityFromNetworkId(vehNetId)))
            xSound:Distance(-1, musicId, volume*100)
            TriggerClientEvent('ogi-car-radio:client:syncAudio', -1, vehNetId, 'id_'.. vehNetId)
        end
    end
end)

if Config.Framework == "ESX" then

    ESX.RegisterServerCallback('ogi-car-radio:server:getRadioForVehicle', function(source, cb, vehNetId)
        if contains(get_keys(vehiclesRadio), vehNetId) then
            cb(vehiclesRadio[vehNetId].radio)
        else
            cb(false)
        end
    end)

    ESX.RegisterServerCallback('ogi-car-radio:server:getRadios', function(source, cb)
        cb(vehiclesRadio)
    end)

else

    QBCore.Functions.CreateCallback('ogi-car-radio:server:getRadioForVehicle', function(source, cb, vehNetId)
        if contains(get_keys(vehiclesRadio), vehNetId) then
            cb(vehiclesRadio[vehNetId].radio)
        else
            cb(false)
        end
    end)

    QBCore.Functions.CreateCallback('ogi-car-radio:server:getRadios', function(source, cb)
        cb(vehiclesRadio)
    end)

end