                                                                                                                                        
*===============Import Kaggle dataset==============*;                                                                                   
proc import datafile="C:\Users\HP\Documents\Customer churn dashboard project\archive\WA_Fn-UseC_-Telco-Customer-Churn.csv"              
out=churn_data                                                                                                                          
DBMS=CSV                                                                                                                                
REPLACE;                                                                                                                                
GETNAMES=YES;                                                                                                                           
RUN;                                                                                                                                    
                                                                                                                                        
*===============Verifying Kaggle dataset==============*;                                                                                
proc contents data=churn_data; run;                                                                                                     
proc print data=churn_data (OBS=10); run;                                                                                               
                                                                                                                                        
*===============Checking for missing values==============*;                                                                             
Proc means data=churn_data N NMISS;                                                                                                     
RUN;                                                                                                                                    
                                                                                                                                        
*===============Look at categorical distributions==============*;                                                                       
proc freq data=churn_data;                                                                                                              
tables Churn  Gender InternetService Contract PaymentMethod;                                                                            
run;                                                                                                                                    
                                                                                                                                        
*===============Inspect numeric ranges==============*;                                                                                  
proc UNIVARIATE data=churn_data;                                                                                                        
var MonthlyCharges TotalCharges Tenure;                                                                                                 
run;                                                                                                                                    
                                                                                                                                        
*=============================================Cleaning the dataset=======================================================*;             
                                                                                                                                        
*===============Fix TotalCharges==============*;                                                                                        
data churn_data_clean;                                                                                                                  
set churn_data;                                                                                                                         
                                                                                                                                        
/* Convert TotalCharges from character to numeric */                                                                                    
if TotalCharges = " "  then TotalCharges_num = .;                                                                                       
else TotalCharges_num = INPUT(TotalCharges,BEST12.);                                                                                    
run;                                                                                                                                    
                                                                                                                                        
/* Drop the old column and keep the numeric one */                                                                                      
data churn_data_clean;                                                                                                                  
set churn_data_clean;                                                                                                                   
drop TotalCharges;                                                                                                                      
Rename TotalCharges_num  = TotalCharges;                                                                                                
run;                                                                                                                                    
                                                                                                                                        
*===============Recode Churn==============*;                                                                                            
data churn_data_clean;                                                                                                                  
set churn_data_clean;                                                                                                                   
if Churn = "Yes" then Churn_flag = 1;                                                                                                   
else if Churn = "No" then Churn_flag = 0;                                                                                               
run;                                                                                                                                    
                                                                                                                                        
*===============Handle other missing values==============*;                                                                             
DATA churn_data_clean;                                                                                                                  
SET churn_data;                                                                                                                         
IF MISSING(TotalCharges) THEN DELETE;                                                                                                   
RUN;                                                                                                                                    
                                                                                                                                        
*===============Checking the data==============*;                                                                                       
PROC CONTENTS DATA=churn_data_clean; RUN;                                                                                               
PROC MEANS DATA=churn_data_clean N NMISS; RUN;                                                                                          
                                                                                                                                        
*=============================================Feature Engineering=======================================================*;              
                                                                                                                                        
*===============Feature 1: Tenure Groups==============*;                                                                                
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    LENGTH TenureGroup $12;                                                                                                             
    IF Tenure <= 12 THEN TenureGroup = "0-12 months";                                                                                   
    ELSE IF Tenure <= 24 THEN TenureGroup = "13-24 months";                                                                             
    ELSE IF Tenure <= 48 THEN TenureGroup = "25-48 months";                                                                             
    ELSE IF Tenure <= 72 THEN TenureGroup = "49-72 months";                                                                             
    ELSE TenureGroup = "73+ months";                                                                                                    
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES TenureGroup*Churn_flag / NOCOL NOPERCENT;                                                                                    
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 2: Average Charges per Month==============*;                                                                    
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    IF Tenure > 0 THEN AvgChargesPerMonth = TotalCharges / Tenure;                                                                      
    ELSE AvgChargesPerMonth = .;                                                                                                        
RUN;                                                                                                                                    
                                                                                                                                        
PROC UNIVARIATE DATA=churn_data_clean;                                                                                                  
    VAR AvgChargesPerMonth;                                                                                                             
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES AvgChargesPerMonth*Churn_flag;                                                                                               
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 3: InternetService Dummies==============*;                                                                      
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    IF InternetService = "DSL" THEN DSL_flag = 1; ELSE DSL_flag = 0;                                                                    
    IF InternetService = "Fiber optic" THEN Fiber_flag = 1; ELSE Fiber_flag = 0;                                                        
    IF InternetService = "No" THEN NoInternet_flag = 1; ELSE NoInternet_flag = 0;                                                       
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES InternetService*(DSL_flag Fiber_flag NoInternet_flag);                                                                       
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 4: Contract Type Flags==============*;                                                                          
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    IF Contract = "Month-to-month" THEN MonthToMonth_flag = 1; ELSE MonthToMonth_flag = 0;                                              
    IF Contract = "One year" THEN OneYear_flag = 1; ELSE OneYear_flag = 0;                                                              
    IF Contract = "Two year" THEN TwoYear_flag = 1; ELSE TwoYear_flag = 0;                                                              
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES Contract*(MonthToMonth_flag OneYear_flag TwoYear_flag);                                                                      
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES Contract*Churn_flag / NOCOL NOPERCENT;                                                                                       
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 5: Payment Method Grouping==============*;                                                                      
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    IF PaymentMethod IN ("Electronic check") THEN PaymentGroup = "Electronic";                                                          
    ELSE PaymentGroup = "Manual";                                                                                                       
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES PaymentGroup*Churn_flag / NOCOL NOPERCENT;                                                                                   
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 6: SeniorCitizen Flag==============*;                                                                           
/* Already numeric (0 = No, 1 = Yes), can be used directly */                                                                           
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES SeniorCitizen*Churn_flag / NOCOL NOPERCENT;                                                                                  
RUN;                                                                                                                                    
                                                                                                                                        
*===============Feature 7: Service Bundle Flag==============*;                                                                          
DATA churn_data_clean;                                                                                                                  
    SET churn_data_clean;                                                                                                               
    IF PhoneService="Yes" AND StreamingTV="Yes" AND StreamingMovies="Yes" THEN Bundle_flag = 1;                                         
    ELSE Bundle_flag = 0;                                                                                                               
RUN;                                                                                                                                    
                                                                                                                                        
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES Bundle_flag*Churn_flag / NOCOL NOPERCENT;                                                                                    
RUN;                                                                                                                                    
                                                                                                                                        
*===============Final Feature Summary==============*;                                                                                   
                                                                                                                                        
/* Check dataset structure */                                                                                                           
PROC CONTENTS DATA=churn_data_clean; RUN;                                                                                               
                                                                                                                                        
/* Check missing values */                                                                                                              
PROC MEANS DATA=churn_data_clean N NMISS; RUN;                                                                                          
                                                                                                                                        
/* Frequency checks for engineered features */                                                                                          
PROC FREQ DATA=churn_data_clean;                                                                                                        
    TABLES TenureGroup*Churn_flag / NOCOL NOPERCENT;                                                                                    
    TABLES AvgChargesPerMonth*Churn_flag;                                                                                               
    TABLES InternetService*(DSL_flag Fiber_flag NoInternet_flag);                                                                       
    TABLES Contract*(MonthToMonth_flag OneYear_flag TwoYear_flag);                                                                      
    TABLES Contract*Churn_flag / NOCOL NOPERCENT;                                                                                       
    TABLES PaymentGroup*Churn_flag / NOCOL NOPERCENT;                                                                                   
    TABLES SeniorCitizen*Churn_flag / NOCOL NOPERCENT;                                                                                  
    TABLES Bundle_flag*Churn_flag / NOCOL NOPERCENT;                                                                                    
RUN;                                                                                                                                    
                                                                                                                                        
PROC EXPORT DATA=churn_data_clean                                                                                                       
    OUTFILE="C:\Users\HP\Documents\Customer churn dashboard project\churn_data_clean.csv"                                               
    DBMS=CSV                                                                                                                            
    REPLACE;                                                                                                                            
RUN;
