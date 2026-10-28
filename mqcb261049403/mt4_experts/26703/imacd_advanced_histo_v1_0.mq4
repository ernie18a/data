//======================================================================================================================================================//
#property copyright "Copyright 2019, Nikolaos Pantzos"
#property link      "https://www.mql5.com/en/users/pannik"
#property version   "1.0"
#property strict
//======================================================================================================================================================//
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
//======================================================================================================================================================//
extern int FastPeriod=12;
extern int SlowPeriod=26;
extern int SignalPeriod=9;
extern ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE;
extern int BarsForAveragePrice=140;
extern double PercentageLevelUp=25;
extern double PercentageLevelDn=25;
//======================================================================================================================================================//
double UpBuffer[];
double DnBuffer[];
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   string iName="iMACD_Histo("+IntegerToString(FastPeriod)+","+IntegerToString(SlowPeriod)+","+IntegerToString(SignalPeriod)+")";
//--------------------------------------------------------------------------------
   IndicatorShortName(iName);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS));
//--------------------------------------------------------------------------------
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
//--------------------------------------------------------------------------------
   SetIndexLabel(0,"UpTrend");
   SetIndexLabel(1,"DownTrend");
//--------------------------------------------------------------------------------
   SetIndexDrawBegin(0,SlowPeriod);
   SetIndexDrawBegin(1,SlowPeriod);
//--------------------------------------------------------------------------------
   return(INIT_SUCCEEDED);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
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
//--------------------------------------------------------------------------------
   int IndicatorShift=0;
   int IndicatorTrend=0;
   double IndicatorValue=0;
   double AvrgValue=0;
//--------------------------------------------------------------------------------
   for(IndicatorShift=Bars-SlowPeriod-1; IndicatorShift>=0; IndicatorShift--)
     {
      AvrgValue=iMACD(NULL,0,FastPeriod,BarsForAveragePrice,SignalPeriod,AppliedPrice,MODE_MAIN,IndicatorShift);
      IndicatorValue=iMACD(NULL,0,FastPeriod,SlowPeriod,SignalPeriod,AppliedPrice,MODE_MAIN,IndicatorShift);
      //---
      if(IndicatorValue>AvrgValue+((AvrgValue*PercentageLevelDn)/100))
         IndicatorTrend=-1;
      if(IndicatorValue<AvrgValue-((AvrgValue*PercentageLevelUp)/100))
         IndicatorTrend=1;
      //---
      if(IndicatorTrend>0)
        {
         if(IndicatorValue>AvrgValue-((AvrgValue*PercentageLevelUp)/100)/2)
            UpBuffer[IndicatorShift]=1.0;
         else
            UpBuffer[IndicatorShift]=1.0;
         DnBuffer[IndicatorShift]=0;
        }
      //---
      if(IndicatorTrend<0)
        {
         if(IndicatorValue<AvrgValue+((AvrgValue*PercentageLevelDn)/100)/2)
            DnBuffer[IndicatorShift]=1.0;
         else
            DnBuffer[IndicatorShift]=1.0;
         UpBuffer[IndicatorShift]=0;
        }
     }
//-----------------------------------------------------------------------------------
   return(rates_total);
//-----------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
