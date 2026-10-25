//+------------------------------------------------------------------+
//|                                               MFI_normalized.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "John Bollinger's MFI normalized indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot NormMFI
#property indicator_label1  "Normalized MFI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodMFI      =  10;            // MFI period
input ENUM_APPLIED_VOLUME  InpAppliedVolume  =  VOLUME_TICK;   // MFI applied volume
input uint                 InpPeriodBB       =  40;            // BB period
input double               InpDeviation      =  2.0;           // BB deviation
//--- indicator buffers
double         BufferNormMFI[];
double         BufferMFI[];
//--- global variables
double         deviation;
int            period_mfi;
int            period_bb;
int            handle_mfi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_mfi=int(InpPeriodMFI<1 ? 1 : InpPeriodMFI);
   period_bb=int(InpPeriodBB<1 ? 1 : InpPeriodBB);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferNormMFI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMFI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MFI normalized ("+(string)period_mfi+","+(string)period_bb+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,1.0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferNormMFI,true);
   ArraySetAsSeries(BufferMFI,true);
//--- create MA's handles
   ResetLastError();
   handle_mfi=iMFI(NULL,PERIOD_CURRENT,period_mfi,InpAppliedVolume);
   if(handle_mfi==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMFI(",(string)period_mfi,") object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_bb,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_bb-period_mfi-1;
      ArrayInitialize(BufferNormMFI,0);
      ArrayInitialize(BufferMFI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_mfi,0,0,count,BufferMFI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double TL=BandsOnArray(rates_total,i,period_bb,deviation,BufferMFI,UPPER_BAND);
      double BL=BandsOnArray(rates_total,i,period_bb,deviation,BufferMFI,LOWER_BAND);
      BufferNormMFI[i]=((TL-BL)!=0 ? (BufferMFI[i]-BL)/(TL-BL) : 0);
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
