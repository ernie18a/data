//+------------------------------------------------------------------+
//|                                     Volatility_Quality_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility Quality Index indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "VQI Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "VQI Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint           InpPeriod      =  7;          // Period
input ENUM_MA_METHOD InpMethod      =  MODE_SMA;   // Method
input uint           InpSmoothing   =  1;          // Smoothing
input uint           InpFilter      =  5;          // Filter
//--- defines
#define              COUNT            (2)
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferVQ[];
double         BufferMAO[];
double         BufferMAH[];
double         BufferMAL[];
double         BufferMAC[];
//--- global variables
string         prefix;
int            wnd;
int            period;
int            period_sm;
int            filter;
int            handle_maO;
int            handle_maH;
int            handle_maL;
int            handle_maC;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   period_sm=int(InpSmoothing<1 ? 1 : InpSmoothing);
   filter=int(InpFilter);
//---
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferVQ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMAC,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility Quality Index ("+(string)period+","+(string)period_sm+","+(string)filter+")");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferVQ,true);
   ArraySetAsSeries(BufferMAO,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferMAC,true);
//--- create MA's handles
   ResetLastError();
   handle_maO=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_OPEN);
   if(handle_maO==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_OPEN object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maH=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_HIGH);
   if(handle_maH==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maL=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_LOW);
   if(handle_maL==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maC=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,PRICE_CLOSE);
   if(handle_maC==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_CLOSE object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_sm,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sm-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferVQ,0);
      ArrayInitialize(BufferMAO,0);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
      ArrayInitialize(BufferMAC,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maO,0,0,count,BufferMAO);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maH,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maL,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maC,0,0,count,BufferMAC);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double o=BufferMAO[i];
      double h=BufferMAH[i];
      double l=BufferMAL[i];
      double c=BufferMAC[i];
      double c2=BufferMAC[i+period_sm];

      BufferDN[i]=BufferUP[i]=EMPTY_VALUE;
      double max=fmax(h-l,fmax(h-c2,c2-l));
      if(max!=0 && h-l!=0)
        {
         double VQnew=fabs(((c-c2)/max+(c-o)/(h-l))*0.5)*((c-c2+(c-o))*0.5);
         BufferVQ[i]=(fabs(VQnew)<filter*Point() ? BufferVQ[i+1] : VQnew);
         if(BufferVQ[i]>0)
           {
            BufferUP[i]=0.5;
            BufferDN[i]=EMPTY_VALUE;
           }
         else
           {
            BufferDN[i]=0.5;
            BufferUP[i]=EMPTY_VALUE;
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
   int arr_colors[]={indicator_color1,indicator_color2};
   string arr_texts[]={"Up direction","Down direction"};
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
