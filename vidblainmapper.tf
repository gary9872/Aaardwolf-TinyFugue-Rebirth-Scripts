
;;; After running to vidblain, hit enter run the mapper 

/load telopt.tf

/def -mregexp -t"Coords ([0-9]+),([0-9]+)" zenith = \
    /set xgo %P1 %; \
    /set ygo %P2 %; \
    rt vidblain %; \
    /input vidblainmapper

/def -mregexp -t"coordinates ([0-9]+),([0-9]+)" getvidcord = \
    /set xgo %P1 %; \
    /set ygo %P2 %; \
    rt vidblain %; \
    /input vidblainmapper

/def -mglob -h'SEND vidblainmapper' vidblain = \
    /rtc_timer

/def rtc_timer = \
    /repeat -0.4 1 /rtc
    
/def rtc = \
    /if (ygo < gmcp_room_info_coord_y ) \
        north %; /rtc_timer %; \
    /elseif (ygo > gmcp_room_info_coord_y ) \
        south %; /rtc_timer %; \
    /elseif (xgo < gmcp_room_info_coord_x ) \
        west %; /rtc_timer %; \
    /elseif (xgo > gmcp_room_info_coord_x ) \
        east %; /rtc_timer %; \
    /endif
