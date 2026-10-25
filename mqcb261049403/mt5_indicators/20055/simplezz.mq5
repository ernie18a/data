//+------------------------------------------------------------------+
//|                                                     SimpleZZ.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot ZZ
#property indicator_label1  "ZZ"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_METHOD_STEP
  {
   METHOD_STEP_POINTS,  // Step in pips
   METHOD_STEP_PERCENT  // Step in percent
  };
//--- input parameters
input ENUM_METHOD_STEP  InpMethodStep  =  METHOD_STEP_POINTS;  // Step calculation method
input double            InpStep        =  100.0;               // Step size
//--- indicator buffers
double         BufferMinPriceZZ[];
double         BufferMaxPriceZZ[];
double         BufferDirection[];
double         BufferMinBar[];
double         BufferMaxBar[];
//--- global variables
double         step_pt;
double         step_pc;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   if(Point()==0)
     {
      Print("Error ",GetLastError(),". The Point() of the symbol ",Symbol()," is zero.");
      return INIT_FAILED;
     }
   step_pt=(InpStep<0 ? 0 : InpStep*Point());
   step_pc=(InpStep<0 ? 0 : InpStep)/100;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMaxPriceZZ,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMinPriceZZ,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDirection,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMinBar,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMaxBar,INDICATOR_CALCULATIONS);
//--- settings plots parameters
   PlotIndexSetString(0,PLOT_LABEL,"ZZ Upper;"+"ZZ Lower;");
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Simple ZigZag");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMinPriceZZ,true);
   ArraySetAsSeries(BufferMaxPriceZZ,true);
   ArraySetAsSeries(BufferDirection,true);
   ArraySetAsSeries(BufferMinBar,true);
   ArraySetAsSeries(BufferMaxBar,true);
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
   if(rates_total<3) return 0;
//--- Установка индексации массивов как у таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int total=rates_total-2;
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=total;
      ArrayInitialize(BufferMinPriceZZ,EMPTY_VALUE);
      ArrayInitialize(BufferMaxPriceZZ,EMPTY_VALUE);
      ArrayInitialize(BufferDirection,EMPTY_VALUE);
      ArrayInitialize(BufferMinBar,EMPTY_VALUE);
      ArrayInitialize(BufferMaxBar,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==total)
        {
         BufferDirection[i]=1;
         BufferMinBar[i]=i;
         BufferMaxBar[i]=i;
         if(close[i]>open[i])
            BufferMaxPriceZZ[i]=BufferMinPriceZZ[i]=high[i];
         else
            BufferMaxPriceZZ[i]=BufferMinPriceZZ[i]=low[i];
        }
      else
        {
         BufferMinBar[i]=BufferMinBar[i+1];
         BufferMaxBar[i]=BufferMaxBar[i+1];
         BufferDirection[i]=BufferDirection[i+1];
         BufferMinPriceZZ[i]=EMPTY_VALUE;
         BufferMaxPriceZZ[i]=EMPTY_VALUE;
         if(close[i]<open[i])
           {
            Calculate(i,high[i],high,low);
            Calculate(i,low[i],high,low);
           }
         else
           {
            Calculate(i,low[i],high,low);
            Calculate(i,high[i],high,low);
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Расчёт верхней точки                                             |
//+------------------------------------------------------------------+
void CalculateUp(const int index,const double price,const double &high[])
  {
   int last_bar=(int)BufferMaxBar[index];
   if(BufferMaxPriceZZ[last_bar]==EMPTY_VALUE)
     {
      BufferMaxPriceZZ[last_bar]=high[last_bar];
     }
   if(price>BufferMaxPriceZZ[last_bar])
     {
      BufferMaxPriceZZ[last_bar]=EMPTY_VALUE;
      BufferMaxPriceZZ[index]=price;
      BufferMaxBar[index]=index;
      last_bar=index;
     }
   if((price+step_pt<BufferMaxPriceZZ[last_bar] &&  InpMethodStep==METHOD_STEP_POINTS) || 
      (price*(1+step_pc/100)<BufferMaxPriceZZ[last_bar]&& InpMethodStep==METHOD_STEP_PERCENT))
     {
      BufferDirection[index]=-1;
      BufferMinPriceZZ[index]=price;
      BufferMinBar[index]=index;
     }
   return;
  }
//+------------------------------------------------------------------+
//| Расчёт нижней точки                                              |
//+------------------------------------------------------------------+
void CalculateDn(const int index,const double price,const double &low[])
  {
   int last_bar=(int)BufferMinBar[index];
   if(BufferMinPriceZZ[last_bar]==EMPTY_VALUE)
     {
      BufferMinPriceZZ[last_bar]=low[last_bar];
     }
   if(price<BufferMinPriceZZ[last_bar])
     {
      BufferMinPriceZZ[last_bar]=EMPTY_VALUE;
      BufferMinPriceZZ[index]=price;
      BufferMinBar[index]=index;
      last_bar=index;
     }
   if((price-step_pt>BufferMinPriceZZ[last_bar] &&  InpMethodStep==METHOD_STEP_POINTS) || 
      (price*(1-step_pc/100)>BufferMinPriceZZ[last_bar]&& InpMethodStep==METHOD_STEP_PERCENT))
     {
      BufferDirection[index]=1;
      BufferMaxPriceZZ[index]=price;
      BufferMaxBar[index]=index;
     }
   return;
  }
//+------------------------------------------------------------------+
//| Расчёт опорных точек ZigZag                                      |
//+------------------------------------------------------------------+
void Calculate(const int index,const double price,const double &high[],const double &low[])
  {
   if(BufferDirection[index]==1)
      CalculateUp(index,price,high);
   else
      CalculateDn(index,price,low);
  }
//+------------------------------------------------------------------+
