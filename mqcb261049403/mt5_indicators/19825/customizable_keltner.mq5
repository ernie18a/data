//+------------------------------------------------------------------+
//|                                         Customizable Keltner.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_METHOD_VARIATION
  {
   METHOD_HL,                 // Smoothed H-L
   METHOD_ATR                 // ATR as source
  };
//--- input parameters
input int                     InpSmoothCenter      =  50;            // Number of the periods to smooth the center line
input int                     InpSmoothDeviation   =  50;            // Number of periods to smooth deviation
input double                  InpF                 =  1.0;           // Factor which is used to apply the deviation
input ENUM_APPLIED_PRICE      InpAppliedPrice      =  PRICE_CLOSE;   // The center line applied price:
input ENUM_MA_METHOD          InpMethodSmoothing   =  MODE_SMA;      // The center line smoothing method
input ENUM_METHOD_VARIATION   InpMethodVariation   =  METHOD_HL;     // Variation Method
//--- indicator buffers
double         BufferUpper[];
double         BufferMiddle[];
double         BufferLower[];
double         BufferVariation[];
//--- global variables
int            handle_ma;
int            handle_atr;
int            period_center;
int            period_dev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(3,BufferVariation,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Keltner with color zones");
//--- settings variables
   period_center=(InpSmoothCenter<1 ? 1 : InpSmoothCenter);
   period_dev=(InpSmoothDeviation<1 ? 1 : InpSmoothDeviation);
//--- MA and ATR handles
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,period_center,0,(ENUM_MA_METHOD)InpMethodSmoothing,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   if(InpMethodVariation==METHOD_ATR)
     {
      ResetLastError();
      handle_atr=iATR(Symbol(),PERIOD_CURRENT,period_dev);
      if(handle_atr==INVALID_HANDLE)
        {
         Print("The iATR object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
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
//--- Зададим направление индексации массивов как у таймсерий
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferVariation,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int copied_ma=0,copied_atr=0,limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferVariation,EMPTY_VALUE);
      copied_ma=CopyBuffer(handle_ma,0,0,rates_total,BufferMiddle);
      if(copied_ma!=rates_total) return 0;
      if(InpMethodVariation==METHOD_ATR)
        {
         copied_atr=CopyBuffer(handle_atr,0,0,rates_total,BufferVariation);
         if(copied_atr!=rates_total) return 0;
        }
      else for(int i=limit; i>=0; i--) BufferVariation[i]=high[i]-low[i];
     }
//--- Подготовка данных
   int copied=(limit>1 ? rates_total : 1);
   copied_ma=CopyBuffer(handle_ma,0,0,copied,BufferMiddle);
   if(copied_ma!=copied) return 0;
   if(InpMethodVariation==METHOD_ATR)
     {
      copied_atr=CopyBuffer(handle_atr,0,0,copied,BufferVariation);
      if(copied_atr!=copied) return 0;
     }
   else for(int i=limit; i>=0; i--)
      BufferVariation[i]=high[i]-low[i];
//--- Цикл расчёта индикатора
   double v=0.0;
   for(int i=limit; i>=0; i--)
     {
      v=(InpMethodVariation==METHOD_ATR ? BufferVariation[i] : iMAOnArray(BufferVariation,0,period_dev,0,InpMethodVariation,i));
      BufferUpper[i]=BufferMiddle[i]+v*InpF;
      BufferLower[i]=BufferMiddle[i]-v*InpF;
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
