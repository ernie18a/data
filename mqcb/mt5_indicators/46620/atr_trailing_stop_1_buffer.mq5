//+------------------------------------------------------------------+
//|                                   ATR_Trailing_Stop_1_Buffer.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Modified ATR Trailing Stop indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot UP
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input uint     InpPeriod   =  7;   // Period
input double   InpCoeff    =  2.0;  // Coefficient
//--- indicator buffers
double         BufferMain[];

double         BufferHL[];
double         BufferDiff[];
double         BufferWMA[];
double         BufferTMP[];
//--- global variables
int            period_ma;
double         K;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   double n1=2.0*double(period_ma-1);
   K=2.0/(n1+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMain,INDICATOR_DATA);

   SetIndexBuffer(1,BufferHL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferDiff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferWMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTMP,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ModATRTS("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMain,true);

   ArraySetAsSeries(BufferHL,true);
   ArraySetAsSeries(BufferDiff,true);
   ArraySetAsSeries(BufferWMA,true);
   ArraySetAsSeries(BufferTMP,true);
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
   if(rates_total<period_ma)
      return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMain,EMPTY_VALUE);

      ArrayInitialize(BufferHL,0);
      ArrayInitialize(BufferDiff,0);
      ArrayInitialize(BufferWMA,0);
      ArrayInitialize(BufferTMP,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferHL[i]=high[i]-low[i];
      double Href=0, Lref=0;
      double SMA=MAOnArray(BufferHL,0,period_ma,0,MODE_SMA,i);
      double HiLo=fmin(BufferHL[i],SMA);
      Href=(low[i]<=high[i+1] ? high[i]-close[i+1] : (BufferHL[i]-close[i+1]+high[i+1])/2);
      Lref=(high[i]>=low[i+1] ? close[i+1]-low[i] : (close[i+1]-low[i+1]+BufferHL[i])/2);
      BufferDiff[i]=fmax(HiLo,fmax(Href,Lref));
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
         BufferWMA[i]=MAOnArray(BufferDiff,0,period_ma,0,MODE_EMA,i);
      else
         BufferWMA[i]=(BufferDiff[i]-BufferWMA[i+1])*K+BufferWMA[i+1];
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double loss=BufferWMA[i]*InpCoeff;
      if(close[i]>BufferTMP[i+1] && close[i+1]>BufferTMP[i+1])
        {
         BufferTMP[i]=fmax(BufferTMP[i+1],close[i]-loss);
         BufferMain[i]=BufferTMP[i];

        }
      else
        {
         if(close[i]<BufferTMP[i+1] && close[i+1]<BufferTMP[i+1])
           {
            BufferTMP[i]=fmin(BufferTMP[i+1],close[i]+loss);
            BufferMain[i]=BufferTMP[i];

           }
         else
           {
            if(close[i]>BufferTMP[i+1])
              {
               BufferTMP[i]=close[i]-loss;
               BufferMain[i]=BufferTMP[i];

              }
            else
              {
               BufferTMP[i]=close[i]+loss;
               BufferMain[i]=BufferTMP[i];

              }
           }
        }
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
   if(total==0)
      total=ArraySize(array);
   if(total>0 && total<=period)
      return(0);
   if(shift>total-period-ma_shift)
      return(0);
//---
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1; i<period; i++,pos--)
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
         if(ArrayResize(buf,total)<0)
            return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2)
               buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos; i<period; i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else
               sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0)
            return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1; i<=period; i++,pos--)
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
            if(pos==0)
               break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
