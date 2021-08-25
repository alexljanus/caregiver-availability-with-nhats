/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Creates a sample-person-level dataset to be used for the statistical models (i.e., sample persons with at least one nonspousal caregiver/helper who was interviewed in the National Study of Caregiving).

Performs one set of imputations to impute missing values of the measures to be used as independent variables in the statistical models.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log9", replace ;

/* FOR SP/CG-LEVEL MODELS, WITH IMPUTATIONS FOR SP/CG-LEVEL CHARACTERISTICS */

use LONG_2b, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

summarize opdhrsmth_i, detail ;

collapse 
/* dependent variables */
(rawsum) 
opdhrsmth_i
nhats_h_focal_ns 
nhats_h_nonfocal_ns 
nhats_h_nonfocal_spouse 
nhats_h_nonfocal_formal 
nhats_h_informal
nhats_h_formal 
(firstnm)
runmet_adls runmet_iadls 
/* focal caregiver characteristics */
(firstnm)
workstat_3cat_fnsc proximity_fnsc helpertype_fnsc cgender_fnsc cage_fnsc health_fnsc
/* sample person characteristics */
(mean)
hhmarital hhmarried rnumchild rhas2child rfemale rlrace rage rnumber_adls rnumber_iadls rdemclas ipmedicaid 
/* household characteristics */
rdresid wanfinwgt0 wvarunit wvarstrat wanfinwgt_cons
/* income variables */
iatoincim1 iatoincim2 iatoincim3 iatoincim4 iatoincim5 
iatotinc iatoincimf iatoincesjt iatoincessg 
, by(spid round) ;

summarize opdhrsmth_i, detail ;

generate opdhrsmth_i_10 = opdhrsmth_i/10 ;
generate formal_informal = 10*(nhats_h_formal / (nhats_h_formal + nhats_h_informal)) ;
generate nonfocal_focal = 10*((nhats_h_nonfocal_spouse + nhats_h_nonfocal_ns) / (nhats_h_nonfocal_spouse + nhats_h_focal_ns + nhats_h_nonfocal_ns)) ;

duplicates report spid round ;

tabulate workstat_3cat_fnsc, missing ;
tabulate proximity_fnsc, missing ;
tabulate helpertype_fnsc, missing ;
tabulate cgender_fnsc, missing ;
tabulate cage_fnsc, missing ;
tabulate health_fnsc, missing ;

tabulate hhmarital, missing ;
tabulate hhmarried, missing ;
tabulate rnumchild, missing ;
tabulate rhas2child, missing ;
tabulate rfemale, missing ;
tabulate rlrace, missing ;
tabulate rage, missing ;
tabulate rnumber_adls, missing ;
tabulate rnumber_iadls, missing ;
tabulate rdemclas, missing ;
tabulate ipmedicaid, missing ;
summarize iatoincim1, detail ;
tabulate rdresid, missing ;

/* analyzing income missingness */
recode iatotinc (0/1000000000=1), generate(iatotinc_r) ;
recode iatoincesjt (1/5=1), generate(iatoincesjt_r) ;
recode iatoincessg (1/5=1), generate(iatoincessg_r) ;
tabulate iatotinc_r, missing ; /* # with exact income */
tabulate iatoincimf, missing ; /* # without exact income */
tab2 iatotinc_r iatoincimf, missing col ; /* confirms above */
generate inc_bracket_flag = 1 if iatoincesjt_r==1 | iatoincessg_r==1 ;
tabulate inc_bracket_flag, missing ; /* # with income bracket */
tabulate inc_bracket_flag if iatoincimf==1, missing ;

/*
REPORT ON MISSINGNESS

workstat_3cat_fc: 43
proximity_fc: 77
health_fc: 27
cgender_fc: 4
cage_fc: 531
helpertype_fc: 0

rfemale: 0
rlrace: 8
rage: 0
rnumber_adls: 26
rnumber_iadls: 0
rdemclas: 4
ipmedicaid: 65
iatoincim1: 0
rdresid: 24
iatoincimf: 0

*/

/* IMPUTING */

mi set flong ;

mi register imputed rnumber_adls ipmedicaid rdresid 
workstat_3cat_fnsc proximity_fnsc cgender_fnsc cage_fnsc health_fnsc ;

mi impute chained 
(pmm, knn(10)) rnumber_adls (logit) ipmedicaid (logit) rdresid 
(pmm, knn(10)) workstat_3cat_fnsc (pmm, knn(10)) proximity_fnsc (logit) cgender_fnsc (pmm, knn(10)) cage_fnsc (pmm, knn(10)) health_fnsc = 
ib1.round ib1.hhmarital ib0.rnumchild ib0.rfemale ib1.rlrace ib1.rage 
ib0.rnumber_iadls ib3.rdemclas c.iatoincim1 
[pweight=wanfinwgt0], add(1) dots force ;

/* the five imputed income variables */

generate totalincome = iatoincim1 if _mi_m==1 ;
replace totalincome = iatoincim2 if _mi_m==2 ;
replace totalincome = iatoincim3 if _mi_m==3 ;
replace totalincome = iatoincim4 if _mi_m==4 ;
replace totalincome = iatoincim5 if _mi_m==5 ;

summarize iatoincim1 if _mi_m==1 | _mi_m==2 | _mi_m==3 | _mi_m==4 | _mi_m==5, detail ;

summarize totalincome if _mi_m==1 | _mi_m==2 | _mi_m==3 | _mi_m==4 | _mi_m==5, detail ;

/* additional recodes for models */

recode rdemclas (1/2=1) (3=0), generate(rdemclas_cat) ;

generate totalincome_log = ln(totalincome) ;

summarize totalincome_log, detail ;

/* mi xtsetting and mi svysetting data */
/*
mi svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) ; 
*/

mi xtset spid round ;

mi extract 1, clear ;

recode round (1=0) (5=1) ;

save LONG_2c, replace ;

log close ;
