//+------------------------------------------------------------------+
//|                                                          VMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot VMA
#property indicator_label1  "VMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  9;             // Period of calculation
input uint                 InpSmoothing      =  2;             // Period of smoothing
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferVMA[];
double         BufferCMO[];
double         BufferPOS[];
double         BufferNEG[];
double         BufferMA[];
//--- global variables
int            handle_ma;
int            period_calc;
int            period_smooth;
double         sc;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_calc=int(InpPeriod<1 ? 1 : InpPeriod);
   period_smooth=int(InpSmoothing<1 ? 1 : InpSmoothing);
   sc=2.0/(period_smooth+1.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferVMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCMO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferPOS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferNEG,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"VMA("+(string)period_calc+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferVMA,true);
   ArraySetAsSeries(BufferCMO,true);
   ArraySetAsSeries(BufferPOS,true);
   ArraySetAsSeries(BufferNEG,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handle MA
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<period_smooth+3) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferVMA,EMPTY_VALUE);
      ArrayInitialize(BufferCMO,EMPTY_VALUE);
      ArrayInitialize(BufferPOS,0);
      ArrayInitialize(BufferNEG,0);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- CMO
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double diff=BufferMA[i]-BufferMA[i+1];
      if(diff>0)
        {
         BufferPOS[i]=diff;
         BufferNEG[i]=0;
        }
      else if(diff<0)
        {
         BufferPOS[i]=0;
         BufferNEG[i]=-diff;
        }
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double s1=iMAOnArray(BufferPOS,0,period_calc,0,MODE_SMA,i);
      double s2=iMAOnArray(BufferNEG,0,period_calc,0,MODE_SMA,i);
      double value=(s1+s2)*100.0;
      BufferCMO[i]=(value!=0 ? (s1-s2)/value : 0);
     }
//--- Расчёт индикатора
   double abs_cmo=0;

   for(int i=limit; i>=0; i--)
     {
      if(i==rates_total-2)
        {
         BufferVMA[i]=BufferMA[i];
        }
      else
        {
         abs_cmo=fabs(BufferCMO[i])*100.0;
         BufferVMA[i]=(sc*abs_cmo*BufferMA[i])+(1-sc*abs_cmo)*BufferVMA[i+1];
        }
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
