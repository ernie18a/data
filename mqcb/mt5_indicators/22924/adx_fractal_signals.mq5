//+------------------------------------------------------------------+
//|                                          ADX_Fractal_Signals.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ADX Fractal Signals indicator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot SigB
#property indicator_label1  "Signal Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SigS
#property indicator_label2  "Signal Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodADX   =  14;         // ADX period
input uint              InpPeriodCCI   =  200;        // CCI period
input double            InpLevB        =  0.0;        // CCI bullish signal level
input double            InpLevS        =  0.0;        // CCI bearish signal level
input ENUM_INPUT_YES_NO InpUseAlert    =  INPUT_YES;  // Use alerts
//--- indicator buffers
double         BufferSigB[];
double         BufferSigS[];
double         BufferADX[];
double         BufferDMIP[];
double         BufferDMIM[];
double         BufferCCI[];
double         BufferFRU[];
double         BufferFRL[];
//--- global variables
double         lev_buy_cci;
double         lev_sell_cci;
double         point;
int            period_adx;
int            period_cci;
int            handle_adx;
int            handle_cci;
int            handle_fr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   point=Point();
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   lev_buy_cci=InpLevB;
   lev_sell_cci=InpLevS;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSigB,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSigS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDMIP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDMIM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFRU,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferFRL,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADX Fractal Signals ("+(string)period_adx+","+(string)period_cci+","+DoubleToString(lev_buy_cci,1)+","+DoubleToString(lev_sell_cci,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSigB,true);
   ArraySetAsSeries(BufferSigS,true);
   ArraySetAsSeries(BufferADX,true);
   ArraySetAsSeries(BufferDMIP,true);
   ArraySetAsSeries(BufferDMIM,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferFRU,true);
   ArraySetAsSeries(BufferFRL,true);
//--- create handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_fr=iFractals(NULL,PERIOD_CURRENT);
   if(handle_fr==INVALID_HANDLE)
     {
      Print("The iFractals object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferSigB,EMPTY_VALUE);
      ArrayInitialize(BufferSigS,EMPTY_VALUE);
      ArrayInitialize(BufferADX,0);
      ArrayInitialize(BufferDMIP,0);
      ArrayInitialize(BufferDMIM,0);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferFRU,0);
      ArrayInitialize(BufferFRL,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferDMIP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferDMIM);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fr,UPPER_LINE,0,count,BufferFRU);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fr,LOWER_LINE,0,count,BufferFRL);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   static datetime last_time=0;
   string alert="";
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSigS[i]=BufferSigB[i]=EMPTY_VALUE;
      //--- BUY:
      if(BufferADX[i]>BufferADX[i+1] && BufferADX[i+1]>BufferADX[i+2]                                 // 1. ADX IS INCREASING IN PAST 2 BARS
         && BufferDMIP[i]>BufferDMIM[i]                                                               // 2. DMI POSITIVE> DMI NEGATIVE
         && BufferCCI[i]>lev_buy_cci && BufferCCI[i+1]>lev_buy_cci && BufferCCI[i+2]>lev_buy_cci      // 3. CCI > BUY LEVEL IN PAST 3 BARS
         && BufferFRL[i+2]>0 && BufferFRL[i+2]<EMPTY_VALUE                                            // 4. APPEARANCE OF NEW SUPPORT FRACTAL(DOWN FRACTAL)
         )
        {
         BufferSigB[i]=low[i]-(20*point);
         if(limit>1 && i==0) 
            alert="ADX Fractal Signal: BUY";
        }
      //--- SELL:
      if(BufferADX[i]>BufferADX[i+1] && BufferADX[i+1]>BufferADX[i+2]                                 // 1. ADX IS INCREACING IN PAST 2 BARS
         && BufferDMIM[i]>BufferDMIP[i]                                                               // 2. DMI NEGATIVE> DMI POSITIVE
         && BufferCCI[i]<lev_sell_cci && BufferCCI[i+1]<lev_sell_cci && BufferCCI[i+2]<lev_sell_cci   // 3. CCI < SELL LEVEL IN PAST 3 BARS
         && BufferFRU[i+2]>0 && BufferFRU[i+2]<EMPTY_VALUE                                            // 4. APPEARANCE OF NEW RESISTANCE FRACTAL(UP FRACTAL)
         )
        {
         BufferSigS[i]=high[i]+(20*point);
         if(limit>1 && i==0) 
            alert="ADX Fractal Signal: SELL";
        }
     }
   if(InpUseAlert && time[0]>last_time && alert!="")
     {
      Alert(Symbol()+" "+TimeframeToString(Period())+": "+alert);
      last_time=TimeCurrent();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
