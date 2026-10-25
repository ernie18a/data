//+------------------------------------------------------------------+
//|                                                   TMS_Arrows.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "TMS Arrows indicator"
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "TMS Bullish"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "TMS Bearish"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- enums
enum ENUM_SIGNAL_POINT_ANCHOR
  {
   ANCHOR_HL,     // High/Low
   ANCHOR_OPEN    // Open
  };
//--- input parameters
input uint                       InpPeriodRSI         =  13;            // TDI RSI period
input ENUM_APPLIED_PRICE         InpAppliedPriceRSI   =  PRICE_CLOSE;   // TDI RSI applied price
input uint                       InpPeriodVolBand     =  34;            // TDI Volatility band period
input uint                       InpPeriodSmRSI       =  2;             // TDI RSI smoothing period
input ENUM_MA_METHOD             InpMethodSmRSI       =  MODE_SMA;      // TDI RSI smoothing method
input uint                       InpPeriodSmSig       =  7;             // TDI Signal smoothing period
input ENUM_MA_METHOD             InpMethodSmSig       =  MODE_SMA;      // TDI Signal smoothing method
input ENUM_SIGNAL_POINT_ANCHOR   InpAnchorBuffer      =  ANCHOR_HL;     // Signal point anchor
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferRSI[];
double         BufferTmpRSI[];
double         BufferHAOpen[];
double         BufferHAClose[];
double         BufferStoM[];
double         BufferStoS[];
double         BufferUpZone[];
double         BufferMdZone[];
double         BufferDnZone[];
double         BufferMa[];
double         BufferMb[];
//--- global variables
int            period_rsi;
int            period_vb;
int            period_sm_rsi;
int            period_sm_sig;
int            handle_rsi;
int            handle_sto;
int            weight_sumR;
int            weight_sumS;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   period_vb=int(InpPeriodVolBand<1 ? 1 : InpPeriodVolBand);
   period_sm_rsi=int(InpPeriodSmRSI<2 ? 2 : InpPeriodSmRSI);
   period_sm_sig=int(InpPeriodSmSig==period_sm_rsi ? period_sm_rsi+1 : InpPeriodSmSig<2 ? 2 : InpPeriodSmSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferTmpRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferHAOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferHAClose,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferStoM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferStoS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferUpZone,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMdZone,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferDnZone,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferMa,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferMb,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TMS ("+(string)period_rsi+","+(string)period_vb+","+(string)period_sm_rsi+","+(string)period_sm_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferTmpRSI,true);
   ArraySetAsSeries(BufferHAOpen,true);
   ArraySetAsSeries(BufferHAClose,true);
   ArraySetAsSeries(BufferStoM,true);
   ArraySetAsSeries(BufferStoS,true);
   ArraySetAsSeries(BufferUpZone,true);
   ArraySetAsSeries(BufferMdZone,true);
   ArraySetAsSeries(BufferDnZone,true);
   ArraySetAsSeries(BufferMa,true);
   ArraySetAsSeries(BufferMb,true);
//--- create Stochastic, RSI handles
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,InpAppliedPriceRSI);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,8,3,3,MODE_SMA,STO_LOWHIGH);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iRSI(",8,",",3,",",3,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_vb,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_vb-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferTmpRSI,0);
      ArrayInitialize(BufferHAOpen,0);
      ArrayInitialize(BufferHAClose,0);
      ArrayInitialize(BufferStoM,0);
      ArrayInitialize(BufferStoS,0);
      ArrayInitialize(BufferUpZone,0);
      ArrayInitialize(BufferMdZone,0);
      ArrayInitialize(BufferDnZone,0);
      ArrayInitialize(BufferMa,0);
      ArrayInitialize(BufferMb,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,MAIN_LINE,0,count,BufferStoM);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferStoS);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=0;
      for(int j=i; j<i+period_vb; j++) 
        {
         BufferTmpRSI[j-i]=BufferRSI[j];
         MA+=BufferRSI[j]/period_vb;
        }
      BufferUpZone[i]=(MA + (1.6185 * StDev(BufferTmpRSI,period_vb)));
      BufferDnZone[i]=(MA - (1.6185 * StDev(BufferTmpRSI,period_vb)));
      BufferMdZone[i]=((BufferUpZone[i]+BufferDnZone[i])/2);
      //--- HA
      BufferHAOpen[i]=(BufferHAOpen[i+1]+BufferHAClose[i+1])/2.0;
      BufferHAClose[i]=(open[i]+high[i]+low[i]+close[i])/4.0;
     }
   switch(InpMethodSmRSI)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_rsi,BufferRSI,BufferMa)==0) return 0;                  break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_rsi,BufferRSI,BufferMa)==0) return 0;                     break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_rsi,BufferRSI,BufferMa,weight_sumR)==0) return 0;   break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_rsi,BufferRSI,BufferMa)==0) return 0;                       break;
     }
   switch(InpMethodSmSig)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_sig,BufferRSI,BufferMb)==0) return 0;                  break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_sig,BufferRSI,BufferMb)==0) return 0;                     break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_sig,BufferRSI,BufferMb,weight_sumS)==0) return 0;   break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_rsi,period_sm_sig,BufferRSI,BufferMb)==0) return 0;                       break;
     }

//--- Расчёт индикатора
   static datetime last_alert=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //--- Bullish: TDI green line crosses red line from below, Stochastic moving upwards, Heiken Ashi 1st or 2nd candle bullish
      if(
         BufferMa[i]>BufferMb[i] && BufferMa[i+1]<BufferMb[i+1] && 
         BufferStoM[i]>BufferStoS[i] && 
         BufferHAOpen[i]<BufferHAClose[i] && 
         (BufferHAOpen[i+1]>BufferHAClose[i+1] || (BufferHAOpen[i+1]<BufferHAClose[i+1] && BufferHAOpen[i+2]>BufferHAClose[i+2]))
        )
        {
         BufferUP[i]=(InpAnchorBuffer==ANCHOR_HL ? low[i] : open[i]);
         if(i==0 && time[0]>last_alert)
           {
            Alert(Symbol()+","+TimeframeToString(Period())+": TMS Bullish Signal");
            last_alert=TimeCurrent();
           }
        }
      //--- Bearish: TDI green line crosses red line from above, Stochastic moving downwards, Heiken Ashi 1st or 2nd candle bearish
      if(
         BufferMa[i]<BufferMb[i] && BufferMa[i+1]>BufferMb[i+1] && 
         BufferStoM[i]<BufferStoS[i] && 
         BufferHAOpen[i]>BufferHAClose[i] && 
         (BufferHAOpen[i+1]<BufferHAClose[i+1] || (BufferHAOpen[i+1]>BufferHAClose[i+1] && BufferHAOpen[i+2]<BufferHAClose[i+2]))
        )
        {
         BufferDN[i]=(InpAnchorBuffer==ANCHOR_HL ? high[i] : open[i]);
         if(i==0 && time[0]>last_alert)
           {
            Alert(Symbol()+","+TimeframeToString(Period())+": TMS Bearish Signal");
            last_alert=TimeCurrent();
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StDev(double &Data[],const int period)
  {
   return(sqrt(Variance(Data,period)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Variance(double &Data[],const int period)
  {
   double sum=0,ssum=0;
   for(int i=0; i<period; i++)
     {
      sum+=Data[i];
      ssum+=pow(Data[i],2);
     }
   return(ssum*period-sum*sum)/(period*(period-1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
