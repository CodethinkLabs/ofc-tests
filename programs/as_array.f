      PROGRAM as_array
        INTEGER a
        DIMENSION a(50, 50)
        DATA a(5,5)/42/
        CALL subr(a)
      END PROGRAM

      SUBROUTINE subr(a)
        INTEGER a
		DIMENSION a(*)

        PRINT *, a(205)
      END SUBROUTINE
