//+------------------------------------------------------------------+
//|                                                 Weather vane.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "Section"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2



double LineBuffer[];
double VALUE,SUMM;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---
   return(0);
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
   static long ticks;

   datetime timeInfo=(datetime)SymbolInfoInteger(Symbol(),SYMBOL_TIME);

   MqlDateTime str;
   TimeToStruct(timeInfo,str);

   long time_min=str.min;

   if(!GlobalVariableCheck("min"))
     {
      GlobalVariableTemp("min");
      GlobalVariableSet("min",time_min);
     }

   if(time_min!=GlobalVariableGet("min"))
     {
      GlobalVariableSet("min",time_min);
      ticks=1;
      VALUE=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      SUMM=VALUE;
     }
   else
     {
      ticks++;
      VALUE+=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      SUMM=NormalizeDouble(VALUE/ticks,8);
     }

   LineBuffer[rates_total-1]=SUMM;
   
   //--- buy
   if((high[rates_total-1]+low[rates_total-1])/2<SUMM) Wingdings(time[rates_total-1],high[rates_total-1]+2*_Point,241,clrBlue);
   //--- sell
   else Wingdings(time[rates_total-1],low[rates_total-1]-2*_Point,242,clrRed);

   Comment(Symbol(),"\n",TimeToString(timeInfo)," - ",ticks);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void Wingdings(datetime time,double last,int wings,color colr)
  {
   ObjectCreate(0,"arrow",OBJ_ARROW,0,0,0,0,0);
   ObjectSetInteger(0,"arrow",OBJPROP_ARROWCODE,wings);
   ObjectSetInteger(0,"arrow",OBJPROP_COLOR,colr);
   ObjectSetInteger(0,"arrow",OBJPROP_TIME,time);
   ObjectSetDouble(0,"arrow",OBJPROP_PRICE,last);
  }
//+------------------------------------------------------------------+
