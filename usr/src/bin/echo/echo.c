/*
 * Copyright (c) 1989 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifndef lint
char copyright[] =
"@(#) Copyright (c) 1989 The Regents of the University of California.\n\
 All rights reserved.\n";
#endif /* not lint */

#ifndef lint
static char sccsid[] = "@(#)echo.c	5.4 (Berkeley) 4/3/91";
#endif /* not lint */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char *
escape(const char *str)
{
        char *buf, *dst;
        const char *src;
        size_t len;

        len = strlen(str);
        if ((buf = malloc(len + 1)) == NULL)
                return NULL;

        for (src = str, dst = buf; *src; ++src, ++dst) {
                if (*src == '\\') {
                        ++src;
                        switch (*src) {
                        case 'a':
                                *dst = '\a';
                                break;
                        case 'b':
                                *dst = '\b';
                                break;
                        case 'f':
                                *dst = '\f';
                                break;
                        case 'n':
                                *dst = '\n';
                                break;
                        case 'r':
                                *dst = '\r';
                                break;
                        case 't':
                                *dst = '\t';
                                break;
                        case 'v':
                                *dst = '\v';
                                break;
                        case '\\':
                                *dst = '\\';
                                break;
                        case '0': case '1': case '2': case '3':
                        case '4': case '5': case '6': case '7': {
                                int c, value = 0;

                                for (c = 0; c < 3 && *src >= '0' && *src <= '7'; ++c, ++src) {
                                        value <<= 3;
                                        value += *src - '0';
                                }
                                --src;
                                *dst = value;
                                break;
                        }
                        default:
                                *dst = *src;
                                break;
                        }
                } else
                        *dst = *src;
        }
        *dst = '\0';
        return buf;
}

/* ARGSUSED */
int
main(argc, argv)
        int argc;
        char **argv;
{
        int nflag, eflag;

        /* This utility may NOT do getopt(3) option parsing. */
        nflag = eflag = 0;
        ++argv;
        while (*argv && **argv == '-' && (*argv)[2] == '\0') {
                if ((*argv)[1] == 'n')
                        nflag = 1;
                else if ((*argv)[1] == 'e')
                        eflag = 1;
                else
                        break;
                ++argv;
        }

        while (*argv) {
                const char *out = *argv;
                char *tmp = NULL;
                if (eflag && (tmp = escape(*argv)) != NULL)
                        out = tmp;
                (void)printf("%s", out);
                free(tmp);
                if (*++argv)
                        putchar(' ');
        }
	if (!nflag)
		putchar('\n');
	exit(0);
}
