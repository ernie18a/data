//+------------------------------------------------------------------+
//|                                           Repulse_Divergence.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Repulse Divergence"
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots   6

//--- plot Arrow to up
#property indicator_label1  "Long signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Arrow to down
#property indicator_label2  "Short signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot divergence line to up
#property indicator_label3  "Line to up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot divergence line to down
#property indicator_label4  "Line to down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- plot RP1
#property indicator_label5  "Repulse line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot RP2
#property indicator_label6  "Signal line"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- enums
enum ENUM_MODE_LINE
  {
   MODE_LINE_MAIN    =  MAIN_LINE,  // Main
   MODE_LINE_SIGNAL  =  SIGNAL_LINE // Signal
  };
//--- input parameters
input uint           InpPeriod1     =  5;                // Repulse period
input uint           InpPeriod2     =  15;               // Signal period
input ENUM_MODE_LINE InpRepulseLine =  MODE_LINE_MAIN;   // Repulse line
//--- indicator buffers
double         BufferArrowToUP[];
double         BufferLineToUP[];
double         BufferArrowToDN[];
double         BufferLineToDN[];
//---
double         BufferRP1[];
double         BufferRP2[];
double         BufferPos1[];
double         BufferNeg1[];
double         BufferPos2[];
double         BufferNeg2[];
double         BufferPos1tmp[];
double         BufferNeg1tmp[];
double         BufferPos2tmp[];
double         BufferNeg2tmp[];
//---
double         BufferDivRepulse[];
double         BufferATR[];
//--- global variables
string         prefix;
int            period1;
int            period2;
int            handle_atr;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   prefix="repulsediv";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArrowToUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArrowToDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLineToUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLineToDN,INDICATOR_DATA);

   SetIndexBuffer(4,BufferRP1,INDICATOR_DATA);
   SetIndexBuffer(5,BufferRP2,INDICATOR_DATA);
   SetIndexBuffer(6,BufferPos1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferNeg1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferPos2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferNeg2,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(10,BufferDivRepulse,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferPos1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferNeg1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferPos2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferNeg2tmp,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(15,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Repulse Divergence("+(string)period1+","+(string)period2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer colors
   PlotIndexSetInteger(0,PLOT_ARROW,241);
   PlotIndexSetInteger(1,PLOT_ARROW,242);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,indicator_color1);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,indicator_color2);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,indicator_color3);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,indicator_color4);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArrowToUP,true);
   ArraySetAsSeries(BufferArrowToDN,true);
   ArraySetAsSeries(BufferLineToUP,true);
   ArraySetAsSeries(BufferLineToDN,true);
   ArraySetAsSeries(BufferDivRepulse,true);
   //---
   ArraySetAsSeries(BufferRP1,true);
   ArraySetAsSeries(BufferRP2,true);
   ArraySetAsSeries(BufferPos1,true);
   ArraySetAsSeries(BufferNeg1,true);
   ArraySetAsSeries(BufferPos2,true);
   ArraySetAsSeries(BufferNeg2,true);
   ArraySetAsSeries(BufferPos1tmp,true);
   ArraySetAsSeries(BufferNeg1tmp,true);
   ArraySetAsSeries(BufferPos2tmp,true);
   ArraySetAsSeries(BufferNeg2tmp,true);
   //---
   ArraySetAsSeries(BufferATR,true);
//--- create ATR handle
   ResetLastError();
   handle_atr=iATR(Symbol(),PERIOD_CURRENT,14);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4 || Point()==0) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int max=fmax(4,fmax(period1,period2));
   if(limit>1)
     {
      limit=rates_total-max-1;
      ArrayInitialize(BufferArrowToUP,EMPTY_VALUE);
      ArrayInitialize(BufferArrowToDN,EMPTY_VALUE);
      ArrayInitialize(BufferLineToUP,EMPTY_VALUE);
      ArrayInitialize(BufferLineToDN,EMPTY_VALUE);
      ArrayInitialize(BufferDivRepulse,0);
      ArrayInitialize(BufferATR,0);
      //---
      ArrayInitialize(BufferRP1,EMPTY_VALUE);
      ArrayInitialize(BufferRP2,EMPTY_VALUE);
      ArrayInitialize(BufferPos1,0);
      ArrayInitialize(BufferNeg1,0);
      ArrayInitialize(BufferPos2,0);
      ArrayInitialize(BufferNeg2,0);
      ArrayInitialize(BufferPos1tmp,0);
      ArrayInitialize(BufferNeg1tmp,0);
      ArrayInitialize(BufferPos2tmp,0);
      ArrayInitialize(BufferNeg2tmp,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//---
   double MinPrice=0,MaxPrice=0;
   int bl=WRONG_VALUE,bh=WRONG_VALUE;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(close[i]==0) continue;
      bl=Lowest(period1,i);
      bh=Highest(period1,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE) continue;
      MinPrice=low[bl];
      MaxPrice=high[bh];
      BufferPos1tmp[i]=100.*(3.*close[i]-2.*MinPrice-open[i])/close[i];
      BufferNeg1tmp[i]=100.*(open[i]+2.*MaxPrice-3.*close[i])/close[i];
      //---
      bl=Lowest(period2,i);
      bh=Highest(period2,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE) continue;
      MinPrice=low[bl];
      MaxPrice=high[bh];
      BufferPos2tmp[i]=100.*(3.*close[i]-2.*MinPrice-open[i+period2])/close[i];
      BufferNeg2tmp[i]=100.*(open[i+period2]+2.*MaxPrice-3.*close[i])/close[i];
     }
//--- Расчёт индикатора
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,5*period1,BufferPos1tmp,BufferPos1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,5*period1,BufferNeg1tmp,BufferNeg1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,5*period2,BufferPos2tmp,BufferPos2);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,5*period2,BufferNeg2tmp,BufferNeg2);
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRP1[i]=(BufferPos1[i]-BufferNeg1[i])/Point();
      BufferRP2[i]=(BufferPos2[i]-BufferNeg2[i])/Point();
      BufferDivRepulse[i]=(!InpRepulseLine ? BufferRP1[i] : BufferRP2[i]);
     }
//--- Поиск дивергенций
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLineToUP[i]=BufferLineToDN[i]=BufferArrowToUP[i]=BufferArrowToDN[i]=EMPTY_VALUE;
      ProcessBullish(rates_total,high,low,time,i+2);
      ProcessBearish(rates_total,high,low,time,i+2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Ищет впадину и возвращает флаг                                   |
//+------------------------------------------------------------------+
bool IsTrough(const int &rates_total,const int index)
  {
   if(BufferDivRepulse[index]<0 && BufferDivRepulse[index]<BufferDivRepulse[index+1] && BufferDivRepulse[index]<BufferDivRepulse[index-1])
     {
      for(int n=index+1 ;n<rates_total-2; n++)
        {
         if(BufferDivRepulse[n]>0)
            return true;
         else if(BufferDivRepulse[index]>BufferDivRepulse[n])
            return false;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Ищет предыдущую впадину и возвращает флаг                        |
//+------------------------------------------------------------------+
int PrevTrough(const int &rates_total,const int index)
  {
   for(int n=index+5; n<rates_total-3; n++)
     {
      if(BufferDivRepulse[n]<=BufferDivRepulse[n+1] && BufferDivRepulse[n]<BufferDivRepulse[n+2] && BufferDivRepulse[n]<=BufferDivRepulse[n-1] && BufferDivRepulse[n]<BufferDivRepulse[n-2])
         return n;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Поиск бычьих дивергенций                                         |
//+------------------------------------------------------------------+
void ProcessBullish(const int &rates_total,const double &high[],const double &low[],const datetime &time[],const int index)
  {
   if(IsTrough(rates_total,index))
     {
      int curr=index;
      int prev=PrevTrough(rates_total,index);
      if(prev!=WRONG_VALUE)
        {
         if(BufferDivRepulse[curr]>BufferDivRepulse[prev] && low[curr]<low[prev])
            DrawDivergence(high,low,time,prev,curr,true);
         else if(BufferDivRepulse[curr]<BufferDivRepulse[prev] && low[curr]>low[prev])
            DrawDivergence(high,low,time,prev,curr,true);
        }
     }
  }
//+------------------------------------------------------------------+
//| Ищет пик и возвращает флаг                                       |
//+------------------------------------------------------------------+
bool IsPeak(const int &rates_total,const int index)
  {
   if(BufferDivRepulse[index]>0 && BufferDivRepulse[index]>BufferDivRepulse[index+1] && BufferDivRepulse[index]>BufferDivRepulse[index-1])
     {
      for(int n=index+1; n<rates_total-2; n++)
        {
         if(BufferDivRepulse[n]<0)
            return true;
         else if(BufferDivRepulse[index]<BufferDivRepulse[n])
            return false;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Ищет предыдущий пик и возвращает флаг                            |
//+------------------------------------------------------------------+
int PrevPeak(const int &rates_total,const int index)
  {
   for(int n=index+5; n<rates_total-3; n++)
     {
      if(BufferDivRepulse[n]>=BufferDivRepulse[n+1] && BufferDivRepulse[n]>BufferDivRepulse[n+2] && BufferDivRepulse[n]>=BufferDivRepulse[n-1] && BufferDivRepulse[n]>BufferDivRepulse[n-2])
         return n;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Поиск медвежьих дивергенций                                      |
//+------------------------------------------------------------------+
void ProcessBearish(const int &rates_total,const double &high[],const double &low[],const datetime &time[],const int index)
  {
   if(IsPeak(rates_total,index))
     {
      int curr=index;
      int prev=PrevPeak(rates_total,index);
      if(prev!=WRONG_VALUE)
        {
         if(BufferDivRepulse[curr]<BufferDivRepulse[prev] && high[curr]>high[prev])
            DrawDivergence(high,low,time,prev,curr,false);
         else if(BufferDivRepulse[curr]>BufferDivRepulse[prev] && high[curr]<high[prev])
            DrawDivergence(high,low,time,prev,curr,false);
        }
     }
  }
//+------------------------------------------------------------------+
//| Отображает найденные дивергенции                                 |
//+------------------------------------------------------------------+
void DrawDivergence(const double &high[],const double &low[],const datetime &time[],const int first,const int second,const bool bull_flag)
  {
   string obj_name=prefix+(string)(long)time[first]+"_"+(string)(long)time[second];
   int wnd;
   if(ObjectFind(0,obj_name)<0)
     {
      wnd=ChartWindowFind();
      if(wnd!=WRONG_VALUE)
        {
         if(bull_flag)
           {
            BufferArrowToUP[second]=BufferDivRepulse[second];
            for(int j=first; j>=second; j--)
               BufferLineToUP[j]=EquationDirect(first,BufferDivRepulse[first],second,BufferDivRepulse[second],j);
            //---
            ObjectCreate(0,obj_name+"~",OBJ_TREND,0,time[first],low[first],time[second],low[second]);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_COLOR,indicator_color3);
            ObjectSetString(0,obj_name+"~",OBJPROP_TOOLTIP,"\n");
            //---
            ObjectCreate(0,obj_name+"~A",OBJ_ARROW,0,time[second],low[second]);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_COLOR,indicator_color3);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_ARROWCODE,241);
            ObjectSetString(0,obj_name+"~A",OBJPROP_TOOLTIP,"Bullish signal: "+TimeToString(time[second]));
           }
         else
           {
            BufferArrowToDN[second]=BufferDivRepulse[second];
            for(int j=first; j>=second; j--)
               BufferLineToDN[j]=EquationDirect(first,BufferDivRepulse[first],second,BufferDivRepulse[second],j);
            //---
            ObjectCreate(0,obj_name+"~",OBJ_TREND,0,time[first],high[first],time[second],high[second]);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_COLOR,indicator_color4);
            ObjectSetString(0,obj_name+"~",OBJPROP_TOOLTIP,"\n");
            //---
            ObjectCreate(0,obj_name+"~A",OBJ_ARROW,0,time[second],high[second]+BufferATR[second]);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_COLOR,indicator_color4);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_ARROWCODE,242);
            ObjectSetString(0,obj_name+"~A",OBJPROP_TOOLTIP,"Bearish signal: "+TimeToString(time[second]));
           }
         ObjectSetInteger(0,obj_name+"~",OBJPROP_RAY,false);
        }
     }
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search) 
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
