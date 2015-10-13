      PROGRAM type
        CHARACTER*10 msg = "TYPE!"
        NAMELIST /grp/msg
        TYPE grp
        TYPE type
          INTEGER*4 type
        END TYPE type
        TYPE (type) type
        type%type = 17
        TYPE *, type%type
      END PROGRAM type

