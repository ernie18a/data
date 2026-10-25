//+------------------------------------------------------------------+
//|                                                          ZMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.1"
#property description "ZigZag Moving Average"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot MAT
#property indicator_label1  "MA Top"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MAB
#property indicator_label2  "MA Bottom"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_PRICE_TYPE
  {
   PRICE_TYPE_CLOSE, // Close
   PRICE_TYPE_HL     // High/Low
  };
//--- input parameters
input uint              InpDepth       =  12;               // ZigZag depth
input uint              InpDeviation   =  5;                // ZigZag deviation
input uint              InpBackstep    =  3;                // ZigZag backstep
input ENUM_PRICE_TYPE   InpPrice       =  PRICE_TYPE_CLOSE; // Price type
//--- indicator buffers
double         BufferMAT[];
double         BufferMAB[];
double         BufferZZ[];
//--- global variables
int            depth;
int            deviation;
int            backstep;
int            handle_zz;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   backstep=int(InpBackstep<1 ? 1 : InpBackstep);
   depth=int((int)InpDepth<backstep ? backstep : InpDepth<1 ? 1 : InpDepth);
   deviation=int(InpDeviation<1 ? 1 : InpDeviation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMAT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMAB,INDICATOR_DATA);
   SetIndexBuffer(2,BufferZZ,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ZMA ("+(string)depth+","+(string)deviation+","+(string)backstep+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMAT,true);
   ArraySetAsSeries(BufferMAB,true);
   ArraySetAsSeries(BufferZZ,true);
//--- create ZZ handles
   ResetLastError();
   handle_zz=iCustom(NULL,PERIOD_CURRENT,"Examples\\ZigZag",depth,deviation,backstep);
   if(handle_zz==INVALID_HANDLE)
     {
      Print("The iCustom(MQL5/Indicators/Examples/ZigZag (",(string)depth,",",(string)deviation,",",(string)backstep,")) object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(depth,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMAT,EMPTY_VALUE);
      ArrayInitialize(BufferMAB,EMPTY_VALUE);
      ArrayInitialize(BufferZZ,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_zz,0,0,count,BufferZZ);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   int index=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMAT[i]=BufferMAB[i]=EMPTY_VALUE;
      if(BufferZZ[i]>0)
        {
         index=GetIndexExtremumZZ(rates_total,i,1,BufferZZ);
         if(index!=WRONG_VALUE)
           {
            double ma=0;
            int period=0;
            if(BufferZZ[index]>BufferZZ[i])
              {
               for(int j=index; j>=i; j--)
                 {
                  period++;
                  ma+=(InpPrice==PRICE_TYPE_HL ? high[j] : close[j]);
                  BufferMAT[j]=ma/period;
                 }
              }
            else
              {
               for(int j=index; j>=i; j--)
                 {
                  period++;
                  ma+=(InpPrice==PRICE_TYPE_HL ? low[j] : close[j]);
                  BufferMAB[j]=ma/period;
                 }
              }   
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс заданного экстремума индикатора ZigZag         |
//+------------------------------------------------------------------+
int GetIndexExtremumZZ(const int rates_total,const int shift,const int num_ext,const double &buffer_zz[]) 
  {
   int k_ext=0, index=WRONG_VALUE;
   for(int i=shift; i<rates_total; i++) 
     {
      if(buffer_zz[i]!=0) 
        {
         k_ext++;
         if(k_ext>num_ext)
           {
            index=i;
            break;
           }
        }
     }
   return index;
  }
//+------------------------------------------------------------------+
