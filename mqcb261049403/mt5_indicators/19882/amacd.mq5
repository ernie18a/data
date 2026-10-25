//+------------------------------------------------------------------+
//|                                                        AMACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodFastAMA=6;           // Period of the Fast AMA
input uint                 InpFastFastAMA   =  2;        // Fast EMA of the Fast AMA
input uint                 InpSlowFastAMA   =  13;       // Slow EMA of the Fast AMA
input uint                 InpPeriodSlowAMA  =  13;      // Period of the Slow AMA
input uint                 InpFastSlowAMA    =  6;       // Fast EMA of the Slow AMA
input uint                 InpSlowSlowAMA    =  30;      // Slow EMA of the Slow AMA
input uint                 InpPeriodSignal   =  5;       // The signal line period
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;  // Applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferColors[];
double         BufferSignal[];
double         BufferFastAMA[];
double         BufferSlowAMA[];
//--- global variables
int            period_fast_ama;
int            fast_fast_ama;
int            slow_fast_ama;
int            period_slow_ama;
int            fast_slow_ama;
int            slow_slow_ama;
int            period_signal;
int            handle_fast_ama;
int            handle_slow_ama;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_fast_ama=int(InpPeriodFastAMA<1 ? 1 : InpPeriodFastAMA);
   period_slow_ama=int(InpPeriodSlowAMA<=(uint)period_fast_ama ? period_fast_ama+1 : InpPeriodSlowAMA);
   fast_fast_ama=int(InpFastFastAMA<1 ? 1 : InpFastFastAMA);
   slow_fast_ama=int(InpSlowFastAMA<1 ? 1 : InpSlowFastAMA);
   fast_slow_ama=int(InpFastSlowAMA<1 ? 1 : InpFastSlowAMA);
   slow_slow_ama=int(InpSlowSlowAMA<1 ? 1 : InpSlowSlowAMA);
   period_signal=int(InpPeriodSignal<1 ? 1 : InpPeriodSignal);
   string short_name="AMACD("+(string)period_fast_ama+","+
                     (string)fast_fast_ama+","+
                     (string)slow_fast_ama+","+
                     (string)period_slow_ama+","+
                     (string)fast_slow_ama+","+
                     (string)slow_slow_ama+","+
                     (string)period_signal+")";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferFastAMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSlowAMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferFastAMA,true);
   ArraySetAsSeries(BufferSlowAMA,true);
//--- Creating the AMA handles
   ResetLastError();
   handle_fast_ama=iAMA(Symbol(),PERIOD_CURRENT,period_fast_ama,fast_fast_ama,slow_fast_ama,0,InpAppliedPrice);
   if(handle_fast_ama==INVALID_HANDLE)
     {
      Print("The iAMA(",(string)period_fast_ama,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_slow_ama=iAMA(Symbol(),PERIOD_CURRENT,period_slow_ama,fast_slow_ama,slow_slow_ama,0,InpAppliedPrice);
   if(handle_fast_ama==INVALID_HANDLE)
     {
      Print("The iAMA(",(string)period_slow_ama,") object was not created: Error ",GetLastError());
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
   if(rates_total<period_slow_ama) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferColors,0);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
      ArrayInitialize(BufferFastAMA,EMPTY_VALUE);
      ArrayInitialize(BufferSlowAMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_fast_ama,0,0,count,BufferFastAMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_slow_ama,0,0,count,BufferSlowAMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0; i--)
      BufferMACD[i]=BufferFastAMA[i]-BufferSlowAMA[i];
   for(int i=limit; i>=0; i--)
     {
      BufferSignal[i]=iMAOnArray(BufferMACD,0,period_signal,0,MODE_SMA,i);
      double hist=BufferMACD[i]-BufferSignal[i];
      if(hist<0)
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
