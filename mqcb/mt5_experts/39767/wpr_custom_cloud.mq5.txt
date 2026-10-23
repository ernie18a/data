//+------------------------------------------------------------------+
//|                                             WPR Custom Cloud.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property description "Larry Williams' Percent Range Custom"
#property description "From the advisor you can set: the color of the line, the thickness of the line, the value of two levels"
#property description " - color of the line"
#property description " - thickness of the line"
#property description " - value of two levels"
//---- indicator settings
#property indicator_separate_window
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
#property indicator_maximum    0.0
#property indicator_minimum    -100.0
//---
#property indicator_buffers    5
#property indicator_plots      3
//--- plot WPR
#property indicator_type1      DRAW_LINE
#property indicator_color1     clrDodgerBlue
//--- plot Cloud Up
#property indicator_label2  "Cloud Up"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrLavenderBlush
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Cloud Dn
#property indicator_label3  "Cloud Dn"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  clrAntiqueWhite
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//---- input parameters
input int      Inp_WPR_Period       = 14;             // Period
input color    Inp_WPR_Color        = clrDodgerBlue;  // Color line
input int      Inp_WPR_Width        = 1;              // Width
input double   Inp_WPR_Level1       = -20.0;          // Value Level #1
input double   Inp_WPR_Level2       = -80.0;          // Value Level #2
//---- buffers
double   ExtWPRBuffer[];
double   CloudUpBuffer1[];
double   CloudUpBuffer2[];
double   CloudDnBuffer1[];
double   CloudDnBuffer2[];
//--- global variables
int       ExtPeriodWPR;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(Inp_WPR_Period<3)
     {
      ExtPeriodWPR=14;
      Print("Incorrect InpWPRPeriod value. Indicator will use value=",ExtPeriodWPR);
     }
   else
      ExtPeriodWPR=Inp_WPR_Period;
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"%R"+"("+string(ExtPeriodWPR)+")");
//--- indicator's buffer
   SetIndexBuffer(0,ExtWPRBuffer);
   SetIndexBuffer(1,CloudUpBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,CloudUpBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,CloudDnBuffer1,INDICATOR_DATA);
   SetIndexBuffer(4,CloudDnBuffer2,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtPeriodWPR-1);
//--- Set an empty value
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- digits
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- custom parameters
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,Inp_WPR_Color);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,Inp_WPR_Width);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_WPR_Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_WPR_Level2);
//---
  }
//+------------------------------------------------------------------+
//| Williams’ Percent Range                                          |
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
//---- insufficient data
   if(rates_total<ExtPeriodWPR)
      return(0);
//--- start working
   int i=prev_calculated-1;
//--- correct position
   if(i<ExtPeriodWPR-1)
      i=ExtPeriodWPR-1;
//---  main cycle
   while(i<rates_total && !IsStopped())
     {
      //--- calculate maximum High
      double dMaxHigh=MaxAr(high,ExtPeriodWPR,i);
      //--- calculate minimum Low
      double dMinLow=MinAr(low,ExtPeriodWPR,i);
      //--- calculate WPR
      if(dMaxHigh!=dMinLow)
         ExtWPRBuffer[i]=-(dMaxHigh-close[i])*100/(dMaxHigh-dMinLow);
      else
         ExtWPRBuffer[i]=ExtWPRBuffer[i-1];
      //---
      CloudUpBuffer1[i]=0.0;
      CloudUpBuffer2[i]=ExtWPRBuffer[i];
      CloudDnBuffer1[i]=ExtWPRBuffer[i];
      CloudDnBuffer2[i]=-100.0;
      //--- increment i for next iteration
      i++;
     }
//--- return new prev_calculated value
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Maximum High                                                     |
//+------------------------------------------------------------------+
double MaxAr(const double &array[],int period,int cur_position)
  {
   double Highest=array[cur_position];
   for(int i=cur_position-1; i>cur_position-period; i--)
     {
      if(Highest<array[i])
         Highest=array[i];
     }
   return(Highest);
  }
//+------------------------------------------------------------------+
//| Minimum Low                                                      |
//+------------------------------------------------------------------+
double MinAr(const double &array[],int period,int cur_position)
  {
   double Lowest=array[cur_position];
   for(int i=cur_position-1; i>cur_position-period; i--)
     {
      if(Lowest>array[i])
         Lowest=array[i];
     }
   return(Lowest);
  }
//+------------------------------------------------------------------+
