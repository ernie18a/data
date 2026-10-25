//+------------------------------------------------------------------+
//|                                       PastRegressionDeviated.mq5 | 
//|                Copyright © 2006, tageiger, aka fxid10t@yahoo.com |
//|                                                fxid10t@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger, aka fxid10t@yahoo.com"
#property link      "fxid10t@yahoo.com"
#property description "past regression deviated"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 7 
//---- 7 graphical plots are used
#property indicator_plots   7
//+--------------------------------------------+
//|  Indicator drawing parameters              |
//+--------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type4   DRAW_LINE
//---- medium violet red color is used for the indicator line
#property indicator_color4 MediumVioletRed
//---- the indicator line is a dash-dotted curve
#property indicator_style4  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "past regression deviated"
//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//---- selection of levels colors
#property indicator_color1  DarkViolet
#property indicator_color2  Orange
#property indicator_color3  Teal
#property indicator_color5  Teal
#property indicator_color6  Orange
#property indicator_color7  DarkViolet
//---- levels are dott-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
//---- levels width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
//---- display levels labels
#property indicator_label1  "3st Std up"
#property indicator_label2  "2st Std up"
#property indicator_label3  "1st Std up"
#property indicator_label5  "1st Std down"
#property indicator_label6  "2st Std down"
#property indicator_label7  "3st Std down"
//+--------------------------------------------+ 
//| Enumeration for the level width            |
//+--------------------------------------------+ 
enum ENUM_WIDTH // Type of constant
  {
   w_1 = 1,   // 1
   w_2,       // 2
   w_3,       // 3
   w_4,       // 4
   w_5        // 5
  };
//+--------------------------------------------+
//|  Indicator input parameters                |
//+--------------------------------------------+
//---- input parameters
int period=0;
input int Length=55;                          // Amount of bars for regression
input double StdChannel1=1;                   // 1st channel
input double StdChannel2=2;                   // 2nd channel
input double StdChannel3=3;                   // 3rd channel
input int Shift=0;                            // Horizontal shift of the indicator in bars
input color Line_color=Red;                   // Trend line color
input ENUM_LINE_STYLE Line_style=STYLE_SOLID; // Trend line style
input ENUM_WIDTH Line_width=w_3;              // Trend line width
//+--------------------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double MeanBuffer[];
//---- declaration of dynamic arrays that
//---- will be used as levels indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[];
double ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];

//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,   // chart ID
                 string   name,       // object name
                 int      nwin,       // window index
                 datetime time1,      // price level time 1
                 double   price1,     // price level 1
                 datetime time2,      // price level time 2
                 double   price2,     // price level 2
                 color    Color,      // line color
                 int      style,      // line style
                 int      width,      // line width
                 string   text)       // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
// ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
// ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,   // chart ID
              string   name,       // object name
              int      nwin,       // window index
              datetime time1,      // price level time 1
              double   price1,     // price level 1
              datetime time2,      // price level time 2
              double   price2,     // price level 2
              color    Color,      // line color
              int      style,      // line style
              int      width,      // line width
              string   text)       // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Length+1;

//---- set MeanBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,MeanBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(MeanBuffer,true);

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);

//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indexing the elements in buffers as timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Past regression deviated(",
                     Length,", ",StdChannel1,", ",StdChannel2,", ",StdChannel3,", ",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- delete the level, if necessary
   ObjectDelete(0,string(period)+"m "+string(Length)+" TL");
//----
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,bar,StartBar,EndBar,n;
   double value,a,b,c,sumy,sumx,sumx2,sumxy,X,StdDev,SumSquared;
   double Price1,Price2;
   string name;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      StartBar=bar+Length;
      EndBar=bar;
      n=StartBar-EndBar+1;
      value=close[EndBar];
      sumy=value;
      sumx=0.0;
      sumxy=0.0;
      sumx2=0.0;

      for(int ii=1; ii<n; ii++)
        {
         value=close[EndBar+ii];
         sumy+=value;
         sumxy+=value*ii;
         sumx+=ii;
         sumx2+=ii*ii;
        }
      c=sumx2*n-sumx*sumx;
      if(c==0.0) return(0);
      b=(sumxy*n-sumx*sumy)/c;
      a=(sumy-sumx*b)/n;
      Price2=a;
      Price1=a+b*n;
      MeanBuffer[bar]=NormalizeDouble(Price2,_Digits);

      name=string(period)+"m "+string(Length)+" TL";
      SetTline(0,name,0,time[StartBar],Price1,time[EndBar],Price2,Line_color,Line_style,Line_width,name);

      X=0;
      StdDev=0;
      SumSquared=0;

      for(int iii=bar; iii<StartBar; iii++)
        {
         X=MathAbs(close[iii]-ObjectGetValueByTime(0,name,time[iii],0));
         SumSquared+=(X*X);
        }

      StdDev=MathSqrt(SumSquared/((StartBar-EndBar)-1));

      ExtLineBuffer1[bar]=MeanBuffer[bar]+StdChannel1*StdDev;
      ExtLineBuffer2[bar]=MeanBuffer[bar]+StdChannel2*StdDev;
      ExtLineBuffer3[bar]=MeanBuffer[bar]+StdChannel3*StdDev;
      ExtLineBuffer4[bar]=MeanBuffer[bar]-StdChannel1*StdDev;
      ExtLineBuffer5[bar]=MeanBuffer[bar]-StdChannel2*StdDev;
      ExtLineBuffer6[bar]=MeanBuffer[bar]-StdChannel3*StdDev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
