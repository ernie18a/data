//+------------------------------------------------------------------+
//|                                            Cumulative_Volume.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Cumulative Volume:"
#property description "Relative and Absolute presentation."
#property description "Cumulative or Separated (Up/Down)"
#property description " data presentation."

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot POS
#property indicator_label1  "Positive"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLimeGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot NEG
#property indicator_label2  "Negative"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrLimeGreen,clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod   =  14;         // Period
input ENUM_INPUT_YES_NO InpCombined =  INPUT_YES;  // Combined
input ENUM_INPUT_YES_NO InpRelative =  INPUT_NO;   // Relative
//--- indicator buffers
double                  BufferPOS[];
double                  BufferColorsPOS[];
double                  BufferNEG[];
double                  BufferColorsNEG[];
double                  BufferPosTMP[];
double                  BufferNegTMP[];
//--- global variables
int                     period_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPOS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsPOS,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferNEG,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsNEG,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferPosTMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferNegTMP,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Cumulative Volume("+(string)period_ma+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPOS,true);
   ArraySetAsSeries(BufferColorsPOS,true);
   ArraySetAsSeries(BufferNEG,true);
   ArraySetAsSeries(BufferColorsNEG,true);
   ArraySetAsSeries(BufferPosTMP,true);
   ArraySetAsSeries(BufferNegTMP,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferPOS,0);
      ArrayInitialize(BufferNEG,0);
      ArrayInitialize(BufferPosTMP,0);
      ArrayInitialize(BufferNegTMP,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0; i--)
     {
      if(close[i]>close[i+1])
        {
         BufferPosTMP[i]=(double)tick_volume[i]/100;
         BufferNegTMP[i]=0;
        }
      else
        {
         BufferPosTMP[i]=0;
         BufferNegTMP[i]=(double)tick_volume[i]/100;
        }
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double pos=MAOnArray(BufferPosTMP,0,period_ma,0,MODE_SMA,i)*period_ma;
      double neg=MAOnArray(BufferNegTMP,0,period_ma,0,MODE_SMA,i)*period_ma;
      double vol=0;
      for(int j=0; j<period_ma; j++)
         vol+=(double)tick_volume[i+j];
      vol/=100;
      if(InpCombined)
        {
         if(InpRelative)
           {
            double res=(pos-neg)*1000/vol;
            BufferPOS[i]=(res>0 ? res : 0);
            BufferNEG[i]=(res<=0 ? res : 0);
            BufferColorsPOS[i]=(BufferPOS[i]>BufferPOS[i+1] ? 0 : 1);
            BufferColorsNEG[i]=(BufferNEG[i]>BufferNEG[i+1] ? 0 : 1);
           }
         else
           {
            double res=pos-neg;
            BufferPOS[i]=(res>0 ? res : 0);
            BufferNEG[i]=(res<=0 ? res : 0);
            BufferColorsPOS[i]=(BufferPOS[i]>BufferPOS[i+1] ? 0 : 1);
            BufferColorsNEG[i]=(BufferNEG[i]>BufferNEG[i+1] ? 0 : 1);
           }
        }
      else
        {
         if(InpRelative)
           {
            BufferPOS[i]=pos*1000/vol;
            BufferNEG[i]=-neg*1000/vol;
            BufferColorsPOS[i]=0;
            BufferColorsNEG[i]=1;
           }
         else
           {
            BufferPOS[i]=pos;
            BufferNEG[i]=-neg;
            BufferColorsPOS[i]=0;
            BufferColorsNEG[i]=1;
           }
        }
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
