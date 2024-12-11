Updated:

fixes: the cuffs not working.
removed: the cuffs in your inventory.

updated: the ability to search people and take the items from their inventory.


any problems
DISCORD ME:  [https://discord.gg/VHDbgpnBbR]




------------------------------------------------------------------------------------------------------------------------------------------------


<p  align="center">
    <a href="https://ndcore.dev" target="_blank">
        <img src="https://github.com/Testaross/ND_Police/assets/86536434/f8ab5177-c317-41f2-a35a-92d2a7b39ce5" width="40%" />
    </a>
</p>

<p align="center"><b><a href="https://ndcore.dev/addons/police">Documentation</a></b>

<div align="center">
    <a href="https://discord.gg/Z9Mxu72zZ6" target="_blank">
        <img src="https://discordapp.com/api/guilds/857672921912836116/widget.png?style=banner2" alt="Andyyy Development Server" height="60px" />
    </a>
</div>




## Credits
- [Overextended](https://github.com/overextended) for creating [ox_police](https://github.com/overextended/ox_police) which this was originally based on.
- [Testaross](https://github.com/Testaross) for beginning this project and contributing a lot to this and ox_police.
- [Hakko](https://github.com/hakkodevelopment) for converting sounds to native audio.
- Florek for resizing and modifying the props.

Everything from ox_police has been completely rewritten besides `client/evidence.lua`, `client/spikes.lua`, and `client/escort.lua` which have minimal changes from the original ox_police.




IMPORTANT!!
[cuffs]

make sure you go to server file then cuff.lua 
line 7 and change your job to the one you want (I've got mine as police so just change that to what ever you have)

## Notes
- Evidence lockers and armories are handled by ox_inventory.
- If you're using NDCore you can create garages for police in `client/vehicle/data`.
- If you're using NDCore ND_MDT has a boss employee page.

If you have suggestions, post a new issue.
If you want to PR a feature, you should ask first (so you won't waste time).


## Features

**Hands up:**
* Keybind that can be changed in the pause menu settings (default: X).
* Click once to cancel.
* search players when cuffed 


**Evidence:**
* Shooting will drop ammo casings on the ground around the player.
* Projectile item will be created where the bullet hits.
* Items for casing and projectile are different per ammo type.

**GSR:**
* When the player shoots, they get GSR on them, which lasts for 15 minutes (configurable).
* If the player stays in water for 1 minute (configurable), GSR will be washed away.
* Police can test players for GSR using ox_target.

**Clothing lockers:**
* Lockers and locker items are created in `data/locker_rooms.lua`.
* Access to a locker or each item within a locker can be set in `data/locker_rooms.lua`.
* Use /getclothing (NDCore Command) to copy the clothing to the clipboard and paste in `data/clothing.lua`.
* When using [ND_ApperanceShops](https://ndcore.dev/addons/appearanceshops) the wardrobe/saved outfits will be available in the locker menu.

**Police shield:**
* When in inventory, the player runs slower, and the shield will be attached to the players back.
* When the item is used, the player will play animation and put the shield in front of them, protecting them from bullets.

**Shotspotter:**
* Ignored jobs can be set, meaning if a player has that job, they won't trigger the shotspotter.
* Ignored weapons can be set, meaning if a player is shooting that weapon, it won't trigger the shotspotter.
* Shotspotter will not be triggered if the player is using a suppressor.
* Shotspotters range/locations can be set in `data/shotspotter.lua`

**Spike strips:**
* Animations for spike strips.
* Animation for player deploying.
* If the player has one spike strip item, it will be deployed.
* If the player has more than one spike strip item, then a menu will pop up asking how many they wish to use.

**Impound:**
* Police can impound any vehicle, and it will be deleted.
* If using NDCore police will be able to select the amount to charge for players to reclaim an impounded vehicle.

