      PROGRAM define_file
        DEFINE FILE unit(nrecs, lenrec, U, ivar)
        DEFINE FILE 3(1000,48,U,NREC)
        DEFINE FILE 3(1000,48,U,N) ,unit(nrecs, lenrec, U, ivar)
      END PROGRAM define_file
