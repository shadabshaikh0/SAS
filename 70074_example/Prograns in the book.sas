*1-1;
libname clean 'c:\books\Clean3';
data Patients;
   infile 'c:\books\clean3\Patients.txt' ;  
   input  @1  Patno      $3.
          @4  Account_No $7.
          @11 Gender     $1.
          @12 Visit      mmddyy10.
          @22 HR         3.
          @25 SBP        3.
          @28 DBP        3.
          @31 Dx         $7.
          @38 AE         1.;
   label Patno   =    "Patient Number"
         Account_No = "Account Number"
         Gender  =    "Gender"
         Visit   =    "Visit Date"
         HR      =    "Heart Rate"
         SBP     =    "Systolic Blood Pressure"
         DBP     =    "Diastolic Blood Pressure"
         Dx      =    "Diagnosis Code"
         AE      =    "Adverse Event?";
    format Visit mmddyy10.;
run;
proc sort data=Clean.Patients;
   by Patno Visit;
run;
proc print data=Clean.Patients;
   id Patno;
run;

*1-2;
libname Clean 'c:\Books\Clean3';
*Program to Compute Frequencies for Gender and the 
 First Two Digits of the Account_No (State Abbreviation);
data Check_Char;
   set Clean.Patients(keep=Patno Account_No Gender);
   length State $ 2;
   State = Account_No;
run;
title "Frequencies for Gender and the First Two Digits of Account_No";
proc freq data=Check_Char;
   tables Gender State / nocum nopercent;
run;

*1-3;
*Program to UPCASE all the character variables in the
 Patients data set;
data Clean.Patients_Caps;
   set Clean.Patients;
   array Chars[*] _character_;
   do i = 1 to dim(Chars);
      Chars[i] = upcase(Chars[i]);
   end;
   drop i;
run;
title "Listing the First 10 Observations in Data Set Patients_Caps";
proc print data=clean.Patients_Caps(obs=10) noobs;
run;

*1-4;
title 'Checking for Invalid Dx Codes';
data _null_;
   set Clean.Patients(keep=Patno Dx);
   length First_Three Last_Three $ 3 Period $ 1;
   First_Three = Dx;   
   Period = substr(Dx,4,1);
   Last_Three = substr(Dx,5,3);
   file print;
   if missing(Dx) then put
      "Missing Dx for patient " Patno;
   else if notdigit(First_Three) or Period ne '.' or notdigit(Last_Three) 
      then put "Invalid Dx " Dx "for patient " Patno;
run;

*1-5;
*Using a DATA step to check for invalid Gender and State Codes;
data _null_;
   title "Invalid Gender or State Codes";
   title2;
   file print;
   set Clean.Patients(keep=Patno Gender Account_No);
   length State $ 2;
   State = Account_No;
   *Checking value of Gender;
   if missing(Gender) then put 
      "Patient " Patno "has a missing value for Gender";
   else if Gender not in ('M','F') then put 
      "Patient number " Patno "has an invalid value for Gender: " Gender;
   *Checking for invalid State abbreviations;
   if State not in ('NJ','NY','PA','CT','DE','VT','NH','ME','RI','MA','MD')
      then put "Patient number " Patno "has an invalid State code: " State;
run;

*1-6;
*Using PROC PRINT to identify data errors;
title "Using PROC Print to Identify Data Errors";
proc print data=Clean.Patients;
   id Patno;
   var Account_No Gender;
   where notdigit(Patno) or
         notalpha(Account_No,-2) or
         notdigit(Account_No,3) or
         Gender not in ('M','F');
run;

*1-7;
*Using formats to identify data errors;
title "Listing Invalid Values of Gender";
proc format;
   value $Gender_Check 'M','F' = 'Valid'
                       ' '     = 'Missing'
                       other   = 'Error';
run;
proc freq data=Clean.Patients;
   tables Gender / nocum nopercent missing;
   format Gender $Gender_Check.;
run;

*1-8;
*Using formats to identify data errors;
title "Listing Invalid Values of Gender";
proc format;
   value $Gender_Check 'M','F' = 'Valid'
                       ' '     = 'Missing'
                       other   = 'Error';
run;
data _null_;
   set Clean.Patients(keep=Patno Gender);
   file print;
   if put(Gender,$Gender_Check.) = 'Missing' then put
      "Missing value for Gender for patient " Patno;
   else if put(Gender,$Gender_Check.) = 'Error' then put
      "Invalid value of " Gender "for Gender for patient " Patno;
run;

*1-9;
proc format library=Clean;
   value $Gender_Check 'M','F' = 'Valid'
                       ' '     = 'Missing'
                       other   = 'Error';
run;

*1-10;
*Program to Remove Units from Numeric Data;
data Units;
   input Weight $ 10.;
   Digits = compress(Weight,,'kd');
   if findc(Weight,'k','i') then
      Wt_Kg = input(Digits,5.);
   else if not missing(Digits) then  
      Wt_Kg = input(Digits,5.)/2.2;
datalines;
100lbs.
110 Lbs.
50Kgs.
70 kg
180
;
title "Reading Weight Values with Units";
proc print data=Units noobs;
   format Wt_Kg 5.1;
run;

*2-1;
title "Checking Dx Values Using a Regular Expression";
data _null_;
   file print;
   set clean.Patients(keep=Patno Dx);
   if not prxmatch("/\d\d\d\.\d\d\d/",Dx) then
      put "Error for patient " Patno "  Dx code = " Dx;
run;  

*2-2;
*Program to test the Regex for US Zip Codes;
title "Testing the Regular Expression for US Zip Codes";
data _null_;
   file print;
   input Zip $10.;
  if not prxmatch("/\d{5}(-\d{4})?/",Zip) then 
      put "Invalid Zip Code " Zip;
datalines;
12345
78010-5049
12Z44
ABCDE
08822
;

*1-3;
title "Testing the Regular Expression for Canadian Postal Codes";
data _null_;
   First =  "/[ABCEFGHJ-NPQRSTVXY][0-9]";
   Second = "[ABCEFGHJ-NPRSTV-Z] ?[0-9]";
   Third =  "[ABCEFGHJ-NPRSTV-Z][0-9]/";
   file print;
   input CPC $7.;
   Regex = First||Second||Third;
   if not prxmatch(Regex,CPC) then 
     put "Invalid Postal Code " CPC;
datalines;
A1B2C3
ABCDEF
A1B 2C3
12345
D5C6F7
;

*2-4;
*Program to test the Regex for Email Addresses;
title "Testing the Regular Expression Email Addresses";
data _null_;
   file print;
   input Email $50.;
   if not prxmatch("/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b/i",
     Email) then 
     put "Invalid Email Address " Email;
datalines;
Jeff.Clark@google.com
no_at_sign_here
1234567890.1234567
fred@rr.tt.org
Bill_Baker@Kerrville.edu
A.B.C@def.too_long
;

*2-5;
*Program to Standardize Phone Numbers;
data Standard_Phone;
   input Phone $16.;
   Digits = compress(Phone,,'kd');
   Phone = cats('(',substr(Digits,1,3),')',substr(Digits,4,3),
      '-',substr(Digits,7));
   drop Digits;
datalines;
(908)123-1234
609.455-7654
2107829999
(800) 123-4567
run;
title "Listing of Standardized Phone Numbers";
proc print data=Standard_Phone noobs;
run;

*2-6;
%macro Test_Regex(Regex=, /*Your regular expression*/
                  String= /*The string you want to test*/);
   data _null_;
      file print;
      put "Regular Expression is: &Regex " /
          "String is: &String";
      Position = prxmatch("&Regex","&String");
      if position then put "Match made starting in position " Position;
      else put "No match";
   run;
%Mend Test_Regex;
/*Sample calls
%Test_Regex(Regex=/cat/,String=there is a cat there)
%Test_Regex(Regex=/([A-Za-z]\d){3}\b/, String=a1b2c3)
%Test_Regex(Regex=/([A-Za-z]\d){3}\b/, String=1a2b3c)
*/

*3-1;
data Company;
   input Name $ 50.;
datalines;
International Business Machines
International Business Macnines, Inc.
IBM
Little and Sons
Little & Sons
Little and Son
MacHenrys
McHenrys
MacHenries
McHenry's
Harley Davidson
;

*3-2;
proc format;
   value $Company 
      "International Business Machines, Inc." = 
      "International Business Machines"
      "IBM" = "International Business Machines"
      "Little & Sons" = "Little and Sons"
      "Little and Son" = "Little and Sons"
      "MacHenrys"      = "McHenrys"
      "MacHenries"     = "McHenrys"
      "McHenry's"      = "McHenrys";
run;

*3-3;
data Standard;
   set Company;
   Standard_Name = put(Name,$Company.);
run;
title "Listing of Standard";
proc print data=Standard noobs;
run;

*3-4;
*Create Data Set Standardize;
data Standardize;
   input @1  Alternate $40.
         @41 Standard  $40.;
datalines;
International Business Machines, Inc.   International Business Machines
IBM                                     International Business Machines
Little & Sons                           Little and Sons
Little and Son                          Little and Sons
MacHenrys                               McHenrys
MacHenries                              McHenrys
McHenry's                               McHenrys
;

*3-5;
data Control;
   set Standardize(rename=(Alternate=Start Standard=Label));
   retain Fmtname "Company" Type "C";
run;

*3-6;
proc format library=work cntlin=Control fmtlib;
run;

*3-7;
*Program to create data set Addresses;
data Clean.Addresses;
   input #1 Name    $25.
         #2 Street  $30.
         #3 @1  City  $20. 
            @21 State  $2.
            @23 Zip   $10.;
datalines;
Robert L. Stevenson
12 River Road
Hartford            CN06101
Mr.  Fred Silver
145A Union Court
Flemingron          NJ08822
Mrs. Beverly Bliss
6767 Camp Verde Road East
Center  Point       tx78010
Mr. Dennis Brown, Jr.
67 First Street
Miami               FL33101
Ms. Sylvia D'AMORE
23 Upper Valley Rd.
Clear   Lake        WI54005
;

title "Listing of Data Set Addresses";
proc print data=clean.Addresses noobs heading=h;
run;

*3-8;
data Std_Addresses;
   set Clean.Addresses;
   array Chars[*] Name Street City;
   do i = 1 to dim(Chars);
      Chars[i] = compbl(Chars[i]);
      Chars[i] = propcase(Chars[i]," '");
   end;
   Street = tranwrd(Street,"Road","Rd.");
   Street = tranwrd(Street,"Court","Ct.");
   Street = tranwrd(Street,"Street","St.");
   State = Upcase(State);
   *Remove ,Jr. from Name;
   Name = tranwrd(Name,"Jr."," ");
   Name = tranwrd(Name,","," ");
   drop i;
run;
title "Listing of Std_Addresses";
proc print data=Std_Addresses noobs;
run;

*3-9;
data Remove_Names;
   set Clean.Addresses(keep=Street);
   Original = Street;
   Words = "s/\sRoad\b|\sCourt\b|\sStreet\b";
   Abbreviations = "|\sRd\.\s*$|\sCt\.\s*$|\sSt\.\s*$/ /";
   Regex = cats(Words,Abbreviations);
   Street = prxchange(Regex,-1,Street);
   Keep Original Street;
run;

*3-10;
data Clean.Discharge;
   set Clean.Discharge;
   LastName = propcase(LastName," '");
   Gender = Upcase(Gender);
run;
data Clean.MI;
   set Clean.MI;
   LastName_MI = propcase(LastName_MI," '");
   Gender_MI = upcase(Gender_MI);
run;

*3-11;
title "Creating a Cartesian Product";
proc sql;
   create table Clean.join as
   select *
   from Clean.Discharge, Clean.MI;
   /* A WHERE Clause will go here -
      Do NOT run this program without it
   */
quit;
title "Listing of Data Set JOIN";
proc print data=Clean.join;
   id LastName;
run;


*3-12;
proc sql;
   create table Clean.Exact as
   select *
   from Clean.Discharge, Clean.MI
   where DOB eq DOB_MI          and
         Gender eq Gender_MI    and
         LastName = LastName_MI;
quit;

*3-13;
proc sql;
   create table Clean.Possible as
   select *
   from Clean.discharge, Clean.MI
   where DOB eq DOB_MI          and
         Gender eq Gender_MI    and
         0 lt spedis(LastName,LastName_MI) le 25;
quit;

*4-1;
title "Running PROC UNIVARIATE on HR, SBP, and DBP";
proc univariate data=Clean.Patients;
   id Patno;
   var HR SBP DBP;
   histogram / normal;
run;

*4-2;
title "Running PROC UNIVARIATE on HR, SBP, and DBP";
ods select ExtremeObs;
proc univariate data=Clean.Patients nextrobs=10;
   id Patno;
   var HR SBP DBP;
   histogram / normal;
run;

*4-3;
proc sort data=Clean.Patients(keep=Patno HR
                              where=(HR is not missing))
                              out=Tmp;
   by HR;
run;
data _null_;
   if 0 then set Tmp nobs=Number_of_Obs;
   High = Number_of_Obs - 9;
   call symputx('High_Cutoff',High);
   stop;
run;
title "Ten Highest and Lowest Values for HR";
data _null_;
   set Tmp(obs=10)                 /* 10 lowest values  */
       Tmp(firstobs=&High_Cutoff); /* 10 highest values */
   file print;
   if _n_ le 10 then do;
      if _n_ = 1 then put / "Ten Lowest Values";
      put "Patno = " Patno @15 "Value = " HR;
   end;
   else if _n_ ge 11 then do;
      if _n_ = 11 then put / "10 Highest Values";
      put "Patno = " Patno @15 "Value = " HR;
   end;
run;

*4-4;
*Macro Name: HighLow
Purpose: To list the "n" highest and lowest values
Arguments: Dsn     - Data set name (one- or two-level)
           Var     - Variable to list
           IDvar   - ID variable
           N       - Number of values to list (default = 10)
example: %HighLow(Dsn=Clean.Patients,
                  Var=HR,
                  IDvar=Patno,
                  N=7)
;
%macro HighLow(Dsn=,     /* Data set name            */
               Var=,     /* Variable to list         */
               IDvar=,   /* ID Variable              */
               N=10      /* Number of high and low
                            values to list.
                            The default number is 10 */);
   proc sort data=&Dsn(keep=&IDvar &Var
                       where=(&Var is not missing))
                       out=Tmp;
      by &Var;
   run;
   data _null_;
      if 0 then set Tmp nobs=Number_of_Obs;
      High = Number_of_Obs - %eval(&N - 1);
      call symputx('High_Cutoff',High);
      stop;
   run;
   title "&N Highest and Lowest Values for &Var";
   data _null_;
   set Tmp(obs=&N)                 /* 'n' lowest values  */
       Tmp(firstobs=&High_Cutoff); /* 'n' highest values */
   file print;
   if _n_ le &N then do;
      if _n_ = 1 then put / "&N Lowest Values";
      put "Patno = " &IDvar @15 "Value = " &Var;
   end;
   else if _n_ ge %eval(&N + 1) then do;
      if _n_ = %eval(&N + 1) then put / "&N Highest Values";
      put "&IDvar = " &IDvar @15 "Value = " &Var;
   end;
   run;
   proc datasets library=work nolist;
      delete Tmp;
   run;
   quit;
%mend HighLow;

%HighLow(Dsn=Clean.Patients,
         Var=HR,
         Idvar=Patno,
          N=7)

*4-5;
*Program HighLowPercent
 Prints the top and bottom 5% of values of a variable;
proc univariate data=Clean.Patients noprint;
   var HR;
   id Patno;
   output out=Tmp pctlpts=5 95 pctlpre = Percent_;   
run;
data HighLowPercent;
   set Clean.Patients(keep=Patno HR);
   ***Bring in upper and lower cutoffs for variable;
   if _n_ = 1 then set Tmp;
   if HR le Percent_5 and not missing(HR) then do;
      Range = 'Low ';
      output;
   end;
   else if HR ge Percent_95 then do;
      Range = 'High';
      output;
   end;
run;
proc sort data=HighLowPercent;
   by HR;   
run;
title "Top and Bottom 5% for Variable HR"; 
proc print data=HighLowPercent;
   id Patno;
   var Range HR;
run;

*4-6;
*---------------------------------------------------------------*
| Program Name: HighLowPcnt.sas                                 |
| Purpose: To list the n percent highest and lowest values for  |
|          a selected variable.                                 |
| Arguments: Dsn     - Data set name                            |
|            Var     - Numeric variable to test                 |
|            Percent - Upper and Lower percentile cutoff        |
|            Idvar   - ID variable to print in the report       |
| Example: %HighLowPcnt(Dsn=clean.patients,                     |
|                       Var=SBP,                                |
|                       Percent=5,                              |
|                       Idvar=Patno)                            |
*---------------------------------------------------------------*;
%macro HighLowPcnt(Dsn=,  /* Data set name                     */
                Var=,     /* Variable to test                  */
                Percent=, /* Upper and lower percentile cutoff */
                Idvar=    /* ID variable                       */);
   ***Compute upper percentile cutoff;
   %let Upper = %eval(100 - &Percent);
   proc univariate data=&Dsn noprint;
      var &Var;
      id &Idvar;
      output out=Tmp pctlpts=&Percent &Upper pctlpre = Percent_;
   run;
   data HiLow;
      set &Dsn(keep=&Idvar &Var);
      if _n_ = 1 then set Tmp;
      if &Var le Percent_&Percent and not missing(&Var) then do;
         range = 'Low ';
         output;
      end;
      else if &Var ge Percent_&Upper then do;
         range = 'High';
         output;
      end;
   run;
   proc sort data=HiLow;
      by &Var;
   run;
   title "Highest and Lowest &Percent% for Variable &var";
   proc print data=HiLow;
      id &Idvar;
      var Range &Var;
   run;
   proc datasets library=work nolist;
     delete Tmp HiLow;
   run;
   quit;
%mend HighLowPcnt;

%HighLowPcnt(Dsn=Clean.Patients,
             Var=SBP,
             Percent=5,
             Idvar=Patno)

*4-7;
*Program to create Rank_Example;
data Rank_Example;
   input ID $ X Y;
datalines;
001 5 10
002 3 15
003 7 11
004 2 13
005 . 14
;

proc rank data=Rank_Example out=Ranked_Data;
   var X;
   ranks Rank_of_X;
run;
title "Listing of Ranked_Data";
proc print data=Ranked_Data noobs;
run;

*4-8;
proc rank data=Rank_Example out=Ranked_Data groups=2;
   var X;
   ranks Rank_of_X;
run;
title "Listing of Ranked_Data with GROUPS=2";
proc print data=Ranked_Data noobs;
run;

*4-9;
proc rank data=Clean.Patients(keep=Patno SBP) out=HiLow groups=20;
   var SBP;
   ranks Range;
run;
proc sort data=HiLow(where=(Range in (0,19)));
   by SBP;
run;
proc format;
   value rank 0 = 'Low'
             19 = 'High';
run;
title "Top and Bottom 5% for Variable SBP"; 
proc print data=HiLow;
   id Patno;
   var Range SBP;
   format Range rank.;
run;          

*4-10;
*Program to List Out-of-Range Values;
title "Listing of Out-of-Range Values";
data _null_;
   file print;
   set Clean.Patients(keep=Patno HR SBP DBP);
   *Check HR;
   if (HR lt 40 and not missing(HR)) or HR gt 100 then
      put Patno= HR=;
   *Check SBP;
   if (SBP lt 50 and not missing (SBP)) or SBP gt 240 then
      put Patno= SBP=;
   *Check DBP;
   if (DBP lt 35 and not missing (DBP)) or DBP gt 130 then
      put Patno= DBP=;
run;

*4-11;
*Program to Demonstrate How to Identify Invalid Data;
title "Listing of Invalid Data for HR, SBP, and DBP";
data _null_;
   file print;
   input @1  Patno $3.
         @4  HR $3. 
         @7  SBP $3.
         @10 DBP $3.;
   if notdigit(trimn(HR)) and not missing(HR) then
      put "Invalid value " HR "for HR in patient " Patno;
   if notdigit(trimn(SBP)) and not missing(SBP) then
      put "Invalid value " SBP "for SBP in patient " Patno;
   if notdigit(trimn(DBP)) and not missing(DBP) then
      put "Invalid value " DBP "for DBP in patient " Patno;
datalines;
001080140 90
0029.0180 90
003abcdefghi
00490x120100
005       80
;

*4-12;
*Program to Demonstrate How to Identify Invalid Data;
title "Listing of Invalid Data for HR, SBP, and DBP";
data _null_;
   file print;
   input @1  Patno $3.
         @4  HR $3. 
         @7  SBP $3.
         @10 DBP $3.;
   X = input(HR,3.);
   if _error_ then do;
      put "Invalid value " HR "for HR in patient " Patno;
      _error_ = 0;
   end;
   X = input(SBP,3.);
   if _error_ then do;
      put "Invalid value " SBP "for SBP in patient " Patno;
      _error_ = 0;
   end;
   X = input(DBP,3.);
   if _error_ then do;
      put "Invalid value " DBP "for DBP in patient " Patno;
      _error_ = 0;
   end;
datalines;
001080140 90
0029.0180 90
003abcdefghi
00490x120100
005       80
;

*4-13;
*Program Name: Errors.Sas
 Purpose: Accumulates errors for numeric variables in a SAS
         data set for later reporting/
         This macro can be called several times with a
         different variable each time. The resulting errors
         are accumulated in a temporary SAS data set called
         errors.
*Macro variables Dsn and IDvar are set with %Let statements before
 the macro is run;
%macro Errors(Var=,    /* Variable to test     */
              Low=,    /* Low value            */
              High=,   /* High value           */
              Missing=ignore 
                       /* How to treat missing values         */
                       /* Ignore is the default.  To flag     */
                       /* missing values as errors set        */
                       /* Missing=error                       */);
data Tmp;
   set &Dsn(keep=&Idvar &Var);
   length Reason $ 10 Variable $ 32;
   Variable = "&Var";
   Value = &Var;
   if &Var lt &Low and not missing(&Var) then do;
      Reason='Low';
      output;
   end;
   %if %upcase(&Missing) ne IGNORE %then %do;
   else if missing(&Var) then do;
      Reason='Missing';
      output;
   end;
   %end;
   else if &Var gt &High then do;
        Reason='High';
      output;
      end;
      drop &Var;
   run;
   proc append base=errors data=Tmp;
   run;
%mend errors;

%macro report;
   proc sort data=Errors;
      by &Idvar;
   run;
   proc print data=errors;
   title "Error Report for Data Set &Dsn";
      id &Idvar;
      var Variable Value Reason;
   run;
   proc datasets library=work nolist;
      delete errors;
      delete tmp;
   run;
   quit;
%mend report;

***Set two macro variables;
%let Dsn=Clean.Patients; 
%let IDvar = Patno;
%Errors(Var=HR, Low=40, High=100, Missing=error)
%Errors(Var=SBP, Low=50, High=240, Missing=ignore)
%Errors(Var=DBP, Low=35, High=130)
***Generate the report;
%report

*5-1;
*Use PROC MEANS to Output means and standard deviations to a data set;
proc means data=Clean.Patients noprint;
   var HR;
   output out=Mean_Std(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

title "Outliers for HR Based on 2 Standard Deviations";
data _null_;
   file print;
   set Clean.Patients(keep=Patno HR);
   ***bring in the means and standard deviations;
   if _n_ = 1 then set Mean_Std;
   if HR lt HR_Mean - 2*HR_StdDev and not missing(HR)
      or HR gt HR_Mean + 2*HR_StdDev then put Patno= HR=;
run;

*5-2;
proc rank data=Clean.Patients(keep=Patno HR) out=Tmp groups=10;
   var HR;
   ranks Rank_HR;
run;
proc means data=Tmp noprint;
   where Rank_HR not in (0,9);
   *Trimming the top and bottom 10%;
   var HR;
   output out=Mean_Std_Trimmed(drop=_type_ _freq_)
          mean=
          std= / autoname;
run;

*5-3;
title "Outliers for HR Based on Trimmed Statistics";
data _null_;
   file print;
   set Clean.Patients(keep=Patno HR);
   ***bring in the means and standard deviations;
   if _n_ = 1 then set Mean_Std_Trimmed;
   *Adjust the standard deviation;
   Mult = 1.49;
   if HR lt HR_Mean - 2*Mult*HR_StdDev and not missing(HR)
      or HR gt HR_Mean + 2*Mult*HR_StdDev then put Patno= HR=;
run;

*5-4;
ods output TrimmedMeans=Trimmed;
proc univariate data=Clean.Patients trim=.1;
   var HR SBP DBP;
run;
ods output close;

data Restructure;
   set Clean.Patients;
   length VarName $ 32;
   array Vars[*] HR SBP DBP;
   do i = 1 to dim(Vars);
      VarName = vname(Vars[i]);
      Value = Vars[i];
      output;
   end;
   keep Patno VarName Value;
run;

proc sort data=Trimmed;
   by VarName;
run;
proc sort data=Restructure;
   by VarName;
run;
data Outliers;
   merge Restructure Trimmed;
   by VarName;
   Std = StdMean*sqrt(DF + 1);
   if Value lt Mean - 2*Std and not
   missing(Value) then do;
      Reason = 'Low  ';
      output;
   end;
   else if Value gt Mean + 2*Std then do;
      Reason = 'High';
      output;
   end;
run;

proc sort data=Outliers;
   by Patno;
run;
title "Outliers based on trimmed Statistics";
proc print data=outliers;
   id patno;
   var Varname Value Reason;
run;

*5-5;
*Method using automatic outlier detection;
%macro Auto_Outliers(
   Dsn=,      /* Data set name                        */
   ID=,       /* Name of ID variable                  */
   Var_list=, /* List of variables to check           */
              /* separate names with spaces           */
   Trim=.1,   /* Integer 0 to n = number to trim      */
              /* from each tail; if between 0 and .5, */
              /* proportion to trim in each tail      */
   N_sd=2     /* Number of standard deviations        */);
   ods listing close;
   ods HTML close;
   ods output TrimmedMeans=Trimmed(keep=VarName Mean Stdmean DF);
   proc univariate data=&Dsn trim=&Trim;
     var &Var_list;
   run;
   ods output close;
   data Restructure;
      set &Dsn;
      length VarName $ 32;
      array Vars[*] &Var_list;
      do i = 1 to dim(Vars);
         VarName = vname(Vars[i]);
         Value = Vars[i];
         output;
      end;
      keep &ID VarName Value;
   run;
   proc sort data=Trimmed;
      by VarName;
   run;
   proc sort data=restructure;
      by VarName;
   run;

   data Outliers;
      merge Restructure Trimmed;
      by VarName;
      Std = StdMean*sqrt(DF + 1);
      if Value lt Mean - &N_sd*Std and not missing(Value) 
         then do;
            Reason = 'Low  ';
            output;
         end;
      else if Value gt Mean + &N_sd*Std
         then do;
         Reason = 'High';
         output;
      end;
   run;
   proc sort data=Outliers;
      by &ID;
   run;
   ods listing;
   ods HTML;
   title "Outliers Based on Trimmed Statistics";
   proc print data=Outliers;
      id &ID;
      var VarName Value Reason;
   run;
   proc datasets nolist library=work;
      delete Trimmed;
      delete Restructure;
   run;
   quit;
%mend Auto_Outliers;

%Auto_Outliers(Dsn=Clean.Patients,
               Id=Patno,
               Var_List=HR SBP DBP,
               Trim=.1,
               N_Sd=2)

*5-6;
*Using PROC SGPLOT to Create a Box Plot for SBP;
title "Using PROC SGPLOT to Create a Box Plot";
proc sgplot data=clean.Patients(keep=Patno SBP);
   hbox SBP;
run;

*5-7;
*Using PROC SGPLOT to Create a Box Plot for SBP;
title "Using PROC SGPLOT to Create a Box Plot";
proc sgplot data=clean.Patients(keep=Patno SBP Gender
   where=(Gender in ('F','M')));
   hbox SBP / category=Gender;
run;

*5-8;
title "Outliers Based on Interquartile Range";
proc means data=Clean.Patients noprint;
   var HR;
   output out=Tmp 
          Q1=
          Q3=
          QRange= / autoname;
run;
data _null_;
   file print;
   set Clean.Patients(keep=Patno HR);
   if _n_ = 1 then set Tmp;
   if HR le HR_Q1 - 1.5*HR_QRange and not missing(HR) or
      HR ge HR_Q3 + 1.5*HR_QRange then   
      put "Possible Outlier for patient " Patno "Value of HR is " HR;
run;

*6-1;
title "Histogram of Account Balances";
proc sgplot data=Clean.Banking;
   histogram Balance;
run;

*6-2;
title "Using PROC UNIVARIATE to Examine Bank Deposits";
proc univariate data=Clean.Banking;
   id Account;
   var Deposit;
   histogram / normal;
run;
*6-3;
%Auto_Outliers(dsn=Clean.Banking,
               ID=Account,
               Var_List=Deposit,
               Trim=.1,
               N_Sd=2)

*6-4;
proc means data=Clean.Banking noprint nway;
   class Account;
   var Deposit;
   output out=By_Account(where=(Deposit_N ge 5) drop=_type_ _freq_) 
      Q1= Q3= QRange= 
      Median= n= / autoname;
run;

*6-5;
data Outliers;
   merge Clean.Banking(keep=Account Deposit 
         where=(Deposit is not missing)) 
         By_Account(In=In_By_Account);
   by Account;
   if In_By_Account;
   if Deposit lt Deposit_Q1 - 1.5*Deposit_QRange or
      Deposit gt Deposit_Q3 + 1.5*Deposit_QRange then output;
run;

*6-6;
title "Listing of Data Set Outliers";
proc report data=Outliers headline;
   columns Account Deposit Deposit_Median Deposit_QRange;
   define Account / order "Account Number" width=7;
   define Deposit / Format=dollar12.2;
   define Deposit_Median / "Median" Format=dollar12.2;
   define Deposit_QRange / "Interquartile Range" width=13;
run;

*6-7;
proc sort data=Outliers(keep=Account) nodupkey out=Single;
   by Account;
run;
Data Plot_Data;
   merge Single(in=In_Single)
         Clean.Banking(keep=Account Deposit
                       where=(Deposit is not missing));
   by Account;
   if In_Single;
run;

*6-8;
title "Box Plots for Possible Deposit Outliers";
proc sgplot data=Plot_Data;
   hbox Deposit / category=Account;
run;

*6-9;
title "Creating Separate Plots for Each Account";
proc sgplot data=Plot_Data;
   hbox Deposit;
   by Account;
run;

*6-10;
title "Regression of Deposit by Balance";
proc reg data=Clean.Banking(where=(Deposit is not missing)
   keep=Account Deposit Balance) 
   plots(only label)=(diagnostics(unpack) 
   residuals(unpack) 
   rstudentbypredicted dffits fitplot observedbypredicted);
   id Account;
   model Deposit=Balance / influence;
   output out=Diagnostics rstudent=Rstudent cookd=Cook_D
                          dffits=DFfits;
   run;
quit;

*6-11;
data _null_;
   if 0 then set Diagnostics nobs=Number_of_Obs;
   call symputx('N',Number_of_Obs);
   stop;
run;

*6-12;
%let  N_Parameters=2;
data Influence;
   set Diagnostics nobs=N;
   Student=0;
   Cook=0;
   DF_fits=0;
   if abs(Rstudent gt 2) then Student=1;
   if Cook_D gt 4/N then Cook=1;
   if DFfits gt 2*sqrt(&N_Parameters/N) then DF_fits=1;
run;

*6-13;
title "Outliers Based on - Rstudent";
proc print data=Influence;
   where Student;
   id Account;
   var Deposit Balance Rstudent;
run;

*6-14;
title "Outliers Based on - All Measures Together";
proc print data=Influence;
   where Student or Cook or DF_fits;
   id Account;
   var Deposit Balance Rstudent Cook_D DFfits;
run;

*7-1;
title "Checking Numeric Missing Values from the Patients data set";
proc means data=Clean.Patients n nmiss;
run;

*7-2;
title "Checking Missing Character Values";
proc format;
   value $Count_Missing ' '   = 'Missing'
                  other = 'Nonmissing';
run;
proc freq data=Clean.Patients;
   tables _character_ / nocum missing;
   format _character_ $Count_Missing.;
run;

*7-3;
title "Listing of Missing Values";
data _null_;
   file print; ***send output to the output window;
   set Clean.Patients(keep=Patno Visit HR Gender Dx);
   if missing(visit) then 
      put "Missing or invalid Visit for ID " Patno;
   if missing(HR) then put "Missing or invalid HR for ID " Patno;
   if missing(Gender) then put "Missing Gender for ID " Patno;
   if missing(Dx) then put "Missing Dx for ID " Patno;
run;

*7-4;
title "Listing of Missing or Invalid Patient Numbers";
data _null_;
   set Clean.Patients;
   ***Be sure to run this on the unsorted data set;
   file print;
   Previous_ID = lag(Patno);
   Previous2_ID = lag2(Patno);
   if missing(Patno) then 
      put "Missing patient ID. Two previous ID's are:"
      Previous2_ID "and " Previous_ID / 
      @5 "Missing record is number " _n_;
   else if notdigit(trimn(Patno)) then
      put "Invalid patient ID:" patno +(-1)
      ". Two previous ID's are:"
      Previous2_ID "and " Previous_ID / 
      @5 "Invalid record is number " _n_;
run;

*7-5;
title "Data listing for patients with Missing or Invalid ID's";
proc print data=Clean.Patients;
   where missing(Patno) or notdigit(trimn(Patno));
run;

*7-6;
title "Listing of Missing Values and Summary of Frequencies";
data _null_;
   set Clean.Patients(keep= Patno Visit HR Gender Dx) end=Last;
   file print; ***Send output to the output window;
   if missing(Visit) then do;
      put "Missing or invalid visit date for ID " Patno;
      N_visit + 1;
   end;
   if missing(HR) then do;
      put "Missing or invalid HR for ID " Patno;
      N_HR + 1;
   end;
   if missing(Gender) then do;
      put "Missing Gender for ID " Patno;
      N_Gender + 1;
   end;
   if missing(Dx) then do;
      put "Missing Dx for ID " Patno;
      N_Dx + 1;
   end;
if Last then
           put // "Summary of missing values" /
           25*'-' /
           "Number of missing dates = " N_Visit /
           "Number of missing HR's = " N_HR /
           "Number of missing genders = " N_Gender /
           "Number of missing Dx = " N_Dx;
run;

*7-7;
***Create test data set;
data Test;
   input X Y A $ X1-X3 Z $;
datalines;
1 2 X 3 4 5 Y
2 999 Y 999 1 999 J
999 999 R 999 999 999 X
1 2 3 4 5 6 7
;

*7-8;
***Program to detect the specified values;
title "Looking for Values of 999 in Data Set Test";
data _null_;
   set Test;
   file print;
   array Nums[*] _numeric_;
   length Varname $ 32;
   do iii = 1 to dim(Nums);
      if Nums[iii] = 999 then do;
         Varname = vname(Nums[iii]);
         put "Value of 999 found for variable " Varname
             "in observation " _n_;
      end;
   end;
   drop iii;
run;

*7-9;
*Macro name: Find_Value.sas
Purpose: Identifies any specified value for all numeric variables
Calling arguments: dsn=   sas data set name
                   value= numeric value to search for
Example:  To find variable values of 999 in data set Test, use          
          %Find_Value(dsn=Test, Value=999);
%macro Find_Value(Dsn=,  /* The data set name */
                  Value= /* Value to look for */ );
   title "Variables with &Value as Missing Values in Data Set &Dsn";
   data Tmp;
      set &Dsn;
      file print;
      length Varname $ 32;
      array Nums[*] _numeric_;
      do iii = 1 to dim(Nums);
         if Nums[iii] = &Value then do;
         Varname = vname(Nums[iii]);
         output;
         end;
      end;
      keep Varname;
   run;
   proc freq data=Tmp;
      tables Varname / out=Summary(keep=Varname Count)
                       nocum;
   run;
   proc datasets library=Work nolist;
      delete Tmp;
   run;
   quit;
%mend Find_Value;

%Find_Value(dsn=Test, Value=999)

*7-10;
data Set_999_to_Missing;
   set Test;
   array Nums[*] _numeric_;
   do iii = 1 to dim(Nums);
      if Nums[iii] = 999 then Nums[iii] = .;
   end;
   drop iii;
run;

*8-1;
title "Dates Before January 1, 2010 or After April 15, 2017";
data _null_;
   file print;
   set Clean.Patients(keep=Visit Patno);
   if Visit lt '01Jan2010'd and not missing(Visit) or
      Visit gt '15Apr2017'd then put Patno= Visit= mmddyy10.;
run;

*8-2;
title "Dates Before January 1, 2010 or After April 15, 2017";
proc print data=Clean.Patients(keep=Patno Visit) noobs;
   where Visit not between '01Jan2010'd and '15Apr2017'd and 
   Visit is not missing;
   format Visit date9.;
run;

*8-3;
data Dates;
   infile "c:\Books\Clean3\Patients.txt";
   input @12 Visit mmddyy10.;
   format Visit mmddyy10.;
run;

*8-4;
title "Listing of Missing and Invalid Dates";
data _null_;
   file print;
   infile "c:\Books\Clean3\Patients.txt";
   input @1  Patno $3.
         @12 Visit mmddyy10.
         @12 Char_Date $char10.;
   if missing(Visit) then put Patno= Char_date=;
run;

*8-5;
title "Listing of iInvalid Dates";
data _null_;
   file print;
   infile "c:\Books\Clean3\patients.txt";
   input @1  Patno $3.
         @12 Visit mmddyy10.
         @12 Char_Date $char10.;
   if missing(Visit) and not missing(Char_Date) then 
      put Patno= Char_Date=;
run;

*8-6;
data Nonstandard;
   input Patno $ 1-3 Month 6-7 Day 13-14 Year 20-23;
   Date = mdy(Month,Day,Year);
   format date mmddyy10.;
datalines;
001  05     23     1998
006  11     01     1998
123  14     03     1998
137  10            1946
;
title "Listing of data set Nonstandard";
proc print data=Nonstandard;
   id Patno;
run;

*8-7;
data No_Day;
   input @1  Date1 monyy7. 
         @8  Month 2. 
         @10 Year 4.;
   Date2 = mdy(Month,15,Year);
   format Date1 Date2 mmddyy10.;
datalines;
JAN98  011998
OCT1998101998
;
title "Listing of data set No_Day";
proc print data=No_Day;
run;

*8-8;
data Miss_Day;
   input @1  Patno  $3.
         @4  Month   2.
         @6  Day     2.
         @8  Year    4.;
   if not missing(Day) then Date = mdy(Month,Day,Year);
   else Date = mdy(Month,15,Year);
   format Date mmddyy10.;
datalines;
00110211998
00205  1998
00344  1998
;
title "Listing of data set Miss_Day";
proc print data=Miss_Day;
run;

*8-9;
data Miss_Day;
   input @1  Patno  $3.
         @4  Month   2.
         @6  Day     2.
         @8  Year    4.;
   Date = mdy(Month,coalesce(Day,15),Year);
   format Date mmddyy10.;
datalines;
00110211998
00205  1998
00344  1998
;

*8-10;
data Dates;
   infile "c:\Books\Clean3\Patients.txt";
   input @12 Visit ?? mmddyy10.;
   format Visit mmddyy10.;
run;

*9-1;
proc sort data=Clean.Patients out=Single nodupkey;
   by Patno;
run;

title "Data Set Single - Duplicated ID's Removed from Patients";
proc print data=Single;
   id Patno;
run;

*9-2;
proc sort data=Clean.Patients out=Single noduprecs;
   by Patno;
run;

*9-3;
*First, a program to create the data set Multiple;
data Multiple;
   input ID $ X Y;
datalines;
001 1 2
006 1 2
009 1 2
001 3 4
001 1 2
009 1 2
001 1 2
;
proc sort data=Multiple out=Strange noduprecs;
   by ID;
run;
title "Listing of Data Set Strange";
proc print data=Strange noobs;
run;

*9-4;
data Clean.Clinic_Visits;
   informat ID $3. Date mmddyy10.;
   input ID Date HR SBP DBP;
   format Date date9.;
datalines;
001 11/11/2016 80 120 76
001 12/24/2016 78 122 78
002 1/3/2017 66 140 88
003 2/2/2017 80 144 94
003 3/2/2017 78 140 90
003 4/2/2017 78 134 78
004 11/15/2016 66 118 78
004 11/15/2016 64 116 76
005 1/5/2017 72 132 82
005 3/15/2017 74 134 84
;
title Listing of Data Set Clinic_Visits;
proc print data=Clean.Clinic_Visits;
   id ID;
run;

*9-5;
proc sort data=Clean.Clinic_Visits;
   by ID Date;
run;
title "Examining First.ID and Last.ID";
data Clinic_Visits;
   set Clean.Clinic_Visits;
   by ID;
   file print;
   put @1 ID= @10 Date= @25 First.ID= @38 Last.ID=;
run;

*9-6;
proc sort data=Clean.Patients out=Tmp;
   by Patno;
run;
data Duplicates;
   set Tmp;
   by Patno;
   if First.Patno and Last.Patno then delete;
run;

*9-7;
proc freq data=clean.patients noprint;
   tables Patno / out=Duplicates(keep=Patno Count
                             where=(Count gt 1));
run;

*9-8;
proc sort data=Clean.Patients out=Tmp;
   by Patno;
run;
proc sort data=Duplicates;
   by Patno;
run;
data Duplicate_Obs;
   merge Tmp Duplicates(in=In_Duplicates drop=Count);
   by Patno;
   if In_Duplicates;
run;

*9-9;
proc sort data=Clean.Clinic_Visits;
   by ID Date;
run;
title "Examining First. and Last. Variables with Two BY Variables";
data Clinic_Visits;
   set Clean.Clinic_Visits;
   by ID Date;
   file print;
   put @1 ID= @8 Date= @24 First.ID= @36 Last.ID=
       @48 First.Date= @62 Last.Date=;
run;

*9-10;
proc sort data=Clean.Clinic_Visits;
   by ID Date;
run;
title "Patient with Two Visits on the Same Date";
data Duplicate_Dates;
   set Clean.Clinic_Visits;
   by ID Date;
   if First.Date and Last.Date then delete;
run;

*9-11;
proc sort data=Clean.Clinic_Visits(keep=ID) out=Tmp;
   by ID;
run;
title "Patient ID's for patients with other than two observations";
data _null_;
   file print;
   set Tmp;  
   by ID;
   if First.ID then n = 0;
   n + 1;
   if last.ID and n ne 2 then put  
      "Patient number " ID "has " n "observation(s).";
run;

*9-12;
proc freq data=Clean.Clinic_Visits noprint;   
   tables ID / out=Duplicates(keep=ID Count
                             where=(Count ne 2));   
run;
title "Patient ID's for Patients with Other than Two Observations";
proc print data=Duplicates noobs;
run;

*10-1;
data One;
   input Patno x y;
datalines;
1 69 79
2 56 .
3 66 99
5 98 87
12 13 14
;
data Two;
   input Patno z;
datalines;
1 56
3 67
4 88
5 98
13 99
;

*10-2;
proc sort data=One;
   by Patno;
run;

proc sort data=Two;
   by Patno;
run;

title "Listing of Missing ID's";
data _null_;
   file print;
   merge one(in=In_One)
         two(in=In_Two)  end=Last;
   by Patno;
   if not In_One then do;
      put "ID " Patno "is not in data set One";
      n + 1;
   end;
   else if not In_Two then do; 
      put "ID " Patno "is not in data set Two";
      n + 1;
   end;

   if Last and n eq 0 then
      put "All ID's match in both files";
run;

*10-3;
data Three;
   input Patno Gender $;
datalines;
1 M 
2 F 
3 M 
5 F 
6 M 
12 M
13 M
;

*10-4;
proc sort data=one(keep=Patno) out=Tmp1;
   by Patno;
run;
proc sort data=two(keep=Patno) out=Tmp2;
   by Patno;
run;
proc sort data=three(keep=Patno) out=Tmp3;
   by Patno;
run;
title "Listing of missing ID's and data set names";
data _null_;
   file print;
   merge Tmp1(in=In_Tmp1)
         Tmp2(in=In_Tmp2)
         Tmp3(in=In_Tmp3)  end=Last;
   by Patno;
   if not In_Tmp1 then do;
      put "ID " Patno "missing from data set One";
      n + 1;
   end;
   if not In_Tmp2 then do;
      put "ID " Patno "missing from data set Two";
      n + 1;
   end;
   if not In_Tmp3 then do;
      put "ID " Patno "missing from data set Three";
      n + 1;
   end;
   if Last and n eq 0 then
      put "All id's match in all files";

run;

*10-5;
*Program Name: Check_ID.sas
 Purpose: Macro which checks if an ID exists in each of n files
 Arguments: The name of the ID variable, followed by as many
            data sets names as desired, separated by BLANKS 
 Example: %Check_ID(ID = Patno,
                    Dsn_list=One Two Three);
%macro Check_ID(ID=,       /* ID variable              */
                Dsn_list=  /* List of data set names,  */
                           /* separated by spaces      */);
   %do i = 1 %to 99;
     /* break up list into data set names */
      %let Dsn = %scan(&Dsn_list,&i,' ');  
      %if &Dsn ne %then %do; /* If non null data set name       */
         %let n = &i;        /* When you leave the loop, n will */
                             /* be the number of data sets      */
         proc sort data=&Dsn(keep=&ID) out=Tmp&i;
            by &ID;
         run;
      %end;
   %end;
   title  "Report of data sets with missing ID's";
   data _null_;
      file print;
      merge
      %do i = 1 %to &n;
         Tmp&i(in=In_Tmp&i)
      %end;
      end=Last;
      by &ID;
      if Last and n eq 0 then do;
         put "All ID's Match in All Files";
         stop;
      end;
      %do i = 1 %to &n;
         %let Dsn = %scan(&Dsn_list,&i);
         if not In_Tmp&i then do;
            put "ID " &ID "missing from data set &dsn";
            n + 1;
         end;
      %end;
      run;
%mend Check_ID;

%check_ID(ID=Patno, Dsn_List=One Two Three)

*11-1;
data One;
   infile "c:\Books\Clean3\File_1.txt" truncover;
   input @1  Patno  3.
         @4  Gender $1.
         @5  DOB    mmddyy8.
         @13 SBP    3.
         @16 DBP    3.;
   format DOB mmddyy10.;
run;
data Two;
   infile "c:\Books\Clean3\File_2.txt" truncover;
   input @1  Patno  3.
         @4  Gender $1.
         @5  DOB    mmddyy8.
         @13 SBP    3.
         @16 DBP    3.;
   format DOB mmddyy10.;
run;

*11-2;
title "Using PROC COMPARE to Compare Two Data Sets";
proc compare base=One compare=Two;
   id Patno;
run;

*11-3;
title "Using PROC COMPARE to Compare Two Data Sets";
proc compare base=One compare=Two brief transpose;
   id Patno;
run;

*11-4;
data One;
   infile "c:\Books\Clean3\File_1.txt" truncover;
   input @1  Patno  $char3.
         @4  Gender $char1.
         @5  DOB    $char8.
         @13 SBP    $char3.
         @16 DBP    $char3.;
run;
data Two;
   infile "c:\Books\Clean3\File_2.txt" truncover;
   input @1  Patno  $char3.
         @4  Gender $char1.
         @5  DOB    $char8.
         @13 SBP    $char3.
         @16 DBP    $char3.;
run;
title "Using PROC COMPARE to Compare Two Data Sets";
proc compare base=One compare=Two brief transpose;
   id Patno;
run;

*12-1;
*Do not run, incomplete program;
*This program corrects errors in the Patients data set;
data Clean.Patients_01Jan2017;
   set Clean.Patients;
   ***Change lowercase values to uppercase;
   array Char_Vars[4] Patno Accoubt_No Gender Dx;
   do i = 1 to 4;
      Char_Vars[i] = upcase(Char_Vars[i]);
   end;
   if Patno = '003' then SBP = 110;
   else if Patno = '011' then Dx = '530.100';
   else if Patno ='023' then do;
      SBP = 146;
      DBP = 98;
   end;
   else if Patno = '034' then HR = 80;
***and so forth;
   drop i;
run;

*12-2;
data Named;
   length Char $ 3;
   informat Date mmddyy10.;
   input x=
         y=
         Char=
         Date=;
datalines;
x=3 y=4 Char=abc Date=10/21/2010
y=7
Date=11/12/2016 Char=xyz x=9
;

*12-3;
data Corrections_01Jan2017;
   length Patno $ 3 
          Account_No Dx $ 7
          Gender $ 1;
   informat Visit mmddyy10.;
   format Visit date9.;
   input Patno=
         Account_No=
         Gender=
         Visit=
         HR=
         SBP=
         DBP=
         Dx=
         AE=;
datalines;
Patno=003 SBP=110
Patno=023 SBP=146 DBP=98
Patno=027 Gender=F
Patno=039 Account_No=NJ34567
Patno=041 Account_No=CT13243
Patno=045 HR=90
;

*12-4;
data Inventory;
   length PartNo $ 3;
   input PartNo $ Quantity Price;
datalines;
133 200 10.99
198 105 30.00
933 45 59.95
;
data Transaction;
   length PartNo $ 3;
   input Partno=
         Quantity=
         Price=;
datalines;
PartNo=133 Quantity=195
PartNo=933 Quantity=40 Price=69.95
;
proc sort data=Inventory;
   by Partno;
run;
proc sort data=Transaction;
   by PartNo;
run;
data Inventory_22Feb2017;
   update Inventory Transaction;
   by Partno;
run;

*12-5;
data Corrections_01Jan2017;
   length Patno $ 3 
          Account_No Dx $ 7
          Gender $ 1;
   informat Visit mmddyy10.;
   ***Note: The MMDDYY10. format is used here to be compatible
      with the original file;
   format Visit mmddyy10.;
   input Patno=
         Account_No=
         Gender=
         Visit=
         HR=
         SBP=
         DBP=
         Dx=
         AE=;
datalines;
Patno=003 SBP=110
Patno=009 Visit=03/15/2015
Patno=011 Dx=530.100
Patno=016 Visit=10/21/2016
Patno=023 SBP=146 DBP=98
Patno=027 Gender=F
Patno=039 Account_No=NJ34567
Patno=041 Account_No=CT13243
Patno=045 HR=90
Patno=050 HR=32
Patno=055 Gender=M
Patno=058 Gender=M
Patno=088 Gender=F
Patno=094 Dx=023.000
Patno=095 Gender=F
Patno=099 DBP=60
;
proc sort data= Corrections_01Jan2017;
   by Patno;
run;

*12-6;
*First remove the duplicate observation in the Patients data set
 before performing the update;
proc sort data=Clean.Patients out=Patients_No_Duprecs noduprecs;
   by Patno;
run;
*Next fix the two patients with the same value of Patno but with
 different data.  Also correct the incorrect patient number 'XX5' and the missing patient number;
data Fix_Incorrect_Patno;
   set Patients_No_Duprecs;
   ***Correct duplicate patient numbers;
   if Patno='007' and Account_no='NJ90043' then Patno='102';
   else if Patno='050' and Account_No='NJ87682' then Patno='103';
   ***Correct incorrect and missing patient numbers;
   if Patno='XX5' then Patno='101';
   ***There was only one missing patient number;
   if missing(Patno) then Patno='104';
run;
proc sort data=Fix_Incorrect_Patno;
   by Patno;
run;

*12-7;
*Using the transaction data set to correct errors in the original data set Fix_Incorrect_Patno;
data Clean.Patients_02Jan2017;
   update Fix_Incorrect_Patno Corrections_01Jan2017;
   by Patno;
   *Upcase all character variables;
   array Char_Vars[4] Patno Accoubt_No Gender Dx;
   do i = 1 to 4;
      Char_Vars[i] = upcase(Char_Vars[i]);
   end;
   drop i;
run;
title "Listing of Data Set Clean.Patients_02Jan2017";
proc print data=Clean.Patients;
   id Patno;
run; 

*13-1;
data Health;
   informat Patno $3. Gender $1.;
   input Patno Gender HR SBP DBP;
datalines;
001 M  88 140  80
002 F  84 120  78
003 M  58 112   .
004 F  66 200 120
007 M  88 148 102
015 F  82 148  88
;

*13-2;
proc datasets library=Work nolist;
   modify Health;
   ic create Gender_Chk = check
      (where=(Gender in('F','M')));
   ic create HR_Chk = check
      (where=(HR between 40 and 100));
   ic create SBP_Chk = check
      (where=(SBP between 50 and 240 or SBP is missing));
   ic create DBP_Chk = check
      (where=(DBP between 35 and 130 or DBP is missing));
   ic create ID_Chk = primary key(Patno);
run;
quit;

*13-3;
data New;
   input Patno : $3. Gender : $1. HR SBP DBP;
datalines;
456 M 66 98 72
567 F 150 130 80
003 M 70 134 86
123 F 66 10 80
013 X . 120 90
;

*13-4;
proc append base=Health data=New;
run;

*13-5;
proc datasets library=Work nolist;
   modify Health;
   ic create Gender_Chk = check
      (where=(Gender in('F','M')))
      message="Gender must be F or M" 
      msgtype=user;
   ic create HR_Chk = check
      (where=(HR between 40 and 100))
      message="HR must be between 40 and 100"
      msgtype=user;
   ic create SBP_Chk = check
      (where=(SBP between 50 and 240 or SBP is missing))
      message="SBP must be between 50 and 240 or missing"
      msgtype=user;
   ic create DBP_Chk = check
      (where=(DBP between 35 and 130 or DBP is missing))
      message="DBP must be between 35 and 130 or missing"
      msgtype=user;
   ic create ID_Chk = primary key (Patno)
      message="Patno must be unique and non-missing"
      msgtype=user;
run;
quit;

*13-6;
proc datasets library=Work nolist;
   modify Health;
   ic delete Gender_Chk;
run;
quit;

*13-7;
proc datasets library=Work nolist;
   audit Health;
   initiate;
run;
quit;

*13-8;
title "Listing of the Audit Trail Data Set";
proc print data=Health(type=audit) noobs;
run;

*13-9;
title "Integrity Constraint Violations";
proc report data=Health(type=audit);
   where _ATOPCODE_ in ('EA' 'ED' 'EU');
   columns Patno Gender HR SBP DBP _ATMESSAGE_;
   define Patno / order "Patient Number" width=7;
   define Gender / display width=6;
   define HR / display "Heart Rate" width=5;
   define SBP / display width=3;
   define DBP / display width=3;
   define _atmessage_ / display "_IC Violation_" 
                        width=30 flow;
run;

*13-10;
data Correct_Audit;
   set Health(type=Audit 
              where=(_ATOPCODE_ in ('EA' 'ED' 'EU')));
   if Patno = '003' then Patno = '103';
   else if Patno = '013' then do;
      Gender = 'F';
      HR = 88;
   end;
   else if Patno = '123' then SBP = 100;
   else if Patno = '567' then HR = 87;
   drop _AT: ;
run;
proc append base=Health data=Correct_Audit;
run;

*13-11;
data Survey;
   length ID $ 3;
   retain ID ' ' TimeTV TimeSleep TimeWork TimeOther .;
   stop;
run;

*13-12;
proc datasets library=Work nolist;
   modify Survey;
   ic create ID_check = primary key(ID)
      message = "ID must be unique and non-missing"
      msgtype = user;
   ic create TimeTV_max = check(where=(TimeTV le 100))
      message = "TimeTV must not be over 100"
      msgtype = user;
   ic create TimeSleep_max = check(where=(TimeSleep le 100))
      message = "TimeSleep must not be over 100"
      msgtype = user;
   ic create TimeWork_max = check(where=(TimeWork le 100))
      message = "TimeWork must not be over 100"
      msgtype = user;
   ic create TimeOther_max = check(where=(TimeOther le 100))
      message = "TimeOther must not be over 100"
      msgtype = user;
   ic create Time_total = 
      check(where=(sum(TimeTV,TimeSleep,TimeWork,TimeOther) le 100))
      message = "Total percentage cannot exceed 100%"
      msgtype = user;
run;
   audit Survey;
   initiate;
run;
quit;

*13-13;
data Add;
   length ID $ 3;
   input ID $ TimeTV TimeSleep TimeWork TimeOther;
datalines;
001 10 40 40 10
002 20 50 40 5
003 10 . . .
004 0 40 60 0
005 120 10 10 10
;
proc append base=Survey data=Add;
run;
title "Integrity Constraint Violations";
proc report data=survey(type=audit);
   where _ATOPCODE_ in ('EA' 'ED' 'EU');
   columns ID TimeTV TimeSleep TimeWork TimeOther _ATMESSAGE_;
   define ID / order "ID Number" width=7;
   define TimeTV / display "Time spent watching TV" width=8;
   define TimeSleep / display "Time spent sleeping" width=8;
   define TimeWork / display "Time spent working" width=8;
   define TimeOther / display "Time spent in other activities" 
                      width=10;
   define _atmessage_ / display "_Error Report_" 
                        width=30 flow;
run;

*13-14;
data Master_List;
   informat FirstName LastName $12. DOB mmddyy10. Gender $1.;
   input FirstName LastName DOB Gender;
   format DOB mmddyy10.;
datalines;
Julie Chen 7/7/1988 F
Nicholas Schneider 4/15/1966 M
Joanne DiMonte 6/15/1983 F
Roger Clement 9/11/1988 M
;
data Salary;
   informat FirstName LastName $12. Salary comma10.;
   input FirstName LastName Salary;
datalines;
Julie Chen $54,123
Nicholas Schneider $56,877
Joanne DiMonte $67,800
Roger Clement $42,000
;
title "Listing of Master List";
proc print data=Master_List;
run;
title "Listing of Salary";
proc print data=Salary;
run;
proc datasets library=Work nolist;
   modify Master_List;
   ic create Prime_Key = primary key (FirstName LastName);
   ic create Gender_Chk = check(where=(Gender in ('F','M')));
run;
   modify Salary;
   ic create Foreign_Key = foreign key (FirstName LastName) 
      references Master_List 
      on delete restrict on update restrict;
   ic create Salary_Chk = check(where=(Salary le 90000));
run;
quit;

*13-15;
*Attempt to delete an observation in the Master_List;
data Master_List;
   modify Master_List;
   if FirstName = 'Joanne' and LastName = 'DiMonte' then remove;
run;
title "Listing of Master_List";
proc print data=Master_List;
run;

*13-16;
data Add_Name;
   informat FirstName LastName $12. Salary comma10.;
   input FirstName LastName Salary;
   format Salary dollar9.;
datalines;
David York 77,777
;
proc append base=Salary data=Add_Name;
run;

*13-17;
*delete prior referential integrity constraint;
*Note: Foreign key must be deleted before the primary key can be deleted;
proc datasets library=Work nolist;
   modify salary;
   ic delete Foreign_Key;
run;
   modify Master_List;
   ic delete Prime_Key;
run;
quit;

*13-18;
proc datasets library=Work nolist;
   modify Master_List;                                                                                                                      
   ic create prime_key = primary key (FirstName LastName);
run;
   modify Salary;
   ic create foreign_key = foreign key (FirstName LastName) 
      references Master_List 
   on delete RESTRICT on update CASCADE;
run;
quit;
data Master_List;
   modify Master_List;
   if FirstName = 'Roger' and LastName = 'Clement' then 
      LastName = 'Cody';
run;
title "Master List";
proc print data=Master_List;
run;
title "Salary";
proc print data=Salary;
run;

*13-19;
proc datasets library=Work nolist;
   modify Master_List;                                                                                                                      
   ic create primary key (FirstName LastName);
run;
   modify Salary;
   ic create foreign key (FirstName LastName) references Master_List 
   on delete SET NULL on update CASCADE;
run;
quit;
data Master_List;
   modify Master_List;
   if FirstName = 'Roger' and LastName = 'Clement' then
      remove;
run;
title "Master List";
proc print data=Master_List;
run;
title "Salary";
proc print data=Salary;
run;

*Note: Each of the macros in this chapter are followed by sample 
 calling sequencies;

*14-1;
%macro Test_Regex(Regex=, /*Your regular expression*/
                  String= /*The string you want to test*/);
   data _null_;
      file print;
      put "Regular Expression is: &Regex " /
          "String is: &String";
      Position = prxmatch("&Regex","&String");
      if position then put "Match made starting in position " Position;
      else put "No match";
   run;
%Mend Test_Regex;

%Test_Regex(Regex=/cat/,String=there is a cat there)
%Test_Regex(Regex=/([A-Za-z]\d){3}\b/, String=a1b2c3)
%Test_Regex(Regex=/([A-Za-z]\d){3}\b/, String=1a2b3c)

*14-2;
*Macro Name: HighLow
Purpose: To list the "n" highest and lowest values
Arguments: Dsn     - Data set name (one- or two-level)
           Var     - Variable to list
           IDvar   - ID variable
           N       - Number of values to list (default = 10)
example: %HighLow(Dsn=Clean.Patients,
                  Var=HR,
                  IDvar=Patno,
                  N=7)
;
%macro HighLow(Dsn=,     /* Data set name            */
               Var=,     /* Variable to list         */
               IDvar=,   /* ID Variable              */
               N=10      /* Number of high and low
                            values to list.
                            The default number is 10 */);
   proc sort data=&Dsn(keep=&IDvar &Var
                       where=(&Var is not missing))
                       out=Tmp;
      by &Var;
   run;
   data _null_;
      if 0 then set Tmp nobs=Number_of_Obs;
      High = Number_of_Obs - %eval(&N - 1);
      call symputx('High_Cutoff',High);
      stop;
   run;
   title "&N Highest and Lowest Values for &Var";
   data _null_;
   set Tmp(obs=&N)                 /* 'n' lowest values  */
       Tmp(firstobs=&High_Cutoff); /* 'n' highest values */
   file print;
   if _n_ le &N then do;
      if _n_ = 1 then put / "&N Lowest Values";
      put "Patno = " &IDvar @15 "Value = " &Var;
   end;
   else if _n_ ge %eval(&N + 1) then do;
      if _n_ = %eval(&N + 1) then put / "&N Highest Values";
      put "&IDvar = " &IDvar @15 "Value = " &Var;
   end;
   run;
   proc datasets library=work nolist;
      delete Tmp;
   run;
   quit;
%mend HighLow;

%HighLow(Dsn=Clean.Patients,
         Var=HR,
         IDvar=Patno,
         N=7)

*14-3;
*---------------------------------------------------------------*
| Program Name: HighLowPcnt.sas                                 |
| Purpose: To list the n percent highest and lowest values for  |
|          a selected variable.                                 |
| Arguments: Dsn     - Data set name                            |
|            Var     - Numeric variable to test                 |
|            Percent - Upper and Lower percentile cutoff        |
|            Idvar   - ID variable to print in the report       |
| Example: %HighLowPcnt(Dsn=clean.patients,                     |
|                       Var=SBP,                                |
|                       Percent=5,                              |
|                       Idvar=Patno)                            |
*---------------------------------------------------------------*;
%macro HighLowPcnt(Dsn=,  /* Data set name                     */
                Var=,     /* Variable to test                  */
                Percent=, /* Upper and lower percentile cutoff */
                Idvar=    /* ID variable                       */);
   ***Compute upper percentile cutoff;
   %let Upper = %eval(100 - &Percent);
   proc univariate data=&Dsn noprint;
      var &Var;
      id &Idvar;
      output out=Tmp pctlpts=&Percent &Upper pctlpre = Percent_;
   run;
   data HiLow;
      set &Dsn(keep=&Idvar &Var);
      if _n_ = 1 then set Tmp;
      if &Var le Percent_&Percent and not missing(&Var) then do;
         range = 'Low ';
         output;
      end;
      else if &Var ge Percent_&Upper then do;
         range = 'High';
         output;
      end;
   run;
   proc sort data=HiLow;
      by &Var;
   run;
   title "Highest and Lowest &Percent% for Variable &var";
   proc print data=HiLow;
      id &Idvar;
      var Range &Var;
   run;
   proc datasets library=work nolist;
     delete Tmp HiLow;
   run;
   quit;
%mend HighLowPcnt;

%HighLowPcnt(Dsn=Clean.Banking,
             Var=Deposit,
             Percent=10,
             Idvar=Account)

*14-4;
*Program Name: Errors.Sas
 Purpose: Accumulates errors for numeric variables in a SAS
         data set for later reporting/
         This macro can be called several times with a
         different variable each time. The resulting errors
         are accumulated in a temporary SAS data set called
         errors.
*Macro variables Dsn and IDvar are set with %Let statements before
 the macro is run;
%macro Errors(Var=,    /* Variable to test     */
              Low=,    /* Low value            */
              High=,   /* High value           */
              Missing=ignore 
                       /* How to treat missing values         */
                       /* Ignore is the default.  To flag     */
                       /* missing values as errors set        */
                       /* Missing=error                       */);
data Tmp;
   set &Dsn(keep=&Idvar &Var);
   length Reason $ 10 Variable $ 32;
   Variable = "&Var";
   Value = &Var;
   if &Var lt &Low and not missing(&Var) then do;
      Reason='Low';
      output;
   end;
   %if %upcase(&Missing) ne IGNORE %then %do;
   else if missing(&Var) then do;
      Reason='Missing';
      output;
   end;
   %end;
   else if &Var gt &High then do;
        Reason='High';
      output;
      end;
      drop &Var;
   run;
   proc append base=errors data=Tmp;
   run;
%mend errors;

%macro report;
   proc sort data=Errors;
      by &Idvar;
   run;
   proc print data=errors;
   title "Error Report for Data Set &Dsn";
      id &Idvar;
      var Variable Value Reason;
   run;
   proc datasets library=work nolist;
      delete errors;
      delete tmp;
   run;
   quit;
%mend report;

%let Dsn=Clean.Patients; 
%let IDvar = Patno;
%Errors(Var=HR, Low=40, High=100, Missing=error)
%Errors(Var=SBP, Low=50, High=240, Missing=ignore)
%Errors(Var=DBP, Low=35, High=130)
***Generate the report;
%report

*14-5;
*Method using automatic outlier detection;
%macro Auto_Outliers(
   Dsn=,      /* Data set name                        */
   ID=,       /* Name of ID variable                  */
   Var_list=, /* List of variables to check           */
              /* separate names with spaces           */
   Trim=.1,   /* Integer 0 to n = number to trim      */
              /* from each tail; if between 0 and .5, */
              /* proportion to trim in each tail      */
   N_sd=2     /* Number of standard deviations        */);
   ods listing close;
   ods HTML close;
   ods output TrimmedMeans=Trimmed(keep=VarName Mean Stdmean DF);
   proc univariate data=&Dsn trim=&Trim;
     var &Var_list;
   run;
   ods output close;
   data Restructure;
      set &Dsn;
      length VarName $ 32;
      array Vars[*] &Var_list;
      do i = 1 to dim(Vars);
         VarName = vname(Vars[i]);
         Value = Vars[i];
         output;
      end;
      keep &ID VarName Value;
   run;
   proc sort data=Trimmed;
      by VarName;
   run;
   proc sort data=restructure;
      by VarName;
   run;

   data Outliers;
      merge Restructure Trimmed;
      by VarName;
      Std = StdMean*sqrt(DF + 1);
      if Value lt Mean - &N_sd*Std and not missing(Value) 
         then do;
            Reason = 'Low  ';
            output;
         end;
      else if Value gt Mean + &N_sd*Std
         then do;
         Reason = 'High';
         output;
      end;
   run;
   proc sort data=Outliers;
      by &ID;
   run;
   ods listing;
   ods HTML;
   title "Outliers Based on Trimmed Statistics";
   proc print data=Outliers;
      id &ID;
      var VarName Value Reason;
   run;
   proc datasets nolist library=work;
      delete Trimmed;
      delete Restructure;
   run;
   quit;
%mend Auto_Outliers;

%Auto_Outliers(Dsn=Clean.Patients,
               Id=Patno,
               Var_List=HR SBP DBP,
               Trim=.1,
               N_Sd=2)

*14-6;
*Macro name: Find_Value.sas
Purpose: Identifies any specified value for all numeric variables
Calling arguments: dsn=   sas data set name
                   value= numeric value to search for
Example:  To find variable values of 999 in data set Test, use          
          %Find_Value(dsn=Test, Value=999);
%macro Find_Value(Dsn=,  /* The data set name */
                  Value= /* Value to look for */ );
   title "Variables with &Value as Missing Values in Data Set &Dsn";
   data Tmp;
      set &Dsn;
      file print;
      length Varname $ 32;
      array Nums[*] _numeric_;
      do iii = 1 to dim(Nums);
         if Nums[iii] = &Value then do;
         Varname = vname(Nums[iii]);
         output;
         end;
      end;
      keep Varname;
   run;
   proc freq data=Tmp;
      tables Varname / out=Summary(keep=Varname Count)
                       nocum;
   run;
   proc datasets library=Work nolist;
      delete Tmp;
   run;
   quit;
%mend Find_Value;

*Create a Test data set;
data Test;
   input Name $ x y z Gender $;
datalines;
Fred 1 2 3 M
Alice 999 4 999 F
Jane 8 999 9 F
Roger 10 20 30 M
Fred 999 23 24 M
;

%Find_Value(dsn=Test, Value=999)

*14-7;
*Program Name: Check_ID.sas
 Purpose: Macro which checks if an ID exists in each of n files
 Arguments: The name of the ID variable, followed by as many
            data sets names as desired, separated by BLANKS 
 Example: %Check_ID(ID = Patno,
                    Dsn_list=One Two Three);
%macro Check_ID(ID=,       /* ID variable              */
                Dsn_list=  /* List of data set names,  */
                           /* separated by spaces      */);
   %do i = 1 %to 99;
     /* break up list into data set names */
      %let Dsn = %scan(&Dsn_list,&i,' ');  
      %if &Dsn ne %then %do; /* If non null data set name       */
         %let n = &i;        /* When you leave the loop, n will */
                             /* be the number of data sets      */
         proc sort data=&Dsn(keep=&ID) out=Tmp&i;
            by &ID;
         run;
      %end;
   %end;
   title  "Report of data sets with missing ID's";
   data _null_;
      file print;
      merge
      %do i = 1 %to &n;
         Tmp&i(in=In_Tmp&i)
      %end;
      end=Last;
      by &ID;
      if Last and n eq 0 then do;
         put "All ID's Match in All Files";
         stop;
      end;
      %do i = 1 %to &n;
         %let Dsn = %scan(&Dsn_list,&i);
         if not In_Tmp&i then do;
            put "ID " &ID "missing from data set &dsn";
            n + 1;
         end;
      %end;
      run;
%mend Check_ID;

*Create data sets One, Two, and Three;

data One;
   input Patno x y;
datalines;
1 69 79
2 56 .
3 66 99
5 98 87
12 13 14
;
data Two;
   input Patno z;
datalines;
1 56
3 67
4 88
5 98
13 99
;
data Three;
   input Patno Gender $;
datalines;
1 M 
2 F 
3 M 
5 F 
6 M 
12 M
13 M
;

%check_ID(ID=Patno, Dsn_List=One Two Three)


