      PROGRAM intr
        INTRINSIC SIN
        CALL function(SIN)

      END PROGRAM intr

      SUBROUTINE function( S )
        REAL NUM, S
        NUM = S(3.14)
        PRINT *, NUM
      END

