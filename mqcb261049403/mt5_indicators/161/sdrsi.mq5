//+------------------------------------------------------------------+
//|                                                        SDRSI.mq5 |
//|                                                  2010, KTS Group |
//|                                               http://www.koss.su |
//+------------------------------------------------------------------+
#property copyright "2010, KTS Group"
#property link      "http://www.koss.su"
#property version   "1.00"
#property description "Relative Strength Index of Volatility"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 30
#property indicator_level3 40
#property indicator_level4 50
#property indicator_level5 60
#property indicator_level6 70
#property indicator_level7 80
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  Green
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
//--- input parameters
input int FastPeriodRSI=24;                // Fast period
input int SlowPeriodRSI=120;               // Slow period
input ENUM_MA_METHOD InpMAMethod=MODE_SMA; // Method
input ENUM_APPLIED_PRICE InpAppPrice=PRICE_CLOSE;

//--- indicator buffers
double    FastRSIBuffer[];
double    SlowRSIBuffer[];

//--- global variable
int       ExtFastRSI;
int       ExtSlowRSI;
int   hFastStdDev,hFastRSI,hSlowStdDev,hSlowRSI;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(FastPeriodRSI<=1)
     {
      ExtFastRSI=24;
     }
   else ExtFastRSI=FastPeriodRSI;

   if(SlowPeriodRSI<=1)
     {
      ExtSlowRSI=120;
     }
   else ExtSlowRSI=SlowPeriodRSI;

   SetIndexBuffer(0,FastRSIBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtFastRSI);

   SetIndexBuffer(1,SlowRSIBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,ExtSlowRSI);

   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,"SDRSI("+string(ExtFastRSI)+"/"+string(ExtSlowRSI)+")");
   SetHandles();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int ToCopy;
   if(rates_total<prev_calculated || prev_calculated==0) //--- recalc at first start
     {
      ToCopy=rates_total;
      if(CopyBuffer(hFastRSI,0,0,ToCopy,FastRSIBuffer)<=0) return(0);
      if(CopyBuffer(hSlowRSI,0,0,ToCopy,SlowRSIBuffer)<=0) return(0);
     }
   else
     {
      if(rates_total>prev_calculated) //--- recalc only at new bar
        {
         ToCopy=rates_total-prev_calculated+1;
         if(CopyBuffer(hFastRSI,0,0,ToCopy,FastRSIBuffer)<=0) return(0);
         if(CopyBuffer(hSlowRSI,0,0,ToCopy,SlowRSIBuffer)<=0) return(0);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| SetHandles                                                       |
//+------------------------------------------------------------------+
void SetHandles(void)
  {
   hSlowStdDev=iStdDev(NULL,0,ExtSlowRSI,0,InpMAMethod,InpAppPrice);
   hFastStdDev=iStdDev(NULL,0,ExtFastRSI,0,InpMAMethod,InpAppPrice);
   hFastRSI=iRSI(NULL,0,ExtFastRSI,hFastStdDev);
   hSlowRSI=iRSI(NULL,0,ExtSlowRSI,hSlowStdDev);
  }
//+------------------------------------------------------------------+
