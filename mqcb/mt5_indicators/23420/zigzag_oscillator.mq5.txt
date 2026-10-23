//+------------------------------------------------------------------+
//|                                            ZigZag_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ZigZag Oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot ZZOsc
#property indicator_label1  "ZigZag Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrBurlyWood,clrOrangeRed,clrLightSeaGreen,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  6
//--- input parameters
input uint     InpDepth       =  12;   // ZigZag Depth
input uint     InpDeviation   =  5;    // ZigZag Deviation
input uint     InpBackstep    =  3;    // ZigZag Backstep
input uchar    InpPivotPoint  =  1;    // ZigZag pivot point
//--- indicator buffers
double         BufferZZOsc[];
double         BufferColors[];
double         BufferZZ[];
double         BufferZZUP[];
double         BufferZZDN[];
double         BufferHigh[];
double         BufferLow[];
//--- global variables
int            depth;
int            deviation;
int            backstep;
int            pivot;
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
   pivot=(int)InpPivotPoint;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferZZOsc,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferZZ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferZZUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferZZDN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferLow,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag Oscillator ("+(string)depth+","+(string)deviation+","+(string)backstep+", Pivot "+(string)pivot+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"ZZOsc("+(string)depth+","+(string)deviation+","+(string)backstep+","+(string)pivot+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferZZOsc,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferZZ,true);
   ArraySetAsSeries(BufferZZUP,true);
   ArraySetAsSeries(BufferZZDN,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
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
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(depth,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>0)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferZZOsc,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferZZ,0);
      ArrayInitialize(BufferZZUP,0);
      ArrayInitialize(BufferZZDN,0);
      ArrayInitialize(BufferHigh,0);
      ArrayInitialize(BufferLow,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_zz,0,0,count,BufferZZ);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   double last_zz=0;
   int index=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      index=GetIndexExtremumZZ(rates_total,i,pivot,BufferZZ);
      if(index==WRONG_VALUE)
         continue;
      last_zz=BufferZZ[index];
      BufferZZOsc[i]=(last_zz!=0 ? 100*(close[i]-last_zz)/last_zz : 0);
      BufferColors[i]=
        (
         BufferZZOsc[i]>0 ? (BufferZZOsc[i]>BufferZZOsc[i+1] ? 0 : BufferZZOsc[i]<BufferZZOsc[i+1] ? 1 : 4) :
         BufferZZOsc[i]<0 ? (BufferZZOsc[i]<BufferZZOsc[i+1] ? 2 : BufferZZOsc[i]>BufferZZOsc[i+1] ? 3 : 4) : 4
        );
     }

   return(rates_total);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс заданного экстремума индикатора ZigZag         |
//+------------------------------------------------------------------+
int GetIndexExtremumZZ(const int rates_total,const int shift,const int pivot_num,const double &buffer_zz[]) 
  {
   int k_ext=0, index=WRONG_VALUE;
   for(int i=shift; i<rates_total; i++) 
     {
      if(buffer_zz[i]!=0) 
        {
         k_ext++;
         if(k_ext>pivot_num)
           {
            index=i;
            break;
           }
        }
     }
   return index;
  }
//+------------------------------------------------------------------+
