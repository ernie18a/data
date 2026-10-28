//+------------------------------------------------------------------+
//|                                                      CCI_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "CCI Bar indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   5
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Crossing Oversold
#property indicator_label3  "Crossing Oversold"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Crossing Overbought
#property indicator_label4  "Crossing Overbought"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrCrimson
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot NL
#property indicator_label5  "Neutral"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrGainsboro
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- defines
#define   COUNT            (5)
//--- input parameters
input uint     InpPeriodCCI   =  45;      // CCI period
input double   InpOverbought  =  150.0;   // Overbought
input double   InpOversold    = -150.0;   // Oversold
input double   InpLevEntryB   = -150;     // Buy entry level
input double   InpLevEntryS   =  150;     // Sell entry level
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferCrossOS[];
double         BufferCrossOB[];
double         BufferCCI[];
//--- global variables
string         prefix;
int            wnd;
double         levB;
double         levS;
double         overbought;
double         oversold;
int            period_cci;
int            handle_cci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   overbought=(fabs(InpOverbought)<0.1 ? 0.1 : fabs(InpOverbought));
   oversold=(-fabs(InpOversold)>-0.1 ? -0.1 : -fabs(InpOversold));
   levB=(InpLevEntryB>overbought ? overbought : InpLevEntryB);
   levS=(InpLevEntryS<oversold ? oversold : InpLevEntryS);
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCrossOS,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCrossOB,INDICATOR_DATA);
   SetIndexBuffer(4,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCCI,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI Bar ("+(string)period_cci+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferCrossOS,true);
   ArraySetAsSeries(BufferCrossOB,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create handles
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      ArrayInitialize(BufferCrossOS,EMPTY_VALUE);
      ArrayInitialize(BufferCrossOB,EMPTY_VALUE);
      ArrayInitialize(BufferCCI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double cci0=BufferCCI[i];
      double cci1=BufferCCI[i+1];
      BufferUP[i]=BufferDN[i]=BufferCrossOS[i]=BufferCrossOB[i]=EMPTY_VALUE;
      BufferNL[i]=0.5;
      
      bool crossing=false;
   //--- пересечение вверх уровня перепроданности
      if(cci0>oversold && cci1<=oversold)
        {
         BufferCrossOS[i]=0.5;
         BufferNL[i]=BufferUP[i]=BufferDN[i]=BufferCrossOB[i]=EMPTY_VALUE;
         crossing=true;
        }
   //--- пересечение вниз уровня перекупленности
      if(cci0<overbought && cci1>=overbought)
        {
         BufferCrossOB[i]=0.5;
         BufferNL[i]=BufferUP[i]=BufferDN[i]=BufferCrossOS[i]=EMPTY_VALUE;
         crossing=true;
        }
   //--- выше/ниже уровня покупки/продажи
      if(!crossing)
        {
         if(cci0>levB && cci0>=cci1)
           {
            BufferUP[i]=0.5;
            BufferNL[i]=BufferDN[i]=BufferCrossOB[i]=BufferCrossOS[i]=EMPTY_VALUE;
           }
         else if(cci0<levS && cci0<=cci1)
           {
            BufferDN[i]=0.5;
            BufferNL[i]=BufferUP[i]=BufferCrossOB[i]=BufferCrossOS[i]=EMPTY_VALUE;
           }
         else
           {
            BufferNL[i]=0.5;
            BufferDN[i]=BufferUP[i]=BufferCrossOB[i]=BufferCrossOS[i]=EMPTY_VALUE;
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
   int arr_colors[]={indicator_color1,indicator_color2,indicator_color3,indicator_color4,indicator_color5};
   string arr_texts[]={"Up direction","Down direction","Crossing to up","Crossing to down","Neutral"};
   string arr_names[COUNT];
   for(int i=0; i<COUNT; i++)
     {
      arr_names[i]=prefix+"label"+(string)i;
      arr_colors[i]=PlotIndexGetInteger(i,PLOT_LINE_COLOR);
      int shift=(i*(i<2 ? 90 : i<COUNT-1 ? 96 : 100)-(i>0 ? x : 0));
      x+=shift;
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
