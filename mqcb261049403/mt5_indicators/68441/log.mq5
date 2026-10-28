//+------------------------------------------------------------------+
//|                                                          Log.mq5 |
//|                                    Copyright 2026, Tadeáš Rusňák |
//|                      https://www.mql5.com/en/users/tadeas.rusnak |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tadeáš Rusňák" 
#property link      "https://www.mql5.com/en/users/tadeas.rusnak" 
#property version   "1.10"

#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_plots   1 

#property indicator_label1  "Log" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  2 

enum ENUM_LOG_MODE
  {
   MODE_LOG_SCALE,      // Log Scale (Absolute)
   MODE_CUMULATIVE,     // Log Scale (Cumulative)   
   MODE_LOG_RETURNS,    // Log Returns (Difference)
   MODE_VOLATILITY      // Log Volatility (Deviation)
  };

input ENUM_LOG_MODE  inpMode   = MODE_LOG_SCALE;
input int            inpPeriod = 12;             // Period for Volatility

double LogBuffer[]; 
double LogReturnsBuffer[]; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, LogBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LogReturnsBuffer, INDICATOR_CALCULATIONS);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Log (" + EnumToString(inpMode) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 5); 
   
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
   if(rates_total < inpPeriod) return(0);

   int start = prev_calculated - 1; 
   if(start < 1) 
   {
      start = 1;
      LogBuffer[0] = 0;
      LogReturnsBuffer[0] = 0;
   }
   
   double log_ret = 0;

   for(int i = start; i < rates_total; i++)
   {
      // check for (Log) from 0.
      if(close[i] <= 0 || close[i-1] <= 0) 
      { 
         LogBuffer[i] = 0;
         LogReturnsBuffer[i] = 0; 
         continue; 
      }

      // Calculation for Log Returns.
      log_ret = MathLog(close[i]) - MathLog(close[i-1]); 
      LogReturnsBuffer[i] = log_ret;

      switch(inpMode)
      {
         case MODE_LOG_SCALE:
            LogBuffer[i] = MathLog(close[i]);
            break;

         case MODE_LOG_RETURNS:
            LogBuffer[i] = log_ret; 
            break;

         case MODE_CUMULATIVE:
            LogBuffer[i] = LogBuffer[i-1] + log_ret; 
            break;
            
         case MODE_VOLATILITY:
         {
            if(i < inpPeriod) 
            {
               LogBuffer[i] = 0;
            }
            else 
            {
               // Deviation from Log Returns
               double sum = 0;
               for(int j = 0; j < inpPeriod; j++)
                  sum += LogReturnsBuffer[i-j];
               
               double mean = sum / inpPeriod;
               double sq_sum = 0;
               
               for(int j = 0; j < inpPeriod; j++)
                  sq_sum += MathPow(LogReturnsBuffer[i-j] - mean, 2);
               
               LogBuffer[i] = MathSqrt(sq_sum / inpPeriod);
            }
            break;
         }
      }
   }
   return(rates_total);
}