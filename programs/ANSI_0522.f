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

      program ANSI_0522
            INTEGER*4      I4TKR(3)
            INTEGER*2      I2TKR(6)
            CHARACTER*12   CTKR
            EQUIVALENCE    (I4TKR,I2TKR,CTKR)
            stop
      end
