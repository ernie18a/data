//+------------------------------------------------------------------+
//|                                     Demo_IndicatorSetInteger.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
//--- Set the max and min values for the indicator window
#property indicator_minimum 0
#property indicator_maximum 100
//--- Show three horizontal levels in a separate indicator window
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
//--- Set the width of horizontal levels
#property indicator_levelwidth 5
//--- Set the color of horizontal levels
#property indicator_levelcolor clrAliceBlue
//--- Set the style of horizontal levels
#property indicator_levelstyle STYLE_DOT
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set descriptions of horizontal levels 
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"First Level (index 0)");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Second Level (index 1)");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Third Level (index 2)");
//--- Set a short name for the indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"IndicatorSetInteger() Demo");
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
   static int tick_counter=0;
//--- Count ticks
   tick_counter++;
//--- and set colors of horizontal levels depending on the ticks counter
   ChangeLevelColor(0,tick_counter,3,6,10); // Three last parameters switch color
   ChangeLevelColor(1,tick_counter,3,6,8);
   ChangeLevelColor(2,tick_counter,4,7,9);
//--- Change the style of horizontal levels
   ChangeLevelStyle(0,tick_counter);
   ChangeLevelStyle(1,tick_counter+5);
   ChangeLevelStyle(2,tick_counter+15);
//--- Get width as the remainder of integer division of the ticks number by 5
   int width=tick_counter%5;
//--- For all horizontal levels set 
   for(int l=0;l<3;l++)
      IndicatorSetInteger(INDICATOR_LEVELWIDTH,l,width+1);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Set color of horizontal line in the separate indicator window    |
//+------------------------------------------------------------------+
void ChangeLevelColor(int level,      // The index of the horizontal line
                      int tick_number,// dividend, number to get the remainder of division
                      int f_trigger,  // first divisor of color switching
                      int s_trigger,  // second divisor of color switching
                      int t_trigger)  // third divisor of color switching
  {
   static color colors[3]={clrRed,clrBlue,clrGreen};
//--- Color index from the colors[] array 
   int index=-1;
//--- calculate the number of color from the colors[] array to paint horizontal line
   if(tick_number%f_trigger==0)
      index=0;   // if tick_number divides by f_trigger without the remainder
   if(tick_number%s_trigger==0)
      index=1;   // if tick_number divides by s_trigger without the remainder
   if(tick_number%t_trigger==0)
      index=2;   // if tick_number divides by t_trigger without the remainder
//--- if the color is defined, set it      
   if(index!=-1)
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,level,colors[index]);
//---
  }
//+------------------------------------------------------------------+
//| Set style of horizontal line in the separate indicator window    |
//+------------------------------------------------------------------+
void ChangeLevelStyle(int level,     // The index of the horizontal line
                      int tick_number// number to get the remainder of division)
                      )
  {
//--- array to store styles
   static ENUM_LINE_STYLE styles[5]=
     {STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//--- index of style from the styles[] array 
   int index=-1;
//--- calculate the number from the styles[] array to set style of horizontal line
   if(tick_number%50==0)
      index=5;   // if tick_number divides by 50 without the remainder, then style is STYLE_DASHDOTDOT
   if(tick_number%40==0)
      index=4;   // ... style STYLE_DASHDOT
   if(tick_number%30==0)
      index=3;   // ... STYLE_DOT
   if(tick_number%20==0)
      index=2;   // ... STYLE_DASH
   if(tick_number%10==0)
      index=1;   // ... STYLE_SOLID
//--- if the style is defined, set it      
   if(index!=-1)
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,level,styles[index]);
  }
//+------------------------------------------------------------------+
