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
extern int PeriodIndicator=20;
extern int ShiftIndicator=0;
extern double DeviationIndicator=2.0;
extern ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE;
//======================================================================================================================================================//
double UpBuffer[];
double DnBuffer[];
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   string iName="iBands_Histo("+IntegerToString(PeriodIndicator)+","+IntegerToString(ShiftIndicator)+","+DoubleToStr(DeviationIndicator,2)+")";
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
   double IndicatorValueUpper=0;
   double IndicatorValueLower=0;
   double IndicatorMovingAvrg=0;
   double PriceClose=0;
//--------------------------------------------------------------------------------
   for(IndicatorShift=Bars-PeriodIndicator-1; IndicatorShift>=0; IndicatorShift--)
     {
      IndicatorValueUpper=iBands(NULL,0,PeriodIndicator,DeviationIndicator,ShiftIndicator,AppliedPrice,MODE_UPPER,IndicatorShift);
      IndicatorValueLower=iBands(NULL,0,PeriodIndicator,DeviationIndicator,ShiftIndicator,AppliedPrice,MODE_LOWER,IndicatorShift);
      IndicatorMovingAvrg=iMA(NULL,0,PeriodIndicator,ShiftIndicator,MODE_SMA,AppliedPrice,IndicatorShift);
      PriceClose=iClose(NULL,0,IndicatorShift);
      //---
      if(PriceClose>IndicatorValueUpper)
         IndicatorTrend=1;
      if(PriceClose<IndicatorValueLower)
         IndicatorTrend=-1;
      //---
      if(IndicatorTrend>0)
        {
         if(PriceClose>IndicatorMovingAvrg)
            UpBuffer[IndicatorShift]=1.0;
         else
            UpBuffer[IndicatorShift]=1.0;
         DnBuffer[IndicatorShift]=0;
        }
      //---
      if(IndicatorTrend<0)
        {
         if(PriceClose<IndicatorMovingAvrg)
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
