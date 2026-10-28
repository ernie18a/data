//+------------------------------------------------------------------+
//|                                                     Fractals.mq5 |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "© 2025 Francisco Gomes (mql5.com)"
#property link      "https://www.mql5.com/en/users/franciscogomes5/seller"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_width1  5
#property indicator_width2  5
#property indicator_color1  Blue
#property indicator_color2  Blue
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"

input int BarsLeft  = 5; //Bars Left
input int BarsRight = 2; //Bars Right

//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift=-10;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|  Fractals on 5 bars                                              |
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
   if(rates_total<5)
      return(0);

   int start;
//--- clean up arrays
   if(prev_calculated<7)
     {
      start=BarsLeft;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else
      start=rates_total-(BarsLeft+BarsRight+1);
   bool status;
//--- main cycle of calculations
   for(int i=start; i<rates_total-(BarsRight+1) && !IsStopped(); i++)
     {
      //--- Upper Fractal
      status = false;
      for(int b=1; b <= BarsRight; b++)
        {
         if(high[i] > high[i+b])
            status = true;
         else
           {
            status = false;
            break;
           }
        }
      if(status == true)
        {
         for(int b=1; b <= BarsLeft; b++)
           {
            if(high[i] > high[i-b])
               status = true;
            else
              {
               status = false;
               break;
              }
           }
        }
      if(status == true)
         ExtUpperBuffer[i]=high[i];
      else
         ExtUpperBuffer[i]=EMPTY_VALUE;
         
         
      //--- Lower Fractal
      status = false;
      for(int b=1; b <= BarsRight; b++)
        {
         if(low[i] < low[i+b])
            status = true;
         else
           {
            status = false;
            break;
           }
        }
      if(status == true)
        {
         for(int b=1; b <= BarsLeft; b++)
           {
            if(low[i] < low[i-b])
               status = true;
            else
              {
               status = false;
               break;
              }
           }
        }
      if(status == true)
         ExtLowerBuffer[i]=low[i];
      else
         ExtLowerBuffer[i]=EMPTY_VALUE;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
