## ■ INTRODUCTION:

ShowSet is a Windower addon for Final Fantasy XI that provides a customizable HUD displaying your gear modes (Normal, Accuracy, DT, etc.), accuracy%, visually track your COR rolls and set an automatic Weapon Skill mode.

There are 2 HUDs:
- ShowSet (displays your accuracy, Idle/Engage set mode and AutoWS)
- ShowRoll (track your Corsair's rolls).

Each HUD can be toggled individually.

## ■ Features:

- **Shows your current accuracy% (incl. miss and crit%) and shows your current Idle and Engage set mode.**
<br>![alt text](https://i.imgur.com/E2fxKq4.png)

- **Shows additional icons such as:**
    <ul>
    <li>Weapon Skill accuracy mode (🧿)</li>
    <li>Your COR Luzaf Ring mode (💍❌ if not equipped)</li>
    <li>Your BLU Spell set (Magic: 🔮, Melee Accuracy: 🧿, Treasure Hunter: 🗝️)</li>
    </ul>
    
  ![alt text](https://i.imgur.com/mymwaGZ.png)


- **As Corsair, shows your current rolls, lucky and unlucky numbers.**
  <br>![alt text](https://i.imgur.com/aRJBgT8.png)

- **When AutoWS is enabled, shows the current Weapon Skill that will automatically be used when reaching 1000TP.**
  <br>![alt text](https://i.imgur.com/wntplNH.png)

<h2>■ How to install:</h2>

- Place the "ShowSet" folder into your Windower4\addon\ folder.
- In Game, type `//lua load showset` to launch the addon.

<h2>■ How to setup:</h2>

**🎲ShowRoll HUD:**

You don't have to set up anything. When you roll as Corsair, the ShowRoll HUD will automatically display.
<br>This HUD can be toggled on/off in the settings.xml or via the in-game command //showset showroll [on/off]

**⚔️ShowSet:**

**How to display your Idle/Engage set mode on the HUD:**

The Idle/Engage set mode can be changed via the commands `//showset idle [Normal|PDT, etc.]` and `//showset engage [Normal|Accuracy|PDT, etc.]`


**GearSwap integration:**

- **Option 1:**
  <br>If you change your Idle/Engage mode via a "state", add the function "update_showset_display" at the bottom of your lua and call this function whenever you change your Idle/Engage mode.

<pre>function get_sets()
    
    include('Modes')

    state = {}
    state.IdleMode = M{'Normal', 'DT'}
    state.EngageMode = M{'Normal', 'Accuracy', 'DT', 'TH'}
    state.AutoWS = M{'Off', 'Tachi: Fudo', 'Tachi: Shoha'} -- Change the Weapon Skills you want to spam automatically when you reach 1000 TP.

    update_showset_display()

    [...]
    
    function self_command(command)
    if command == 'equip TP.Normal set' then
        state.EngageMode:set('Normal')
        update_showset_display()
        send_command('input /echo -- TP Set changed to Normal.')
        if player.status == 'Engaged' then
            equip(sets.TP.Normal)
        end
    end
    
    [...]
    
    function update_showset_display()
    
    windower.send_command('showset idle ' .. state.IdleMode.value)
    windower.send_command('showset engage ' .. state.EngageMode.value)
    windower.send_command('showset autows ' .. state.AutoWS.value)
    
    --Extra:
    -- windower.send_command('showset wsaccuracy ' .. state.WSAccuracyMode.value)
    -- windower.send_command('showset luzaf ' .. state.LuzafRing.value)
    end</pre>

<br>

- **Option 2:**
<br>If you change your Idle/Engage mode directly with a command, add `send_command('showset idle <Name of your set>')` after changing your Idle set mode and `send_command('showset engage <Name of your set>')` after changing your Engage set mode.

<br>

- **Option 3:**
<br>If you have no clue what any of this means, don't worry! You can use one of my lua template which is made easy to use.

**How to display extra icons:**

- When you swap for your Weapon Skill Accuracy set, use `//showset wsaccuracy [Normal|Accuracy]` to hide ("Normal") or display ("Accuracy") a 🧿 icon.
- When you swap your Luzaf Ring off as COR, use `//showset luzaf [On|Off]` to hide or display a 💍❌ icon.
- For Blue Mages, an icon will be displayed when a specific spell is set.
    - "Spectral Floe" will display "🔮" (usually used for AoE Magic set).
    - "Anvil Lightning" will display "🧿" (usually used for Melee Accuracy set).
    - "Amorphic Spikes" will display "🗝️" (usually used for Treasure Hunter set)

<br>*These spells and icons can be changed in the showset.lua file.

**How to use the AutoWS feature:**

Use `//showset autows "Exact name of WS"` to enable the AutoWS.
<br>The Weapon Skill will be used automatically when you're engaged and reach 1000TP.
