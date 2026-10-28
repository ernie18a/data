//+------------------------------------------------------------------+
//|                                                  ZeroLagMACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Histogram
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrLimeGreen,clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input uint                 InpPeriodFast     =  12;            // Period of the Fast EMA
input uint                 InpPeriodSlow     =  24;            // Period of the Slow EMA
input uint                 InpPeriodSig      =  9;             // Period of the signal line
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSignal[];
double         BufferHistogram[];
double         BufferColors[];
double         BufferFastEMA[];
double         BufferSlowEMA[];
double         BufferFastOnArray[];
double         BufferSlowOnArray[];
double         BufferSignalOnArray[];
//--- global variables
int            handle_fast_ema;
int            handle_slow_ema;
int            handle_fast_on_array;
int            handle_slow_on_array;
int            period_fast_ema;
int            period_slow_ema;
int            period_signal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_fast_ema=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow_ema=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_signal=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHistogram,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferFastEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSlowEMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFastOnArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSlowOnArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferSignalOnArray,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag MACD("+(string)period_fast_ema+","+(string)period_slow_ema+","+(string)period_signal+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferHistogram,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFastEMA,true);
   ArraySetAsSeries(BufferSlowEMA,true);
   ArraySetAsSeries(BufferFastOnArray,true);
   ArraySetAsSeries(BufferSlowOnArray,true);
   ArraySetAsSeries(BufferSignalOnArray,true);
//--- create MA's handles
   ResetLastError();
   handle_fast_ema=iMA(Symbol(),PERIOD_CURRENT,period_fast_ema,0,MODE_EMA,InpAppliedPrice);
   if(handle_fast_ema==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_slow_ema=iMA(Symbol(),PERIOD_CURRENT,period_slow_ema,0,MODE_EMA,InpAppliedPrice);
   if(handle_slow_ema==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_fast_on_array=iMA(Symbol(),PERIOD_CURRENT,period_fast_ema,0,MODE_EMA,handle_fast_ema);
   if(handle_fast_on_array==INVALID_HANDLE)
     {
      Print("The iMAOnArray(",(string)period_fast_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_slow_on_array=iMA(Symbol(),PERIOD_CURRENT,period_slow_ema,0,MODE_EMA,handle_slow_ema);
   if(handle_slow_on_array==INVALID_HANDLE)
     {
      Print("The iMAOnArray(",(string)period_slow_ema,") object was not created: Error ",GetLastError());
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
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit2=limit;
   if(limit>1)
     {
      limit=rates_total-1;
      limit2=rates_total-2;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferHistogram,EMPTY_VALUE);
      ArrayInitialize(BufferColors,EMPTY_VALUE);
      ArrayInitialize(BufferFastEMA,EMPTY_VALUE);
      ArrayInitialize(BufferSlowEMA,EMPTY_VALUE);
      ArrayInitialize(BufferFastOnArray,EMPTY_VALUE);
      ArrayInitialize(BufferSlowOnArray,EMPTY_VALUE);
      ArrayInitialize(BufferSignalOnArray,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_fast_ema,0,0,count,BufferFastEMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_slow_ema,0,0,count,BufferSlowEMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fast_on_array,0,0,count,BufferFastOnArray);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_slow_on_array,0,0,count,BufferSlowOnArray);
   if(copied!=count) return 0;
//---
   for(int i=limit; i>=0; i--)
      BufferMACD[i]=(2*BufferFastEMA[i]-BufferFastOnArray[i]-2*BufferSlowEMA[i]+BufferSlowOnArray[i])/Point();
   for(int i=limit; i>=0; i--)
      BufferSignalOnArray[i]=iMAOnArray(BufferMACD,0,period_signal,0,MODE_EMA,i);
//--- Расчёт индикатора
   for(int i=limit2; i>=0; i--)
     {
      BufferSignal[i]=2*BufferSignalOnArray[i]-iMAOnArray(BufferSignalOnArray,0,period_signal,0,MODE_EMA,i);
      BufferHistogram[i]=BufferMACD[i]-BufferSignal[i];
      if(BufferHistogram[i]<BufferHistogram[i+1])
         BufferColors[i]=1;
      else
         BufferColors[i]=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double iMAOnArray(double &array[],int total,int period,int ma_shift,int ma_method,int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
//---
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1;i<period;i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2) buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos;i<period;i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1;i<=period;i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0) break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default: return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
