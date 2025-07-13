-- showset.lua
_addon.name = 'ShowSet'
_addon.author = 'DreamEyes'
_addon.version = '1.0'
_addon.commands = {'showset'}

local texts = require('texts')
local config = require('config')
local res = require('resources')



----------------------- ACCURACY & SET DISPLAY HUD -----------------------

-- Default settings
local default_settings = {
    x = 1420,
    y = 835,
    text = {
        font = 'Segoe UI Emoji',
        size = 9.5,
        padding = 2,
        stroke = {
            width = 2,
            alpha = 200,
            red = 50,
            green = 50,
            blue = 50,
        },
    },
    bg_red = 0,
    bg_green = 0,
    bg_blue = 5,
    bg_alpha = 100,
    show_rolls = true,
}

local settings = config.load(default_settings)
local player = windower.ffxi.get_player()
local job_short = player and player.main_job:lower()


-- Get the HUD background color based on job
local function get_job_background_color(job)
    local color = settings.showset.background[job]

    -- If job colour is not defined, use default
    if color then return color end
    return {
        red = settings.bg_red or 0,
        green = settings.bg_green or 0,
        blue = settings.bg_blue or 0,
        alpha = settings.bg_alpha or 100,
    }
end

-- Create HUD showing accuracy, gearset and AutoWS mode
local job_color = get_job_background_color(job_short)

local showset_display = texts.new({
    pos = {x = settings.showset.x, y = settings.showset.y},
    text = {
        font = settings.showset.text.font,
        size = settings.showset.text.size,
        stroke = {
            width = settings.showset.text.stroke.width,
            alpha = settings.showset.text.stroke.alpha,
            red = settings.showset.text.stroke.red,
            green = settings.showset.text.stroke.green,
            blue = settings.showset.text.stroke.blue,
        },
    },
    
   bg = {
        red = job_color.red,
        green = job_color.green,
        blue = job_color.blue,
        alpha = job_color.alpha,
    },
    padding = settings.showset.padding,
    flags = {draggable = true},
})

-- Initialise variables used for the HUD
local total_swings, total_hits, total_crits = 0, 0, 0
local idle_mode, engage_mode, autows_mode = '--', '--', 'Off'
local wsaccuracy_mode = 'Normal'
local luzaf_ring = 'On'

-- Define icons for BLU spell set
local function update_equipped_blu_spell_icon()
    local player = windower.ffxi.get_player()

    -- Reset by default
    equipped_blu_spell = nil

    if not player or player.main_job ~= 'BLU' then
        return
    end

    -- These are the unique spells checked to determine which BLU spell set is equipped (e.g. Magic, Treasure Hunter, etc.)
    local spell_icon_map = {
        ["Spectral Floe"]     = "🔮",
        ["Anvil Lightning"]   = "🧿",
        ["Amorphic Spikes"]   = "🗝️",
    }

    local blu_data = windower.ffxi.get_mjob_data()
    if blu_data and blu_data.spells then
        for _, spell_id in ipairs(blu_data.spells) do
            local spell = res.spells[spell_id]
            if spell then
                local icon = spell_icon_map[spell.en]
                if icon then
                    equipped_blu_spell = icon
                    break
                end
            end
        end
    end
end

-- Update HUD display
local function update_showset_display()

    local accuracy_percent = (total_swings > 0) and math.floor((total_hits / total_swings) * 100) or 100
    local crit_percent = (total_hits > 0) and math.floor((total_crits / total_hits) * 100) or 0
    local total_misses = total_swings - total_hits

    -- This is what will be displayed on the HUD (1st line).
    local accuracy_info = (total_swings > 0) 
    and string.format("🏹 %d%% ( %d | %d%% )", accuracy_percent, total_misses, crit_percent)
    or "🏹 --                      "

    local wsaccuracy_info = (wsaccuracy_mode ~= 'Normal') and ' 🧿' or ''
    local luzaf_ring_info = (luzaf_ring == 'Off') and ' 💍❌' or '' 
    update_equipped_blu_spell_icon()
    local blu_magic_set_info = equipped_blu_spell or ""

    -- This is what will be displayed on the HUD (2nd line).
    local gearset_info = string.format("⚔️ %s %s %s %s\n 🧍  %s", engage_mode, wsaccuracy_info, luzaf_ring_info, blu_magic_set_info, idle_mode)
    
    -- This is what will be displayed on the HUD (3rd line) only if the AutoWS mode is not 'Off'.
    local autows_info = (autows_mode ~= 'Off') and string.format("⚙: \\cs(205,205,125)%s\\cr", autows_mode) or ''

    local text = accuracy_info .. '\n' .. gearset_info
    if autows_info ~= '' then
        text = text .. '\n' .. autows_info
    end

    if settings.showset.show then
        showset_display:text(text)
        showset_display:show()
    end
end

-- Event: Incoming text - update HUD when AzureSets (BLU addon) is mentioned to display an BLU spell set icon based on equipped spell set.
windower.register_event('incoming text', function(original, modified, color)
    if color == 207 and modified:find('AzureSets:') then
        update_equipped_blu_spell_icon()
        update_showset_display()
    end
end)

-- Track melee accuracy
windower.register_event('action', function(act)

    local player = windower.ffxi.get_player()
    if not player or act.actor_id ~= player.id or act.category ~= 1 then return end

    for _, target in ipairs(act.targets) do
        for _, action in ipairs(target.actions) do
            total_swings = total_swings + 1
            if action.message == 1 or action.message == 67 or action.message == 352 then
                total_hits = total_hits + 1
                if action.message == 67 then
                    total_crits = total_crits + 1
                end
            end
        end
    end

    update_showset_display()
end)

-- Update HUD on job change
windower.register_event('job change', function()
    
    total_swings, total_hits, total_crits = 0, 0, 0
    wsaccuracy_mode = 'Normal'
    luzaf_ring = 'On'

    local player = windower.ffxi.get_player()
    local job_short = player and player.main_job:lower()
    local job_color = get_job_background_color(job_short)

    -- Update the HUD background color
    showset_display:bg_color(job_color.red, job_color.green, job_color.blue)
    showset_display:bg_alpha(job_color.alpha)

 -- Delay update for BLU spell detection
    coroutine.schedule(function()
        update_equipped_blu_spell_icon()
        update_showset_display()
    end, 2) -- wait 2 seconds before updating
end)

-- Function to set HUD visibility (true to show, false to hide)
local function set_hud_visibility(visible)
    if not showset_display then return end
    if visible and showset_display_hidden then
        showset_display:show()
        showset_display_hidden = false
    elseif not visible and not showset_display_hidden then
        showset_display:hide()
        showset_display_hidden = true
    end
end

local function update_hud_visibility()
    local player = windower.ffxi.get_player()
    local is_cutscene = player and player.status == 4
    set_hud_visibility(not is_cutscene)
end

-- Auto-update on login
windower.register_event('login', function()
    coroutine.schedule(function()
        update_equipped_blu_spell_icon()
        update_showset_display()
        set_hud_visibility(true)
    end, 3)
end)

-- Hide HUD on logout to prevent showing on title screen
windower.register_event('logout', function()
    set_hud_visibility(false)
end)


-- Event: Zone change - reset counters and update display. Comment if you don't want to reset counters on zone change.
windower.register_event('zone change', function()
    total_swings, total_hits, total_crits = 0, 0, 0
    coroutine.schedule(update_showset_display, 3)
end)

--Hide HUD when interacting with NPC or loading
local showset_display_hidden = false

-- Event: Cutscene/menu/combat status changed
windower.register_event('status change', update_hud_visibility)

-- Event: Zoning - hide HUD for safety
windower.register_event('zone change', function()
    set_hud_visibility(false)
end)

-- If AutoWS is enabled, use Weapon Skill automatically when TP reaches 1000
windower.register_event('tp change', function(tp)
    local player = windower.ffxi.get_player() -- Refresh live player status

    if player and player.status == 1 and autows_mode ~= 'Off' and tp >= 1000 then
        windower.send_command('input /ws "' .. autows_mode .. '" <t>')
    end
end)








----------------------- CORSAIR ROLL TRACKER HUD -----------------------

-- Create HUD showing COR rolls
local showroll_display = texts.new({
    pos = {x = settings.showroll.x, y = settings.showroll.y},
    text = {
        font = settings.showroll.text.font,
        size = settings.showroll.text.size,
        stroke = {
            width = settings.showroll.text.stroke.width,
            alpha = settings.showroll.text.stroke.alpha,
            red = settings.showroll.text.stroke.red,
            green = settings.showroll.text.stroke.green,
            blue = settings.showroll.text.stroke.blue,
        },
    },
    bg = {
        red = settings.showroll.background.red,
        green = settings.showroll.background.green,
        blue = settings.showroll.background.blue,
        alpha = settings.showroll.background.alpha,        
    },
    padding = settings.showroll.padding,
    flags = {draggable = true},
})

-- Set icons for lucky, unlucky, and 11 roll
-- The \\cs[...]\\cr is used to color the text in Windower
local function get_roll_icon(roll, lucky, unlucky)
    if roll == lucky then return "\\cs(110,190,135)🍀\\cr"
    elseif roll == unlucky then return "\\cs(235,110,110)😥\\cr"
    elseif roll == 11 then return "\\cs(205,205,125)🎉\\cr"
    else return "" end
end

-- Set the color for the roll number based on lucky, unlucky, and 11 roll
local function color_roll_number(roll, lucky, unlucky)
    if roll == lucky then return "\\cs(110,190,135)"..roll.."\\cr"
    elseif roll == unlucky then return "\\cs(240,60,60)"..roll.."\\cr"
    elseif roll == 11 then return "\\cs(205,205,125)"..roll.."\\cr"
    else return tostring(roll) end
end

-- Update the display with the current roll information
windower.register_event('action', function(act)
    if not settings.show_rolls then return end

    local player = windower.ffxi.get_player()
    if not player or act.actor_id ~= player.id then return end

    local affected_players = 0

    for _, target in ipairs(act.targets) do
        local mob = windower.ffxi.get_mob_by_id(target.id)
        if mob and not mob.is_npc and not mob.is_pet then
            affected_players = affected_players + 1
        end
    end

    if act.category == 6 then
        local ability = res.job_abilities[act.param]
        if ability and Rolls[ability.en] then
            local roll = act.targets[1].actions[1].param
            local lucky = Rolls[ability.en].Lucky
            local unlucky = Rolls[ability.en].Unlucky

            local icon = get_roll_icon(roll, lucky, unlucky)
            local colored = color_roll_number(roll, lucky, unlucky)
            local text = string.format(
                "🎲 %s  🧍%s\n            %s\n👍 \\cs(110,190,135)%d\\cr   [  %s  ]  👎 \\cs(240,60,60)%d\\cr",
                ability.en, affected_players, icon, lucky, colored, unlucky
            )

            if settings.showroll.show then
                showroll_display:text(text)
                showroll_display:show()
            end
        end
    end
end)

-- Hide the roll display when the player gains a specific buff (e.g. Burst)
windower.register_event('gain buff', function(buff_id)
    -- print('Buff gained:', buff_id)
    
    if buff_id == 309 then
        showroll_display:hide()
    end
end)

-- Hide the roll display when the player loses a specific buff (e.g. Double Up)
windower.register_event('lose buff', function(buff_id)
    -- print('Buff lost:', buff_id)
    if buff_id == 308 then
        showroll_display:hide()
    end
end)

-- Show all commands when typing //showset help in the console
local function print_help()
    windower.add_to_chat(207, "[ShowSet Commands]")
    windower.add_to_chat(207, "//showset help                   - Show this help menu")
    windower.add_to_chat(207, "//showset idle [mode]           - Set Idle mode (e.g., Normal, PDT)")
    windower.add_to_chat(207, "//showset engage [mode]       - Set Engage mode (e.g., Acc, Hybrid)")
    windower.add_to_chat(207, "//showset autows [name]       - Set Auto WS (e.g., Savage Blade)")
    windower.add_to_chat(207, "//showset wsaccuracy [mode]  - Set WS accuracy mode to display the icon (Normal or Accuracy)")
    windower.add_to_chat(207, "//showset luzaf [On|Off]        - Toggle Luzaf Ring icon display")
    windower.add_to_chat(207, "//showset showset [on|off]     - Show/hide ShowSet HUD")
    windower.add_to_chat(207, "//showset showroll [on|off]    - Show/hide Roll HUD")
    windower.add_to_chat(207, "//showset resetaccuracy        - Reset accuracy/crit tracking")
    windower.add_to_chat(207, "//showset save                   - Save HUD positions to settings.xml")
    windower.add_to_chat(207, "//showset refresh                - Force refresh the HUDs")
end

-- Custom commands for the ShowSet and ShowRoll HUD (can be triggered from GearSwap or manually)
windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or ''

    -- Update Idle set with the argument value
    if cmd == 'idle' and args[1] then
        idle_mode = table.concat(args, ' ')
    
    -- Update Engage set with the argument value
    elseif cmd == 'engage' and args[1] then
        engage_mode = table.concat(args, ' ')
    
    -- Update AutoWS mode with the argument value
    elseif cmd == 'autows' and args[1] then
        autows_mode = table.concat(args, ' ')
    
    -- Reset accuracy counters
    elseif cmd == 'resetaccuracy' then
        total_swings, total_hits, total_crits = 0, 0, 0
    
    -- Display or hide the WS Accuracy icon by setting the WS Accuracy mode to Normal or Accuracy
    elseif cmd == 'wsaccuracy' and args[1] then
        wsaccuracy_mode = args[1]

    -- Display or hide the "No Luzaf's Ring equipped" icon
    elseif cmd == 'luzaf' and args[1] then
        luzaf_ring = args[1]

    -- Show or hide the ShowSet HUD
    elseif cmd == 'showset' and args[1] then
        if args[1]:lower() == 'on' then
            settings.showset.show = true
            showset_display:show()
            config.save(settings)
            return
        elseif args[1]:lower() == 'off' then
            settings.showset.show = false
            showset_display:hide()
            config.save(settings)
            return
        end

    -- Show or hide the ShowRoll HUD
    elseif cmd == 'showroll' and args[1] then
        if args[1]:lower() == 'on' then
            settings.showroll.show = true
            showroll_display:show()
            config.save(settings)
            return
        elseif args[1]:lower() == 'off' then
            settings.showroll.show = false
            showroll_display:hide()
            config.save(settings)
            return
        end

        -- Save current HUD positions in settings
        elseif cmd == 'save' then
            settings.showset.x = showset_display:pos_x()
            settings.showset.y = showset_display:pos_y()
            settings.showroll.x = showroll_display:pos_x()
            settings.showroll.y = showroll_display:pos_y()
            config.save(settings)
            windower.add_to_chat(200, '[ShowSet] HUD positions saved.')

        -- Refresh the HUD display
        elseif cmd == 'refresh' then
            update_equipped_blu_spell_icon()
            update_showset_display()
            return

        elseif cmd == 'help' then
            print_help()
            return
    end
    
    update_showset_display()
end)




Rolls = {
	["Magus's Roll"] 		=	{Lucky = 2,	Unlucky = 6	},	["Choral Roll"] 		=	{Lucky = 2,	Unlucky = 6	},	["Samurai Roll"] 		=	{Lucky = 2,	Unlucky = 6	},	
	["Scholar's Roll"]		=	{Lucky = 2,	Unlucky = 6	},	["Caster's Roll"]		=	{Lucky = 2,	Unlucky = 7	},	["Companion's Roll"]	=	{Lucky = 2,	Unlucky = 10},
	["Naturalist's Roll"]	=	{Lucky = 3,	Unlucky = 7	},	["Healer's Roll"]		=	{Lucky = 3,	Unlucky = 7	},	["Monk's Roll"]			=	{Lucky = 3,	Unlucky = 7	},	
	["Puppet Roll"]			=	{Lucky = 3,	Unlucky = 7	},	["Gallant's Roll"]		=	{Lucky = 3,	Unlucky = 7	},	["Dancer's Roll"]		=	{Lucky = 3,	Unlucky = 7	},
	["Bolter's Roll"]		=	{Lucky = 3,	Unlucky = 9	},	["Courser's Roll"]		=	{Lucky = 3,	Unlucky = 9	},	["Allies' Roll"]		=	{Lucky = 3,	Unlucky = 10},	
	["Runeist's Roll"]		=	{Lucky = 4,	Unlucky = 8	}, 	["Ninja's Roll"]		=	{Lucky = 4,	Unlucky = 8	},	["Hunter's Roll"]		=	{Lucky = 4,	Unlucky = 8	},
	["Chaos Roll"]			=	{Lucky = 4,	Unlucky = 8	},	["Drachen Roll"]		=	{Lucky = 4,	Unlucky = 8	},	["Beast Roll"]			=	{Lucky = 4,	Unlucky = 8	},	
	["Warlock's Roll"] 		=	{Lucky = 4,	Unlucky = 8	},	["Avenger's Roll"]		=	{Lucky = 4,	Unlucky = 8	},	["Blitzer's Roll"]		=	{Lucky = 4,	Unlucky = 9	},
	["Miser's Roll"]		=	{Lucky = 5,	Unlucky = 7	},	["Tactician's Roll"]	=	{Lucky = 5,	Unlucky = 8	},	["Corsair's Roll"]		=	{Lucky = 5,	Unlucky = 9	},	
	["Evoker's Roll"] 		=	{Lucky = 5,	Unlucky = 9	},	["Rogue's Roll"] 		=	{Lucky = 5,	Unlucky = 9	},	["Fighter's Roll"] 		=	{Lucky = 5,	Unlucky = 9	},	
	["Wizard's Roll"] 		=	{Lucky = 5,	Unlucky = 9	},
}

update_equipped_blu_spell_icon()
update_showset_display()