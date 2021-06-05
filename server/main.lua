QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local shots = {}
local blood = {}

QBCore.Functions.CreateCallback("core_evidence:getData", function(source, cb)
    cb({shots = shots, blood = blood, time = os.time()})
end)

QBCore.Functions.CreateCallback("core_evidence:getStorageData", function(source, cb)
    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `evidence_storage` WHERE 1", {
    },function(reports)
        cb(reports)
    end)
end)

RegisterServerEvent("core_evidence:deleteEvidenceFromStorage")
AddEventHandler("core_evidence:deleteEvidenceFromStorage", function(id)
    QBCore.Functions.ExecuteSql(false, "DELETE FROM `evidence_storage` WHERE id = @id", {
        ["@id"] = id
    })
end)

RegisterServerEvent("core_evidence:addEvidenceToStorage")
AddEventHandler("core_evidence:addEvidenceToStorage", function(evidence)
    QBCore.Functions.ExecuteSql(false, "INSERT INTO `evidence_storage`(`data`) VALUES (@evidence)", {
        ["@evidence"] = evidence
    })
end)

RegisterServerEvent("core_evidence:removeEverything")
AddEventHandler("core_evidence:removeEverything", function()
    for k, v in pairs(blood) do
        if v.interior == 0 then
            blood[k] = nil
        end
    end
    for k, v in pairs(shots) do
        print(v.interior)
        if v.interior == 0 then
            shots[k] = nil
        end
    end
end)

RegisterServerEvent("core_evidence:removeBlood")
AddEventHandler("core_evidence:removeBlood", function(citizenid)
    blood[citizenid] = nil
end)

RegisterServerEvent("core_evidence:removeShot")
AddEventHandler("core_evidence:removeShot", function(citizenid)
    shots[citizenid] = nil
end)

RegisterServerEvent("core_evidence:LastInCar")
AddEventHandler("core_evidence:LastInCar",function(id)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(id)
    local xPlayer = QBCore.Functions.GetPlayer(NetworkGetEntityOwner(entity))
    local citizenid = xPlayer.PlayerData.citizenid
    if xPlayer ~= nil then
        if NetworkGetEntityOwner(entity) ~= src then
            QBCore.Functions.ExecuteSql(true, "SELECT " .. Config.EvidenceReportInformationFingerprint .. " FROM `players` WHERE citizenid = @citizenid LIMIT 1", {
                ["@citizenid"] = citizenid
            },function(reportInfo)
                TriggerClientEvent("core_evidence:addFingerPrint", src, reportInfo[1])
            end)
        else
            TriggerClientEvent("core_evidence:SendTextMessage", src, Config.Text["no_fingerprints_found"])
        end
    else
        TriggerClientEvent("core_evidence:SendTextMessage", src, Config.Text["no_fingerprints_found"])
    end
end)

RegisterServerEvent("core_evidence:saveBlood")
AddEventHandler("core_evidence:saveBlood", function(coords, interior)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local citizenid = xPlayer.PlayerData.citizenid
    QBCore.Functions.ExecuteSql(true, "SELECT " .. Config.EvidenceReportInformationBlood .. " FROM `players` WHERE citizenid = @citizenid LIMIT 1", {
        ["@citizenid"] = citizenid
    }, function(reportInfo)
        local time = os.time()
        blood[time] = {coords = coords, reportInfo = reportInfo[1], interior = interior}
    end)
end)

QBCore.Functions.CreateUseableItem('uvlight', function(playerId)
    TriggerClientEvent('core_evidence:checkForFingerprints', playerId)
end)

RegisterServerEvent("core_evidence:saveShot")
AddEventHandler("core_evidence:saveShot", function(coords, bullet, interior)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local citizenid = xPlayer.PlayerData.citizenid
    QBCore.Functions.ExecuteSql(true, "SELECT " .. Config.EvidenceReportInformationBullet .. " FROM `players` WHERE citizenid = @citizenid LIMIT 1", {
        ["@citizenid"] = citizenid
    }, function(reportInfo)
        local time = os.time()
        shots[time] = {coords = coords, bullet = bullet, reportInfo = reportInfo[1], interior = interior}
    end)
end)