//+------------------------------------------------------------------+
//|                                                  Trend_Range.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot Max
#property indicator_label1  "Max"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Flat
#property indicator_label2  "Flat"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Hist
#property indicator_label3  "Range"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrBlue,clrRed,clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input uint           InpPeriodTR    =  10;         // Period
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // Method
input double         InpDeviation   =  1.0;        // Deviation
//--- indicator buffers
double         BufferMax[];
double         BufferFlat[];
double         BufferHist[];
double         BufferColors[];
double         BufferMA[];
double         BufferMADevTmp[];
double         BufferDev[];
//--- global variables
int            period_tr;
double         deviation;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tr=int(InpPeriodTR<1 ? 1 : InpPeriodTR);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMax,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFlat,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMADevTmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferDev,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Range("+(string)period_tr+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMax,true);
   ArraySetAsSeries(BufferFlat,true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMADevTmp,true);
   ArraySetAsSeries(BufferDev,true);
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
   if(rates_total<2 || Point()==0) return rates_total;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMax,EMPTY_VALUE);
      ArrayInitialize(BufferFlat,EMPTY_VALUE);
      ArrayInitialize(BufferHist,0);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferMADevTmp,EMPTY_VALUE);
      ArrayInitialize(BufferDev,EMPTY_VALUE);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferHist[i]=(high[i]-low[i])/Point()*tick_volume[i];
   StdDevOnArray(rates_total,prev_calculated,0,period_tr,InpMethod,BufferMADevTmp,BufferHist,BufferDev);
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferMA[i]=MAOnArray(BufferHist,0,period_tr,0,InpMethod,i);
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=BufferMA[i];
      double StdDev=BufferDev[i];
      double max=MA+StdDev*deviation;
      double flat=max/2;
      BufferFlat[i]=flat;
      BufferMax[i]=max;
      BufferColors[i]=(BufferHist[i]>max ? 0 : BufferHist[i]>flat ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Standart Deviation on array                                      |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
template<typename T>
int StdDevOnArray(const int rates_total,
                  const int prev_calculated,
                  const int begin,
                  const int period,
                  const ENUM_MA_METHOD method,
                  double &buffer_ma_tmp[],
                  const T &src_array[],
                  double &dest_buffer[]
                  )
  {
//--- variables of indicator
   int pos=0;
//--- check for rates count
   if(rates_total<period) return(0);
//--- save as_series flags
   bool as_series_arr=ArrayGetAsSeries(src_array);
   bool as_series_dev=ArrayGetAsSeries(dest_buffer);
   bool as_series_ma=ArrayGetAsSeries(buffer_ma_tmp);
   if(as_series_arr)
      ArraySetAsSeries(src_array,false);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,false);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,false);

//--- starting work
   pos=prev_calculated-1;
//--- correct position for first iteration
   if(pos<period)
     {
      pos=period-1;
      ArrayInitialize(dest_buffer,0.0);
      ArrayInitialize(buffer_ma_tmp,0.0);
     }
//--- main cycle
   switch(method)
     {
      case  MODE_EMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=ExponentialMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_SMMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=SmoothedMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_LWMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=LinearWeightedMA(i,period,src_array);
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      default   :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
     }
//--- restore as_series flags
   if(as_series_arr)
      ArraySetAsSeries(src_array,true);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,true);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,true);
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
template<typename T>
double StdDevFunc(const T &price[],const double &price_ma[],const int period,int position)
  {
   double dev=0.0;
   for(int i=0;i<period;i++) dev+=pow(price[position-i]-price_ma[position],2);
   dev=sqrt(dev/period);
   return(dev);
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
