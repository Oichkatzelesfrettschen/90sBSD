/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _LIB_LIBG++_G++_INCLUDE_SWAP_H_
#define _LIB_LIBG++_G++_INCLUDE_SWAP_H_

/* From Ron Guillmette; apparently needed for Hansen's code */

#define swap(a,b) ({ typeof(a) temp = (a); (a) = (b); (b) = temp; })

#endif /* _LIB_LIBG++_G++_INCLUDE_SWAP_H_ */
