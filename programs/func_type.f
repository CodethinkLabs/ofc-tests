      PROGRAM func_type
        LOGICAL a
        LOGICAL b
        b = a()
        PRINT *, b
      END PROGRAM func_type

      FUNCTION a()
        LOGICAL a
        a = .FALSE.
      End
