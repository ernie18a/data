//+------------------------------------------------------------------+
//|                                         DailyPivotShift_Full.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- link to the website of the author
#property link      "https://www.metaquotes.net/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- fifteen buffers are used for calculation and drawing the indicator
#property indicator_buffers 15
//---- fifteen plots are used
#property indicator_plots   15
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of the indicator 1 line
#property indicator_color1  Blue
//---- line of the indicator 1 is a continuous line
#property indicator_style1  STYLE_DASHDOTDOT
//---- thickness of the indicator 1 line is equal to 1
#property indicator_width1  1
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- magenta color is used for the indicator 2 line
#property indicator_color2  Magenta
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_DASHDOTDOT
//---- thickness of the indicator 2 line is equal to 1
#property indicator_width2  1
//+----------------------------------------------+
//|  R30 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type3   DRAW_ARROW
//---- use the following color for the indicator line
#property indicator_color3 MediumSeaGreen
//---- the indicator line width
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Pivot R3.0"
//+----------------------------------------------+
//|  R25 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type4   DRAW_ARROW
//---- medium sea green color is used for the indicator
#property indicator_color4 MediumSeaGreen
//---- the indicator line width
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "Pivot R2.5"
//+----------------------------------------------+
//|  R20 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type5   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color5 Lime
//---- the indicator line width
#property indicator_width5  2
//---- displaying the indicator label
#property indicator_label5  "Pivot R2.0"
//+----------------------------------------------+
//|  R15 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type6   DRAW_ARROW
//---- medium sea green color is used for the indicator
#property indicator_color6 MediumSeaGreen
//---- the indicator width
#property indicator_width6  1
//---- displaying the indicator label
#property indicator_label6  "Pivot R1.5"
//+----------------------------------------------+
//|  R10 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type7   DRAW_ARROW
//---- medium sea green color is used for the indicator
#property indicator_color7 MediumSeaGreen
//---- the indicator width
#property indicator_width7  3
//---- displaying the indicator label
#property indicator_label7  "Pivot R1.0"
//+----------------------------------------------+
//|  R05 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type8   DRAW_ARROW
//---- medium sea green color is used for the indicator
#property indicator_color8 MediumSeaGreen
//---- the indicator width
#property indicator_width8  1
//---- displaying the indicator label
#property indicator_label8  "Pivot R0.5"
//+----------------------------------------------+
//|  P level drawing parameters                  |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type9   DRAW_ARROW
//---- use the following color for the indicator line
#property indicator_color9 DarkOrchid
//---- the indicator line width
#property indicator_width9  1
//---- displaying the indicator label
#property indicator_label9  "Pivot P"
//+----------------------------------------------+
//|  S05 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type10   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color10 Red
//---- the indicator line width
#property indicator_width10  1
//---- displaying the indicator label
#property indicator_label10  "Pivot S0.5"
//+----------------------------------------------+
//|  S10 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type11   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color11 Red
//---- the indicator line width
#property indicator_width11  1
//---- displaying the indicator label
#property indicator_label11  "Pivot S1.0"

//+----------------------------------------------+
//|  S15 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type12   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color12 Red
//---- the indicator line width
#property indicator_width12  2
//---- displaying the indicator label
#property indicator_label12  "Pivot S1.5"
//+----------------------------------------------+
//|  S20 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type13   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color13 Magenta
//---- the indicator width
#property indicator_width13  1
//---- displaying the indicator label
#property indicator_label13  "Pivot S2.0"
//+----------------------------------------------+
//|  S25 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type14   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color14 Red
//---- the indicator width
#property indicator_width14  3
//---- displaying the indicator label
#property indicator_label14  "Pivot S2.5"
//+----------------------------------------------+
//|  S30 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type15   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color15 Red
//---- the indicator width
#property indicator_width15  1
//---- displaying the indicator label
#property indicator_label15  "Pivot S3.0"
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int  ShiftTime_=1;
input Number  ExtFormula=Number_0;

input int  Symbol_R30 = 119;        //R30 level label
input int  Symbol_R25 = 158;        //R25 level label
input int  Symbol_R20 = 167;        //R20 level label
input int  Symbol_R15 = 158;        //R15 level label
input int  Symbol_R10 = 108;        //R10 level label
input int  Symbol_R05 = 158;        //R05 level label
input int  Symbol_P   = 167;        //P level label
input int  Symbol_S05 = 158;        //S05 level label
input int  Symbol_S10 = 108;        //S10 level label
input int  Symbol_S15 = 158;        //S15 level label
input int  Symbol_S20 = 167;        //S20 level label
input int  Symbol_S25 = 158;        //S25 level label
input int  Symbol_S30 = 119;        //S30 level label
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double P_Buffer[];
double R05_Buffer[],R10_Buffer[],R15_Buffer[],R20_Buffer[],R25_Buffer[],R30_Buffer[];
double S05_Buffer[],S10_Buffer[],S15_Buffer[],S20_Buffer[],S25_Buffer[],S30_Buffer[];
//----
int  ShiftTime,minbar;
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   minbar=1440*60/PeriodSeconds();
   ShiftTime=ShiftTime_;
   if(MathAbs(ShiftTime)>23) ShiftTime=0;
   Comment("Shift Hours = ",ShiftTime);
   if(ShiftTime<0) ShiftTime=0;
   ShiftTime*=3600;
/*
   int draw_begin;
   if(ExtHowManyDays < 1) draw_begin=0;
   else                   draw_begin=ExtHowManyDays; */
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,0);
//---- performing the shift of the beginning of the indicator drawing
//PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,draw_begin);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer1,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set BearsAroonBuffer dynamic array into an indicator buffer
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,0);
//---- shifting the start of drawing the indicator 2
//PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,draw_begin);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- converting dynamic arrays into indicator buffers
   SetIndexBuffer(2,R30_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,R25_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,R20_Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,R15_Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,R10_Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,R05_Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,P_Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,S05_Buffer,INDICATOR_DATA);
   SetIndexBuffer(10,S10_Buffer,INDICATOR_DATA);
   SetIndexBuffer(11,S15_Buffer,INDICATOR_DATA);
   SetIndexBuffer(12,S20_Buffer,INDICATOR_DATA);
   SetIndexBuffer(13,S25_Buffer,INDICATOR_DATA);
   SetIndexBuffer(14,S30_Buffer,INDICATOR_DATA);

//---- indicator symbols
   PlotIndexSetInteger(2,PLOT_ARROW,Symbol_R30);
   PlotIndexSetInteger(3,PLOT_ARROW,Symbol_R25);
   PlotIndexSetInteger(4,PLOT_ARROW,Symbol_R20);
   PlotIndexSetInteger(5,PLOT_ARROW,Symbol_R15);
   PlotIndexSetInteger(6,PLOT_ARROW,Symbol_R10);
   PlotIndexSetInteger(7,PLOT_ARROW,Symbol_R05);
   PlotIndexSetInteger(8,PLOT_ARROW,Symbol_P);
   PlotIndexSetInteger(9,PLOT_ARROW,Symbol_S05);
   PlotIndexSetInteger(10,PLOT_ARROW,Symbol_S10);
   PlotIndexSetInteger(11,PLOT_ARROW,Symbol_S15);
   PlotIndexSetInteger(12,PLOT_ARROW,Symbol_S20);
   PlotIndexSetInteger(13,PLOT_ARROW,Symbol_S25);
   PlotIndexSetInteger(14,PLOT_ARROW,Symbol_S30);

//---- create label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Pivot R3.0");
   PlotIndexSetString(3,PLOT_LABEL,"Pivot R2.5");
   PlotIndexSetString(4,PLOT_LABEL,"Pivot R2.0");
   PlotIndexSetString(5,PLOT_LABEL,"Pivot R1.5");
   PlotIndexSetString(6,PLOT_LABEL,"Pivot R1.0");
   PlotIndexSetString(7,PLOT_LABEL,"Pivot R0.5");
   PlotIndexSetString(8,PLOT_LABEL,"Pivot P");
   PlotIndexSetString(9,PLOT_LABEL,"Pivot S0.5");
   PlotIndexSetString(10,PLOT_LABEL,"Pivot S1.0");
   PlotIndexSetString(11,PLOT_LABEL,"Pivot S1.5");
   PlotIndexSetString(12,PLOT_LABEL,"Pivot S2.0");
   PlotIndexSetString(13,PLOT_LABEL,"Pivot S2.5");
   PlotIndexSetString(14,PLOT_LABEL,"Pivot S3.0");

//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(R30_Buffer,true);
   ArraySetAsSeries(R25_Buffer,true);
   ArraySetAsSeries(R20_Buffer,true);
   ArraySetAsSeries(R15_Buffer,true);
   ArraySetAsSeries(R10_Buffer,true);
   ArraySetAsSeries(R05_Buffer,true);
   ArraySetAsSeries(P_Buffer,true);
   ArraySetAsSeries(S05_Buffer,true);
   ArraySetAsSeries(S10_Buffer,true);
   ArraySetAsSeries(S15_Buffer,true);
   ArraySetAsSeries(S20_Buffer,true);
   ArraySetAsSeries(S25_Buffer,true);
   ArraySetAsSeries(S30_Buffer,true);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   if(ExtFormula==Number_0)
     {
      IndicatorSetString(INDICATOR_SHORTNAME,"Pivot");
      PlotIndexSetString(0,PLOT_LABEL,"Pivot");
      PlotIndexSetString(1,PLOT_LABEL,NULL);
     }
   else
     {
      IndicatorSetString(INDICATOR_SHORTNAME,"Support&Resistance");
      PlotIndexSetString(0,PLOT_LABEL,"Resistance");
      PlotIndexSetString(1,PLOT_LABEL,"Support");
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   if(_Period>=PERIOD_D1) return(0);
   if(prev_calculated==rates_total) return(rates_total);

   static double yesterday_high,yesterday_low,yesterday_close;
   static double P,S05,R05,S10,R10,S15,R15,S20,R20,S25,R25,S30,R30;
   static double hi=0,lo=100000000;

//---- declarations of local variables 
   int    begin_bar,cnt,day,new_day,minbar_;
   double cl=0,S=0,R=0;

//---- calculate the begin_bar starting index for the loop of bars recalculation and initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      begin_bar=rates_total-1;
   else begin_bar=rates_total-prev_calculated;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- 
   MqlDateTime tm;
   TimeToStruct(time[begin_bar]-ShiftTime,tm);
   new_day=tm.day_of_week;
//----
   minbar_=minbar;
   if(minbar_>=rates_total) minbar_=rates_total-1;

   for(cnt=MathMax(begin_bar,minbar_); cnt>=0; cnt--)
     {
      TimeToStruct(time[cnt]-ShiftTime,tm);
      day=tm.day_of_week;

      if(day==new_day)
        {
         if(high[cnt]>hi) hi=high[cnt];
         if(low[cnt]<lo|| lo==0) lo=low[cnt];
         cl=close[cnt];
        }
      else
        {
         new_day=day;
         if(new_day>0 && new_day<6)
           {
            yesterday_close=cl;
            yesterday_high=hi;
            yesterday_low=lo;
            hi=0;lo=0;
            P = (yesterday_high + yesterday_low + yesterday_close) / 3;
           }

         switch(ExtFormula)
           {
            case 1 :
               R = P + P - yesterday_low;
               S = P + P - yesterday_high;
               break;

            case 2 :
               R = P + yesterday_high - yesterday_low;
               S = P - yesterday_high + yesterday_low;
               break;

            case 3 :
               R = P + P - yesterday_low - yesterday_low + yesterday_high;
               S = P + P - yesterday_high - yesterday_high + yesterday_low;
           }
        }

      if(ExtFormula==0)
        {
         ExtMapBuffer1[cnt]=P;
         ExtMapBuffer2[cnt]=0.0;
        }
      else
        {
         ExtMapBuffer1[cnt]=R;
         ExtMapBuffer2[cnt]=S;
        }

      R10=NormalizeDouble((2*P)-yesterday_low,_Digits);
      S10=NormalizeDouble((2*P)-yesterday_high,_Digits);

      R05 = NormalizeDouble((P+R10)/2,_Digits);
      S05 = NormalizeDouble((P+S10)/2,_Digits);

      R20 = NormalizeDouble(P+(yesterday_high-yesterday_low),_Digits);
      S20 = NormalizeDouble(P-(yesterday_high-yesterday_low),_Digits);

      R15 = NormalizeDouble((R10+R20)/2,_Digits);
      S15 = NormalizeDouble((S10+S20)/2,_Digits);

      R30 = NormalizeDouble(2*P+(yesterday_high-2*yesterday_low),_Digits);
      S30 = NormalizeDouble(2*P-(2*yesterday_high-yesterday_low),_Digits);

      R25 = NormalizeDouble((R20+R30)/2,_Digits);
      S25 = NormalizeDouble((S20+S30)/2,_Digits);

      R30_Buffer[cnt]=R30;
      R25_Buffer[cnt]=R25;
      R20_Buffer[cnt]=R20;
      R15_Buffer[cnt]=R15;
      R10_Buffer[cnt]=R10;
      R05_Buffer[cnt]=R05;

      P_Buffer[cnt]=P;

      S05_Buffer[cnt]=S05;
      S10_Buffer[cnt]=S10;
      S15_Buffer[cnt]=S15;
      S20_Buffer[cnt]=S20;
      S25_Buffer[cnt]=S25;
      S30_Buffer[cnt]=S30;
     }
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
