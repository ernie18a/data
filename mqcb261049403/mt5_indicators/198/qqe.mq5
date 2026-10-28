//+------------------------------------------------------------------+
//|                                                          qqe.mq5 |
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
2010 09 26: v02   Code rewritten to make the indicator work better with MetaTrader5
                  Fixed wrong values returned at the start of the chart
----------------------------------------------------------------------*/

#property description "QQE - Qualitative Quantitative Estimation."
#property description "Calculated as two indicators:"
#property description "1) MA on RSI"
#property description "2) Difference of MA on RSI and MA of MA of ATR of MA of RSI"
#property description "The signal for buy is when blue line crosses level 50 from below"
#property description "after crossing the yellow line from below."
#property description "The signal for sell is when blue line crosses level 50 from above"
#property description "after crossing the yellow line from above."

#include <MovingAverages.mqh>

#property indicator_separate_window

#property indicator_buffers 6
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
input int                  InpSF=5;                         // Smoothing Factor
input int                  InpAlertLevel=50;                // Alert level
input bool                 InpMsgAlerts=false;              // Use alert message
input bool                 InpEmailAlerts=false;            // Send email alert
input bool                 InpSoundAlerts=false;            // Play sound alert
input string               InpSoundAlertFile="alert.wav";   // Sound alert
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;     // Applied price

//--- indicator buffers
double                     ExtRsiMaBuffer[];                // moving average of RSI
double                     ExtTrLevelSlowBuffer[];          // true range level
double                     ExtRsiBuffer[];                  // RSI
double                     ExtAtrRsiBuffer[];               // average true range of RSI
double                     ExtMaAtrRsiBuffer[];             // moving average of true range of RSI
double                     ExtMaMaAtrRsiBuffer[];           // moving average of moving average of true range of RSI

//--- indicator handles
int                        RsiHandle;

//--- global variables
int                        RSI_Period=14;
int                        Wilders_Period;
int                        SmoothingFactor;
int                        AlertLevel;
int                        LastAlertBar;

//--- turn on/off error messages
bool                       ShowErrorMessages=true;          // turn on/off error messages for debugging
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

//--- check alert level
   AlertLevel=InpAlertLevel;
   if(AlertLevel<0 || AlertLevel>100) AlertLevel=50;

//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRsiMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTrLevelSlowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtAtrRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtMaAtrRsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtMaMaAtrRsiBuffer,INDICATOR_CALCULATIONS);

//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtRsiMaBuffer,true);
   ArraySetAsSeries(ExtTrLevelSlowBuffer,true);
   ArraySetAsSeries(ExtRsiBuffer,true);
   ArraySetAsSeries(ExtAtrRsiBuffer,true);
   ArraySetAsSeries(ExtMaAtrRsiBuffer,true);
   ArraySetAsSeries(ExtMaMaAtrRsiBuffer,true);

//--- name for plots
   PlotIndexSetString(0,PLOT_LABEL,"Fast RSI MA");
   PlotIndexSetString(1,PLOT_LABEL,"Slow RSI MA");

//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RSI_Period+SmoothingFactor);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,RSI_Period+SmoothingFactor+1+Wilders_Period+Wilders_Period);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,4);

//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,-5);
   IndicatorSetDouble(INDICATOR_MAXIMUM,105);

//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"QQE("+IntegerToString(SmoothingFactor)+")");

//--- get indicator handles
   RsiHandle=iRSI(NULL,0,RSI_Period,InpAppliedPrice);

   if(RsiHandle==INVALID_HANDLE)
     {
      return(-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Converts timeframe period to string                              |
//+------------------------------------------------------------------+
string TF2Str(int period)
  {
   switch(period)
     {
      case PERIOD_M1:  return("M1");
      case PERIOD_M2:  return("M2");
      case PERIOD_M3:  return("M3");
      case PERIOD_M4:  return("M4");
      case PERIOD_M5:  return("M5");
      case PERIOD_M6:  return("M6");
      case PERIOD_M10:  return("M10");
      case PERIOD_M12:  return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20:  return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H2:  return("H2");
      case PERIOD_H3:  return("H3");
      case PERIOD_H4:  return("H4");
      case PERIOD_H6:  return("H6");
      case PERIOD_H8:  return("H8");
      case PERIOD_H12:  return("H12");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN");
     }

   return(IntegerToString(Period()));
  }
//+------------------------------------------------------------------+
//| QQE	       		                                                |
//+------------------------------------------------------------------+
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
//--- check for data
   if(rates_total<=MathMax(Wilders_Period,SmoothingFactor))
      return(0);

//--- not all data may be calculated
   int calculated;

   calculated=BarsCalculated(RsiHandle);
   if(calculated<rates_total)
     {
      if(ShowErrorMessages) Print("Not all data of RsiHandle has been calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }

//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      //--- older bars ([1]) are needed to calculate the current bar
      limit=rates_total-1-1;
   else
      limit=rates_total-prev_calculated;

//--- calculate how many bars need to be recalculated
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }

//--- get RSI buffer values
   if(CopyBuffer(RsiHandle,0,0,to_copy,ExtRsiBuffer)<=0)
     {
      if(ShowErrorMessages) Print("Getting RSI failed! Error",GetLastError());
      return(0);
     }

//--- get EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period,SmoothingFactor,ExtRsiBuffer,ExtRsiMaBuffer);

//--- get ATR of EMA of RSI buffer values
   for(int i=limit;i>=0;i--)
      ExtAtrRsiBuffer[i]=MathAbs(ExtRsiMaBuffer[i+1]-ExtRsiMaBuffer[i]);

//--- get EMA of ATR of EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period+SmoothingFactor+1,Wilders_Period,ExtAtrRsiBuffer,ExtMaAtrRsiBuffer);

//--- get EMA of EMA of ATR of EMA of RSI buffer values
   ExponentialMAOnBuffer(rates_total,prev_calculated,RSI_Period+SmoothingFactor+1+Wilders_Period,Wilders_Period,ExtMaAtrRsiBuffer,ExtMaMaAtrRsiBuffer);

//--- get ExtTrLevelSlowBuffer values
   double rsi0,rsi1,dar,tr,dv;

   tr=ExtTrLevelSlowBuffer[limit+1];
   rsi1=ExtRsiMaBuffer[limit+1];

   for(int i=limit+1;i>=0;i--)
     {
      rsi0=ExtRsiMaBuffer[i];
      dar=ExtMaMaAtrRsiBuffer[i]*4.236;
      dv=tr;

      if(rsi0<tr)
        {
         tr=rsi0+dar;
         if((rsi1<dv) && (tr>dv)) tr=dv;
        }
      else if(rsi0>tr)
        {
         tr=rsi0-dar;
         if((rsi1>dv) && (tr<dv)) tr=dv;
        }

      ExtTrLevelSlowBuffer[i]=tr;
      rsi1=rsi0;
     }

//--- check if alerts are set
   if((InpMsgAlerts || InpSoundAlerts || InpEmailAlerts) && rates_total>LastAlertBar)
     {
      //--- check if alert level is hit and set direction of alert
      int AlertDirection=0;
      if(ExtRsiMaBuffer[1]<AlertLevel && ExtRsiMaBuffer[0]>=AlertLevel) AlertDirection=1;
      if(ExtRsiMaBuffer[1]>AlertLevel && ExtRsiMaBuffer[0]<=AlertLevel) AlertDirection=-1;

      if(AlertDirection==1 || AlertDirection==-1)
        {
         //--- create alert subject
         string AlertSubj=Symbol()+", TF: "+TF2Str(Period())+", "+IntegerToString(AlertLevel)+" level Cross ";
         if(AlertDirection==1) AlertSubj=AlertSubj+"UP";
         if(AlertDirection==-1) AlertSubj=AlertSubj+"DOWN";
         //--- create alert message
         string AlertMsg=AlertSubj+" @ "+TimeToString(TimeLocal(),TIME_SECONDS);
         //--- pop up alert message
         if(InpMsgAlerts) Alert(AlertMsg);
         //--- send email alert message
         if(InpEmailAlerts)
           {
            bool mailsent=false;
            mailsent=SendMail(AlertSubj,AlertMsg);
            if(mailsent==false && ShowErrorMessages)
               Print("Email alert was not sent! ",AlertMsg," --- Error",GetLastError());
           }
         //--- play sound alert
         if(InpSoundAlerts)
           {
            bool playsoundfile=false;
            playsoundfile=PlaySound(InpSoundAlertFile);
            if(playsoundfile==false && ShowErrorMessages)
               Print("Soundfile not found:\"",InpSoundAlertFile,"\" --- Error",GetLastError());
           }
         //--- send only one alert per bar
         LastAlertBar=rates_total;
        }
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
