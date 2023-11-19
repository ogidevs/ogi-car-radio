local customStations = {}
local liveRadioSounds = {}
local radioWheelDisabled = false
local youtubeActive = false
local radioVolume = Config.defaultRadioVolume
xSound = exports.xsound

local function AutoDetectFramework()
    if GetResourceState("es_extended") == "started" then
        return "ESX"
    else
        return "qbcore"
    end
end

if Config.Framework == "auto-detect" then
    Config.Framework = AutoDetectFramework()
end

if Config.Framework == "ESX" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function()
        lib.callback('ogi-car-radio:server:getRadios', false, function(vehicles)
            for vehNetId, info in pairs(vehicles) do
                TriggerEvent('ogi-car-radio:client:syncAudio', vehNetId, info.radio, info.volume, info.url)
            end
        end)
    end)
elseif Config.Framework == "qbcore" then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        lib.callback('ogi-car-radio:server:getRadios', false, function(vehicles)
            for vehNetId, info in pairs(vehicles) do
                TriggerEvent('ogi-car-radio:client:syncAudio', vehNetId, info.radio, info.volume, info.url)
            end
        end)
    end)
end

-- iterate through all radios, filter the ones that are used as custom and show only those
for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), "supersede_radio") - 1 do
    local radio = GetResourceMetadata(GetCurrentResourceName(), "supersede_radio", i)
    if not contains(Config.availableRadios, radio) then
        print("radio: " .. radio .. " is an invalid radio.")
    else
        local data = json.decode(GetResourceMetadata(GetCurrentResourceName(), "supersede_radio_extra", i))
        if data ~= nil then
            customStations[radio] = data.url
            if data.name then
                AddTextEntry(radio, data.name)
            end
        else
            print("radio: Missing data for " .. radio .. ".")
        end
    end
end

RegisterNetEvent('ogi-car-radio:client:syncAudio', function(vehNetId, musicId)
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    SetFrontendRadioActive(false)
    if musicId == nil then
        SetVehRadioStation(GetVehiclePedIsIn(PlayerPedId()),"OFF")
        liveRadioSounds[vehNetId] = nil
        SetUserRadioControlEnabled(true)
        return
    end
    xSound:onPlayStart(musicId, function()
        SetUserRadioControlEnabled(true)
        liveRadioSounds[vehNetId] = musicId
    end)
end)

-- main logic
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and vehicle ~= nil then
            radioStationName = GetPlayerRadioStationName()
            if customStations[radioStationName] == "options" and not youtubeActive and GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(-1) then
                StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
                SetFrontendRadioActive(false)
                SetUserRadioControlEnabled(false)
                local inputData = lib.inputDialog(Language[Config.Language]["name"], {
                    {
                        type = "number",
                        label = Language[Config.Language]["volume_label"],
                        icon = Language[Config.Language]["volume_icon"],
                        min = 0,
                        max = 10, -- do not change this
                        placeholder = Language[Config.Language]["volume_help"],
                        default = 2,
                        required = true,
                    },{
                        type = "input",
                        label = Language[Config.Language]["custom_url_label"], 
                        icon = Language[Config.Language]["custom_url_icon"],
                        placeholder = Language[Config.Language]["custom_url_help"],
                    },
                })
                if inputData then
                    radioVolume = inputData[1]/10
                    if inputData[2] and inputData[2] ~= "" and isYoutubeUrl(inputData[2]) then
                        youtubeActive = true
                        TriggerServerEvent('ogi-car-radio:server:saveAudio', VehToNet(vehicle), customStations[radioStationName], radioVolume, inputData[2])
                    else
                        TriggerServerEvent('ogi-car-radio:server:saveAudio', VehToNet(vehicle), nil, radioVolume, nil)
                    end
                else
                    SetVehRadioStation(GetVehiclePedIsIn(PlayerPedId()),"OFF")
                end
            end
            lib.callback('ogi-car-radio:server:getRadioForVehicle', false, function(radio)
                if radio ~= customStations[radioStationName] and GetIsVehicleEngineRunning(vehicle) and IsVehicleRadioEnabled(vehicle) then -- PLAY NEW RADIO    
                    SetUserRadioControlEnabled(false)
                    youtubeActive = false
                    TriggerServerEvent('ogi-car-radio:server:saveAudio', VehToNet(vehicle), customStations[radioStationName], radioVolume, nil)
                elseif not GetIsVehicleEngineRunning(vehicle) or not IsVehicleRadioEnabled(vehicle) then -- STOP RADIO
                    Citizen.SetTimeout(1500, function() -- wait for the player to leave vehicle
                        if not IsVehicleRadioEnabled(vehicle) or not GetIsVehicleEngineRunning(vehicle) then
                            youtubeActive = false
                            TriggerServerEvent('ogi-car-radio:server:saveAudio', VehToNet(vehicle), nil, radioVolume, nil)
                        end
                    end)
                end
            end, VehToNet(vehicle))
        else
            local vehicle = GetVehiclePedIsIn(ped, true)
            if vehicle ~= 0 and vehicle ~= nil then
                if NetworkDoesEntityExistWithNetworkId(VehToNet(vehicle)) then
                    lib.callback('ogi-car-radio:server:getRadioForVehicle', false, function(radio)
                        if not GetIsVehicleEngineRunning(vehicle) or not IsVehicleRadioEnabled(vehicle) then -- stop radio
                            if not IsVehicleRadioEnabled(vehicle) or not GetIsVehicleEngineRunning(vehicle) then
                                youtubeActive = false
                                TriggerServerEvent('ogi-car-radio:server:saveAudio', VehToNet(vehicle), nil, radioVolume, nil)
                            end
                        end
                    end, VehToNet(vehicle))
                end
            end
        end
        Wait(1000)
    end
end)

-- only show custom stations in vehicle
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, true)
        if inVehicle then
            Wait(0)
            for i = 0, GetNumUnlockedRadioStations() - 1 do
                if not contains(get_keys(customStations), GetRadioStationName(i)) then
                    SetRadioStationIsVisible(GetRadioStationName(i), false)
                else
                    SetRadioStationIsVisible(GetRadioStationName(i), true)
                end
            end
        else
            Wait(1000)
        end
        Wait(500)
    end
end)

-- update sound pos or destroy if vehicle is gone
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        for vehNetId, musicId in pairs(liveRadioSounds) do
            if musicId == nil then
                liveRadioSounds[vehNetId] = nil
            elseif vehNetId == nil or NetworkDoesEntityExistWithNetworkId(vehNetId) == false or GetVehicleEngineHealth(NetToVeh(vehNetId)) < 0 then
                xSound:Destroy(musicId)
                liveRadioSounds[vehNetId] = nil
            else
                if GetVehiclePedIsIn(PlayerPedId(), false) == NetToVeh(vehNetId) then -- inside of vehicle in which radio is playing
                    if xSound:getDistance(musicId) ~= Config.soundDistanceInMusicVehicle then -- update distance ONLY FOR people inside of a vehicle (client side)
                        xSound:Distance(musicId, Config.soundDistanceInMusicVehicle)
                    end
                else -- outside of vehicle in which radio is playing
                    if xSound:getDistance(musicId) == Config.soundDistanceInMusicVehicle then
                        xSound:Distance(musicId, xSound:getVolume(musicId)*50) -- max distance = 50
                    end
                end
                xSound:Position(musicId, GetEntityCoords(NetToVeh(vehNetId)))
            end
        end
        Wait(sleep)
    end
end)