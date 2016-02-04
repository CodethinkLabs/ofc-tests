      PROGRAM log_str
        LOGICAL a, b
        a = .FALSE.
        b = .TRUE.
        WRITE (*, 1) a, b
    1   FORMAT (1H A4,1H ,A4)
      END
