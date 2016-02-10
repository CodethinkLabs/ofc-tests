      PROGRAM label_end_do
        IF (.TRUE.) THEN
          GO TO 10
          PRINT *, "FAIL"
          STOP
10      END IF
        PRINT *, "PASS"
      END PROGRAM
