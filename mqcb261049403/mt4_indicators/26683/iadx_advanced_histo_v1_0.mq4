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
extern int BarsForAverage=24;
extern ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE;
//======================================================================================================================================================//
double UpBuffer[];
double DnBuffer[];
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   string iName="iADX_Histo("+IntegerToString(PeriodIndicator)+")";
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
   double IndicatorValuePlus=0;
   double IndicatorValueMinus=0;
//--------------------------------------------------------------------------------
   for(IndicatorShift=Bars-PeriodIndicator-1; IndicatorShift>=0; IndicatorShift--)
     {
      for(int i=0; i<BarsForAverage; i++)
        {
         IndicatorValuePlus+=iADX(NULL,0,PeriodIndicator,AppliedPrice,MODE_PLUSDI,IndicatorShift+i);
         IndicatorValueMinus+=iADX(NULL,0,PeriodIndicator,AppliedPrice,MODE_MINUSDI,IndicatorShift+i);
        }
      //---
      IndicatorValuePlus/=BarsForAverage;
      IndicatorValueMinus/=BarsForAverage;
      //---
      if(IndicatorValuePlus>IndicatorValueMinus)
         IndicatorTrend=1;
      if(IndicatorValuePlus<IndicatorValueMinus)
         IndicatorTrend=-1;
      //---
      if(IndicatorTrend>0)
        {
         if(IndicatorValuePlus>IndicatorValueMinus)
            UpBuffer[IndicatorShift]=1.0;
         else
            UpBuffer[IndicatorShift]=1.0;
         DnBuffer[IndicatorShift]=0;
        }
      //---
      if(IndicatorTrend<0)
        {
         if(IndicatorValuePlus<IndicatorValueMinus)
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
