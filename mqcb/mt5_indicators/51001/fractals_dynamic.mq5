//+------------------------------------------------------------------+
//|                                             Fractals Dynamic.mq5 |
//|                                    Copyright 2023, by Ivan Butko |
//|                        https://www.mql5.com/ru/users/capitalplus |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2023, iboot@yandex.ru"
#property link      "https://www.mql5.com/ru/users/capitalplus"
#property version   "1.00"
#property description "Fractals Dynamic is a modified Bill Williams fractal indicator,"
#property description "which added the ability to set manually"
#property description "number of bars to the left and right of the fractal,"
#property description "and also change the color for each of the opposite fractals."
#property description ""
#property description "Wishing you great profits in trading!"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrTomato
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"





input int Bars_left     = 2;   // Number of bars on the left
input int Bars_right    = 2;   // Number of bars on the right
input int Width         = 1;   // Label size
input int ExtArrowShift = 10;  // Offset from price in pixels







//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price



int fr;
bool flag_l, flag_r;






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
   
   //--- РАЗМЕРЫ
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH, Width);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH, Width);
   
   
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT, -ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT, ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
   // Размер фрактала
   fr = Bars_left + Bars_right + 1;
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
   
   if(rates_total < fr)
      return(0);

   int start;
//--- clean up arrays
   if(prev_calculated<7)
     {
      start = fr;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else
      start = rates_total - fr;
//--- main cycle of calculations
    for(int i = start; i < rates_total - Bars_right - 1 && !IsStopped(); i++)
      {
        // Check the bars on the left of the HIGH
        flag_l = true;
        for (int lb = 1; lb < Bars_left + 1 && !IsStopped(); lb++)
           {
             if (high[i] >= high[i - lb]) continue;
             else 
               {
                 flag_l = false;
                 flag_r = false;
                 break;
               }            
           }
       
        // If the condition on the left is met, check the bars to the right of the HIGH
        if (flag_l)      
          {
            flag_r = true;
            for (int rb = 1; rb < Bars_right + 1 && !IsStopped(); rb++)
              {
                if (high[i] > high[i + rb]) continue;
                else 
                  {
                    flag_r = false;
                    break;
                  }            
              }
          }
         
        // If the condition on the right is also met, mark the fractal
        if (flag_r)      ExtUpperBuffer[i] = high[i];
        else             ExtUpperBuffer[i] = EMPTY_VALUE;
      
      
      
      
        // Check the bars on the left of the LOW
        flag_l = true;
        for (int lb = 1; lb < Bars_left + 1 && !IsStopped(); lb++)
           {
             if (low[i] <= low[i - lb]) continue;
             else 
               {
                 flag_l = false;
                 flag_r = false;
                 break;
               }            
           }
       
        // If the condition on the left is met, check the bars to the right of the HIGH 
        if (flag_l)      
          {
            flag_r = true;
            for (int rb = 1; rb < Bars_right + 1 && !IsStopped(); rb++)
              {
                if (low[i] < low[i + rb]) continue;
                else 
                  {
                    flag_r = false;
                    break;
                  }            
              }
          }
         
        // If the condition on the right is also met, mark the fractal
        if (flag_r)      ExtLowerBuffer[i] = low[i];
        else             ExtLowerBuffer[i] = EMPTY_VALUE; 
      
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
