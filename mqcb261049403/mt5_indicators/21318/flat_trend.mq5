//+------------------------------------------------------------------+
//|                                                   Flat_Trend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Flat Trend indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
//--- plot UpUp
#property indicator_label1  "Up/Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot UpDn
#property indicator_label2  "Up/Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot DnUp
#property indicator_label3  "Down/Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot DnDn
#property indicator_label4  "Down/Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input double               InpStepSAR        =  0.02;          // SAR step
input double               InpMaxSAR         =  0.2;           // SAR max
input uint                 InpPeriodDMI      =  14;            // ADX period
//--- indicator buffers
double         BufferUpUp[];
double         BufferUpDn[];
double         BufferDnUp[];
double         BufferDnDn[];
double         BufferPDI[];
double         BufferMDI[];
double         BufferSAR[];
//--- global variables
string         prefix;
double         step_sar;
double         max_sar;
int            period_dmi;
int            handle_sar;
int            handle_adx;
int            wnd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_dmi=int(InpPeriodDMI<1 ? 1 : InpPeriodDMI);
   step_sar=(InpStepSAR<0.0001 ? 0.0001 : InpStepSAR);
   max_sar=(InpMaxSAR<0.0001 ? 0.0001 : InpMaxSAR);
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpUp,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUpDn,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDnUp,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDnDn,INDICATOR_DATA);
   SetIndexBuffer(4,BufferPDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSAR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<4; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Flat Trend (SAR: "+DoubleToString(step_sar,2)+","+DoubleToString(max_sar,2)+", ADX: "+(string)period_dmi+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpUp,true);
   ArraySetAsSeries(BufferUpDn,true);
   ArraySetAsSeries(BufferDnUp,true);
   ArraySetAsSeries(BufferDnDn,true);
   ArraySetAsSeries(BufferPDI,true);
   ArraySetAsSeries(BufferMDI,true);
   ArraySetAsSeries(BufferSAR,true);
//--- create ADX and SAR handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_dmi);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_dmi,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sar=iSAR(NULL,PERIOD_CURRENT,step_sar,max_sar);
   if(handle_sar==INVALID_HANDLE)
     {
      Print("The iSAR(",DoubleToString(step_sar,2),","+DoubleToString(max_sar,2),") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUpUp,EMPTY_VALUE);
      ArrayInitialize(BufferUpDn,EMPTY_VALUE);
      ArrayInitialize(BufferDnUp,EMPTY_VALUE);
      ArrayInitialize(BufferDnDn,EMPTY_VALUE);
      ArrayInitialize(BufferPDI,0);
      ArrayInitialize(BufferMDI,0);
      ArrayInitialize(BufferSAR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferPDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferMDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sar,0,0,count,BufferSAR);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double PDI=BufferPDI[i];
      double MDI=BufferMDI[i];
      double SAR=BufferSAR[i];

      bool one=(PDI>MDI ? true : false);
      bool two=(SAR>low[i] ? false : true);

      BufferUpUp[i]=BufferUpDn[i]=BufferDnUp[i]=BufferDnDn[i]=EMPTY_VALUE;

      if(one)
        {
         if(two)
            BufferUpUp[i]=0.5;
         else
            BufferUpDn[i]=0.5;
        }
      else
        {
         if(two)
            BufferDnUp[i]=0.5;
         else
            BufferDnDn[i]=0.5;
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
      for(int i=0;i<4;i++)
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
   int arr_colors[]={indicator_color1,indicator_color2,indicator_color3,indicator_color4};
   string arr_texts[]={"DMI up, SAR up","DMI up, SAR down","DMI down, SAR up","DMI down, SAR down"};
   string arr_names[4];
   for(int i=0; i<4; i++)
     {
      arr_names[i]=prefix+"label"+(string)i;
      arr_colors[i]=PlotIndexGetInteger(i,PLOT_LINE_COLOR);
      x=(i==0 ? x : i==1 ? 110 : i==2 ? 230 : 350);
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
