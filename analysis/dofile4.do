/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Performs the following merges with the other-person-level data file (which includes caregivers/helpers) from Round 5 ("NHATS_Round_5_OP_File_V2"):
	One-to-one merge with the data file containing imputed caregiving hours from Round 5 ("Round_5_hours") using the composite primary key spid, opid.
	Many-to-one merge with the revised sample-person-level data file from Round 5 ("SP_ROUND5") using the key spid.
	One-to-one merge with the National Study of Caregiving other-person-level tracker file from Round 5 ("NSOC_Round_5_OP_Tracker_File_V2") using the composite primary key spid, opid.
	One-to-one merge with the National Study of Caregiving main data file from Round 5 ("NSOC_Round_5_File_V2") using the composite primary key spid, opid.

Saves a revised other-person-level data file from Round 5 ("ROUND5")

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log4", replace ;

use NHATS_Round_5_OP_File_V2, clear ;

keep
spid opid 
op5paidhelpr 
op5relatnshp
op5dhrsmth 
op5dage 
op5outhlp op5insdhlp op5bedhlp 
op5eathlp op5bathhlp op5toilhlp op5dreshlp 
op5launhlp op5shophlp op5mealhlp op5bankhlp op5medshlp 
op5moneyhlp op5dochlp op5insurhlp op5tkplhlp1 op5tkplhlp2 
op5prsninhh
;

merge 1:1 spid opid using Round_5_hours ;

merge m:1 spid using SP_ROUND5, 
keepusing(r5demclas r5number_iadls r5number_adls r5unmet_adls r5unmet_iadls r5unmet_any hh5specdisabled 
hh5marital hh5married r5numchild r5has2child ip5medicaid r5female rl5race r5age r5dresid 
ia5toincim1 ia5toincim2 ia5toincim3 ia5toincim4 ia5toincim5 
w5anfinwgt0 w5varunit w5varstrat ia5toincimf ia5totinc ia5toincesjt ia5toincessg) 
generate(_merge30) ;

merge 1:1 spid opid using NSOC_Round_5_OP_Tracker_File_V2, generate(_merge3) ;

merge 1:1 spid opid using NSOC_Round_5_File_V2, 
keepusing(cdc5hlpdyswk cdc5hlphrsdy cdc5hlphrmvf cdc5hlpsched cdc5hlpdysmt cdc5hlphrlmt c5dgender cca5tm2spmin cca5tm2spunt cca5tm2sphrs che5health
cec5hrsweek cec5wrkmulti cec5hrslstwk cec5misswork cec5hrswork cec5flexhrs cec5wrksched cec5wrk4pay 
chd5martstat chd5chldlvng chd5numchild chd5numchu18 w5cgfinwgt0) 
generate(_merge4) ;

tabulate op5dnsoc, missing ;

tab1 op5relatnshp, missing ;

save ROUND5, replace ;

log close ;
