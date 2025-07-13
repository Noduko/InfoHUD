■ INTRODUCTION:

ShowSet is a Windower addon for Final Fantasy XI that provides a customizable HUD displaying your gear modes (Normal, Accuracy, DT, etc.), accuracy%, visually track your COR rolls and set an automatic Weapon Skill mode.

There are 2 HUDs:
- ShowSet (displays your accuracy, Idle/Engage set mode and AutoWS)
- ShowRoll (track your Corsair's rolls).

Each HUD can be toggled individually.

■ FEATURES:

<ul>
<li>Show your current accuracy% (incl. miss and crit%) and shows your current Idle and Engage set mode.
SCREENSHOT
</li>

<li>Show additional icons such as Weapon Skill accuracy mode (🧿), your COR Luzaf Ring mode (💍❌ if not equipped) or your BLU Spell set (Magic: 🔮, Melee Accuracy: 🧿, Treasure Hunter: 🗝️)
SCREENSHOT
</li>

<li>As Corsair, show your current rolls, lucky and unlucky numbers.
SCREENSHOT
</li>


<li>When AutoWS is enabled, show the current Weapon Skill that will automatically be used when reaching 1000TP.
SCREENSHOT
</li>
</ul>


How to install:

Place the "ShowSet" folder into your Windower4\addon\ folder.
In Game, type //lua load showset to launch the addon.

Setup:

ShowRoll:
You don't have to change anything. When you roll as Corsair, the ShowRoll HUD will automatically display.
This HUD can be toggled on/off in the settings.xml or via the in-game command //showset showroll [on/off]

ShowSet:

How to display your Idle/Engage set mode:

The Idle/Engage set mode can be changed via the commands //showset idle [Normal|PDT, etc.] and //showset engage [Normal|Accuracy|PDT, etc.]


GearSwap integration:

If you change your Idle/Engage mode via a "state" (e.g. state.EngageMode = M{'Normal', 'Accuracy', 'DT', 'TH'}):

Add the function update_showset_display at the bottom of your lua:
function update_showset_display()
    
    windower.send_command('showset idle ' .. state.IdleMode.value)
    windower.send_command('showset engage ' .. state.EngageMode.value)
    windower.send_command('showset autows ' .. state.AutoWS.value)
    
    --Extra:
    -- windower.send_command('showset wsaccuracy ' .. state.WSAccuracyMode.value)
    -- windower.send_command('showset luzaf ' .. state.LuzafRing.value)
end

*You can find an example in my Template.lua.

If you change your Idle/Engage mode directly with a command:

Add "send_command('showset idle <Name of your set>')" after changing your Idle set mode.
Add "send_command('showset engage <Name of your set>')" after changing your Engage set mode.

If you have no clue what any of this means, don't worry! You can use one of my lua template which is made easy to use.

How to display extra icons:

When you swap for your Weapon Skill Accuracy set, use //showset wsaccuracy [Normal|Accuracy] to hide or display a 🧿 icon.
When you swap your Luzaf Ring off as COR, use //showset luzaf [On|Off] to hide or display a 💍❌ icon.
For Blue Mages, an icon will be displayed when a specific spell is set.

"Spectral Floe" will display "🔮" (usually used for AoE Magic set).
"Anvil Lightning" will display "🧿" (usually used for Melee Accuracy set).
"Amorphic Spikes" will display "🗝️" (usually used for Treasure Hunter set)

These spells and icons can be changed in the showset.lua file.

How to use the AutoWS feature:

Use //showset autows "Exact name of WS" to enable the AutoWS. The Weapon Skill will be used automatically when you're engaged and reach 1000TP.