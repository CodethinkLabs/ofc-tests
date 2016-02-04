      PROGRAM subarray
        INTEGER*4 a(4, 4)
        INTEGER*2 b
        DATA a/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/
        EQUIVALENCE (b, a(1))
        PRINT *, a
        PRINT *, b
      END PROGRAM subarray
