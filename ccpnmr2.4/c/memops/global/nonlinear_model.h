/*
======================COPYRIGHT/LICENSE START==========================

nonlinear_model.h: Part of the CcpNmr Analysis program

Copyright (C) 2003-2010 Wayne Boucher and Tim Stevens (University of Cambridge)

=======================================================================

The CCPN license can be found in ../../../license/CCPN.license.

======================COPYRIGHT/LICENSE END============================

for further information, please contact :

- CCPN website (http://www.ccpn.ac.uk/)

- email: ccpn@bioc.cam.ac.uk

- contact the authors: wb104@bioc.cam.ac.uk, tjs23@cam.ac.uk
=======================================================================

If you are using this software for academic purposes, we suggest
quoting the following references:

===========================REFERENCE START=============================
R. Fogh, J. Ionides, E. Ulrich, W. Boucher, W. Vranken, J.P. Linge, M.
Habeck, W. Rieping, T.N. Bhat, J. Westbrook, K. Henrick, G. Gilliland,
H. Berman, J. Thornton, M. Nilges, J. Markley and E. Laue (2002). The
CCPN project: An interim report on a data model for the NMR community
(Progress report). Nature Struct. Biol. 9, 416-418.

Wim F. Vranken, Wayne Boucher, Tim J. Stevens, Rasmus
H. Fogh, Anne Pajon, Miguel Llinas, Eldon L. Ulrich, John L. Markley, John
Ionides and Ernest D. Laue (2005). The CCPN Data Model for NMR Spectroscopy:
Development of a Software Pipeline. Proteins 59, 687 - 696.

===========================REFERENCE END===============================

*/
#ifndef _incl_nonlinear_model
#define _incl_nonlinear_model

#include "macros.h"
#include "types.h"

#define  INITIAL_STAGE		1
#define  GENERAL_STAGE		2
#define  FINAL_STAGE		3

typedef void (*Nonlinear_model_func)(float x, float *a, float *y, float *dy_da, void *user_data);

extern CcpnStatus nonlinear_model
	(float *x, float *y, float *w, int n,
			float *a, float **covar, float **alpha,
			float *beta, float *da, float *ap, float *dy_da,
			int *piv, int *row, int *col, int m,
			float *chisq, float *lambda,
			Nonlinear_model_func func, int stage,
			void *user_data, char *error_msg);

extern CcpnStatus nonlinear_fit
        (int npts, float *x, float *y, float *w, float *y_fit,
        int nparams, float *params, float *params_dev,
        int max_iter, float noise, float *chisq,
        Nonlinear_model_func func, void *user_data, char *error_msg);

#endif /* _incl_nonlinear_model */
