      PROGRAM type_basic
        TYPE color
          REAL :: r, g, b, a = 1.0
        END TYPE

        TYPE (color) :: pink
        pink%r = 1.0
        pink%g = 0.5
        pink%b = 0.5

        PRINT *, pink%r, pink%g, pink%b, pink%a
      END PROGRAM type_basic
