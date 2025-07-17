## ■ Introduction:

InfoHUD is a Windower addon for Final Fantasy XI that provides a customizable HUD displaying your gear modes (Normal, Accuracy, DT, etc.), accuracy%, visually track your COR rolls and set an automatic Weapon Skill mode.

The addon features 2 HUDs:
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


- **As Corsair, shows your current rolls, lucky, unlucky numbers and affected players.**
  <br>![alt text](https://i.imgur.com/2AnAv1T.png)

- **When AutoWS is enabled, shows the current Weapon Skill that will automatically be used when reaching 1000TP.**
  <br>![alt text](https://i.imgur.com/2PkYMRD.png)

## ■ How to install:

- Place the "InfoHud" folder into your Windower4\addon\ folder.
- In Game, type `//lua load infohud` to launch the addon.

## ■ How to setup:

### **🎲ShowRoll HUD:**

You don't have to set up anything. When you roll as Corsair, the ShowRoll HUD will automatically display.
<br>This HUD can be toggled on/off in the settings.xml or via the in-game command //infohud showroll [on/off]

### **⚔️ShowSet HUD:**

**How to display your Idle/Engage set mode on the HUD:**

The Idle/Engage set mode can be changed via the commands `//infohud idle [Normal|PDT, etc.]` and `//infohud engage [Normal|Accuracy|PDT, etc.]`


#### **GearSwap integration:**

- **Option 1:**
  <br>If you change your Idle/Engage mode via a "state", add the function "update_infohud_display" at the bottom of your lua and call this function whenever you change your Idle/Engage mode.

<pre>function get_sets()
    
    include('Modes')

    state = {}
    state.IdleMode = M{'Normal', 'DT'}
    state.EngageMode = M{'Normal', 'Accuracy', 'DT', 'TH'}
    state.AutoWS = M{'Off', 'Tachi: Fudo', 'Tachi: Shoha'} -- Change the Weapon Skills you want to spam automatically when you reach 1000 TP.

    update_infohud_display()

    [...]
    
    function self_command(command)
    if command == 'equip TP.Normal set' then
        state.EngageMode:set('Normal')
        update_infohud_display()
        send_command('input /echo -- TP Set changed to Normal.')
        if player.status == 'Engaged' then
            equip(sets.TP.Normal)
        end
    end
    
    [...]
    
    function update_infohud_display()
    
    windower.send_command('infohud idle ' .. state.IdleMode.value)
    windower.send_command('infohud engage ' .. state.EngageMode.value)
    windower.send_command('infohud autows ' .. state.AutoWS.value)
    
    --Extra:
    -- windower.send_command('infohud wsaccuracy ' .. state.WSAccuracyMode.value)
    -- windower.send_command('infohud luzaf ' .. state.LuzafRing.value)
    end</pre>

<br>

- **Option 2:**
<br>If you change your Idle/Engage mode directly with a command, add `send_command('infohud idle <Name of your set>')` after changing your Idle set mode and `send_command('infohud engage <Name of your set>')` after changing your Engage set mode.

<br>

- **Option 3:**
<br>If you have no clue what any of this means, don't worry! You can use my lua template available [here](https://github.com/Noduko/FFXI-Dream-UI) (addons > GearSwap > Data) which is made easy to use.

#### **How to display extra icons:**

- When you swap for your Weapon Skill Accuracy set, use `//infohud wsaccuracy [Normal|Accuracy]` to hide ("Normal") or display ("Accuracy") a 🧿 icon.
- When you swap your Luzaf Ring off as COR, use `//infohud luzaf [On|Off]` to hide or display a 💍❌ icon.
- For Blue Mages, an icon will be displayed when a specific spell is set.
    - "Spectral Floe" will display "🔮" (usually used for AoE Magic set).
    - "Anvil Lightning" will display "🧿" (usually used for Melee Accuracy set).
    - "Amorphic Spikes" will display "🗝️" (usually used for Treasure Hunter set)

<br>*These spells and icons can be changed in the infohud.lua file.

### **⚙️AutoWS feature:**

Use `//infohud autows "Exact name of WS"` to enable the AutoWS.
<br>The Weapon Skill will be used automatically when you're engaged and reach 1000TP.

## ■ Addon commands:

| Command                            | Description                                                                |
|------------------------------------|----------------------------------------------------------------------------|
| `//infohud help`                   | Show this help menu                                                        |
| `//infohud idle [mode]`            | Set Idle mode (e.g., `Normal`, `PDT`)                                      |
| `//infohud engage [mode]`          | Set Engage mode (e.g., `Acc`, `Hybrid`)                                    |
| `//infohud autows [name]`          | Set Auto WS (e.g., `Savage Blade`)                                         |
| `//infohud wsaccuracy [mode]`      | Set WS accuracy mode to show icon (`Normal` or `Accuracy`)                |
| `//infohud luzaf [On/Off]`         | Toggle Luzaf Ring icon display                                             |
| `//infohud showset [on/off]`       | Show or hide the main ShowSet HUD                                          |
| `//infohud showroll [on/off]`      | Show or hide the Corsair's Roll HUD                                          |
| `//infohud resetaccuracy`          | Reset accuracy and critical hit tracking                                   |
| `//infohud save`                   | Save the current HUDs position to `settings.xml`                           |
| `//infohud refresh`                | Force refresh the HUD display manually                                     |
