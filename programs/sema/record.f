      PROGRAM record
        STRUCTURE /color/
          REAL r, g, b, a
        END STRUCTURE

        RECORD /color/ pink, gradient(16)
        pink.r = 1.0
        pink.g = 0.5
        pink.b = 0.5
        pink.a = 1.0

        PRINT *, pink.r, pink.g, pink.b, pink.a
      END PROGRAM
