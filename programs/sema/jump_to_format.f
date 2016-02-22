      PROGRAM jump_to_format
        GO TO 10
        WRITE (*, 10) "FAIL"
        GOTO 20
10      FORMAT (A4)
        WRITE (*, 10) "PASS"
20    END PROGRAM
