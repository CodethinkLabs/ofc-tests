      PROGRAM idv
        INTEGER IVI
        DATA IVI/7/
        WRITE (*, 10) (IVI, IVI=1,5)
        WRITE (*, 10) IVI
10      FORMAT (I4)
      END
