/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Reads in the sample-person-level data file from Round 5 "NHATS_Round_5_SP_File_V2" (available from the National Health and Aging Trends Study website https://nhats.org).

Generates the following sample-person-level variables:
	Measures of dementia status
	Measures of limitations with self-care and mobility activities
	Measures of unmet need with activities of daily living (ADLs) and instrumental activities of daily living (IADLs)
	Measures of socio-demographic characteristics (gender, racial ancestry, age, spouse has self-care needs, marital status, number of children, total income, medicaid coverage, residential care status)

Saves a revised sample-person-level data file from Round 5 containing the aforementioned measures.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log2", replace ;

/* WORKING ON THE NHATS SAMPLE PERSON DATA FILE */

use NHATS_Round_5_SP_File_V2, clear ;

/* GENERATING DEMENTIA STATUS VARIABLES (SEE NHATS TECHNICAL PAPER #5 AND ADDENDUM) */

#delimit cr ;

/* NOTE: The input file to run this code is the NHATS_Round_2_SP_File*/
/*SET MISSING (RESIDENTIAL CARE FQ ONLY) AND N.A. (NURSING HOME RESIDENTS, DECEASED)*/
gen r5demclas=-9 if r5dresid==7
replace r5demclas=-1 if r5dresid==6 |r5dresid==8
/*CODE PROBABLE IF DEMENTIA DIAGNOSIS REPORTED BY SELF OR PROXY*/
replace r5demclas=1 if (hc5disescn9==1 | hc5disescn9==7) & (is5resptype==1 | is5resptype==2)
tab r5demclas
/*CODE AD8_SCORE*/
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
/*ASSIGN VALUES TO AD8 ITEMS IF PROXY AND DEMENTIA CLASS NOT ALREADY ASSIGNED BY REPORTED DIAGNOSIS*/
foreach num of numlist 1/8 {
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
gen r5ad8_`num'=-1
replace r5ad8_`num'=. if is5resptype==2 & r5demclas==.
/*PROXY REPORTS A CHANGE OR ALZ/DEMENTIA*/
replace r5ad8_`num'=1 if is5resptype==2 & r5demclas==. & (cp5chgthink`num'==1 | cp5chgthink`num'==3)
/*PROXY REPORTS NO CHANGE*/
replace r5ad8_`num'=0 if is5resptype==2 & r5demclas==. & (cp5chgthink`num'==2) & r5ad8_`num'==.
}
foreach num of numlist 1/8 {
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
gen r5ad8miss_`num'=-1
replace r5ad8miss_`num'=0 if is5resptype==2 & r5demclas==. & (r5ad8_`num'==0 | r5ad8_`num'==1)
replace r5ad8miss_`num'=1 if is5resptype==2 & r5demclas==. & r5ad8_`num'==.
replace r5ad8_`num'=0 if is5resptype==2 & r5demclas==. & r5ad8_`num'==.
}
/*COUNT AD8 ITEMS*/
gen r5ad8_score=-1
replace r5ad8_score=(r5ad8_1+r5ad8_2+r5ad8_3+r5ad8_4+r5ad8_5+r5ad8_6+r5ad8_7+r5ad8_8) if is5resptype==2 & r5demclas==.
/*SET PREVIOUS ROUND DEMENTIA DIAGNOSIS BASED ON AD8 TO AD8_SCORE=8*/
replace r5ad8_score=8 if cp5dad8dem==1 & is5resptype==2 & r5demclas==.
/*COUNT MISSING AD8 ITEMS*/
gen r5ad8_miss= -1
replace r5ad8_miss=(r5ad8miss_1+r5ad8miss_2+r5ad8miss_3+r5ad8miss_4+r5ad8miss_5+r5ad8miss_6+r5ad8miss_7+r5ad8miss_8) if is5resptype==2 & r5demclas==.
/*CODE AD8 DEMENTIA CLASS*/
/*IF SCORE>=2 THEN MEETS AD8 CRITERIA*/
gen r5ad8_dem=1 if r5ad8_score>=2
/* IF SCORE IS 0 OR 1 OR ALL ITEMS MISSING THEN DOES NOT MEET AD8 CRITERION*/
replace r5ad8_dem=2 if (r5ad8_score==0 | r5ad8_score==1 | r5ad8_miss==8) & r5ad8_dem==.
/*UPDATE DEMENTIA CLASSIFICATION VARIABLE WITH AD8 CLASS*/
/*PROBABLE DEMENTIA BASED ON AD8 SCORE*/
replace r5demclas=1 if r5ad8_dem==1 & r5demclas==.
/*NO DIAGNOSIS, DOES NOT MEET AD8 CRITERION, AND PROXY SAYS CANNOT ASK SP COGNITIVE ITEMS*/
replace r5demclas=3 if r5ad8_dem==2 & cg5speaktosp==2 & r5demclas==.
tab r5demclas
/*CODE DATE ITEMS AND COUNT*/
/*USE THE FOLLOWING LOOP FOR ROUNDS 1-3, 5*/
foreach num of numlist 1/4 {
/*CODE ONLY YES/NO RESPONSES: MISSING/NA CODES -1, -9 LEFT MISSING*/
gen r5date_item`num'=cg5todaydat`num' if cg5todaydat`num'>0
/*2: NO/DK OR -7: REFUSED RECODED TO : NO/DK/RF*/
replace r5date_item`num'=0 if cg5todaydat`num'==2 | cg5todaydat`num'==-7
}
/*COUNT CORRECT DATE ITEMS*/
gen r5date_sum=r5date_item1 + r5date_item2 + r5date_item3 + r5date_item4 //USE THIS LINE FOR ROUNDS 1-3, 5
/*PROXY SAYS CAN'T SPEAK TO SP*/
replace r5date_sum=-2 if r5date_sum==. & cg5speaktosp==2
/*PROXY SAYS CAN SPEAK TO SP BUT SP UNABLE TO ANSWER*/
replace r5date_sum=-3 if (r5date_item1==. | r5date_item2==. | r5date_item3==. | r5date_item4==.) & cg5speaktosp==1
gen r5date_sumr=r5date_sum
/*MISSING IF PROXY SAYS CAN'T SPEAK TO SP*/
replace r5date_sumr=. if r5date_sum==-2
/*0 IF SP UNABLE TO ANSWER*/
replace r5date_sumr=0 if r5date_sum==-3
/*PRESIDENT AND VICE PRESIDENT NAME ITEMS AND COUNT*/
/* CODE ONLY YES/NO RESPONSES: MISSING/N.A. CODES -1,-9 LEFT MISSING */
/*2:NO/DK OR -7:REFUSED RECODED TO 0:NO/DK/RF*/
gen r5preslast=cg5presidna1 if cg5presidna1>0
replace r5preslast=0 if cg5presidna1==-7 | cg5presidna1==2
gen r5presfirst=cg5presidna3 if cg5presidna3>0
replace r5presfirst=0 if cg5presidna3==-7 | cg5presidna3==2
gen r5vplast=cg5vpname1 if cg5vpname1>0
replace r5vplast=0 if cg5vpname1==-7 | cg5vpname1==2
gen r5vpfirst=cg5vpname3 if cg5vpname3>0
replace r5vpfirst=0 if cg5vpname3==-7 | cg5vpname3==2
/*COUNT CORRECT PRESIDENT/VP NAME ITEMS*/
gen r5presvp= r5preslast+r5presfirst+r5vplast+r5vpfirst
/* PROXY SAYS CAN'T SPEAK TO SP */
replace r5presvp=-2 if r5presvp==. & cg5speaktosp==2
/* PROXY SAYS CAN SPEAK TO SP BUT SP UNABLE TO ANSWER */
replace r5presvp=-3 if r5presvp==. & cg5speaktosp==1 & (r5preslast==. | r5presfirst==. | r5vplast==. | r5vpfirst==.)
gen r5presvpr=r5presvp
/*MISSING IF PROXY SAYS CAN’T SPEAK TO SP*/
replace r5presvpr=. if r5presvp==-2
/*0 IF SP UNABLE TO ANSWER*/
replace r5presvpr=0 if r5presvp==-3
/*ORIENTATION DOMAIN: SUM OF DATE RECALL AND PRESIDENT/VP NAMING*/
gen r5date_prvp=r5date_sumr + r5presvpr
/*EXECUTIVE FUNCTION DOMAIN: CLOCK DRAWING SCORE*/
gen r5clock_scorer=cg5dclkdraw
replace r5clock_scorer=. if cg5dclkdraw==-2 | cg5dclkdraw==-9
replace r5clock_scorer=0 if cg5dclkdraw==-3 | cg5dclkdraw==-4 | cg5dclkdraw==-7
/*IMPUTE MEAN SCORE TO PERSONS MISSING A CLOCK*/
/*IF PROXY SAID CAN ASK SP*/
replace r5clock_scorer=2 if cg5dclkdraw==-9 & cg5speaktosp==1
/*IF SELF-RESPONDENT*/
replace r5clock_scorer=3 if cg5dclkdraw==-9 & cg5speaktosp==-1
/*MEMORY DOMAIN: IMMEDIATE AND DELAYED WORD RECALL*/
gen r5irecall=cg5dwrdimmrc
replace r5irecall=. if cg5dwrdimmrc==-2 | cg5dwrdimmrc==-1
replace r5irecall=0 if cg5dwrdimmrc==-7 | cg5dwrdimmrc==-3
gen r5drecall=cg5dwrddlyrc
replace r5drecall=. if cg5dwrddlyrc==-2 | cg5dwrddlyrc==-1
replace r5drecall=0 if cg5dwrddlyrc==-7 | cg5dwrddlyrc==-3
gen r5wordrecall0_20=r5irecall+r5drecall
/*CREATE COGNITIVE DOMAINS FOR ALL ELIGIBLE*/
gen r5clock65=0 if r5clock_scorer>1 & r5clock_scorer<=5
replace r5clock65=1 if r5clock_scorer>=0 & r5clock_scorer<=1
gen r5word65=0 if r5wordrecall0_20>3 & r5wordrecall0_20<=20
replace r5word65=1 if r5wordrecall0_20>=0 & r5wordrecall0_20<=3
gen r5datena65=0 if r5date_prvp>3 & r5date_prvp<=8
replace r5datena65=1 if r5date_prvp>=0 & r5date_prvp<=3
/*CREATE COGNITIVE DOMAIN SCORE*/
gen r5domain65 = r5clock65+r5word65+r5datena65
/*UPDATE COGNITIVE CLASSIFICATION*/
/*PROBABLE DEMENTIA*/
replace r5demclas=1 if r5demclas==. & (cg5speaktosp==1 | cg5speaktosp==-1) & (r5domain65==2 | r5domain65==3)
/*POSSIBLE DEMENTIA*/
replace r5demclas=2 if r5demclas==. & (cg5speaktosp==1 | cg5speaktosp==-1) & r5domain65==1
/*NO DEMENTIA*/
replace r5demclas=3 if r5demclas==. & (cg5speaktosp==1 | cg5speaktosp==-1) & r5domain65==0
/*Label variables and values*/
label variable r5ad8_dem "Dementia classification based on proxy AD8 report"
label define r5ad8_dem_values 1 "1 Meets dementia criteria" 2 "2 Does not meet dementia criteria"
label values r5ad8_dem r5ad8_dem_values
label variable r5demclas "r5 NHATS Dementia Diagnosis 65+"
label define dementialabel652 1 "1 Probable dementia" 2 "2 Possible dementia" 3 "3 No dementia" -1 "-1 Deceased or nursing home resident in R1 and r5" -9 "-9 Missing"
label values r5demclas dementialabel652
label define domain_labels2 0 "0 Does not meet criteria" 1 "1 Meets criteria"
label values r5clock65 r5word65 r5datena65 domain_labels2
label define domain65_label2 0 "0 Not impaired" 1 "Impaired in 1 domain" 2 "Impaired in 2 domains" 3 "Impaired in 3 domains"
label values r5domain65 domain65_labels2
tab r5demclas

#delimit ;

/*TABULATING DEMENTIA STATUS VARIABLE (r5demclas)*/

tabulate r5demclas ;

/* MEASURES OF LIMITATIONS WITH SELF-CARE AND MOBILITY ACTIVITIES */

/*  

LIMITATION IF (LESS EXPANSIVE CRITERIA):
1. did not perform the activity in the last month
2. had difficulty
3. received help

4. did not have difficulty or received help

LIMITATION IF (MORE EXPANSIVE CRITERIA):
1. performed the activity less frequently compared to a year ago or did not perform the activity in the last month
2. used equipment
3. had difficulty
4. got help

IADL LIMITATION IF:

1. "#1 ALWAYS DID IT BY SELF" AND "A LITTLE," "SOME," OR "A LOT" OF DIFFICULTY.
2. "#2 ALWAYS DID IT TOGETHER WITH SOMEONE ELSE" AND "HEALTH OR FUNCTIONING"
3. "#3 SOMEONE ELSE ALWAYS DID IT" AND "HEALTH OR FUNCTIONING"
4. "#4 IT VARIED" AND ("HEALTH OR FUNCTIONING" OR "A LITTLE," "SOME," OR "A LOT" OF DIFFICULTY)
5. "#5 NOT DONE IN LAST MONTH" AND "HEALTH OR FUNCTIONING"

*/

/* laundry */

generate limit_laundry = 1 if ha5laun==1 & (ha5laundif==2 | ha5laundif==3 | ha5laundif==4) ;
replace limit_laundry = 1 if ha5laun==2 & ha5dlaunreas==1 ;
replace limit_laundry = 1 if ha5laun==3 & ha5dlaunreas==1 ;
replace limit_laundry = 1 if ha5laun==4 & (ha5dlaunreas==1 | ha5laundif==2 | ha5laundif==3 | ha5laundif==4) ;
replace limit_laundry = 1 if ha5laun==5 & ha5dlaunreas==1 ;
replace limit_laundry = 1 if (ha5laun==-7 | ha5laun==-8) & (ha5laundif==2 | ha5laundif==3 | ha5laundif==4) ;

replace limit_laundry = 0 if ha5laun==1 & ha5laundif~=2 & ha5laundif~=3 & ha5laundif~=4 ;
replace limit_laundry = 0 if ha5laun==2 & ha5dlaunreas~=1 ;
replace limit_laundry = 0 if ha5laun==3 & ha5dlaunreas~=1 ;
replace limit_laundry = 0 if ha5laun==4 & ha5dlaunreas~=1 & ha5laundif~=2 & ha5laundif~=3 & ha5laundif~=4 ;
replace limit_laundry = 0 if ha5laun==5 & ha5dlaunreas~=1 ;
replace limit_laundry = 0 if (ha5laun==-7 | ha5laun==-8) & ha5laundif~=2 & ha5laundif~=3 & ha5laundif~=4 ;

codebook limit_laundry ;

/* shopping */

generate limit_shopping = 1 if ha5shop==1 & (ha5shopdif==2 | ha5shopdif==3 | ha5shopdif==4) ;
replace limit_shopping = 1 if ha5shop==2 & ha5dshopreas==1 ;
replace limit_shopping = 1 if ha5shop==3 & ha5dshopreas==1 ;
replace limit_shopping = 1 if ha5shop==4 & (ha5dshopreas==1 | ha5shopdif==2 | ha5shopdif==3 | ha5shopdif==4) ;
replace limit_shopping = 1 if ha5shop==5 & ha5dshopreas==1 ;
replace limit_shopping = 1 if (ha5shop==-7 | ha5shop==-8) & (ha5shopdif==2 | ha5shopdif==3 | ha5shopdif==4) ;

replace limit_shopping = 0 if ha5shop==1 & ha5shopdif~=2 & ha5shopdif~=3 & ha5shopdif~=4 ;
replace limit_shopping = 0 if ha5shop==2 & ha5dshopreas~=1 ;
replace limit_shopping = 0 if ha5shop==3 & ha5dshopreas~=1 ;
replace limit_shopping = 0 if ha5shop==4 & ha5dshopreas~=1 & ha5shopdif~=2 & ha5shopdif~=3 & ha5shopdif~=4 ;
replace limit_shopping = 0 if ha5shop==5 & ha5dshopreas~=1 ;
replace limit_shopping = 0 if (ha5shop==-7 | ha5shop==-8) & ha5shopdif~=2 & ha5shopdif~=3 & ha5shopdif~=4 ;

codebook limit_shopping ;

/* hot meals */

generate limit_hotmeals = 1 if ha5meal==1 & (ha5mealdif==2 | ha5mealdif==3 | ha5mealdif==4) ;
replace limit_hotmeals = 1 if ha5meal==2 & ha5dmealreas==1 ;
replace limit_hotmeals = 1 if ha5meal==3 & ha5dmealreas==1 ;
replace limit_hotmeals = 1 if ha5meal==4 & (ha5dmealreas==1 | ha5mealdif==2 | ha5mealdif==3 | ha5mealdif==4) ;
replace limit_hotmeals = 1 if ha5meal==5 & ha5dmealreas==1 ;
replace limit_hotmeals = 1 if (ha5meal==-7 | ha5meal==-8) & (ha5mealdif==2 | ha5mealdif==3 | ha5mealdif==4) ;

replace limit_hotmeals = 0 if ha5meal==1 & ha5mealdif~=2 & ha5mealdif~=3 & ha5mealdif~=4 ;
replace limit_hotmeals = 0 if ha5meal==2 & ha5dmealreas~=1 ;
replace limit_hotmeals = 0 if ha5meal==3 & ha5dmealreas~=1 ;
replace limit_hotmeals = 0 if ha5meal==4 & ha5dmealreas~=1 & ha5mealdif~=2 & ha5mealdif~=3 & ha5mealdif~=4 ;
replace limit_hotmeals = 0 if ha5meal==5 & ha5dmealreas~=1 ;
replace limit_hotmeals = 0 if (ha5meal==-7 | ha5meal==-8) & ha5mealdif~=2 & ha5mealdif~=3 & ha5mealdif~=4 ;

codebook limit_hotmeals ;

/* banking */

generate limit_banking = 1 if ha5bank==1 & (ha5bankdif==2 | ha5bankdif==3 | ha5bankdif==4) ;
replace limit_banking = 1 if ha5bank==2 & ha5dbankreas==1 ;
replace limit_banking = 1 if ha5bank==3 & ha5dbankreas==1 ;
replace limit_banking = 1 if ha5bank==4 & (ha5dbankreas==1 | ha5bankdif==2 | ha5bankdif==3 | ha5bankdif==4) ;
replace limit_banking = 1 if ha5bank==5 & ha5dbankreas==1 ;
replace limit_banking = 1 if (ha5bank==-7 | ha5bank==-8) & (ha5bankdif==2 | ha5bankdif==3 | ha5bankdif==4) ;

replace limit_banking = 0 if ha5bank==1 & ha5bankdif~=2 & ha5bankdif~=3 & ha5bankdif~=4 ;
replace limit_banking = 0 if ha5bank==2 & ha5dbankreas~=1 ;
replace limit_banking = 0 if ha5bank==3 & ha5dbankreas~=1 ;
replace limit_banking = 0 if ha5bank==4 & ha5dbankreas~=1 & ha5bankdif~=2 & ha5bankdif~=3 & ha5bankdif~=4 ;
replace limit_banking = 0 if ha5bank==5 & ha5dbankreas~=1 ;
replace limit_banking = 0 if (ha5bank==-7 | ha5bank==-8) & ha5bankdif~=2 & ha5bankdif~=3 & ha5bankdif~=4 ;

codebook limit_banking ;

/* medication */

generate limit_meds = 1 if mc5medstrk==1 & (mc5medsdif==2 | mc5medsdif==3 | mc5medsdif==4) ;
replace limit_meds = 1 if mc5medstrk==2 & mc5dmedsreas==1 ;
replace limit_meds = 1 if mc5medstrk==3 & mc5dmedsreas==1 ;
replace limit_meds = 1 if mc5medstrk==4 & (mc5dmedsreas==1 | mc5medsdif==2 | mc5medsdif==3 | mc5medsdif==4) ;
replace limit_meds = 1 if mc5medstrk==5 & mc5dmedsreas==1 ;
replace limit_meds = 1 if (mc5medstrk==-7 | mc5medstrk==-8) & (mc5medsdif==2 | mc5medsdif==3 | mc5medsdif==4) ;

replace limit_meds = 0 if mc5meds==2 | mc5meds==-7 | mc5meds==-8 ;
replace limit_meds = 0 if mc5medstrk==1 & mc5medsdif~=2 & mc5medsdif~=3 & mc5medsdif~=4 ;
replace limit_meds = 0 if mc5medstrk==2 & mc5dmedsreas~=1 ;
replace limit_meds = 0 if mc5medstrk==3 & mc5dmedsreas~=1 ;
replace limit_meds = 0 if mc5medstrk==4 & mc5dmedsreas~=1 & mc5medsdif~=2 & mc5medsdif~=3 & mc5medsdif~=4 ;
replace limit_meds = 0 if mc5medstrk==5 & mc5dmedsreas~=1 ;
replace limit_meds = 0 if (mc5medstrk==-7 | mc5medstrk==-8) & mc5medsdif~=2 & mc5medsdif~=3 & mc5medsdif~=4 ;

codebook limit_meds ;

/* getting around outside */

generate limit_outside = 1 if mo5outoft==5 ; /* 1 */
replace limit_outside = 1 if mo5outdif==2 | mo5outdif==3 | mo5outdif==4 ; /* 2 */
replace limit_outside = 1 if mo5outhlp==1 ; /* 3 */
replace limit_outside = 0 if mo5outdif==1 & mo5outhlp==2 ; /* 4 */

codebook limit_outside ;

/* getting around inside */

generate limit_inside = 1 if mo5oflvslepr==5 ; /* 1 */
replace limit_inside = 1 if mo5insddif==2 | mo5insddif==3 | mo5insddif==4 ; /* 2 */
replace limit_inside = 1 if mo5insdhlp==1 ; /* 3 */
replace limit_inside = 0 if mo5insddif==1 & mo5insdhlp==2 ; /* 4 */

codebook limit_inside ;

/* getting out of bed */

generate limit_bed = 1 if mo5beddif==2 | mo5beddif==3 | mo5beddif==4 ; /* 2 */
replace limit_bed = 1 if mo5bedhlp==1 ; /* 3 */
replace limit_bed = 0 if mo5beddif==1 & mo5bedhlp==2 ; /* 4 */

codebook limit_bed ;

/* eating */

generate limit_eating = 1 if sc5eatdev==7 ; /* 1 */
replace limit_eating = 1 if sc5eatslfdif==2 | sc5eatslfdif==3 | sc5eatslfdif==4 ; /* 2 */
replace limit_eating = 1 if sc5eathlp==1 ; /* 3 */
replace limit_eating = 0 if sc5eatslfdif==1 & sc5eathlp==2 ; /* 4 */

codebook limit_eating ;

/* bathing */

generate limit_bathing = 1 if sc5bathdif==2 | sc5bathdif==3 | sc5bathdif==4 ; /* 2 */
replace limit_bathing = 1 if sc5bathhlp==1 ; /* 3 */
replace limit_bathing = 0 if sc5bathdif==1 & sc5bathhlp==2 ; /* 4 */

codebook limit_bathing ;

/* toileting */

generate limit_toileting = 1 if sc5toildif==2 | sc5toildif==3 | sc5toildif==4 ; /* 2 */
replace limit_toileting = 1 if sc5toilhlp==1 ; /* 3 */
replace limit_toileting = 0 if sc5toildif==1 & sc5toilhlp==2 ; /* 4 */

codebook limit_toileting ;

/* dressing */

generate limit_dressing = 1 if sc5dresoft==5 ; /* 1 */
replace limit_dressing = 1 if sc5dresdif==2 | sc5dresdif==3 | sc5dresdif==4 ; /* 2 */
replace limit_dressing = 1 if sc5dreshlp==1 ; /* 3 */
replace limit_dressing = 0 if sc5dresdif==1 & sc5dreshlp==2 ; /* 4 */

codebook limit_dressing ;

generate r5number_iadls = limit_laundry + limit_shopping + limit_hotmeals + limit_banking + limit_meds ;

tabulate r5number_iadls, missing ;

generate r5number_adls = limit_outside + limit_inside + limit_bed + limit_eating + limit_bathing + limit_toileting + limit_dressing ;

tabulate r5number_adls, missing ;

/* UNMET NEED */

generate r5unmet_adls = 1 if sc5eatwout==1 | sc5bathwout==1 | sc5toilwout==1 | sc5dreswout==1 | mo5outwout==1 | mo5insdwout==1 | mo5bedwout==1 ;
replace r5unmet_adls = 0 if r5unmet_adls ~= 1 ;

tabulate r5unmet_adls, missing ;

generate r5unmet_iadls = 1 if ha5launwout==1 | ha5shopwout==1 | ha5mealwout==1 | ha5bankwout==1 | mc5medsmis==1 ;
replace r5unmet_iadls = 0 if r5unmet_iadls ~= 1 ;

tabulate r5unmet_iadls, missing ;

generate r5unmet_any = 1 if r5unmet_adls==1 | r5unmet_iadls==1 ;
replace r5unmet_any = 0 if r5unmet_adls==0 & r5unmet_iadls==0 ;

tabulate r5unmet_any, missing ;

/* GENDER */

recode r5dgender (1=0) (2=1), generate(r5female) ;

codebook r5female ;

/* RACIAL ANCESTRY */

recode rl5dracehisp (5 6=.), generate(rl5race) ;

codebook rl5race ;

/* AGE */

recode r5d2intvrage (1 2=1) (3 4=2) (5 6=3) (-1=.), generate(r5age) ;

codebook r5age ;

/* SPOUSE NEEDS HELP WITH PERSONAL CARE */

recode hh5spoupchlp (1=1) (2=0) (-1 -7 -8 -9=.), generate(hh5specdisabled) ;

tabulate hh5specdisabled, missing ;

/* IS MARRIED AND HAS MORE THAN ONE CHILD */

recode hh5dmarstat (-8 -7 -1=.) (1 2=1) (3 4=2) (5=3) (6=4), generate(hh5marital) ;

codebook hh5marital ;

recode hh5dmarstat (-8 -7 -1=.) (1 2=1) (3 4 5 6=0), generate(hh5married) ;

codebook hh5married ;

recode cs5dnumchild (-1 0=0) (1=1) (2=2) (3/100=3), generate(r5numchild) ;

codebook r5numchild ;

recode cs5dnumchild (-1 0/1=0) (2/100=1), generate(r5has2child) ;

codebook r5has2child ;

/* TOTAL INCOME */

recode ia5totinc (-9 -8 -7 -1=.), generate(ia5totinc_r) ;

recode ia5toincim1 ia5toincim2 ia5toincim3 ia5toincim4 ia5toincim5 (-9 -1=.) ;

replace ia5toincim1 = ia5totinc_r if ia5toincimf==0 | ia5toincim1==. ;
replace ia5toincim2 = ia5totinc_r if ia5toincimf==0 | ia5toincim2==. ;
replace ia5toincim3 = ia5totinc_r if ia5toincimf==0 | ia5toincim3==. ;
replace ia5toincim4 = ia5totinc_r if ia5toincimf==0 | ia5toincim4==. ;
replace ia5toincim5 = ia5totinc_r if ia5toincimf==0 | ia5toincim5==. ;

/* MEDICAID */

recode ip5cmedicaid (1=1) (2 -1=0) (-9 -8 -7=.), generate(ip5medicaid) ;

codebook ip5medicaid ;

/* RESIDENTIAL CARE STATUS */

recode r5dresid (1=0) (2=1) (3 4=.) ;

codebook r5dresid ;

save SP_ROUND5, replace ;

log close ;
