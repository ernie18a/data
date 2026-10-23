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
extern int K_Period=5;
extern int D_Perdiod=3;
extern int Slowing=3;
extern ENUM_MA_METHOD MA_Method=MODE_SMA;
extern int LevelTrendUp=20;
extern int LevelTrendDn=80;
//======================================================================================================================================================//
double UpBuffer[];
double DnBuffer[];
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   string iName="iStochastic_Histo("+IntegerToString(K_Period)+","+IntegerToString(D_Perdiod)+","+IntegerToString(Slowing)+")";
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
   SetIndexDrawBegin(0,K_Period);
   SetIndexDrawBegin(1,K_Period);
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
//--------------------------------------------------------------------------------
   for(IndicatorShift=Bars-K_Period-1; IndicatorShift>=0; IndicatorShift--)
     {
      IndicatorValue=iStochastic(NULL,0,K_Period,D_Perdiod,Slowing,MA_Method,0,MODE_MAIN,IndicatorShift);
      //---
      if(IndicatorValue>LevelTrendDn)
         IndicatorTrend=1;
      if(IndicatorValue<LevelTrendUp)
         IndicatorTrend=-1;
      //---
      if(IndicatorTrend>0)
        {
         if(IndicatorValue>(double)LevelTrendUp+((double)LevelTrendUp/20))
            UpBuffer[IndicatorShift]=1.0;
         else
            UpBuffer[IndicatorShift]=1.0;
         DnBuffer[IndicatorShift]=0;
        }
      //---
      if(IndicatorTrend<0)
        {
         if(IndicatorValue<(double)LevelTrendDn-((double)LevelTrendDn/20))
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
