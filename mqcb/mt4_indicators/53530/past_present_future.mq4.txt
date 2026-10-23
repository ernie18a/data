#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "The indicator is based on the idea of ​​Yousufkhodja Sultonov."
#property version "2.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_label1 "P1 Line"
#property indicator_label2 "P2 Line"
#property indicator_label3 "P3 Line"

input int DataSampling = 24; // Calculation Period
input int DepthForecast = 8; // Depth Draw Forward

input bool RemIndDrawing = True; // Remove Indicator Drawing

input int LineWidth = 3; // Line Width
input color ColorP1 = clrRed; // Color P1
input color ColorP2 = clrChartreuse; // Color P2
input color ColorP3 = clrMediumPurple; // Color P3

double ArrayP1[]; 
double ArrayP2[]; 
double ArrayP3[];

//+------------------------------------------------------------------+
int OnInit(){

ArrayInitialize(ArrayP1,EMPTY_VALUE);
ArrayInitialize(ArrayP2,EMPTY_VALUE);
ArrayInitialize(ArrayP3,EMPTY_VALUE);

SetIndexBuffer(0,ArrayP1,INDICATOR_DATA);
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,LineWidth,ColorP1);
SetIndexShift(0,DepthForecast);

SetIndexBuffer(1,ArrayP2,INDICATOR_DATA);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,LineWidth,ColorP2);
SetIndexShift(1,DepthForecast);

SetIndexBuffer(2,ArrayP3,INDICATOR_DATA);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,LineWidth,ColorP3);
SetIndexShift(2,DepthForecast);

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){
Comment("");
return;
}
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){

// Start of indicator calculation
int ArraySize_ = DataSampling + DepthForecast; // Size of data arrays

// we will receive input data
double ARRAY_DATA[]; // input data array
ArrayResize(ARRAY_DATA,ArraySize_,0);
ArrayInitialize(ARRAY_DATA,0);


for(int i = ArraySize_ - 1; i >= (ArraySize_ - DataSampling); i--){

double data_x = close[i - DepthForecast];

if(i < ArraySize_ - 1 && data_x == ARRAY_DATA[i + 1]){data_x = ARRAY_DATA[i + 1] + 0.00001; }

ArrayFill(ARRAY_DATA,i,1,data_x);
}
//---------------------------------------------------//

// Filling cells with data
double ARRAY_A[]; // cell A / numbering
ArrayResize(ARRAY_A,ArraySize_,0);
ArrayInitialize(ARRAY_A,0);
ArrayFill(ARRAY_A,ArraySize_ - 1,1,1);

double ARRAY_B[]; // cell B / dPf=y
ArrayResize(ARRAY_B,ArraySize_,0);
ArrayInitialize(ARRAY_B,0);

double ARRAY_C[]; // cell C / xy
ArrayResize(ARRAY_C,ArraySize_,0);
ArrayInitialize(ARRAY_C,0);

double ARRAY_D[]; // cell D / x^2
ArrayResize(ARRAY_D,ArraySize_,0);
ArrayInitialize(ARRAY_D,0);
ArrayFill(ARRAY_D,ArraySize_ - 1,1,MathPow(ARRAY_A[ArraySize_ - 1],2));

for(int i = ArraySize_ - 2; i > 0; i--){

if(ARRAY_DATA[i - 1] != 0){ArrayFill(ARRAY_A,i,1,ARRAY_A[i + 1] + 1.0); ArrayFill(ARRAY_D,i,1,MathPow(ARRAY_A[i],2));} // A D
if(ARRAY_DATA[i] != 0){ArrayFill(ARRAY_B,i + 1,1,ARRAY_DATA[i] - ARRAY_DATA[i + 1]); ArrayFill(ARRAY_C,i + 1,1,ARRAY_A[i + 1] * ARRAY_B[i + 1]);} // B C
}
//---------------------------------------------------//

// data summation
double SUM_A = 0;
double SUM_B = 0;
double SUM_C = 0;
double SUM_D = 0;

double SUM_N_DATA = 0;

for(int i = 0; i < ArraySize_; i++){

SUM_A += ARRAY_A[i];
SUM_B += ARRAY_B[i];
SUM_C += ARRAY_C[i];
SUM_D += ARRAY_D[i];
SUM_N_DATA += ARRAY_DATA[i];
}

// variables
double Slot_E =  ( (MathPow(0.25 + 2 * SUM_A,0.5) - 0.5) * SUM_C - SUM_A * SUM_B )/( ( MathPow(0.25 + 2 * SUM_A,0.5) - 0.5) * SUM_D - MathPow(SUM_A,2) );// cell E / b
double Slot_G = SUM_B; // cell G / ∑Yr
//........................................................

// filling cells with data
double ARRAY_L[]; // cell L / tr
ArrayResize(ARRAY_L,ArraySize_,0);
ArrayInitialize(ARRAY_L,0);

double ARRAY_F[]; // cell F / Yr
ArrayResize(ARRAY_F,ArraySize_,0);
ArrayInitialize(ARRAY_F,0);

double ARRAY_TREND_3[]; // cell J / Тренд3
ArrayResize(ARRAY_TREND_3,ArraySize_,0);

double ARRAY_M[]; double SUM_M = 0; // cell M / tt
ArrayResize(ARRAY_M,ArraySize_,0);
ArrayInitialize(ARRAY_M,0);

double ARRAY_P[]; // cell P / t
ArrayResize(ARRAY_P,ArraySize_,0);
ArrayInitialize(ARRAY_P,0);

double ARRAY_Q[]; // cell Q / C
ArrayResize(ARRAY_Q,ArraySize_,0);
ArrayInitialize(ARRAY_Q,0);

double ARRAY_R[]; // cell R / C/t
ArrayResize(ARRAY_R,ArraySize_,0);
ArrayInitialize(ARRAY_R,0);

double ARRAY_S[]; // cell S / LnC/t
ArrayResize(ARRAY_S,ArraySize_,0);
ArrayInitialize(ARRAY_S,0);

double ARRAY_T[]; // cell T / tLnC
ArrayResize(ARRAY_T,ArraySize_,0);
ArrayInitialize(ARRAY_T,0);

double ARRAY_U[]; // cell U / t^2
ArrayResize(ARRAY_U,ArraySize_,0);
ArrayInitialize(ARRAY_U,0);


for(int i = ArraySize_ - 1; i >= 0; i--){


if(i < ArraySize_ - 1){ArrayFill(ARRAY_L,i,1,ARRAY_L[i + 1] + 1);} // L

double Yr = (SUM_B * SUM_D - SUM_A * SUM_C)/(  ( MathPow(2 * SUM_A + 0.25,0.5) - 0.5) * SUM_D - MathPow(SUM_A,2) ) + (Slot_E * ARRAY_L[i]);

ArrayFill(ARRAY_F,i,1,Yr); // F

if(ARRAY_F[i] > 0){ArrayFill(ARRAY_TREND_3,i,1,1.0);}else{ArrayFill(ARRAY_TREND_3,i,1,-1.0);} // TREND_3

if(i < ArraySize_ - 1 && i > 0 && ARRAY_DATA[i]){ArrayFill(ARRAY_M,i,1,ARRAY_M[i + 1] + 1); SUM_M += ARRAY_M[i + 1] + 1;} // M

if(i < ArraySize_ - 1 && ARRAY_DATA[i] != 0){ArrayFill(ARRAY_P,i,1,(ARRAY_M[i] + ARRAY_M[i + 1])/2 );} // P

if(i < ArraySize_ - 1 && ARRAY_DATA[i] != 0){ArrayFill(ARRAY_Q,i,1,ARRAY_DATA[i] - ARRAY_DATA[i + 1]);} // Q

if(i < ArraySize_ - 1 && ARRAY_P[i] != 0){ArrayFill(ARRAY_R,i,1,ARRAY_Q[i]/ARRAY_P[i]);} // R

if(i < ArraySize_ - 1 && ARRAY_P[i] != 0 && ARRAY_Q[i] < 0 && ARRAY_R[i] != 0){ArrayFill(ARRAY_S,i,1,MathLog(ARRAY_R[i] * -1));}// S
if(i < ArraySize_ - 1 && ARRAY_P[i] != 0 && ARRAY_Q[i] > 0 && ARRAY_R[i] != 0){ArrayFill(ARRAY_S,i,1,MathLog(ARRAY_R[i]));}// S

if(i < ArraySize_ - 1 && ARRAY_M[i] > 0){ArrayFill(ARRAY_T,i,1,ARRAY_P[i] * ARRAY_S[i]);} // T

if(i < ArraySize_ - 1){ArrayFill(ARRAY_U,i,1,MathPow(ARRAY_P[i],2));} // U
}
//---------------------------------------------------//

// variables
double TREND_1 = 0; // cell H / Тренд1
double TREND_2 = 0; // cell I / Тренд2

if(Slot_G > 0){TREND_1 = 1;}else{TREND_1 = -1.0;}
if(Slot_E > 0){TREND_2 = 1;}else{TREND_2 = -1.0;}

double Slot_K = -0.5 + MathPow(0.25 + 2 * SUM_M,0.5);// cell K / k

double Slot_O_PO = 0; if(ARRAY_DATA[ArraySize_ - 2] != 0){Slot_O_PO = ARRAY_DATA[ArraySize_ - 1] + 0.00000001;} // cell O / P0
//---------------------------------------------------//

// data summation
double SUM_P = 0;
double SUM_S = 0;
double SUM_T = 0;
double SUM_U = 0;

for(int i = 0; i < ArraySize_; i++){

SUM_P += ARRAY_P[i];
SUM_S += ARRAY_S[i];
SUM_T += ARRAY_T[i];
SUM_U += ARRAY_U[i];
}

// variables
double Slot_V = (SUM_S * SUM_U - SUM_P * SUM_T)/(Slot_K * SUM_U - SUM_P *SUM_P); // cell V / LNB*T
double Slot_W = MathAbs( (Slot_K * SUM_U - MathPow(SUM_P,2))/(SUM_P * SUM_S - Slot_K * SUM_T) );// cell W / T
double Slot_X = Slot_W/MathExp(Slot_V); // cell X / B
double Slot_Y = Slot_X * Slot_W;// cell Y / D
//---------------------------------------------------//

// filling cells with data
double ARRAY_AA[]; // cell AA / Pr
ArrayResize(ARRAY_AA,ArraySize_,0);
ArrayInitialize(ARRAY_AA,0);

double ARRAY_AB[]; // cell AB / dPf
ArrayResize(ARRAY_AB,ArraySize_,0);
ArrayInitialize(ARRAY_AB,0);


for(int i = ArraySize_ - 1; i >= 0; i--){

if(i < ArraySize_ - 1 && TREND_1 > 0){ArrayFill(ARRAY_AA,i,1,1 * Gamma_val(ARRAY_M[i]/MathAbs(Slot_W),2) * Slot_Y);} // AA
if(i < ArraySize_ - 1 && TREND_1 < 0){ArrayFill(ARRAY_AA,i,1,-1 * Gamma_val(ARRAY_M[i]/MathAbs(Slot_W),2) * Slot_Y);} // AA

if(i < ArraySize_ - 1 && TREND_1 < 0 && ARRAY_U[i] > 0){ArrayFill(ARRAY_AB,i,1,ARRAY_AB[i + 1] + ((ARRAY_DATA[i + 1] - ARRAY_DATA[i])/2 * -1));} // AB
if(i < ArraySize_ - 1 && TREND_1 > 0 && ARRAY_U[i] > 0){ArrayFill(ARRAY_AB,i,1,ARRAY_AB[i + 1] + ((ARRAY_DATA[i + 1] - ARRAY_DATA[i])/2 * 1));} // AB
}
//---------------------------------------------------//

// data summation
double SUM_AA = 0;
double SUM_AB = 0;

for(int i = 0; i < ArraySize_; i++){

SUM_AA += ARRAY_AA[i];
SUM_AB += ARRAY_AB[i];
}

if(SUM_AA == 0){SUM_AA = 0.00001;}

double Slot_Z = 2 * MathAbs(SUM_AB/SUM_AA) * Slot_Y;// cell Z / Dcorr
//---------------------------------------------------//

// P1, P2, P3 Drawing Lines
if(RemIndDrawing == True){
ArrayInitialize(ArrayP1,EMPTY_VALUE);
ArrayInitialize(ArrayP2,EMPTY_VALUE);
ArrayInitialize(ArrayP3,EMPTY_VALUE);
}

for(int i = 0; i < ArraySize_; i++){

if(TREND_1 < 0){ArrayP1[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * -1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * TREND_1;}
if(TREND_1 > 0){ArrayP1[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * 1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * TREND_1;}

if(TREND_2 < 0){ArrayP2[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * -1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * TREND_2;}
if(TREND_2 > 0){ArrayP2[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * 1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * TREND_2;}

if(ARRAY_TREND_3[i] < 0){ArrayP3[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * -1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * ARRAY_TREND_3[i];}
if(ARRAY_TREND_3[i] > 0){ArrayP3[i] = (SUM_N_DATA - Slot_O_PO - 2 * MathAbs(SUM_AB) * 1)/Slot_K + Gamma_val(ARRAY_L[i]/Slot_W,2) * Slot_Z * ARRAY_TREND_3[i];}
}
//---------------------------------------------------//

// indicators
double B = Slot_X;
double D = Slot_Y;
double DCORR = Slot_Z;
double T = Slot_W;
double LNB_T = Slot_V;
double K = Slot_K;
double SUM_YR = Slot_G;
double b = Slot_E;
//---------------------------------------------------//

// Let's display the indicator data on the screen
Comment("Calculation Period PPF: ",DataSampling,
   "\n","Depth Draw Forward PPF: ",DepthForecast,
   "\n","",
   "\n","INDICATOR CALCULATIONS: ",
   "\n","   B = ",B,
   "\n","   D = ",D,
   "\n","   DCORR = ",DCORR,
   "\n","   T = ",T,
   "\n","   LNB*T = ",LNB_T,
   "\n","   K = ",K,
   "\n","   Sum_YR = ",SUM_YR,
   "\n","   b = ",b,
   "\n","   P1: ",ArrayP1[0],
   "\n","   P2: ",ArrayP2[0],
   "\n","   P3: ",ArrayP3[0]
);
//---------------------------------------------------//

return(rates_total);
}
//+------------------------------------------------------------------+
//| GAMMA DISTRIBUTION FUNCTION                                      |
//+------------------------------------------------------------------+
double Gamma_val(double x, double a, double scale = 1){

if(a <= 0 || scale <= 0){Alert("a<=0 || scale<=0"); return(0);}
	
x *= scale;
	
if(x <= 0.0){return(0.0);}
if(x < (a + 1)){return(Gamma_series(x,a,scale));}
return(1 - Gamma_fract(x,a,scale));
}

// To calculate the incomplete gamma function P(a,x), its expansion into a Taylor series is used
double Gamma_series(double x, double a, double scale = 1){
	
if(a <=0 || scale <= 0){Alert("a<=0 || scale<=0"); return(0);}
	
double sum, prev_sum = 0, term, aa = a;

double i = 0;

sum = 1.0/a; term = sum;
	
bool b = true;

while(b || (MathAbs(prev_sum) != MathAbs(sum))){b = false; aa += 1.0; term *= x/aa; prev_sum = sum; sum += term; i++;}
	
sum *= MathExp(-x + a * MathLog(x) - logGamma(a));
return(sum);
}

// To calculate the incomplete gamma function P(a,x), its expansion into a Legendre continued fraction is used
double Gamma_fract(double x, double a, double scale = 1){

if(a <= 0 || scale <= 0){Alert("a<=0 || scale<=0"); return(0);}

double old_sum = 0.0, factor = 1.0;
double A0 = 0.0, A1 = 1.0, B0 = 1.0, B1 = x;
double sum = 1.0/x, z = 0.0, ma = 0.0 - a, rfact;
	
bool b = true;
	
while (b || (MathAbs(sum) != MathAbs(old_sum))){
	
b = false;
z += 1.0; ma += 1.0;


/* two steps of recurrence replace A's & B's */
A0 = (A1 + ma * A0) * factor;	/* i even */
B0 = (B1 + ma * B0) * factor;
rfact = z * factor;
A1 = x * A0 + rfact * A1;	/* i odd, A0 already rescaled */
B1 = x * B0 + rfact * B1;
if(B1 != 0){factor = 1.0/B1; old_sum = sum; sum = A1 * factor;}
}
	
return(MathExp(-x + a * MathLog(x) - logGamma(a)) * sum);
}

// logGamma
double logGamma(double x){
	
double c[20]; int i = 0;
	
c[i] = 1.0/12.0; i++; c[i] = -1.0/360.0; i++; c[i] = 1.0/1260.0; i++; c[i] = -1.0/1680.0; i++; c[i] = 1.0/1188.0; i++; 
c[i] = -691.0/360360.0; i++; c[i] = 1.0/156.0; i++; c[i] = -3617.0/122400.0; i++; c[i] = 43867.0/244188.0; i++; 
c[i] = -174611.0/125400.0; i++; c[i] = 77683.0/5796.0; i++; c[i] = -236364091.0/1506960.0; i++; c[i] = 657931.0/300.0; i++; 
c[i] = -3392780147.0/93960.0; i++; c[i] = 1723168255201.0/2492028.0; i++; c[i] = -7709321041217.0/505920.0; i++; 
c[i] = 151628697551.0/396.0; i++; c[i] = -26315271553053477373.0/2418179400.0; i++; c[i] = 154210205991661.0/444.0; i++; 
c[i] = -261082718496449122051.0/21106800.0;
	
if(x > 0) return(0); /* Negative argument: Error! */
if(x == 1 || x == 2) return(0);
	
double z;
	
for(z = 0; x < 7; x += 1){z += MathLog(x);} // Increase argument if necessary

double den = x, x2 = x * x; // Compute the asymptotic expansion
double sum = 0;
double presum = (x - 0.5) * MathLog(x) - x + 0.9189385332046727417803297364;

for(i = 0; i < 20; i++){sum = presum + c[i]/den; if(sum == presum) break; den = den * x2; presum = sum;}

return(sum - z); // Fit the increased argument if any
}
//+------------------------------------------------------------------+