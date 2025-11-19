/* rnd.c - version 1.0.2 */

#define RND(x)	((random()>>3) % x)

int
rn1(x,y)
int
register x,y;
{
	return(RND(x)+y);
}

int
rn2(x)
int
register x;
{
	return(RND(x));
}

int
rnd(x)
int
register x;
{
	return(RND(x)+1);
}

int
d(n,x)
int
register n,x;
{
int
	register tmp = n;

	while(n--) tmp += RND(x);
	return(tmp);
}
