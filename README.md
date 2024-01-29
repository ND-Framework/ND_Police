<p  align="center">
    <a href="https://ndcore.dev" target="_blank">
        <img src="https://github.com/Testaross/ND_Police/assets/86536434/f8ab5177-c317-41f2-a35a-92d2a7b39ce5" width="40%" />
    </a>
</p>

<p align="center"><b><a href="https://ndcore.dev/">Documentation</a></b>

<div align="center">
    <a href="https://discord.gg/Z9Mxu72zZ6" target="_blank">
        <img src="https://discordapp.com/api/guilds/857672921912836116/widget.png?style=banner2" alt="Andyyy Development Server" height="60px" />
    </a>
</div>




## Credits
- [Overextended](https://github.com/overextended) for creating [ox_police](https://github.com/overextended/ox_police) which this was originally based on.
- [Testaross](https://github.com/Testaross) for beginning this project and contributing a lot to this and ox_police.

Everything from ox_police has been completely rewritten besides `client/evidence.lua` and `client/spikes.lua` which have minimal changes from the original ox_police.

## Notes
- Evidence lockers and armouries are handled by ox_inventory.
- If you're using NDCore you can create garages for police in `client/vehicle/data`.
- If you're using NDCore ND_MDT has boss employee page.

If you have suggestions, post a new issue.
If you want to PR a feature you should ask first (so you won't waste time).


## Features

**Hand up:**
* Keybind that can be changed in the pause menu settings (default: X).
* Click once to put hands up.
* Hold for ~3 seconds to put hands up and kneel.
* Click once to cancel.

**Cuffs/zipties:**
* Unique zipties & cuffs props.
* Unique zipties & cuff sounds for both applying and removing them.
* Animation for normal cuffing & agressive cuffing.
* Normal cuffing occurs when a player has their hands up standing.
* Agressive cuffing occurs when player has their hands up and kneeling or when not having their hands up at all.
* Cuffs can be used when hands are not up, zipties require player to have hands up.
* Front & back cuff/ziptie animations for normal cuffing.
* Agressive cuffing will promt the target player with a minigame, if they complete it they cancel the cuffing animation and can run away.
* Uncuffing require `handcuffkey` item and cutting zipties requires `tools` items which is also used for hotwiring in NDCore.

**Escort/drag:**
* Players can only be draged when cuffed/ziptied.
* Person dragging will play an animation holding the player being dragged.
* Person being dragged will have their legs animated when the dragging player walks/runs.
* Uncuffing/removing zipties will release person from being dragged.

**Evidence:**
* Shooting will drop ammo casing on the ground around the player.
* Projectile item will be created where the bullet hits.
* Itens for casing and projectile are different per ammo type.

**GSR:**
* When player shoots they get GSR on them which lasts for 15 minutes (configurable).
* If player stays in water for 1 minute (configurable) gsr will be washed away.
* Police can test players for GSR using ox_target.

**Clothing lockers:**
* Lockers and locker items are created in `data/locker_rooms.lua`.
* Access for a locker or each item within a locker can be set in `data/locker_rooms.lua`.
* Use /getclothing (NDCore Command) to copy the clothing to clipboard and paste in `data/clothing.lua`.
* When using [ND_ApperanceShops](https://ndcore.dev/addons/appearanceshops) the wardrobe/saved outfits will be available in the locker menu.

**Police shield:**
* When in inventory player runs slower, and the shield will be attached to the players back.
* When the item used player will play animation and put the shield infront of them protecting them from bullets.

**Shotspotter:**
* Ignored jobs can be set, meaning if a player has that job they won't trigger the shotspotter.
* Ignored weapons can be set, meaning if a player is shooting that weapon it won't trigger the shotspotter.
* Shotspotter will not be triggered if the player is using a suppressor.
* Shotspotters range/locations can be set in `data/shotspotter.lua`

**Spikestrips:**
* Animations for spike strips.
* Animation for player deploying.
* If the player has one spike strip item it will be deployed.
* If the player has more than one spike strip item then a menu will pop up asking how many they wish to use.
