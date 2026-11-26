//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//
//--- input parameters
//

input int             inpPeriodsToDisplay = 10;             // Display fibos for last (nnn) weeks
input string          inpUniqueID         = "WeeklyFibos1"; // Unique ID for fibos
input color           inpLevelsuColor     = clrDodgerBlue;  // Levels above open color
input color           inpLevelsdColor     = clrRed;         // Levels bellow open color
input color           inpLevels0Color     = clrDarkGray;    // Level open color
input ENUM_LINE_STYLE inpLevel0Style      = STYLE_DOT;      // Level zero style
input ENUM_LINE_STYLE inpLevelsStyle      = STYLE_SOLID;    // Levels style
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"Weekly fibo levels");
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,inpUniqueID+":");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double _fiboLevels[21]={0,0.236,0.382,0.5,0.618,1,1.61,2.61,3.61,4.23,4.61,-0.236,-0.382,-0.5,-0.618,-1,-1.61,-2.61,-3.61,-4.23,-4.61};
//
//---
//
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   MqlRates _weeklyRates[];
   int _weeklyRatesCopied=CopyRates(_Symbol,PERIOD_W1,0,inpPeriodsToDisplay+1,_weeklyRates);

   for(int i=1; i<_weeklyRatesCopied && !_StopFlag; i++)
     {
      string _name  = inpUniqueID+":"+(string)i;
      double _range = _weeklyRates[i-1].high-_weeklyRates[i-1].low;
      ObjectCreate(0,_name,OBJ_FIBO,0,_weeklyRates[i].time,_weeklyRates[i].open+_range,_weeklyRates[i].time+PeriodSeconds(PERIOD_W1),_weeklyRates[i].open);
      ObjectSetInteger(0,_name,OBJPROP_RAY,false);
      ObjectSetInteger(0,_name,OBJPROP_LEVELS,21);
      ObjectSetInteger(0,_name,OBJPROP_COLOR,clrNONE);
      for(int k=0; k<21; k++)
        {
         ObjectSetInteger(0,_name,OBJPROP_LEVELCOLOR,k,k==0?inpLevels0Color:_fiboLevels[k]>0?inpLevelsuColor:inpLevelsdColor);
         ObjectSetInteger(0,_name,OBJPROP_LEVELSTYLE,k,k==0?inpLevel0Style:inpLevelsStyle);
         ObjectSetDouble(0,_name,OBJPROP_LEVELVALUE,k,_fiboLevels[k]);
         ObjectSetString(0,_name,OBJPROP_LEVELTEXT,k,DoubleToString(_fiboLevels[k]*100,1)+" %");
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
