      PROGRAM ANSI_NON_STANDARD_ARG
      PARAMETER ( P1 = Z'1F' )
      INTEGER*2 N1, N2, N3, N4
      DATA N1 /B'0011111'/, N2/O'37'/, N3/X'1f'/, N4/Z'1f'/
      WRITE ( *, 1 ) N1, N2, N3, N4, P1
1     FORMAT ( 1X, O4, O4, Z4, Z4, Z4 )
      STOP
      END
