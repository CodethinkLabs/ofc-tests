!     Copyright 2018 Codethink Ltd.
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

      PROGRAM IFNOTLOGICAL
!     ***************************************************************
!     PRINT WARNINGS WHEN RUN IF CONDITION ON NOT LOGICAL EXPRESSIONS
!     ***************************************************************
        IMPLICIT NONE

        INTEGER V_I
        REAL V_R
        COMPLEX V_C
        LOGICAL V_L
        BYTE V_B
        INTEGER, DIMENSION(2) :: V_A_I
        REAL, DIMENSION(2) :: V_A_R
        LOGICAL, DIMENSION(2) :: V_A_L
        COMPLEX, DIMENSION(2) :: V_A_C
        BYTE, DIMENSION(2) :: V_A_B

!     ***************************************************************
!     LOGICAL IF
!     ***************************************************************
        IF (V_I) PRINT *, "Expected: warning INTEGER is not logical
     C                     expression"
        IF (V_R) PRINT *, "Expected: warning REAL is not logical
     C                     expression"
        IF (V_C) PRINT *, "Expected: warning COMPLEX is not logical
     C                     expression"
        IF (V_L) PRINT *, "Expected: no warning because it is logical
     C                     expression"
        IF (V_B) PRINT *, "Expected: warning COMPLEX is not logical
     C                     expression"
        IF (V_A_I) PRINT *, "Expected: warning arrary is not logical"
        IF (V_A_R) PRINT *, "Expected: warning arrary is not logical"
        IF (V_A_C) PRINT *, "Expected: warning arrary is not logical"
        IF (V_A_L) PRINT *, "Expected: warning arrary is not logical"
        IF (V_A_B) PRINT *, "Expected: warning arrary is not logical"

!     ***************************************************************
!     IF_THEN BLOCK
!     ***************************************************************
        IF (V_I) THEN
            PRINT *, "Expected: warning INTEGER is not logical
     C                expression"
        END IF

        IF (V_R) THEN
            PRINT *, "Expected: warning REAL is not logical expression"
        END IF

        IF (V_C) THEN
            PRINT *, "Expected: warning COMPLEX is not logical
     C                expression"
        END IF

        IF (V_L) THEN
            PRINT *, "Expected: no warning because it is logical"
        END IF

        IF (V_B) THEN
            PRINT *, "Expected: warning BYTE is not logical expression"
        END IF

        IF (V_A_I) THEN
            PRINT *, "Expected: warning array is not logical expression"
        END IF

        IF (V_A_R) THEN
            PRINT *, "Expected: warning array is not logical expression"
        END IF

        IF (V_A_L) THEN
            PRINT *, "Expected: warning array is not logical expression"
        END IF

        IF (V_A_B) THEN
            PRINT *, "Expected: warning array is not logical expression"
        END IF

      END PROGRAM IFNOTLOGICAL
