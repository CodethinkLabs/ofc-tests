        program ANSI_F77_SUBSTRING
            real a /5.0/
            character         v*8 / 'abcdefgh' /, 
     &           m(2,3)*3 / 'e11', 'e21', 
     &           'e12', 'e22', 
     &           'e13', 'e23' / 
            print *, v(3:5) 
            print *, v(3:int(a)) 
            print *, v(3:a) 
        end
