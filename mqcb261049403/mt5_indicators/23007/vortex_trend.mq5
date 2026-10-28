//+------------------------------------------------------------------+
//|                                                 Vortex_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Vortex Trend"
#property indicator_separate_window
#property indicator_buffers 10
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
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodV     =  14;         // Vortex period
input double            InpOverbought  =  110.0;      // Upper limit of the filtering range
input double            InpOversold    =  90.0;       // Lower limit of the filtering range
input ENUM_INPUT_YES_NO InpUseSmooth   =  INPUT_YES;  // Use Vortex smoothing
input uint              InpPeriodMA    =  20;         // Smoothing
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferVPos[];
double         BufferVNeg[];
double         BufferVHigh[];
double         BufferVLow[];
double         BufferMAUp[];
double         BufferMADn[];
double         BufferATR[];
//--- global variables
string         prefix;
int            wnd;
double         overbought;
double         oversold;
int            period_v;
int            period_ma;
int            handle_atr;
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
   period_v=int(InpPeriodV<1 ? 1 : InpPeriodV);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   overbought=(InpOverbought<100.0 ? 100.0 : InpOverbought);
   oversold=(InpOversold>100.0 ? 100.0 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferVPos,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferVNeg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferVLow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMAUp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMADn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferATR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Vortex Trend ("+(string)period_v+","+(string)period_ma+","+(string)overbought+","+(string)oversold+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferVPos,true);
   ArraySetAsSeries(BufferVNeg,true);
   ArraySetAsSeries(BufferVHigh,true);
   ArraySetAsSeries(BufferVLow,true);
   ArraySetAsSeries(BufferMAUp,true);
   ArraySetAsSeries(BufferMADn,true);
   ArraySetAsSeries(BufferATR,true);
//--- create ATR handle
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,1);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(1) object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_v-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVHigh[i]=fabs(high[i]-low[i+1]);
      BufferVLow[i]=fabs(low[i]-high[i+1]);
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //--- Vortex
      double sum_v_high=0,sum_v_low=0,sum_atr=0;
      for(int j=(i+period_v-1); j>=i; j--)
        {
         sum_v_high+=BufferVHigh[j];
         sum_v_low+=BufferVLow[j];
         sum_atr+=BufferATR[j];
        }
      BufferVPos[i]=(sum_atr!=0 ? sum_v_high/sum_atr*100.0 : 100.0);
      BufferVNeg[i]=(sum_atr!=0 ? sum_v_low/sum_atr*100.0 : 100.0);
      BufferMAUp[i]=GetSMA(rates_total,i,period_ma,BufferVPos);
      BufferMADn[i]=GetSMA(rates_total,i,period_ma,BufferVNeg);

      //--- Vortex Trend
      BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
      BufferNL[i]=0.5;
      if(InpUseSmooth)
        {
         if(BufferMAUp[i]>overbought && BufferMADn[i]<oversold)
           {
            BufferUP[i]=0.5;
            BufferDN[i]=BufferNL[i]=EMPTY_VALUE;
           }
         else if(BufferMADn[i]>overbought && BufferMAUp[i]<oversold)
           {
            BufferDN[i]=0.5;
            BufferUP[i]=BufferNL[i]=EMPTY_VALUE;
           }
         else
           {
            BufferNL[i]=0.5;
            BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
           }
         }
      else
        {
         if(BufferVPos[i]>overbought && BufferVNeg[i]<oversold)
           {
            BufferUP[i]=0.5;
            BufferDN[i]=BufferNL[i]=EMPTY_VALUE;
           }
         else if(BufferVNeg[i]>overbought && BufferVPos[i]<oversold)
           {
            BufferDN[i]=0.5;
            BufferUP[i]=BufferNL[i]=EMPTY_VALUE;
           }
         else
           {
            BufferNL[i]=0.5;
            BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
           }
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
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
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
   string arr_texts[]={"Up direction","Down direction","Neutral"};
   for(int i=0; i<COUNT; i++)
     {
      string name=prefix+"label"+(string)i;
      color clr=(color)PlotIndexGetInteger(i,PLOT_LINE_COLOR);
      x=(i==0 ? x : i==1 ? 110 : 230);
      Label(name,x,y,CharToString(167),16,clr,"Wingdings");
      Label(name+"_txt",x+10,y+5,arr_texts[i],10,clrGray,"Calibri");
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
