/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Creates datasets of summary statistics describing sample persons for use in constructing Table 1: Characteristics of SPs with at least 1 NSOC-Interviewed Nonspousal Helper, SPs without an NSOC-Interviewed Nonspousal Helper, and the Combined Sample.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log6", replace ;

/* Table 1 (SPs with an NSOC-Eligible Caregiver) */

use LONG_2, clear ;

keep if sp_with_eligible_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

tabulate flag_eligible_ns, missing ;
tabulate flag_interviewed_ns, missing ;

collapse 
(rawsum) 
opdhrsmth_i 
nhats_h_informal 
nhats_h_ns 
nhats_h_nonfocal_spouse
nhats_h_formal 
flag_helper flag_informal flag_formal 
sp_with_eligible_ns sp_with_interviewed_ns
flag_eligible_ns flag_interviewed_ns 
(mean)
runmet_adls runmet_iadls runmet_any 
rfemale rlrace rage rnumber_adls rnumber_iadls rdemclas ipmedicaid
hhmarital rnumchild  
iatoincim1 rdresid wanfinwgt0 wvarunit wvarstrat iatoincimf
, by(spid round) ;

recode flag_formal (0=0) (1/100=1) ;

tabulate round ; 
tabulate rfemale, missing ;
tabulate rlrace, missing ;
tabulate rage, missing ;
tabulate rnumber_adls, missing ;
tabulate rnumber_iadls, missing ;
tabulate rdemclas, missing ;
tabulate ipmedicaid, missing ;
tabulate hhmarital, missing ; 
tabulate rnumchild, missing ;  
summarize iatoincim1, detail ;
tabulate rdresid, missing ;

generate missing_sp = 1 if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate missing_sp ;

/* trying different svyset commands */

/* svyset wvarunit, strata(wvarstrat) weight(wanfinwgt0) ; */
/* svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) ; */

/* IMPUTING rnumber_adls ipmedicaid rdresid */

mi set flong ;

mi register imputed rnumber_adls ipmedicaid rdresid ;

mi impute chained 
(ologit) rnumber_adls (logit) ipmedicaid (logit) rdresid = 
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumber_iadls ib3.rdemclas ib1.hhmarital ib0.rnumchild c.iatoincim1 ib1.round 
, add(1) dots force ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

proportion sp_with_eligible_ns if _mi_m==1 [pweight=wanfinwgt0] ;

proportion round if _mi_m==1 [pweight=wanfinwgt0] ;

mean opdhrsmth_i if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_informal if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_ns if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_nonfocal_spouse if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_formal if _mi_m==1 [pweight=wanfinwgt0] ;

mean flag_helper if _mi_m==1 [pweight=wanfinwgt0] ;
mean flag_informal if _mi_m==1 [pweight=wanfinwgt0] ;
proportion flag_formal if _mi_m==1 [pweight=wanfinwgt0] ;

proportion runmet_adls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_any if _mi_m==1 [pweight=wanfinwgt0] ;

proportion rfemale if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rlrace if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rage if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_adls if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdemclas if _mi_m==1 [pweight=wanfinwgt0] ;
proportion ipmedicaid if _mi_m==1 [pweight=wanfinwgt0] ;
proportion hhmarital if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rnumchild if _mi_m==1 [pweight=wanfinwgt0] ;
mean iatoincim1 if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdresid if _mi_m==1 [pweight=wanfinwgt0] ;

/* Table 1 (SPs with an NSOC-Interviewed Caregiver) */

use LONG_2, clear ;

keep if sp_with_eligible_ns==1 & sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

collapse 
(rawsum) 
opdhrsmth_i 
nhats_h_informal 
nhats_h_ns 
nhats_h_nonfocal_spouse
nhats_h_formal 
flag_helper flag_informal flag_formal 
sp_with_eligible_ns sp_with_interviewed_ns
(mean)
runmet_adls runmet_iadls runmet_any 
rfemale rlrace rage rnumber_adls rnumber_iadls rdemclas ipmedicaid
hhmarital rnumchild  
iatoincim1 rdresid wanfinwgt0 wvarunit wvarstrat iatoincimf
, by(spid round) ;

recode flag_formal (0=0) (1/100=1) ;

tabulate round ; 
tabulate rfemale, missing ;
tabulate rlrace, missing ;
tabulate rage, missing ;
tabulate rnumber_adls, missing ;
tabulate rnumber_iadls, missing ;
tabulate rdemclas, missing ;
tabulate ipmedicaid, missing ;
tabulate hhmarital, missing ; 
tabulate rnumchild, missing ;  
summarize iatoincim1, detail ;
tabulate rdresid, missing ;

generate missing_sp = 1 if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate missing_sp ;

/* trying different svyset commands */

/* svyset wvarunit, strata(wvarstrat) weight(wanfinwgt0) ; */
/* svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) ; */

/* IMPUTING rnumber_adls ipmedicaid rdresid */

mi set flong ;

mi register imputed rnumber_adls ipmedicaid rdresid ;

mi impute chained 
(ologit) rnumber_adls (logit) ipmedicaid (logit) rdresid = 
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumber_iadls ib3.rdemclas ib1.hhmarital ib0.rnumchild c.iatoincim1 ib1.round 
, add(1) dots force ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

proportion sp_with_eligible_ns if _mi_m==1 [pweight=wanfinwgt0] ;

proportion round if _mi_m==1 [pweight=wanfinwgt0] ;

mean opdhrsmth_i if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_informal if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_ns if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_nonfocal_spouse if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_formal if _mi_m==1 [pweight=wanfinwgt0] ;

mean flag_helper if _mi_m==1 [pweight=wanfinwgt0] ;
mean flag_informal if _mi_m==1 [pweight=wanfinwgt0] ;
proportion flag_formal if _mi_m==1 [pweight=wanfinwgt0] ;

proportion runmet_adls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_any if _mi_m==1 [pweight=wanfinwgt0] ;

proportion rfemale if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rlrace if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rage if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_adls if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdemclas if _mi_m==1 [pweight=wanfinwgt0] ;
proportion ipmedicaid if _mi_m==1 [pweight=wanfinwgt0] ;
proportion hhmarital if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rnumchild if _mi_m==1 [pweight=wanfinwgt0] ;
mean iatoincim1 if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdresid if _mi_m==1 [pweight=wanfinwgt0] ;

/* figuring out number of SPs per round */

use LONG_2, clear ;

keep if sp_with_eligible_ns==1 & sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

collapse 
(rawsum) 
opdhrsmth_i 
nhats_h_informal 
nhats_h_formal 
flag_helper flag_informal flag_formal 
sp_with_eligible_ns sp_with_interviewed_ns
(mean)
runmet_adls runmet_iadls runmet_any 
rfemale rlrace rage rnumber_adls rnumber_iadls rdemclas ipmedicaid
hhmarital rnumchild  
iatoincim1 rdresid wanfinwgt0 wvarunit wvarstrat iatoincimf
, by(spid round) ;

generate round_flag=1 if round==1 ;
replace round_flag=2 if round==5 ;

tabulate round, missing ;

tabulate round_flag, missing ;

collapse 
(rawsum) 
round_flag
, by(spid) ;

tabulate round_flag, missing ;

/* Table 1 (SPs without an NSOC-Interviewed Caregiver) */

use LONG_2, clear ;

keep if sp_with_eligible_ns==1 & sp_with_interviewed_ns~=1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

collapse 
(rawsum) 
opdhrsmth_i 
nhats_h_informal 
nhats_h_ns 
nhats_h_nonfocal_spouse
nhats_h_formal 
flag_helper flag_informal flag_formal 
sp_with_eligible_ns sp_with_interviewed_ns
(mean)
runmet_adls runmet_iadls runmet_any 
rfemale rlrace rage rnumber_adls rnumber_iadls rdemclas ipmedicaid
hhmarital rnumchild  
iatoincim1 rdresid wanfinwgt0 wvarunit wvarstrat iatoincimf
, by(spid round) ;

recode flag_formal (0=0) (1/100=1) ;

tabulate round ; 
tabulate rfemale, missing ;
tabulate rlrace, missing ;
tabulate rage, missing ;
tabulate rnumber_adls, missing ;
tabulate rnumber_iadls, missing ;
tabulate rdemclas, missing ;
tabulate ipmedicaid, missing ;
tabulate hhmarital, missing ; 
tabulate rnumchild, missing ;  
summarize iatoincim1, detail ;
tabulate rdresid, missing ;

generate missing_sp = 1 if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate missing_sp ;

/* trying different svyset commands */

/* svyset wvarunit, strata(wvarstrat) weight(wanfinwgt0) ; */
/* svyset wvarunit [pweight=wanfinwgt0], strata(wvarstrat) ; */

/* IMPUTING rnumber_adls ipmedicaid rdresid */

mi set flong ;

mi register imputed rnumber_adls ipmedicaid rdresid ;

mi impute chained 
(ologit) rnumber_adls (logit) ipmedicaid (logit) rdresid = 
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumber_iadls ib3.rdemclas ib1.hhmarital ib0.rnumchild c.iatoincim1 ib1.round 
, add(1) dots force ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

proportion sp_with_eligible_ns if _mi_m==1 [pweight=wanfinwgt0] ;

proportion round if _mi_m==1 [pweight=wanfinwgt0] ;

mean opdhrsmth_i if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_informal if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_ns if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_nonfocal_spouse if _mi_m==1 [pweight=wanfinwgt0] ;
mean nhats_h_formal if _mi_m==1 [pweight=wanfinwgt0] ;

mean flag_helper if _mi_m==1 [pweight=wanfinwgt0] ;
mean flag_informal if _mi_m==1 [pweight=wanfinwgt0] ;
proportion flag_formal if _mi_m==1 [pweight=wanfinwgt0] ;

proportion runmet_adls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion runmet_any if _mi_m==1 [pweight=wanfinwgt0] ;

proportion rfemale if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rlrace if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rage if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_adls if _mi_m==1 [pweight=wanfinwgt0] ;
mean rnumber_iadls if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdemclas if _mi_m==1 [pweight=wanfinwgt0] ;
proportion ipmedicaid if _mi_m==1 [pweight=wanfinwgt0] ;
proportion hhmarital if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rnumchild if _mi_m==1 [pweight=wanfinwgt0] ;
mean iatoincim1 if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rdresid if _mi_m==1 [pweight=wanfinwgt0] ;

log close ;
