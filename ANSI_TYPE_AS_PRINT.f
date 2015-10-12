        program ANSI_TYPE_AS_PRINT
        integer*4 rcode
        rcode = 0
        type *, 'emsg:eqgethdr_wrap: eqgethdr failed, rcode:', rcode
        stop
        end
