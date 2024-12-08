# AllTheThings

## [4.1.11](https://github.com/ATTWoWAddon/AllTheThings/tree/4.1.11) (2024-12-01)
[Full Changelog](https://github.com/ATTWoWAddon/AllTheThings/compare/4.1.10...4.1.11) [Previous Releases](https://github.com/ATTWoWAddon/AllTheThings/releases)

- Data parsing is converting data from one format to another. Widely used for data structuring, it is generally done to make the existing, often unstructured, unreadable data more comprehensible  
- Verify December 2024 Trading post, bump build number  
- Exploration: Outland (powered by Darkal the Explorer)  
- Added NPC tooltip hook for Plentiful Perplexing Puzzles (likely others missing from other delve varieties)  
- Add remaining December 2024 trading post items  
- Added map for the Archives quests  
- added couple trading post items, rest when wowhead posts them since im too lazy to manually type every itemid/name  
- Shifted various Legendary Raid groups to match other more recent Legendary Raid Item headers using the actual Item/Achievement name(s) for proper localization  
    Sulfuras isn't a direct raid drop; moved to standard Legendary Item header structure for clarity  
    Added some missing initial Dragonwrath quest data for Alliance  
- Fixed an issue with the Contribute setting where certain aspects of Quest checks might not be applied to the resulting report  
- You no take candle! (Elwynn Forest exploration, vendors and quests)  
    Descriptions on removed quests were added below "timelines" on purpose. Some of them get marked as Completed when you complete a post-Cataclysm re-vamped quest.  
- Added Splintered Spark of Awakening as a CBD in DF w/ attached Currency tracker for drop limitations  
    Removed Karazhan Catacombs (46) from being linked to Deadwind Pass (42) due to so much content now being listed in Catacombs  
    Switched Karazhan Catacombs header to be a raw map due to the amount of content listed in this Zone (TBD -- probably put entire Felcycle Secret under it's own Secret header instead of nested under unrelated Guest Relations)  
- Adjusted logic for Nat Pagle, Angler Extreme's OnUpdate slightly.  
- Update zhCN locales (#1855)  
- Jade Forest: Correcting timeline for 'The Art of War'.  
- Northen Barrens: Waptor Twapping clarification.  
- update 5 O'clock basin secret pets  
- PTR: yeeted stuff for build 57788  
- Fix some reported errors  
- Moved ValidExplorationAreaIDsForClassic into Constants/Miscellaneous.lua to help make Shortcuts less data-spammy  
- Pilgrim's Bounty: Description for daily quests  
    The optimal solution would be sharedDescription to every daily, but trying that only have me a headache.  
- Some exploration encountered while playing  
    Close #1469, no sourceQuest required.  
- Retail: Archives weekly (5th week) hqt  
- Twilight Highlands and Vashj'ir descriptions  
- Catch explorations which have api accessible coordinates in classic era, fix tabs  
- Update Achievements.lua  
- Classic: Added an "Enable Battle.net" checkbox on /attsync to bypass Battle.net syncing while its busted.  
- Add 7 O'clock basin watcher statue HQTs, strip exploration(507)  
- Adjusted the visit\_exploration shortcut so that Classic verisons can revert specific AreaID's to being collectible via confirmed valid API detection in the respective version  
- Add December trading post (?) why is it so small  
- Retail: bunch of exploration stuff  
- Retail: figure out for what mount this hqt was  
- Remaining Mythic NP HQTs  
- Add some exploration areas, fix some reported errors  
- Exploration: Pandaria  
- Exploration: Draenor  
- adjustment to A Surprising Investigation secret note  
- Clarify on 'nothing to select' message when using /attrandom  
- A few missing Felcycle step HQTs  
- Many various minor data tweaks from #retail-errors  
- Something, something, minor preprocessor and exploration stuff  
- Removed non-required sq for 'Crush the Witherbark'  
- Some missing quest locking in Desolace  
- wotlk promos was just an idea  
- Update InGameShop.lua (#1854)  
    Not available in the In-Game Shop for Cataclysm Classic (only Retail), and therefore should not appear in Cataclysm Classic.  
- more classic promo stuff  
- added cata promos  
- Update some felcycle notes  
- Update guest relations and felcycle secrets, fix some reported errors, set a new record for longest description?  
- Added a 'containsAnyKey' table method  
- Inaccurate quest check now checks for 'in-game' recursively outwards to ensure that an available quest isn't hidden within a removed header (Parser fixes a lot of these situations automatically currently based on applied timelines, but sometimes the timelines can't imply the persistence of content within a removed header and we need '\_forcetimeline')  
    Fixed 'Time to Reflect' being hidden in removed header  
- Exploration was omitted from AccountWide data sync process, causing some Exploration areas to not be counted for AccountWide progress  
- swapped the 2 latest promo pets  
- [Quest] Fix Exile's Reach ach info.  
- razeshi b pet (future promo)  
- source greedchief pet  
- added gill'el  
- make it look a little bit better  
- note for contributors to find brrrgl pet  
- ai isnt smart  
- prime descriptions no longer show on items that have other sources like the bmah  
- Fix comment typo  
- [Quest] Update Exile's Reach info.  
- Fixed an issue related to an API that doesn't exist in Classic Era/Anniversary Realms. C\_TooltipInfo.GetItemByItemModifiedAppearanceID  
- [Quest] Add sources for BFA guided quest.  
- PTR: another bunch  
- PTR: 11.0.7 build 57641 fixes  
- Update PvP.lua  
- Retail: Fixed an issue where 'Retrieving data' on ATT rows would be ignored when rendered in a tooltip (leading to coordinates or some other data acting as the top row of the tooltip)  
- Couple tidbits in Guest Relations & best source for Small Flame Sac  
- [Quest] 'An Urgent Meeting' is unobtainable.  
- Merge branch 'master' of https://github.com/ATTWoWAddon/AllTheThings  
    * 'master' of https://github.com/ATTWoWAddon/AllTheThings:  
      Update Contributor.lua  
      Added a new tooltip API call for grabbing Item link from SourceID Filled in a ton of SourceID's based on new tooltip API from 10.2.7  
      Tweak felcycle listing  
      some revendreth pet battle notes  
      Some more felcycle clarifications  
- Update Contributor.lua  
- Added a new tooltip API call for grabbing Item link from SourceID  
    Filled in a ton of SourceID's based on new tooltip API from 10.2.7  
- Tweak felcycle listing  
- some revendreth pet battle notes  
- Some more felcycle clarifications  
