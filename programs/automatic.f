      PROGRAM auto
        CALL subr
      END PROGRAM

      SUBROUTINE subr
        AUTOMATIC message
        CHARACTER*12 message/"Hello World!"/
        PRINT *, message
      END SUBROUTINE
