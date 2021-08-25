/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Performs a one-to-one merge with the revised other-person-level data files from Round 1 and Round 5.

Reshapes the merged data file ("WIDE") from wide to long format so that caregiver/helper-level data from different rounds is recorded in separate rows.

Generates the following caregiver/helper-level variables:
	Multiple helper flags.
	Measures of caregivers'/helpers' socio-demographic characteristics.
	Dependent variables for the hours of care received from focal (primary) non-spousal helpers, non-focal non-spousal helpers, non-focal spousal helpers, formal helpers, and all sources combined.

Saves a revised caregiver/helper-level data file in long format so that caregiver/helper-level data from different rounds is recorded in separate rows.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log5", replace ;

use ROUND1, clear ;

merge 1:1 spid opid using ROUND5, generate(_merge5) ;

save WIDE, replace ;

use WIDE, clear ;

/* RESHAPE FROM WIDE TO LONG */

reshape long op@dnsoc op@paidhelpr op@relatnshp op@dhrsmth op@dage
op@outhlp op@insdhlp op@bedhlp op@eathlp op@bathhlp op@toilhlp op@dreshlp op@launhlp op@shophlp op@mealhlp op@bankhlp op@medshlp 
op@moneyhlp op@dochlp op@insurhlp op@tkplhlp1 op@tkplhlp2 op@prsninhh
cdc@hlpdyswk cdc@hlphrsdy cdc@hlphrmvf cdc@hlpsched cdc@hlpdysmt cdc@hlphrlmt c@dgender cca@tm2spmin cca@tm2spunt cca@tm2sphrs che@health
cec@hrsweek cec@wrkmulti cec@hrslstwk cec@misswork cec@hrswork cec@flexhrs cec@wrksched cec@wrk4pay 
chd@martstat chd@chldlvng chd@numchild chd@numchu18 w@cgfinwgt0
r@demclas r@number_iadls r@number_adls r@unmet_adls r@unmet_iadls r@unmet_any hh@specdisabled 
hh@marital hh@married r@numchild r@has2child ip@medicaid r@female rl@race r@age r@dresid 
ia@toincim1 ia@toincim2 ia@toincim3 ia@toincim4 ia@toincim5 
w@anfinwgt0 w@varunit w@varstrat ia@toincimf ia@totinc ia@toincesjt ia@toincessg
op@dhrsmth_i, i(spid opid) j(round) ;

/* RECODING CAREGIVING HOURS */

recode opdhrsmth_i (-1=.) ;

replace opdhrsmth_i = opdhrsmth_i / 4 ;

tabulate opdhrsmth_i ;

/* GENERATING NSOC-ELIGIBLE HELPER AND NSOC-INTERVIEWED HELPER FLAGS */

tab2 opdnsoc round, col missing ;

generate flag_eligible=1 if opdnsoc==1 | opdnsoc==2 | opdnsoc==3 | opdnsoc==4 | opdnsoc==5 | opdnsoc==6 ;

tab2 flag_eligible round, col missing ;

generate flag_interviewed=1 if opdnsoc==1 ;

tab2 flag_interviewed round, col missing ;

/* GENERATING HELPERTYPE */

tabulate oppaidhelpr ;
recode oppaidhelpr (1=1) (-8 -7 -1 2=.), generate(flag_paid) ;
tab2 flag_paid round, col missing ;

tab2 oprelatnshp round, col missing ;
recode oprelatnshp (-1=.) (2 41=1) (3 4=2) (5/29 91 = 3) (30/39 40 92 = 4), generate(oprelatnshp_r) ;
tab2 oprelatnshp_r round, col missing ;

generate helpertype = 1 if oprelatnshp_r==1 & flag_eligible==1 ; /* NSOC-eligible spouse */
replace helpertype = 2 if oprelatnshp_r==2 & flag_eligible==1 ; /* NSOC-eligible child */
replace helpertype = 3 if oprelatnshp_r==3 & flag_eligible==1 ; /* NSOC-eligible other related helper */
replace helpertype = 4 if oprelatnshp_r==4 & flag_paid~=1 & flag_eligible==1 ; /* NSOC-eligible unpaid unrelated helper */
replace helpertype = 5 if oprelatnshp_r==4 & flag_paid==1 ; /* paid unrelated helper */

tab2 helpertype round, col missing ;

/* KEEPING FORMAL AND (NSOC-ELIGIBLE) INFORMAL HELPERS */

keep if helpertype==1 | helpertype==2 | helpertype==3 | helpertype==4 | helpertype==5 ;

/* GENERATING HELPERTYPE FLAGS */

generate flag_helper=1 ;
generate flag_informal=1 if helpertype==1 | helpertype==2 | helpertype==3 | helpertype==4 ;
generate flag_spouse=1 if helpertype==1 ;
generate flag_nonspouse=1 if helpertype==2 | helpertype==3 | helpertype==4 ;
generate flag_formal=1 if helpertype==5 ;
generate flag_child=1 if helpertype==2 ;
generate flag_nonchild=1 if helpertype==1 | helpertype==3 | helpertype==4 ;
generate flag_related=1 if helpertype==3 ;
generate flag_unpaid=1 if helpertype==4 ;

/* GENERATING NSOC-ELIGIBLE (NON)SPOUSAL HELPER AND NSOC-INTERVIEWED (NON)SPOUSAL HELPER FLAGS */

tab2 opdnsoc round, col missing ;

generate flag_eligible_ns=1 if (opdnsoc==1 | opdnsoc==2 | opdnsoc==3 | opdnsoc==4 | opdnsoc==5 | opdnsoc==6) & flag_nonspouse==1 ;

tab2 flag_eligible_ns round, col missing ;

generate flag_eligible_spouse=1 if (opdnsoc==1 | opdnsoc==2 | opdnsoc==3 | opdnsoc==4 | opdnsoc==5 | opdnsoc==6) & flag_spouse==1 ;

tab2 flag_eligible_spouse round, col missing ;

generate flag_interviewed_ns=1 if opdnsoc==1 & flag_nonspouse==1 ;

tab2 flag_interviewed_ns round, col missing ;

generate flag_interviewed_spouse=1 if opdnsoc==1 & flag_spouse==1 ;

tab2 flag_interviewed_spouse round, col missing ;

/* IDENTIFYING OLDER PEOPLE WITH AT LEAST ONE NSOC-ELIGIBLE CAREGIVER */

bysort round spid: egen sp_num_eligible = count(flag_eligible) ;

tab2 sp_num_eligible round, col missing ;

generate sp_with_eligible=1 if sp_num_eligible>=1 & sp_num_eligible<1000 ;

tab2 sp_with_eligible round, col missing ;

/* IDENTIFYING OLDER PEOPLE WITH AT LEAST ONE NSOC-INTERVIEWED CAREGIVER */

bysort round spid: egen sp_num_interviewed = count(flag_interviewed) ;

tab2 sp_num_interviewed round, col missing ;

generate sp_with_interviewed=1 if sp_num_interviewed>=1 & sp_num_interviewed<1000 ;

tab2 sp_with_interviewed round, col missing ;

/* IDENTIFYING OLDER PEOPLE WITH AT LEAST ONE NSOC-ELIGIBLE NONSPOUSAL CAREGIVER */

bysort round spid: egen sp_num_eligible_ns = count(flag_eligible_ns) ;

tab2 sp_num_eligible_ns round, col missing ;

generate sp_with_eligible_ns=1 if sp_num_eligible_ns>=1 & sp_num_eligible_ns<1000 ;

tab2 sp_with_eligible_ns round, col missing ;

/* IDENTIFYING OLDER PEOPLE WITH AT LEAST ONE NSOC-INTERVIEWED NONSPOUSAL CAREGIVER */

bysort round spid: egen sp_num_interviewed_ns = count(flag_interviewed_ns) ;

tab2 sp_num_interviewed_ns round, col missing ;

generate sp_with_interviewed_ns=1 if sp_num_interviewed_ns>=1 & sp_num_interviewed_ns<1000 ;

tab2 sp_with_interviewed_ns round, col missing ;

/* caregiver's hours usually worked */

generate workhours = cechrsweek if cecwrkmulti==2 & cechrsweek~=997 ;
replace workhours = cechrslstwk if cecwrkmulti==2 & cechrsweek==997 & cecmisswork~=1 ;
replace workhours = cechrswork if cecwrkmulti==1 ;

recode workhours cecflexhrs cecwrksched (-7 -8 -1=.) ;

bysort round: summarize workhours, detail ;

tab2 workhours round, col missing ;

recode workhours (1/39=1) (40/1000=2), generate(partfulltime) ;

tab2 partfulltime round, col missing ;

/* caregiver's two-category and three-category employment status */

recode cecwrk4pay (1=1) (2 3=0) (-7 -8=.), generate(workstat_2cat) ;

tab2 workstat_2cat round, col missing ;

generate workstat_3cat = 3 if workstat_2cat==0 ;
replace workstat_3cat = 1 if workstat_2cat==1 & partfulltime==2 ;
replace workstat_3cat = 2 if workstat_2cat==1 & partfulltime==1 ;

tab2 workstat_3cat round, col missing ;

/* proximity to SP */

recode ccatm2spmin (1/14=1) (15/29=2) (30/59=3) (60=4), generate(ccatm2spmin_cat) ;

generate proximity = . if ccatm2spunt==-7 | ccatm2spunt==-8 ;
replace proximity = 1 if ccatm2spunt==-1 ; /* co-resident */
replace proximity = 2 if ccatm2spmin_cat==1 ; 
replace proximity = 3 if ccatm2spmin_cat==2 ; 
replace proximity = 4 if ccatm2spmin_cat==3 ; 
replace proximity = 5 if (ccatm2spmin_cat==4 | (ccatm2sphrs>=1 & ccatm2sphrs<100)) ;
/*
replace proximity = 6 if (ccatm2spmin_cat==1 | ccatm2spmin_cat==2 | ccatm2spmin_cat==3 | ccatm2spmin_cat==4 | 
(ccatm2sphrs>=1 & ccatm2sphrs<100)) 
& helpertype==1 ; /* spouse */
*/
tab2 proximity round, col missing ;

recode proximity (1=1) (2/3=2) (4/5=3) ;

tab2 proximity round, col missing ;

/* gender */

recode cdgender (1=0) (2=1) (-9=.), generate(cgender) ;

tab2 cgender round, col missing ;

/* caregiver's marital status and children */

recode chdmartstat (-8 -7 -1=.) (1 2=1) (3 4 5 6=0), generate(cg_married) ;

generate cg_childu18 = 1 if chdnumchu18>=1 & chdnumchu18<10 ;
replace cg_childu18 = 0 if chdnumchu18==0 | chdchldlvng==2 ;

/* subjective health */

recode chehealth (1=1) (2=2) (3=3) (4=4) (5=5) (-7 -8=.), generate(health) ;

tab2 health round, col missing ;

/* IDENTIFYING PRIMARY, SECONDARY CAREGIVERS, ETC. AMONG NSOC-ELIGIBLE HELPERS AND NSOC-INTERVIEWED HELPERS */

bysort round spid: egen rank_helper_nhats = rank(opdhrsmth_i) if flag_helper==1, unique ;
bysort round spid: egen rank_eligible_nhats = rank(opdhrsmth_i) if flag_eligible==1, unique ;
bysort round spid: egen rank_interviewed_nhats = rank(opdhrsmth_i) if flag_interviewed==1, unique ;

tab2 rank_helper_nhats round, col missing ;
tab2 rank_eligible_nhats round, col missing ;
tab2 rank_interviewed_nhats round, col missing ;

/* SAME FOR NON-SPOUSAL CAREGIVERS ONLY */

bysort round spid: egen rank_ns_helper_nhats = rank(opdhrsmth_i) if flag_helper==1 & flag_nonspouse==1, unique ;
bysort round spid: egen rank_ns_eligible_nhats = rank(opdhrsmth_i) if flag_eligible==1 & flag_nonspouse==1, unique ;
bysort round spid: egen rank_ns_interviewed_nhats = rank(opdhrsmth_i) if flag_interviewed==1 & flag_nonspouse==1, unique ;

tab2 rank_ns_helper_nhats round, col missing ;
tab2 rank_ns_eligible_nhats round, col missing ;
tab2 rank_ns_interviewed_nhats round, col missing ;

/* VARIABLE FOR NUMBER OF NONSPOUSE, SPOUSAL, AND FORMAL HELPERS TO USE IN CREATING TABLE 2 */

bysort round spid: egen SP_flag_eligible_ns = total(flag_eligible_ns) ;
bysort round spid: egen SP_flag_eligible_spouse = total(flag_eligible_spouse) ;
bysort round spid: egen SP_flag_formal = total(flag_formal) ;

/* IDENTIFYING FOCAL CAREGIVERS */

generate focal_nhats=1 if rank_interviewed_nhats==1 ;

tab2 rank_eligible_nhats round if focal_nhats==1, col missing ;

/* IDENTIFYING FOCAL NON-SPOUSAL CAREGIVERS */

generate ns_focal_nhats=1 if rank_ns_interviewed_nhats==1 ;

tab2 rank_ns_eligible_nhats round if ns_focal_nhats==1, col missing ;

/* GENERATING OUTCOMES: 
(a) FOCAL NON-SPOUSE, (b) NON-FOCAL NON-SPOUSE, (c) NON-FOCAL SPOUSE, (d) FORMAL, and (e) ALL SOURCES COMBINED */

generate nhats_h_focal_ns = opdhrsmth_i if flag_nonspouse==1 & ns_focal_nhats==1 ;
generate nhats_h_nonfocal_ns = opdhrsmth_i if flag_nonspouse==1 & ns_focal_nhats~=1 ;
generate nhats_h_nonfocal_spouse = opdhrsmth_i if flag_spouse==1 & ns_focal_nhats~=1 ;
generate nhats_h_nonfocal_formal = opdhrsmth_i if flag_formal==1 & ns_focal_nhats~=1 ;

generate nhats_h_informal = opdhrsmth_i if flag_informal==1 ;
generate nhats_h_ns = opdhrsmth_i if flag_nonspouse==1 ;
generate nhats_h_formal = opdhrsmth_i if flag_formal==1 ;

bysort round spid: egen SP_nhats_h_focal_ns = total(nhats_h_focal_ns) ;
bysort round spid: egen SP_nhats_h_nonfocal_ns = total(nhats_h_nonfocal_ns) ;
bysort round spid: egen SP_nhats_h_nonfocal_spouse = total(nhats_h_nonfocal_spouse) ;
bysort round spid: egen SP_nhats_h_nonfocal_formal = total(nhats_h_nonfocal_formal) ;

generate SP_morehours_spouse = 0 ; 
replace SP_morehours_spouse = 1 if SP_nhats_h_focal_ns >= SP_nhats_h_nonfocal_spouse ;

generate SP_morehours_formal = 0 ; 
replace SP_morehours_formal = 1 if SP_nhats_h_focal_ns >= SP_nhats_h_nonfocal_formal ;

/* FOCAL CAREGIVERS' AGE, GENDER, PROXIMITY, AND SUBJECTIVE HEALTH */

recode opdage (-1 -7 -8=.) (2 3 4 5 6=1) (7 8 9 10=2) (11 12 13 14 15 16=3), generate(cage) ;
tab2 cage round, col missing ;
generate cage_fc = cage if focal_nhats==1 ;
tab2 cage_fc round, col missing ;

generate cgender_fc = cgender if focal_nhats==1 ;
tab2 cgender_fc round, col missing ;

generate helpertype_fc = helpertype if focal_nhats==1 ;
tab2 helpertype_fc round, col missing ;

generate proximity_fc = proximity if focal_nhats==1 ;
tab2 proximity_fc round, col missing ;

generate health_fc = health if focal_nhats==1 ;
tab2 health_fc round, col missing ;

generate workstat_3cat_fc = workstat_3cat if focal_nhats==1 ;
tab2 workstat_3cat_fc round, col missing ;

generate workstat_2cat_fc = workstat_2cat if focal_nhats==1 ;
tab2 workstat_2cat_fc round, col missing ;

generate workhours_fc = workhours if focal_nhats==1 ;
tab2 workhours_fc round, col missing ;

/* FOCAL NONSPOUSAL CAREGIVERS' RELATIONSHIP TO SP, EMPLOYMENT STATUS, PROXIMITY TO SP, GENDER, AGE, AND SELF-REPORTED HEALTH
FOR THE STATISTICAL MODELS */

generate helpertype_fnsc = helpertype if ns_focal_nhats==1 ;
tab2 helpertype_fnsc round, col missing ;

generate workstat_3cat_fnsc = workstat_3cat if ns_focal_nhats==1 ;
tab2 workstat_3cat_fnsc round, col missing ;

generate workstat_2cat_fnsc = workstat_2cat if ns_focal_nhats==1 ;
tab2 workstat_2cat_fnsc round, col missing ;

generate proximity_fnsc = proximity if ns_focal_nhats==1 ;
tab2 proximity_fnsc round, col missing ;

generate cgender_fnsc = cgender if ns_focal_nhats==1 ;
tab2 cgender_fnsc round, col missing ;

generate cage_fnsc = cage if ns_focal_nhats==1 ;
tab2 cage_fnsc round, col missing ;

generate health_fnsc = health if ns_focal_nhats==1 ;
tab2 health_fnsc round, col missing ;

/* VARIABLES FOR TABLE 2 */

generate help_mobility = 1 if opouthlp==1 | opinsdhlp==1 | opbedhlp==1 ;
replace help_mobility = 0 if help_mobility==. ;

generate help_selfcare = 1 if opeathlp==1 | opbathhlp==1 | optoilhlp==1 | opdreshlp==1 ;
replace help_selfcare = 0 if help_selfcare==. ;

generate help_household = 1 if oplaunhlp==1 | opshophlp==1 | opmealhlp==1 | opbankhlp==1 | opmedshlp==1 ;
replace help_household = 0 if help_household==. ;

generate help_other = 1 if opmoneyhlp==1 | opdochlp==1 | opinsurhlp==1 | optkplhlp1==1 | optkplhlp2==1 ;
replace help_other = 0 if help_other==. ;

recode rank_ns_eligible_nhats (1=1) (2/100=0) ;
tab2 rank_ns_eligible_nhats round, col missing ;

save LONG, replace ;

/* CREATING CORESIDENT CHILD(REN) */

use LONG, clear ;

generate child_flag = 1 if oprelatnshp==3 | oprelatnshp==4 ;
replace child_flag = 0 if child_flag~=1 ;

tab2 child_flag round, col missing ;

generate coresidentchild_flag = 1 if (oprelatnshp==3 | oprelatnshp==4) & opprsninhh==1 ;
replace coresidentchild_flag = 0 if coresidentchild_flag~=1 ;

tab2 coresidentchild_flag round, col missing ;

collapse (sum) child_flag (sum) coresidentchild_flag, by(spid round) ;

tab2 child_flag round, col missing ;

tab2 coresidentchild_flag round, col missing ;

recode child_flag coresidentchild_flag (0=0) (1/100=1) ;

generate coresidentchild = 1 if child_flag==0 ;
replace coresidentchild = 2 if child_flag==1 & coresidentchild_flag==0 ;
replace coresidentchild = 3 if child_flag==1 & coresidentchild_flag==1 ;

tab2 coresidentchild round, col missing ;

save coresidentchild, replace ;

/* MERGING CORESIDENT CHILD(REN) */

use LONG, clear ;

merge m:1 spid round using coresidentchild, keepusing(coresidentchild) generate(_merge6) ;

save LONG_2, replace ;

/* creating wanfinwgt_cons and merging it with LONG_2 */

use LONG_2, clear ;

collapse wanfinwgt0, by(spid round) ;

keep spid round wanfinwgt0 ;

reshape wide w@anfinwgt0, i(spid) j(round) ;

egen wanfinwgt_cons = rowfirst(w1anfinwgt0 w5anfinwgt0) ; 

keep spid wanfinwgt_cons ;

save weight_cons, replace ;

use LONG_2, clear ;

merge m:1 spid using weight_cons, generate(_merge100) ;

save LONG_2b, replace ;

log close ;
