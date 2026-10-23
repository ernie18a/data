//+------------------------------------------------------------------+
//|                                             Gann_Multi_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Gann multi trend indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot UP1
#property indicator_label1  "First up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP2
#property indicator_label2  "Second up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot UP3
#property indicator_label3  "Third up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot DN1
#property indicator_label4  "First down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot DN2
#property indicator_label5  "Second down"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrange
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot DN3
#property indicator_label6  "Third down"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
//--- input parameters
input uint     InpPeriod1  =  1;    // Short term period
input uint     InpPeriod2  =  2;    // Medium term period
input uint     InpPeriod3  =  3;    // Long term period
input int      InpDev      =  15;   // Deviation
//--- indicator buffers
double         BufferUP1[];
double         BufferUP2[];
double         BufferUP3[];
double         BufferDN1[];
double         BufferDN2[];
double         BufferDN3[];
//--- global variables
int            period_1;
int            period_2;
int            period_3;
int            period_max;
double         k2;
double         k3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   period_max=fmax(period_1,fmax(period_2,period_3));
   k2=InpDev*Point();
   k3=2*InpDev*Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUP2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUP3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferDN2,INDICATOR_DATA);
   SetIndexBuffer(5,BufferDN3,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Gann multi trend ("+(string)period_1+","+(string)period_2+","+(string)period_3+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"First up("+(string)period_1+")");
   PlotIndexSetString(1,PLOT_LABEL,"Second up("+(string)period_2+")");
   PlotIndexSetString(2,PLOT_LABEL,"Third up("+(string)period_3+")");
   
   PlotIndexSetString(3,PLOT_LABEL,"First down("+(string)period_1+")");
   PlotIndexSetString(4,PLOT_LABEL,"Second down("+(string)period_2+")");
   PlotIndexSetString(5,PLOT_LABEL,"Third down("+(string)period_3+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP1,true);
   ArraySetAsSeries(BufferUP2,true);
   ArraySetAsSeries(BufferUP3,true);
   ArraySetAsSeries(BufferDN1,true);
   ArraySetAsSeries(BufferDN2,true);
   ArraySetAsSeries(BufferDN3,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferUP1,EMPTY_VALUE);
      ArrayInitialize(BufferUP2,EMPTY_VALUE);
      ArrayInitialize(BufferUP3,EMPTY_VALUE);
      ArrayInitialize(BufferDN1,EMPTY_VALUE);
      ArrayInitialize(BufferDN2,EMPTY_VALUE);
      ArrayInitialize(BufferDN3,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(!CalcData(i,period_1,BufferUP1,BufferDN1,high,low,0))  continue;
      if(!CalcData(i,period_2,BufferUP2,BufferDN2,high,low,k2)) continue;
      if(!CalcData(i,period_3,BufferUP3,BufferDN3,high,low,k3)) continue;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CalcData(const int index,const int period,
              double &array_up[],double &array_dn[],
              const double &high[],const double &low[],
              const double distance)
  {
   int bh=Highest(period,index+period);
   int bl=Lowest(period,index+period);
   if(bh==WRONG_VALUE || bl==WRONG_VALUE)
      return false;
   double max=high[bh];
   double min=low[bl];

   if(high[index]>max && low[index]>min)
     {
      array_up[index]=low[index]-distance;
      array_up[index+1]=low[index+1]-distance;
      array_dn[index]=EMPTY_VALUE;
     }
   else
     {
      if(high[index]<max && low[index]<min)
        {
         array_dn[index]=high[index]+distance;
         array_dn[index+1]=high[index+1]+distance;
         array_up[index]=EMPTY_VALUE;
        }
      else
        {
         if(high[index]<max && low[index]>min)
           {
            array_up[index]=array_up[index+1];
            array_dn[index]=array_dn[index+1];
           }
         else
           {
            array_up[index]=EMPTY_VALUE;
            array_dn[index]=EMPTY_VALUE;
            array_up[index+1]=EMPTY_VALUE;
            array_dn[index+1]=EMPTY_VALUE;
           }
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
