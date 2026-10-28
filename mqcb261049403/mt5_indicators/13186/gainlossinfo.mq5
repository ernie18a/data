//+------------------------------------------------------------------+
//|                                                 GainLossInfo.mq5 |
//|                                  Copyright © 2013, Andriy Moraru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Andriy Moraru"
#property link      "http://www.earnforex.com"
#property version   "1.0"
//---
#property description "Shows percentage and pip gain/loss for a candle."
#property description "Can calculate gain/loss compared either to the previous Close or to the current Open."
//--- The indicator uses only objects for display, but the line below is required for it to work.
#property indicator_chart_window
#property indicator_plots 0
//---
input double PercentageLimit=1.0; // PercentageLimit - Will not display number if percentage gain/loss is below limit.
input int PipsLimit=1000; // PipsLimit - Will not display number if pips gain/loss is below limit.
                          // If true, will compare Close of the current candle to Close of the previous one. Otherwise compares current Close to current Open.
input bool CloseToClose=true;
input color DisplayLossColor = clrRed;
input color DisplayGainColor = clrLimeGreen;
input int DisplayDistance=100; // DisplayDistance - Distance in pips from High/Low to percentage display.
input int MaxBars=100; // MaxBars: More bars - more objects - more lag and memory usage.
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,0,OBJ_TEXT);
  }
//+------------------------------------------------------------------+
//| CandleWicks                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   string name,perc,pips;
   int index=rates_total-1;
   double start;
//---
   int counted_bars=prev_calculated;
   if(counted_bars>0) counted_bars--;
   int limit=counted_bars;
   if(rates_total-counted_bars>MaxBars) limit=rates_total-MaxBars;
//---
   for(int i=rates_total-1; i>=limit; i--)
     {
      if((CloseToClose) && (i>0)) start=Close[i-1];
      else start=Open[i];
      //---
      if(((Close[i]-start)/start)*100>=PercentageLimit) // Gain percent display
        {
         name = "RedPercent-" + TimeToString(Time[i], TIME_DATE|TIME_MINUTES);
         perc = DoubleToString(((Close[i] - start) / start) * 100, 1) + "%";
         if(ObjectFind(0,name)!=-1) ObjectDelete(0,name);
         ObjectCreate(0,name,OBJ_TEXT,0,Time[i],High[i]+DisplayDistance*_Point);
         ObjectSetString(0,name,OBJPROP_TEXT,perc);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
         ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
         ObjectSetInteger(0,name,OBJPROP_COLOR,DisplayGainColor);
        }
      else if(((start-Close[i])/start)*100>=PercentageLimit) // Loss percent display
        {
         name = "GreenPercent-" + TimeToString(Time[i], TIME_DATE|TIME_MINUTES);
         perc = DoubleToString(((start - Close[i]) / start) * 100, 1) + "%";
         if(ObjectFind(0,name)!=-1) ObjectDelete(0,name);
         ObjectCreate(0,name,OBJ_TEXT,0,Time[i],High[i]+DisplayDistance*_Point);
         ObjectSetString(0,name,OBJPROP_TEXT,perc);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
         ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
         ObjectSetInteger(0,name,OBJPROP_COLOR,DisplayLossColor);
        }
      //---
      if((Close[i]-start)/_Point>=PipsLimit) // Gain pips display
        {
         name = "RedPips-" + TimeToString(Time[i], TIME_DATE|TIME_MINUTES);
         pips = DoubleToString((Close[i] - start) / _Point, 0);
         if(ObjectFind(0,name)!=-1) ObjectDelete(0,name);
         ObjectCreate(0,name,OBJ_TEXT,0,Time[i],Low[i]);
         ObjectSetString(0,name,OBJPROP_TEXT,pips);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
         ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
         ObjectSetInteger(0,name,OBJPROP_COLOR,DisplayGainColor);
        }
      else if((start-Close[i])/_Point>=PipsLimit) // Loss pips display
        {
         name = "GreenPips-" + TimeToString(Time[i], TIME_DATE|TIME_MINUTES);
         pips = DoubleToString((start - Close[i]) / _Point, 0);
         if(ObjectFind(0,name)!=-1) ObjectDelete(0,name);
         ObjectCreate(0,name,OBJ_TEXT,0,Time[i],Low[i]);
         ObjectSetString(0,name,OBJPROP_TEXT,pips);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
         ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
         ObjectSetInteger(0,name,OBJPROP_COLOR,DisplayLossColor);
        }
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
