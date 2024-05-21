require ("lib.moonloader")
local ev = require ("lib.samp.events")
local dlstatus = require('moonloader').download_status
update_state = true -- Если переменная == true, значит начнётся обновление.
update_found = true -- Если будет true, будет доступна команда /update.

local script_vers = 1.0
local script_vers_text = "v1.0" -- Название нашей версии. В будущем будем её выводить ползователю.

local update_url = 'https://raw.githubusercontent.com/pid228228/auto-update/main/update.ini' -- Путь к ini файлу. Позже нам понадобиться.
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = '' -- Путь скрипту.
local script_path = thisScript().path
function check_update() -- Создаём функцию которая будет проверять наличие обновлений при запуске скрипта.
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then -- Сверяем версию в скрипте и в ini файле на github
                sampAddChatMessage("{FFFFFF}Имеется {32CD32}новая {FFFFFF}версия скрипта. Версия: {32CD32}"..updateIni.info.vers_text..". {FFFFFF}/update что-бы обновить", 0xFF0000) -- Сообщаем о новой версии.
                update_found == true -- если обновление найдено, ставим переменной значение true
            end
            os.remove(update_path)
        end
    end)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    check_update()

    if update_found then -- Если найдено обновление, регистрируем команду /update.
        sampRegisterChatCommand('update' function()  -- Если пользователь напишет команду, начнётся обновление.
            update_state = true -- Если человек пропишет /update, скрипт обновится.
        end)
    else
        sampAddChatMessage('{FFFFFF}Нету доступных обновлений!')
    end

    while true do
        wait(0)
  
        if update_state then -- Если человек напишет /update и обновлени есть, начнётся скаачивание скрипта.
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("{FFFFFF}Скрипт {32CD32}успешно {FFFFFF}обновлён.", 0xFF0000)
                end
            end)
            break
        end
  
    end 
end


local tag = '{0000FF} [Rvanka by Ega] {000000}- '
local rvanka = false


function main()
    if not isSampAvailable() then return false end

    sampAddChatMessage(tag .. '{3333ff}Хуйня {ffffff}нихуя не загружена.', -1)

    sampRegisterChatCommand('pid', function(id)
        if not id or not tonumber(id) then
            rvanka = false
            sampAddChatMessage(tag .. '{ffffff}Хуй сидит на этом айди', -1)
        end
        if not isCharInAnyCar(PLAYER_PED) then
            sampAddChatMessage(tag .. '{ffffff}Пошел нахуй, ты не в авто', -1)
            rvanka = false
        end

        local result,ped = sampGetCharHandleBySampPlayerId(id)
        if result then
            if doesCharExist(ped) then
                local px, py, pz = getCharCoordinates(ped)
                local ax, ay, az = getCharCoordinates(PLAYER_PED)
                local dist = getDistanceBetweenCoords3d(px, py, pz, ax, ay, az)
                if dist <= 29 then
                    _, pid = sampGetPlayerIdByCharHandle(ped)
                    victimPed = ped
                    rvanka = not rvanka
                    printStringNow(rvanka and 'Rvanka - ~g~ON' or 'Rvanka - ~r~OFF',1000)
                end
            end
        end
    end)

    wait(-1)
end


function ev.onSendVehicleSync(data)
    if rvanka then
        local px, py, pz = getCharCoordinates(victimPed) 
        local ax, ay, az = getCharCoordinates(PLAYER_PED)
        local dist = getDistanceBetweenCoords3d(px, py, pz, ax, ay, az)

        if dist <= 29 then
            if sampIsPlayerConnected(pid) and sampGetCharHandleBySampPlayerId(pid) then
                data.position = {px,py,pz - 0.7}
                data.moveSpeed = {0,0,1}
            end
        else
            rvanka = false
            sampAddChatMessage("Пошел нахуй, он далеко.", -1)
        end
    end
end