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

        program ANSI_F77_SUBSTRING
            real a /5.0/
            character         v*8 / 'abcdefgh' /, 
     &           m(2,3)*3 / 'e11', 'e21', 
     &           'e12', 'e22', 
     &           'e13', 'e23' / 
            print *, v(3:5) 
            print *, v(3:int(a)) 
            print *, v(3:a) 
        end
