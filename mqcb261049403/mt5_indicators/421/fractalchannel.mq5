//+------------------------------------------------------------------+ 
//|                                               FractalChannel.mq5 | 
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1 Lime
//---- indicator line is a dot-dash line
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying of the indicator line label
#property indicator_label1  "Upper FractalChannel"

//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- gray color is used for the indicator line
#property indicator_color2 Gray
//---- indicator line is a dot-dash line
#property indicator_style2  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying of the indicator line label
#property indicator_label2  "Middle FractalChannel"

//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color3 Red
//---- indicator line is a dot-dash line
#property indicator_style3  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying of the indicator line label
#property indicator_label3  "Lower FractalChannel"
//+-----------------------------------+
//|  Indicators input parameters      |
//+-----------------------------------+
enum Type //Type of constant
  {
   Type_1 = 1,     //Type_1
   Type_2,         //Type_2
   Type_3          //Type_3
  };
//----
enum PriceType //Type of constant
  {
   OpenClose,   //OpenClose
   LowHigh      //LowHigh
  };
//----
input Type       ChannelType=Type_1;
input double     Margins=0;
input double     Advance=0;
input PriceType  Prices=OpenClose;
input int        Shift=0; // Horizontal shift of the indicator in bars
//---+
//---- indicator buffers
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//---- Declaration of the integer variables for the start of data calculation
int start=7;
//+------------------------------------------------------------------+    
//| FractalChannel initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set UpperBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//--- creating a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper FractalChannel");
//---- setting values of the indicator that will not be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(UpperBuffer,true);

//---- set MiddleBuffer dynamic array as indicator buffer
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//--- creating a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle FractalChannel");
//---- setting values of the indicator that will not be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(MiddleBuffer,true);

//---- set LowerBuffer dynamic array as indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//--- creating a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower FractalChannel");
//---- setting values of the indicator that will not be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(LowerBuffer,true);

//---- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"FractalChannel( ChannelType = ",ChannelType,
                     ", Prices = ",Prices,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| FractalChannel iteration function                                | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<start) return(0);

//---- indexing elements in arrays, as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- Declaration of variables with a floating point  
   double smax,smin,Low0,Low1,Low2,Low3,Low4,Low5,Low6;
   double High0,High1,High2,High3,High4,High5,High6,v1,v2;
//---- Declaration of integer variables
   int limit,bar;
//---- Declaration of static variables  
   static double smax_,smin_;

//---- calculations of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-start; // starting index for calculation of all bars
      smax_ = 0;
      smin_ = 1000000000000;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- restore values of the variables
   smax = smax_;
   smin = smin_;

//---- Main loop of the indicator calculation    
   for(bar=limit; bar>=0; bar--)
     {
      //---- storing values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         smax_ = smax;
         smin_ = smin;
        }

      v1=-1;
      v2=-1;

      switch(Prices)
        {
         case  OpenClose:
            High0=high[bar+0];
            High1=high[bar+1];
            High2=high[bar+2];
            High3=high[bar+3];
            High4=high[bar+4];
            High5=high[bar+5];
            High6=high[bar+6];

            Low0=low[bar+0];
            Low1=low[bar+1];
            Low2=low[bar+2];
            Low3=low[bar+3];
            Low4=low[bar+4];
            Low5=low[bar+5];
            Low6=low[bar+6];
            break;

         case  LowHigh:
            High0=MathMax(close[bar+0],open[bar+1]);
            High1=MathMax(close[bar+1],open[bar+1]);
            High2=MathMax(close[bar+2],open[bar+2]);
            High3=MathMax(close[bar+3],open[bar+3]);
            High4=MathMax(close[bar+4],open[bar+4]);
            High5=MathMax(close[bar+5],open[bar+5]);
            High6=MathMax(close[bar+6],open[bar+6]);

            Low0=MathMin(close[bar+0],open[bar+1]);
            Low1=MathMin(close[bar+1],open[bar+1]);
            Low2=MathMin(close[bar+2],open[bar+2]);
            Low3=MathMin(close[bar+3],open[bar+3]);
            Low4=MathMin(close[bar+4],open[bar+4]);
            Low5=MathMin(close[bar+5],open[bar+5]);
            Low6=MathMin(close[bar+6],open[bar+6]);
            break;

         default:
            High0=high[bar+0];
            High1=high[bar+1];
            High2=high[bar+2];
            High3=high[bar+3];
            High4=high[bar+4];
            High5=high[bar+5];
            High6=high[bar+6];

            Low0=low[bar+0];
            Low1=low[bar+1];
            Low2=low[bar+2];
            Low3=low[bar+3];
            Low4=low[bar+4];
            Low5=low[bar+5];
            Low6=low[bar+6];
        }

      switch(ChannelType)
        {
         case  Type_1:
           {
            if(High2<=High1 && High0<High1) v1=High1;
            if(Low2 >= Low1 && Low0 > Low1) v2=Low1;
           }
         break;

         case  Type_2:
           {
            if(High4<=High2 && High3<=High2 && High0<High2 && High1<High2) v1=High2;
            if(Low4 >= Low2 && Low3 >= Low2 && Low0 > Low2 && Low1 > Low2) v2=Low2;
           }
         break;

         case  Type_3:
           {
            if(High6<=High3 && High5<=High3 && High4<=High3 && High0<High3 && High1<High3 && High2<High3) v1=High3;
            if(Low6 >= Low3 && Low5 >= Low3 && Low4 >= Low3 && Low0 > Low3 && Low1 > Low3 && Low2 > Low3) v2=Low3;
           }
         break;

         default:
           {
            if(High2<=High1 && High0<High1) v1=High1;
            if(Low2 >= Low1 && Low0 > Low1) v2=Low1;
           }
        }

      if(v1>0) smax=v1;
      if(High0>smax) smax=High0;

      if(v2>0) smin=v2;
      if(Low0<smin) smin=Low0;

      UpperBuffer[bar]=smax-(smax-smin)*Margins;
      LowerBuffer[bar]=smin+(smax-smin)*Margins;
      MiddleBuffer[bar]=(UpperBuffer[bar]+LowerBuffer[bar])/2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
