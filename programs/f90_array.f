      PROGRAM f90_array
        INTEGER, DIMENSION(10) :: A = (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
     & /)
        CHARACTER(5), DIMENSION(2) :: B = (/ "ALPHA", "BETA " /)
        PRINT *, A(7), B(2)
      END PROGRAM
