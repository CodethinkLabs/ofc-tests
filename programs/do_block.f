!     Copyright 2016 Codethink Ltd.
!
!     Licensed under the Apache License, Version 2.0 (the "License");
!     you may not use this file except in compliance with the License.
!     You may obtain a copy of the License at
!
!         http://www.apache.org/licenses/LICENSE-2.0
!
!     Unless required by applicable law or agreed to in writing, software
!     distributed under the License is distributed on an "AS IS" BASIS,
!     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!     See the License for the specific language governing permissions and
!     limitations under the License.

      PROGRAM DOTEST
!     **********************************************************
!     TEST 1: DO WHILE
!     **********************************************************
      I = 0
      J = 10
      DO WHILE(I .LT .10)
        I = I + 1
        J = J - 1
      END DO
      PRINT *, "TEST 1: DO WHILE"
      PRINT *, "Expected:"
      PRINT *, "I = ", 10
      PRINT *, "J = ", 0
      PRINT *, "Result:"
      PRINT *, "I = ", I
      PRINT *, "J = ", J
      PRINT *, " "
!     **********************************************************
!     END OF TEST 1
!     **********************************************************
!     **********************************************************
!     TEST 2: DO LOOP
!     **********************************************************
      PRINT *, "TEST 2: DO LOOP"
      PRINT *, "Expected: Print all even numbers from 1-20 inclusive."
      PRINT *, "Result:"
      DO 1 J=1,10
        K=J*2
        PRINT *, K
    1 CONTINUE
      PRINT *, " "
!     **********************************************************
!     END OF TEST 2
!     **********************************************************
!     **********************************************************
!     TEST 3: DO LOOP WITH GOTO
!     **********************************************************
      PRINT *, "TEST 3: DO LOOP WITH GOTO"
      PRINT *, "Expected: Print all even numbers from 1-20 inclusive."
      PRINT *, "Result:"
      DO 2 J = 1, 10
        GO TO 3
    4   PRINT *, K
    2 CONTINUE
      GO TO 5
    3 K = J * 2
      GO TO 4
    5 CONTINUE
      PRINT *, " "
!     **********************************************************
!     END OF TEST 3
!     **********************************************************
!     **********************************************************
!     TEST 4: DO WHILE WITH LABELED END DO
!     **********************************************************
      PRINT *, "TEST 4: DO WHILE WITH LABELED END DO"
      PRINT *, "Expected: Print all odd numbers from 1-20 inclusive."
      PRINT *, "Result:"
      I = 0
      DO WHILE(I .LT .20)
        I = I + 1
        IF (MOD(I, 2) .EQ. 0) THEN
          GO TO 6
        END IF
        PRINT *, I
    6 END DO
      PRINT *, " "
!     **********************************************************
!     END OF TEST 4
!     **********************************************************
      END PROGRAM DOTEST
