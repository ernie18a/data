#property copyright "BestForexScript.Com"
#property link      "https://bestforexscript.com"
#property version   "1.00"
#property description "Download Expert Advisors and Indicator for FREE!"
#property description "Want an EA with Indicator, contact me on telegram: @sopheak_khmer_trader"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 3

#property indicator_label1 "Range High"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "Range Low"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "Range Fill"
#property indicator_type3 DRAW_FILLING
#property indicator_color3 clrDodgerBlue,clrRed

input string InpFromTime = "00:00";  // Range Start Time
input string InpToTime = "05:00";    // Range End Time
input string InpEndTime = "20:00";   // Trade End Time
input int InpMinPip = 250;//Minimum Size (point)
input int InpMaxPip = 500;//Maximum Size (point)

int maxday = 10;
double ZoneHighBuffer[], ZoneLowBuffer[];
double FillHighBuffer[], FillLowBuffer[];
double FillColors[];

int OnInit()
{
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   SetIndexBuffer(0,ZoneHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZoneLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,FillHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,FillLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,FillColors,INDICATOR_COLOR_INDEX);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "RangeBreakOut ("+InpFromTime+"-"+InpToTime+")");
   return(INIT_SUCCEEDED);
}




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
   if(PeriodSeconds(PERIOD_CURRENT) > PeriodSeconds(PERIOD_H1))return(0);
   if(maxday > iBars(_Symbol,PERIOD_D1))maxday = iBars(_Symbol,PERIOD_D1);
   if(rates_total <4) return(0);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ZoneHighBuffer,true);
   ArraySetAsSeries(ZoneLowBuffer,true);
   ArraySetAsSeries(FillHighBuffer,true);
   ArraySetAsSeries(FillLowBuffer,true);
   ArraySetAsSeries(FillColors,true);
   datetime dtime = iTime(_Symbol,PERIOD_D1,maxday -1);
   int limit = iBarShift(_Symbol,_Period,dtime,false);
   for(int i = limit; i>=0; i--)
   {
      MqlDateTime dt;
      TimeToStruct(time[i],dt);
      datetime fromtime = StringToTime(string(dt.year)+"."+string(dt.mon)+"."+string(dt.day)+" " + InpFromTime + ":00");
      datetime totime = StringToTime(string(dt.year)+"."+string(dt.mon)+"."+string(dt.day)+" " + InpToTime + ":00");
      datetime endtime = StringToTime(string(dt.year)+"."+string(dt.mon)+"."+string(dt.day)+" " + InpEndTime + ":00");
      if(totime < fromtime)totime += 24*3600;
      if(endtime < fromtime)endtime += 24*3600;
      int fromshift = iBarShift(_Symbol,_Period,fromtime,false);
      int toshift = iBarShift(_Symbol,_Period,totime,false);
      int highest = iHighest(_Symbol,_Period,MODE_HIGH,fromshift-toshift+1,toshift);
      int lowest = iLowest(_Symbol,_Period,MODE_LOW,fromshift-toshift+1,toshift);
      double zhigh = high[highest];
      double zlow = low[lowest];
      double zlength = zhigh - zlow;
      if(zhigh == 0 || zlow == 0)continue;
      ZoneHighBuffer[i] = EMPTY_VALUE;
      ZoneLowBuffer[i] = EMPTY_VALUE;
      FillHighBuffer[i] = 0;
      FillLowBuffer[i] = 0;
      if(time[i]>=fromtime && time[i]<=endtime)
      {
         if(time[i] <= totime)
         {
            if(zlength >= InpMinPip*_Point && zlength <= InpMaxPip*_Point)
            {
               FillHighBuffer[i] = zhigh;
               FillLowBuffer[i] = zlow;
               FillColors[i] = 0;
            }
            else 
            {
               FillHighBuffer[i] = zlow;
               FillLowBuffer[i] = zhigh;
               FillColors[i] = 1;
            }
         }
         ZoneHighBuffer[i] = zhigh;
         ZoneLowBuffer[i] = zlow;
      }
   } 
   return(rates_total);
}