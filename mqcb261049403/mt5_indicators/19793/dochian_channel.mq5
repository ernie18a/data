//+------------------------------------------------------------------+
//|                                              Dochian_Channel.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot U75
#property indicator_label2  "U75"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Middle
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot L25
#property indicator_label4  "L25"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrCyan
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Lower
#property indicator_label5  "Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrMagenta
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- enums
enum ENUM_MODE_CALCULATION
  {
   MODE_CLOSE,    // Close
   MODE_HL        // High/Low
  };
//--- input parameters
input uint                    InpPeriod   =  20;      // Period
input ENUM_MODE_CALCULATION   InpMode     =  MODE_HL; // Mode of calculation
//--- indicator buffers
double         BufferUpper[];
double         BufferU75[];
double         BufferMiddle[];
double         BufferL25[];
double         BufferLower[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferU75,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(3,BufferL25,INDICATOR_DATA);
   SetIndexBuffer(4,BufferLower,INDICATOR_DATA);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Dochian channel");
//--- settings variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period+1) return 0;
//--- Зададим направление индексации массивов как у таймсерий
   ArraySetAsSeries(BufferL25,true);
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferU75,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferL25,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferU75,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
     }
//--- Цикл расчёта индикатора
   int H=0,L=0;
   for(int i=limit; i>=0; i--)
     {
      if(InpMode==MODE_CLOSE)
        {
         H=Highest(Symbol(),PERIOD_CURRENT,PRICE_CLOSE,period,i);
         L=Lowest(Symbol(),PERIOD_CURRENT,PRICE_CLOSE,period,i);
         if(H==WRONG_VALUE || L==WRONG_VALUE) return 0;
         BufferUpper[i]=close[H];
         BufferLower[i]=close[L];
        }
      else
        {
         H=Highest(Symbol(),PERIOD_CURRENT,PRICE_HIGH,period,i);
         L=Lowest(Symbol(),PERIOD_CURRENT,PRICE_LOW,period,i);
         if(H==WRONG_VALUE || L==WRONG_VALUE) return 0;
         BufferUpper[i]=high[H];
         BufferLower[i]=low[L];
        }
      BufferMiddle[i]=(BufferUpper[i]+BufferLower[i])/2;
      BufferU75[i]=(BufferUpper[i]+BufferMiddle[i])/2;
      BufferL25[i]=(BufferMiddle[i]+BufferLower[i])/2;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Returns highest prices value from timeseries array               |
//+------------------------------------------------------------------+
int Highest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE mode_price,int count=WHOLE_ARRAY,int start=0)
  {
   if(start<0) return(-1);
   if(count==WHOLE_ARRAY) count=Bars(symbol_name,timeframe);
   double array[];
   ArraySetAsSeries(array,true);
   int copied=
     (
      mode_price==PRICE_CLOSE ?  CopyClose(symbol_name,timeframe,start,count,array) :
      mode_price==PRICE_HIGH  ?  CopyHigh(symbol_name,timeframe,start,count,array)  :
      mode_price==PRICE_LOW   ?  CopyLow(symbol_name,timeframe,start,count,array)   :
      CopyOpen(symbol_name,timeframe,start,count,array)
     );
   return(copied<=0 ? WRONG_VALUE : ArrayMaximum(array)+start);
  }
//+------------------------------------------------------------------+
//| Returns lowest prices value from timeseries array                |
//+------------------------------------------------------------------+
int Lowest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE mode_price,int count=WHOLE_ARRAY,int start=0)
  {
   if(start<0) return(-1);
   if(count==WHOLE_ARRAY) count=Bars(symbol_name,timeframe);
   double array[];
   ArraySetAsSeries(array,true);
   int copied=
     (
      mode_price==PRICE_CLOSE ?  CopyClose(symbol_name,timeframe,start,count,array) :
      mode_price==PRICE_HIGH  ?  CopyHigh(symbol_name,timeframe,start,count,array)  :
      mode_price==PRICE_LOW   ?  CopyLow(symbol_name,timeframe,start,count,array)   :
      CopyOpen(symbol_name,timeframe,start,count,array)
     );
   return(copied<=0 ? WRONG_VALUE : ArrayMinimum(array)+start);
  }
//+------------------------------------------------------------------+
