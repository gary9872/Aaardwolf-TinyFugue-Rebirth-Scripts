;;;
;;; Teleopt macro file sourced from Abelinc's  June 2012
;;;
/require textutil.tf
/loaded telopt.tf
/require customexit.tf
;;;
;;; ATCP stuff
;;;

;;;
;;; Commented out since ATCP support was removed when GMCP came in. Figured
;;; the few k it'd save wouldn't be worth totally deleting it, in case someone
;;; also MUDs somewhere that still used ATCP v1 (GMCP is also known as ATCP2)
;;;
;
;/def -hATCP received-atcp = /do-atcp-stuff %*
;
;/def do-atcp-stuff = \
;	/echo ATCP: %* %; \
;	/if (%1 =~ "Room.Num") /set current_room=%2 %; /endif %; \
;	/if (%1 =~ "Room.FullExits") \
;		/check_room_exits %2 %; \
;	/endif
;
;/def check_room_exits = \
;	/if (regmatch("n[(]([0-9]+)[)]",%1)) /set north_exit=%P1 %; /endif %; \
;	/if (regmatch("e[(]([0-9]+)[)]",%1)) /set east_exit=%P1 %; /endif %; \
;	/if (regmatch("s[(]([0-9]+)[)]",%1)) /set south_exit=%P1 %; /endif %; \
;	/if (regmatch("w[(]([0-9]+)[)]",%1)) /set west_exit=%P1 %; /endif %; \
;	/if (regmatch("u[(]([0-9]+)[)]",%1)) /set up_exit=%P1 %; /endif %; \
;	/if (regmatch("d[(]([0-9]+)[)]",%1)) /set down_exit=%P1 %; /endif %; \
;	/if (atcp_maze_walk) /do_next_room_check %; /endif
;
;/def maze-walk = \
;	/set atcp_maze_walk=1 %; \
;	/eval /eval /set atcp_maze_path=%%{%{1}_maze}
;
;/def do_next_room_check = \
;	/set next_needed_room=$(/dequeue atcp_maze_path) %; \
;	/if (next_needed_room=~ "") \
;		/unset atcp_maze_walk %; /break %; /endif %; \
;	/if (north_exit =~ next_needed_room) north %; /endif %; \
;	/if (east_exit =~ next_needed_room) east %; /endif %; \
;	/if (south_exit =~ next_needed_room) south %; /endif %; \
;	/if (west_exit =~ next_needed_room) west %; /endif %; \
;	/if (up_exit =~ next_needed_room) up %; /endif %; \
;	/if (down_exit =~ next_needed_room) down %; /endif

;;;
;;; GMCP stuff
;;;

; place holder for added actions

/def gmcp_group_members_done = /set do_nothing 0

/def -hGMCP received-gmcp = /do-gmcp-stuff %*

/def send-gmcp = /test gmcp("$[replace("\"","\\\"",%{*})]")

; Only normal macros to use for GMCP...toggles whether you see GMCP messages 
; echoed to screen, or GMCP channel messages echoed to screen. Useful to get 
; a feel for what GMCP messages are sent when, and to periodically check for 
; more goodies being added after a reboot. Spammy otherwise. No current way
; to turn off the normal channel messages when receiving via GMCP (would have
; to gag...not hard to do, but defeats the main purpose of GMCP or tags IMO).
; I hardcoded an initialization to N of each of them...change to taste.

/def gmcp-echo = \
	/if (gmcp_echo=~"N") \
		/echo You're now going to see raw GMCP messages %; \
		/set gmcp_echo=Y %; \
	/else \
		/echo You're NOT going to see the raw GMCP messages %; \
		/set gmcp_echo=N %; \
	/endif
/set gmcp_echo=N

/def gmcp-channel-echo = \
	/if (gmcp_channel_echo=~"N") \
		/echo You're now going to see GMCP channel messages %; \
		/set gmcp_channel_echo=Y %; \
	/else \
		/echo You're NOT going to see the GMCP channel messages %; \
		/set gmcp_channel_echo=N %; \
	/endif
/set gmcp_channel_echo=N

; Determines what type of GMCP message it is, and directs the data to the 
; proper macro to have the variables assigned

/def do-gmcp-stuff = \
	/if (gmcp_echo =~ "Y") \
		/echo GMCP: $[decode_ansi(%*)] %; \
	/endif %; \
	/if (%1 =~ "char.base") \
		/check_char_base %-1 %; \
	/elseif (%1 =~ "char.maxstats") \
		/check_char_maxstats %-1 %; \
	/elseif (%1 =~ "char.stats") \
		/check_char_stats %-1 %; \
	/elseif (%1 =~ "char.status") \
		/check_char_status %-1 %; \
	/elseif (%1 =~ "char.worth") \
		/check_char_worth %-1 %; \
	/elseif (%1 =~ "char.vitals") \
		/check_char_vitals %-1 %; \
	/elseif (%1 =~ "comm.channel") \
;		/check_comm_channel $[decode_ansi(%-1)] %; \
		/check_comm_channel %-1 %; \
	/elseif (%1 =~ "comm.event") \
		/check_comm_event %-1 %; \
	/elseif (%1 =~ "comm.quest") \
		/check_comm_quest %-1 %; \
	/elseif (%1 =~ "comm.repop") \
		/check_comm_repop %-1 %; \
	/elseif (%1 =~ "comm.tick") \
		/check_comm_tick %; \
	/elseif (%1 =~ "room.info") \
		/check_room_info $[decode_ansi(%-1)] %; \
	/elseif (%1 =~ "room.wrongdir") \
		/check_room_wrongdir %-1] %; \
	/elseif (%1 =~ "group") \
		/check_group_info $[decode_ansi(%-1)] %; \
	/else	/echo I didn't match any of the top-level GMCP modules. %; \
		/echo GMCP: $[decode_ansi(%*)] %; \
	/endif


; A macro per GMCP module to assign the variables

/def check_char_base = \
	/if (regmatch("\"name\": \"([A-Za-z]+)\"",%*)) /set gmcp_char_base_name=%P1 %; /endif %; \
	/if (regmatch("\"class\": \"([A-Za-z]+)\"",%*)) /set gmcp_char_base_class=%P1 %; /endif %; \
	/if (regmatch("\"subclass\": \"([A-Za-z]+)\"",%*)) /set gmcp_char_base_subclass=%P1 %; /endif %; \
	/if (regmatch("\"race\": \"([^,]+)\"",%*)) /set gmcp_char_base_race=%P1 %; /endif %; \
	/if (regmatch("\"clan\": \"([A-Za-z]*)\"",%*)) /set gmcp_char_base_clan=%P1 %; /endif %; \
	/if (regmatch("\"pretitle\": \"(.*?)\"",%*)) /set gmcp_char_base_pretitle=%P1 %; /endif %; \
	/if (regmatch("\"perlevel\": ([0-9]+)",%*)) /set gmcp_char_base_perlevel=%P1 %; /endif %; \
	/if (regmatch("\"tier\": ([0-9])",%*)) /set gmcp_char_base_tier=%P1 %; /endif %; \
	/if (regmatch("\"remorts\": ([0-9])",%*)) /set gmcp_char_base_remorts=%P1 %; /endif %; \
	/if (regmatch("\"redos\": \"?([0-9]+)\"?",%*)) /set gmcp_char_base_redos=%P1 %; /endif

/def check_char_vitals = \
	/if (regmatch("\"hp\": ([0-9]+)",%*)) /set gmcp_char_vitals_hp=%P1 %; /endif %; \
	/if (regmatch("\"mana\": ([0-9]+)",%*)) /set gmcp_char_vitals_mana=%P1 %; /endif %; \
	/if (regmatch("\"moves\": ([0-9]+)",%*)) /set gmcp_char_vitals_moves=%P1 %; /endif %; \
; quick hack because on reconnects, base stats aren't set...so if tf is quit
; without Aard being quit, the next instance of tf won't have the base info
	/if (!gmcp_char_maxstats_maxhp) /send-gmcp request char %; /endif %; \
	/set gmcp_char_perc_hp=$[100 * %gmcp_char_vitals_hp / %gmcp_char_maxstats_maxhp] %; \
	/set gmcp_char_quart_perc_hp=$[{gmcp_char_perc_hp} / 4] %; \
	/set gmcp_char_perc_mana=$[100 * %gmcp_char_vitals_mana / %gmcp_char_maxstats_maxmana]

/def check_char_maxstats = \
	/if (regmatch("\"maxhp\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxhp=%P1 %; /endif %; \
	/if (regmatch("\"maxmana\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxmana=%P1 %; /endif %; \
	/if (regmatch("\"maxmoves\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxmoves=%P1 %; /endif %; \
	/if (regmatch("\"maxstr\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxstr=%P1 %; /endif %; \
	/if (regmatch("\"maxint\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxint=%P1 %; /endif %; \
	/if (regmatch("\"maxwis\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxwis=%P1 %; /endif %; \
	/if (regmatch("\"maxdex\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxdex=%P1 %; /endif %; \
	/if (regmatch("\"maxcon\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxcon=%P1 %; /endif %; \
	/if (regmatch("\"maxluck\": ([0-9]+)",%*)) /set gmcp_char_maxstats_maxluck=%P1 %; /endif

/def check_char_stats = \
	/if (regmatch("\"str\": ([0-9]+)",%*)) /set gmcp_char_stats_str=%P1 %; /endif %; \
	/if (regmatch("\"int\": ([0-9]+)",%*)) /set gmcp_char_stats_int=%P1 %; /endif %; \
	/if (regmatch("\"wis\": ([0-9]+)",%*)) /set gmcp_char_stats_wis=%P1 %; /endif %; \
	/if (regmatch("\"dex\": ([0-9]+)",%*)) /set gmcp_char_stats_dex=%P1 %; /endif %; \
	/if (regmatch("\"con\": ([0-9]+)",%*)) /set gmcp_char_stats_con=%P1 %; /endif %; \
	/if (regmatch("\"luck\": ([0-9]+)",%*)) /set gmcp_char_stats_luck=%P1 %; /endif %; \
	/if (regmatch("\"hr\": ([0-9]+)",%*)) /set gmcp_char_stats_hr=%P1 %; /endif %; \
	/if (regmatch("\"dr\": ([0-9]+)",%*)) /set gmcp_char_stats_dr=%P1 %; /endif %; \
	/if (regmatch("\"saves\": ([0-9]+)",%*)) /set gmcp_char_stats_saves=%P1 %; /endif %; \

; For State, when not fighting, get rid of the combat-related variables. Since
; they're simply not sent when not fighting, there's nothing else to clear them.
; State uses the same set of numbers as the list below in option 102. If we're
; not in state 3 (fully logged in, able to send MUD commands, not in note mode)
; then set in_note_mode, and any other scripts can use that to know when to
; shut up (so we won't have tons of lines of "c 123" in notes we write)

/def check_char_status = \
	/if (regmatch("\"level\": ([0-9]+)",%*)) /set gmcp_char_status_level=%P1 %; /endif %; \
	/if (regmatch("\"tnl\": ([0-9]+)",%*)) /set gmcp_char_status_tnl=%P1 %; /endif %; \
	/if (regmatch("\"hunger\": ([0-9]+)",%*)) /set gmcp_char_status_hunger=%P1 %; /endif %; \
	/if (regmatch("\"thirst\": ([0-9]+)",%*)) /set gmcp_char_status_thirst=%P1 %; /endif %; \
	/if (regmatch("\"align\": (-?[0-9]+)",%*)) /set gmcp_char_status_align=%P1 %; /endif %; \
	/if (regmatch("\"state\": ([0-9]+)",%*)) /set gmcp_char_status_state=%P1 %; \
		/if (%P1 != 8) \
			/unset gmcp_char_status_enemy %; \
			/unset gmcp_char_status_enemypct %; \
			/if (_loaded_libs=/"*aardstatusgraph.tf*") /clear-healthfile %; /endif %; \
		/endif %; \
		/if (gmcp_char_status_state != 3) /set in_note_mode=Y %; \
		/elseif (gmcp_char_status_state = 3) /set in_note_mode=N %; \
		/endif %; \
	/endif %; \
	/if (regmatch("\"pos\": \"([A-Za-z]+)\"",%*)) /set gmcp_char_status_pos=%P1 %; /endif %; \
	/if (regmatch("\"enemy\": \"(.*?)\"",%*)) /set gmcp_char_status_enemy=%P1 %; /endif %; \
	/if (regmatch("\"enemypct\": ([0-9]+)",%*)) /set gmcp_char_status_enemypct=%P1 %; /endif

/def check_char_worth = \
	/if (regmatch("\"gold\": ([0-9]+)",%*)) /set gmcp_char_worth_gold=%P1 %; /endif %; \
	/if (regmatch("\"bank\": ([0-9]+)",%*)) /set gmcp_char_worth_bank=%P1 %; /endif %; \
	/if (regmatch("\"qp\": ([0-9]+)",%*)) /set gmcp_char_worth_qp=%P1 %; /endif %; \
	/if (regmatch("\"tp\": ([0-9]+)",%*)) /set gmcp_char_worth_tp=%P1 %; /endif %; \
	/if (regmatch("\"trains\": ([0-9]+)",%*)) /set gmcp_char_worth_trains=%P1 %; /endif %; \
	/if (regmatch("\"pracs\": ([0-9]+)",%*)) /set gmcp_char_worth_pracs=%P1 %; /endif

; Tinyfugue currently has an issue where it will truncate GMCP message at 
; around 200 characters (and echo stuff to the screen even without my /echo). 
; The only GMCP module that affects is the comm one, because of the length 
; of some channel messages.

; Hmm, now that the amount of info has been expanded per room,some rooms are
; impacted by this limitation as well. OK, it's time to get off my ass long
; enough to see where the code puts the buffer at 8 bits (256 char)

; The source code that I have posted with all patches pre-applied also has a
; one-line change to fix that behavior. So if you compiled from my full source
; you should be good. There's a line if (xsock->subbuffer->len > 255) {
; I simply made it if (xsock->subbuffer->len > 1023) {

/def check_comm_channel = \
	/if (regmatch("{ \"chan\": \"([a-z]+)\", \"msg\": \"(.*?)\", \"player\": \"([a-zA-Z]+)\" [}]",{*})) \
		 /if ((%P1 =~ "tell") & (%P2 =/ "* pages you *")) /beep %; /endif %; \
		/set gmcp_comm_channel_name=%P1 %; \
		/set gmcp_comm_channel_message=$[decode_ansi($[replace("\\/","/",$[replace("\\\\","\\",%P2)])])] %; \
		/set gmcp_comm_channel_player=%P3 %; \
		/if (gmcp_channel_echo =~ "Y") \
			/echo %P1 channel: Player: %P3, %P2 %; \
		/endif %; \
		/if (gmcp_comm_channel_name=~"tell")\
			/push %gmcp_comm_channel_player tell_player_list%;\
			/eval /set tell_player_list=$(/unique %tell_player_list)%;\
		/endif%;\
	/if (_loaded_libs=/"*abenewchannel.tf*") /abe_channel_proc %; /endif %; \
	/endif

; Heh, feel free to delete or comment out the /echo lines...just a little flavor

/def check_comm_quest = \
	/if (regmatch("{ \"action\": \"comp\", \"qp\": ([0-9]+), \"tierqp\": ([0-9]+), \"pracs\": ([0-9]+), \"hardcore\": ([0-9]+), \"opk\": ([0-9]+), \"trains\": ([0-9]+), \"tp\": ([0-9]+), \"mccp\": ([02]), \"lucky\": ([0-9]+), \"double\": ([01]+), \"daily\": ([01]), \"totqp\": ([0-9]+), \"gold\": ([0-9]+), \"completed\": ([0-9]+), \"wait\": 30 }",%*)) \
		/set gmcp_comm_quest_qp=%P1 %; \
		/set gmcp_comm_quest_tierqp=%P2 %; \
		/set gmcp_comm_quest_pracs=%P3 %; \
		/set gmcp_comm_quest_trains=%P4 %; \
		/set gmcp_comm_quest_tp=%P5 %; \
		/set gmcp_comm_quest_mccp=%P6 %; \
		/set gmcp_comm_quest_lucky=%P7 %; \
		/set gmcp_comm_quest_double=%P8 %; \
		/set gmcp_comm_quest_daily=%P9 %; \
		/set gmcp_comm_quest_totqp=%P10 %; \
		/set gmcp_comm_quest_gold=%P11 %; \
		/set gmcp_comm_quest_completed=%P12 %; \
		/set gmcp_comm_quest_status=WAITING %; \
		/do_reward_quest %; \
	/elseif (regmatch("{ \"action\": \"fail\", \"wait\": 15 }",%*)) \
		/echo Quest Failed %; \
		/set gmcp_comm_quest_status=WAITING %; \
	/elseif (regmatch("{ \"action\": \"killed\", \"time\": ([0-9]+) }",%*)) \
		/set gmcp_comm_quest_status=TARGETDEAD %; \
	/elseif (regmatch("{ \"action\": \"ready\" }",%*)) \
		/set gmcp_comm_quest_status=CANQUEST %; \
	/elseif (regmatch("{ \"action\": \"start\", \"targ\": \"(.*?)\", \"room\": \"(.*?)\", \"area\": \"(.*?)\", \"timer\": ([0-9]+) }",%*)) \
		/set gmcp_comm_quest_target=%P1 %; \
		/set gmcp_comm_quest_room=%P2 %; \
		/set gmcp_comm_quest_area=%P3 %; \
		/set gmcp_comm_quest_timer=%P4 %; \
		/set gmcp_comm_quest_status=QUESTSTARTED %; \
		/eval /set QuestStartTime $[time()] %; \
		/if (whoami=~"aard_abelinc") \
			/tweet Quest to kill %{gmcp_comm_quest_target} in %{gmcp_comm_quest_area} %; \
		/endif %; \
	/elseif (regmatch("{ \"action\": \"status\", \"targ\": \"(.*?)\", \"room\": \"(.*?)\", \"area\": \"(.*?)\", \"timer\": ([0-9]+) }",%*)) \
		/set gmcp_comm_quest_target=%P1 %; \
		/set gmcp_comm_quest_room=%P2 %; \
		/set gmcp_comm_quest_area=%P3 %; \
		/set gmcp_comm_quest_timer=%P4 %; \
	/elseif (regmatch("{ \"action\": \"status\", \"wait\": ([0-9]+) }",%*)) \
		/set gmcp_comm_quest_timer=%P1 %; \
		/set gmcp_comm_quest_status=WAITING %; \
	/elseif (regmatch("{ \"action\": \"status\", \"status\": \"ready\" }",%*)) \
		/set gmcp_comm_quest_timer=%P1 %; \
		/set gmcp_comm_quest_status=CANQUEST %; \
	/elseif (regmatch("{ \"action\": \"status\", \"target\": \"killed\", \"time\": ([0-9]+) }",%*)) \
		/set gmcp_comm_quest_timer=%P1 %; \
		/set gmcp_comm_quest_status=TARGETDEAD %; \
	/elseif (regmatch("{ \"action\": \"timeout\", \"wait\": 30 }",%*)) \
		/echo j00 SUCK! Ran out of time! %; \
		/set gmcp_comm_quest_status=WAITING %; \
	/elseif (regmatch("{ \"action\": \"reset\", \"timer\": 1 }",%*)) \
		/echo Woohoo! Quest reset! %; \
		/set gmcp_comm_quest_status=WAITING %; \
	/elseif (regmatch("{ \"action\": \"reset\", \"timer\": 0 }",%*)) \
		/echo Woohoo! Quest reset! %; \
		/set gmcp_comm_quest_status=CANQUEST %; \
	/else	/echo I didn't match any of the GMCP comm.quest action types. %; \
		/echo GMCP: $[decode_ansi(%*)] %; \
	/endif

; Heh, feel free to delete or comment out the /echo lines...just a little flavor

/def check_comm_tick = \
;adjusts drift of autotick from tick.tf, comment if you don't run
;	/tickset %; \
;runs "just ticked" routine for ghaan's moon script, comment if you don't run
;	/tick_adjust2 %; \
;	/echo -aCred % TICK! %; \
    quest info %; \
    double %; \
	/if (gmcp_comm_quest_status =~ "TARGETDEAD") \
		/echo -aCred HEY  Don't forget to complete your quest ! %; \
	/elseif (gmcp_comm_quest_status =~ "CANQUEST") \
		/echo -aCred WHAT ARE YOU WAITING FOR?!? GO QUEST! %; \
	/endif %; \
;I use for a "stand if at 100%, and autoprac if turned on"...comment to taste
;The repeat is to delay the "at 100%" check because tick is sent before vitals
;	/repeat -0.5 1 /getbetter

/def check_comm_repop = \
	/if (regmatch("{ \"zone\": \"([a-z0-9]+)\" }",%*)) \
		/area_repop %P1 %; \
	/endif

/def area_repop = /echo -aCred REPOP! Area: %*

/def check_room_info = \
	/if (regmatch("\"num\": (-?[0-9]+)",%*)) /set gmcp_room_info_num=%P1 %; /endif %; \
	/echo GMCP: Room.Num %gmcp_room_info_num %; /check_rms %; \
	/if (regmatch(", \"name\": \"(.*?)\", \"zone",%*)) /set gmcp_room_info_name=%P1 %; /endif %; \
;	/echo GMCP: Room.Name %gmcp_room_info_name %; \
	/if (regmatch("\"zone\": \"(.*?)\"",%*)) /set gmcp_room_info_zone=%P1 %; /endif %; \
;	/echo GMCP: Room.Zone %gmcp_room_info_zone %; \
	/if (regmatch("\"terrain\": \"([a-z]+)\"",%*)) /set gmcp_room_info_terrain=%P1 %; /endif %; \
;	/echo GMCP: Room.Terrain %gmcp_room_info_terrain %; \
	/if (regmatch("\"details\": \"([a-z,]*)\"",%*)) \
;		/echo GMCP: Room.Details %P1 %; \
		/set gmcp_room_info_details=%P1 %; \
		/gmcp_check_room_details %P1 %; \
	/endif %; \
	/if (regmatch("\"exits\": [{]([^}]*)[}]",%*)) \
;		/echo GMCP: Room.Exits %P1 %; \
		/gmcp_check_room_exits %P1 %; \
	/endif %; \
	/if (regmatch("\"coord\": [{] \"id\": ([0-9]+), \"x\": ([0-9]+), \"y\": ([0-9]+), \"cont\": ([01])",%*)) \
		/set gmcp_room_info_coord_ContId=%P1 %; \
		/set gmcp_room_info_coord_x=%P2 %; \
		/set gmcp_room_info_coord_y=%P3 %; \
		/set gmcp_room_info_coord_IsCont=%P4 %; \
	/endif %; \
;	/echo GMCP: Room.Coord %gmcp_room_info_coord_ContId %gmcp_room_info_coord_x %gmcp_room_info_coord_y %gmcp_room_info_coord_IsCont %; \
	/make_room_sql

/def make_room_sql = /test fwrite("room_sqlinsert.sql","insert into room (UID, Roomname, RoomZoneShort, RoomTerrain, RoomDetailMaze, RoomDetailBank, RoomDetailSafe, RoomDetailGraffiti, RoomDetailShop, RoomDetailTrainer, RoomDetailGuild, RoomDetailQuestor, RoomDetailHealer, RoomDetailPk, RoomDetailOther, RoomExitN, RoomExitS, RoomExitE, RoomExitW, RoomExitU, RoomExitD, RoomCoordContId, RoomCoordX, RoomCoordY, RoomCoordIsCont) VALUES (%gmcp_room_info_num,'$[replace("'","\'",%gmcp_room_info_name)]','%gmcp_room_info_zone','%gmcp_room_info_terrain',%gmcp_room_info_details_maze,%gmcp_room_info_details_bank,%gmcp_room_info_details_safe,%gmcp_room_info_details_graffiti,%gmcp_room_info_details_shop,%gmcp_room_info_details_trainer,%gmcp_room_info_details_guild,%gmcp_room_info_details_questor,%gmcp_room_info_details_healer,%gmcp_room_info_details_pk,'%gmcp_room_info_details','%gmcp_room_info_exit_north','%gmcp_room_info_exit_south','%gmcp_room_info_exit_east','%gmcp_room_info_exit_west','%gmcp_room_info_exit_up','%gmcp_room_info_exit_down',%gmcp_room_info_coord_ContId,%gmcp_room_info_coord_x,%gmcp_room_info_coord_y,%gmcp_room_info_coord_IsCont);")

; Heh, feel free to delete or comment out the /echo lines...just a little flavor
; Not sure how I feel about this one yet.

/def check_room_wrongdir = \
	/if (regmatch("\"([nsewud])\"",%1)) \
	/echo D'oh! No room there! Try going somewhere other than %P1 next time!%;\
	/endif

; The ability to totally bypass mazes was removed with the update to GMCP,
; but i'll prolly script in a quick maze mapper using the GMCP data eventually

/def gmcp_check_room_details = \
		/if (regmatch("maze",%*)) \
			/set gmcp_room_info_details_maze=1 %; \
		/else /set gmcp_room_info_details_maze=0 %; \
		/endif %; \
		/if (regmatch("bank",%*)) \
			/set gmcp_room_info_details_bank=1 %; \
		/else /set gmcp_room_info_details_bank=0 %; \
		/endif %; \
		/if (regmatch("safe",%*)) \
			/set gmcp_room_info_details_safe=1 %; \
		/else /set gmcp_room_info_details_safe=0 %; \
		/endif %; \
		/if (regmatch("graffiti",%*)) \
			/set gmcp_room_info_details_graffiti=1 %; \
		/else /set gmcp_room_info_details_graffiti=0 %; \
		/endif %; \
		/if (regmatch("shop",%*)) \
			/set gmcp_room_info_details_shop=1 %; \
		/else /set gmcp_room_info_details_shop=0 %; \
		/endif %; \
		/if (regmatch("trainer",%*)) \
			/set gmcp_room_info_details_trainer=1 %; \
		/else /set gmcp_room_info_details_trainer=0 %; \
		/endif %; \
		/if (regmatch("guild",%*)) \
			/set gmcp_room_info_details_guild=1 %; \
		/else /set gmcp_room_info_details_guild=0 %; \
		/endif %; \
		/if (regmatch("questor",%*)) \
			/set gmcp_room_info_details_questor=1 %; \
		/else /set gmcp_room_info_details_questor=0 %; \
		/endif %; \
		/if (regmatch("healer",%*)) \
			/set gmcp_room_info_details_healer=1 %; \
		/else /set gmcp_room_info_details_healer=0 %; \
		/endif %; \
		/if (regmatch("pk",%*)) \
			/set gmcp_room_info_details_pk=1 %; \
		/else /set gmcp_room_info_details_pk=0 %; \
		/endif


; This macro needs to UNset the room exits for any exit it doesn't explicitly
; see each time it's called.
/def gmcp_check_room_exits = \
	/if (regmatch("n\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_north=%P1 %; \
		/else /unset gmcp_room_info_exit_north %; \
	/endif %; \
	/if (regmatch("e\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_east=%P1 %; \
		/else /unset gmcp_room_info_exit_east %; \
	/endif %; \
	/if (regmatch("s\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_south=%P1 %; \
		/else /unset gmcp_room_info_exit_south %; \
	/endif %; \
	/if (regmatch("w\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_west=%P1 %; \
		/else /unset gmcp_room_info_exit_west %; \
	/endif %; \
	/if (regmatch("u\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_up=%P1 %; \
		/else /unset gmcp_room_info_exit_up %; \
	/endif %; \
	/if (regmatch("d\": ([-0-9]+)",%*)) /set gmcp_room_info_exit_down=%P1 %; \
		/else /unset gmcp_room_info_exit_down %; \
	/endif %; \
	/if (atcp_maze_walk) /do_next_room_check %; /endif

/def check_group_info = \
	/if (regmatch("\"groupname\": \"(.*?)\", \"",%*)) \
		/set gmcp_group_info_groupname=$[replace("\\\"","\"",%P1)] %; \
	/endif %; \
	/if (regmatch("\"leader\": \"([A-Za-z]+)\", \"",%*)) \
		/set gmcp_group_info_leader=%P1 %; \
	/endif %; \
	/if (regmatch("\"created\": \"([0-9]+ [A-Za-z]+ [0-9]+:[0-9]+)\", \"",%*)) \
		/set gmcp_group_info_created=%P1 %; \
	/endif %; \
	/if (regmatch("\"status\": \"([A-Za-z]+)\", \"",%*)) \
		/set gmcp_group_info_status=%P1 %; \
	/endif %; \
	/if (regmatch("\"count\": ([0-9]+), \"",%*)) \
		/set gmcp_group_info_count=%P1 %; \
	/endif %; \
	/if (regmatch("\"kills\": ([0-9]+), \"",%*)) \
		/set gmcp_group_info_kills=%P1 %; \
	/endif %; \
	/if (regmatch("\"exp\": ([0-9]+), \"",%*)) \
		/set gmcp_group_info_exp=%P1 %; \
	/endif %; \
	/if (regmatch("\"members\": [[] ",%*)) \
		/set group_member_number=0 %; /gmcp_group_members %PR %; \
	/endif

/def gmcp_group_members = \
	/if (regmatch("[{] \"name\": \"([A-Za-z]+)\", \"info\": [{] \"hp\": ([0-9]+), \"mhp\": ([0-9]+), \"mn\": ([0-9]+), \"mmn\": ([0-9]+), \"mv\": ([0-9]+), \"mmv\": ([0-9]+), \"align\": ([0-9-]+), \"tnl\": ([0-9]+), \"qt\": ([0-9]+), \"qs\": ([0-3]), \"lvl\": ([0-9]+) [}] [}]",%*)) \
		/test $[++group_member_number] %; \
;		/echo %{group_member_number} Name %P1 %; \
		/set gmcp_group_member_%{group_member_number}_name=%P1 %; \
;		/echo %{group_member_number} Hp %P2 %; \
		/set gmcp_group_member_%{group_member_number}_hp=%P2 %; \
;		/echo %{group_member_number} MaxHP %P3 %; \
		/set gmcp_group_member_%{group_member_number}_maxhp=%P3 %; \
;		/echo %{group_member_number} Mana %P4 %; \
		/set gmcp_group_member_%{group_member_number}_mana=%P4 %; \
;		/echo %{group_member_number} MaxMana %P5 %; \
		/set gmcp_group_member_%{group_member_number}_maxmana=%P5 %; \
;		/echo %{group_member_number} Moves %P6 %; \
		/set gmcp_group_member_%{group_member_number}_moves=%P6 %; \
;		/echo %{group_member_number} MaxMoves %P7 %; \
		/set gmcp_group_member_%{group_member_number}_maxmoves=%P7 %; \
;		/echo %{group_member_number} Align %P8 %; \
		/set gmcp_group_member_%{group_member_number}_align=%P8 %; \
;		/echo %{group_member_number} Tnl %P9 %; \
		/set gmcp_group_member_%{group_member_number}_tnl=%P9 %; \
;		/echo %{group_member_number} QuestTime %P10 %; \
		/set gmcp_group_member_%{group_member_number}_qtime=%P10 %; \
;		/echo %{group_member_number} QuestStatus %P11 %; \
		/set gmcp_group_member_%{group_member_number}_qstatus=%P11 %; \
;		/echo %{group_member_number} Level %P12 %; \
		/set gmcp_group_member_%{group_member_number}_level=%P12 %; \
		/gmcp_group_members %PR %; \
	/else /gmcp_group_members_done %; \
	/endif

/sh rm gmcp_group_health.txt
/sh touch gmcp_group_health.txt
;/def gmcp_group_members_done = \
	/for i 1 %%{gmcp_group_info_count} \
        /echo go %%i %; \
		/build_group_member_info %%i %; \
;	/listvar -v gmcp_group_member_*_ansi_stats_var %| /writefile -a gmcp_group_health.txt

/def purge-group = /quote -S /unset `/listvar -s gmcp_group_member_*

/def gmcp_group_member_write_file = /listvar -v gmcp_group_member_*_ansi_stats_var %| /writefile gmcp_group_health.txt

/def show-group = \
	/eval /sh xterm -geometry 80x$[%{group_member_number} + 1] -T HealthStatus -bg black -fg white -e tail -f gmcp_group_health.txt &

/def build_group_member_info = \
	/eval /set temp_groupmate_name=%%{gmcp_group_member_%{i}_name} %; \
	/eval /set temp_groupmate_hp=%%{gmcp_group_member_%{i}_hp} %; \
	/eval /set temp_groupmate_maxhp=%%{gmcp_group_member_%{i}_maxhp} %; \
	/eval /set temp_groupmate_qtime=%%{gmcp_group_member_%{i}_qtime} %; \
	/set temp_groupmate_perc_hp=$[100 * %temp_groupmate_hp / %temp_groupmate_maxhp] %; \
    /echo bad %; \
	/set temp_groupmate_quart_perc_hp=$[25 * %temp_groupmate_hp / %temp_groupmate_maxhp] %; \
	/if ({temp_groupmate_perc_hp} < 33) /set temp_healthcolor=Cred %; \
	/elseif ({temp_groupmate_perc_hp} < 66) /set temp_healthcolor=Cyellow %; \
	/else /set temp_healthcolor=Cgreen %; \
	/endif %; \
	/eval /set temp_groupmate_mana=%%{gmcp_group_member_%{i}_mana} %; \
	/eval /set temp_groupmate_maxmana=%%{gmcp_group_member_%{i}_maxmana} %; \
	/set temp_groupmate_perc_mana=$[100 * %temp_groupmate_mana / %temp_groupmate_maxmana] %; \
	/set temp_groupmate_quart_perc_mana=$[25 * %temp_groupmate_mana / %temp_groupmate_maxmana] %; \
	/if ({temp_groupmate_perc_mana} < 33) /set temp_manacolor=Cred %; \
	/elseif ({temp_groupmate_perc_mana} < 66) /set temp_manacolor=Cyellow %; \
	/else /set temp_manacolor=Cgreen %; \
	/endif %; \
	/eval /set gmcp_group_member_%{i}_stats_var=$[pad(%temp_groupmate_name,-12," HP ",-3,"[@{%temp_healthcolor}",-1,strrep("#",%temp_groupmate_quart_perc_hp),-25,"@{n}]",1," Mana: ",7,"[@{%temp_manacolor}",-1,strrep("#",%temp_groupmate_quart_perc_mana),-25,"@{n}]",-1," Qt: ",5,%temp_groupmate_qtime,2)] %; \
	/eval /set gmcp_group_member_%{i}_color_stats_var=$$[decode_attr(gmcp_group_member_%{i}_stats_var)] %; \
	/eval /set gmcp_group_member_%{i}_ansi_stats_var=$$[encode_ansi(gmcp_group_member_%{i}_color_stats_var)] %; \
	/echo %temp_groupmate_name: %temp_groupmate_hp / %temp_groupmate_maxhp, %temp_groupmate_perc_hp%


; This command tells Aard which modules to turn on or off. 0 for off, 1 for on.
; You can change it to your personal preferences of what info you wish to
; receive via GMCP. You can also make the changes temporarily in-game by typing
; /send-gmcp Core.Supports.Set [ "debug 1" ]
; to turn on the debug echos, etc. You don't need to send the full set of 
; options, just the one you're changing. Typing "proto gmcp" shows your current
; settings according to Aard. These settings are not persistent, and must be
; sent every time you connect.

/test gmcp("Core.Supports.Set [ \"Char 1\", \"Comm 1\", \"Core 1\", \"Debug.packets 0\", \"Debug.json 0\", \"Room 1\", \"Group 1\" ]")

;;;
;;; Option 102 stuff
;;;

; /def -hOPTION102 received-option102 = /do-option-102-stuff $[ascii(%*)] $[ascii($[substr(%*,1)])]

;Option Description
;1 Statmon
;2 Bigmap + Coordinates tags
;3 Help tags
;4 Map tags
;5 Channel tags
;6 Tell tags (see .help telltags. in game)
;7 Spellup tags (see .help spelltags. in game)
;8 Skillgains tags
;9 Say tags
;11 Score tags
;12 Room names in mapper
;14 Exits in mapper
;15 Editor tags
;16 Equip tags
;17 Inventory tags
;
;50 Quiet all tags (tags quiet on/off)
;51 Turn autotick on/off
;52 Turn prompts on/off
;53 Turn output paging on/off (remembers pagesize)

; The command to send Opt102 messages to the MUD. An example is on my telopt page.

/def send-102 = /test option102("$[char(%1)]$[char(%2)]")

;Option Description
;100,0 Player sleeping, sitting, or resting
;100,1 At login screen, no player yet
;100,2 Player at MOTD or other login sequence
;100,3 Player fully active & able to receive MUD commands, standing, no combat
;100,4 Player AFK
;100,5 Player in note mode
;100,6 Player in Building/Edit mode
;100,7 Player at paged output prompt
;100,8 Player in combat

; If you don't use a moon script, comment out the tick_adjust2 line. If you
; do use one, use this tick_adjust2 to overrule the tick trigger in it. This
; will work even if you're in note mode for 20 minutes, since it still gets
; tick info.

; I commented out most of this, since I'm doing it in GMCP now. GMCP doesn't
; have a method to send commands to turn tags on/off yet, among other things,
; so option102 isn't quite redundant yet.

/def do-option-102-stuff = \
;	/echo Option 102: %1,%2 %; \
;	/if ((%1 = 101) & (%2 = 1)) \
;		/tick_adjust2 %; \
;	/elseif ((%1 = 100) & (%2 != 3)) /set in_note_mode=Y %; \
;	/elseif ((%1 = 100) & (%2 = 3)) /set in_note_mode=N %; \
;	/endif

/set in_note_mode=N


; GMCP: { "action": "comp", "qp": 14, "tierqp": 0, "pracs": 0, "hardcore": 0, "opk": 0, "trains": 0, "tp": 0, "mccp": 2, "lucky": 0, "double": 0, "daily": 0, 
; "totqp": 16, "gold": 3640, "completed": 34, "wait": 30 }
