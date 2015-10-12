
      program ANSI_0376
      real A(3,5)
      integer i,j
      do 20 j = 1, 3
         do 10 i = 1, 3
            A(i,j) = real(i)/real(j)
   10    continue
   20 continue
      A(i) = 0
      end
