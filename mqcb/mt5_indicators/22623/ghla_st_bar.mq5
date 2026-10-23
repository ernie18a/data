//+------------------------------------------------------------------+
//|                                                  GHLA_ST_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Gann HiLo Activator/SuperTrend Bar indicator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "GHLA/ST Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "GHLA/ST Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NL
#property indicator_label3  "GHLA/ST Neutral"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLightSteelBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- defines
#define                 COUNT             (3)
//--- input parameters
input uint              InpPeriodGHLA  =  10;         // GHLA period
input uint              InpPeriodST    =  14;         // SuperTrend period
input uint              InpShiftST     =  20;         // SuperTrend shift
input ENUM_INPUT_YES_NO InpUseFilterST =  INPUT_YES;  // Use SuperTrend filter
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
//--- GHLA buffers
double         BufferGHLA[];
double         BufferMAH[];
double         BufferMAL[];
double         BufferDir[];
//--- SuperTrend buffers
double         BufferST[];
double         BufferFlag[];
double         BufferCCI[];
//--- global variables
string         prefix;
int            wnd;
int            period_ghla;
int            handle_mah;
int            handle_mal;
//---
double         shift;
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
   period_ghla=int(InpPeriodGHLA<1 ? 1 : InpPeriodGHLA);
   period_cci=int(InpPeriodST<1 ? 1 : InpPeriodST);
   shift=InpShiftST*Point();
//---
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
//--- GHLA
   SetIndexBuffer(3,BufferGHLA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferDir,INDICATOR_CALCULATIONS);
//--- SuperTrend
   SetIndexBuffer(7,BufferST,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferFlag,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferCCI,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"GHLA/SuperTrend Bar ("+(string)period_ghla+","+(string)period_cci+","+(string)InpShiftST+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferGHLA,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferDir,true);
   ArraySetAsSeries(BufferST,true);
   ArraySetAsSeries(BufferFlag,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create MA's handles
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period_ghla,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ghla,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal=iMA(NULL,PERIOD_CURRENT,period_ghla,0,MODE_SMA,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ghla,") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create cci handle
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ghla,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      //---
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      //--- GHLA
      ArrayInitialize(BufferGHLA,0);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
      ArrayInitialize(BufferDir,0);
      //--- SuperTrend
      ArrayInitialize(BufferST,0);
      ArrayInitialize(BufferFlag,0);
      ArrayInitialize(BufferCCI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
   //--- Расчёт GHLA
      double avgH=BufferMAH[i];
      double avgL=BufferMAL[i];
      int sw=(close[i]>avgH ? 1 : close[i]<avgL ? -1 : 0);
      BufferDir[i]=(sw!=0 ? sw : BufferDir[i+1]);
      if(BufferDir[i]<0)
         BufferGHLA[i]=avgH;
      else
         BufferGHLA[i]=avgL;
   //--- Расчёт SuperTrend
      double CCI=BufferCCI[i];
      BufferST[i]=BufferST[i+1];
      BufferFlag[i]=BufferFlag[i+1];
      if(CCI>0 && BufferFlag[i]<=0)
        {
         BufferFlag[i]=1;
         BufferST[i]=low[i]-shift;
        }
      if(CCI<0 && BufferFlag[i]>=0)
        {
         BufferFlag[i]=-1;
         BufferST[i]=high[i]+shift;
        }
      BufferST[i]=
        (
         BufferFlag[i]>0 && low[i]-shift>BufferST[i+1] ? low[i]-shift :
         BufferFlag[i]<0 && high[i]+shift<BufferST[i+1] ? high[i]+shift :
         BufferST[i]
        );
      if(InpUseFilterST)
        {
         if(BufferFlag[i]>0 && BufferST[i]>BufferST[i+1])
           {
            if(close[i]<open[i])
               BufferST[i]=BufferST[i+1];
            if(high[i]<high[i+1])
               BufferST[i]=BufferST[i+1];
           }
         if(BufferFlag[i]<0 && BufferST[i]<BufferST[i+1])
           {
            if(close[i]>open[i])
               BufferST[i]=BufferST[i+1];
            if(low[i]>low[i+1])
               BufferST[i]=BufferST[i+1];
           }
        }
   //--- Расчёт индикатора
      double ST=BufferST[i];
      double GHLA=BufferGHLA[i];
      BufferUP[i]=BufferDN[i]=BufferNL[i]=EMPTY_VALUE;
      if(close[i]>ST && close[i]>GHLA)
         BufferUP[i]=0.5;
      else
        {
         if(close[i]<ST && close[i]<GHLA)
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
