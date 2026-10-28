//+------------------------------------------------------------------+
//|                                                       Spread.mq5 |
//|                                        Copyright 2015, Serj_Che. |
//|                           https://www.mql5.com/ru/users/serj_che |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Serj_Che."
#property link      "https://www.mql5.com/ru/users/serj_che"
#property version   "1.00"
#property indicator_chart_window
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  DeepPink,RoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_minimum 0.0
//--- input data
input int Count = 20;
//--- indicator buffers
double                    ExtSpreadBuffer[];
double                    ExtColorsBuffer[];
//--- global variable
MqlTick tick;
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,ExtSpreadBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Spread("+IntegerToString(Count)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,LimeGreen);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0.1);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"spread");
  }
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
   if(rates_total<2) return(0);
   int start=prev_calculated-1;
   if(start<1) start=1;
   CalculateSpread(start,rates_total,spread);
   int minimum=ArrayMinimum(ExtSpreadBuffer,rates_total-Count,Count);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,spread[minimum]);
   SymbolInfoTick(_Symbol,tick);
   if(ObjectFind(0,"spread")<0)
     {
      int sub_wnd=ChartWindowFind();
      ObjectCreate(0,"spread",OBJ_LABEL,sub_wnd,0,0);
      ObjectSetInteger(0,"spread",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"spread",OBJPROP_YDISTANCE,5);
      ObjectSetInteger(0,"spread",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"spread",OBJPROP_FONTSIZE,12);
      ObjectSetString(0,"spread",OBJPROP_FONT,"Courier New");
      ObjectSetInteger(0,"spread",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"spread",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"spread",OBJPROP_SELECTABLE,false);
     }
   ObjectSetString(0,"spread",OBJPROP_TEXT,StringFormat("Current Spread:%3i",(int)((tick.ask-tick.bid)/_Point),0));
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CalculateSpread(const int nPosition,
                     const int nRatesCount,
                     const int &SrcBuffer[])
  {
   ExtSpreadBuffer[0]=(double)SrcBuffer[0];
   ExtColorsBuffer[0]=0.0;
   for(int i=nPosition;i<nRatesCount && !IsStopped();i++)
     {
      double dCurrSpread=(double)SrcBuffer[i];
      double dPrevSpread=(double)SrcBuffer[i-1];
      ExtSpreadBuffer[i]=dCurrSpread;
      if(dCurrSpread>dPrevSpread)
         ExtColorsBuffer[i]=0.0;
      else
         ExtColorsBuffer[i]=1.0;
     }
  }
//+------------------------------------------------------------------+
