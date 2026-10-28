//+------------------------------------------------------------------+
//|                                             Dynamic_Zone_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Dynamic Zone RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot RSI
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Middle
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot arrow up
#property indicator_label5  "Intersection up"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot arrow down
#property indicator_label6  "Intersection down"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//--- input parameters
input uint              InpPeriodRSI   =  5;          // RSI period
input uint              InpPeriodBB    =  30;         // Bands period
input double            InpDeviation   =  1.3185;     // Deviation
input ENUM_INPUT_YES_NO InpShowArrows  =  INPUT_YES;  // Show intersection arrows
input ENUM_INPUT_YES_NO InpUseMiddle   =  INPUT_NO;   // Allow midline intersections
input ENUM_INPUT_YES_NO InpUseAlerts   =  INPUT_NO;   // Use alerts
//--- indicator buffers
double         BufferRSI[];
double         BufferTop[];
double         BufferMiddle[];
double         BufferBottom[];
double         BufferArrUP[];
double         BufferArrDN[];
//--- global variables
double         deviation;
int            period_rsi;
int            period_bb;
int            handle_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_bb=int(InpPeriodBB<1 ? 1 : InpPeriodBB);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(4,BufferArrUP,INDICATOR_DATA);
   SetIndexBuffer(5,BufferArrDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(4,PLOT_ARROW,158);
   PlotIndexSetInteger(5,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Dynamic Zone RSI ("+(string)period_rsi+","+(string)period_bb+","+DoubleToString(deviation,4)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferArrUP,true);
   ArraySetAsSeries(BufferArrDN,true);
//--- create handle
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI (",(string)period_rsi,") object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_bb,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferArrUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrDN,EMPTY_VALUE);
     }

//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTop[i]=BandsOnArray(rates_total,i,period_bb,deviation,BufferRSI,UPPER_BAND);
      BufferMiddle[i]=BandsOnArray(rates_total,i,period_bb,deviation,BufferRSI,BASE_LINE);
      BufferBottom[i]=BandsOnArray(rates_total,i,period_bb,deviation,BufferRSI,LOWER_BAND);
      
      BufferArrUP[i]=BufferArrDN[i]=EMPTY_VALUE;
      if(InpShowArrows)
        {
         if((BufferRSI[i+1]<=BufferTop[i+1] && BufferRSI[i]>BufferTop[i]) || (InpUseMiddle && BufferRSI[i+1]<=BufferMiddle[i+1] && BufferRSI[i]>BufferMiddle[i]) || (BufferRSI[i+1]<=BufferBottom[i+1] && BufferRSI[i]>BufferBottom[i]))
            BufferArrUP[i]=BufferRSI[i];
         if((BufferRSI[i+1]>=BufferTop[i+1] && BufferRSI[i]<BufferTop[i]) || (InpUseMiddle && BufferRSI[i+1]>=BufferMiddle[i+1] && BufferRSI[i]<BufferMiddle[i]) || (BufferRSI[i+1]>=BufferBottom[i+1] && BufferRSI[i]<BufferBottom[i]))
            BufferArrDN[i]=BufferRSI[i];
        }
     }
   static datetime last_time=0;
   if(InpUseAlerts)
     {
      if(time[0]>last_time)
        {
         if(BufferRSI[0]>BufferTop[0] && BufferRSI[1]<=BufferTop[1])
            Alert(Symbol()+" "+TimeframeToString(Period())+": RSI Above Top Band");
         if(BufferRSI[0]<BufferBottom[0] && BufferRSI[1]>=BufferBottom[1])
            Alert(Symbol()+" "+TimeframeToString(Period())+": RSI Below Bottom Band");
         last_time=TimeCurrent();
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| BandsOnArray                                                     |
//+------------------------------------------------------------------+
double BandsOnArray(const int rates_total,const int index,const int period,const double deviation_bb,const double &array[],const int line,const bool as_series=true)
  {
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate StdDev
   double dev=StdDevOnArray(rates_total,index,period,array);
//--- base line
   double mid=0;
   for(int i=0; i<period; i++)
      mid+=array[index+i];
   mid/=period;
//--- upper line
   double top=mid+dev*deviation_bb;
//--- lower line
   double btm=mid-dev*deviation_bb;
   return(line==UPPER_BAND ? top : line==LOWER_BAND ? btm : mid);
  }
//+------------------------------------------------------------------+
//| StdDevOnArray                                                    |
//+------------------------------------------------------------------+
double StdDevOnArray(const int rates_total,const int index,const int period,const double &array[],const bool as_series=true)
  {
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   double avg=0;
   for(int i=0; i<period; i++)
      avg+=array[index+i];
   avg/=period;
   double sd=0;
   for(int i=0; i<period; i++)
      sd+=(avg-array[index+i])*(avg-array[index+i]);
   return(sqrt(sd/period));
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
