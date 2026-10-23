//The Simple Trend Detector. Based on code RSI.mq4,  Copyright © 2004, MetaQuotes Software Corp. http://www.metaquotes.net/
//3-Pole Butterworth Filter: Code by Witold Wozniak, www.mqlsoft.com

#property  copyright "Copyright © 2004, MetaQuotes Software Corp., BECEMAL 2010"
#property  link      "http://www.becemal.ru/"
#property version   "1.01"
#property indicator_separate_window
#property indicator_minimum -1.0
#property indicator_maximum  1.0
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_label1  "STD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


input int inSTDPeriod = 15; // Period Of 	Smoothed Simple Trend Detector

int STDPeriod, sSTDPeriod;
double Buffer[], PosBuffer[], NegBuffer[];
double A1, A2, A3, A4;

void  TPBF(double InPeriod, double &R1, double &R2, double &R3, double &R4)  {
double   CutOffPeriod = InPeriod;
if(CutOffPeriod < 4.0)   CutOffPeriod = 4.0;
double a1 = MathExp( -1.0 * M_PI / CutOffPeriod);
double b1 = 2.0 * a1 * MathCos(M_PI * MathSqrt(3.0) / CutOffPeriod);
double c1 = a1 * a1;
R2 = b1 + c1;
R3 = -(c1 + b1 * c1);
R4 = c1 * c1;
R1 = 1.0 - R2 - R3 - R4;   }

int OnInit()   {
if(inSTDPeriod < 8) {
      sSTDPeriod = 16;
      Print("Incorrect Period Of Simple Trend Detector = ", inSTDPeriod, ". Indicator use STDPeriod = ", sSTDPeriod);  }
else  sSTDPeriod = inSTDPeriod;
TPBF(sSTDPeriod, A1, A2, A3, A4);
STDPeriod = (sSTDPeriod > 16)?sSTDPeriod/4:4;
 
SetIndexBuffer(0,Buffer,INDICATOR_DATA);
SetIndexBuffer(1,PosBuffer,INDICATOR_CALCULATIONS);
SetIndexBuffer(2,NegBuffer,INDICATOR_CALCULATIONS);

if(!ArraySetAsSeries(Buffer,false) ||
   !ArraySetAsSeries(PosBuffer,false) ||
   !ArraySetAsSeries(NegBuffer,false))   {
      Print("ArraySetAsSeries Error ",GetLastError());  
      return(-1);  }

return(0);  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
int i, limit;
if(rates_total <= STDPeriod) return(0);

if(prev_calculated > rates_total || prev_calculated <= 0)   {

   for(i = begin; i < STDPeriod;i++)   PosBuffer[i] = 0.0;
   for(i = begin; i < STDPeriod;i++)   NegBuffer[i] = 0.0;
   for(i = begin; i < STDPeriod;i++)   Buffer[i] = 0.0;
   limit = STDPeriod;   }
else limit = prev_calculated - 2; // ReCalc 2 Bars

for(i = limit;i < rates_total && !IsStopped();i++)  {
      double   positive = 0.0, negative = 0.0;
      double   rel = price[i] - price[i - 1];
      if(rel > 0.0)  positive = rel;
         else        negative =-rel;
      PosBuffer[i] = positive;
      NegBuffer[i] = negative;   }

if(IsStopped())   return(0);

for(i = limit;i < rates_total && !IsStopped();i++)  {    
   double   positive = 0.0, negative = 0.0;
   for(int j = 0;j < STDPeriod;j++) {
         double Norm = STDPeriod - j;
         positive += Norm * PosBuffer[i - j];
         negative += Norm * NegBuffer[i - j]; }
      double   Den = positive + negative;
      double   STD = 0.0;
      if(Den == 0.0)  STD = 0.0;
      else STD = 2.0 * positive / Den - 1.0;
      Buffer[i] = A1 * STD + A2 * Buffer[i - 1] + A3 * Buffer[i - 2] + A4 * Buffer[i - 3];   }

if(IsStopped())   return(0);

return(rates_total); }

