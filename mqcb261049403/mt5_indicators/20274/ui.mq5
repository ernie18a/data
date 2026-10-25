//+------------------------------------------------------------------+
//|                                                           UI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Ulcer index"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot UI
#property indicator_label1  "UI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriodMA       =  14;            // Period
input ENUM_INPUT_YES_NO    InpInvPair        =  INPUT_NO;      // Inverse pair
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferUI[];
double         BufferPD[];
double         BufferMA[];
//--- global variables
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Ulcer index("+(string)period_ma+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUI,true);
   ArraySetAsSeries(BufferPD,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
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
   if(rates_total<period_ma) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-1;
      ArrayInitialize(BufferUI,EMPTY_VALUE);
      ArrayInitialize(BufferPD,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   int index;
   double max;
   double Pr;
   for(int i=limit; i>=0; i--)
     {
      if(InpInvPair)
        {
         index=Lowest(NULL,PERIOD_CURRENT,InpAppliedPrice,period_ma,i);
         if(index==WRONG_VALUE) return 0;
         max=1/BufferMA[index];
         Pr=1/BufferMA[i];     
        }
      else
        {
         index=Highest(NULL,PERIOD_CURRENT,InpAppliedPrice,period_ma,i);
         if(index==WRONG_VALUE) return 0;
         max=BufferMA[index];
         Pr=BufferMA[i];     
        }
      BufferPD[i]=pow((Pr-max)/(max!=0 ? max : DBL_MIN),2);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double MA=MAOnArray(BufferPD,0,period_ma,0,MODE_SMA,i);
      BufferUI[i]=sqrt(MA)*100;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии               |
//+------------------------------------------------------------------+
int Highest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   int copied=0;
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      default:
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии                |
//+------------------------------------------------------------------+
int Lowest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      default:
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
     }
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
