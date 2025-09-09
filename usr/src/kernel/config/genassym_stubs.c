/* Stub functions for genassym compilation */
#include "sys/types.h"
#include "sys/proc.h"
#include "vm_object.h"
#include "vm_page.h"

struct pgrp *pgfind(pid_t pgid) { return 0; }
void pgsignal(struct pgrp *pgrp, int sig, int checkctty) { }
void vm_page_insert(vm_page_t mem, vm_object_t object, vm_offset_t offset) { }