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

!     ***************************************************************
!     LOGICAL IF
!     ***************************************************************
        IF (V_I) PRINT *, "Expected: warning INTEGER is not logical
     C                     expression"

!     ***************************************************************
!     IF_THEN BLOCK
!     ***************************************************************
        IF (V_I) THEN
            PRINT *, "Expected: warning INTEGER is not logical
     C                expression"
        END IF

      END PROGRAM IFNOTLOGICAL
