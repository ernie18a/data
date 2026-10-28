//+------------------------------------------------------------------+
//|                                                      qqe_mtf.mq5 |
//|                                           Copyright © 2010, AK20 |
//|                                             traderak20@gmail.com |
//|                                                                  |
//|                                                        Based on: |
//|                                                          QQE.mq5 |
//|                                      Copyright © 2010, EarnForex |
//|                                         http://www.earnforex.com |
//|                             Based on version by Tim Hyder (2008) |
//|                         Based on version by Roman Ignatov (2006) |
//+------------------------------------------------------------------+
#property copyright   "2010, traderak20@gmail.com"
//#property version     "V02"

/*--------------------------------------------------------------------
2010 09 26: v02   Improved display of values on timeframes smaller than the chart's timeframe
                     Set buffers to EMPTY_VALUE instead of 0 after: if(convertedTime<tempTimeArray_TF2[0])
                  Code optimization
                     Removed PLOT_DRAW_BEGIN from OnInit() - inherited from single time frame indicator
                     Moved ArraySetAsSeries of buffers and arrays into OnInit()
----------------------------------------------------------------------*/

#property description "QQE - Qualitative Quantitative Estimation, Multi-timeframe"
#property description "Calculated as two indicators:"
#property description "1) MA on RSI"
#property description "2) Difference of MA on RSI and MA of MA of ATR of MA of RSI"
#property description "The signal for buy is when blue line crosses level 50 from below"
#property description "after crossing the yellow line from below."
#property description "The signal for sell is when blue line crosses level 50 from above"
#property description "after crossing the yellow line from above."

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_plots   2

//--- indicator plots
#property indicator_width1 2
#property indicator_color1 DodgerBlue
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width2 1
#property indicator_color2 Yellow
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DOT

//--- indicator levels
#property indicator_level1 50
#property indicator_levelcolor Aqua
#property indicator_levelstyle STYLE_DOT

//--- input parameters
input ENUM_TIMEFRAMES      InpTimeFrame_2=PERIOD_H1;                          // Timeframe 2 (TF2) period
input string               InpIndicator_TF1="qqe";                            // Location of single timeframe indicator
input int                  InpSF=5;                                           // Smoothing Factor
input int                  InpAlertLevel=50;                                  // Alert level
input bool                 InpMsgAlerts=false;                                // Use alert message
input bool                 InpEmailAlerts=false;                              // Send email alert
input bool                 InpSoundAlerts=false;                              // Play sound alert
input string               InpSoundAlertFile="alert.wav";                     // Sound alert
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;                       // Applied price

//--- indicator buffers
double                     ExtRsiMaBuffer_TF2[];
double                     ExtTrLevelSlowBuffer_TF2[];

//--- arrays TF2 - to retrieve TF 2 values of buffers and/or timeseries
double                     ExtRsiMaArray_TF2[];                               // intermediate array to hold TF2 Fast RSI MA buffer values
double                     ExtTrLevelSlowArray_TF2[];                         // intermediate array to hold TF2 Slow RSI MA buffer values

//--- global variables
int                        PeriodRatio=1;                                     // ratio between timeframe 1 (TF1) and timeframe 2 (TF2)
int                        PeriodSeconds_TF1;                                 // TF1 period in seconds
int                        PeriodSeconds_TF2;                                 // TF2 period in seconds
int                        RSI_Period=14;
int                        Wilders_Period;
int                        SmoothingFactor;

//--- indicator handles TF2
int                        ExtQqeHandle_TF2;                                  // QQE handle TF2

//--- turn on/off error messages
bool                       ShowErrorMessages=true;                            // turn on/off error messages for debugging
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set Wilders Period
   Wilders_Period=RSI_Period*2-1;

//--- check smoothing factor
   SmoothingFactor=InpSF;
   if(SmoothingFactor<=0) SmoothingFactor=5;

//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRsiMaBuffer_TF2,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTrLevelSlowBuffer_TF2,INDICATOR_DATA);

//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtRsiMaBuffer_TF2,true);
   ArraySetAsSeries(ExtTrLevelSlowBuffer_TF2,true);
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtRsiMaArray_TF2,true);
   ArraySetAsSeries(ExtTrLevelSlowArray_TF2,true);

//--- name for plots
   PlotIndexSetString(0,PLOT_LABEL,"Fast RSI MA_TF2");
   PlotIndexSetString(1,PLOT_LABEL,"Slow RSI MA_TF2");

//--- calculate at which bar to start drawing indicators
   PeriodSeconds_TF1=PeriodSeconds();
   PeriodSeconds_TF2=PeriodSeconds(InpTimeFrame_2);

   if(PeriodSeconds_TF1<PeriodSeconds_TF2)
      PeriodRatio=PeriodSeconds_TF2/PeriodSeconds_TF1;

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,4);

//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,-5);
   IndicatorSetDouble(INDICATOR_MAXIMUM,105);

//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"QQE("+IntegerToString(SmoothingFactor)+")");

//--- get QQE handle
   ExtQqeHandle_TF2=iCustom(NULL,InpTimeFrame_2,InpIndicator_TF1,InpSF,InpAlertLevel,InpMsgAlerts,InpEmailAlerts,InpSoundAlerts,InpSoundAlertFile,InpAppliedPrice);

   if(ExtQqeHandle_TF2==INVALID_HANDLE)
     {
      return(-1);
     }
   return(0);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| QQE                                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(Time,true);

//--- check for data
   int bars_TF2=Bars(NULL,InpTimeFrame_2);
   if(bars_TF2<(RSI_Period+SmoothingFactor+1+Wilders_Period+Wilders_Period))
      return(0);

//--- not all data may be calculated
   int calculated_TF2;

   calculated_TF2=BarsCalculated(ExtQqeHandle_TF2);
   if(calculated_TF2<bars_TF2)
     {
      if(ShowErrorMessages) Print("Not all data of ExtQqeHandle_TF2 has been calculated (",calculated_TF2," bars). Error",GetLastError());
      return(0);
     }

//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated;

//--- create variable required to convert between TF1 and TF2
   datetime convertedTime=0;

//--- loop through TF1 bars to set buffer TF1 values
   for(int i=limit;i>=0;i--)
     {
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 which is to close during the current TF1 bar
      //--- use this for calculations with PRICE_CLOSE, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      if(InpAppliedPrice!=PRICE_OPEN)
         convertedTime=Time[i]+PeriodSeconds_TF1-PeriodSeconds_TF2;
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 at the same time or before the current TF1 bar
      //--- use this for calculations with PRICE_OPEN
      if(InpAppliedPrice==PRICE_OPEN)
         convertedTime=Time[i];

      //--- check if TF2 data is available at convertedTime
      datetime tempTimeArray_TF2[];
      CopyTime(NULL,InpTimeFrame_2,calculated_TF2-1,1,tempTimeArray_TF2);
      //--- no TF2 data available
      if(convertedTime<tempTimeArray_TF2[0])
        {
         ExtRsiMaBuffer_TF2[i]=EMPTY_VALUE;
         ExtTrLevelSlowBuffer_TF2[i]=EMPTY_VALUE;
         continue;
        }

      //--- get Fast RSI MA buffer values of TF2
      if(CopyBuffer(ExtQqeHandle_TF2,0,convertedTime,1,ExtRsiMaArray_TF2)<=0)
        {
         if(ShowErrorMessages) Print("Getting ICycle Arrow TF2 failed! Error",GetLastError());
         return(0);
        }
      //--- set Fast RSI MA TF2 buffer on TF1
      else
         ExtRsiMaBuffer_TF2[i]=ExtRsiMaArray_TF2[0];

      //--- get Slow RSI MA buffer values of TF2
      if(CopyBuffer(ExtQqeHandle_TF2,1,convertedTime,1,ExtTrLevelSlowArray_TF2)<=0)
        {
         if(ShowErrorMessages) Print("Getting ICycle Arrow color TF2 failed! Error",GetLastError());
         return(0);
        }
      //--- set Slow RSI MA TF2 buffer on TF1
      else
         ExtTrLevelSlowBuffer_TF2[i]=ExtTrLevelSlowArray_TF2[0];
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
