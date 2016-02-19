      PROGRAM non_exec_label
        IMPLICIT NONE
10      INTEGER A
        DATA A/5/

        A = A + 1
        IF (A == 6) GOTO 10

        PRINT *, A
      END PROGRAM
