//+------------------------------------------------------------------+
//|                                                      LR_MACD.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Linear regression MACD"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SIG
#property indicator_label2  "SIG"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot HIST
#property indicator_label3  "HIST"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrLimeGreen,clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input uint                 InpPeriodFast  =12;              // Fast LSMA period
input uint                 InpPeriodSlow  =26;              // Slow LSMA period
input uint                 InpPeriodSig   =9;               // Signal period
input ENUM_MA_METHOD       InpMethodSig   =  MODE_EMA;      // Signal method
input ENUM_APPLIED_PRICE   InpPriceSig    =  PRICE_CLOSE;   // Signal applied price
//--- indicator buffers
double         BufferMACD[];
double         BufferSIG[];
double         BufferHIST[];
double         BufferColors[];
//---
double         BufferMAF[];
double         BufferMAS[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_sig;
int            handle_maf;
int            handle_mas;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSIG,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHIST,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMAF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAS,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LRMACD("+(string)period_fast+","+(string)period_slow+","+(string)period_sig+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSIG,true);
   ArraySetAsSeries(BufferHIST,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAF,true);
   ArraySetAsSeries(BufferMAS,true);
//--- create MA fast handle
   ResetLastError();
   handle_maf=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_maf==INVALID_HANDLE)
     {
      Print("The Fast iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create MA slow handle
   ResetLastError();
   handle_mas=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_mas==INVALID_HANDLE)
     {
      Print("The Slow iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
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
   int max=fmax(period_fast,period_slow);
   if(rates_total<max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max-2;
      ArrayInitialize(BufferMACD,EMPTY_VALUE);
      ArrayInitialize(BufferSIG,EMPTY_VALUE);
      ArrayInitialize(BufferHIST,EMPTY_VALUE);
      ArrayInitialize(BufferMAF,EMPTY_VALUE);
      ArrayInitialize(BufferMAS,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_maf,0,0,count,BufferMAF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mas,0,0,count,BufferMAS);
   if(copied!=count) return 0;
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double xF=0,x2F=0, xS=0,x2S=0;
      double yF=0,xyF=0, yS=0,xyS=0;
      for(int jf=0; jf<period_fast; jf++)
        {
         yF+=BufferMAF[i+jf];
         xyF+=BufferMAF[i+jf]*jf;
         xF+=jf;
         x2F+=jf*jf;
        }
      for(int js=0; js<period_slow; js++)
        {
         yS+=BufferMAS[i+js];
         xyS+=BufferMAS[i+js]*js;
         xS+=js;
         x2S+=js*js;
        }
      //--- Fast LSMA
      double tempF=period_fast*x2F-xF*xF;
      double mF=(period_fast*xyF-xF*yF)/(tempF!=0 ? tempF : DBL_MIN);
      double yintF=(yF+mF*xF)/period_fast;
      //--- Slow LSMA
      double tempS=period_slow*x2S-xS*xS;
      double mS=(period_slow*xyS-xS*yS)/(tempS!=0 ? tempS : DBL_MIN);
      double yintS=(yS+mS*xS)/period_slow;
      //---
      BufferMAF[i]=yintF-mF*period_fast;
      BufferMAS[i]=yintS-mS*period_slow;
      BufferMACD[i]=BufferMAF[i]-BufferMAS[i];
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSIG[i]=MAOnArray(BufferMACD,0,period_sig,0,InpMethodSig,i);
      BufferHIST[i]=BufferMACD[i]-BufferSIG[i];
      BufferColors[i]=(BufferHIST[i]>BufferHIST[i+1] ? 0 : 1);
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
