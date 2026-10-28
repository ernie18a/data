//+------------------------------------------------------------------+
//|                                                  Trend_Angle.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Angle indicator"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot TA
#property indicator_label1  "TA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input color                InpLineColor      =  clrDodgerBlue; // Line color
input uint                 InpLineWidth      =  1;             // Line width
input ENUM_LINE_STYLE      InpLineStyle      =  STYLE_DOT;     // Line style
input uchar                InpFontSize       =  10;            // Font size
//--- indicator buffers
double         BufferTA[];
//--- global variables
string         prefix;
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTA,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Angle ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<=period_ma*2) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferTA,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferTA);
   if(copied!=count) return 0;
//--- Вывод линии и метки значения угла
   string nm=prefix+"line";
   double p1,p0;
   datetime t1,t0;
   p1=BufferTA[1];
   p0=BufferTA[0];
   t1=time[1];
   t0=time[0];
   if(ObjectFind(0,nm)<0)
     {
      ObjectCreate(0,nm,OBJ_TREND,0,t1,p1,t0,p0);
      ObjectSetInteger(0,nm,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,nm,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,nm,OBJPROP_WIDTH,InpLineWidth);
      ObjectSetInteger(0,nm,OBJPROP_STYLE,InpLineStyle);
      ObjectSetInteger(0,nm,OBJPROP_COLOR,InpLineColor);
     }
   else
     {
      if(ObjectGetInteger(0,nm,OBJPROP_TIME,0)!=t1)
         ObjectSetInteger(0,nm,OBJPROP_TIME,0,t1);
      if(ObjectGetInteger(0,nm,OBJPROP_TIME,1)!=t0)
         ObjectSetInteger(0,nm,OBJPROP_TIME,1,t0);
      if(ObjectGetDouble(0,nm,OBJPROP_PRICE,0)!=p1)
         ObjectSetDouble(0,nm,OBJPROP_PRICE,0,p1);
      if(ObjectGetDouble(0,nm,OBJPROP_PRICE,1)!=p0)
         ObjectSetDouble(0,nm,OBJPROP_PRICE,1,p0);
     }

   double angle;
   string angle_str;
   int x1,x2,y1,y2;
   ChartTimePriceToXY(0,0,time[10],10.0*p1-9.0*p0,x1,y1);
   ChartTimePriceToXY(0,0,t0,p0,x2,y2);
   double diff=double(y2-y1);
   angle=90-atan((x1-x2)/(diff!=0 ? diff : DBL_MIN))*180.0/M_PI;
   angle_str=DoubleToString(angle,2);

   nm=prefix+"label";
   if(ObjectFind(0,nm)<0)
     {
      ObjectCreate(0,nm,OBJ_TEXT,0,t0,p0);
      ObjectSetInteger(0,nm,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
      ObjectSetString(0,nm,OBJPROP_FONT,"Calibri");
      ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetInteger(0,nm,OBJPROP_COLOR,InpLineColor);
     }
   else
     {
      if(ObjectGetInteger(0,nm,OBJPROP_TIME,0)!=t0)
         ObjectSetInteger(0,nm,OBJPROP_TIME,0,t0);
      if(ObjectGetDouble(0,nm,OBJPROP_PRICE,0)!=p0)
         ObjectSetDouble(0,nm,OBJPROP_PRICE,0,p0);
     }
   ObjectSetString(0,nm,OBJPROP_TEXT,angle_str);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
