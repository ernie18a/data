//+------------------------------------------------------------------+
//|                                                 Par_MA_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Parabolic Moving Average with Bands indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot MA
#property indicator_label1  "Parabolic MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BandUP
#property indicator_label2  "Upper Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BandDN
#property indicator_label3  "Lower Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpDeviation      =  1.0;           // Deviation
//--- indicator buffers
double         BufferPMA[];
double         BufferBandUP[];
double         BufferBandDN[];
double         BufferMA[];
double         BufferDev[];
double         BufferMADevTmp[];
//--- global variables
double         sum_x;
double         sum_x2;
double         sum_x3;
double         sum_x4;
double         deviation;
int            period_pma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   deviation=InpDeviation;
   period_pma=int(InpPeriod<3 ? 3 : InpPeriod);
   sum_x=(1.0+period_pma)*period_pma/2.0;
   sum_x2=(1.0+period_pma)*(2.0*period_pma+1.0)*period_pma/6.0;
   sum_x3=sum_x*sum_x;
   sum_x4=(1.0+period_pma)*period_pma*(2.0*period_pma+1.0)*(3.0*period_pma*period_pma+3.0*period_pma-1.0)/30.0;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBandUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBandDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMADevTmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PMAwB ("+(string)period_pma+","+(string)deviation+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPMA,true);
   ArraySetAsSeries(BufferBandUP,true);
   ArraySetAsSeries(BufferBandDN,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferMADevTmp,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_pma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_pma-1;
      ArrayInitialize(BufferPMA,EMPTY_VALUE);
      ArrayInitialize(BufferBandUP,EMPTY_VALUE);
      ArrayInitialize(BufferBandDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDev,0);
      ArrayInitialize(BufferMADevTmp,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum_y=0.0;
      double sum_xy=0.0;
      double sum_x2y=0.0;
      for(int j=1;j<=period_pma;j++)
        {
         double tmp=BufferMA[i+period_pma-j];
         sum_y+=tmp;
         sum_xy+=tmp*j;
         sum_x2y+=tmp*j*j;
        }
      double F=sum_x3;
      double M=sum_x4;
      double P=sum_y;
      double R=sum_xy;
      double S=sum_x2y;
      double E=sum_x2;
      double L=sum_x3;
      double Q=sum_x/period_pma;
      E-=Q*sum_x;
      F-=Q*sum_x2;
      R-=Q*P;
      Q=sum_x2/period_pma;
      L-=Q*sum_x;
      M-=Q*sum_x2;
      S-=Q*P;
      Q=L/E;
      double B2=(S-R*Q)/(M-F*Q);
      double B1=(R-F*B2)/E;
      double B0=(P-sum_x*B1-sum_x2*B2)/period_pma;
      BufferPMA[i]=B0+(B1+B2*period_pma)*period_pma;
     }
   if(StdDevOnArray(rates_total,prev_calculated,0,period_pma,MODE_SMA,BufferMADevTmp,BufferPMA,BufferDev)==0)
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBandUP[i]=BufferPMA[i]+BufferDev[i]*deviation;
      BufferBandDN[i]=BufferPMA[i]-BufferDev[i]*deviation;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Standart Deviation on array                                      |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
template<typename T>
int StdDevOnArray(const int rates_total,
                  const int prev_calculated,
                  const int begin,
                  const int period,
                  const ENUM_MA_METHOD method,
                  double &buffer_ma_tmp[],
                  const T &src_array[],
                  double &dest_buffer[]
                  )
  {
//--- variables of indicator
   int pos=0;
//--- check for rates count
   if(rates_total<period) return(0);
//--- save as_series flags
   bool as_series_arr=ArrayGetAsSeries(src_array);
   bool as_series_dev=ArrayGetAsSeries(dest_buffer);
   bool as_series_ma=ArrayGetAsSeries(buffer_ma_tmp);
   if(as_series_arr)
      ArraySetAsSeries(src_array,false);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,false);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,false);

//--- starting work
   pos=prev_calculated-1;
//--- correct position for first iteration
   if(pos<period)
     {
      pos=period-1;
      ArrayInitialize(dest_buffer,0.0);
      ArrayInitialize(buffer_ma_tmp,0.0);
     }
//--- main cycle
   switch(method)
     {
      case  MODE_EMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=ExponentialMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_SMMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==period-1)
               buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            else
               buffer_ma_tmp[i]=SmoothedMA(i,period,buffer_ma_tmp[i-1],src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      case MODE_LWMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=LinearWeightedMA(i,period,src_array);
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
         break;
      default   :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            buffer_ma_tmp[i]=SimpleMA(i,period,src_array);
            //--- Calculate StdDev
            dest_buffer[i]=StdDevFunc(src_array,buffer_ma_tmp,period,i);
           }
     }
//--- restore as_series flags
   if(as_series_arr)
      ArraySetAsSeries(src_array,true);
   if(as_series_dev)
      ArraySetAsSeries(dest_buffer,true);
   if(as_series_ma)
      ArraySetAsSeries(buffer_ma_tmp,true);
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
template<typename T>
double StdDevFunc(const T &price[],const double &price_ma[],const int period,int position)
  {
   double dev=0.0;
   for(int i=0; i<period; i++) dev+=pow(price[position-i]-price_ma[position],2);
   dev=sqrt(dev/period);
   return(dev);
  }
//+------------------------------------------------------------------+
