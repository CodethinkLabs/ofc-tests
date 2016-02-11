      PROGRAM var_implicit_do
        IMPLICIT NONE
        INTEGER i
        INTEGER j
        INTEGER k
        DIMENSION k(10)

        READ (*, 10) i
        READ (*, 10) (k(j), j=1, i)
        WRITE (*, 10) (k(j), j=1, i)

10      FORMAT (I1)
      END PROGRAM
