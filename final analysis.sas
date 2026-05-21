proc import datafile='/home/u64226081/Studies/Feedback and perfectionsim/Combined wave 3.csv'
	out= tempwork
	dbms=csv
	replace;
run;

* no items need to be reversed coded.
* check if somehting is miscoded. all fine;
proc means data=work n min max mean std;
    var 
        OOP1 OOP2 OOP3 OOP4 OOP5
        FO1-FO20
        RF1-RF12
        SAT1-SAT7
        GO1-GO13;
run;

proc means data=work;
	var FO;
run;

proc means data=work min max mean std;
  var OOP;
run;
* Create the composite scores and dummy variables, centered moderator, interactions;
data work;
    set tempwork;
    
    FE = mean(of FE1-FE32);

    OOP = mean(OOP1, OOP2, OOP3, OOP4, OOP5);

    FO = mean(FO1, FO2, FO3, FO4, FO5,
              FO6, FO7, FO8, FO9, FO10,
              FO11, FO12, FO13, FO14, FO15,
              FO16, FO17, FO18, FO19, FO20);

    RF_Prevent = mean(RF1, RF2, RF3, RF4, RF5, RF6);
    RF_Promo   = mean(RF7, RF8, RF9, RF10, RF11, RF12);

    SAT = mean(SAT1, SAT2, SAT3, SAT4, SAT5, SAT6, SAT7);

    GO_Mastery   = mean(GO1, GO2, GO3, GO4, GO5);
    GO_Approach  = mean(GO6, GO7, GO8, GO9);
    GO_Avoidance = mean(GO10, GO11, GO12, GO13);
    
    
    if class = 1 then D2 = 0;
    if class = 2 then D2 = 1;
    if class = 3 then D2 = 0;

    if class = 1 then D3 = 0;
    if class = 2 then D3 = 0;
    if class = 3 then D3 = 1;
    FO_c = FO - 4.0310235;
    D2xFO = D2 * FO_c;
    D3xFO = D3 * FO_c;
    
    FO_low = FO - (4.0310235 - 0.5497884);
	D2xFO_low = D2*FO_low;
	D3xFO_low = D3*FO_low;
	
	FO_high = FO - (4.0310235 + 0.5497884);
	D2xFO_high = D2*FO_high;
	D3xFO_high = D3*FO_high;

run;


proc print data= work;
run;

proc freq data=work;
   tables Profile;
run;

proc means data=work;
	var Fo;
run;

*Get the alphas, all looks good;
proc corr data=work alpha;
    var OOP1-OOP5;
run;

proc corr data=work alpha;
    var FO1-FO20;
run;

proc corr data=work alpha;
    var RF1-RF6;
run;

proc corr data=work alpha;
    var RF7-RF12;
run;

proc corr data=work alpha;
    var SAT1-SAT7;
run;

proc corr data=work alpha;
    var GO1-GO5;
run;

proc corr data=work alpha;
    var GO6-GO9;
run;

proc corr data=work alpha;
    var GO10-GO13;
run;



*factor analysis, not doing feedback enviornment or FO;

proc calis data=work;
factor
    F1 => OOP1-OOP5;
run;

proc calis data=work;
factor
    F1 => SAT1-SAT7;
run;

proc calis data=work;
factor
    F1 => RF1-RF6,
    F2 => RF7-RF12;
run;

proc calis data=work;
factor
    F1 => FO1-FO5,
    F2 => FO6-FO10,
    F3 => FO11-FO15,
    F4 => FO16-FO20;
run;

proc calis data=work;
factor
    F1 => GO1-GO5,
    F2 => GO6-GO9,
    F3 => GO10-GO13;
run;



* first path with moderator;
proc reg data=work;
    model OOP = D2 D3 FO_c D2xFO D3xFO;
run;
quit;


*simple effects with unf reference;

proc glm data=work;
  model OOP = D2 D3 FO_low D2xFO_low D3xFO_low;
run;


proc glm data=work;
  model OOP = D2 D3 FO_high D2xFO_high D3xFO_high;
run;

* Mediation;

* first path;
proc reg data= work;
	model OOP = D2 D3 FO_c D2xFO D3xFO ;
run;

* B path;
proc reg data= work;
	model GO_Mastery GO_Approach GO_Avoidance = D2 D3 OOP;
run;


* total effect;
proc reg data= work;
	model RF_Prevent RF_Promo SAT GO_Mastery GO_Approach GO_Avoidance = D2 D3;
run;

*first path, not sig, so will do conditional indeirect effect, or moderated mediation;

* B path and direct effect;
proc reg data= work;
	model GO_Mastery GO_Approach GO_Avoidance = D2 D3 OOP;
run;

* now do the moderated mediaiton;
%process(
  data = work,
  y = GO_Approach,
  x = class,
  m = OOP,
  w = FO_c,
  model = 8,
  mcx = 1,
  moments = 1,
  boot = 5000,
  seed = 1234
);


proc surveyselect data=work method=urs rep=5000 sampsize=469 seed=1234 out=boot outhits;
	id D2 D3 FO_c D2xFO D3xFO OOP GO_Mastery GO_Approach GO_Avoidance;
run;

proc sort data=boot; by replicate; run;

/* a path */
proc reg data=boot noprint outest=tempA;
	model OOP = D2 D3 FO_c D2xFO D3xFO;
	by replicate;
run;

data stage1;
	set tempA;
	a1 = D2;
	a2 = D3;
	a4 = D2xFO;
	a5 = D3xFO;
	keep replicate a1 a2 a4 a5;
run;

/* b path (example: GO_Approach) */
proc reg data=boot noprint outest=tempB;
	model GO_Avoidance = D2 D3 FO_c D2xFO D3xFO OOP;
	by replicate;
run;

data stage2;
	set tempB;
	b = OOP;
	keep replicate b;
run;

proc sort data=stage1; by replicate; run;
proc sort data=stage2; by replicate; run;

/* indirect + index */
data IE;
	merge stage1 stage2;
	by replicate;

	Wlow  = -0.5497884;
	Whigh =  0.5497884;

	IED2_low  = (a1 + a4*Wlow)*b;
	IED2_high = (a1 + a4*Whigh)*b;

	IED3_low  = (a2 + a5*Wlow)*b;
	IED3_high = (a2 + a5*Whigh)*b;

	Index_D2 = a4*b;
	Index_D3 = a5*b;
run;

proc freq; tables IED2_low; run;
proc freq; tables IED2_high; run;
proc freq; tables Index_D2; run;


proc univariate data=IE noprint;
	var IED2_low IED2_high IED3_low IED3_high Index_D2 Index_D3;
	output out=CI
		pctlpts=2.5 97.5
		pctlpre=IED2_low_ IED2_high_ IED3_low_ IED3_high_ Index_D2_ Index_D3_
		pctlname=LCL UCL;
run;

proc print data=CI; run;

