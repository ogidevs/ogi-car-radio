QBCore = exports['qb-core']:GetCoreObject()

local customStations = {}
local liveRadioSounds = {}
local radioWheelDisabled = false
local youtubeActive = false
local radioVolume = Config.defaultRadioVolume
xSound = exports.xsound

-- iterate through all radios, filter the ones that are used as custom and show only those
for i = 0, GetNumResourceMetadata("ogi-car-radio", "supersede_radio") - 1 do
    local radio = GetResourceMetadata("ogi-car-radio", "supersede_radio", i)
    if not contains(Config.availableRadios, radio) then
        print("radio: " .. radio .. " is an invalid radio.")
    else
        local data = json.decode(GetResourceMetadata("ogi-car-radio", "supersede_radio_extra", i))
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

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    QBCore.Functions.TriggerCallback('ogi-car-radio:server:getRadios', function(vehicles)
        for vehNetId, info in pairs(vehicles) do
            TriggerEvent('ogi-car-radio:client:syncAudio', vehNetId, info.radio, info.volume, info.url)
        end
    end)
end)

RegisterNetEvent('ogi-car-radio:client:syncAudio', function(vehNetId, musicId)
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    SetFrontendRadioActive(false)
    if musicId == nil then
        SetVehRadioStation(GetVehiclePedIsIn(PlayerPedId()),"OFF")
    end
    
    liveRadioSounds[vehNetId] = musicId
    Wait(5000)
    radioWheelDisabled = false
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
        Wait(100)
    end
end)

-- main logic
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and vehicle ~= nil then
            radioStationName = GetPlayerRadioStationName()
            if customStations[radioStationName] == "options" and not youtubeActive then
                StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
                SetFrontendRadioActive(false)
                radioWheelDisabled = true
                local inputData = lib.inputDialog(Lang:t("options.name"), {
                    {
                        type = "number",
                        label = Lang:t("options.volume_label"),
                        icon = Lang:t("options.volume_icon"),
                        min = 0,
                        max = 10, -- do not change this
                        placeholder = Lang:t("options.volume_help"),
                        default = 2,
                        required = true,
                    },{
                        type = "input",
                        label = Lang:t("options.custom_url_label"),
                        icon = Lang:t("options.custom_url_icon"),
                        placeholder = Lang:t("options.custom_url_help"),
                    },
                })
                if inputData then
                    radioVolume = inputData[1]/10
                    if inputData[2] and inputData[2] ~= "" and isYoutubeUrl(inputData[2]) then
                        youtubeActive = true
                        TriggerServerEvent('ogi-car-radio:server:saveAudio', NetworkGetNetworkIdFromEntity(vehicle), customStations[radioStationName], radioVolume, inputData[2])
                    else
                        TriggerServerEvent('ogi-car-radio:server:saveAudio', NetworkGetNetworkIdFromEntity(vehicle), nil, radioVolume, nil)
                    end
                else
                    SetVehRadioStation(GetVehiclePedIsIn(PlayerPedId()),"OFF")
                end
            end
            QBCore.Functions.TriggerCallback('ogi-car-radio:server:getRadioForVehicle', function(radio)
                if radio ~= customStations[radioStationName] and GetIsVehicleEngineRunning(vehicle) and IsVehicleRadioEnabled(vehicle) then -- PLAY NEW RADIO    
                    radioWheelDisabled = true
                    youtubeActive = false
                    TriggerServerEvent('ogi-car-radio:server:saveAudio', NetworkGetNetworkIdFromEntity(vehicle), customStations[radioStationName], radioVolume, nil)
                elseif not GetIsVehicleEngineRunning(vehicle) or not IsVehicleRadioEnabled(vehicle) then -- STOP RADIO
                    Citizen.SetTimeout(2000, function()
                        if not IsVehicleRadioEnabled(vehicle) or not GetIsVehicleEngineRunning(vehicle) then
                            radioWheelDisabled = false
                            youtubeActive = false
                            TriggerServerEvent('ogi-car-radio:server:saveAudio', NetworkGetNetworkIdFromEntity(vehicle), nil, radioVolume, nil)
                        end
                    end)
                end
            end, NetworkGetNetworkIdFromEntity(vehicle))
        end
        Wait(2000)
    end
end)

-- update radio station based on car
Citizen.CreateThread(function()
    while true do
        local sleep = 100
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsEntering(ped)
        if vehicle ~= 0 and vehicle ~= nil then
            if NetworkDoesEntityExistWithNetworkId(NetworkGetNetworkIdFromEntity(vehicle)) then
                local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
                if xSound:soundExists('id_' .. vehNetId) or xSound:soundExists('idyt_' .. vehNetId) then
                    QBCore.Functions.TriggerCallback('ogi-car-radio:server:getRadioForVehicle', function(radio)
                        if radio ~= nil then
                            SetVehRadioStation(vehicle, get_key_for_value(customStations, radio))
                            SetRadioToStationName(get_key_for_value(customStations, radio))
                        end
                    end, vehNetId)
                end
            end
        end
        Wait(sleep)
    end
end)

-- update sound pos or destroy if vehicle is gone
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        for vehNetId, musicId in pairs(liveRadioSounds) do
            if musicId == nil then
                liveRadioSounds[vehNetId] = nil
            elseif not NetworkDoesEntityExistWithNetworkId(vehNetId) then
                xSound:Destroy(musicId)
                liveRadioSounds[vehNetId] = nil
            else
                if GetVehiclePedIsIn(PlayerPedId(), false) == NetworkGetEntityFromNetworkId(vehNetId) then -- inside of vehicle in which radio is playing
                    if xSound:getDistance(musicId) ~= Config.soundDistanceInMusicVehicle then -- update distance ONLY FOR people inside of a vehicle (client side)
                        xSound:Distance(musicId, Config.soundDistanceInMusicVehicle)
                    end
                else -- outside of vehicle in which radio is playing
                    if xSound:getDistance(musicId) == Config.soundDistanceInMusicVehicle then
                        xSound:Distance(musicId, xSound:getVolume(musicId)*50) -- max distance = 50
                    end
                end
                xSound:Position(musicId, GetEntityCoords(NetworkGetEntityFromNetworkId(vehNetId)))
            end
        end
        Wait(sleep)
    end
end)

-- disable radio wheel while changing radio, could possibly just leave this out
CreateThread(function()
    local ped = PlayerPedId()
    while true do
        local inVehicle = IsPedInAnyVehicle(ped, true)
        if inVehicle then
            if radioWheelDisabled then
                -- controls for the radio wheel
                DisableControlAction(0, 81, true)
                DisableControlAction(0, 82, true)
                DisableControlAction(0, 83, true)
                DisableControlAction(0, 84, true)
                DisableControlAction(0, 85, true)
            else
                Wait(500)
            end
        else
            Wait(1000)
        end
        Wait(10)
    end
end)