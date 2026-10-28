//+------------------------------------------------------------------+
//|                                                   Diff_TF_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot MA1
#property indicator_label1  "MA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA2
#property indicator_label2  "MA2"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint              InpMAPeriod=10;            // Period MA
input ENUM_TIMEFRAMES   InpMATimeframe=PERIOD_H4;  // Timeframe MA
//--- indicator buffers
double         BufferMA1[];
double         BufferMA2[];
//--- global variables
int            period_ma1;
int            period_ma2;
int            handle_ma1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA2,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- settings variables
   period_ma1=int(InpMAPeriod<1 ? 1 : InpMAPeriod);
   int v1=PeriodSeconds(InpMATimeframe)/60;
   int v2=PeriodSeconds(Period())/60;
   int v3=period_ma1*v1/v2;
   period_ma2=(v3>0 ? v3 : 1);
//--- settings a string parameters to the plot buffers
   PlotIndexSetString(0,PLOT_LABEL,"MA("+NameTimeframe(Period())+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA("+NameTimeframe(InpMATimeframe)+")");
//--- create handle MA1
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_ma2,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<period_ma2) return 0;
//--- Зададим направление индексации массивов как у таймсерий
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMA1,EMPTY_VALUE);
      ArrayInitialize(BufferMA2,EMPTY_VALUE);
     }
//--- Подготовка данных МА
   int copied=(limit==0 ? 1 : rates_total);
   int copied_ma1=CopyBuffer(handle_ma1,0,0,copied,BufferMA1);
   if(copied_ma1!=copied) return 0;
//--- Цикл расчёта индикатора
   for(int i=limit; i>=0 &&!IsStopped(); i--)
     {
      int index=BarShift(InpMATimeframe,time[i]);
      if(index==WRONG_VALUE) return 0;
      if(time[i]==Time(InpMATimeframe,index))
        {
         double ma2=GetMA(InpMATimeframe,period_ma1,MODE_SMA,PRICE_CLOSE,index);
         if(ma2==WRONG_VALUE) return 0;
         BufferMA2[i]=ma2;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| MA from one specified bar                                        |
//+------------------------------------------------------------------+
double GetMA(const ENUM_TIMEFRAMES timeframe,
             const int period,
             const ENUM_MA_METHOD method,
             const ENUM_APPLIED_PRICE price,
             const int shift)
  {
   double array[];
   ResetLastError();
   int handle=iMA(Symbol(),timeframe,period,0,method,price);
   if(handle==INVALID_HANDLE)
     {
      Print("Trading day average: Error creating MA handle ",GetLastError(),", recalculate now");
      return(WRONG_VALUE);
     }
   if(CopyBuffer(handle,0,shift,1,array)==1) return array[0];
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Returns the offset of the bar by time                            |
//+------------------------------------------------------------------+
int BarShift(const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   int res=WRONG_VALUE;
   datetime last_bar=0;
   if(SeriesInfoInteger(Symbol(),timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      if(time>last_bar) res=0;
      else
        {
         const int shift=Bars(Symbol(),timeframe,time,last_bar);
         if(shift>0) res=shift-1;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Returns specified Time by shift                                  |
//+------------------------------------------------------------------+
datetime Time(const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   if(CopyTime(Symbol(),timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns the name timeframe                                       |
//+------------------------------------------------------------------+
string NameTimeframe(int timeframe=PERIOD_CURRENT) 
  {
   if(timeframe==PERIOD_CURRENT) timeframe=Period();
   switch(timeframe)
     {
      case 1      : return "M1";
      case 2      : return "M2";
      case 3      : return "M3";
      case 4      : return "M4";      
      case 5      : return "M5";
      case 6      : return "M6";
      case 10     : return "M10";
      case 12     : return "M12";
      case 15     : return "M15";
      case 20     : return "M20";
      case 30     : return "M30";
      case 16385  : return "H1";
      case 16386  : return "H2";
      case 16387  : return "H3";
      case 16388  : return "H4";
      case 16390  : return "H6";
      case 16392  : return "H8";
      case 16396  : return "H12";
      case 16408  : return "D1";
      case 32769  : return "W1";
      case 49153  : return "MN1";      
      default     : return (string)(int)Period();
     }
  }
//+------------------------------------------------------------------+
