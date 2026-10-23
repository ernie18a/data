//+------------------------------------------------------------------+
//|                                               Channel N Bars.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.003"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Lowest
#property indicator_label1  "Lowest"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- plot Highest
#property indicator_label2  "Highest"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//+------------------------------------------------------------------+
//| Enum Price                                                       |
//+------------------------------------------------------------------+
enum ENUM_PRICE
  {
   hl=0,    // high low
   oc=1,    // open close
  };
//--- input parameters
input int         InputNBars  = 9;  // N Bars
input ENUM_PRICE  InpPrice    = oc; // Cannel price
//--- indicator buffers
double   LowestBuffer[];
double   HighestBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
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
   if(rates_total<InputNBars)
      return(0);
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=InputNBars;
   for(int i=limit; i<rates_total; i++)
     {
      if(InpPrice==hl)
        {
         LowestBuffer[i]=low[ArrayMinimum(low,i-InputNBars+1,InputNBars)];
         HighestBuffer[i]=high[ArrayMaximum(high,i-InputNBars+1,InputNBars)];
        }
      else
        {
         LowestBuffer[i]=close[ArrayMinimum(close,i-InputNBars+1,InputNBars)];
         HighestBuffer[i]=open[ArrayMaximum(open,i-InputNBars+1,InputNBars)];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
