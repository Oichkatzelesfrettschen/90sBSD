/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _USR.BIN_CPIO_DEFER_H_
#define _USR.BIN_CPIO_DEFER_H_

struct deferment
  {
    struct deferment *next;
    struct new_cpio_header header;
  };

struct deferment *create_deferment P_((struct new_cpio_header *file_hdr));
void free_deferment P_((struct deferment *d));

#endif /* _USR.BIN_CPIO_DEFER_H_ */
