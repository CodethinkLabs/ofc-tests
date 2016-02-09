      PROGRAM ds_array
        call subr(500)
      END PROGRAM

      SUBROUTINE subr(a)
        INTEGER a
        INTEGER b
        DIMENSION b(a)
        b(a) = 5
        PRINT *, b(a) 
      END SUBROUTINE
