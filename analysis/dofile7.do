/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Calculates estimates describing focal (primary) non-spousal helpers for Table 2: Characteristics of Focal Nonspousal Helpers.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log7", replace ;

/* TABLE 2, FOCAL NONSPOUSAL HELPERS */

use LONG_2, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

keep if ns_focal_nhats==1 & flag_nonspouse==1 ; /* CHANGE THIS LINE */

tabulate sp_with_interviewed_ns ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate sp_with_interviewed_ns ;

tabulate helpertype, missing ;
tabulate workstat_3cat, missing ;
tabulate proximity, missing ;
tabulate cgender, missing ;
tabulate cage, missing ;
tabulate health, missing ;

/* IMPUTING */

mi set flong ;

mi register imputed workstat_3cat proximity cgender cage health ;

mi impute chained 
(ologit, augment) workstat_3cat (mlogit, augment) proximity (ologit, augment) cage (ologit, augment) health = 
ib1.round ib0.rfemale ib1.rlrace ib1.rage c.rnumber_adls c.rnumber_iadls 
ib3.rdemclas ib0.ipmedicaid c.iatoincim1 ib0.rdresid 
, add(1) dots force ;

mean nhats_h_focal_ns if _mi_m==1 [pweight=wanfinwgt0] ;

proportion rank_ns_eligible_nhats if _mi_m==1 [pweight=wanfinwgt0] ;
recode SP_flag_eligible_ns (1=0) (2/1000=1) ;
proportion SP_flag_eligible_ns if _mi_m==1 [pweight=wanfinwgt0] ;
proportion rank_ns_eligible_nhats if _mi_m==1 & SP_flag_eligible_ns==1 [pweight=wanfinwgt0] ;

proportion SP_morehours_spouse if _mi_m==1 [pweight=wanfinwgt0] ;
recode SP_flag_eligible_spouse (0=0) (1/1000=1) ;
proportion SP_flag_eligible_spouse if _mi_m==1 [pweight=wanfinwgt0] ;
proportion SP_morehours_spouse if _mi_m==1 & SP_flag_eligible_spouse==1 [pweight=wanfinwgt0] ;

proportion SP_morehours_formal if _mi_m==1 [pweight=wanfinwgt0] ;
recode SP_flag_formal (0=0) (1/1000=1) ;
proportion SP_flag_formal if _mi_m==1 [pweight=wanfinwgt0] ;
proportion SP_morehours_formal if _mi_m==1 & SP_flag_formal==1 [pweight=wanfinwgt0] ;

proportion help_mobility if _mi_m==1 [pweight=wanfinwgt0] ;
proportion help_selfcare if _mi_m==1 [pweight=wanfinwgt0] ;
proportion help_household if _mi_m==1 [pweight=wanfinwgt0] ;
proportion help_other if _mi_m==1 [pweight=wanfinwgt0] ;

proportion helpertype if _mi_m==1 [pweight=wanfinwgt0] ;

proportion workstat_3cat if _mi_m==1 [pweight=wanfinwgt0] ;
proportion proximity if _mi_m==1 [pweight=wanfinwgt0] ;
proportion cgender if _mi_m==1 [pweight=wanfinwgt0] ;
proportion cage if _mi_m==1 [pweight=wanfinwgt0] ;
proportion health if _mi_m==1 [pweight=wanfinwgt0] ;

/* TABLE 2, NONFOCAL NONSPOUSAL HELPERS */

use LONG_2, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

keep if ns_focal_nhats~=1 & flag_nonspouse==1 ; /* CHANGE THIS LINE */

tabulate sp_with_interviewed_ns ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate sp_with_interviewed_ns ;

tabulate helpertype, missing ;

mean nhats_h_nonfocal_ns [pweight=wanfinwgt0] ;

proportion help_mobility [pweight=wanfinwgt0] ;
proportion help_selfcare [pweight=wanfinwgt0] ;
proportion help_household [pweight=wanfinwgt0] ;
proportion help_other [pweight=wanfinwgt0] ;

proportion helpertype [pweight=wanfinwgt0] ;

/* TABLE 2, NONFOCAL SPOUSAL HELPERS */

use LONG_2, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

keep if ns_focal_nhats~=1 & flag_spouse==1 ; /* CHANGE THIS LINE */

tabulate sp_with_interviewed_ns ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate sp_with_interviewed_ns ;

tabulate helpertype, missing ;

mean nhats_h_nonfocal_spouse [pweight=wanfinwgt0] ;

proportion help_mobility [pweight=wanfinwgt0] ;
proportion help_selfcare [pweight=wanfinwgt0] ;
proportion help_household [pweight=wanfinwgt0] ;
proportion help_other [pweight=wanfinwgt0] ;

proportion helpertype [pweight=wanfinwgt0] ;

/* TABLE 2, FORMAL HELPERS */

use LONG_2, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

keep if ns_focal_nhats~=1 & flag_formal==1 ; /* CHANGE THIS LINE */

tabulate sp_with_interviewed_ns ;

drop if round==. | rfemale==. | rlrace==. | rage==. | rnumber_adls==. | rnumber_iadls==. | 
rdemclas==. | ipmedicaid==. | 
hhmarital==. | rnumchild==. |
iatoincim1==. | rdresid==. ;

tabulate sp_with_interviewed_ns ;

tabulate helpertype, missing ;

mean nhats_h_nonfocal_formal [pweight=wanfinwgt0] ;

proportion help_mobility [pweight=wanfinwgt0] ;
proportion help_selfcare [pweight=wanfinwgt0] ;
proportion help_household [pweight=wanfinwgt0] ;
proportion help_other [pweight=wanfinwgt0] ;

proportion helpertype [pweight=wanfinwgt0] ;

log close ;
