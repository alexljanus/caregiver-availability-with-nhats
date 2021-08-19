/*
features of model estimation
-essentially glm, irls
-essentially robust standard errors with cluser variable spid
-essentialy suest (but multiple imputation is incompatible with suest, do don't use multiple imputation here)
*/

#delimit ;

cd "F:\Research\NHATS project\NHATS\DATA" ;

log using "F:\Research\NHATS project\NHATS\LOGS\log2", replace ;

use LONG_2c, clear ;

/* nhats_h_focal_ns */

xtgee nhats_h_focal_ns ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* nhats_h_nonfocal_ns */

xtgee nhats_h_nonfocal_ns ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

xtgee nhats_h_nonfocal_ns ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if rnumchild==2 | rnumchild==3, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* nhats_h_nonfocal_spouse */

xtgee nhats_h_nonfocal_spouse ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform tolerance(.02) ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

xtgee nhats_h_nonfocal_spouse ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if hhmarried==1, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* nhats_h_nonfocal_formal */

xtgee nhats_h_nonfocal_formal ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* opdhrsmth_i */

xtgee opdhrsmth_i ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

xtgee opdhrsmth_i ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if rnumchild==2 | rnumchild==3 | hhmarried==1, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

recode workstat_3cat_fnsc (1 2=1) (3=0), generate(workstat_2cat_fnsc) ;
recode proximity_fnsc (1=0) (2 3=1), generate(proximity_2cat_fnsc) ;

/* nhats_h_focal_ns */

xtgee nhats_h_focal_ns ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

/* nhats_h_nonfocal_ns */

xtgee nhats_h_nonfocal_ns ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

xtgee nhats_h_nonfocal_ns ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if rnumchild==2 | rnumchild==3, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

/* nhats_h_nonfocal_spouse */

xtgee nhats_h_nonfocal_spouse ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform tolerance(.02) ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

xtgee nhats_h_nonfocal_spouse ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if hhmarried==1, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

/* nhats_h_nonfocal_formal */

xtgee nhats_h_nonfocal_formal ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

/* opdhrsmth_i */

xtgee opdhrsmth_i ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

xtgee opdhrsmth_i ib0.round ib0.workstat_2cat_fnsc ib0.proximity_2cat_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons] if rnumchild==2 | rnumchild==3 | hhmarried==1, family(poisson) link(log) corr(independent) vce(robust) eform ; 

margins workstat_2cat_fnsc ;
margins proximity_2cat_fnsc ;

/* runmet_adls */

xtgee runmet_adls ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(binomial) link(logit) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* runmet_adls */

xtgee runmet_adls ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
c.opdhrsmth_i_10 c.nonfocal_focal c.formal_informal 
[pweight=wanfinwgt_cons], family(binomial) link(logit) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* runmet_iadls */

xtgee runmet_iadls ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
[pweight=wanfinwgt_cons], family(binomial) link(logit) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

/* runmet_iadls */

xtgee runmet_iadls ib0.round ib3.workstat_3cat_fnsc ib1.proximity_fnsc ib2.helpertype_fnsc ib0.cgender_fnsc ib1.cage_fnsc ib1.health_fnsc
ib0.rfemale ib1.rlrace ib1.rage ib0.hhmarried ib0.rnumchild c.rnumber_adls c.rnumber_iadls ib3.rdemclas ib0.ipmedicaid c.totalincome_log ib0.rdresid
c.opdhrsmth_i_10 c.nonfocal_focal c.formal_informal 
[pweight=wanfinwgt_cons], family(binomial) link(logit) corr(independent) vce(robust) eform ; 

margins workstat_3cat_fnsc ;
margins proximity_fnsc ;

log close ;
