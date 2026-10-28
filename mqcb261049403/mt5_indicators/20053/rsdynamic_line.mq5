//+------------------------------------------------------------------+
//|                                               RSdynamic_line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
//--- plot Supp
#property indicator_label1  "Support"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Resist
#property indicator_label2  "Resistance"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MA1
#property indicator_label3  "MA1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot MA2
#property indicator_label4  "MA2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrFuchsia
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_PRICE_CALC
  {
   PRICE_CALC_CLOSE  =  PRICE_CLOSE,   // Close
   PRICE_CALC_OPEN   =  PRICE_OPEN,    // Open
   PRICE_CALC_HIGH   =  PRICE_HIGH,    // High
   PRICE_CALC_LOW    =  PRICE_LOW      // Low
  };
//--- input parameters
input uint              InpPeriodMA       =  14;               // Period
input ENUM_PRICE_CALC   InpAppliedPrice   =  PRICE_CALC_CLOSE; // Applied price
//--- indicator buffers
double         BufferSupp[];
double         BufferResist[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferMATMP[];
double         BufferStream1[];
double         BufferStream2[];
double         BufferStream3[];
//--- global variables
int            handle_ma;
int            period_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSupp,INDICATOR_DATA);
   SetIndexBuffer(1,BufferResist,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMATMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferStream1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferStream2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferStream3,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"RS dynamic line indicator");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSupp,true);
   ArraySetAsSeries(BufferResist,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferMATMP,true);
   ArraySetAsSeries(BufferStream1,true);
   ArraySetAsSeries(BufferStream2,true);
   ArraySetAsSeries(BufferStream3,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,(ENUM_APPLIED_PRICE)InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA object was not created: Error ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferSupp,EMPTY_VALUE);
      ArrayInitialize(BufferResist,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,EMPTY_VALUE);
      ArrayInitialize(BufferMA2,EMPTY_VALUE);
      ArrayInitialize(BufferMATMP,EMPTY_VALUE);
      ArrayInitialize(BufferStream1,EMPTY_VALUE);
      ArrayInitialize(BufferStream2,EMPTY_VALUE);
      ArrayInitialize(BufferStream3,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMATMP);
   if(copied!=count) return 0;
   for(int i=limit; i>=0; i--)
     {
      int HHVindex=Highest(Symbol(),PERIOD_CURRENT,(ENUM_APPLIED_PRICE)InpAppliedPrice,period_ma,i);
      int LLVindex=Lowest(Symbol(),PERIOD_CURRENT,(ENUM_APPLIED_PRICE)InpAppliedPrice,period_ma,i);
      int HHV2index=Highest(Symbol(),PERIOD_CURRENT,(ENUM_APPLIED_PRICE)InpAppliedPrice,period_ma/2,i);
      int LLV2index=Lowest(Symbol(),PERIOD_CURRENT,(ENUM_APPLIED_PRICE)InpAppliedPrice,period_ma/2,i);
      if(HHVindex==WRONG_VALUE || LLVindex==WRONG_VALUE || HHV2index==WRONG_VALUE || LLV2index==WRONG_VALUE)
         continue;
      double HHV=BufferMATMP[HHVindex];
      double LLV=BufferMATMP[LLVindex];
      double HHV2=BufferMATMP[HHV2index];
      double LLV2=BufferMATMP[LLV2index];
      double a1=(HHV+LLV+BufferMATMP[i])/3;
      BufferStream1[i]=2*a1-HHV;
      BufferStream2[i]=2*a1-LLV;
      BufferStream3[i]=(HHV2+LLV2+BufferMATMP[i])/3;
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSupp[i]=MAOnArray(BufferStream1,0,period_ma,0,MODE_SMA,i);
      BufferResist[i]=MAOnArray(BufferStream2,0,period_ma,0,MODE_SMA,i);
      BufferMA1[i]=MAOnArray(BufferStream3,0,period_ma/2,0,MODE_SMA,i);
      BufferMA2[i]=(BufferSupp[i]+BufferResist[i]+BufferMA1[i])/3;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
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
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
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
