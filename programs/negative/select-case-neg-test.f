      PROGRAM sel
        RINDEX = 2.5
        SELECT CASE (RINDEX)
        CASE (2:6)
          X = 1.0
        CASE (:3)
          X = 2.0
        CASE (7)
          X = 3.0
        CASE DEFAULT
          X = 99.0
        END SELECT
        PRINT *, X
      END PROGRAM sel
