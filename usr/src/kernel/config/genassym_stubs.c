/* Stub variables and functions for genassym compilation */
#include "sys/types.h"
#include "vm_param.h"

/* Forward declare types used in function signatures */
typedef struct vm_page *vm_page_t;
typedef struct vm_object *vm_object_t;

/* Kernel variables that genassym needs but aren't available during compilation */
int pidhashmask = 0;
struct proc *pidhash[1] = {0};

/* Empty stubs for functions that aren't implemented during genassym build */
struct pgrp *pgfind(pid_t pgid) { return 0; }
void pgsignal(struct pgrp *pgrp, int sig, int checkctty) { }
void vm_page_insert(vm_page_t mem, vm_object_t object, vm_offset_t offset) { }