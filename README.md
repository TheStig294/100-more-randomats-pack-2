_This is the second of my 4 randomat packs. These randomats require "Custom Roles for TTT", a mod that adds new roles like the 'Jester'._\
_Some extra randomats will activate if have other mods installed, linked below those randomats' descriptions_

# Settings/Options

_Words in italics_ are console commands.\
Press ` or ~ in a game of TTT to open the console and type in _the words in italics_ (plus a space and a number) to change this mod’s settings. \
\
Alternatively, add the italic text to your __server.cfg__ (for dedicated servers)\
or __listenserver.cfg__ (for peer-to-peer servers)\
\
For example, to turn off randomats triggering at the start of a round of TTT, type in:\
_ttt_randomat_auto 0_\
(1 = on, 0 = off)\
\
_ttt_randomat_auto_ - Default: 0 - Whether the Randomat should automatically trigger on round start.\
_ttt_randomat_auto_chance_ - Default: 1 - Chance of the auto-Randomat triggering.\
_ttt_randomat_auto_silent_ - Default: 0 - Whether the auto-started event should be silent.\
_ttt_randomat_chooseevent_ - Default: 0 - Allows you to choose out of a selection of events.\
_ttt_randomat_rebuyable_ - Default: 0 - Whether you can buy more than one Randomat.\
_ttt_randomat_event_weight_ - Default: 1 - The default selection weight each event should use.\
_ttt_randomat_event_hint_ - Default: 1 - Whether the Randomat should print what each event does when they start.\
_ttt_randomat_event_hint_chat_ - Default: 1 - Whether hints should also be put in chat.\
_ttt_randomat_event_history_ - Default: 10 - How many events should be kept in history. Events in history will are ignored when searching for a random event to start.

# Newly added randomats

1. Democracy Intensifies - Everyone votes for a randomat every 30 seconds!
2. Suck it! - Jet guns only!
3. Hwapoon! - Everyone gets a 'Hwapoon!' and a "Yogscast Lewis" model, if installed

# Randomats

__Randomats that don't have credit were completely made by me__

## A killer in disguise...

Gives everyone a knife and changes someone to a killer\
\
_ttt_randomat_killerdisguise_ - Default: 1 - Whether this randomat is enabled\
\
Changed name from "Who Let The Killer Out?", now gives everyone a knife as well, only innocents can now be the killer (except the detective)\
Originally made by [ruiner189](https://steamcommunity.com/sharedfiles/filedetails/?id=1988901134)
## Democracy Intensifies

Everyone votes for a randomat every 30 seconds!\
\
_ttt_randomat_killerdisguise_ - Default: 1 - Whether this randomat is enabled\
_randomat_democracyintensifies_timer_ - Default: 30 - Seconds between randomat votes\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086>

## Everyone's a detective

Everyone gains the ability to search bodies and gets a DNA scanner.\
\
_ttt_randomat_dna_ - Default: 1 - Whether this randomat is enabled

## Home Run!

Everyone is continually given home run bats!\
\
_ttt_randomat_homerun_ - Default: 1 - Whether this randomat is enabled\
_randomat_homerun_strip_ - Default: 1 - The event strips your other weapons\
_randomat_homerun_weaponid_ - Default: weapon_ttt_homebat - Id of the weapon given\
\
Changed name from "Batter Up!"\
Originally made by [nanz](https://steamcommunity.com/sharedfiles/filedetails/?id=2194776699)\
\
Requires: <https://steamcommunity.com/workshop/filedetails/?id=648957314>
## Hwapoon!

Everyone gets a 'hwapoon!'\
If installed, everyone also gets a random "Yogscast Lewis" playermodel.\
\
_ttt_randomat_hwapoon_ - Default: 1 - Whether this randomat is enabled\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=456189236> or <https://steamcommunity.com/sharedfiles/filedetails/?id=1625876886>\
Optional "Yogscast Lewis" playermodel: <https://steamcommunity.com/sharedfiles/filedetails/?id=2293499171>

## I'll be back

Changes all normal innocents into phantoms\
\
_ttt_randomat_beback_ - Default: 1 - Whether this randomat is enabled

Changed name from "We'll Be Back", made to be compatible with custom roles for TTT, changed to only transform ordinary innocents to help prevent RDM\
Originally made by [nanz](https://steamcommunity.com/sharedfiles/filedetails/?id=2194776699)

## Infected

1 initial zombie starts with a throwing knife, everyone else is innocent. Zombies respawn after a 5 second delay and innocents win by surviving for a minute and a half.\
\
_ttt_randomat_infected_ - Default: 1 - Whether this randomat is enabled\
_randomat_infected_timer_ - Default: 90 - Time players must survive in seconds

## Murder (Yogscast intro)

Plays the original Yogscast Murder theme and the original Yogscast Murder logo pops up on screen, then triggers the “Murder” randomat, if installed.\
\
_ttt_randomat_yogsmurder_ - Default: 1 - Whether this randomat is enabled\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086>

## Mystery box

Everyone gets a random COD Zombies wonder weapon!\
\
_ttt_randomat_mysterybox_ - Default: 1 - Whether this randomat is enabled\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2252594978>

## No, I'm a deputy!

Ordinary innocents are turned into deputies, ordinary traitors are turned into impersonators.\
\
_ttt_randomat_imdeputy_ - Default: 1 - Whether this randomat is enabled

## Now, you're thinking with portals.

Everyone gets a portal gun!\
\
_ttt_randomat_portal_ - Default: 1 - Whether this randomat is enabled\
\
Changed name from "Aperture Science!", now uses a different portal gun weapon\
Originally made by [nanz](https://steamcommunity.com/sharedfiles/filedetails/?id=2194776699)\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2315732527>\
or: <https://steamcommunity.com/sharedfiles/filedetails/?id=954453521>

## O Rubber Tree...

Continually gives donconnans to everyone\
\
_ttt_randomat_donconnons_ - Default: 1 - Whether this randomat is enabled\
_randomat_donconnons_timer_ - Default: 5 - Time between being given donconnons\
_randomat_donconnons_strip_ - Default: 0 - The event strips your other weapons\
_randomat_donconnons_weaponid_ - Default: weapon_ttt_donconnon_randomat - Id of the weapon given\
_randomat_donconnons_damage_ - Default: 1000 - Donconnon Damage\
_randomat_donconnons_speed_ - Default: 350 - Donconnon Speed\
_randomat_donconnons_range_ - Default: 2000 - Donconnon Range\
_randomat_donconnons_scale_ - Default: 0.1 - Donconnon Size\
_randomat_donconnons_turn_ - Default: 0 - Donconnon Homing turn speed, set to 0 to disable homing\
_randomat_donconnons_lockondecaytime_ - Default: 15 - Seconds until homing stop\
\
Changed name from "O Rubber Tree", added description, made doncon projectiles much smaller, faster and one-shot, added convars to change donconnon stats, no longer strips all weapons by default, fixed donconnons eventually stopping being given out\
Originally made by [Fate](https://steamcommunity.com/sharedfiles/filedetails/?id=2122924789)\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2237522867>

## Prop Hunt (Yogscast intro)

Plays the original Yogscast Prop Hunt theme and the original Yogscast Prop Hunt logo pops up on screen, then triggers the “Prop Hunt” randomat, if installed.\
\
_ttt_randomat_yogsprophunt_ - Default: 1 - Whether this randomat is enabled\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086>

## Suck it!

Everyone is continually given jet guns! If your gun overheats, you'll have to wait 5 seconds before being given a new one\
\
_ttt_randomat_jetgun_ - Default: 1 - Whether this randomat is enabled\
_randomat_jetgun_strip_ - Default: 1 - The event strips your other weapons\
_randomat_jetgun_timer_ - Default: 5 - Seconds between being given a new jet gun\
\
Changed name from "Batter Up!", now gives jet guns instead of bats, no longer transforms jesters into innocents\
Originally made by [nanz](https://steamcommunity.com/sharedfiles/filedetails/?id=2194776699)\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2252594978>

## Team Building Exercise

1 detective, 1 traitor, everyone else is a 'beggar'. Detective has 200 health and both have 2 credits. Only activates if a custom roles mod adding the beggar is installed and the beggar is enabled.\
\
_ttt_randomat_teambuilding_ - Default: 1 - Whether this randomat is enabled\
\
Changed name from "One traitor, One Detective. Everyone else is a Jester. Detective is stronger." Changed jesters to beggars. Detective and traitor are now set to 2 credits.\
Originally made by [Dem](https://steamcommunity.com/sharedfiles/filedetails/?id=1406495040)

## The detective is acting suspicious...

A detective has a 50% chance to secretly be turned into a traitor.\
\
_ttt_randomat_dsuspicious_ - Default: 1 - Whether this randomat is enabled

## The killer is coming... (a.k.a. The killers are coming...)

Changes 1/2 as many people as there were traitors to killers, and everyone else to an innocent. The killer gets extra health and a cloaking device. Turns off map lighting, you have to use your flashlight!\
The killer's goal is to be the last person standing. They have a limited shop, and do less damage with guns, instead they must attack with their re-usable knife, and sneak around as a shadow with their 'Shadow Cloak'.\
While the/a killer is cloaked, everyone hears a distinct sound after a few seconds.\
Spectators can play a random sound to living players on a cooldown.\
If a player sees someone uncloak, they hear a dramatic sound!\
\
_ttt_randomat_horror_ - Default: 1 - Whether this randomat is enabled\
_randomat_horror_music_ - Default: 1 - Whether this randomat plays music\
_randomat_horror_ending_ - Default: 1 - Win screen plays a horror sound and ending title is changed\
_randomat_horror_spectator_sounds_ - Default: 1 - Spectators can play horror sounds\
_randomat_horror_cloak_sounds_ - Default: 1 - Sounds play as the killer is cloaked/uncloaks\
_randomat_horror_spectator_charge_time_ - Default: 30 - Seconds until a spectator can play a sound again\
_randomat_horror_spectator_sound_cooldown_ - Default: 30 - Seconds it takes until someone can hear a spectator sound again\
_randomat_horror_killer_crowbar_ - Default: 0 - Killer gets a throwable crowbar rather than a normal one\
_randomat_horror_killer_health_ - Default: 200 - How much health the killer starts with\
_randomat_horror_killer_credits_ - Default: 1 - Credits the killer starts with\
_randomat_horror_killer_cloak_ - Default: 1 - Killer gets a 'Shadow Cloak' item, which makes them appear as a shadow while held\
_randomat_horror_cloak_sound_timer_ - Default: 10 - Seconds until the cloak sound is heard again while cloaked

Code responsible for removing map lighting originally made by [Wasted](https://steamcommunity.com/sharedfiles/filedetails/?id=2267954071)

Credit for sounds/music used:\
"Unseen Horrors" by Kevin MacLeod\
Link: https://www.youtube.com/watch?v=7URbQvJzztI\
License: https://filmmusic.io/standard-license\
\
"Horror Sounds" by GowlerMusic\
Link: https://freesound.org/people/GowlerMusic/sounds/262257/\
License: https://creativecommons.org/licenses/by/3.0/\
\
"Hand Bells, Reverse Cluster" by InspectorJ\
Link: https://freesound.org/people/InspectorJ/sounds/339821/\
License: https://creativecommons.org/licenses/by/4.0/\
\
"Horror, Violin Tremolo Cluster, B" by InspectorJ\
Link: https://freesound.org/people/InspectorJ/sounds/370937/\
License: https://creativecommons.org/licenses/by/4.0/\
\
"Piano, String Glissando, Low, A" by InspectorJ\
Link: https://freesound.org/people/InspectorJ/sounds/339671/\
License: https://creativecommons.org/licenses/by/4.0/\
\
"Ghost Scream" by onderwish\
Link: https://freesound.org/people/onderwish/sounds/469141/\
License: https://creativecommons.org/publicdomain/zero/1.0/

## UNLIMITED POWEEERRRRRR!

Everyone gets a stungun with unlimited ammo!\
\
_ttt_randomat_stungun_ - Default: 1 - Whether this randomat is enabled\
\
Originally made by [nanz](https://steamcommunity.com/sharedfiles/filedetails/?id=2194776699)\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=785294711>

## Watch your step!

Randomly places shark traps around the map\
\
_ttt_randomat_sharktrap_ - Default: 1 - Whether this randomat is enabled\
_randomat_sharktrap_chance_ - Default: 20 - % of possible spawns replaced with shark traps\
\
Idea from "ProtoThis" on YouTube\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2550782000>

## What am I?

Hides your role and disables the scoreboard\
\
_ttt_randomat_whatami_ - Default: 1 - Whether this randomat is enabled

## Yay!

Turns someone into a clown and someone else into a jester. Whenever someone dies everyone makes a clown activation sound and sprays confetti.\
\
_ttt_randomat_yay_ - Default: 1 - Whether this randomat is enabled

## Yellow Is The New Green!

Changes all innocents to mercenaries\
\
_ttt_randomat_yellow_ - Default: 1 - Whether this randomat is enabled\
_randomat_yellow_credits_ - Default: 1 - How many credits the Mercenaries get\
\
Changed name from "Shops are open from 8AM to 9PM", mercenaries now get 1 credit\
Originally made by [ruiner189](https://steamcommunity.com/sharedfiles/filedetails/?id=1988901134)

## You're on the case, detective...

Only detectives can search bodies, all other players can only call a detective over to search a body.\
\
_ttt_randomat_detectivesearch_ - Default: 1 - Whether this randomat is enabled

## You just triggered my trap card!

Everyone gets an uno reverse card that reflects all damage and lasts for a set amount of time\
\
_ttt_randomat_uno_ - Default: 1 - Whether this randomat is enabled\
_randomat_uno_time_ - Default: 3 - How long the uno reverse card lasts\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2329721936>
