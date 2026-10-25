//+------------------------------------------------------------------+
//|                                         Candle_Range_Envelop.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Candle Range Envelop"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
//--- plot Range
#property indicator_label1  "Range"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Top
#property indicator_label3  "Top"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_MODE_ENV
  {
   MODE_ENV_DEV,  // Deviation
   MODE_ENV_PRC   // Percentage
  };
//---
enum ENUM_MODE_PRC
  {
   MODE_PRC_HL,   // High/Low
   MODE_PRC_OC    // Open/Close
  };
//--- input parameters
input uint           InpPeriodRng      =  1;             // Range period
input uint           InpPeriodSig      =  14;            // Signal period
input uint           InpPeriodDev      =  14;            // Deviation period
input double         InpDeviation      =  2.0;           // Deviation multiplier
input double         InpEnvPrcTop      =  20.0;          // Percent top envelope
input double         InpEnvPrcBottom   =  20.0;          // Percent bottom envelope
input ENUM_MODE_ENV  InpMethodEnv      =  MODE_ENV_DEV;  // Envelop method
input ENUM_MODE_PRC  InpMethodPrc      =  MODE_PRC_HL;   // Price method
//--- indicator buffers
double         BufferRange[];
double         BufferColors[];
double         BufferSignal[];
double         BufferTop[];
double         BufferBottom[];
//--- global variables
double         deviation;
double         percent_t;
double         percent_b;
int            period_rng;
int            period_sig;
int            period_dev;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rng=int(InpPeriodRng<1 ? 1 : InpPeriodRng);
   period_sig=int(InpPeriodSig<1 ? 1 : InpPeriodSig);
   period_dev=int(InpPeriodDev<1 ? 1 : InpPeriodDev);
   period_max=fmax(period_dev,fmax(period_rng,period_sig));
   percent_b=InpEnvPrcBottom;
   percent_t=InpEnvPrcTop;
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRange,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBottom,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Candle Range Envelop");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRange,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferRange,0);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //--- гистограмма
      if(InpMethodPrc==MODE_PRC_HL)
        {
         int bh=Highest(period_rng,i);
         int bl=Lowest(period_rng,i);
         if(bh==WRONG_VALUE || bl==WRONG_VALUE)
            continue;
         BufferRange[i]=(high[bh]-low[bl])/Point();
        }
      else
        {
         BufferRange[i]=fabs(open[i+period_rng]-close[i])/Point();
        }
      BufferSignal[i]=SMA(rates_total,BufferRange,period_sig,i);
      //--- огибающие и цвет столбцов
      double delta_t=0,delta_b=0;
      if(InpMethodEnv==MODE_ENV_DEV)
         delta_b=delta_t=StdDevSMA(BufferSignal,period_dev,i)*deviation;
      else
        {
         delta_t=(BufferSignal[i]/100.0)*percent_t;
         delta_b=(BufferSignal[i]/100.0) *percent_b;
        }
      BufferTop[i]=BufferSignal[i]+delta_t;
      BufferBottom[i]=BufferSignal[i]-delta_b;
      BufferColors[i]=(BufferRange[i]>BufferTop[i] ? 0 : BufferRange[i]<BufferBottom[i] ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return array_src[shift];
   double sum=0;
   for(int i=0; i<period; i++)
      sum+=array_src[shift+i];
   return(sum/period);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Стандартное отклонение SMA на баре i                             |
//+------------------------------------------------------------------+
double StdDevSMA(double &array[],int period,int index)
  {
   double avg=0;
   for(int i=0; i<period; i++)
      avg+=array[index+i];
   avg=avg/period;
   double SD=0;
   for(int i=0; i<period; i++)
      SD+=(avg-array[index+i])*(avg-array[index+i]);
   SD=sqrt(SD/period);
   return SD;
  }
//+------------------------------------------------------------------+