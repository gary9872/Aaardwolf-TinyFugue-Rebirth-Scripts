; Retrieve, Write, and Delete Custom Exits.
; check_rms needs to be called externally on a timed loop.

/def check_rms = \
    /set sql select * from hidden where hidden match '%{gmcp_room_info_num}' %; \
        /SET result=$(/sys /usr/bin/sqlite3 roomdb "%{sql}") %; \
        /if (regmatch("([0-9]*)([\|])([0-9a-zA-Z\s]*)",%{result})) \
        /input %P3 %; \
        /endif

/def -mregexp -h"SEND cexit add ([\w\s]+)" add_rms = \
    /set sql_write insert into hidden(room,action) VALUES ('%gmcp_room_info_num','%P1'); %; \
    /SET result=$(/sys /usr/bin/sqlite3 roomdb "%{sql_write}") %; \
    /echo Added custom exit: %P1 to room %gmcp_room_info_num
    
/def -mregexp -h"SEND cexit remove" del_rms = \
    /set sql_write DELETE FROM hidden where room LIKE %gmcp_room_info_num; %; \
    /SET result=$(/sys /usr/bin/sqlite3 roomdb "%{sql_write}") %; \
    /echo Deleted custom exit for room %gmcp_room_info_num
