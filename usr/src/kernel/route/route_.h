/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_ROUTE_ROUTE__H_
#define _KERNEL_ROUTE_ROUTE__H_

extern void
rt_missmsg(int type, struct sockaddr *dst, struct sockaddr *gate,
	struct sockaddr *mask, struct sockaddr *src, int flags, int error);
/* static */ struct rtentry *rtalloc1(struct sockaddr *dst, int report);

#endif /* _KERNEL_ROUTE_ROUTE__H_ */
