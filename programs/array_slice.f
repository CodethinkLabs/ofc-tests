      PROGRAM array_slice
        INTEGER a(4,4)
        INTEGER b(4)
        DATA a/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/
        b = a(3,:)
        PRINT *, b
      END PROGRAM
