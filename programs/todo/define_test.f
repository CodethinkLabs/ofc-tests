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

      PROGRAM define_file
        DEFINE FILE unit(nrecs, lenrec, U, ivar)
        DEFINE FILE 3(1000,48,U,NREC)
        DEFINE FILE 3(1000,48,U,N) ,unit(nrecs, lenrec, U, ivar)
      END PROGRAM define_file
