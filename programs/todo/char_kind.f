      PROGRAM char_kind
        CHARACTER A
        INTEGER B
        B = 256 + 65
        A = CHAR(B, 1_12)
        PRINT *, A
      END PROGRAM
