//+------------------------------------------------------------------+
//|                                              Volatility_Band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility Band"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MD
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriodB     =  8;    // Period Band
input uint     InpPeriodV     =  13;   // Period
input double   InpDeviation   =  0.55; // Deviation factor
input double   InpAdjust      =  0.9;  // Low band adjustment
//--- indicator buffers
double         BufferUP[];
double         BufferMD[];
double         BufferDN[];
double         BufferTMA[];
double         BufferLMA[];
double         BufferTSeries[];
double         BufferVSeries[];
//--- global variables
int            period_b;
int            period_v;
double         deviation;
int            handle_tma;
int            handle_lma;
int            handle_ema;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_b=int(InpPeriodB<1 ? 1 : InpPeriodB);
   period_v=int(InpPeriodV<1 ? 1 : InpPeriodV);
   deviation=(InpDeviation==0 ? 0.1 : InpDeviation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferTSeries,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferVSeries,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VBand");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferMD,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTMA,true);
   ArraySetAsSeries(BufferLMA,true);
   ArraySetAsSeries(BufferTSeries,true);
   ArraySetAsSeries(BufferVSeries,true);
//--- create MA's handle
   ResetLastError();
   handle_tma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_TYPICAL);
   if(handle_tma==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_TYPICAL object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_lma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);
   if(handle_lma==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ema=iMA(NULL,PERIOD_CURRENT,period_b,0,MODE_EMA,PRICE_TYPICAL);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_b,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferMD,0);
      ArrayInitialize(BufferDN,0);
      ArrayInitialize(BufferTMA,0);
      ArrayInitialize(BufferLMA,0);
      ArrayInitialize(BufferTSeries,0);
      ArrayInitialize(BufferVSeries,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ema,0,0,count,BufferMD);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_tma,0,0,count,BufferTMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_lma,0,0,count,BufferLMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double tp0=BufferTMA[i];
      double tp1=BufferTMA[i+1];
      double l0=BufferLMA[i];
      double l1=BufferLMA[i+1];
      BufferTSeries[i]=(tp0>=tp1 ? tp0-l1 : tp1-l0);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVSeries[i]=MAOnArray(BufferTSeries,0,period_v,0,MODE_SMA,i)/deviation;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double devHigh=MAOnArray(BufferVSeries,0,period_b,0,MODE_EMA,i);
      double devLow=devHigh*InpAdjust;
      BufferDN[i]=BufferMD[i]-devLow;
      BufferUP[i]=BufferMD[i]+devHigh;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double MAOnArray(double &array[],int total,int period,int ma_shift,int ma_method,int shift)
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
