      PROGRAM implicit_sub_arg
        call sub1(5)
      END PROGRAM

      SUBROUTINE sub1(i)
        IMPLICIT NONE
        INTEGER b(i)
        INTEGER i
        b(i - 1) = 7
        PRINT *, i, b(i - 1)
      END SUBROUTINE
