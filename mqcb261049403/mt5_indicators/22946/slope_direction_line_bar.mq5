//+------------------------------------------------------------------+
//|                                     Slope_Direction_Line_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slope Direction Line / Moving Average confirmation bars indicator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NL
#property indicator_label3  "Neutral"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGainsboro
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- defines
#define   COUNT            (3)
//--- input parameters
input uint                 InpPeriodMA          =  50;            // MA period
input ENUM_MA_METHOD       InpMethodMA          =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPriceMA    =  PRICE_CLOSE;   // MA applied price
input uint                 InpPeriodSlope       =  50;            // Slope period
input ENUM_MA_METHOD       InpMethodSlope       =  MODE_SMA;      // Slope method
input ENUM_APPLIED_PRICE   InpAppliedPriceSlope =  PRICE_CLOSE;   // Slope applied price
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferSlope[];
double         BufferMA[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferVect[];
//--- global variables
string         prefix;
int            wnd;
int            UpFr;
int            DnFr;
//--- slope/MA
int            period_slope;
int            period_slope2;
int            period_sqrt;
int            period_ma;
int            period_max;
int            weight_sum;
int            handle_ma;
int            handle_ma1;
int            handle_ma2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   SizeByScale();
   Descriptions();
//--- slope/MA
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_slope=int(InpPeriodSlope<2 ? 2 : InpPeriodSlope);
   period_slope2=int(floor(period_slope/2));
   period_sqrt=int(floor(sqrt(period_slope)));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSlope,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferVect,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Slope/MA bars ("+(string)period_slope+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferSlope,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferVect,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethodMA,InpAppliedPriceMA);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_slope,0,InpMethodSlope,InpAppliedPriceSlope);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slope,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_slope2,0,InpMethodSlope,InpAppliedPriceSlope);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slope2,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_slope,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      ArrayInitialize(BufferSlope,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferVect,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVect[i]=2.0*BufferMA2[i]-BufferMA1[i];
     
//--- Расчёт индикатора
   switch(InpMethodSlope)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope,weight_sum)==0) return 0;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDN[i]=BufferUP[i]=EMPTY_VALUE;
      BufferNL[i]=0.5;
      if(BufferSlope[i]>BufferSlope[i+1])
        {
         if(BufferMA[i]>BufferMA[i+1])
           {
            BufferUP[i]=0.5;
            BufferDN[i]=BufferNL[i]=EMPTY_VALUE;
           }
        }
      else if(BufferSlope[i]<BufferSlope[i+1])
        {
         if(BufferMA[i]<BufferMA[i+1])
           {
            BufferDN[i]=0.5;
            BufferUP[i]=BufferNL[i]=EMPTY_VALUE;
           }
        }
      else
        {
         BufferNL[i]=0.5;
         BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      for(int i=0;i<COUNT;i++)
         PlotIndexSetInteger(i,PLOT_LINE_WIDTH,SizeByScale());
      Descriptions();
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Возвращает размер, соответствующий масштабу                      |
//+------------------------------------------------------------------+
uchar SizeByScale(void)
  {
   uchar scale=(uchar)ChartGetInteger(0,CHART_SCALE);
   uchar size=(scale<3 ? 1 : scale==3 ? 2 : scale==4 ? 5 : 8);
   return size;
  }
//+------------------------------------------------------------------+
//| Описание                                                         |
//+------------------------------------------------------------------+
void Descriptions(void)
  {
   int x=4;
   int y=1;
   int arr_colors[]={indicator_color1,indicator_color2,indicator_color3};
   string arr_texts[]={"Up direction","Down direction","Neutral"};
   string arr_names[COUNT];
   for(int i=0; i<COUNT; i++)
     {
      arr_names[i]=prefix+"label"+(string)i;
      arr_colors[i]=PlotIndexGetInteger(i,PLOT_LINE_COLOR);
      x=(i==0 ? x : i==1 ? 110 : 230);
      Label(arr_names[i],x,y,CharToString(167),16,arr_colors[i],"Wingdings");
      Label(arr_names[i]+"_txt",x+10,y+5,arr_texts[i],10,clrGray,"Calibri");
     }
  }
//+------------------------------------------------------------------+
//| Выводит текстовую метку                                          |
//+------------------------------------------------------------------+
void Label(const string name,const int x,const int y,const string text,const int size,const color clr,const string font)
  {
   if(ObjectFind(0,name)!=wnd)
      ObjectCreate(0,name,OBJ_LABEL,wnd,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//---
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  }
//+------------------------------------------------------------------+
