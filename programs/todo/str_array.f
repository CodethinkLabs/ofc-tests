      PROGRAM str_array
        CHARACTER*16 a(16)
        DATA a(1:8)/"a", "b", "c", "d", "e", "f", "g", "h"/
        DATA a(9)(3:5)/"hey"/
        PRINT *, a(9)
      END PROGRAM
