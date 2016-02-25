      PROGRAM holstr
        INTEGER :: i = 4HABCD
        INTEGER :: j = TRANSFER("ABCD", 1)
        INTEGER :: k = 4H 
        INTEGER :: l = TRANSFER("    ", 1)
        INTEGER :: m = 1H 
        INTEGER :: n = TRANSFER(" ", 1)

        PRINT *, i
        PRINT *, j
        PRINT *, k
        PRINT *, l
        PRINT *, m
        PRINT *, n
      END PROGRAM holstr
