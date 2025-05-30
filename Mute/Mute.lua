--[[ 
        This lua attempts to detect auto-spammers and then selectively mute their shouts/yells.
        It does so by keeping track of each individual's chat messages and the interval that they occur.
        After 3 regular intervals of the same chat message, the spammer is added to a temporary mute list.
        The mute list is emptied after every zone.
 ]]

require('luau')
packets = require('packets')
files = require('files')

verbose = false

muted = {}
autoMuter = {}

autoEmptyMuteList = true

--Register Incoming Chunks for chat parsing
windower.register_event('incoming chunk', function(id,data)
    if id == 0x017 then -- 0x017 - Chat.
        local chat = packets.parse('incoming', data)
    
        local timestamp = os.time()
        local sender = windower.convert_auto_trans(chat['Sender Name']):lower():gsub('%W','')
        local message = windower.convert_auto_trans(chat['Message']):lower():gsub('%W','')

        if muted[sender] then
            if verbose then
                windower.add_to_chat(8, "Blocked chat from "..sender)
            end
            return true
        else
            if autoMuter[sender] then
                local spammer = autoMuter[sender]

                if spammer.message == message then
                    local interval = timestamp - spammer.timestamp
                    if spammer.interval > interval - 2 and spammer.interval < interval + 2 then
                        if verbose then
                            windower.add_to_chat(24, sender.." is likely botting")
                        end
                        spammer.count = spammer.count + 1
                    else
                        if verbose then
                            --windower.add_to_chat(8, sender.." is normal")
                        end
                        spammer.count = 1
                    end
                    spammer.timestamp = timestamp
                    spammer.interval = interval
                    if verbose then
                        windower.add_to_chat(8, sender.." spammed the same thing "..interval.." seconds ago")
                    end
                end

                autoMuter[sender] = spammer
                
                if spammer.count >= 3 then
                    windower.add_to_chat(163, "*** Auto-muting "..sender)
                    muted[sender] = true
                    return true
                end
            else
                if verbose then
                    windower.add_to_chat(8, "Now tracking "..sender)
                end
                local spammer = {}
                spammer.message = message
                spammer.timestamp = timestamp
                spammer.count = 1
                spammer.interval = 0
                autoMuter[sender] = spammer
            end
        end
    end
end)

windower.register_event('zone change', function(new_id, old_id)
    if autoEmptyMuteList then
        if verbose then
            windower.add_to_chat(8, "Zone change, emptying memory")
        end
        muted = {}
        autoMuter = {}
    end
end)

windower.register_event('unhandled command', function(command, ...)
    if command == "mute" then
        local args = T{...}:map(string.lower)

        if args[1] == "print" then
            windower.add_to_chat(163, "Currently muted:")
            for k,v in pairs(muted) do
                windower.add_to_chat(8, " -"..k)
            end
        elseif args[1] == "add" then
            windower.add_to_chat(8, "Muting "..args[2])
            muted[string.lower(args[2])] = true
        elseif args[1] == "remove" then
            windower.add_to_chat(8, "Unmuting "..args[2])
            muted[string.lower(args[2])] = false
        elseif args[1] == "clear" then
            windower.add_to_chat(8, "Clearing mutelist")
            muted = {}
            autoMuter = {}
        else
            windower.add_to_chat(8, "Muting "..args[1])
            muted[string.lower(args[1])] = true
        end
    end
end)

function log(...)
    local date = os.date('*t')

    local file = files.new('../../logs/%s_%.4u.%.2u.%.2u.log':format('mute', date.year, date.month, date.day))
    if not file:exists() then
        file:create()
    end
    local args = {...}
    for key,val in ipairs(args) do
        file:append('%s\n':format(tostring(val)))
    end
    file:append('-----\n')
 end
