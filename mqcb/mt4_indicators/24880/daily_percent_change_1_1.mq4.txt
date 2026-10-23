//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*------------------------------------------------------------------+
//| Daily Percent Change                                            |
//+-----------------------------------------------------------------+
*/

#property copyright "Copyright © 2019, Rob Rice"
#property version   "1.2"
#property strict
#property indicator_separate_window
#property indicator_buffers    1
#property indicator_color1     LightSeaGreen

//--- input parameter

#property indicator_level2     0.85
#property indicator_level1    -0.85
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

//--- buffers

double DPCBuffer[];  // declare array
double O,C;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit(void)
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,DPCBuffer);                 // assign array to buffer
   string short_name="Daily Percent Change";
   IndicatorShortName(short_name);
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

//--- prevent total recalculation
   int i=rates_total-prev_calculated-1;
//--- current value should be recalculated
   if(i<0)
      i=0;
//---
   while(i>=0)
     {
      if(TimeHour(Time[i])==0 && TimeMinute(Time[i])==0)
        {
         O=Open[i];
        }
      if(O==0) O=Open[i];
      C=iClose(NULL,0,i);
      DPCBuffer[i]=NormalizeDouble(((C-O)/O*100),2);
      i--;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
