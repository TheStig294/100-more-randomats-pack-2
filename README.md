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

1. Yay! - Guarantees a clown/jester but you can't see when the clown activates
1. No, I'm a Deputy! - Normal innocents/traitors become deputies/impersonators
1. Everyone's a detective - Everyone can search bodies and gets a DNA scanner

# Randomats

__Randomats that don't have credit were completely made by me__

## A killer in disguise

Gives everyone a knife and changes someone to a killer\
\
_ttt_randomat_killerdisguise_ - Default: 1 - Whether this randomat is enabled\
\
Changed name from "Who Let The Killer Out?", now gives everyone a knife as well, only innocents can now be the killer (except the detective)\
Originally made by [ruiner189](https://steamcommunity.com/sharedfiles/filedetails/?id=1988901134)

## Everyone's a detective

Everyone gains the ability to search bodies and gets a DNA scanner.\
\
_ttt_randomat_dna_ - Default: 1 - Whether this randomat is enabled

## Home Run

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
_randomat_infected_time_ - Default: 90 - Time players must survive in seconds

## Murder (Yogscast intro)

Plays the original Yogscast Murder theme and the original Yogscast Murder logo pops up on screen, then triggers the “Murder” randomat, if installed.\
\
_ttt_randomat_yogsmurder_ - Default: 1 - Whether this randomat is enabled

## Mystery box

Everyone gets a random COD Zombies wonder weapon!\
\
_ttt_randomat_mysterybox_ - Default: 1 - Whether this randomat is enabled\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2252594978>

## No, I'm a deputy

Ordinary innocents are turned into deputies, ordinary traitors are turned into impersonators.\
\
_ttt_randomat_imdeputy_ - Default: 1 - Whether this randomat is enabled

## Prop Hunt (Yogscast intro)

Plays the original Yogscast Prop Hunt theme and the original Yogscast Prop Hunt logo pops up on screen, then triggers the “Prop Hunt” randomat, if installed.\
\
_ttt_randomat_yogsprophunt_ - Default: 1 - Whether this randomat is enabled

## Team Building Exercise

1 detective, 1 traitor, everyone else is a 'beggar'. Detective has 200 health and both have 2 credits. Only activates if a custom roles mod adding the beggar is installed and the beggar is enabled.\
\
_ttt_randomat_teambuilding_ - Default: 1 - Whether this randomat is enabled\
\
Changed name from "One traitor, One Detective. Everyone else is a Jester. Detective is stronger." Changed jesters to beggars. Detective and traitor are now set to 2 credits.\
Originally made by [Dem](https://steamcommunity.com/sharedfiles/filedetails/?id=1406495040)

## The detective is acting suspicious

A detective has a 50% chance to secretly be turned into a traitor.\
\
_ttt_randomat_dsuspicious_ - Default: 1 - Whether this randomat is enabled

## What am I?

Hides your role and disables the scoreboard\
\
_ttt_randomat_whatami_ - Default: 1 - Whether this randomat is enabled

## Yay

Turns someone into a clown and someone else into a jester. Whenever someone dies everyone makes a clown activation sound and sprays confetti.\
\
_ttt_randomat_yay_ - Default: 1 - Whether this randomat is enabled

## Yellow Is The New Green

Changes all innocents to mercenaries\
\
_ttt_randomat_yellow_ - Default: 1 - Whether this randomat is enabled\
_randomat_yellow_credits_ - Default: 1 - How many credits the Mercenaries get\
\
Changed name from "Shops are open from 8AM to 9PM", mercenaries now get 1 credit\
Originally made by [ruiner189](https://steamcommunity.com/sharedfiles/filedetails/?id=1988901134)

## You're on the case, detective

If detective-only search is off (a setting form Custom Roles for TTT), this randomat can trigger, and it simply turns that setting on for the round.\
It makes it so only detectives can search bodies, and all other players can only call a detective over to search a body.\
\
_ttt_randomat_detectivesearch_ - Default: 1 - Whether this randomat is enabled

## You just triggered my trap card

Everyone gets an uno reverse card that reflects all damage and lasts for a set amount of time\
\
_ttt_randomat_uno_ - Default: 1 - Whether this randomat is enabled\
_randomat_uno_time_ - Default: 3 - How long the uno reverse card lasts\
\
Requires: <https://steamcommunity.com/sharedfiles/filedetails/?id=2329721936>
