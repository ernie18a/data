//+------------------------------------------------------------------+
//|                                                  SHL_MA_Band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed High/Low Linear regression band"
#property indicator_chart_window
#property indicator_buffers 9 // 5
#property indicator_plots   3
//--- plot HIST
#property indicator_label1  "Upper Band;Lower Band"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrRed,clrGold,clrFuchsia,clrLimeGreen,clrSalmon
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- plot H
#property indicator_label2  "High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot L
#property indicator_label3  "Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint           InpPeriod   =  15;         // Period
input ENUM_MA_METHOD InpMethod   =  MODE_EMA;   // Method
//--- indicator buffers
double         BufferHIST1[];
double         BufferHIST2[];
double         BufferHISTColors[];
double         BufferH[];
double         BufferL[];
//---
double         BufferMAH[];
double         BufferMAL[];
double         BufferLRLH[];
double         BufferLRLL[];
//--- global variables
int            period_ma;
int            handle_mah;
int            handle_mal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHIST1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHIST2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferHISTColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,BufferH,INDICATOR_DATA);
   SetIndexBuffer(4,BufferL,INDICATOR_DATA);
   SetIndexBuffer(5,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLRLH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferLRLL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SHLLRB("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHIST1,true);
   ArraySetAsSeries(BufferHIST2,true);
   ArraySetAsSeries(BufferHISTColors,true);
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferL,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferLRLH,true);
   ArraySetAsSeries(BufferLRLL,true);
//--- create MA High handle
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create MA Low handle
   ResetLastError();
   handle_mal=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
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
   if(rates_total<period_ma) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferHIST1,EMPTY_VALUE);
      ArrayInitialize(BufferHIST2,EMPTY_VALUE);
      ArrayInitialize(BufferH,EMPTY_VALUE);
      ArrayInitialize(BufferL,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,EMPTY_VALUE);
      ArrayInitialize(BufferMAL,EMPTY_VALUE);
      ArrayInitialize(BufferLRLH,0);
      ArrayInitialize(BufferLRLL,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;
//--- Расчёт LRL
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x=0,x2=0;
      double yH=0,xyH=0, yL=0,xyL=0;
      for(int j=0; j<period_ma; j++)
        {
         yH+=BufferMAH[i+j];
         xyH+=BufferMAH[i+j]*j;
         yL+=BufferMAL[i+j];
         xyL+=BufferMAL[i+j]*j;
         x+=j;
         x2+=j*j;
        }
      double temp=period_ma*x2-x*x;
      double mH=(period_ma*xyH-x*yH)/(temp!=0 ? temp : DBL_MIN);
      double yintH=(yH+mH*x)/period_ma;
      double mL=(period_ma*xyL-x*yL)/(temp!=0 ? temp : DBL_MIN);
      double yintL=(yL+mL*x)/period_ma;
      BufferLRLH[i]=yintH-mH*period_ma;
      BufferLRLL[i]=yintL-mL*period_ma;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferH[i]=BufferHIST1[i]=MAOnArray(BufferLRLH,0,period_ma,0,InpMethod,i);
      BufferL[i]=BufferHIST2[i]=MAOnArray(BufferLRLL,0,period_ma,0,InpMethod,i);
      //---
      if(BufferH[i]>BufferH[i+1])
         BufferHISTColors[i]=(BufferL[i]>BufferL[i+1] ? 1 : 0);
      else
         BufferHISTColors[i]=(BufferL[i]>BufferL[i+1] ? 3 : 2);
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
