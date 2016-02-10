      PROGRAM if_block_format
        IMPLICIT NONE

        CHARACTER*72 Message/'What am I doing?'/

        IF (.TRUE.) THEN
10        FORMAT (A72)
        END IF

        WRITE (*, 10) Message
      END PROGRAM
