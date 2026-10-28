//+------------------------------------------------------------------+
//|                                                          WSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Wave Segregation Index indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot WSI
#property indicator_label1  "WSI"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrDarkSeaGreen,clrRed,clrBurlyWood,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriodCCI   =  100;  // CCI period
input uint     InpPeriodADX   =  100;  // ADX period
//--- indicator buffers
double         BufferWSI[];
double         BufferColors[];
double         BufferCCI[];
double         BufferADX[];
double         BufferMA[];
//--- global variables
int            period_cci;
int            period_adx;
int            handle_cci;
int            handle_adx;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WSI ("+(string)period_cci+","+(string)period_adx+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWSI,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferADX,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_TYPICAL);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferWSI,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferADX,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferWSI[i]=(BufferCCI[i]*BufferMA[i]*BufferADX[i])/1000.0;
      BufferColors[i]=
        (
         BufferWSI[i]>0 ? (BufferWSI[i]>BufferWSI[i+1] ? 0 : BufferWSI[i]<BufferWSI[i+1] ? 1 : 4) : 
         BufferWSI[i]<0 ? (BufferWSI[i]<BufferWSI[i+1] ? 2 : BufferWSI[i]>BufferWSI[i+1] ? 3 : 4) : 4
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
