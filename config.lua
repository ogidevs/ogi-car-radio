Config = {}

Config.Framework = "auto-detect" -- Framework | types: auto-detect, qbcore, ESX

Config.Language = 'EN' --[ 'EN' / 'PT' / 'SR' / 'PL' ]   You can add your own locales to Locales.lua, but be sure to update the Config.Language to match it.

-- default volume for the radio
Config.defaultRadioVolume = 0.2
-- max distance for the radio to be heard
-- distance is relative to the volume, so if you have a volume of 0.2 distance would be 0.2 * 50.0 = 10.0
Config.maxDistance = 50.0
-- distance for the sound to be heard for people in the vehicle where the sound is playing from, 
-- go above 50.0 or sound will not be heard on high speeds, 
-- Config.maxDistance is ignored when in vehicle from which the sound is playing
Config.soundDistanceInMusicVehicle = 100.0 

Config.availableRadios = {
    "RADIO_01_CLASS_ROCK",              -- Los Santos Rock Radio
    "RADIO_02_POP",                     -- Non-Stop-Pop FM
    "RADIO_03_HIPHOP_NEW",              -- Radio Los Santos
    "RADIO_04_PUNK",                    -- Channel X
    "RADIO_05_TALK_01",                 -- West Coast Talk Radio
    "RADIO_06_COUNTRY",                 -- Rebel Radio
    "RADIO_07_DANCE_01",                -- Soulwax FM
    "RADIO_08_MEXICAN",                 -- East Los FM
    "RADIO_09_HIPHOP_OLD",              -- West Coast Classics
    "RADIO_11_TALK_02",                 -- Blaine County Radio
    "RADIO_12_REGGAE",                  -- Blue Ark
    "RADIO_13_JAZZ",                    -- Worldwide FM
    "RADIO_14_DANCE_02",                -- FlyLo FM
    "RADIO_15_MOTOWN",                  -- The Lowdown 91.1
    "RADIO_16_SILVERLAKE",              -- Radio Mirror Park
    "RADIO_17_FUNK",                    -- Space 103.2
    "RADIO_18_90S_ROCK",                -- Vinewood Boulevard Radio
    "RADIO_19_USER",                    -- Self Radio
    "RADIO_20_THELAB",                  -- The Lab
    "RADIO_21_DLC_XM17",                -- Blonded Los Santos 97.8 FM
    "RADIO_22_DLC_BATTLE_MIX1_RADIO",   -- Los Santos Underground Radio
    "RADIO_23_DLC_XM19_RADIO",          -- iFruit Radio
    "RADIO_27_DLC_PRHEI4",              -- Still Slipping Los Santos
    "RADIO_34_DLC_HEI4_KULT",           -- Kult FM
    "RADIO_35_DLC_HEI4_MLR",            -- The Music Locker
    "RADIO_36_AUDIOPLAYER",             -- Media Player
    "RADIO_37_MOTOMAMI"                 -- MOTOMAMI Los Santos
}

function isYoutubeUrl(url)
    return string.match(url, "^https?://www%.youtube%.com/watch%?v=.-$") ~= nil or string.match(url, "^https?://youtu%.be/.-$") ~= nil
end

function get_keys(t)
    local keys={}
    for key,_ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

function get_key_for_value(t, value) -- should change this
    for k,v in pairs(t) do
        if v==value then return k end
    end
    return nil
end

function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end