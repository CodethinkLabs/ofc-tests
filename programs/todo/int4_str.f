      PROGRAM int4_str
        INTEGER*4 s
        s = 'TEST'
        WRITE(*, 10) s
10      FORMAT(A4)
      END PROGRAM
