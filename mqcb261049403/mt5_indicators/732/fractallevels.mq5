//+------------------------------------------------------------------+
//|                                                FractalLevels.mq5 |
//|                                        Copyright © 2008, lotos4u |
//|                                                lotos4u@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, lotos4u"
#property link      "lotos4u@gmail.com"
#property description "Fractal Levels"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- 6 buffers are used for calculation and drawing the indicator
#property indicator_buffers 6
//---- 6 graphical plots are used
#property indicator_plots   6
//+--------------------------------------------+
//|  Declaration of constants                  |
//+--------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- lime color is used as the color of the indicator line
#property indicator_color1  Lime
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Fractal resistance"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used for the indicator line
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Fractal support"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- blue color is used for the indicator
#property indicator_color3  Blue
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "UPWARD fractal"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color4  Magenta
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label2 "DOWNWARD fractal"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 5 as a symbol
#property indicator_type5   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color5  Lime
//---- indicator 5 width is equal to 4
#property indicator_width5  4
//---- displaying the indicator label
#property indicator_label5  "UPWARD breakout"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 6 as a symbol
#property indicator_type6   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color6  Red
//---- indicator 6 width is equal to 4
#property indicator_width6  4
//---- displaying the indicator label
#property indicator_label6 "Пробой ВНИЗ"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint LeftBars_  = 3;
input uint RightBars_ = 3;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double LineUpBuffer[];
double LineDownBuffer[];
double ArrowUpBuffer[];
double ArrowDownBuffer[];
double ArrowBreakUpBuffer[];
double ArrowBreakDownBuffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
uint LeftBars,RightBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables
   LeftBars=LeftBars_;
   RightBars=RightBars_;
   if(LeftBars<2) LeftBars=2;
   if(RightBars<2) RightBars=2;
   min_rates_total=int(LeftBars+RightBars+1);

//---- set LineUpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,LineUpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LineUpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set LineDownBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,LineDownBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LineDownBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set ArrowUpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ArrowUpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,119);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ArrowUpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set ArrowDownBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ArrowDownBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,119);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ArrowDownBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set ArrowBreakUpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(4,ArrowBreakUpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(4,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ArrowBreakUpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

//---- set ArrowBreakDownBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(5,ArrowBreakDownBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(5,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ArrowBreakDownBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Fractal Levels";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Searching for the upper fractal                                  |
//+------------------------------------------------------------------+
double isFractalUp(int index,int lBars,int rBars,const double &High[])
  {
//----   
   int start=index-rBars;
   int end=index+lBars+1;
   //--- High price value of the analyzed bar is taken as the maximum
   double max=High[index]; 

   for(int i=start; i<end; i++)
      if(max<High[i] && i!=index)
        {
         if(max<High[i]) return(0);
         if(MathAbs(i-index)>1) return(0);
        }
//----
   return(max);
  }
//+------------------------------------------------------------------+
//| Searching for the lower fractal                                  |
//+------------------------------------------------------------------+
double isFractalDown(int index,int lBars,int rBars,const double &Low[])
  {
//----   
   int start=index-rBars;
   int end=index+lBars+1;
   //--- Low price value of the analyzed bar is taken as the minimum
   double min=Low[index]; 

   for(int i=start; i<end; i++)
      if(min>Low[i] && i!=index)
        {
         if(min>Low[i]) return(0);
         if(MathAbs(i-index)>1) return(0);
        }
//----
   return(min);
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total)return(RESET);

//---- declaration of local variables 
   int limit,bar;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop

   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1;                 // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ArrowUpBuffer[bar]=0.0;
      ArrowDownBuffer[bar]=0.0;
      ArrowBreakUpBuffer[bar]=0.0;
      ArrowBreakDownBuffer[bar]=0.0;

      if(bar<int(RightBars))
        {
         LineUpBuffer[bar]=LineUpBuffer[bar+1];
         LineDownBuffer[bar]=LineDownBuffer[bar+1];
         continue;
        }

      LineUpBuffer[bar]=isFractalUp(bar,LeftBars,RightBars,high);

      if(!LineUpBuffer[bar]) LineUpBuffer[bar]=LineUpBuffer[bar+1];
      else ArrowUpBuffer[bar]=LineUpBuffer[bar];

      LineDownBuffer[bar]=isFractalDown(bar,LeftBars,RightBars,low);

      if(!LineDownBuffer[bar]) LineDownBuffer[bar]=LineDownBuffer[bar+1];
      else ArrowDownBuffer[bar]=LineDownBuffer[bar];

      if(close[bar]>LineUpBuffer[bar]   && close[bar+1]<=LineUpBuffer[bar+1]  ) ArrowBreakUpBuffer[bar]=close[bar];
      if(close[bar]<LineDownBuffer[bar] && close[bar+1]>=LineDownBuffer[bar+1]) ArrowBreakDownBuffer[bar]=close[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
