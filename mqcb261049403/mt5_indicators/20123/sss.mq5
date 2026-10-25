//+------------------------------------------------------------------+
//|                                                          SSS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description   "Special Slow Stochastic"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot K
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DS
#property indicator_label3  "SSS"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriodK     =  5;    // %K period
input uint     InpPeriodD     =  3;    // %D period
input uint     InpSlowing     =  3;    // Slowing
input uint     InpPeriodDS    =  3;    // Period Special Slow
input double   InpOverbought  =  80.0; // Overbought
input double   InpOversold    =  20.0; // Oversold
//--- indicator buffers
double         BufferMAIN[];
double         BufferSIG[];
double         BufferDS[];
//--- global variables
double         overbought;
double         oversold;
int            period_k;
int            slowing;
int            period_d;
int            period_ds;
int            handle_sto;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   period_ds=int(InpPeriodDS<1 ? 1 : InpPeriodDS);
   oversold=(InpOversold<0 ? 0 : InpOversold> 99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMAIN,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSIG,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDS,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Sto("+(string)period_k+","+(string)slowing+","+(string)period_d+","+(string)period_ds+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMAIN,true);
   ArraySetAsSeries(BufferSIG,true);
   ArraySetAsSeries(BufferDS,true);
//--- create handle Stochastic
   ResetLastError();
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,slowing,MODE_SMA,STO_LOWHIGH);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k,",",(string)period_d,",",(string)slowing,") object was not created: Error ",GetLastError());
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
   if(rates_total<period_ds) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMAIN,EMPTY_VALUE);
      ArrayInitialize(BufferSIG,EMPTY_VALUE);
      ArrayInitialize(BufferDS,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1), copied=0;
   copied=CopyBuffer(handle_sto,MAIN_LINE,0,count,BufferMAIN);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferSIG);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferDS[i]=MAOnArray(BufferSIG,0,period_ds,0,MODE_SMA,i);

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
