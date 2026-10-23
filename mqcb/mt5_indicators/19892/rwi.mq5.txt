//+------------------------------------------------------------------+
//|                                                          RWI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot RWIH
#property indicator_label1  "RWI High"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot RWIL
#property indicator_label2  "RWI Low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot TR
#property indicator_label3  "TR"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod=2; // Period
//--- indicator buffers
double         BufferRWIH[];
double         BufferRWIL[];
double         BufferTR[];
//--- global variables
int            period_calc;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_calc=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRWIH,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRWIL,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTR,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Random Walk Index("+(string)period_calc+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRWIH,true);
   ArraySetAsSeries(BufferRWIL,true);
   ArraySetAsSeries(BufferTR,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_calc-2;
      ArrayInitialize(BufferRWIH,EMPTY_VALUE);
      ArrayInitialize(BufferRWIL,EMPTY_VALUE);
      ArrayInitialize(BufferTR,EMPTY_VALUE);
     }
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Подготовка данных
   for(int i=limit; i>=0; i--)
      BufferTR[i]=fmax(high[i]-low[i],fmax(fabs(high[i]-close[i+1]),fabs(close[i+1]-low[i])));
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double H=0;
      double L=0;
      for(int n=1; n<=period_calc; n++)
        {
         double ATR=iMAOnArray(BufferTR,0,n,0,MODE_SMA,i)/sqrt(n+1);
         if(ATR!=0)
           {
            H=fmax(H,(high[i]-low[i+n])/ATR);
            L=fmax(L,(high[i+n]-low[i])/ATR);
           }
        }
      BufferRWIH[i]=H;
      BufferRWIL[i]=L;
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
