       PROGRAM lit8
       IMPLICIT NONE
       INTEGER*8 test
       test = 999999999999
       test = (test / 1000)
       PRINT *, "test is ", test
       PRINT *, "test should be 999999999"
       END PROGRAM lit8
