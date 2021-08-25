/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Calculates the percentage of sample persons with data from Round 1 only, Round 5 only, and both rounds.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log8", replace ;

/* xtdescribing data */

use LONG_2, clear ;

keep if sp_with_interviewed_ns==1 ;

keep if (runmet_adls==0 | runmet_adls==1) & (runmet_iadls==0 | runmet_iadls==1) ;

collapse 
(rawsum) 
opdhrsmth_i
, by(spid round) ;

duplicates report spid round ;

recode round (1=0) (5=1) ;

xtset spid round ;

xtdescribe ;

log close ;
