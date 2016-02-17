      PROGRAM goto_init
        INTEGER A
        GOTO 10
20      PRINT *, A
        GOTO 30
10      A = 42
        GOTO 20
30    END
