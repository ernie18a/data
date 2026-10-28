//+------------------------------------------------------------------+
//|                                                    MA_Filter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MA with filter"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   5
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Arr0
#property indicator_label2  "Substrate"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrGreen,clrRed,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ArrUP
#property indicator_label3  "Swing to Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrYellowGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ArrDN
#property indicator_label4  "Swing to Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGold
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot ArrNT
#property indicator_label5  "Swing to Neutral"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrLightGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint                 InpPeriodMA       =  20;            // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpShiftMA        =  1;             // MA anchor shift
input uint                 InpMinDiffMA      =  10;            // MA anchor difference
//--- indicator buffers
double         BufferMA[];
double         BufferColorsMA[];
double         BufferArrSub[];
double         BufferColorsArrSub[];
double         BufferArrUP[];
double         BufferArrDN[];
double         BufferArrNL[];
//--- global variables
double         diff_pt;
int            period;
int            shift;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   shift=int(InpShiftMA<1 ? 1 : InpShiftMA);
   int diff=int(InpMinDiffMA<1 ? 1 : InpMinDiffMA);
   diff_pt=diff*Point();
   int width_sub=indicator_width1+1;
   int width_arr=(width_sub-2<1 ? 1 : width_sub-2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsMA,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferArrSub,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsArrSub,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferArrUP,INDICATOR_DATA);
   SetIndexBuffer(5,BufferArrDN,INDICATOR_DATA);
   SetIndexBuffer(6,BufferArrNL,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159); // BufferArrSub
   PlotIndexSetInteger(2,PLOT_ARROW,159); // BufferArrUP
   PlotIndexSetInteger(3,PLOT_ARROW,159); // BufferArrDN
   PlotIndexSetInteger(4,PLOT_ARROW,159); // BufferArrNL
//--- setting indicator parameters
   string method=StringSubstr(EnumToString(InpMethod),5);
   IndicatorSetString(INDICATOR_SHORTNAME,method+" with filter ("+(string)period+","+(string)shift+","+(string)diff+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,width_sub);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,width_arr);
   PlotIndexSetInteger(3,PLOT_LINE_WIDTH,width_arr);
   PlotIndexSetInteger(4,PLOT_LINE_WIDTH,width_arr);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferColorsMA,true);
   ArraySetAsSeries(BufferArrSub,true);
   ArraySetAsSeries(BufferColorsArrSub,true);
   ArraySetAsSeries(BufferArrUP,true);
   ArraySetAsSeries(BufferArrDN,true);
   ArraySetAsSeries(BufferArrNL,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shift-3;
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferColorsMA,2);
      ArrayInitialize(BufferArrSub,EMPTY_VALUE);
      ArrayInitialize(BufferArrUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrDN,EMPTY_VALUE);
      ArrayInitialize(BufferArrNL,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferMA[i]>BufferMA[i+shift] && fabs(BufferMA[i]-BufferMA[i+shift])>diff_pt)
        {
         BufferColorsMA[i]=0;
         if(BufferColorsMA[i+1]!=0)
           {
            BufferArrUP[i+1]=BufferArrSub[i+1]=BufferMA[i+1];
            BufferColorsArrSub[i+1]=0;
           }
        }
      else
        {
         if(BufferMA[i]<BufferMA[i+shift] && fabs(BufferMA[i]-BufferMA[i+shift])>diff_pt)
           {
            BufferColorsMA[i]=1;
            if(BufferColorsMA[i+1]!=1)
              {
               BufferArrDN[i+1]=BufferArrSub[i+1]=BufferMA[i+1];
               BufferColorsArrSub[i+1]=1;
              }
           }
         else
           {
            BufferColorsMA[i]=2;
            if(BufferColorsMA[i+1]!=2)
              {
               BufferArrNL[i+1]=BufferArrSub[i+1]=BufferMA[i+1];
               BufferColorsArrSub[i+1]=2;
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
