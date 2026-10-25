//+------------------------------------------------------------------+
//|                                           Overbough_Oversold.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              https://mql5.com    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 5
#property indicator_plots   3
//--- plot ObOs
#property indicator_label1  "OB/OS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot overbought
#property indicator_label2  "OB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Oversold
#property indicator_label3  "OS"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriod=20;        // Period
input ENUM_MA_METHOD InpMethod;           // Method
input double         InpOverbought=70.0;  // Overbought
input double         InpOversold=30.0;    // Oversold
//--- indicator buffers
double         BufferObOs[];
double         BufferOB[];
double         BufferOS[];
double         BufferATR[];
double         BufferST[];
//--- global variables
int            period_ma;
int            handle_atr;
double         overbought;
double         oversold;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferObOs,INDICATOR_DATA);
   SetIndexBuffer(1,BufferOB,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOS,INDICATOR_DATA);
   SetIndexBuffer(3,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferST,INDICATOR_CALCULATIONS);
//--- set plot buffers parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_ma);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_ma);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_ma);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"OB/OS");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferObOs,true);
   ArraySetAsSeries(BufferOB,true);
   ArraySetAsSeries(BufferOS,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferST,true);
//--- create handle MA High
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_ma);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_ma,") object was not created: Error ",GetLastError());
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
   if(rates_total<period_ma+1) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferObOs,EMPTY_VALUE);
      ArrayInitialize(BufferOB,EMPTY_VALUE);
      ArrayInitialize(BufferOS,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
      ArrayInitialize(BufferST,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit>1 ? rates_total : 1);
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   for(int i=limit; i>=0; i--)
     {
      BufferST[i]=close[i]-low[i];
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferObOs[i]=100*MAOnArray(BufferST,0,period_ma,0,InpMethod,i)/(BufferATR[i]>0 ? BufferATR[i]: DBL_MIN);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferOB[i]=50+(overbought-50)/100*MAOnArray(BufferObOs,0,1,0,InpMethod,i);
      BufferOS[i]=50+(oversold-50)/100*MAOnArray(BufferObOs,0,1,0,InpMethod,i);
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
