//+------------------------------------------------------------------+
//|                                             TMACD_Divergence.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "TMACD Divergence indicator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   5
//--- plot TMACD
#property indicator_label1  "TMACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "Short signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot UP
#property indicator_label3  "Long signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot divergence line to up
#property indicator_label4  "Line to up"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot divergence line to down
#property indicator_label5  "Line to down"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint                 InpPeriodFast     =  7;             // Fast MA period
input uint                 InpPeriodSlow     =  14;            // Slow MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferTMACD[];
double         BufferColors[];
double         BufferArrowToDN[];
double         BufferArrowToUP[];
double         BufferLineToUP[];
double         BufferLineToDN[];
double         BufferFMA[];
double         BufferSMA[];
double         BufferATR[];
//--- global variables
string         prefix;
int            period_fast;
int            period_slow;
int            len_f;
int            len_s;
int            period_max;
int            handle_fma;
int            handle_sma;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int((int)InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   prefix="tmacdiv";
   len_f=(int)floor(period_fast/2)+1;
   len_s=(int)floor(period_slow/2)+1;
   period_max=fmax(len_f,len_s);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTMACD,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferArrowToDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferArrowToUP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferLineToUP,INDICATOR_DATA);
   SetIndexBuffer(5,BufferLineToDN,INDICATOR_DATA);
   SetIndexBuffer(6,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferATR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,242);
   PlotIndexSetInteger(2,PLOT_ARROW,241);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TMACD Divergence ("+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTMACD,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferArrowToDN,true);
   ArraySetAsSeries(BufferArrowToUP,true);
   ArraySetAsSeries(BufferLineToUP,true);
   ArraySetAsSeries(BufferLineToDN,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,len_f,0,MODE_SMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)len_f,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,len_s,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)len_s,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr=iATR(NULL,PERIOD_CURRENT,14);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-5;
      ArrayInitialize(BufferTMACD,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferArrowToDN,EMPTY_VALUE);
      ArrayInitialize(BufferArrowToUP,EMPTY_VALUE);
      ArrayInitialize(BufferLineToUP,EMPTY_VALUE);
      ArrayInitialize(BufferLineToDN,EMPTY_VALUE);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double F_TMA=GetSMA(rates_total,i,len_f,BufferFMA);
      double S_TMA=GetSMA(rates_total,i,len_s,BufferSMA);
      BufferTMACD[i]=(F_TMA-S_TMA)/Point();
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLineToUP[i]=BufferLineToDN[i]=BufferArrowToUP[i]=BufferArrowToDN[i]=EMPTY_VALUE;
      ProcessBullish(rates_total,high,low,time,i+2);
      ProcessBearish(rates_total,high,low,time,i+2);
      BufferColors[i]=(BufferTMACD[i]>BufferTMACD[i+1] ? 0 : BufferTMACD[i]<BufferTMACD[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
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
//| Ищет впадину и возвращает флаг                                   |
//+------------------------------------------------------------------+
bool IsTrough(const int &rates_total,const int index)
  {
   if(BufferTMACD[index]<0 && BufferTMACD[index]<BufferTMACD[index+1] && BufferTMACD[index]<BufferTMACD[index-1])
     {
      for(int n=index+1; n<rates_total-2; n++)
        {
         if(BufferTMACD[n]>0)
            return true;
         else if(BufferTMACD[index]>BufferTMACD[n])
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
      if(BufferTMACD[n]<=BufferTMACD[n+1] && BufferTMACD[n]<BufferTMACD[n+2] && BufferTMACD[n]<=BufferTMACD[n-1] && BufferTMACD[n]<BufferTMACD[n-2])
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
         if(BufferTMACD[curr]>BufferTMACD[prev] && low[curr]<low[prev])
            DrawDivergence(high,low,time,prev,curr,true);
         else if(BufferTMACD[curr]<BufferTMACD[prev] && low[curr]>low[prev])
            DrawDivergence(high,low,time,prev,curr,true);
        }
     }
  }
//+------------------------------------------------------------------+
//| Ищет пик и возвращает флаг                                       |
//+------------------------------------------------------------------+
bool IsPeak(const int &rates_total,const int index)
  {
   if(BufferTMACD[index]>0 && BufferTMACD[index]>BufferTMACD[index+1] && BufferTMACD[index]>BufferTMACD[index-1])
     {
      for(int n=index+1; n<rates_total-2; n++)
        {
         if(BufferTMACD[n]<0)
            return true;
         else if(BufferTMACD[index]<BufferTMACD[n])
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
      if(BufferTMACD[n]>=BufferTMACD[n+1] && BufferTMACD[n]>BufferTMACD[n+2] && BufferTMACD[n]>=BufferTMACD[n-1] && BufferTMACD[n]>BufferTMACD[n-2])
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
         if(BufferTMACD[curr]<BufferTMACD[prev] && high[curr]>high[prev])
            DrawDivergence(high,low,time,prev,curr,false);
         else if(BufferTMACD[curr]>BufferTMACD[prev] && high[curr]<high[prev])
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
            BufferArrowToUP[second]=BufferTMACD[second];
            for(int j=first; j>=second; j--)
               BufferLineToUP[j]=EquationDirect(first,BufferTMACD[first],second,BufferTMACD[second],j);
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
            BufferArrowToDN[second]=BufferTMACD[second];
            for(int j=first; j>=second; j--)
               BufferLineToDN[j]=EquationDirect(first,BufferTMACD[first],second,BufferTMACD[second],j);
            //---
            ObjectCreate(0,obj_name+"~",OBJ_TREND,0,time[first],high[first],time[second],high[second]);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_COLOR,indicator_color2);
            ObjectSetString(0,obj_name+"~",OBJPROP_TOOLTIP,"\n");
            //---
            ObjectCreate(0,obj_name+"~A",OBJ_ARROW,0,time[second],high[second]+BufferATR[second]);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,obj_name+"~",OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,obj_name+"~A",OBJPROP_COLOR,indicator_color2);
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
