      PROGRAM reshapen
        INTEGER, DIMENSION(3, 3) :: X = RESHAPE((/ 1, 2, 3, 4, 5, 6, 7,
     &8, 9 /), (/ 3, 3 /))
        PRINT *, X(1, 2)
        PRINT *, X(3, 2)
      END PROGRAM
