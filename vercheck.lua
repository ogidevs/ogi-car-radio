local function VersionLog(_type, log)
    local color = _type == 'success' and '^2' or '^1'
    print(('^1[ocr]%s %s^3'):format(color, log))
end

local function CheckMenuVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/ogidevs/ogi-car-radio/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not text then
            VersionLog('error', 'Currently unable to run a version check.')
            return
        end
        VersionLog('success', ('Current Version: %s'):format(currentVersion))
        VersionLog('success', ('Latest Version: %s'):format(text))
        if text:gsub("%s+", "") == currentVersion:gsub("%s+", "") then
            VersionLog('success', 'You are running the latest version of the official ogi-car-radio script by ogidevs.')
        else
            VersionLog('error', ('You are currently running an outdated version of ogi-car-radio, please update to version %s'):format(text))
        end
    end)
end

CheckMenuVersion()