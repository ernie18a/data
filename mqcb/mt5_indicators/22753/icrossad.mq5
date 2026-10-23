//+------------------------------------------------------------------+
//|                                                     iCrossAD.mq5 |
//|              Copyright 2016, Artem A. Trishkin, Skype artmedia70 |
//|                         https://www.mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Artem A. Trishkin, Skype artmedia70"
#property link      "https://www.mql5.com/ru/users/artmedia70"
#property version   "1.00"
#property description ""
#property strict
//#property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot AD
#property indicator_label1  "AD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ArrowUP
#property indicator_label2  "Arrow to Up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ArrowDN
#property indicator_label3  "Arrow to Down"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#define OP_BUY    0
#define OP_SELL   1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//---
enum ENUM_STYLE
  {
   STYLE_FILL  =  1,    // Fill
   STYLE_FRAME =  0     // Frame
  };
//---
enum ENUM_WIDTH
  {
   WIDTH1      =  1,    // 1
   WIDTH2      =  2,    // 2
   WIDTH3      =  3,    // 3
   WIDTH4      =  4     // 4
  };
//---
enum ENUM_FILTER
  {
   FILTER_NO,           // Without filtration
   FILTER_CCI,          // Filter by CCI
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_LINE_STOCH
  {
   LINE_STOCH_MAIN   =  MAIN_LINE,  // Main Line
   LINE_STOCH_SIG    =  SIGNAL_LINE // Signal Line
  };

//--- input parameters
input ENUM_APPLIED_VOLUME  InpAppliedVolime     =  VOLUME_TICK;         // AD applied volume
input uint                 InpPeriodFind        =  60;                  // Bars for calculate
input uint                 InpUnheckedBars      =  3;                   // Unchecked bars
//---
//input string sep_line_0="-- Filtration --"; //======================================
input ENUM_FILTER          InpFilterBy          =  FILTER_CCI;          // Filtering indicator
input ENUM_INPUT_YES_NO    InpUseDefaultSetting =  INPUT_YES;           // Use settings by default CCI parameters
input uint                 InpPeriodIND         =  14;                  // CCI period
input ENUM_APPLIED_PRICE   InpAppliedPriceCCI   =  PRICE_TYPICAL;       // CCI applied price
//---
//input string sep_line_1="-- Parameters of CCI levels --"; //======================================
input double               InpUpperLevelIND     =  100.0;               // The upper level of the filter indicator
input double               InpLowerLevelIND     = -100.0;               // The lower level of the filter indicator
//---
//input string sep_line_2="-- Graphics Options --"; //======================================
sinput ENUM_INPUT_YES_NO   InpDrawChartsArrow   =  INPUT_YES;           // Draw arrows on chart
sinput ENUM_WIDTH          InpArrowSize         =  WIDTH2;              // The size of the arrows on the chart
sinput color               InpColorBullishArrow =  clrBlue;             // Bullish arrows color
sinput color               InpColorBearishArrow =  clrRed;              // Bearish arrows color
//---
sinput ENUM_INPUT_YES_NO   InpDrawTrendLine     =  INPUT_NO;            // Draw a trend line
sinput ENUM_WIDTH          InpWidthTrendLine    =  WIDTH1;              // Trend line thickness
sinput ENUM_LINE_STYLE     InpStyleTrendLine    =  STYLE_DOT;           // Trend line style
sinput color               InpColorTrendDN      =  clrRed;              // Downtrend line color
sinput color               InpColorTrendUP      =  clrBlue;             // Uptrend line color
//---
sinput ENUM_INPUT_YES_NO   InpDrawArea          =  INPUT_NO;            // Draw the search area
sinput ENUM_STYLE          InpStyleFrame        =  STYLE_FRAME;         // Search area style
sinput ENUM_WIDTH          InpWidthLineArea     =  WIDTH1;              // Search area line width (if Frame mode)
sinput ENUM_LINE_STYLE     InpStyleLineFrame    =  STYLE_SOLID;         // Search area line style (if Frame mode)
sinput color               InpColorArea         =  clrLightSteelBlue;   // Search area color
//--- indicator buffers
double         BufferAD[];
double         BufferUpperArrow[];
double         BufferLowerArrow[];
double         BufferCCI[];
//---
double         BufferPeakUP[][2];   // array of peak up [i][0] - time, [i][1] - value
double         BufferPeakDN[][2];   // array of peak down [i][0] - time, [i][1] - value
//--- Global variables
ENUM_APPLIED_PRICE AppliedPriceCCI;
double         upper_level;
double         lower_level;
int            period_find;         // Number bars for calculate
int            unhecked_bars;       // Unchecked bars
int            period_cci;
bool           checkFilter;
string         prefix;
int            wnd;
int            handle_ad;
int            handle_cci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   AppliedPriceCCI=InpAppliedPriceCCI;
   period_find=int(InpPeriodFind<6 ? 6 : InpPeriodFind);        // Number bars for calculate
   unhecked_bars=int(InpUnheckedBars<2 ? 2 : InpUnheckedBars);  // Unchecked bars
   period_cci=int(InpPeriodIND<1 ? 1 : InpPeriodIND);
   upper_level=InpUpperLevelIND;
   lower_level=InpLowerLevelIND;
   prefix="SCAD("+(string)period_find+")";
   wnd=ChartWindowFind();
   checkFilter=true;
//--- correct input variables
   if(InpUseDefaultSetting) CorrectInputValue(InpFilterBy);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAD);
   SetIndexBuffer(1,BufferUpperArrow);
   SetIndexBuffer(2,BufferLowerArrow);
   SetIndexBuffer(3,BufferCCI);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,241);
   PlotIndexSetInteger(2,PLOT_ARROW,242);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,prefix);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAD,true);
   ArraySetAsSeries(BufferUpperArrow,true);
   ArraySetAsSeries(BufferLowerArrow,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create AD handle
   ResetLastError();
   handle_ad=iAD(NULL,PERIOD_CURRENT,InpAppliedVolime);
   if(handle_ad==INVALID_HANDLE)
     {
      Print("The iAD() by ",EnumToString(InpAppliedVolime)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- create filtering handle
   if(InpFilterBy==FILTER_CCI)
     {
      handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,AppliedPriceCCI);
      if(handle_cci==INVALID_HANDLE)
        {
         Print("The iCCI("+(string)period_cci+") by ",EnumToString(AppliedPriceCCI)," object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete graphics
   ObjectsDeleteAll(0,prefix);
//---
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
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period_find+unhecked_bars+1) return(0);
//---
   int limit=rates_total-prev_calculated;
   if(limit>1) 
     {
      limit=rates_total-period_find-unhecked_bars-1;
      ArrayInitialize(BufferAD,EMPTY_VALUE);
      ArrayInitialize(BufferUpperArrow,EMPTY_VALUE);
      ArrayInitialize(BufferLowerArrow,EMPTY_VALUE);
      ArrayInitialize(BufferCCI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ad,0,0,count,BufferAD);
   if(copied!=count) return 0;
   if(InpFilterBy==FILTER_CCI)
     {
      copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
      if(copied!=count) return 0;
     }

//--- Расчёт индикатора
   string nm="";
   double p1=0, p2=0;
   double value_left_dn=DBL_MAX,value_left_up=-DBL_MAX;
   double value_right_dn=DBL_MAX,value_right_up=-DBL_MAX;
   datetime time_right_dn=0,time_right_up=0;
   int bar_max=0,bar_min=0;
   ArrayResize(BufferPeakUP,0);
   ArrayResize(BufferPeakDN,0);
//--- Main cicle
   for(int i=limit; i>=0; i--) 
     {
      BufferUpperArrow[i]=EMPTY_VALUE;
      BufferLowerArrow[i]=EMPTY_VALUE;
      //--- Finding all the extremums within the period Find. Поиск всех экстремумов в пределах period_find
      int jup=0,jdn=0;
      for(int j=i; j<=i+period_find+unhecked_bars-1; j++) 
        {
         if(j>i+unhecked_bars) 
           {
            //--- Up peacks. вершины
            if(DirectionExtremum(BufferAD[j+1],BufferAD[j],BufferAD[j-1])==OP_SELL) 
              {
               jup++;
               ArrayResize(BufferPeakUP,jup,period_find);
               BufferPeakUP[jup-1][0]=int(time[j]);
               BufferPeakUP[jup-1][1]=BufferAD[j];
              }
            //--- Down peacks. донышки
            if(DirectionExtremum(BufferAD[j+1],BufferAD[j],BufferAD[j-1])==OP_BUY) 
              {
               jdn++;
               ArrayResize(BufferPeakDN,jdn,period_find);
               BufferPeakDN[jdn-1][0]=int(time[j]);
               BufferPeakDN[jdn-1][1]=BufferAD[j];
              }
           }
        }
      //--- Tops within the period Find. Вершины в пределах period_find
      int size_mass_up=ArrayRange(BufferPeakUP,0);
      if(size_mass_up>0) 
        {
         time_right_up=int(BufferPeakUP[0][0]);
         int bar_right_up=BarShift(NULL,PERIOD_CURRENT,time_right_up);
         value_right_up=BufferPeakUP[0][1];
         int index_max=ArrayMaximumInXDimm(BufferPeakUP,1);  // наибольшее значение в массиве
         datetime time_max=int(BufferPeakUP[index_max][0]);
         bar_max=BarShift(NULL,PERIOD_CURRENT,time_max);
         value_left_up=BufferPeakUP[index_max][1];
         if(time_right_up>time_max && BufferAD[bar_max]>value_right_up) 
           {
            for(int k=index_max-0; k>0; k--) 
              {
               int bar_k=BarShift(NULL,PERIOD_CURRENT,datetime(BufferPeakUP[k][0]));
               double virtual_price=EquationDirect(bar_max,value_left_up,bar_right_up,value_right_up,bar_k);
               //--- if the top of crosses the line. если вершина пересекает линию
               if(BufferAD[bar_k]>virtual_price) 
                 {
                  bar_max=BarShift(NULL,PERIOD_CURRENT,int(BufferPeakUP[k][0]));
                  value_left_up=BufferPeakUP[k][1];
                 }
              }
            //--- check the intersection to down. проверка пересечения вниз
            if(EquationDirect(bar_max,value_left_up,bar_right_up,value_right_up,i+1)<BufferAD[i+1] && 
               (EquationDirect(bar_max,value_left_up,bar_right_up,value_right_up,i+2)>=BufferAD[i+2] ||
                EquationDirect(bar_max,value_left_up,bar_right_up,value_right_up,i+3)>=BufferAD[i+3]))
              {
               if(InpFilterBy!=FILTER_NO) 
                 {
                  double filter_1=GetDataIND(InpFilterBy,i+1);
                  double filter_2=GetDataIND(InpFilterBy,i+2);
                  double filter_3=GetDataIND(InpFilterBy,i+3);
                  checkFilter=(filter_1<=lower_level && filter_2<lower_level ? true : false);
                 }
               else checkFilter=true;
               if(checkFilter) 
                 {
                  BufferUpperArrow[i]=BufferAD[i+1];
                  if(InpDrawChartsArrow)
                     SetArrow(prefix+"ChartArrowUP_"+TimeToString(time[i]),InpColorBullishArrow,time[i],open[i],(char)241,ANCHOR_TOP,InpArrowSize);
                 }
              }
           }
        }
      //--- Bottoms within the period Find. Донышки в пределах period_find
      int size_mass_dn=ArrayRange(BufferPeakDN,0);
      if(size_mass_dn>0) 
        {
         time_right_dn=int(BufferPeakDN[0][0]);
         int bar_right_dn=BarShift(NULL,PERIOD_CURRENT,time_right_dn);
         value_right_dn=BufferPeakDN[0][1];
         int index_min=ArrayMinimumInXDimm(BufferPeakDN,1);  // наименьшее значение в массиве
         datetime time_min=int(BufferPeakDN[index_min][0]);
         bar_min=BarShift(NULL,PERIOD_CURRENT,time_min);
         value_left_dn=BufferPeakDN[index_min][1];
         if(time_right_dn>time_min && BufferAD[bar_min]<value_right_dn) 
           {
            for(int k=index_min-0; k>0; k--) 
              {
               int bar_k=BarShift(NULL,PERIOD_CURRENT,datetime(BufferPeakDN[k][0]));
               double virtual_price=EquationDirect(bar_min,value_left_dn,bar_right_dn,value_right_dn,bar_k);
               //--- if the bottom of line crosses. если дно пересекает линию
               if(BufferAD[bar_k]<virtual_price) 
                 {
                  bar_min=BarShift(NULL,PERIOD_CURRENT,int(BufferPeakDN[k][0]));
                  value_left_dn=BufferPeakDN[k][1];
                 }
              }
            //--- check the intersection to up. проверка пересечения вверх
            if(EquationDirect(bar_min,value_left_dn,bar_right_dn,value_right_dn,i+1)>BufferAD[i+1] && 
               (EquationDirect(bar_min,value_left_dn,bar_right_dn,value_right_dn,i+2)<=BufferAD[i+2] ||
               EquationDirect(bar_min,value_left_dn,bar_right_dn,value_right_dn,i+3)<=BufferAD[i+3]))
              {
               if(InpFilterBy!=FILTER_NO) 
                 {
                  double filter_1=GetDataIND(InpFilterBy,i+1);
                  double filter_2=GetDataIND(InpFilterBy,i+2);
                  double filter_3=GetDataIND(InpFilterBy,i+3);
                  checkFilter=(filter_1>=upper_level && filter_2>upper_level ? true : false);
                 }
               else checkFilter=true;
               if(checkFilter) 
                 {
                  BufferLowerArrow[i]=BufferAD[i+1];
                  if(InpDrawChartsArrow)
                     SetArrow(prefix+"ChartArrowDN_"+TimeToString(time[i]),InpColorBearishArrow,time[i],open[i],(char)242,ANCHOR_BOTTOM,InpArrowSize);
                 }
              }
           }
        }
     }
   if(InpDrawArea)
      SetRectangle(prefix+"_range",InpColorArea,time[period_find+unhecked_bars],BufferAD[ArrayMaximum(BufferAD,unhecked_bars,period_find)],time[unhecked_bars],BufferAD[ArrayMinimum(BufferAD,unhecked_bars,period_find)],InpWidthLineArea,InpStyleLineFrame,InpStyleFrame);
   if(InpDrawTrendLine) 
     {
      SetTLine(prefix+"_TLineDN",InpColorTrendDN,time[bar_max],BufferAD[bar_max],time_right_up,BufferPeakUP[0][1],InpWidthTrendLine,InpStyleTrendLine,true);
      SetTLine(prefix+"_TLineUP",InpColorTrendUP,time[bar_min],BufferAD[bar_min],time_right_dn,BufferPeakDN[0][1],InpWidthTrendLine,InpStyleTrendLine,true);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| EquationDirect                                                   |
//| Author KimIV (http://www.kimiv.ru), edited by artmedia70         |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const double bar_to_search) 
  {
   return((right_bar==left_bar) ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
//| DirectionExtremum                                                |
//+------------------------------------------------------------------+
int DirectionExtremum(const double a,const double b,const double c) 
  {
   if((a-b)*(b-c)<0) 
     {
      if(c>b) return(0);
      if(c<b) return(1);
     }
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| ArrayMaximumInXDimm                                              |
//+------------------------------------------------------------------+
int ArrayMaximumInXDimm(const double &array[][2],const int rank_index=1,const int count=0,const int start_find=0) 
  {
   if(ArrayRange(array,0)==0) return(WRONG_VALUE);
   int res=0,num=(count<=0 ? ArrayRange(array,0) : count);
   double value=array[start_find][rank_index];
   for(int i=start_find+1; i<num; i++) 
     {
      if(array[i][rank_index]>value) 
        {
         value=array[i][rank_index];
         res=i;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| ArrayMinimumInXDimm                                              |
//+------------------------------------------------------------------+
int ArrayMinimumInXDimm(const double &array[][2],const int rank_index=1,const int count=0,const int start_find=0) 
  {
   if(ArrayRange(array,0)<=0) return(WRONG_VALUE);
   int res=0,num=(count==0 ? ArrayRange(array,0) : count);
   double value=array[start_find][rank_index];
   for(int i=start_find+1; i<num; i++) 
     {
      if(array[i][rank_index]<value) 
        {
         value=array[i][rank_index];
         res=i;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| SetRectangle                                                     |
//+------------------------------------------------------------------+
void SetRectangle(const string obj_name,const color obj_color,
                  const datetime obj_time1,const double obj_price1,const datetime obj_time2,const double obj_price2,
                  const int obj_width=1,const ENUM_LINE_STYLE obj_style=0,const bool obj_fill=false,const string obj_tooltip="\n") 
  {
   if(ObjectFind(0,obj_name)<0)
      ObjectCreate(0,obj_name,OBJ_RECTANGLE,wnd,0,0,0,0);
   ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,obj_time1);
   ObjectSetDouble(0,obj_name,OBJPROP_PRICE,0,obj_price1);
   ObjectSetInteger(0,obj_name,OBJPROP_TIME,1,obj_time2);
   ObjectSetDouble(0,obj_name,OBJPROP_PRICE,1,obj_price2);
   ObjectSetInteger(0,obj_name,OBJPROP_COLOR,obj_color);
   ObjectSetInteger(0,obj_name,OBJPROP_STYLE,obj_style);
   ObjectSetInteger(0,obj_name,OBJPROP_WIDTH,obj_width);
   ObjectSetInteger(0,obj_name,OBJPROP_FILL,obj_fill);
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,obj_name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,obj_tooltip);
  }
//+------------------------------------------------------------------+
//| SetTLine                                                         |
//+------------------------------------------------------------------+
void SetTLine(const string obj_name,const color obj_color,
              const datetime obj_time1,const double obj_price1,const datetime obj_time2,const double obj_price2,
              const int obj_width=1,const ENUM_LINE_STYLE obj_style=0,const bool obj_ray_right=false,
              const string obj_text="",const string obj_tooltip="\n") 
  {
   if(ObjectFind(0,obj_name)<0)
      ObjectCreate(0,obj_name,OBJ_TREND,wnd,0,0,0,0);
   ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,obj_time1);
   ObjectSetDouble(0,obj_name,OBJPROP_PRICE,0,obj_price1);
   ObjectSetInteger(0,obj_name,OBJPROP_TIME,1,obj_time2);
   ObjectSetDouble(0,obj_name,OBJPROP_PRICE,1,obj_price2);
   ObjectSetInteger(0,obj_name,OBJPROP_COLOR,obj_color);
   ObjectSetInteger(0,obj_name,OBJPROP_RAY_RIGHT,obj_ray_right);
   ObjectSetInteger(0,obj_name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,obj_name,OBJPROP_STYLE,obj_style);
   ObjectSetInteger(0,obj_name,OBJPROP_WIDTH,obj_width);
   ObjectSetString(0,obj_name,OBJPROP_TEXT,obj_text);
   ObjectSetString(0,obj_name,OBJPROP_FONT,"Calibri");
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,obj_name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,obj_tooltip);
  }
//+------------------------------------------------------------------+
//| SetArrow                                                         |
//+------------------------------------------------------------------+
void SetArrow(const string obj_name,const color obj_color,
              const datetime obj_time,const double obj_price,
              const char obj_code,const ENUM_ARROW_ANCHOR obj_anchor,const int obj_size=0,
              const string obj_tooltip="\n") 
  {
   if(ObjectFind(0,obj_name)<0)
      ObjectCreate(0,obj_name,OBJ_ARROW,0,0,0);
   ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,obj_time);
   ObjectSetDouble(0,obj_name,OBJPROP_PRICE,0,obj_price);
   ObjectSetInteger(0,obj_name,OBJPROP_ARROWCODE,obj_code);
   ObjectSetInteger(0,obj_name,OBJPROP_COLOR,obj_color);
   ObjectSetInteger(0,obj_name,OBJPROP_WIDTH,obj_size);
   ObjectSetInteger(0,obj_name,OBJPROP_ANCHOR,obj_anchor);
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,obj_name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,obj_name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,obj_tooltip);
  }
//+------------------------------------------------------------------+
//| GetDataIND                                                       |
//+------------------------------------------------------------------+
double GetDataIND(ENUM_FILTER filtered_indicator,int index) 
  {
   switch(filtered_indicator)
     {
      default: // CCI
         return BufferCCI[index];
      break;
     }
  }
//+------------------------------------------------------------------+
//| CorrectInputValue                                                |
//+------------------------------------------------------------------+
void CorrectInputValue(const ENUM_FILTER filtered_indicator) 
  {
   switch(filtered_indicator)
     {
      default  :        // CCI
         period_cci=14;
         AppliedPriceCCI=PRICE_TYPICAL;
      break;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
