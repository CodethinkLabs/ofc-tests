      PROGRAM type_data
        TYPE color
          REAL :: r, g, b, a = 1.0
        END TYPE

        TYPE (color) :: pink
        DATA pink%r,pink%g,pink%b/1.0, 0.5, 0.5/

        PRINT *, pink%r, pink%g, pink%b, pink%a
      END PROGRAM type_data
