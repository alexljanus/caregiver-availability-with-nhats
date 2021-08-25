/*****OVERVIEW OF ANALYTICAL STEPS*****
***************************************
***************************************

Reads in the sample-person-level data file from Round 1 "NHATS_Round_1_SP_File" (available from the National Health and Aging Trends Study website https://nhats.org).

Generates the following sample-person-level variables:
	Measures of dementia status
	Measures of limitations with self-care and mobility activities
	Measures of unmet need with activities of daily living (ADLs) and instrumental activities of daily living (IADLs)
	Measures of socio-demographic characteristics (gender, racial ancestry, age, spouse has self-care needs, marital status, number of children, total income, medicaid coverage, residential care 	 status)

Saves a revised sample-person-level data file from Round 1 containing the aforementioned measures.

**************************************
**************************************/

#delimit ;

cd "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\DATA" ;

log using "C:\Users\Alex\Desktop\Research\NHATS project\NHATS\LOGS\log1", replace ;

/* WORKING ON THE NHATS SAMPLE PERSON DATA FILE */

use NHATS_Round_1_SP_File, clear ;

/* GENERATING DEMENTIA STATUS VARIABLES (SEE NHATS TECHNICAL PAPER #5 AND ADDENDUM) */

/*NOTE: The input file to run this code is the NHATS_Round_1_File*/
/*CREATE DEMENTIA CLASSIFICATION VARIABLE*/
/*SET MISSING (RESIDENTIAL CARE FQ ONLY) AND N.A. (NURSING HOME RESIDENTS)*/
gen r1demclas=-9 if r1dresid==3 ;
replace r1demclas=-1 if r1dresid==4 ;
/*CODE PROBABLE IF DEMENTIA DIAGNOSIS REPORTED BY SELF OR PROXY*/
replace r1demclas=1 if hc1disescn9==1 & (is1resptype==1 | is1resptype==2) ;
/*CODE AD8_SCORE*/
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
/*ASSIGN VALUES TO AD8 ITEMS IF PROXY AND DEMENTIA CLASS NOT ALREADY ASSIGNED BY REPORTED DIAGNOSIS*/
foreach num of numlist 1/8 { ;
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
gen ad8_`num'=-1 ;
replace ad8_`num'=. if is1resptype==2 & r1demclas==. ;
/*PROXY REPORTS A CHANGE OR ALZ/DEMENTIA*/
replace ad8_`num'=1 if is1resptype==2 & r1demclas==. & (cp1chgthink`num'==1 | cp1chgthink`num'==3) ;
/*PROXY REPORTS NO CHANGE*/
replace ad8_`num'=0 if is1resptype==2 & r1demclas==. & (cp1chgthink`num'==2) & ad8_`num'==. ;
} ;
foreach num of numlist 1/8 { ;
/*INITIALIZE COUNTS TO NOT APPLICABLE*/
gen ad8miss_`num'=-1 ;
replace ad8miss_`num'=0 if is1resptype==2 & r1demclas==. & (ad8_`num'==0 | ad8_`num'==1) ;
replace ad8miss_`num'=1 if is1resptype==2 & r1demclas==. & ad8_`num'==. ;
replace ad8_`num'=0 if is1resptype==2 & r1demclas==. & ad8_`num'==. ;
} ;
/*COUNT AD8 ITEMS*/
gen ad8_score=-1 ;
replace ad8_score=(ad8_1+ad8_2+ad8_3+ad8_4+ad8_5+ad8_6+ad8_7+ad8_8) if is1resptype==2 & r1demclas==. ;
/*COUNT MISSING AD8 ITEMS*/
gen ad8_miss= -1 ;
replace ad8_miss=(ad8miss_1+ad8miss_2+ad8miss_3+ad8miss_4+ad8miss_5+ad8miss_6+ad8miss_7+ad8miss_8) if is1resptype==2 & r1demclas==. ;
/*CODE AD8 DEMENTIA CLASS*/
/*IF SCORE>=2 THEN MEETS AD8 CRITERIA*/
gen ad8_dem=1 if ad8_score>=2 ;
/*IF SCORE IS 0 OR 1 THEN DOES NOT MEET AD8 CRITERIA*/
replace ad8_dem=2 if ad8_score==0 | ad8_score==1 ;
/*UPDATE DEMENTIA CLASSIFICATION VARIABLE WITH AD8 CLASS*/
/*PROBABLE DEMENTIA BASED ON AD8 SCORE*/
replace r1demclas=1 if ad8_dem==1 & r1demclas==. ;
/*NO DIAGNOSIS, DOES NOT MEET AD8 CRITERION, AND PROXY SAYS CANNOT ASK SP COGNITIVE ITEMS*/
replace r1demclas=3 if ad8_dem==2 & cg1speaktosp==2 & r1demclas==. ;
/*CODE DATE ITEMS AND COUNT*/
foreach num of numlist 1/4 { ;
/*CODE ONLY YES/NO RESPONSES: MISSING/NA CODES -1, -9 LEFT MISSING*/
gen date_item`num'=cg1todaydat`num' if cg1todaydat`num'>0 ;
/*2: NO/DK OR -7: REFUSED RECODED TO : NO/DK/RF*/
replace date_item`num'=0 if cg1todaydat`num'==2 | cg1todaydat`num'==-7 ;
} ;
/*COUNT CORRECT DATE ITEMS*/
gen date_sum=date_item1 + date_item2 + date_item3 + date_item4 ;
/*PROXY SAYS CAN'T SPEAK TO SP*/
replace date_sum=-2 if date_sum==. & cg1speaktosp==2 ;
/*PROXY SAYS CAN SPEAK TO SP BUT SP UNABLE TO ANSWER*/
replace date_sum=-3 if (date_item1==. | date_item2==. | date_item3==. | date_item4==.) & cg1speaktosp==1 ;
gen date_sumr=date_sum ;
/*MISSING IF PROXY SAYS CAN'T SPEAK TO SP*/
replace date_sumr=. if date_sum==-2 ;
/*0 IF SP UNABLE TO ANSWER*/
replace date_sumr=0 if date_sum==-3 ;
/*PRESIDENT AND VICE PRESIDENT NAME ITEMS AND COUNT*/
/* CODE ONLY YES/NO RESPONSES: MISSING/N.A. CODES -1,-9 LEFT MISSING*/
/*2:NO/DK OR -7:REFUSED RECODED TO 0:NO/DK/RF*/
gen preslast=cg1presidna1 if cg1presidna1>0 ;
replace preslast=0 if cg1presidna1==-7 | cg1presidna1==2 ;
gen presfirst=cg1presidna3 if cg1presidna3>0 ;
replace presfirst=0 if cg1presidna3==-7 | cg1presidna3==2 ;
gen vplast=cg1vpname1 if cg1vpname1>0 ;
replace vplast=0 if cg1vpname1==-7 | cg1vpname1==2 ;
gen vpfirst=cg1vpname3 if cg1vpname3>0 ;
replace vpfirst=0 if cg1vpname3==-7 | cg1vpname3==2 ;
/*COUNT CORRECT PRESIDENT/VP NAME ITEMS*/
gen presvp= preslast+presfirst+vplast+vpfirst ;
/* PROXY SAYS CAN'T SPEAK TO SP */
replace presvp=-2 if presvp==. & cg1speaktosp==2 ;
/* PROXY SAYS CAN SPEAK TO SP BUT SP UNABLE TO ANSWER */
replace presvp=-3 if presvp==. & cg1speaktosp==1 & (preslast==. | presfirst==. | vplast==. | vpfirst==.) ;
gen presvpr=presvp ;
/*MISSING IF PROXY SAYS CAN’T SPEAK TO SP*/
replace presvpr=. if presvp==-2 ;
/*0 IF SP UNABLE TO ANSWER*/
replace presvpr=0 if presvp==-3 ;
/*ORIENTATION DOMAIN: SUM OF DATE RECALL AND PRESIDENT/VP NAMING*/
gen date_prvp=date_sumr + presvpr ;
/*EXECUTIVE FUNCTION DOMAIN: CLOCK DRAWING SCORE*/
gen clock_scorer=cg1dclkdraw ;
replace clock_scorer=. if cg1dclkdraw==-2 | cg1dclkdraw==-9 ;
replace clock_scorer=0 if cg1dclkdraw==-3 | cg1dclkdraw==-4 | cg1dclkdraw==-7 ;
/*IMPUTE MEAN SCORE TO PERSONS MISSING A CLOCK*/
/*IF PROXY SAID CAN ASK SP*/
replace clock_scorer=2 if cg1dclkdraw==-9 & cg1speaktosp==1 ;
/*IF SELF-RESPONDENT*/
replace clock_scorer=3 if cg1dclkdraw==-9 & cg1speaktosp==-1 ;
/*MEMORY DOMAIN: IMMEDIATE AND DELAYED WORD RECALL*/
gen irecall=cg1dwrdimmrc ;
replace irecall=. if cg1dwrdimmrc==-2 | cg1dwrdimmrc==-1 ;
replace irecall=0 if cg1dwrdimmrc==-7 | cg1dwrdimmrc==-3 ;
gen drecall=cg1dwrddlyrc ;
replace drecall=. if cg1dwrddlyrc==-2 | cg1dwrddlyrc==-1 ;
replace drecall=0 if cg1dwrddlyrc==-7 | cg1dwrddlyrc==-3 ;
gen wordrecall0_20=irecall+drecall ;
/*CREATE COGNITIVE DOMAINS FOR ALL ELIGIBLE*/
gen clock65=0 if clock_scorer>1 & clock_scorer<=5 ;
replace clock65=1 if clock_scorer>=0 & clock_scorer<=1 ;
gen word65=0 if wordrecall0_20>3 & wordrecall0_20<=20 ;
replace word65=1 if wordrecall0_20>=0 & wordrecall0_20<=3 ;
gen datena65=0 if date_prvp>3 & date_prvp<=8 ;
replace datena65=1 if date_prvp>=0 & date_prvp<=3 ;
/*CREATE COGNITIVE DOMAIN SCORE*/
gen domain65 = clock65+word65+datena65 ;
/*UPDATE COGNITIVE CLASSIFICATION*/
/*PROBABLE DEMENTIA*/
replace r1demclas=1 if r1demclas==. & (cg1speaktosp==1 | cg1speaktosp==-1) & (domain65==2 | domain65==3) ;
/*POSSIBLE DEMENTIA*/
replace r1demclas=2 if r1demclas==. & (cg1speaktosp==1 | cg1speaktosp==-1) & domain65==1 ;
/*NO DEMENTIA*/
replace r1demclas=3 if r1demclas==. & (cg1speaktosp==1 | cg1speaktosp==-1) & domain65==0 ;
/*Label variables and values*/
label variable ad8_dem "Dementia classification based on proxy AD8 report" ;
label define ad8_dem_values 1 "1 Meets dementia criteria" 2 "2 Does not meet dementia criteria" ;
label values ad8_dem ad8_dem_values ;
label variable r1demclas "NHATS Dementia Diagnosis 65+" ;
label define dementialabel65 1 "1 Probable dementia" 2 "2 Possible dementia" 3 "3 No dementia" -1 "-1 Nursing home resident" -9 "-9 Missing" ;
label values r1demclas dementialabel65 ;
label define domain_labels 0 "0 Does not meet criteria" 1 "1 Meets criteria" ;
label values clock65 word65 datena65 domain_labels ;
label define domain65_label 0 "0 Not impaired" 1 "Impaired in 1 domain" 2 "Impaired in 2 domains" 3 "Impaired in 3 domains" ;
label values domain65 domain65_labels ;

/*TABULATING DEMENTIA STATUS VARIABLE (r1demclas)*/

tabulate r1demclas ;

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

generate limit_laundry = 1 if ha1laun==1 & (ha1laundif==2 | ha1laundif==3 | ha1laundif==4) ;
replace limit_laundry = 1 if ha1laun==2 & ha1dlaunreas==1 ;
replace limit_laundry = 1 if ha1laun==3 & ha1dlaunreas==1 ;
replace limit_laundry = 1 if ha1laun==4 & (ha1dlaunreas==1 | ha1laundif==2 | ha1laundif==3 | ha1laundif==4) ;
replace limit_laundry = 1 if ha1laun==5 & ha1dlaunreas==1 ;
replace limit_laundry = 1 if (ha1laun==-7 | ha1laun==-8) & (ha1laundif==2 | ha1laundif==3 | ha1laundif==4) ;

replace limit_laundry = 0 if ha1laun==1 & ha1laundif~=2 & ha1laundif~=3 & ha1laundif~=4 ;
replace limit_laundry = 0 if ha1laun==2 & ha1dlaunreas~=1 ;
replace limit_laundry = 0 if ha1laun==3 & ha1dlaunreas~=1 ;
replace limit_laundry = 0 if ha1laun==4 & ha1dlaunreas~=1 & ha1laundif~=2 & ha1laundif~=3 & ha1laundif~=4 ;
replace limit_laundry = 0 if ha1laun==5 & ha1dlaunreas~=1 ;
replace limit_laundry = 0 if (ha1laun==-7 | ha1laun==-8) & ha1laundif~=2 & ha1laundif~=3 & ha1laundif~=4 ;

codebook limit_laundry ;

/* shopping */

generate limit_shopping = 1 if ha1shop==1 & (ha1shopdif==2 | ha1shopdif==3 | ha1shopdif==4) ;
replace limit_shopping = 1 if ha1shop==2 & ha1dshopreas==1 ;
replace limit_shopping = 1 if ha1shop==3 & ha1dshopreas==1 ;
replace limit_shopping = 1 if ha1shop==4 & (ha1dshopreas==1 | ha1shopdif==2 | ha1shopdif==3 | ha1shopdif==4) ;
replace limit_shopping = 1 if ha1shop==5 & ha1dshopreas==1 ;
replace limit_shopping = 1 if (ha1shop==-7 | ha1shop==-8) & (ha1shopdif==2 | ha1shopdif==3 | ha1shopdif==4) ;

replace limit_shopping = 0 if ha1shop==1 & ha1shopdif~=2 & ha1shopdif~=3 & ha1shopdif~=4 ;
replace limit_shopping = 0 if ha1shop==2 & ha1dshopreas~=1 ;
replace limit_shopping = 0 if ha1shop==3 & ha1dshopreas~=1 ;
replace limit_shopping = 0 if ha1shop==4 & ha1dshopreas~=1 & ha1shopdif~=2 & ha1shopdif~=3 & ha1shopdif~=4 ;
replace limit_shopping = 0 if ha1shop==5 & ha1dshopreas~=1 ;
replace limit_shopping = 0 if (ha1shop==-7 | ha1shop==-8) & ha1shopdif~=2 & ha1shopdif~=3 & ha1shopdif~=4 ;

codebook limit_shopping ;

/* hot meals */

generate limit_hotmeals = 1 if ha1meal==1 & (ha1mealdif==2 | ha1mealdif==3 | ha1mealdif==4) ;
replace limit_hotmeals = 1 if ha1meal==2 & ha1dmealreas==1 ;
replace limit_hotmeals = 1 if ha1meal==3 & ha1dmealreas==1 ;
replace limit_hotmeals = 1 if ha1meal==4 & (ha1dmealreas==1 | ha1mealdif==2 | ha1mealdif==3 | ha1mealdif==4) ;
replace limit_hotmeals = 1 if ha1meal==5 & ha1dmealreas==1 ;
replace limit_hotmeals = 1 if (ha1meal==-7 | ha1meal==-8) & (ha1mealdif==2 | ha1mealdif==3 | ha1mealdif==4) ;

replace limit_hotmeals = 0 if ha1meal==1 & ha1mealdif~=2 & ha1mealdif~=3 & ha1mealdif~=4 ;
replace limit_hotmeals = 0 if ha1meal==2 & ha1dmealreas~=1 ;
replace limit_hotmeals = 0 if ha1meal==3 & ha1dmealreas~=1 ;
replace limit_hotmeals = 0 if ha1meal==4 & ha1dmealreas~=1 & ha1mealdif~=2 & ha1mealdif~=3 & ha1mealdif~=4 ;
replace limit_hotmeals = 0 if ha1meal==5 & ha1dmealreas~=1 ;
replace limit_hotmeals = 0 if (ha1meal==-7 | ha1meal==-8) & ha1mealdif~=2 & ha1mealdif~=3 & ha1mealdif~=4 ;

codebook limit_hotmeals ;

/* banking */

generate limit_banking = 1 if ha1bank==1 & (ha1bankdif==2 | ha1bankdif==3 | ha1bankdif==4) ;
replace limit_banking = 1 if ha1bank==2 & ha1dbankreas==1 ;
replace limit_banking = 1 if ha1bank==3 & ha1dbankreas==1 ;
replace limit_banking = 1 if ha1bank==4 & (ha1dbankreas==1 | ha1bankdif==2 | ha1bankdif==3 | ha1bankdif==4) ;
replace limit_banking = 1 if ha1bank==5 & ha1dbankreas==1 ;
replace limit_banking = 1 if (ha1bank==-7 | ha1bank==-8) & (ha1bankdif==2 | ha1bankdif==3 | ha1bankdif==4) ;

replace limit_banking = 0 if ha1bank==1 & ha1bankdif~=2 & ha1bankdif~=3 & ha1bankdif~=4 ;
replace limit_banking = 0 if ha1bank==2 & ha1dbankreas~=1 ;
replace limit_banking = 0 if ha1bank==3 & ha1dbankreas~=1 ;
replace limit_banking = 0 if ha1bank==4 & ha1dbankreas~=1 & ha1bankdif~=2 & ha1bankdif~=3 & ha1bankdif~=4 ;
replace limit_banking = 0 if ha1bank==5 & ha1dbankreas~=1 ;
replace limit_banking = 0 if (ha1bank==-7 | ha1bank==-8) & ha1bankdif~=2 & ha1bankdif~=3 & ha1bankdif~=4 ;

codebook limit_banking ;

/* medication */

generate limit_meds = 1 if mc1medstrk==1 & (mc1medsdif==2 | mc1medsdif==3 | mc1medsdif==4) ;
replace limit_meds = 1 if mc1medstrk==2 & mc1dmedsreas==1 ;
replace limit_meds = 1 if mc1medstrk==3 & mc1dmedsreas==1 ;
replace limit_meds = 1 if mc1medstrk==4 & (mc1dmedsreas==1 | mc1medsdif==2 | mc1medsdif==3 | mc1medsdif==4) ;
replace limit_meds = 1 if mc1medstrk==5 & mc1dmedsreas==1 ;
replace limit_meds = 1 if (mc1medstrk==-7 | mc1medstrk==-8) & (mc1medsdif==2 | mc1medsdif==3 | mc1medsdif==4) ;

replace limit_meds = 0 if mc1meds==2 | mc1meds==-7 | mc1meds==-8 ;
replace limit_meds = 0 if mc1medstrk==1 & mc1medsdif~=2 & mc1medsdif~=3 & mc1medsdif~=4 ;
replace limit_meds = 0 if mc1medstrk==2 & mc1dmedsreas~=1 ;
replace limit_meds = 0 if mc1medstrk==3 & mc1dmedsreas~=1 ;
replace limit_meds = 0 if mc1medstrk==4 & mc1dmedsreas~=1 & mc1medsdif~=2 & mc1medsdif~=3 & mc1medsdif~=4 ;
replace limit_meds = 0 if mc1medstrk==5 & mc1dmedsreas~=1 ;
replace limit_meds = 0 if (mc1medstrk==-7 | mc1medstrk==-8) & mc1medsdif~=2 & mc1medsdif~=3 & mc1medsdif~=4 ;

codebook limit_meds ;

/* getting around outside */

generate limit_outside = 1 if mo1outoft==5 ; /* 1 */
replace limit_outside = 1 if mo1outdif==2 | mo1outdif==3 | mo1outdif==4 ; /* 2 */
replace limit_outside = 1 if mo1outhlp==1 ; /* 3 */
replace limit_outside = 0 if mo1outdif==1 & mo1outhlp==2 ; /* 4 */

codebook limit_outside ;

/* getting around inside */

generate limit_inside = 1 if mo1oflvslepr==5 ; /* 1 */
replace limit_inside = 1 if mo1insddif==2 | mo1insddif==3 | mo1insddif==4 ; /* 2 */
replace limit_inside = 1 if mo1insdhlp==1 ; /* 3 */
replace limit_inside = 0 if mo1insddif==1 & mo1insdhlp==2 ; /* 4 */

codebook limit_inside ;

/* getting out of bed */

generate limit_bed = 1 if mo1beddif==2 | mo1beddif==3 | mo1beddif==4 ; /* 2 */
replace limit_bed = 1 if mo1bedhlp==1 ; /* 3 */
replace limit_bed = 0 if mo1beddif==1 & mo1bedhlp==2 ; /* 4 */

codebook limit_bed ;

/* eating */

generate limit_eating = 1 if sc1eatdev==7 ; /* 1 */
replace limit_eating = 1 if sc1eatslfdif==2 | sc1eatslfdif==3 | sc1eatslfdif==4 ; /* 2 */
replace limit_eating = 1 if sc1eathlp==1 ; /* 3 */
replace limit_eating = 0 if sc1eatslfdif==1 & sc1eathlp==2 ; /* 4 */

codebook limit_eating ;

/* bathing */

generate limit_bathing = 1 if sc1bathdif==2 | sc1bathdif==3 | sc1bathdif==4 ; /* 2 */
replace limit_bathing = 1 if sc1bathhlp==1 ; /* 3 */
replace limit_bathing = 0 if sc1bathdif==1 & sc1bathhlp==2 ; /* 4 */

codebook limit_bathing ;

/* toileting */

generate limit_toileting = 1 if sc1toildif==2 | sc1toildif==3 | sc1toildif==4 ; /* 2 */
replace limit_toileting = 1 if sc1toilhlp==1 ; /* 3 */
replace limit_toileting = 0 if sc1toildif==1 & sc1toilhlp==2 ; /* 4 */

codebook limit_toileting ;

/* dressing */

generate limit_dressing = 1 if sc1dresoft==5 ; /* 1 */
replace limit_dressing = 1 if sc1dresdif==2 | sc1dresdif==3 | sc1dresdif==4 ; /* 2 */
replace limit_dressing = 1 if sc1dreshlp==1 ; /* 3 */
replace limit_dressing = 0 if sc1dresdif==1 & sc1dreshlp==2 ; /* 4 */

codebook limit_dressing ;

generate r1number_iadls = limit_laundry + limit_shopping + limit_hotmeals + limit_banking + limit_meds ;

tabulate r1number_iadls, missing ;

generate r1number_adls = limit_outside + limit_inside + limit_bed + limit_eating + limit_bathing + limit_toileting + limit_dressing ;

tabulate r1number_adls, missing ;

/* UNMET NEED */

generate r1unmet_adls = 1 if sc1eatwout==1 | sc1bathwout==1 | sc1toilwout==1 | sc1dreswout==1 | mo1outwout==1 | mo1insdwout==1 | mo1bedwout==1 ;
replace r1unmet_adls = 0 if r1unmet_adls ~= 1 ;

tabulate r1unmet_adls, missing ;

generate r1unmet_iadls = 1 if ha1launwout==1 | ha1shopwout==1 | ha1mealwout==1 | ha1bankwout==1 | mc1medsmis==1 ;
replace r1unmet_iadls = 0 if r1unmet_iadls ~= 1 ;

tabulate r1unmet_iadls, missing ;

generate r1unmet_any = 1 if r1unmet_adls==1 | r1unmet_iadls==1 ;
replace r1unmet_any = 0 if r1unmet_adls==0 & r1unmet_iadls==0 ;

tabulate r1unmet_any, missing ;

/* GENDER */

recode r1dgender (1=0) (2=1), generate(r1female) ;

codebook r1female ;

/* RACIAL ANCESTRY */

recode rl1dracehisp (5 6=.), generate(rl1race) ;

codebook rl1race ;

/* AGE */

recode r1d2intvrage (1 2=1) (3 4=2) (5 6=3), generate(r1age) ;

codebook r1age ;

/* SPOUSE NEEDS HELP WITH PERSONAL CARE */

recode hh1spoupchlp (1=1) (2=0) (-1 -7 -8 -9=.), generate(hh1specdisabled) ;

tabulate hh1specdisabled, missing ;

/* IS MARRIED AND HAS MORE THAN ONE CHILD */

recode hh1martlstat (-9 -8 -7 -1=.) (1 2=1) (3 4=2) (5=3) (6=4), generate(hh1marital) ;

codebook hh1marital ;

recode hh1martlstat (-9 -8 -7 -1=.) (1 2=1) (3 4 5 6=0), generate(hh1married) ;

codebook hh1married ;

recode cs1dnumchild (-1 0=0) (1=1) (2=2) (3/100=3), generate(r1numchild) ;

codebook r1numchild ;

recode cs1dnumchild (-1 0/1=0) (2/100=1), generate(r1has2child) ;

codebook r1has2child ;

/* TOTAL INCOME */

recode ia1toincim1 ia1toincim2 ia1toincim3 ia1toincim4 ia1toincim5 (-9 -1=.) ;

codebook ia1toincim1 ia1toincim2 ia1toincim3 ia1toincim4 ia1toincim5 ;

/* MEDICAID */

recode ip1cmedicaid (1=1) (2 -1=0) (-9 -8 -7=.), generate(ip1medicaid) ;

codebook ip1medicaid ;

/* RESIDENTIAL CARE STATUS */

recode r1dresid (1=0) (2=1 )(3 4=.) ;

codebook r1dresid ;

save SP_ROUND1, replace ;

log close ;
