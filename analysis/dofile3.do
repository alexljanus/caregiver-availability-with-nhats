/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Performs the following merges with the other-person-level data file (which includes caregivers/helpers) from Round 1 ("NHATS_Round_1_OP_File_v2"):
	One-to-one merge with the data file containing imputed caregiving hours from Round 1 ("Round_1_hours") using the composite primary key spid, opid.
	Many-to-one merge with the revised sample-person-level data file from Round 1 ("SP_ROUND1") using the key spid.
	One-to-one merge with the National Study of Caregiving other-person-level tracker file from Round 1 ("NSOC_Round_1_OP_Tracker_File") using the composite primary key spid, opid.
	One-to-one merge with the National Study of Caregiving main data file from Round 1 ("NSOC_Round_1_File_v2") using the composite primary key spid, opid.

Saves a revised other-person-level data file from Round 1 ("ROUND1")

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log3", replace ;

use NHATS_Round_1_OP_File_v2, clear ;

keep
spid opid 
op1paidhelpr 
op1relatnshp 
op1dhrsmth  
op1dage  
op1outhlp op1insdhlp op1bedhlp  
op1eathlp op1bathhlp op1toilhlp op1dreshlp  
op1launhlp op1shophlp op1mealhlp op1bankhlp op1medshlp  
op1moneyhlp op1dochlp op1insurhlp op1tkplhlp1 op1tkplhlp2  
op1prsninhh
;

merge 1:1 spid opid using Round_1_hours ;

merge m:1 spid using SP_ROUND1, 
keepusing(r1demclas r1number_iadls r1number_adls r1unmet_adls r1unmet_iadls r1unmet_any hh1specdisabled 
hh1marital hh1married r1numchild r1has2child ip1medicaid r1female rl1race r1age r1dresid 
ia1toincim1 ia1toincim2 ia1toincim3 ia1toincim4 ia1toincim5 
w1anfinwgt0 w1varunit w1varstrat ia1toincimf ia1totinc ia1toincesjt ia1toincessg) 
generate(_merge10) ;

merge 1:1 spid opid using NSOC_Round_1_OP_Tracker_File, generate(_merge1) ;

merge 1:1 spid opid using NSOC_Round_1_File_v2, 
keepusing(cdc1hlpdyswk cdc1hlphrsdy cdc1hlphrmvf cdc1hlpsched cdc1hlpdysmt cdc1hlphrlmt c1dgender cca1tm2spmin cca1tm2spunt cca1tm2sphrs che1health
cec1hrsweek cec1wrkmulti cec1hrslstwk cec1misswork cec1hrswork cec1flexhrs cec1wrksched cec1wrk4pay 
chd1martstat chd1chldlvng chd1numchild chd1numchu18 w1cgfinwgt0) 
generate(_merge2) ; 

tabulate op1dnsoc, missing ;

tab1 op1relatnshp, missing ;

save ROUND1, replace ;

log close ;
