//+------------------------------------------------------------------+
//|                                                 MA_With_Band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   5
//--- plot CloudUpper
#property indicator_label1  "Cloud Upper"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot CloudLower
#property indicator_label2  "Cloud Lower"
#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lower
#property indicator_label3  "Upper"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot MA
#property indicator_label4  "Middle"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrCyan
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Upper
#property indicator_label5  "Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint                 InpPeriodMA       =  10;            // Period of MA calculation
input ENUM_MA_METHOD       InpMethodMA       =  MODE_SMA;      // Method of MA calculation
input ENUM_APPLIED_PRICE   InpAppliedPriceMA =  PRICE_CLOSE;   // Applied price of MA
input uint                 InpPeriodBand     =  15;            // Period of BB calculation
input double               InpDeviationBand  =  2.0;           // Deviation of BB
//--- indicator buffers
double         BufferCloudUpper1[];
double         BufferCloudUpper2[];
double         BufferCloudLower1[];
double         BufferCloudLower2[];
double         BufferLower[];
double         BufferMiddle[];
double         BufferUpper[];
//--- global variables
int            handle_ma;
int            handle_bb;
int            period_ma;
int            period_bb;
double         deviation;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_bb=int(InpPeriodBand<1 ? 1 : InpPeriodBand);
   deviation=(InpDeviationBand<0.1 ? 0.1 : InpDeviationBand);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCloudUpper1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCloudUpper2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCloudLower1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCloudLower2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(5,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(6,BufferLower,INDICATOR_DATA);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCloudUpper1,true);
   ArraySetAsSeries(BufferCloudUpper2,true);
   ArraySetAsSeries(BufferCloudLower1,true);
   ArraySetAsSeries(BufferCloudLower2,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferLower,true);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"MA with Band");
//--- creating handles MA and BB
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,period_ma,0,InpMethodMA,InpAppliedPriceMA);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("Error creating MA's handle: ",GetLastError());
      return INIT_FAILED;
     }
   handle_bb=iBands(Symbol(),PERIOD_CURRENT,period_bb,0,deviation,handle_ma);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("Error creating BB's handle: ",GetLastError());
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period_ma) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferCloudUpper1,EMPTY_VALUE);
      ArrayInitialize(BufferCloudUpper2,EMPTY_VALUE);
      ArrayInitialize(BufferCloudLower1,EMPTY_VALUE);
      ArrayInitialize(BufferCloudLower2,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMiddle);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,1,0,count,BufferUpper);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,2,0,count,BufferLower);
   if(copied!=count) return 0;

//--- Отображение индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferCloudLower1[i]=BufferCloudUpper2[i]=BufferMiddle[i];
      BufferCloudUpper1[i]=BufferUpper[i];
      BufferCloudLower2[i]=BufferLower[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
