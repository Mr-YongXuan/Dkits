--Author:NatanashaKatyushaRabbit
--Version:1.0.0 Alpha

Dkits = Dkits or {}

--Dkits Config
Dkits.MissionConfig = {

    --show players the server name
    --向玩家们展示的服务器名称
    serverName = "兔兔服",

    --the server administrators group members
    --服务器管理员列表
    administrators = {'c3c8356c929ed5c9be4bb9019f98e69e', '9afafa161df8318bc9b494d1de15eaec', '9b3a5d870a74efef251b5dbbe76048e6', '6e56db6af504909ffdefc3fb2c7a7439', 'da5468933dcd3789c82218e834d27282'},

    switchGetOn   = true,
    switchPostOn  = true,

    --every 120 frame push data once
    --每当帧率计数器达到120帧时提交一次数据,值得注意的是该值越低则数据提交速率越快,cpu使用率越高.
    --优化提示:过低的值将导致多人游戏中的玩家卡顿
    dataPushRate = 120,
    
    --ignore something in world event - accept empty as {}
    --忽略掉某些不需要的事件 比如 18和19为玩家启动和停止引擎事件
    --这些数据将被丢弃而不被提交 本配置可以接受空值 {}
    ignoreEventid = {18, 19},

    --Where is the data going? Yes! Please set your api interface url, method must be post.
    --这里填写编写好的api接口,因为最终数据都会被提交到你所设置的接口之上
    dataPostUrl = "http://127.0.0.1/DataPort1",

    --Is it necessary to verify the reliability of submitted data?
    --if apiAuthentication == true then apikey and apisec in http request body
    --Note: validation is simple, Not absolutely necessarily reliable
    --是否需要在请求数据中带入apikey 和 apisec参数作为简单验证手段?
    apiAuthentication = false,
    --apiAuthentication=false then apikey is invalid | apiAuthentication=false则本参数无效
    apiKey = 'test',
    -- apiAuthentication=false this apisec is invalid | apiAuthentication=false则本参数无效
    apiSec = 'password'
}


package.path = package.path .. ';.\\LuaSocket\\?.lua'
package.cpath = package.cpath .. ';.\\LuaSocket\\?.dll'
Dkits.http = require('http')
Dkits.ltn12 = require('ltn12')


function Dkits.info(msg)
    msg = tostring(msg)
    local newMsg = 'DKits INFO: ' .. msg
    net.log(newMsg)
end


function Dkits.dostring(str)
	local func, err = loadstring(str)
	if func then
		return true, func()
	end
	return false, err
end


function Dkits.eval(str)
	st, rs = Dkits.dostring('return ' .. str)
	if st then return rs end
	return nil
end


function Dkits.nameToUcid(playerName)
    for _, uid in pairs(net.get_player_list()) do
        if playerName == net.get_player_info(uid, 'name') then
            return net.get_player_info(uid, 'ucid')
        end
    end

    return nil
end


function Dkits.showPlayers(uid)
    msg = '当前' .. Dkits.MissionConfig['serverName'] .. '玩家:\n'
    for _, uid in pairs(net.get_player_list()) do
        msg = msg .. '  ' .. net.get_player_info(uid, 'name') .. ' = ' .. uid .. '\n'
    end
    net.send_chat_to(msg, uid)
end


function Dkits.split(str, reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end


function Dkits.strInTab(str, tab)
    for _, v in pairs(tab) do
        if str == v then return true end
    end

    return false
end


function Dkits.ToStringEx(value)
    if type(value) == 'table' then
        return Dkits.TableToStr(value)
    elseif type(value) == 'string' then
        return "\'" .. value .. "\'"
    else
        return tostring(value)
    end
end


function Dkits.TableToStr(t)
    if t == nil then return "" end
    local retstr = "{"

    local i = 1
    for key, value in pairs(t) do
        local signal = ","
        if i == 1 then signal = "" end

        if key == i then
            retstr = retstr .. signal .. Dkits.ToStringEx(value)
        else
            if type(key) == 'number' or type(key) == 'string' then
                retstr =
                    retstr .. signal .. Dkits.ToStringEx(key) .. "=" ..
                    Dkits.ToStringEx(value)
            else
                if type(key) == 'userdata' then
                    retstr = retstr .. signal .. "*s" ..
                    Dkits.TableToStr(getmetatable(key)) .. "*e" ..
                                 "=" .. Dkits.ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. "=" ..
                    Dkits.ToStringEx(value)
                end
            end
        end

        i = i + 1
    end

    retstr = retstr .. "}"
    return retstr
end


function Dkits.postData(data)
    if Dkits.MissionConfig['apiAuthentication'] then
        request_body = 'apikey=' .. Dkits.MissionConfig['apiKey'] .. '&apisec=' .. Dkits.MissionConfig['apiSec'] .. '&data=' .. data
    else
        request_body = 'data=' .. data
    end
    
    local response_body = {}
       
    Dkits.http.request{
        url = Dkits.MissionConfig['dataPostUrl'],
        method = "POST",
        headers =
            {
                ["Content-Type"] = "application/x-www-form-urlencoded";
                ["Content-Length"] = #request_body;
            },
            source = Dkits.ltn12.source.string(request_body),
            sink = Dkits.ltn12.sink.table(response_body),
        }
        rstab = Dkits.eval(table.concat(response_body))
        if not rstab then
            Dkits.info('ERROR = Dkits.eval func failed, str = ' .. table.concat(response_body))
        end
        return rstab
end


------------------------>===Dkits Missions Control===<------------------------
Dkits.gameInjection = {}
Dkits.commonArgs = {
    FrameCount = 0,
    MissionStart = false
}

Dkits.gameInjection[#Dkits.gameInjection+1] = [==[
    local Dkits = Dkits or {}
    Dkits.eventMQ = {} -- Game event queues
    Dkits.eventHandler = {}

    Dkits.sameEvent = {}
    Dkits.eventNameMap = {
        1  = "shot",
        2  = "hit",
        3  = "takeoff",
        4  = "land",
        5  = "crash",
        6  = "ejection",
        7  = "refuelingStart",
        8  = "dead",
        9  = "pilotDead",
        10 = "baseCaptured",
        11 = "missionStart",
        12 = "missionEnd",
        13 = "tookControl", -- hoggit标红项
        14 = "refuelingStop",
        15 = "birth",
        16 = "pilotFailure",
        17 = "detailedFailure" -- hoggit未知项
    }

    function Dkits.ToStringEx(value)
        if type(value) == 'table' then
            return Dkits.TableToStr(value)
        elseif type(value) == 'string' then
            return "\'" .. value .. "\'"
        else
            return tostring(value)
        end
    end
    
    
    function Dkits.TableToStr(t)
        if t == nil then return "" end
        local retstr = "{"
    
        local i = 1
        for key, value in pairs(t) do
            local signal = ","
            if i == 1 then signal = "" end
    
            if key == i then
                retstr = retstr .. signal .. Dkits.ToStringEx(value)
            else
                if type(key) == 'number' or type(key) == 'string' then
                    retstr =
                        retstr .. signal .. '[' .. Dkits.ToStringEx(key) .. "]=" ..
                        Dkits.ToStringEx(value)
                else
                    if type(key) == 'userdata' then
                        retstr = retstr .. signal .. "*s" ..
                        Dkits.TableToStr(getmetatable(key)) .. "*e" ..
                                     "=" .. Dkits.ToStringEx(value)
                    else
                        retstr = retstr .. signal .. key .. "=" ..
                        Dkits.ToStringEx(value)
                    end
                end
            end
    
            i = i + 1
        end
    
        retstr = retstr .. "}"
        return retstr
    end

    
    function Dkits.eventHandler:onEvent(_event)
        env.info('Dkits event id : ' .. _event.id, false)

        --此处将在本周重构 -- 重构完成之前 不用新增代码在这个判断上
        --player takeoff event rebuild
        if _event.id == 3 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'TakeOff',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign(),
                coalition  = _event.initiator:getCoalition(),
                baseName   = _event.place:getCallsign()
            }

        --player land event rebuild
        elseif _event.id == 4 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'land',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign(),
                coalition  = _event.initiator:getCoalition(),
                baseName   = _event.place:getCallsign()
            }
        
        --player crash event rebuild
        elseif _event.id == 5 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'crash',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign(),
                coalition  = _event.initiator:getCoalition()
            }

        --player ejection event rebuild
        elseif _event.id == 6 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'ejection',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign()
            }
        
        --player refuelingStart event rebuild
        elseif _event.id == 7 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'refuelingStart',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign()
            }
        
        --objectDead event rebuild
        elseif _event.id == 8 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'dead',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign()
            }

        --player dead event rebuild
        elseif _event.id == 7 then
            Dkits.eventMQ[#Dkits.eventMQ+1] = {
                event = 'pilotDead',
                time = _event.time,
                playerName = _event.initiator:getPlayerName() or "",
                playerType = _event.initiator:getTypeName(),
                pilotName  = _event.initiator:getName(),
                callSign   = _event.initiator:getCallsign()
            }
        end
    end
    

    function getNextEvent()
        if Dkits.eventMQ then
            _event = Dkits.eventMQ[1]
            table.remove(Dkits.eventMQ, 1)
            return Dkits.TableToStr(_event)
        end
        return ''
    end


    world.addEventHandler(Dkits.eventHandler)
]==]


function Dkits.onSimulationFrame()
    if DCS.isServer() and DCS.isMultiplayer() and Dkits.commonArgs['MissionStart'] then
        if Dkits.commonArgs['FrameCount'] >= Dkits.MissionConfig['dataPushRate'] then
            Dkits.commonArgs['FrameCount'] = 0

            --check event
            local _event, err = net.dostring_in('server', 'return getNextEvent()')
            if err and _event ~= '' then
                Dkits.info(_event) --debug remove before production
                event = Dkits.eval(_event)

                -- add ucid to string if have playerName
                if event['playerName'] ~= '' then
                    event['ucid'] = Dkits.nameToUcid(event['playerName'])
                else
                    event['ucid'] = ''
                end
                Dkits.postData(Dkits.TableToStr(event))
            else
                if _event ~= '' then
                    Dkits.info('ERROR = ' .. _event)
                end
            end

        else --nothing to do
            Dkits.commonArgs['FrameCount'] = Dkits.commonArgs['FrameCount'] + 1
        end
    end
end


function Dkits.onMissionLoadEnd()
    local rs, err = net.dostring_in('server', Dkits.gameInjection[1])
    if err then
        Dkits.commonArgs['MissionStart'] = true
        Dkits.info('inGameScripts loaded!')
    else
        Dkits.info('ERROR = Can not load inGameScripts! reason:' .. rs)
    end
end


------------------------>===Dkits Server Control===<------------------------
function Dkits.onPlayerTrySendChat(playerID, msg, all)
    msg = Dkits.split(msg, ' ')
    if msg[1] == '-list' or msg[1] == '-l' or msg[1] == '-列表' then
        if Dkits.strInTab(net.get_player_info(playerID, 'ucid'), Dkits.MissionConfig['administrators']) then
            Dkits.showPlayers(playerID)
        else
            net.send_chat_to('您并非' .. Dkits.MissionConfig['serverName'] .. '的管理员!', playerID)
        end
    
    elseif msg[1] == '-kick' or msg[1] == '-k' or msg[1] == '-踢出' then
        if Dkits.strInTab(net.get_player_info(playerID, 'ucid'), Dkits.MissionConfig['administrators']) then
            net.kick(tonumber(msg[2]), '您已被管理员:' .. net.get_player_info(playerID, 'name') .. ' 踢出了服务器,请遵守' .. Dkits.MissionConfig['serverName'] .. '的玩家公约!')
        else
            net.send_chat_to('您并非' .. Dkits.MissionConfig['serverName'] .. '的管理员!', playerID)
        end
    
    elseif msg[1] == '-ban' or msg[1] == '-b' or msg[1] == '-封禁' then
        if Dkits.strInTab(net.get_player_info(playerID, 'ucid'), Dkits.MissionConfig['administrators']) then
            net.banlist_add(tonumber(msg[2]), 31536000, '您已被管理员:' .. net.get_player_info(playerID, 'name') .. ' 封禁! 时长为:365天')
        else
            net.send_chat_to('您并非' .. Dkits.MissionConfig['serverName'] .. '的管理员!', playerID)
        end
    
    elseif msg[1] == '-run' or msg[1] == '-r' or msg[1] == '-执行' then
        st, rs = Dkits.dostring(msg[2])
        if st then
            net.send_chat_to('命令执行成功 返回值如下:\n' .. rs, playerID)
        else
            net.send_chat_to('命令执行失败 原因如下:\n' .. rs, playerID)
        end
    end
end


DCS.setUserCallbacks(Dkits)
Dkits.info('DKits.lua loaded!')
