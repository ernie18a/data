//+------------------------------------------------------------------+
//|                                                      MA_NRTR.mq5 |
//|                                  Copyright © 2012, Ivan Kornilov |
//|                                         E-mail: excelf@gmail.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2012, Ivan Kornilov"
//---- link to the website of the author
#property link "excelf@gmail.com"
//---- indicator version number
#property version   "7.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator line drawing parameters           |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- use DeepPink color for the bearish indicator line
#property indicator_color1  DeepPink
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Upper MA NRTR"
//---- dawing the indicator 2 as a line
//+----------------------------------------------+
//|  Indicator line drawing parameters           |
//+----------------------------------------------+
#property indicator_type2   DRAW_LINE
//---- teal color is used as the color of the bullish line of the indicator
#property indicator_color2  Teal
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying the bearish label of the indicator line
#property indicator_label2  "Lower MA NRTR"
//+----------------------------------------------+
//|  Indicator label drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- spring green color is used as the color of the bullish indicator line
#property indicator_color3  SpringGreen
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- the indicator 3 line width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  " MA NRTR Buy"
//+----------------------------------------------+
//|  Indicator label drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- use red color for the bearish indicator line
#property indicator_color4  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- thickness of the indicator 4 line is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4  " MA NRTR Sell"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int               Length  = 12;             // indicator period
input int              MAShift  = 150;            // vertical shift of MA in points
input ENUM_MA_METHOD MA_Method  = MODE_SMA;       // smoothing method
input bool              OneWay  = true;           // indicator movement without a rollback
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
double SellBuffer[];
double BuyBuffer[];

double MAShift_;
//---- declaration of integer variables for the indicators handles
int MAH_Handle,MAL_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Length+1;

//---- initialization of variables  
   MAShift_=MAShift*_Point;

//---- getting handle of the iMA indicator
   MAH_Handle=iMA(NULL,0,Length,0,MA_Method,PRICE_HIGH);
   if(MAH_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return(1);
     }

//---- getting handle of the iMA indicator
   MAL_Handle=iMA(NULL,0,Length,0,MA_Method,PRICE_LOW);
   if(MAL_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return(1);
     }

//---- set BufferUp dynamic array as indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(UpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set BufferDown dynamic array as indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(DnBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set BufferUp1 dynamic array as indicator buffer
   SetIndexBuffer(2,BuyBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,164);

//---- set BufferDown1 dynamic array as indicator buffer
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,164);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"StepMA NRTR (",Length,", ",MAShift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(MAH_Handle)<rates_total
      || BarsCalculated(MAL_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double up0,down0,trend0,MAH[],MAL[];

   static double up1,down1,trend1;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(MAH,true);
   ArraySetAsSeries(MAL,true);

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total;   // starting index for calculation of all bars
      trend1=0;
      up1=999999999.9999;
      down1=0.0000;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----   
   to_copy=limit+2;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(MAH_Handle,0,0,to_copy,MAH)<=0) return(RESET);
   if(CopyBuffer(MAL_Handle,0,0,to_copy,MAL)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0; bar--)
     {
      UpBuffer[bar]=0.0;
      DnBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      trend0= trend1;
      up0   = MAH[bar+1] + MAShift_;
      down0 = MAL[bar+1] - MAShift_;

      if(OneWay)
        {
         if(trend1==+1&&down0<down1) down0=down1;
         if(trend1==-1&&up0>up1) up0=up1;
        }

      if(high[bar]>up0) trend0=+1;
      if(low[bar]<down0) trend0=-1;

      if(trend0==-1.0) UpBuffer[bar]=up0;
      if(trend0==+1.0) DnBuffer[bar]=down0;

      if(!DnBuffer[bar+1] && DnBuffer[bar]) BuyBuffer[bar]=DnBuffer[bar];
      if(!UpBuffer[bar+1] && UpBuffer[bar]) SellBuffer[bar]=UpBuffer[bar];

      if(bar)
        {
         up1=up0;
         down1=down0;
         trend1=trend0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
