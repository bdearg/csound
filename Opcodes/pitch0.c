/*
    pitch0.c:

    Copyright (C) 1999 John ffitch, Istvan Varga

    This file is part of Csound.

    The Csound Library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Csound is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Csound; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#include "cs.h"         /*                                      PITCH.C       */
#include <limits.h>
#include "spectra.h"
#include "pitch.h"
#include "uggab.h"
#include "namedins.h"   /* IV - Oct 31 2002 */
#include "csdl.h"

int mute_inst(MUTE *p)
{
    int n = (int) strarg2insno(p->ins, p->STRARG);      /* IV - Oct 31 2002 */
    int onoff = (*p->onoff == FL(0.0) ? 0 : 1);
    if (n < 1) return NOTOK;
    if (onoff==0) {
      printf(Str(X_1778,"Muting new instances of instr %d\n"), n);
    }
    else {
      printf(Str(X_1779,"Allowing instrument %d to start\n"), n);
    }
    instrtxtp[n]->muted = onoff;
    return OK;
}

int instcount(INSTCNT *p)
{
    int n = (int)*p->ins;
    if (n<0 || n>maxinsno || instrtxtp[n]==NULL)
      *p->cnt = FL(0.0);
    else
      *p->cnt = (MYFLT)instrtxtp[n]->active;
    return OK;
}

/* After gabriel maldonado */

int cpuperc(CPU_PERC *p)
{
    int n = (int) *p->instrnum;
    if (n>=0 && n<=maxinsno && instrtxtp[n]!=NULL)     /* If instrument exists */
      instrtxtp[n]->cpuload = *p->ipercent;
    return OK;
}

int maxalloc(CPU_PERC *p)
{
    int n = (int) *p->instrnum;
    if (n>=0 && n<=maxinsno && instrtxtp[n]!=NULL)     /* If instrument exists */
      instrtxtp[n]->maxalloc = (int)*p->ipercent;
    return OK;
}

int prealloc(CPU_PERC *p)
{
    int     n, a;

    /* IV - Oct 31 2002 */
    n = (int) strarg2opcno(p->instrnum, p->STRARG,
                           (*p->iopc == FL(0.0) ? 0 : 1));
    if (n < 1) return NOTOK;
    /* IV - Oct 24 2002 */
    a = (int) *p->ipercent - instrtxtp[n]->active;
    for ( ; a > 0; a--) instance(n);
    return OK;
}

int pfun(PFUN *p)
{
    int n = (int)(*p->pnum + FL(0.5));
    MYFLT ans;
    printf("p(%d) %f\n", n,*p->pnum);
    if (n<1 || n>PMAX) ans = FL(0.0);
    else ans = currevent->p[n];
    *p->ans = ans;
    return OK;
}

