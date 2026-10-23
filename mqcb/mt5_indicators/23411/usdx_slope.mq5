//+------------------------------------------------------------------+
//|                                                   USDX_Slope.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "USDX vs Slope Direction Line indicator"
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
#property indicator_color3  clrDarkGray
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
input uint                 InpPeriodMA       =  80;            // SDL Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // SDL Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // SDL Applied price
input uint                 InpShiftX         =  1;             // USDX slope shift
input ENUM_INPUT_YES_NO    InpReverceX       =  INPUT_NO;      // USDX reverce
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
//--- SDL
double         BufferSDL[];
double         BufferMAP[];
double         BufferMAP2[];
double         BufferRAW[];
//--- USDX
double         BufferUSDX[];
//--- global variables
string         prefix;
int            wnd;
int            shiftX;
//--- SDL
int            period_ma;
int            period2;
int            periodSqrt;
int            handle_maP;
int            handle_maP2;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   shiftX=int(InpShiftX<1 ? 1 : InpShiftX);
//--- SDL
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period2=(int)floor(period_ma/2.0);
   periodSqrt=(int)floor(sqrt(period_ma));
//---
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   //--- SDL
   SetIndexBuffer(3,BufferSDL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMAP2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferRAW,INDICATOR_CALCULATIONS);
   //--- USDX
   SetIndexBuffer(7,BufferUSDX,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,(InpReverceX ? "Reverce " : "")+"USDX ("+(string)shiftX+") vs SDL("+(string)period_ma+") Bar");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   //--- SDL
   ArraySetAsSeries(BufferSDL,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMAP2,true);
   ArraySetAsSeries(BufferRAW,true);
   //--- USDX
   ArraySetAsSeries(BufferUSDX,true);
//--- create handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP2=iMA(NULL,PERIOD_CURRENT,period2,0,InpMethod,InpAppliedPrice);
   if(handle_maP2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- check symbols and get USDX datas
   if(!SymbolCheck("EURUSD")) return INIT_FAILED;
   if(!SymbolCheck("USDJPY")) return INIT_FAILED;
   if(!SymbolCheck("GBPUSD")) return INIT_FAILED;
   if(!SymbolCheck("USDCAD")) return INIT_FAILED;
   if(!SymbolCheck("USDSEK")) return INIT_FAILED;
   if(!SymbolCheck("USDCHF")) return INIT_FAILED;
   Time("EURUSD",PERIOD_CURRENT,1);
   Time("USDJPY",PERIOD_CURRENT,1);
   Time("GBPUSD",PERIOD_CURRENT,1);
   Time("USDCAD",PERIOD_CURRENT,1);
   Time("USDSEK",PERIOD_CURRENT,1);
   Time("USDCHF",PERIOD_CURRENT,1);
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
   if(rates_total<fmax(4,fmax(shiftX,period_ma))) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shiftX-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      //--- SDL
      ArrayInitialize(BufferSDL,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMAP2,0);
      ArrayInitialize(BufferRAW,0);
      //--- USDX
      ArrayInitialize(BufferUSDX,0);
     }
//--- Подготовка данных
   if(Time("EURUSD",PERIOD_CURRENT,1)==0) return 0;
   if(Time("USDJPY",PERIOD_CURRENT,1)==0) return 0;
   if(Time("GBPUSD",PERIOD_CURRENT,1)==0) return 0;
   if(Time("USDCAD",PERIOD_CURRENT,1)==0) return 0;
   if(Time("USDSEK",PERIOD_CURRENT,1)==0) return 0;
   if(Time("USDCHF",PERIOD_CURRENT,1)==0) return 0;

   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP2,0,0,count,BufferMAP2);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
   //--- расчёт USDX
      double clEU=Close("EURUSD",PERIOD_CURRENT,i);
      double clUJ=Close("USDJPY",PERIOD_CURRENT,i);
      double clGU=Close("GBPUSD",PERIOD_CURRENT,i);
      double clUC=Close("USDCAD",PERIOD_CURRENT,i);
      double clUS=Close("USDSEK",PERIOD_CURRENT,i);
      double clUCH=Close("USDCHF",PERIOD_CURRENT,i);
      if(clEU==0 || clUJ==0 || clGU==0 || clUC==0 || clUS==0 || clUCH==0)
         continue;
      double EU=pow(clEU,-0.576);
      double UJ=pow(clUJ,0.136);
      double GU=pow(clGU,-0.119);
      double UC=pow(clUC,0.091);
      double US=pow(clUS,0.042);
      double UCH=pow(clUCH,0.036);
      double x=50.14348112*EU*UJ*GU*UC*US*UCH;
      BufferUSDX[i]=(InpReverceX ? 1.0/x : x);
   //--- подготовка данных SDL
      BufferRAW[i]=2.0*BufferMAP2[i]-BufferMAP[i];
     }
//--- расчёт SDL
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;                    break;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      SetNeutral(i);
      if(BufferSDL[i]>BufferSDL[i+1] && BufferUSDX[i]>BufferUSDX[i+shiftX])
         SetUp(i);
      else if(BufferSDL[i]<BufferSDL[i+1] && BufferUSDX[i]<BufferUSDX[i+shiftX])
         SetDown(i);
      else
         SetNeutral(i);
     }
      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator ChartEvent function                             |
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
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time("EURUSD",PERIOD_CURRENT,1);
   Time("USDJPY",PERIOD_CURRENT,1);
   Time("GBPUSD",PERIOD_CURRENT,1);
   Time("USDCAD",PERIOD_CURRENT,1);
   Time("USDSEK",PERIOD_CURRENT,1);
   Time("USDCHF",PERIOD_CURRENT,1);
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
      int shift=(i*(i<2 ? 90 : 96)-(i>0 ? x : 0));
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
//| Устанавливает направление вверх                                  |
//+------------------------------------------------------------------+
void SetUp(const int index)
  {
   BufferUP[index]=0.5;
   BufferDN[index]=BufferNL[index]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//| Устанавливает направление вниз                                   |
//+------------------------------------------------------------------+
void SetDown(const int index)
  {
   BufferDN[index]=0.5;
   BufferUP[index]=BufferNL[index]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//| Устанавливает нейтральное направление                            |
//+------------------------------------------------------------------+
void SetNeutral(const int index)
  {
   BufferNL[index]=0.5;
   BufferDN[index]=BufferUP[index]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
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
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
