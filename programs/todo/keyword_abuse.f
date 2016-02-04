      PROGRAM keyword_abuse
        INTEGER a
        REAL b
        DIMENSION a(2)
        a(COMPLEX b) = 12
        b = 3
        a = 34
        a(2.3) = 56
        WRITE (*,10) COMPLEX b
        WRITE (*,10) a
        WRITE (*,10) a(2)
        WRITE (*,10) a(COMPLEX b)
10      FORMAT (I12)
20      FORMAT (F8.4E4.0)
      END
