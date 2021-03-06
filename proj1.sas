%web_drop_table(WORK.train);


FILENAME REFFILE '/folders/myshortcuts/StatsSAScode/Project/train_clean.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.train;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.train; RUN;


%web_open_table(WORK.train);

data train2;
set train;
log_price = log(SalePrice);
sqft_100 = GrLivArea/100;
if (id = 524 or id = 1299) then delete;
run;







/*Question1*/
data train;
set train;
if not (neighborhood eq 'NWAmes' or neighborhood eq 'Edwards' or neighborhood eq 'BrkSide')  then delete;
sqft_100 = GrLivArea/100;
if neighborhood eq 'NWAmes' then nwa = 1;
else nwa = 0;
if neighborhood eq 'Edwards' then edw = 1;
else edw = 0;
/* if (id = 524 or id = 1299) then delete; */
/* sqft_100 = GrLivArea/100; */
run;
proc sgplot data=train;
 reg x=sqft_100 y=SalePrice /group=neighborhood;
run;
proc sgscatter data = train;
  plot (sqft_100)* (SalePrice)/ group=neighborhood;
run;
proc glm data = train;
class neighborhood (ref= "NWAmes");
model SalePrice = sqft_100 | neighborhood / solution clparm;
run;
proc reg data=train;
model SalePrice = sqft_100 ;
run;
/*Deleting outliers*/
data train;
set train;
if (id = 524 or id = 1299) then delete;
run;
proc glm data = train;
class neighborhood (ref= "NWAmes");
model SalePrice = sqft_100 | neighborhood / solution clparm;
run;
proc reg data=train;
model SalePrice = sqft_100 ;
run;
/*Trying log transform*/
data train;
set train;
log_gla = log(sqft_100);
run;
proc glm data = train;
class neighborhood (ref= "NWAmes");
model SalePrice = log_gla | neighborhood / solution clparm;
run;
proc reg data=train;
model SalePrice = log_gla ;
run;



/* Preliminary check for outliers and faulty variables */
proc glm data=train2 plots=all;
class SaleCondition SaleType MiscFeature Fence PoolQC PavedDrive GarageCond GarageQual GarageFinish GarageType FireplaceQu Functional KitchenQual Electrical CentralAir HeatingQC Heating BsmtFinType2 BsmtFinType1 BsmtExposure BsmtCond BsmtQual Foundation ExterCond ExterQual MasVnrType Exterior2nd Exterior1st MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl ;
model SalePrice = MSSubClass	MSZoning	LotFrontage	LotArea	Street	Alley	LotShape	LandContour	Utilities	LotConfig	LandSlope	Neighborhood	Condition1	Condition2	BldgType	HouseStyle	OverallQual	OverallCond	YearBuilt	YearRemodAdd	RoofStyle	RoofMatl	Exterior1st	Exterior2nd	MasVnrType	MasVnrArea	ExterQual	ExterCond	Foundation	BsmtQual	BsmtCond	BsmtExposure	BsmtFinType1	BsmtFinSF1	BsmtFinType2	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	Heating	HeatingQC	CentralAir	Electrical	X1stFlrSF	X2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	KitchenQual	TotRmsAbvGrd	Functional	Fireplaces	FireplaceQu	GarageType	GarageYrBlt	GarageFinish	GarageCars	GarageArea	GarageQual	GarageCond	PavedDrive	WoodDeckSF	OpenPorchSF	EnclosedPorch	X3SsnPorch	ScreenPorch	PoolArea	PoolQC	Fence	MiscFeature	MiscVal	MoSold	YrSold	SaleType	SaleCondition;
OUTPUT COOKD=SalePrice;
run;



proc reg data=train2;
model SalePrice = GrLivArea / INFLUENCE;
run;

proc glm data=train2;
class SaleCondition SaleType MiscFeature Fence PoolQC PavedDrive GarageCond GarageQual GarageFinish GarageType FireplaceQu Functional KitchenQual Electrical CentralAir HeatingQC Heating BsmtFinType2 BsmtFinType1 BsmtExposure BsmtCond BsmtQual Foundation ExterCond ExterQual MasVnrType Exterior2nd Exterior1st MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl ;
model SalePrice = MSSubClass	MSZoning	LotFrontage	LotArea	Street	Alley	LotShape	LandContour	Utilities	LotConfig	LandSlope	Neighborhood	Condition1	Condition2	BldgType	HouseStyle	OverallQual	OverallCond	YearBuilt	YearRemodAdd	RoofStyle	RoofMatl	Exterior1st	Exterior2nd	MasVnrType	MasVnrArea	ExterQual	ExterCond	Foundation	BsmtQual	BsmtCond	BsmtExposure	BsmtFinType1	BsmtFinSF1	BsmtFinType2	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	Heating	HeatingQC	CentralAir	Electrical	X1stFlrSF	X2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	KitchenQual	TotRmsAbvGrd	Functional	Fireplaces	FireplaceQu	GarageType	GarageYrBlt	GarageFinish	GarageCars	GarageArea	GarageQual	GarageCond	PavedDrive	WoodDeckSF	OpenPorchSF	EnclosedPorch	X3SsnPorch	ScreenPorch	PoolArea	PoolQC	Fence	MiscFeature	MiscVal	MoSold	YrSold	SaleType	SaleCondition;
run;




/*Question2*/
/*trying fits*/
proc reg data = train2 plots=rsquare;
model SalePrice = GrLivArea LotArea YearBuilt YearRemodAdd YrSold/selection = forward slentry=0.15 adjrsq ;
run;
proc reg data = train2 plots=rsquare;
model SalePrice = GrLivArea LotArea YearBuilt YearRemodAdd YrSold/selection = backward slstay=0.15 adjrsq ;
run;
proc reg data = train2 plots=rsquare;
model SalePrice = GrLivArea LotArea YearBuilt YearRemodAdd MoSold GarageArea OverallQual/selection = stepwise slentry=0.15 slstay=0.15 adjrsq ;
run;
proc glmselect data = train2 plots(stepaxis = number) = (criterionpanel ASEplot);
class Neighborhood ExterQual BsmtQual KitchenQual OverallQual;
model SalePrice =  GrLivArea  TotalBsmtSF GarageCars GarageArea X1stFlrSF
                   |  Neighborhood | ExterQual | BsmtQual | KitchenQual | OverallQual
/selection = stepwise (select=PRESS stop=PRESS) cvmethod=random(5) stats=adjrsq;
/* output out = results p = predict; */
run;



/*prediction data import*/
%web_drop_table(WORK.train);


FILENAME REFFILE '/folders/myshortcuts/StatsSAScode/Project/train.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.train;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.train; RUN;


%web_open_table(WORK.train);


%web_drop_table(WORK.test);


FILENAME REFFILE '/folders/myshortcuts/StatsSAScode/Project/test.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.test;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.test; RUN;


%web_open_table(WORK.test);

data combo;
   set train test;
run;


data combo;
set combo;
if MSZoning = "NA" then MSZoning = "NZ";
if LotFrontage = "NA" then LotFrontage = 0;
if Alley = "NA" then Alley = "NL";
if Utilities = "NA" then Utilities = "NU";
if Exterior1st = "NA" then Exterior1st = "Other";
if Exterior2nd = "NA" then Exterior2nd = "Other";
if MasVnrType = "NA" then MasVnrType = "None";
if MasVnrArea = "NA" then MasVnrArea = 0;
if BsmtQual = "NA" then BsmtQual = "NB";
if BsmtCond = "NA" then BsmtCond = "NB";
if BsmtExposure = "NA" then BsmtExposure = "NB";
if BsmtFinType1 = "NA" then BsmtFinType1 = "NB";
if BsmtFinType2 = "NA" then BsmtFinType2 = "NB";
if BsmtFinSF1 = "NA" then BsmtFinSF1 = 0;
if BsmtFinSF2 = "NA" then BsmtFinSF2 = 0;
if BsmtUnfSF = "NA" then BsmtUnfSF = 0;
if TotalBsmtSF = "NA" then TotalBsmtSF = 0;
if BsmtFullBath = "NA" then BsmtFullBath = 0;
if BsmtHalfBath = "NA" then BsmtHalfBath = 0;
if KitchenQual = "NA" then KitchenQual = "NK";
if Functional = "NA" then Functional = "NH";
if Electrical = "NA" then Electrical = "NE";
if FireplaceQu = "NA" then FireplaceQu = "NF";
if GarageType = "NA" then GarageType = "NG";
if GarageYrBlt = "NA" then GarageYrBlt = 0;
if GarageFinish = "NA" then GarageFinish = "NG";
if GarageCars = "NA" then GarageCars = 0;
if GarageArea = "NA" then GarageArea = 0;
if GarageQual = "NA" then GarageQual = "NG";
if GarageCond = "NA" then GarageCond = "NG";
if PoolQC = "NA" then PoolQC = "NP";
if Fence = "NA" then Fence = "NF";
if MiscFeature = "NA" then MiscFeature = "NM";
if SaleType = "NA" then SaleType = "Other";
if (id = 524 or id = 1299) then delete;
run;







/* Computer Selection~~~~*/
/*forward selection*/
proc glmselect data = combo plots(stepaxis = number) = (criterionpanel ASEplot);
class SaleCondition SaleType MiscFeature Fence PoolQC PavedDrive GarageCond GarageQual GarageFinish GarageType FireplaceQu Functional KitchenQual Electrical CentralAir HeatingQC Heating BsmtFinType2 BsmtFinType1 BsmtExposure BsmtCond BsmtQual Foundation ExterCond ExterQual MasVnrType Exterior2nd Exterior1st MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl ;
model SalePrice = MSSubClass	MSZoning	LotFrontage	LotArea	Street	Alley	LotShape	LandContour	Utilities	LotConfig	LandSlope	Neighborhood	Condition1	Condition2	BldgType	HouseStyle	OverallQual	OverallCond	YearBuilt	YearRemodAdd	RoofStyle	RoofMatl	Exterior1st	Exterior2nd	MasVnrType	MasVnrArea	ExterQual	ExterCond	Foundation	BsmtQual	BsmtCond	BsmtExposure	BsmtFinType1	BsmtFinSF1	BsmtFinType2	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	Heating	HeatingQC	CentralAir	Electrical	X1stFlrSF	X2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	KitchenQual	TotRmsAbvGrd	Functional	Fireplaces	FireplaceQu	GarageType	GarageYrBlt	GarageFinish	GarageCars	GarageArea	GarageQual	GarageCond	PavedDrive	WoodDeckSF	OpenPorchSF	EnclosedPorch	X3SsnPorch	ScreenPorch	PoolArea	PoolQC	Fence	MiscFeature	MiscVal	MoSold	YrSold	SaleType	SaleCondition
/selection = Forwards (select=cv) cvmethod=random(5) stats=adjrsq;
output out = resultsf p = predict;
run;



data results_f;
set resultsf;
if Predict > 0 then SalePrice = Predict;
if Predict < 0 then SalePrice = 180932;
keep id SalePrice;
where id>1460;
;
proc export data=WORK.results_f
outfile='/folders/myshortcuts/StatsSAScode/Project/results_f.csv'
dbms=csv
replace;
run;

/*backward selection*/
proc glmselect data = combo plots(stepaxis = number) = (criterionpanel ASEplot);
class SaleCondition SaleType MiscFeature Fence PoolQC PavedDrive GarageCond GarageQual GarageFinish GarageType FireplaceQu Functional KitchenQual Electrical CentralAir HeatingQC Heating BsmtFinType2 BsmtFinType1 BsmtExposure BsmtCond BsmtQual Foundation ExterCond ExterQual MasVnrType Exterior2nd Exterior1st MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl ;
model SalePrice = MSSubClass	MSZoning	LotFrontage	LotArea	Street	Alley	LotShape	LandContour	Utilities	LotConfig	LandSlope	Neighborhood	Condition1	Condition2	BldgType	HouseStyle	OverallQual	OverallCond	YearBuilt	YearRemodAdd	RoofStyle	RoofMatl	Exterior1st	Exterior2nd	MasVnrType	MasVnrArea	ExterQual	ExterCond	Foundation	BsmtQual	BsmtCond	BsmtExposure	BsmtFinType1	BsmtFinSF1	BsmtFinType2	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	Heating	HeatingQC	CentralAir	Electrical	X1stFlrSF	X2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	KitchenQual	TotRmsAbvGrd	Functional	Fireplaces	FireplaceQu	GarageType	GarageYrBlt	GarageFinish	GarageCars	GarageArea	GarageQual	GarageCond	PavedDrive	WoodDeckSF	OpenPorchSF	EnclosedPorch	X3SsnPorch	ScreenPorch	PoolArea	PoolQC	Fence	MiscFeature	MiscVal	MoSold	YrSold	SaleType	SaleCondition
/selection = Backward (select=CV) cvmethod=random(5) stats=adjrsq;
output out = resultsb p = predict;
run;



data results_b;
set resultsb;
if Predict > 0 then SalePrice = Predict;
if Predict < 0 then SalePrice = 180932;
keep id SalePrice;
where id>1460;
;
proc export data=WORK.results_b
outfile='/folders/myshortcuts/StatsSAScode/Project/results_b.csv'
dbms=csv
replace;
run;


/*stepwise selection*/
proc glmselect data = combo plots(stepaxis = number) = (criterionpanel ASEplot);
class SaleCondition SaleType MiscFeature Fence PoolQC PavedDrive GarageCond GarageQual GarageFinish GarageType FireplaceQu Functional KitchenQual Electrical CentralAir HeatingQC Heating BsmtFinType2 BsmtFinType1 BsmtExposure BsmtCond BsmtQual Foundation ExterCond ExterQual MasVnrType Exterior2nd Exterior1st MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl ;
model SalePrice = MSSubClass	MSZoning	LotFrontage	LotArea	Street	Alley	LotShape	LandContour	Utilities	LotConfig	LandSlope	Neighborhood	Condition1	Condition2	BldgType	HouseStyle	OverallQual	OverallCond	YearBuilt	YearRemodAdd	RoofStyle	RoofMatl	Exterior1st	Exterior2nd	MasVnrType	MasVnrArea	ExterQual	ExterCond	Foundation	BsmtQual	BsmtCond	BsmtExposure	BsmtFinType1	BsmtFinSF1	BsmtFinType2	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	Heating	HeatingQC	CentralAir	Electrical	X1stFlrSF	X2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	KitchenQual	TotRmsAbvGrd	Functional	Fireplaces	FireplaceQu	GarageType	GarageYrBlt	GarageFinish	GarageCars	GarageArea	GarageQual	GarageCond	PavedDrive	WoodDeckSF	OpenPorchSF	EnclosedPorch	X3SsnPorch	ScreenPorch	PoolArea	PoolQC	Fence	MiscFeature	MiscVal	MoSold	YrSold	SaleType	SaleCondition
/selection = Stepwise (select=cv) cvmethod=random(5) stats=adjrsq;
output out = resultss p = predict;
run;



data results_s;
set resultss;
if Predict > 0 then SalePrice = Predict;
if Predict < 0 then SalePrice = 180932;
keep id SalePrice;
where id>1460;
;
proc export data=WORK.results_s
outfile='/folders/myshortcuts/StatsSAScode/Project/results_s.csv'
dbms=csv
replace;
run;


/*custom model, hybrid computer human selection~~~~~*/
/*best code so far: final model */
proc glmselect data = combo plots(stepaxis = number) = (criterionpanel ASEplot);
class Neighborhood OverallQual ExterQual KitchenQual BsmtQual SaleCondition GarageQual;
model SalePrice =   GrLivArea | KitchenQual GrLivArea |Neighborhood ExterQual | OverallQual GrLivArea | OverallQual BsmtQual GarageCars | GarageQual  SaleCondition | OverallQual YearBuilt YearRemodAdd
/selection = stepwise (select=CV) cvmethod=random(5) stats=adjrsq;
output out = results p = predict;
run;

proc means data=results;
var SalePrice;
run;


data results2;
set results;
if Predict > 0 then SalePrice = Predict;
if Predict < 0 then SalePrice = 180932;
keep id SalePrice;
where id>1460;
;

proc export data=WORK.results2
outfile='/folders/myshortcuts/StatsSAScode/Project/results2.csv'
dbms=csv
replace;
run;














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*code included from the google doc*/
/* Loading Data */
%web_drop_table(WORK.train);
FILENAME REFFILE '/folders/myshortcuts/StatsSAScode/Project/train_clean.csv';

PROC IMPORT DATAFILE=REFFILE
    DBMS=CSV
    OUT=WORK.train;
    GETNAMES=YES;
RUN;
PROC CONTENTS DATA=WORK.train; RUN;
%web_open_table(WORK.train);

data train2;
set train;
log_price = log(SalePrice);
sqft_100 = GrLivArea/100;
if (id = 524 or id = 1299) then delete;
run;
/* Data Filtering and Preparation */
proc glm data = sub_house;
class neighborhood (ref= "NWAmes");
model SalePrice = sqft_100 | neighborhood / solution clparm;
run;


/* Initial Scatterplot (non-grouped) */
proc sgplot data=train;
reg x=sqft_100 y=SalePrice;
run;
/* Initial Cook's D and Leverage (non-grouped) (with outliers) */
proc reg data=train;
model SalePrice = sqft_100  / clm cli;
run;
/* Remove the two outliers (i.e. model homes) */
data train;
set train;
if (id = 524 or id = 1299) then delete;
run;
/* Cook's D and Leverage Again (non-grouped) (without outliers) */
proc reg data=train;
model SalePrice = sqft_100  / clm cli;
run;


/* Calculate the regression line */
proc sgplot data=train;
reg x=sqft_100 y=SalePrice /group=neighborhood;
run;


/* Calculate all estimate and confidence intervals */
/* This also generates the graphs for assumption checking */
proc glm data = train plots=all;
class neighborhood (ref= "NWAmes");
model SalePrice = sqft_100 | neighborhood / solution clparm;
run;


/*CI by Neighborhood*/
proc glm data = train ;
where neighborhood eq 'Edwards';
model SalePrice = sqft_100 / solution clparm;
run;

proc glm data = train ;
where neighborhood eq 'NWAmes';
model SalePrice = sqft_100 / solution clparm;
run;

proc glm data = train ;
where neighborhood eq 'BrkSide';
model SalePrice = sqft_100 / solution clparm;
run;

