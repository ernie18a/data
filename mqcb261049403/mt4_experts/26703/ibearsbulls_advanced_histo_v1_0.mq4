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
extern int PeriodIndicator=14;
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
   string iName="iBearsBulls_Histo("+IntegerToString(PeriodIndicator)+"/"+IntegerToString(BarsForAveragePrice)+")";
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
   SetIndexDrawBegin(0,PeriodIndicator);
   SetIndexDrawBegin(1,PeriodIndicator);
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
   double IndicatorValueUp=0;
   double IndicatorValueDn=0;
   double AvrgValueUp=0;
   double AvrgValueDn=0;
//--------------------------------------------------------------------------------
   for(IndicatorShift=Bars-PeriodIndicator-1; IndicatorShift>=0; IndicatorShift--)
     {
      AvrgValueUp=iBullsPower(NULL,0,BarsForAveragePrice,0,IndicatorShift);
      AvrgValueDn=iBearsPower(NULL,0,BarsForAveragePrice,0,IndicatorShift);
      //---
      IndicatorValueUp=iBullsPower(NULL,0,PeriodIndicator,0,IndicatorShift);
      IndicatorValueDn=iBearsPower(NULL,0,PeriodIndicator,0,IndicatorShift);
      //---
      if(IndicatorValueDn>AvrgValueDn+((AvrgValueDn*PercentageLevelDn)/100))
         IndicatorTrend=-1;
      if(IndicatorValueUp<AvrgValueUp-((AvrgValueUp*PercentageLevelUp)/100))
         IndicatorTrend=1;
      //---
      if(IndicatorTrend>0)
        {
         if(IndicatorValueUp>AvrgValueUp-((AvrgValueUp*PercentageLevelUp)/100)/2)
            UpBuffer[IndicatorShift]=1.0;
         else
            UpBuffer[IndicatorShift]=1.0;
         DnBuffer[IndicatorShift]=0;
        }
      //---
      if(IndicatorTrend<0)
        {
         if(IndicatorValueDn<AvrgValueDn+((AvrgValueDn*PercentageLevelDn)/100)/2)
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
