//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Szymon Palczyński and Masood Abak"
#property link      "https://www.mql5.com/en/users/stiopa"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2

//--- External Variable
extern  int                PeriodMA    = 7;            // MA Period
extern  ENUM_MA_METHOD     MethodMA    = MODE_SMMA;    // MA Method
extern  ENUM_APPLIED_PRICE AppliedToMA = PRICE_MEDIAN; // MA Applied to

double Buffer_1[];
double Buffer_2[];
double Buffer_3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- add a buffer used for calculations
   IndicatorBuffers(3);

//--- indicator buffers mapping   
   int DrawBeginIndex = PeriodMA*2;
   
   SetIndexBuffer(0,Buffer_1);
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,3,clrRed);
   SetIndexDrawBegin(0,DrawBeginIndex);
   SetIndexLabel(0,"Histogram Buffer (Red)");
        
   SetIndexBuffer(1,Buffer_2);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,3,clrBlue);
   SetIndexDrawBegin(1,DrawBeginIndex);
   SetIndexLabel(1,"Histogram Buffer (Blue)");

   SetIndexBuffer(2,Buffer_3);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexDrawBegin(2,DrawBeginIndex);
   SetIndexLabel(2,"Temprary Buffer");
//--- indicator name
   IndicatorShortName("MA HISTOGRAM SEPARATE WINDOW ("+IntegerToString(PeriodMA)+")");
//--- set indicator digits   
   IndicatorDigits(_Digits);
          
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[])
{
  
  //--- check to have enough bars
   int limit = rates_total - PeriodMA;
   if(rates_total <= limit)
      return(0);
     
  //--- before the first run of OnCalculate
   limit = limit - prev_calculated;
     
   if(rates_total - prev_calculated == 0) limit = 1;  // after the first run of the OnCalculate      
   else limit++;                                      // on the first tick of a new bar
   
  //--- loop over bars to draw histogram 
   for(int i=limit; i >= 0; i--)  
   {
     //--- calculate sum  
      double sum = 0.0;
      
      for(int j=0; j<PeriodMA; j++)
         sum += iMA(_Symbol,PERIOD_CURRENT,PeriodMA,0,MethodMA,AppliedToMA,i+j);            
     //--- fill buffer to draw histogram 
      Buffer_3[i] = sum / PeriodMA;
      Buffer_1[i] = Buffer_3[i+1];
      Buffer_1[i] = Buffer_3[i] - Buffer_1[i];
      if(Buffer_3[i]>Buffer_3[i+1])
      Buffer_2[i]=Buffer_1[i];
      else
      Buffer_1[i]=Buffer_1[i];
   }
      
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
