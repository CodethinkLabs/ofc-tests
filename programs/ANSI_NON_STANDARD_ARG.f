!     Copyright 2015 Codethink Ltd.
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

      PROGRAM ANSI_NON_STANDARD_ARG
      PARAMETER ( P1 = Z'1F' )
      INTEGER*2 N1, N2, N3, N4
      DATA N1 /B'0011111'/, N2/O'37'/, N3/X'1f'/, N4/Z'1f'/
      WRITE ( *, 1 ) N1, N2, N3, N4, P1
1     FORMAT ( 1X, O4, O4, Z4, Z4, Z4 )
      STOP
      END
