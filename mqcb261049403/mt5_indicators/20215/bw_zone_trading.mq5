//+------------------------------------------------------------------+
//|                                              BW_Zone_Trading.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Modified BW Zone Trading"
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots   5

//--- plot Signal UP
#property indicator_label1  "Signal Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal Down
#property indicator_label2  "Signal Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot Zone to Up
#property indicator_label3  "Bullish zone"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Zone to Down
#property indicator_label4  "Bearish zone"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrFireBrick
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- plot Zone
#property indicator_label5  "Open;High;Low;Close"
#property indicator_type5   DRAW_COLOR_CANDLES
#property indicator_color5  clrLimeGreen,clrOrangeRed,clrGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- enums
enum ENUM_FILTER_TYPE
  {
   FILTER_TYPE_ONE,  // By AO and AC
   FILTER_TYPE_TWO,  // By AO
   FILTER_TYPE_THREE // By AC
  };
//--- input parameters
input uint                 InpPeriodFastMA   =  5;                // AO Fast MA period
input uint                 InpPeriodSlowMA   =  35;               // AO Slow MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_MEDIAN;     // AO Applied price
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;         // AO Calculation method
input uint                 InpAccDec         =  5;                // AC smoothing period
input ENUM_FILTER_TYPE     InpFilter         =  FILTER_TYPE_ONE;  // Filter type
//--- indicator buffers
double         BufferArrUP[];
double         BufferArrDN[];
double         BufferBullish[];
double         BufferBearish[];
//---
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
double         BufferColors[];
//---
double         BufferFMA[];
double         BufferSMA[];
double         BufferAO[];
double         BufferAC[];
double         BufferSigAO[];
double         BufferSigAC[];
double         BufferSignal[];
//--- global variables
int            period_fast_ma;
int            period_slow_ma;
int            acc_dec;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_fast_ma=int(InpPeriodFastMA<1 ? 1 : InpPeriodFastMA);
   period_slow_ma=int(InpPeriodSlowMA<1 ? 1 : InpPeriodSlowMA);
   acc_dec=int(InpAccDec<1 ? 1 : InpAccDec);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArrUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArrDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBullish,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBearish,INDICATOR_DATA);
   //---
   SetIndexBuffer(4,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(5,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(6,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(7,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(8,BufferColors,INDICATOR_COLOR_INDEX);
//---
   SetIndexBuffer(9,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferAC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferSigAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferSigAC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferSignal,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"BW Zone("+(string)period_fast_ma+","+(string)period_slow_ma+","+(string)acc_dec+")");
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,32);
   PlotIndexSetInteger(1,PLOT_ARROW,32);
   PlotIndexSetInteger(2,PLOT_ARROW,32);
   PlotIndexSetInteger(3,PLOT_ARROW,32);
//--- setting plot buffer
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArrUP,true);
   ArraySetAsSeries(BufferArrDN,true);
   ArraySetAsSeries(BufferBullish,true);
   ArraySetAsSeries(BufferBearish,true);
   //---
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
   ArraySetAsSeries(BufferColors,true);
//---
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferAO,true);
   ArraySetAsSeries(BufferAC,true);
   ArraySetAsSeries(BufferSigAO,true);
   ArraySetAsSeries(BufferSigAC,true);
   ArraySetAsSeries(BufferSignal,true);
//--- create MA`s handle
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast_ma,0,InpMethod,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The Fast iMA(",(string)period_fast_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow_ma,0,InpMethod,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The Slow iMA(",(string)period_slow_ma,") object was not created: Error ",GetLastError());
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
   int max=fmax(period_fast_ma,fmax(period_slow_ma,acc_dec));
   if(rates_total<max) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferArrUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrDN,EMPTY_VALUE);
      ArrayInitialize(BufferBullish,EMPTY_VALUE);
      ArrayInitialize(BufferBearish,EMPTY_VALUE);
      //---
      ArrayInitialize(BufferOpen,0);
      ArrayInitialize(BufferHigh,0);
      ArrayInitialize(BufferLow,0);
      ArrayInitialize(BufferClose,0);
      //---
      ArrayInitialize(BufferFMA,EMPTY_VALUE);
      ArrayInitialize(BufferSMA,EMPTY_VALUE);
      ArrayInitialize(BufferAO,0);
      ArrayInitialize(BufferAC,0);
      ArrayInitialize(BufferSigAO,0);
      ArrayInitialize(BufferSigAC,0);
      ArrayInitialize(BufferSignal,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0; i--)
      BufferAO[i]=BufferFMA[i]-BufferSMA[i];
   for(int i=limit; i>=0; i--)
      BufferAC[i]=BufferAO[i]-MAOnArray(BufferAO,0,acc_dec,0,InpMethod,i);
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferArrUP[i]=BufferArrDN[i]=BufferBullish[i]=BufferBearish[i]=EMPTY_VALUE;
      BufferSignal[i]=2;
      BufferSigAO[i]=(BufferAO[i]>BufferAO[i+1] ? 0 : BufferAO[i]<BufferAO[i+1]? 1 : BufferSigAO[i+1]);
      BufferSigAC[i]=(BufferAC[i]>BufferAC[i+1] ? 0 : BufferAC[i]<BufferAC[i+1] ? 1 : BufferSigAC[i+1]);
      //---
      BufferSignal[i]=
        (
         InpFilter==FILTER_TYPE_ONE ?
            (BufferSigAO[i]==0 && BufferSigAC[i]==0) ? 0 : 
            (BufferSigAO[i]==1 && BufferSigAC[i]==1) ? 1 : 2 :
         InpFilter==FILTER_TYPE_TWO ?
            BufferSigAO[i] :
         InpFilter==FILTER_TYPE_THREE ?
            BufferSigAC[i] : 2
        );
      BufferBullish[i]=(BufferSignal[i]==0 ? low[i] : EMPTY_VALUE);
      BufferBearish[i]=(BufferSignal[i]==1 ? high[i] : EMPTY_VALUE);
      BufferArrUP[i]=(BufferBullish[i]!=EMPTY_VALUE && BufferBullish[i+1]==EMPTY_VALUE ? low[i] : EMPTY_VALUE);
      BufferArrDN[i]=(BufferBearish[i]!=EMPTY_VALUE && BufferBearish[i+1]==EMPTY_VALUE ? high[i] : EMPTY_VALUE);
      //--- Свечи
      BufferOpen[i]=open[i];
      BufferHigh[i]=high[i];
      BufferLow[i]=low[i];
      BufferClose[i]=close[i];
      BufferColors[i]=BufferSignal[i];
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
