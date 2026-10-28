//+------------------------------------------------------------------+
//|                                        Tymen_STARC_Bands_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframe Tymen STARC Bands indicator"
#property indicator_chart_window
#property indicator_buffers 36
#property indicator_plots   15
//--- plot Highest 1
#property indicator_label1  "Highest"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top 1
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Middle 1
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom 1
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Lowest 1
#property indicator_label5  "Lowest"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

//--- plot Highest 2
#property indicator_label6  "Highest"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Top 2
#property indicator_label7  "Top"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Middle 2
#property indicator_label8  "Middle"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot Bottom 2
#property indicator_label9  "Bottom"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot Lowest 2
#property indicator_label10 "Lowest"
#property indicator_type10  DRAW_LINE
#property indicator_color10 clrBlue
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1

//--- plot Highest 3
#property indicator_label11 "Highest"
#property indicator_type11  DRAW_LINE
#property indicator_color11 clrRed
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
//--- plot Top 3
#property indicator_label12 "Top"
#property indicator_type12  DRAW_LINE
#property indicator_color12 clrRed
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
//--- plot Middle 3
#property indicator_label13 "Middle"
#property indicator_type13  DRAW_LINE
#property indicator_color13 clrRed
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
//--- plot Bottom 3
#property indicator_label14 "Bottom"
#property indicator_type14  DRAW_LINE
#property indicator_color14 clrRed
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
//--- plot Lowest 3
#property indicator_label15 "Lowest"
#property indicator_type15  DRAW_LINE
#property indicator_color15 clrRed
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
//--- enums
enum ENUM_MA_MODE
  {
   METHOD_SMA,          // Simple
   METHOD_EMA,          // Exponential
   METHOD_SMMA,         // Smoothed
   METHOD_LWMA,         // Linear-Weighted
   METHOD_WILDER_EMA,   // Wilder Exponential
   METHOD_SINE_WMA,     // Sine-Weighted
   METHOD_TRI_MA,       // Triangular
   METHOD_LSMA,         // Least Square
   METHOD_HMA,          // Hull MA by Alan Hull
   METHOD_ZL_EMA,       // Zero-Lag Exponential
   METHOD_ITREND_MA,    // Instantaneous Trendline by J.Ehlers
   METHOD_MOVING_MEDIAN,// Moving Median
   METHOD_GEO_MEAN,     // Geometric Mean
   METHOD_REMA,         // Regularized EMA by Chris Satchwell
   METHOD_ILRS,         // Integral of Linear Regression Slope
   METHOD_IE_2,         // Combination of LSMA and ILRS
   METHOD_TRI_MA_GEN,   // Triangular MA generalized by J.Ehlers
   METHOD_VWMA          // Volume-Weighted
  };
//---
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input ENUM_DRAW_MODE       InpDrawMode       =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_INPUT_YES_NO    InpShowMiddle     =  INPUT_YES;        // Show middle lines
input ENUM_INPUT_YES_NO    InpShowBands1     =  INPUT_YES;        // Show first Tymen STARC Bands
input ENUM_TIMEFRAMES      InpTimeframe1     =  PERIOD_H1;        // First bands timeframe
input uint                 InpPeriodATR1     =  15;               // First bands ATR period
input uint                 InpPeriodMA1      =  6;                // First bands MA period
input ENUM_MA_MODE         InpMethod1        =  METHOD_EMA;       // First bands Method
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;      // First bands Applied price
input double               InpKATR1          =  1.0;              // First bands ATR coefficient
input double               InpMKATR1         =  0.7;              // First bands ATR middle coefficient
//---
input ENUM_INPUT_YES_NO    InpShowBands2     =  INPUT_YES;        // Show second Tymen STARC Bands
input ENUM_TIMEFRAMES      InpTimeframe2     =  PERIOD_H4;        // Second bands timeframe
input uint                 InpPeriodATR2     =  15;               // Second bands ATR period
input uint                 InpPeriodMA2      =  6;                // Second bands MA period
input ENUM_MA_MODE         InpMethod2        =  METHOD_EMA;       // Second bands Method
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_CLOSE;      // Second bands Applied price
input double               InpKATR2          =  1.0;              // Second bands ATR coefficient
input double               InpMKATR2         =  0.7;              // Second bands ATR middle coefficient
//---
input ENUM_INPUT_YES_NO    InpShowBands3     =  INPUT_YES;        // Show third Tymen STARC Bands
input ENUM_TIMEFRAMES      InpTimeframe3     =  PERIOD_D1;        // Third bands timeframe
input uint                 InpPeriodATR3     =  15;               // Third bands ATR period
input uint                 InpPeriodMA3      =  6;                // Third bands MA period
input ENUM_MA_MODE         InpMethod3        =  METHOD_EMA;       // Third bands Method
input ENUM_APPLIED_PRICE   InpAppliedPrice3  =  PRICE_CLOSE;      // Third bands Applied price
input double               InpKATR3          =  1.0;              // Third bands ATR coefficient
input double               InpMKATR3         =  0.7;              // Third bands ATR middle coefficient
//--- structures
struct SDataBand
  {
   double               BufferTopExtr[];
   double               BufferTop[];
   double               BufferMiddle[];
   double               BufferBottom[];
   double               BufferBottomExtr[];
   double               BufferATR[];
   double               BufferPrice[];
   double               BufferTopExtrTMP[];
   double               BufferTopTMP[];
   double               BufferMiddleTMP[];
   double               BufferBottomTMP[];
   double               BufferBottomExtrTMP[];
   ENUM_TIMEFRAMES      timeframe;
   ENUM_APPLIED_PRICE   applied_price;
   ENUM_MA_MODE         method;
   double               katr;
   double               mkatr;
   string               label;
   bool                 show;
   int                  period_ma;
   int                  period_atr;
   int                  handle_ma;
   int                  handle_atr;
  };
//--- global variables
SDataBand         DataBuff[3];
int               period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   DataBuff[0].period_ma=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   DataBuff[0].period_atr=int(InpPeriodATR1<1 ? 1 : InpPeriodATR1);
   DataBuff[0].timeframe=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   DataBuff[0].applied_price=InpAppliedPrice1;
   DataBuff[0].katr=InpKATR1;
   DataBuff[0].mkatr=InpMKATR1;
   DataBuff[0].label=TimeframeToString(InpTimeframe1)+" ";
   DataBuff[0].show=InpShowBands1;
   DataBuff[0].method=InpMethod1;
//---
   DataBuff[1].period_ma=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   DataBuff[1].period_atr=int(InpPeriodATR2<1 ? 1 : InpPeriodATR2);
   DataBuff[1].timeframe=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   DataBuff[1].applied_price=InpAppliedPrice2;
   DataBuff[1].katr=InpKATR2;
   DataBuff[1].mkatr=InpMKATR2;
   DataBuff[1].label=TimeframeToString(InpTimeframe2)+" ";
   DataBuff[1].show=InpShowBands2;
   DataBuff[1].method=InpMethod2;
//---
   DataBuff[2].period_ma=int(InpPeriodMA3<2 ? 2 : InpPeriodMA3);
   DataBuff[2].period_atr=int(InpPeriodATR3<1 ? 1 : InpPeriodATR3);
   DataBuff[2].timeframe=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   DataBuff[2].applied_price=InpAppliedPrice3;
   DataBuff[2].katr=InpKATR3;
   DataBuff[2].mkatr=InpMKATR3;
   DataBuff[2].label=TimeframeToString(InpTimeframe3)+" ";
   DataBuff[2].show=InpShowBands3;
   DataBuff[2].method=InpMethod3;
//---
   period_max=fmax(DataBuff[0].period_ma,fmax(DataBuff[1].period_ma,DataBuff[2].period_ma));
//--- indicator buffers mapping, plot buffer parameters, handles
   int n=-1;
   for(int i=0;i<3;i++)
     {
      n++;
      SetIndexBuffer(n*5,DataBuff[i].BufferTopExtr);
      PlotIndexSetString(n*5,PLOT_LABEL,DataBuff[i].label+"Top Extr");
      PlotIndexSetInteger(n*5,PLOT_DRAW_TYPE,DataBuff[i].show);
      
      SetIndexBuffer(n*5+1,DataBuff[i].BufferTop);
      PlotIndexSetString(n*5+1,PLOT_LABEL,DataBuff[i].label+"Top");
      PlotIndexSetInteger(n*5+1,PLOT_DRAW_TYPE,DataBuff[i].show);
      
      SetIndexBuffer(n*5+2,DataBuff[i].BufferMiddle);
      PlotIndexSetString(n*5+2,PLOT_LABEL,DataBuff[i].label+"Middle");
      PlotIndexSetInteger(n*5+2,PLOT_DRAW_TYPE,(DataBuff[i].show ? InpShowMiddle : 0));
      
      SetIndexBuffer(n*5+3,DataBuff[i].BufferBottom);
      PlotIndexSetString(n*5+3,PLOT_LABEL,DataBuff[i].label+"Bottom");
      PlotIndexSetInteger(n*5+3,PLOT_DRAW_TYPE,DataBuff[i].show);
      
      SetIndexBuffer(n*5+4,DataBuff[i].BufferBottomExtr);
      PlotIndexSetString(n*5+4,PLOT_LABEL,DataBuff[i].label+"Bottom Extr");
      PlotIndexSetInteger(n*5+4,PLOT_DRAW_TYPE,DataBuff[i].show);
      
      SetIndexBuffer(n*7+15,DataBuff[i].BufferPrice);
      SetIndexBuffer(n*7+16,DataBuff[i].BufferATR);
      SetIndexBuffer(n*7+17,DataBuff[i].BufferTopExtrTMP);
      SetIndexBuffer(n*7+18,DataBuff[i].BufferTopTMP);
      SetIndexBuffer(n*7+19,DataBuff[i].BufferMiddleTMP);
      SetIndexBuffer(n*7+20,DataBuff[i].BufferBottomTMP);
      SetIndexBuffer(n*7+21,DataBuff[i].BufferBottomExtrTMP);
      //---
      ArraySetAsSeries(DataBuff[i].BufferTopExtr,true);
      ArraySetAsSeries(DataBuff[i].BufferTop,true);
      ArraySetAsSeries(DataBuff[i].BufferMiddle,true);
      ArraySetAsSeries(DataBuff[i].BufferBottom,true);
      ArraySetAsSeries(DataBuff[i].BufferBottomExtr,true);
      //---
      ArraySetAsSeries(DataBuff[i].BufferPrice,true);
      ArraySetAsSeries(DataBuff[i].BufferATR,true);
      ArraySetAsSeries(DataBuff[i].BufferTopExtrTMP,true);
      ArraySetAsSeries(DataBuff[i].BufferTopTMP,true);
      ArraySetAsSeries(DataBuff[i].BufferMiddleTMP,true);
      ArraySetAsSeries(DataBuff[i].BufferBottomTMP,true);
      ArraySetAsSeries(DataBuff[i].BufferBottomExtrTMP,true);
      
      ResetLastError();
      DataBuff[i].handle_ma=iMA(NULL,DataBuff[i].timeframe,1,0,MODE_SMA,DataBuff[i].applied_price);
      if(DataBuff[i].handle_ma==INVALID_HANDLE)
        {
         Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      DataBuff[i].handle_atr=iATR(NULL,DataBuff[i].timeframe,DataBuff[i].period_atr);
      if(DataBuff[i].handle_atr==INVALID_HANDLE)
        {
         Print(__LINE__,": The iATR(",(string)DataBuff[i].period_atr,") object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
     }
   
//--- setting indicator parameters
   string label=TimeframeToString(InpTimeframe1)+","+TimeframeToString(InpTimeframe2)+","+TimeframeToString(InpTimeframe3)+" Tymen STARC Bands";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- get time
   for(int i=0;i<3;i++)
      Time(NULL,DataBuff[i].timeframe,1);
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
   ArraySetAsSeries(tick_volume,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      for(int i=0;i<3;i++)
        {
         ArrayInitialize(DataBuff[i].BufferTopExtr,EMPTY_VALUE);
         ArrayInitialize(DataBuff[i].BufferTop,EMPTY_VALUE);
         ArrayInitialize(DataBuff[i].BufferMiddle,0);
         ArrayInitialize(DataBuff[i].BufferBottom,EMPTY_VALUE);
         ArrayInitialize(DataBuff[i].BufferBottomExtr,EMPTY_VALUE);
         
         ArrayInitialize(DataBuff[i].BufferPrice,0);
         ArrayInitialize(DataBuff[i].BufferATR,0);
         ArrayInitialize(DataBuff[i].BufferTopExtrTMP,0);
         ArrayInitialize(DataBuff[i].BufferTopTMP,0);
         ArrayInitialize(DataBuff[i].BufferMiddleTMP,0);
         ArrayInitialize(DataBuff[i].BufferBottomTMP,0);
         ArrayInitialize(DataBuff[i].BufferBottomExtrTMP,0);
        }
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   for(int i=0;i<3;i++)
     {
      if(Time(NULL,DataBuff[i].timeframe,1)==0)
         return 0;
      copied=CopyBuffer(DataBuff[i].handle_atr,0,0,count,DataBuff[i].BufferATR);
      if(copied<1) return 0;
      copied=CopyBuffer(DataBuff[i].handle_ma,0,0,count,DataBuff[i].BufferPrice);
      if(copied<1) return 0;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      for(int j=0;j<3;j++)
        {
         GetMA(rates_total,DataBuff[j].method,DataBuff[j].period_ma,i,DataBuff[j].BufferPrice,DataBuff[j].BufferMiddleTMP,tick_volume);
         DataBuff[j].BufferTopExtrTMP[i]=DataBuff[j].BufferMiddleTMP[i]+DataBuff[j].BufferATR[i]*DataBuff[j].katr;
         DataBuff[j].BufferTopTMP[i]=DataBuff[j].BufferMiddleTMP[i]+DataBuff[j].BufferATR[i]*DataBuff[j].mkatr;
         DataBuff[j].BufferBottomTMP[i]=DataBuff[j].BufferMiddleTMP[i]-DataBuff[j].BufferATR[i]*DataBuff[j].mkatr;
         DataBuff[j].BufferBottomExtrTMP[i]=DataBuff[j].BufferMiddleTMP[i]-DataBuff[j].BufferATR[i]*DataBuff[j].katr;
        }
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      for(int j=0;j<3;j++)
        {
         DataConversion(rates_total,NULL,DataBuff[j].timeframe,i,DataBuff[j].BufferMiddleTMP,DataBuff[j].BufferMiddle,InpDrawMode);
         DataConversion(rates_total,NULL,DataBuff[j].timeframe,i,DataBuff[j].BufferTopExtrTMP,DataBuff[j].BufferTopExtr,InpDrawMode);
         DataConversion(rates_total,NULL,DataBuff[j].timeframe,i,DataBuff[j].BufferTopTMP,DataBuff[j].BufferTop,InpDrawMode);
         DataConversion(rates_total,NULL,DataBuff[j].timeframe,i,DataBuff[j].BufferBottomTMP,DataBuff[j].BufferBottom,InpDrawMode);
         DataConversion(rates_total,NULL,DataBuff[j].timeframe,i,DataBuff[j].BufferBottomExtrTMP,DataBuff[j].BufferBottomExtr,InpDrawMode);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   for(int i=0;i<3;i++)
      Time(NULL,DataBuff[i].timeframe,1);
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
//| GetMA                                                            |
//+------------------------------------------------------------------+
void GetMA(const int rates_total,const ENUM_MA_MODE method,const int period,const int shift,const double &price[],double &ma[],const long &tick_volume[])
  {
   switch(method)
     {
      case METHOD_EMA            : ma[shift] = EMA(rates_total,price[shift],ma[shift+1],period,shift);      break;
      case METHOD_SMMA           : ma[shift] = SMMA(rates_total,price,ma[shift+1],period,shift);            break;
      case METHOD_LWMA           : ma[shift] = LWMA(rates_total,price,period,shift);                        break;
      case METHOD_WILDER_EMA     : ma[shift] = Wilder(rates_total,price[shift],ma[shift+1],period,shift);   break;
      case METHOD_SINE_WMA       : ma[shift] = SineWMA(rates_total,price,period,shift);                     break;
      case METHOD_TRI_MA         : ma[shift] = TriMA(rates_total,price,period,shift);                       break;
      case METHOD_LSMA           : ma[shift] = LSMA(rates_total,price,period,shift);                        break;
      case METHOD_HMA            : ma[shift] = HMA(rates_total,price,period,shift);                         break;
      case METHOD_ZL_EMA         : ma[shift] = ZeroLagEMA(rates_total,price,ma[shift+1],period,shift);      break;
      case METHOD_ITREND_MA      : ma[shift] = ITrend(rates_total,price,ma,period,shift);                   break;
      case METHOD_MOVING_MEDIAN  : ma[shift] = Median(rates_total,price,period,shift);                      break;
      case METHOD_GEO_MEAN       : ma[shift] = GeoMean(rates_total,price,period,shift);                     break;
      case METHOD_REMA           : ma[shift] = REMA(rates_total,price[shift],ma,period,0.5,shift);          break;
      case METHOD_ILRS           : ma[shift] = ILRS(rates_total,price,period,shift);                        break;
      case METHOD_IE_2           : ma[shift] = IE2(rates_total,price,period,shift);                         break;
      case METHOD_TRI_MA_GEN     : ma[shift] = TriMAgen(rates_total,price,period,shift);                    break;
      case METHOD_VWMA           : ma[shift] = VWMA(rates_total,price,tick_volume,period,shift);            break;
      default /*METHOD_SMA*/     : ma[shift] = SMA(rates_total,price,period,shift);                         break;
     }
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
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double EMA(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+2.0/(1+period)*(price-prev));
  }
//+------------------------------------------------------------------+
//| Wilder Exponential Moving Average                                |
//+------------------------------------------------------------------+
double Wilder(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+(price-prev)/period);
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
double LWMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=(period-i);
      sum+=array_src[shift+i]*(period-i);
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| Sine Weighted Moving Average                                     |
//+------------------------------------------------------------------+
double SineWMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=sin(M_PI*(i+1)/(period+1));
      sum+=array_src[shift+i]*sin(M_PI*(i+1)/(period+1));
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| Triangular Moving Average                                        |
//+------------------------------------------------------------------+
double TriMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sma;
   int len=(int)ceil((period+1)*0.5);
   double sum=0;
   for(int i=0; i<len; i++)
     {
      sma=SMA(rates_total,array_src,len,shift+i);
      sum+=sma;
     }
   return sum/len;
  }
//+------------------------------------------------------------------+
//| Least Square Moving Average                                      |
//+------------------------------------------------------------------+
double LSMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   for(int i=period; i>=1; i--)
      sum+=(i-(period+1)/3.0)*array_src[shift+period-i];
   return sum*6.0/(period*(period+1));
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
double SMMA(const int rates_total,const double &array_src[],const double prev,const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double smma=0;
   if(shift==rates_total-period-1)
      smma=SMA(rates_total,array_src,period,shift);
   else if(shift<rates_total-period-1)
     {
      double sum=0;
      for(int i = 0; i<period; i++)
         sum+=array_src[shift+i+1];
      smma=(sum-prev+array_src[shift])/period;
     }
   return smma;
  }
//+------------------------------------------------------------------+
//| Hull Moving Average by Alan Hull                                 |
//+------------------------------------------------------------------+
double HMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double tmp1[];
   double hma=0;
   int len=(int)sqrt(period);
   ArrayResize(tmp1,len);
   if(shift==rates_total-period-1)
      hma=array_src[shift];
   else if(shift<rates_total-period-1)
     {
      for(int i=0; i<len; i++)
         tmp1[i]=2.0*LWMA(rates_total,array_src,period/2,shift+i)-LWMA(rates_total,array_src,period,shift+i);
      hma=LWMA(rates_total,tmp1,len,0);
     }
   return hma;
  }
//+------------------------------------------------------------------+
//| Zero-Lag Exponential Moving Average                              |
//+------------------------------------------------------------------+
double ZeroLagEMA(const int rates_total,const double &array_src[],const double prev,const int period,const int shift)
  {
   double alfa=2.0/(1+period);
   int lag=int(0.5*(period-1));
   return(shift>=rates_total-lag ? array_src[shift] : alfa*(2.0*array_src[shift]-array_src[shift+lag])+(1-alfa)*prev);
  }
//+------------------------------------------------------------------+
//| Instantaneous Trendline by J.Ehlers                              |
//+------------------------------------------------------------------+
double ITrend(const int rates_total,const double &array_src[],const double &array[],const int period,const int shift)
  {
   double alfa=2.0/(period+1);
   return
     (
      shift<rates_total-7 ?
      (alfa-0.25*alfa*alfa)*array_src[shift]+0.5*alfa*alfa*array_src[shift+1]-(alfa-0.75*alfa*alfa)*array_src[shift+2]+2*(1-alfa)*array[shift+1]-(1-alfa)*(1-alfa)*array[shift+2]:
      (array_src[shift]+2*array_src[shift+1]+array_src[shift+2])/4.0
     );
  }
//+------------------------------------------------------------------+
//| Moving Median                                                    |
//+------------------------------------------------------------------+
double Median(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double array[];
   ArrayResize(array,period);
   for(int i=0; i<period; i++)
      array[i]=array_src[shift+i];
   ArraySort(array);
   int num=(int)round((period-1)/2);
   return(fmod(period,2)>0 ? array_src[num] : 0.5*(array_src[num]+array[num+1]));
  }
//+------------------------------------------------------------------+
//| Geometric Mean                                                   |
//+------------------------------------------------------------------+
double GeoMean(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   double gmean=0;
   if(shift<rates_total-period)
     {
      gmean=pow(array_src[shift],1.0/period);
      for(int i=1; i<period; i++)
         gmean*=pow(array_src[shift+i],1.0/period);
     }
   return(gmean);
  }
//+------------------------------------------------------------------+
//| Regularized EMA by Chris Satchwell                               |
//+------------------------------------------------------------------+
double REMA(const int rates_total,const double price,const double &array[],const int period,const double lambda,const int shift)
  {
   double alpha=2.0/(period+1);
   return(shift>=rates_total-3 ? price : (array[shift+1]*(1+2*lambda)+alpha*(price-array[shift+1])-lambda*array[shift+2])/(1+lambda));
  }
//+------------------------------------------------------------------+
//| Integral of Linear Regression Slope                              |
//+------------------------------------------------------------------+
double ILRS(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=period*(period-1)*0.5;
   double sum2=(period-1)*period*(2*period-1)/6.0;
   double sum1=0;
   double sumy=0;
   for(int i=0; i<period; i++)
     {
      sum1+=i*array_src[shift+i];
      sumy+=array_src[shift+i];
     }
   double num1=period*sum1-sum*sumy;
   double num2=sum*sum-period*sum2;
   double slope=(num2!=0 ? num1/num2 : 0);
   return(slope+SMA(rates_total,array_src,period,shift));
  }
//+------------------------------------------------------------------+
//| Combination of LSMA and ILRS                                     |
//+------------------------------------------------------------------+
double IE2(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   return(0.5*(ILRS(rates_total,array_src,period,shift)+LSMA(rates_total,array_src,period,shift)));
  }
//+------------------------------------------------------------------+
//| Triangular Moving Average generalized by J.Ehlers                |
//+------------------------------------------------------------------+
double TriMAgen(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   int len1=(int)floor((period+1)*0.5);
   int len2=(int)ceil((period+1)*0.5);
   double sum=0;
   for(int i=0; i<len2; i++)
      sum+=SMA(rates_total,array_src,len1,shift+i);
   return(sum/len2);
  }
//+------------------------------------------------------------------+
//| Volume-Weighted Moving Average                                   |
//+------------------------------------------------------------------+
template<typename T>
double VWMA(const int rates_total,const double &array_src[],const T &volume[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=(double)volume[shift+i];
      sum+=array_src[shift+i]*volume[shift+i];
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
