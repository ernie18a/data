//+------------------------------------------------------------------+
//|                                            Dynamic_Trend_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframe Dynamic Trend indicator"
#property indicator_chart_window
#property indicator_buffers 24
#property indicator_plots   9
//--- plot Line 1
#property indicator_label1  "DT 1"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrBlue,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UP 1
#property indicator_label2  "Up 1"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DN 1
#property indicator_label3  "Down 1"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- plot Line 2
#property indicator_label4  "DT 2"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDeepSkyBlue,clrOrange,clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot UP 2
#property indicator_label5  "Up 2"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrDeepSkyBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot DN 2
#property indicator_label6  "Down 2"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrOrange
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- plot Line 3
#property indicator_label7  "DT 3"
#property indicator_type7   DRAW_COLOR_LINE
#property indicator_color7  clrOliveDrab,clrGold,clrDarkGray
#property indicator_style7  STYLE_SOLID
#property indicator_width7  3
//--- plot UP 3
#property indicator_label8  "Up 3"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrOliveDrab
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot DN 3
#property indicator_label9  "Down 3"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrGold
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriod      =  14;               // Period
input uint              InpPercent     =  10;               // Percent
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First DT timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second DT timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third DT timeframe
//--- indicator buffers
double         BufferLine1[];
double         BufferColors1[];
double         BufferUP1[];
double         BufferDN1[];
double         BufferLine2[];
double         BufferColors2[];
double         BufferUP2[];
double         BufferDN2[];
double         BufferLine3[];
double         BufferColors3[];
double         BufferUP3[];
double         BufferDN3[];
double         BufferLine1tmp[];
double         BufferLine2tmp[];
double         BufferLine3tmp[];
double         BufferColors1tmp[];
double         BufferColors2tmp[];
double         BufferColors3tmp[];
double         BufferUP1tmp[];
double         BufferDN1tmp[];
double         BufferUP2tmp[];
double         BufferDN2tmp[];
double         BufferUP3tmp[];
double         BufferDN3tmp[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
int               percent;
int               period_dt;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   percent=(int)InpPercent;
   period_dt=int(InpPeriod<1 ? 1 : InpPeriod);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLine1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors1,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferUP1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDN1,INDICATOR_DATA);
   SetIndexBuffer(4,BufferLine2,INDICATOR_DATA);
   SetIndexBuffer(5,BufferColors2,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,BufferUP2,INDICATOR_DATA);
   SetIndexBuffer(7,BufferDN2,INDICATOR_DATA);
   SetIndexBuffer(8,BufferLine3,INDICATOR_DATA);
   SetIndexBuffer(9,BufferColors3,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,BufferUP3,INDICATOR_DATA);
   SetIndexBuffer(11,BufferDN3,INDICATOR_DATA);
   SetIndexBuffer(12,BufferLine1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferLine2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferLine3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferUP1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferDN1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,BufferUP2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,BufferDN2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,BufferUP3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,BufferDN3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(21,BufferColors1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,BufferColors2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,BufferColors3tmp,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   if(timeframe1==Period())
     {
      PlotIndexSetInteger(1,PLOT_ARROW,233);
      PlotIndexSetInteger(2,PLOT_ARROW,234);
     }
   else
     {
      PlotIndexSetInteger(1,PLOT_ARROW,159);
      PlotIndexSetInteger(2,PLOT_ARROW,159);
     }
   if(timeframe2==Period())
     {
      PlotIndexSetInteger(4,PLOT_ARROW,233);
      PlotIndexSetInteger(5,PLOT_ARROW,234);
     }
   else
     {
      PlotIndexSetInteger(4,PLOT_ARROW,159);
      PlotIndexSetInteger(5,PLOT_ARROW,159);
     }
   if(timeframe3==Period())
     {
      PlotIndexSetInteger(7,PLOT_ARROW,233);
      PlotIndexSetInteger(8,PLOT_ARROW,234);
     }
   else
     {
      PlotIndexSetInteger(7,PLOT_ARROW,159);
      PlotIndexSetInteger(8,PLOT_ARROW,159);
     }
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Dynamic Trend ("+(string)period_dt+","+(string)percent+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" DT("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe1)+" Up("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe1)+" Down("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(3,PLOT_LABEL,TimeframeToString(timeframe2)+" DT("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(4,PLOT_LABEL,TimeframeToString(timeframe2)+" Up("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(5,PLOT_LABEL,TimeframeToString(timeframe2)+" Down("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(6,PLOT_LABEL,TimeframeToString(timeframe3)+" DT("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(7,PLOT_LABEL,TimeframeToString(timeframe3)+" Up("+(string)period_dt+","+(string)percent+")");
   PlotIndexSetString(8,PLOT_LABEL,TimeframeToString(timeframe3)+" Down("+(string)period_dt+","+(string)percent+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLine1,true);
   ArraySetAsSeries(BufferColors1,true);
   ArraySetAsSeries(BufferUP1,true);
   ArraySetAsSeries(BufferDN1,true);
   ArraySetAsSeries(BufferLine2,true);
   ArraySetAsSeries(BufferColors2,true);
   ArraySetAsSeries(BufferUP2,true);
   ArraySetAsSeries(BufferDN2,true);
   ArraySetAsSeries(BufferLine3,true);
   ArraySetAsSeries(BufferColors3,true);
   ArraySetAsSeries(BufferUP3,true);
   ArraySetAsSeries(BufferDN3,true);
   ArraySetAsSeries(BufferLine1tmp,true);
   ArraySetAsSeries(BufferLine2tmp,true);
   ArraySetAsSeries(BufferLine3tmp,true);
   ArraySetAsSeries(BufferUP1tmp,true);
   ArraySetAsSeries(BufferDN1tmp,true);
   ArraySetAsSeries(BufferUP2tmp,true);
   ArraySetAsSeries(BufferDN2tmp,true);
   ArraySetAsSeries(BufferUP3tmp,true);
   ArraySetAsSeries(BufferDN3tmp,true);
   ArraySetAsSeries(BufferColors1tmp,true);
   ArraySetAsSeries(BufferColors2tmp,true);
   ArraySetAsSeries(BufferColors3tmp,true);
//--- get timeframe
   Time(NULL,timeframe1,1);
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
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
   if(rates_total<fmax(period_dt,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-4;
      ArrayInitialize(BufferLine1,0);
      ArrayInitialize(BufferLine2,0);
      ArrayInitialize(BufferLine3,0);
      ArrayInitialize(BufferColors1,2);
      ArrayInitialize(BufferColors2,2);
      ArrayInitialize(BufferColors3,2);
      ArrayInitialize(BufferUP1,EMPTY_VALUE);
      ArrayInitialize(BufferDN1,EMPTY_VALUE);
      ArrayInitialize(BufferUP2,EMPTY_VALUE);
      ArrayInitialize(BufferDN2,EMPTY_VALUE);
      ArrayInitialize(BufferUP3,EMPTY_VALUE);
      ArrayInitialize(BufferDN3,EMPTY_VALUE);
      ArrayInitialize(BufferLine1tmp,0);
      ArrayInitialize(BufferLine2tmp,0);
      ArrayInitialize(BufferLine3tmp,0);
      ArrayInitialize(BufferUP1tmp,EMPTY_VALUE);
      ArrayInitialize(BufferDN1tmp,EMPTY_VALUE);
      ArrayInitialize(BufferUP2tmp,EMPTY_VALUE);
      ArrayInitialize(BufferDN2tmp,EMPTY_VALUE);
      ArrayInitialize(BufferUP3tmp,EMPTY_VALUE);
      ArrayInitialize(BufferDN3tmp,EMPTY_VALUE);
      ArrayInitialize(BufferColors1tmp,2);
      ArrayInitialize(BufferColors2tmp,2);
      ArrayInitialize(BufferColors3tmp,2);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DT(NULL,timeframe1,period_dt,i,BufferLine1tmp,BufferUP1tmp,BufferDN1tmp,BufferColors1tmp);
      DT(NULL,timeframe2,period_dt,i,BufferLine2tmp,BufferUP2tmp,BufferDN2tmp,BufferColors2tmp);
      DT(NULL,timeframe3,period_dt,i,BufferLine3tmp,BufferUP3tmp,BufferDN3tmp,BufferColors3tmp);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferColors1[i]=BufferColors2[i]=BufferColors3[i]=2;
      //---
      DataConversion(rates_total,NULL,timeframe1,i,BufferLine1tmp,BufferLine1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferColors1tmp,BufferColors1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferUP1tmp,BufferUP1,DRAW_MODE_STEPS);
      DataConversion(rates_total,NULL,timeframe1,i,BufferDN1tmp,BufferDN1,DRAW_MODE_STEPS);
      //---
      DataConversion(rates_total,NULL,timeframe2,i,BufferLine2tmp,BufferLine2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferColors2tmp,BufferColors2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferUP2tmp,BufferUP2,DRAW_MODE_STEPS);
      DataConversion(rates_total,NULL,timeframe2,i,BufferDN2tmp,BufferDN2,DRAW_MODE_STEPS);
      //---
      DataConversion(rates_total,NULL,timeframe3,i,BufferLine3tmp,BufferLine3,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferColors3tmp,BufferColors3,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferUP3tmp,BufferUP3,DRAW_MODE_STEPS);
      DataConversion(rates_total,NULL,timeframe3,i,BufferDN3tmp,BufferDN3,DRAW_MODE_STEPS);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(NULL,timeframe1,1);
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
  }  
//+------------------------------------------------------------------+
//| Transfering data from the source timeframe to current timeframe  |
//+------------------------------------------------------------------+
void DataConversion(const int rates_total,
                    const string symbol_name,
                    const ENUM_TIMEFRAMES timeframe_src,
                    const int shift,
                    const double &buffer_src[],
                    double &buffer_dest[],
                    ENUM_DRAW_MODE mode=DRAW_MODE_STEPS
                   )
  {
   double close=Close(symbol_name,timeframe_src,shift);
   if(close==0)
      return;
   if(timeframe_src==Period())
     {
      buffer_dest[shift]=buffer_src[shift];
      return;
     }
   int bar_curr=BarToCurrent(symbol_name,timeframe_src,shift);
   if(bar_curr>rates_total-1)
      return;
   int bar_prev=BarToCurrent(symbol_name,timeframe_src,shift+1);
   int bar_next=(shift>0 ? BarToCurrent(symbol_name,timeframe_src,shift-1) : 0);
   if(bar_prev==WRONG_VALUE || bar_curr==WRONG_VALUE || bar_next==WRONG_VALUE)
      return;
   buffer_dest[bar_curr]=buffer_src[shift];
   if(mode==DRAW_MODE_STEPS)
      for(int j=bar_curr; j>=bar_next; j--)
         buffer_dest[j]=buffer_dest[bar_curr];
   else
     {
      if(bar_prev>rates_total-1) return;
      for(int j=bar_prev; j>=bar_curr; j--)
         buffer_dest[j]=EquationDirect(bar_prev,buffer_dest[bar_prev],bar_curr,buffer_dest[bar_curr],j);
      if(shift==0)
         for(int j=bar_curr; j>=0; j--)
            buffer_dest[j]=buffer_dest[bar_curr];
     }
  }
//+------------------------------------------------------------------+
//| Возвращает бар заданного таймфрейма как бар текущего таймфрейма  |
//+------------------------------------------------------------------+
int BarToCurrent(const string symbol_name,const ENUM_TIMEFRAMES timeframe_src,const int shift,bool exact=false)
  {
   datetime time=Time(symbol_name,timeframe_src,shift);
   return(time!=0 ? BarShift(symbol_name,Period(),time,exact) : WRONG_VALUE);
  }  
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает Open                                                  |
//+------------------------------------------------------------------+
double Open(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyOpen(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает High                                                  |
//+------------------------------------------------------------------+
double High(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Low                                                   |
//+------------------------------------------------------------------+
double Low(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search) 
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Close         |
//+------------------------------------------------------------------+
int HighestClose(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Close          |
//+------------------------------------------------------------------+
int LowestClose(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Расчёт Elder's Safe Zone                                         |
//+------------------------------------------------------------------+
void DT(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,double &buffer_line[],double &buffer_up[],double &buffer_dn[],double &buffer_color[])
  {
   int bh=HighestClose(symbol_name,timeframe,period,shift+1);
   int bl=LowestClose(symbol_name,timeframe,period,shift+1);
   double open0=Open(symbol_name,timeframe,shift);
   double close0=Close(symbol_name,timeframe,shift);
   double close1=Close(symbol_name,timeframe,shift+1);
   double close2=Close(symbol_name,timeframe,shift+2);
   double close3=Close(symbol_name,timeframe,shift+3);
   if(bl==WRONG_VALUE || bh==WRONG_VALUE || open0==0 || close0==0 || close1==0 || close2==0 || close3==0)
      return;
   double closeBH=Close(symbol_name,timeframe,bh);
   double closeBL=Close(symbol_name,timeframe,bl);
   if(closeBH==0 || closeBL==0)
      return;
   
   //buffer_line[shift]=(close0<buffer_line[shift+1] ? closeBH-percent*Point() : closeBL+percent*Point());
   
   buffer_color[shift]=2;
   if(close0<buffer_line[shift+1])
     {
      buffer_line[shift]=closeBH-percent*Point();
      buffer_color[shift]=1;
     }
   else
     {
      buffer_line[shift]=closeBL+percent*Point();
      buffer_color[shift]=0;
     }
   
   
   buffer_up[shift]=buffer_dn[shift]=EMPTY_VALUE;

   if(close1>buffer_line[shift+1] && close2<=buffer_line[shift+2])
      buffer_up[shift]=open0;

   if(close1<buffer_line[shift+1] && close2>=buffer_line[shift+2])
      buffer_dn[shift]=open0;
  }
//+------------------------------------------------------------------+
