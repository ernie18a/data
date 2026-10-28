//+------------------------------------------------------------------+
//|                     Count of candles in interval (histogram).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4 
#property indicator_plots   2 
//--- plots Histogram 
#property indicator_label1  "Bulls" 
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrBlue 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1
#property indicator_label2  "Bears" 
#property indicator_type2   DRAW_HISTOGRAM 
#property indicator_color2  clrRed 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1 
//--- input parameters
input ushort   InputRightBar  = 2;  // The number of the starting bar
input ushort   InputLeftBar   = 5;  // The number of the end bar
//--- indicator buffer
double         ExtBullsBuffer[];
double         ExtBearsBuffer[];
double         ExtBullsBufferTemp[];
double         ExtBearsBufferTemp[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InputRightBar==InputLeftBar)
     {
      Print("The starting and ending bars can not be equal");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InputRightBar>InputLeftBar)
     {
      Print("The starting bar can not be more than the final bar");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping 
   SetIndexBuffer(0,ExtBullsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBearsBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtBullsBufferTemp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtBearsBufferTemp,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetString(INDICATOR_SHORTNAME,"Count ("+IntegerToString(InputLeftBar)+","+IntegerToString(InputRightBar)+")");
//---
   ArraySetAsSeries(ExtBullsBuffer,true);
   ArraySetAsSeries(ExtBearsBuffer,true);
   ArraySetAsSeries(ExtBullsBufferTemp,true);
   ArraySetAsSeries(ExtBearsBufferTemp,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of input time series 
                 const int prev_calculated,  // bars handled in previous call 
                 const datetime& time[],     // Time 
                 const double& open[],       // Open 
                 const double& high[],       // High 
                 const double& low[],        // Low 
                 const double& close[],      // Close 
                 const long& tick_volume[],  // Tick Volume 
                 const long& volume[],       // Real Volume 
                 const int& spread[]         // Spread 
                 )
  {
//--- the rightmost bar on the chart has an index of "0"
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   int limit=rates_total-prev_calculated+1;
   if(prev_calculated==0)
      limit=rates_total-1;

   for(int i=limit;i>=0;i--)
     {
      ExtBullsBufferTemp[i]=(open[i]<close[i])?1.0:0.0;
      ExtBearsBufferTemp[i]=(open[i]>close[i])?-1.0:0.0;

      int limit_left_bar=i+InputLeftBar;
      if(limit_left_bar>=rates_total)
        {
         ExtBullsBuffer[i]=0.0;
         ExtBearsBuffer[i]=0.0;
        }
      else
        {
         ExtBullsBuffer[i]=ExtBearsBuffer[i]=0.0;
         for(int j=limit_left_bar;j>=i+InputRightBar;j--)
           {
            ExtBullsBuffer[i]+=ExtBullsBufferTemp[j];
            ExtBearsBuffer[i]+=ExtBearsBufferTemp[j];
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
