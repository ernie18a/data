//The Simple Trend Detector. Based on code RSI.mq4,  Copyright © 2004, MetaQuotes Software Corp. http://www.metaquotes.net/

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


input int inSTDPeriod = 15; // Period Of Simple Trend Detector

int STDPeriod;
double Buffer[], PosBuffer[], NegBuffer[];

int OnInit()   {
if(inSTDPeriod < 4) {
      STDPeriod = 15;
      Print("Incorrect Period Of Simple Trend Detector = ", inSTDPeriod, ". Indicator use STDPeriod = ",STDPeriod);  }
else  STDPeriod = inSTDPeriod;
 
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
      if(Den == 0.0) Buffer[i] = 0.0;
      else Buffer[i]= 2.0 * positive / Den - 1.0;  }

if(IsStopped())   return(0);

return(rates_total); }

