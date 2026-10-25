//+------------------------------------------------------------------+
//|                                                        PPMCC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Pearson product-moment correlation coefficient"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   1
#property indicator_maximum 1
#property indicator_minimum -1
//--- plot PPMCC
#property indicator_label1  "PPMCC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  50;            // Period
input string               InpSymbolX        =  "EURUSD";      // First symbol name
input ENUM_APPLIED_PRICE   InpAppliedPriceX  =  PRICE_CLOSE;   // First symbol applied price
input string               InpSymbolY        =  "USDJPY";      // Second symbol name
input ENUM_APPLIED_PRICE   InpAppliedPriceY  =  PRICE_CLOSE;   // Second symbol applied price
//--- indicator buffers
double         BufferPPMCC[];
//---
double         BufferAB[];
double         BufferC[];
double         BufferD[];
//---
double         BufferMAX[];
double         BufferMAY[];
double         BufferMAA[];
double         BufferMAB[];
//--- global variables
int            period_ma;
int            handle_maX;
int            handle_maY;
int            handle_maA;
int            handle_maB;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPPMCC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferAB,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAY,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMAA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMAB,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PPMCC"+"("+(string)period_ma+")"+InpSymbolX+"/"+InpSymbolY);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPPMCC,true);
   ArraySetAsSeries(BufferAB,true);
   ArraySetAsSeries(BufferC,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferMAX,true);
   ArraySetAsSeries(BufferMAY,true);
   ArraySetAsSeries(BufferMAA,true);
   ArraySetAsSeries(BufferMAB,true);
//--- check symbol name
   if(!SymbolCheck(InpSymbolX))
      return INIT_FAILED;
   if(!SymbolCheck(InpSymbolY))
      return INIT_FAILED;
//--- create MA's handle
   ResetLastError();
   handle_maX=iMA(InpSymbolX,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPriceX);
   if(handle_maX==INVALID_HANDLE)
     {
      Print("The ",InpSymbolX," iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maA=iMA(InpSymbolX,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPriceX);
   if(handle_maA==INVALID_HANDLE)
     {
      Print("The ",InpSymbolX," iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maY=iMA(InpSymbolY,PERIOD_CURRENT,period_ma,0,MODE_SMA,InpAppliedPriceY);
   if(handle_maY==INVALID_HANDLE)
     {
      Print("The ",InpSymbolY," iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maB=iMA(InpSymbolY,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPriceY);
   if(handle_maB==INVALID_HANDLE)
     {
      Print("The ",InpSymbolY," iMA(1) object was not created: Error ",GetLastError());
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
   int barsX=Bars(InpSymbolX,PERIOD_CURRENT);
   int barsY=Bars(InpSymbolY,PERIOD_CURRENT);
   if(rates_total<4 || barsX<4 || barsY<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferPPMCC,EMPTY_VALUE);
      ArrayInitialize(BufferAB,0);
      ArrayInitialize(BufferC,0);
      ArrayInitialize(BufferMAX,0);
      ArrayInitialize(BufferMAY,0);
      ArrayInitialize(BufferMAA,0);
      ArrayInitialize(BufferMAB,0);
     }
   int limit_min=fmin(rates_total,fmin(barsX,barsY))-1;
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : limit_min);
   copied=CopyBuffer(handle_maX,0,0,count,BufferMAX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maA,0,0,count,BufferMAA);
   if(copied!=count) return 0;
   //---
   copied=CopyBuffer(handle_maY,0,0,count,BufferMAY);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maB,0,0,count,BufferMAB);
   if(copied!=count) return 0;
   //---
   count=(limit==0 ? limit : limit_min);
   for(int i=count; i>=0 && !IsStopped(); i--)
     {
      int index1=BarShift(InpSymbolX,PERIOD_CURRENT,time[i]);
      int index2=BarShift(InpSymbolY,PERIOD_CURRENT,time[i]);
      if(index1>count || index2>count) continue;
      if(index1!=WRONG_VALUE && index2!=WRONG_VALUE)
        {
         double avg1=BufferMAX[index1]; 
         double avg2=BufferMAY[index2];  
         double a=BufferMAA[index1]-avg1;
         double b=BufferMAB[index1]-avg2;
         BufferAB[i]=a*b;
         BufferC[i]=a*a;
         BufferD[i]=b*b;
        }
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Numerator=MAOnArray(BufferAB,0,period_ma,0,MODE_SMA,i);
      double DenominatorC=MAOnArray(BufferC,0,period_ma,0,MODE_SMA,i);
      double DenominatorD=MAOnArray(BufferD,0,period_ma,0,MODE_SMA,i);
      double Denominator=sqrt(DenominatorC*DenominatorD);
      BufferPPMCC[i]=Numerator/(Denominator!=0 ? Denominator : DBL_MIN);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/code/1864                                |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   datetime last_bar;
   if(!SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      datetime array[1];
      if(CopyTime(symbol_name,timeframe,0,1,array)==1)
         last_bar=array[0];
      else
         return WRONG_VALUE;
     }
   if(time>last_bar)
      return(0);
   int shift=Bars(symbol_name,timeframe,time,last_bar);
   datetime array[1];
   if(CopyTime(symbol_name,timeframe,time,1,array)==1)
      return(array[0]==time ? shift-1 : exact && time>array[0]+PeriodSeconds(timeframe) ? WRONG_VALUE : shift);
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
