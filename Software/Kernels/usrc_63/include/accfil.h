** System accounting buffer** Each entry in the system accounting file has this form.*          base    0         * struct accfilacuid     rmb     2          user idacstrt    rmb     4          task start timeacend     rmb     4          task stop timeacsyst    rmb     3          task system timeacusrt    rmb     3          task user timeacstat    rmb     2          task termination statusactty     rmb     1          task terminal numberacmem     rmb     1          max memory usedacblks    rmb     2          io blocks transferedacspar    rmb     2          spare bytesacname    rmb     8          command name if exec'dSABSIZ    equ     *          entry size