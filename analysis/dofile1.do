#delimit ;

cd "F:\Research\NHATS project\NHATS\DATA" ;

log using "F:\Research\NHATS project\NHATS\LOGS\log1", replace ;

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
