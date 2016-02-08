      PROGRAM open_rt_status
        CHARACTER*16 A
10      FORMAT(A16)
        READ(*,10) A
        OPEN(UNIT=5,STATUS=A)
      END PROGRAM
