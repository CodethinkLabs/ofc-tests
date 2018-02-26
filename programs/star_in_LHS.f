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

      PROGRAM STARINLHS
!     ***************************************************************
!     PRINT WARNING WHEN STAR IS IN THE LHS OF A DECL
!     ***************************************************************
        INTEGER LHSSTAR*4
        INTEGER*4 STARINTYPE/2/

        DATA LHSSTAR/5/

        CHARACTER STARINLHS_CHAR*5/'Hello'/
        CHARACTER*5 STARINTYPE_CHAR/'Hola!'/

        PRINT *, LHSSTAR
        PRINT *, STARINTYPE
        PRINT *, STARINLHS_CHAR
        PRINT *, STARINTYPE_CHAR

      END PROGRAM STARINLHS
