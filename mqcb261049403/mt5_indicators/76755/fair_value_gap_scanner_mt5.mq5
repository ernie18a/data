//+------------------------------------------------------------------+
//|                                   Fair Value Gap Scanner MT5.mq5 |
//|                                         Copyright 2026, Shahrukh |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Shahrukh"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Closed candle fair value gap scanner with mitigation tracking."
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

input group "Gap Detection"
input int              InpMaximumBars        = 400;       // Bars to scan
input double           InpMinimumGapPoints   = 20.0;      // Minimum gap in points
input bool             InpShowBullishGaps    = true;
input bool             InpShowBearishGaps    = true;
input bool             InpHideMitigated      = false;
input bool             InpUseFullFill        = true;      // Full fill or first touch

input group "Display"
input int              InpExtensionBars      = 80;
input color            InpBullishGapColor    = clrPaleGreen;
input color            InpBearishGapColor    = clrMistyRose;
input color            InpMitigatedColor     = clrGainsboro;
input uchar            InpTransparency       = 55;
input bool             InpShowLabels         = true;

input group "Alerts"
input bool             InpEnableAlerts       = false;

string   g_prefix="FVGSCAN_";
datetime g_last_bar=0;
datetime g_last_alert_bar=0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMaximumBars<20 || InpMinimumGapPoints<0.0 || InpExtensionBars<1)
     {
      Print("Invalid scanner settings.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"Fair Value Gap Scanner");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
bool IsBullishMitigated(const int formation_index,const double gap_bottom,
                       const double gap_top,const double &low[])
  {
   const double threshold=(InpUseFullFill ? gap_bottom : gap_top);
   for(int index=formation_index-1; index>=0; index--)
      if(low[index]<=threshold)
         return(true);
   return(false);
  }

//+------------------------------------------------------------------+
bool IsBearishMitigated(const int formation_index,const double gap_bottom,
                       const double gap_top,const double &high[])
  {
   const double threshold=(InpUseFullFill ? gap_top : gap_bottom);
   for(int index=formation_index-1; index>=0; index--)
      if(high[index]>=threshold)
         return(true);
   return(false);
  }

//+------------------------------------------------------------------+
void DrawGap(const string id,const datetime start_time,const datetime end_time,
             const double top,const double bottom,const bool bullish,
             const bool mitigated)
  {
   const string rectangle_name=g_prefix+"BOX_"+id;
   color base_color=(mitigated ? InpMitigatedColor :
                     (bullish ? InpBullishGapColor : InpBearishGapColor));

   if(!ObjectCreate(0,rectangle_name,OBJ_RECTANGLE,0,start_time,top,end_time,bottom))
      return;

   ObjectSetInteger(0,rectangle_name,OBJPROP_COLOR,ColorToARGB(base_color,InpTransparency));
   ObjectSetInteger(0,rectangle_name,OBJPROP_FILL,true);
   ObjectSetInteger(0,rectangle_name,OBJPROP_BACK,true);
   ObjectSetInteger(0,rectangle_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,rectangle_name,OBJPROP_HIDDEN,true);

   if(!InpShowLabels)
      return;

   const string label_name=g_prefix+"TEXT_"+id;
   const double label_price=(top+bottom)*0.5;
   if(ObjectCreate(0,label_name,OBJ_TEXT,0,start_time,label_price))
     {
      string label=(bullish ? "Bullish FVG" : "Bearish FVG");
      if(mitigated)
         label+="  filled";
      ObjectSetString(0,label_name,OBJPROP_TEXT,label);
      ObjectSetString(0,label_name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,label_name,OBJPROP_COLOR,mitigated ? clrGray :
                       (bullish ? clrForestGreen : clrFireBrick));
      ObjectSetInteger(0,label_name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,label_name,OBJPROP_HIDDEN,true);
     }
  }

//+------------------------------------------------------------------+
void BuildGaps(const int rates_total,const datetime &time[],
               const double &high[],const double &low[])
  {
   ObjectsDeleteAll(0,g_prefix);
   const int seconds=PeriodSeconds(_Period);
   const int bar_seconds=(seconds>0 ? seconds : 60);
   const int oldest=MathMin(InpMaximumBars,rates_total-3);
   bool new_bullish=false,new_bearish=false;

   for(int index=oldest; index>=1; index--)
     {
      const double bullish_size=low[index]-high[index+2];
      const double bearish_size=low[index+2]-high[index];
      const datetime end_time=time[index]+(datetime)(bar_seconds*InpExtensionBars);
      const string id=IntegerToString((int)time[index]);

      if(InpShowBullishGaps && bullish_size>=InpMinimumGapPoints*_Point)
        {
         const double top=low[index];
         const double bottom=high[index+2];
         const bool mitigated=IsBullishMitigated(index,bottom,top,low);
         if(!mitigated || !InpHideMitigated)
            DrawGap(id+"_B",time[index+2],end_time,top,bottom,true,mitigated);
         if(index==1 && !mitigated)
            new_bullish=true;
        }

      if(InpShowBearishGaps && bearish_size>=InpMinimumGapPoints*_Point)
        {
         const double top=low[index+2];
         const double bottom=high[index];
         const bool mitigated=IsBearishMitigated(index,bottom,top,high);
         if(!mitigated || !InpHideMitigated)
            DrawGap(id+"_S",time[index+2],end_time,top,bottom,false,mitigated);
         if(index==1 && !mitigated)
            new_bearish=true;
        }
     }

   if(InpEnableAlerts && time[1]!=g_last_alert_bar)
     {
      if(new_bullish)
         Alert(_Symbol," ",EnumToString(_Period)," new bullish fair value gap");
      if(new_bearish)
         Alert(_Symbol," ",EnumToString(_Period)," new bearish fair value gap");
      if(new_bullish || new_bearish)
         g_last_alert_bar=time[1];
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   if(rates_total<10)
      return(0);

   if(time[0]!=g_last_bar || prev_calculated==0)
     {
      g_last_bar=time[0];
      BuildGaps(rates_total,time,high,low);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
