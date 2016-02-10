      PROGRAM label_end_do
        LOGICAL Loop/.TRUE./
        DO WHILE (Loop)
          Loop = .FALSE.
          GO TO 10
          PRINT *, "FAIL"
          STOP
10      END DO
        PRINT *, "PASS"
      END PROGRAM
