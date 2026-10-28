//+------------------------------------------------------------------+
//|                                           StochasticMomentum.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot STO
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SIG
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodSTO      =  13;         // Period
input uint              InpPeriodSIG      =  3;          // Signal
input ENUM_MA_METHOD    InpMethodSIG      =  MODE_SMA;   // Method
input ENUM_INPUT_YES_NO InpSmooth         =  INPUT_YES;  // Smooth
input uint              InpPeriodFirst    =  10;         // First MA period 
input ENUM_MA_METHOD    InpMethodFirst    =  MODE_SMA;   // First MA method
input uint              InpPeriodSecond   =  20;         // Second MA period
input ENUM_MA_METHOD    InpMethodSecond   =  MODE_SMA;   // Second MA method
//--- indicator buffers
double                  BufferSTO[];
double                  BufferSIG[];
double                  BufferRaw[];
double                  BufferFirst[];
double                  BufferSecond[];
//--- global variables
int                     period_sto;
int                     period_sig;
int                     period_1;
int                     period_2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sto=int(InpPeriodSTO<1 ? 1 : InpPeriodSTO);
   period_sig=int(InpPeriodSIG<1 ? 1 : InpPeriodSIG);
   period_1=int(InpPeriodFirst<1 ? 1 : InpPeriodFirst);
   period_2=int(InpPeriodSecond<1 ? 1 : InpPeriodSecond);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSTO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSIG,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRaw,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferFirst,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSecond,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,(InpSmooth ? "A" : "")+"SM("+(string)period_sto+","+(string)period_sig+","+(string)period_1+","+(string)period_2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSTO,true);
   ArraySetAsSeries(BufferSIG,true);
   ArraySetAsSeries(BufferRaw,true);
   ArraySetAsSeries(BufferFirst,true);
   ArraySetAsSeries(BufferSecond,true);
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
   if(rates_total<period_sto) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit1=limit;
   int limit2=limit;
   int limit3=limit;
   int limit4=limit;
   if(limit>1)
     {
      limit=rates_total-1;
      limit1=limit-period_sto;
      limit2=limit1-period_1;
      limit3=limit2-period_2;
      limit4=limit3-period_sig;
      ArrayInitialize(BufferSTO,0);
      ArrayInitialize(BufferSIG,0);
      ArrayInitialize(BufferRaw,0);
      ArrayInitialize(BufferFirst,0);
      ArrayInitialize(BufferSecond,0);
     }
//--- Подготовка данных
   for(int i=limit1; i>=0 && !IsStopped(); i--)
     {
      int h=Highest(period_sto,i);
      int l=Lowest(period_sto,i);
      if(h==WRONG_VALUE || l==WRONG_VALUE) return 0;
      BufferRaw[i]=close[i]-0.5*(low[l]+high[h]);
     }
//--- Расчёт главной линии
   if(InpSmooth)
     {
      for(int i=limit2; i>=0 && !IsStopped(); i--)
         BufferFirst[i]=MAOnArray(BufferRaw,0,period_1,0,InpMethodFirst,i);
      for(int i=limit3; i>=0; i--)
        {
         BufferSecond[i]=MAOnArray(BufferFirst,0,period_2,0,InpMethodSecond,i);
         BufferSTO[i]=BufferSecond[i];
        }
     }
   else
     {
      for(int i=limit1; i>=0 && !IsStopped(); i--)
         BufferSTO[i]=BufferRaw[i];
     }
//--- Расчёт сигнальной линии
   for(int i=limit4; i>=0 && !IsStopped(); i--)
      BufferSIG[i]=MAOnArray(BufferSTO,0,period_sig,0,InpMethodSIG,i);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвразает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвразает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
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
