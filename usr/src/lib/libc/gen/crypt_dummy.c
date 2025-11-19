/* Dummy crypt stub - real implementation requires DES library */
extern int write(int, const void *, unsigned);

char *
crypt (k, s) char *k,*s; {
	write(2,"Crypt not present in system\n", 29);
	return(k);
}
