//+------------------------------------------------------------------+
//|                                              Williams_Thrust.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Williams Thrust indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "WT Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "WT Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NL
#property indicator_label3  "WT Neutral"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- defines
#define   COUNT            (3)
//--- input parameters
input uint           InpPeriodLW1   =  250;        // First WPR period
input uint           InpPeriodMA1   =  50;         // First MA period
input uint           InpPeriodLW2   =  50;         // Second WPR period
input uint           InpPeriodMA2   =  10;         // Second MA period
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // MA method
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferWPR1[];
double         BufferWPR2[];
double         BufferAvgWPR1[];
double         BufferAvgWPR2[];
//--- global variables
string         prefix;
int            period_lw1;
int            period_ma1;
int            period_lw2;
int            period_ma2;
int            period_max;
int            handle_wpr1;
int            handle_wpr2;
int            weight_sum1;
int            weight_sum2;
int            wnd;
//--- include
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_lw1=int(InpPeriodLW1<1 ? 1 : InpPeriodLW1);
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_lw2=int(InpPeriodLW2<1 ? 1 : InpPeriodLW2);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferWPR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferWPR2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAvgWPR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgWPR2,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Williams Thrust ("+(string)period_lw1+","+(string)period_ma1+","+(string)period_lw2+","+(string)period_ma2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferWPR1,true);
   ArraySetAsSeries(BufferWPR2,true);
   ArraySetAsSeries(BufferAvgWPR1,true);
   ArraySetAsSeries(BufferAvgWPR2,true);
//--- create MA's handles
   ResetLastError();
   handle_wpr1=iWPR(NULL,PERIOD_CURRENT,period_lw1);
   if(handle_wpr1==INVALID_HANDLE)
     {
      Print("The iWPR(",(string)period_lw1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_wpr2=iWPR(NULL,PERIOD_CURRENT,period_lw2);
   if(handle_wpr2==INVALID_HANDLE)
     {
      Print("The iWPR(",(string)period_lw2,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      ArrayInitialize(BufferWPR1,0);
      ArrayInitialize(BufferWPR2,0);
      ArrayInitialize(BufferAvgWPR1,0);
      ArrayInitialize(BufferAvgWPR2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_wpr1,0,0,count,BufferWPR1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_wpr2,0,0,count,BufferWPR2);
   if(copied!=count) return 0;

   switch(InpMethod)
     {
      case MODE_EMA  :
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma1,BufferWPR1,BufferAvgWPR1)==0) return 0;
        if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma2,BufferWPR1,BufferAvgWPR2)==0) return 0;
        break;
      case MODE_SMMA :
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma1,BufferWPR1,BufferAvgWPR1)==0) return 0;
        if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma2,BufferWPR1,BufferAvgWPR2)==0) return 0;
        break;
      case MODE_LWMA :
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma1,BufferWPR1,BufferAvgWPR1,weight_sum1)==0) return 0;
        if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma2,BufferWPR1,BufferAvgWPR2,weight_sum2)==0) return 0;
        break;
      //---MODE_SMA
      default        :
        if(SimpleMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma1,BufferWPR1,BufferAvgWPR1)==0) return 0;
        if(SimpleMAOnBuffer(rates_total,prev_calculated,period_lw1,period_ma2,BufferWPR1,BufferAvgWPR2)==0) return 0;
        break;
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP[i]=BufferDN[i]=BufferNL[i]=EMPTY_VALUE;

      if(BufferWPR1[i]>BufferAvgWPR1[i] && BufferWPR2[i]>BufferAvgWPR2[i])
         BufferUP[i]=0.5;
      else
        {
         if(BufferWPR1[i]<BufferAvgWPR1[i] && BufferWPR2[i]<BufferAvgWPR2[i])
            BufferDN[i]=0.5;
         else
            BufferNL[i]=0.5;
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
