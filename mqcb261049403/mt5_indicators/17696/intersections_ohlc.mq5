//+------------------------------------------------------------------+
//|                                           Intersections OHLC.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Intersections OHLC"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE 
//--- define 2 colors for coloring each bar (they are stored in the special array) 
#property indicator_color1  clrBlue,clrRed // (Up to 64 colors can be specified)
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  2
#property indicator_label1  "Intersections OHLC"
//--- day of week 
enum ENUM_INTERSECTIONS
  {
   HighLow=0,// High and Low
  };
//--- input parameter
input ENUM_INTERSECTIONS intersections=HighLow;
//--- indicator buffers
double   ExtDataBuffer[];
//--- a buffer for storing the line color on each bar 
double   ColorLineColors[];
double   ExtCalcBuffer[];
//--- the array for storing colors contains 2 elements 
color    colors[]={clrRed,clrBlue};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Print(__FUNCTION__," In");
   SetIndexBuffer(0,ExtDataBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorLineColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtCalcBuffer,INDICATOR_CALCULATIONS);

//--- name for DataWindow and indicator subwindow label 
   string text="";
   switch(intersections)
     {
      default:
         text="High and Low ";
         break;
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"Intersections "+text);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---
   Print(__FUNCTION__," Out");
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
//---
   static datetime   prev_time=0;
   int limit=-1;
   if(prev_calculated==0) // the first start of calculation
     {
      limit=2;
      ArrayInitialize(ExtDataBuffer,1.0);
      ArrayInitialize(ColorLineColors,0.0);
      ArrayInitialize(ExtCalcBuffer,1.0);
      prev_time=0;
     }
   else
      limit=prev_calculated;

   if(prev_time==time[rates_total-1])
     {
      return(rates_total);
     }

   prev_time=time[rates_total-1];

   for(int i=limit;i<rates_total;i++)
     {
      switch(intersections)
        {
         default:                                  // High and Low
            ExtCalcBuffer[i]=ExtCalcBuffer[i-1];// start init
            if(high[i-1]>high[i-2])
              {
               ExtCalcBuffer[i]++;
              }
            if(low[i-1]<low[i-2])
              {
               ExtCalcBuffer[i]--;
              }
            ExtDataBuffer[i]=ExtCalcBuffer[i];
        }
     }
   for(int i=limit;i<rates_total;i++)
     {
      if(ExtDataBuffer[i]>ExtDataBuffer[i-1])
        {
         //--- For this bar, the line will have the color with the index color_index 
         ColorLineColors[i]=0;
        }
      else
        {
         //--- For this bar, the line will have the color with the index color_index 
         ColorLineColors[i]=1;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
