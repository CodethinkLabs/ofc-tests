      PROGRAM intrinsic_ishft
        IMPLICIT NONE
        INTEGER a
        DATA a/5/
        a = ISHFT(a+1,-1)
        PRINT *, a
      END PROGRAM
