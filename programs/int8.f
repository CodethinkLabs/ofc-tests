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

       PROGRAM int8
       IMPLICIT NONE
       INTEGER*8 test
       test = 999999999
       test = (test * 1000) + 999
       test = (test / 1000)
       PRINT *, "test is ", test
       PRINT *, "test should be 999999999"
       END PROGRAM int8