#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "fmmacja.h"
#include "tomacja.h"

#define PkgName "Lingua::JA::MacJapanese"

#define FromMbTbl	fm_macja
#define ToMbTbl 	to_macja
#define ToMbTblC	to_macja_contra

#define IsMbLED(i)   (0x81<=(i) && (i)<=0x9F || 0xE0<=(i) && (i)<=0xFC)
#define IsMbTRL(i)   (0x40<=(i) && (i)<=0x7E || 0x80<=(i) && (i)<=0xFC)

#define Is_SJIS_UDC(i)  (0xF0<=(i) && (i)<=0xFC)
#define Is_SJIS_PUA(uv) (0xE000 <= (uv) && (uv) <= 0xE98B)
#define SJIS_PUA_BASE   (0xE000)

/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvuni
#define utf8n_to_uvuni  utf8_to_uv
#endif /* utf8n_to_uvuni */

static void
sv_cat_cvref (SV *dst, SV *cv, SV *sv)
{
    dSP;
    int count;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(sv_2mortal(sv));
    PUTBACK;
    count = call_sv(cv, (G_EVAL|G_SCALAR));
    SPAGAIN;
    if (SvTRUE(ERRSV) || count != 1) {
	croak("died in XS, " PkgName "\n");
    }
    sv_catsv(dst,POPs);
    PUTBACK;
    FREETMPS;
    LEAVE;
}

MODULE = Lingua::JA::MacJapanese	PACKAGE = Lingua::JA::MacJapanese
PROTOTYPES: DISABLE

void
decode(...)
  ALIAS:
    decodeMacJapanese = 1
  PREINIT:
    SV *src, *dst, *ref;
    STRLEN srclen, mblen;
    U8 *s, *e, *p;
    bool has_cv = 0;
    bool has_pv = 0;
    STDCHAR **lb, *tb;
    UV uv;
    U8 unibuf[UTF8_MAXLEN + 1];
    STRLEN ulen;
  PPCODE:
    ref = NULL;
    if (0 < items && SvROK(ST(0))) {
	ref = SvRV(ST(0));
	if (SvTYPE(ref) == SVt_PVCV)
	    has_cv = TRUE;
	else if (SvPOK(ref))
	    has_pv = TRUE;
	else
	    croak(PkgName " 1st argument is not STRING nor CODEREF");
    }
    src = ref
	? (1 < items) ? ST(1) : &PL_sv_undef
	: (0 < items) ? ST(0) : &PL_sv_undef;

    if (SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_downgrade(src, 0);
    }
    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dst = sv_2mortal(newSV(1));
    (void)SvPOK_only(dst);
    SvUTF8_on(dst);

    for (p = s; p < e; p += mblen) {
	mblen = 2 <= (e - p) && IsMbLED(*p) && IsMbTRL(p[1]) ? 2 : 1;

	if (mblen == 2 && Is_SJIS_UDC(*(p))) {
	    uv = SJIS_PUA_BASE + 188 * (*(p) - 0xF0) +
		(p)[1] - ((p)[1] > 0x7E ? 0x41 : 0x40);
	    ulen = uvuni_to_utf8((U8*)unibuf, uv) - unibuf;
	    sv_catpvn(dst, (char*)unibuf, ulen);
	    continue;
	}

	lb = FromMbTbl[mblen == 2 ? *p : 0];
	tb = lb ? lb[mblen == 2 ? p[1] : *p] : NULL;

	if (tb) {
	    if (*tb)
		sv_catpv(dst, (char*)tb);
	    else /* \0 to \0 */
		sv_catpvn(dst, (char*)tb, 1);
	}
	else if (has_pv)
	    sv_catsv(dst, ref);
	else if (has_cv)
	    sv_cat_cvref(dst, ref, newSVpvn((char*)p, mblen));
    }
    XPUSHs(dst);


void
encode(...)
  ALIAS:
    encodeMacJapanese = 1
  PREINIT:
    SV *src, *dst, *ref;
    STRLEN srclen, retlen;
    U8 *s, *e, *p, mbcbuf[3];
    U16 mc, *t;
    struct mbc_contra *p_contra, *cel_contra, **row_contra;
    UV uv;
    bool has_cv = 0;
    bool has_pv = 0;
  PPCODE:
    ref = NULL;
    if (0 < items && SvROK(ST(0))) {
	ref = SvRV(ST(0));
	if (SvTYPE(ref) == SVt_PVCV)
	    has_cv = TRUE;
	else if (SvPOK(ref))
	    has_pv = TRUE;
	else
	    croak(PkgName " 1st argument is not STRING nor CODEREF");
    }
    src = ref
	? (1 < items) ? ST(1) : &PL_sv_undef
	: (0 < items) ? ST(0) : &PL_sv_undef;

    if (!SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_upgrade(src);
    }
    s = (U8*)SvPV(src,srclen);
    e = s + srclen;
    dst = sv_2mortal(newSV(1));
    (void)SvPOK_only(dst);
    SvUTF8_off(dst);

    for (p = s; p < e;) {
	uv = utf8n_to_uvuni(p, e - p, &retlen, 0);
	p += retlen;

	if (Is_SJIS_PUA(uv)) {
	    uv -= SJIS_PUA_BASE;
	    mbcbuf[0] = (U8)((uv / 188) + 0xF0);
	    mbcbuf[1] = (U8)(uv % 188 + (uv % 188 > 0x3E ? 0x41 : 0x40));
	    mbcbuf[2] = '\0';
	    sv_catpvn(dst, (char*)mbcbuf, 2);
	    continue;
	}

	mc = 0;
	row_contra = uv < 0x10000 ? ToMbTblC[uv >> 8] : NULL;
	cel_contra = row_contra ? row_contra[uv & 0xff] : NULL;

	if (cel_contra) {
	    for (p_contra = cel_contra; p_contra->string; p_contra++) {
		if (p_contra->len <= (e - p) &&
		    memEQ(p, p_contra->string, p_contra->len)) {
		    mc = p_contra->mchar;
		    p += p_contra->len;
		    break;
		}
	    }
	}

	if (!mc) {
	    t = uv < 0x10000 ? ToMbTbl[uv >> 8] : NULL;
	    mc = t ? t[uv & 0xff] : 0;
	}

	if (mc || uv == 0) {
	    if (mc >= 256) {
		mbcbuf[0] = (U8)(mc >> 8);
		mbcbuf[1] = (U8)(mc & 0xff);
		mbcbuf[2] = '\0';
		sv_catpvn(dst, (char*)mbcbuf, 2);
	    }
	    else {
		mbcbuf[0] = (U8)(mc & 0xff);
		mbcbuf[1] = '\0';
		sv_catpvn(dst, (char*)mbcbuf, 1);
	    }
	}
	else if (has_pv)
	    sv_catsv(dst, ref);
	else if (has_cv)
	    sv_cat_cvref(dst, ref, newSVuv(uv));
    }
    XPUSHs(dst);

