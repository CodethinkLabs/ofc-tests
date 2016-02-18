      PROGRAM while_do
        IMPLICIT NONE

        INTEGER i/1/

        WHILE (i .LE. 5) DO
          PRINT *, i
          i = i + 1;
        END DO
      END PROGRAM
