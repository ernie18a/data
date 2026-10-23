//+------------------------------------------------------------------+
//|                                                       iTrend.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the indicator histogram
#property indicator_color1 DimGray,Lime,MediumSeaGreen,Red,Brown
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "iTrend Histogram"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color2 Blue
//---- the indicator line is a continuous curve
#property indicator_style2 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "iTrend TrendLine"

//---- declaration of the constant for getting the command for the indicator recalculation back to the terminal
#define RESET 0
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum BandsMode //Type of constant
  {
   BASE_LINE_ = 0, //Middle Bollinger
   UPPER_BAND_,    //Upper Bollinger
   LOWER_BAND_     //Lower Bollinger
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int Power_Period=13; //Indicator period
input ENUM_APPLIED_PRICE Power_Price=0; //Indicators price
input ENUM_APPLIED_PRICE Price_Type=0;  //Calculated price
input BandsMode Bands_Mode=BASE_LINE; //Bollinger type
input int Bands_Period=20;   //Bollinger period
input int Bands_Deviation=2; //Number of standard Bollinger deviations
input bool direction=true; //Histogram inversion
//+-----------------------------------+
//---- indicator buffers
double HistBuffer[],ColorHistBuffer[],LineBuffer[];
//---- declaration of integer variables
int Direct;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of variables for the indicators handles
int BandsHandle,BearsHandle,BullsHandle;
//+------------------------------------------------------------------+
//| Histogram coloring                                               |
//+------------------------------------------------------------------+  
void PointHistogram_X5
(const int rates_total,    // number of bars in history at the current tick
 const int prev_calculated,// number of bars calculated at previous call
 int &limit,             // bars counting beginning index
 const double &Buffer[],// indicator buffer for data storage
 double &ColorBuffer[],// indicator buffer for colors storage
 int bar)
  {
//----
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit--;
//---- main cycle of the histogram coloring
   for(bar=limit; bar>=0; bar--)
     {
      ColorHistBuffer[bar]=0;

      if(Buffer[bar]>0)
        {
         if(Buffer[bar]>Buffer[bar+1]) ColorBuffer[bar]=1;
         if(Buffer[bar]<Buffer[bar+1]) ColorBuffer[bar]=2;
        }

      if(Buffer[bar]<0)
        {
         if(Buffer[bar]<Buffer[bar+1]) ColorBuffer[bar]=3;
         if(Buffer[bar]>Buffer[bar+1]) ColorBuffer[bar]=4;
        }
     }
//----
  }
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=MathMax(Power_Period,Bands_Period);
//---- initialize constants  
   Direct=2*direction-1;

//---- get indicator's handle
   BandsHandle=iBands(NULL,0,Bands_Period,0,Bands_Deviation,Power_Price);
   if(BandsHandle==INVALID_HANDLE) Print(" Failed to get handle of the iBands indicator");
//---- get indicator's handle
   BearsHandle=iBearsPower(NULL,0,Power_Period);
   if(BearsHandle==INVALID_HANDLE) Print(" Failed to get handle of the iBearsPower indicator");
//---- get indicator's handle
   BullsHandle=iBullsPower(NULL,0,Power_Period);
   if(BearsHandle==INVALID_HANDLE) Print(" Failed to get handle of the iBullsPower indicator");

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,HistBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(HistBuffer,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorHistBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ColorHistBuffer,true);

//---- set MACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,LineBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LineBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"iTrend( ",Power_Period,", ",Bands_Period,", ",Bands_Deviation," )");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // bars reliable counting beginning index
                const double &price[])     // price array for calculation of the indicator         
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(BandsHandle)<rates_total
      || BarsCalculated(BearsHandle)<rates_total
      || BarsCalculated(BullsHandle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of integer variables
   int to_copy,limit,bar;
//---- declaration of variables with a floating point  
   double Bands[],Bears[],Bulls[];

//---- calculations of the necessary amount of data to be copied and
//---- the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1-begin; // starting index for calculation of all bars
      //---- performing the shift of the beginning of the indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data in the arrays
   if
   (CopyBuffer(BandsHandle,Bands_Mode,0,to_copy,Bands)<=0
    || CopyBuffer(BearsHandle,0,0,to_copy,Bears)<=0
    || CopyBuffer(BullsHandle,0,0,to_copy,Bulls)<=0)
      return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Bands,true);
   ArraySetAsSeries(Bears,true);
   ArraySetAsSeries(Bulls,true);
   ArraySetAsSeries(price,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HistBuffer[bar]=Direct*(price[bar]-Bands[bar]);
      LineBuffer[bar]=Bears[bar]+Bulls[bar];
     }

//---- main cycle of the histogram coloring
   PointHistogram_X5(rates_total,prev_calculated,limit,HistBuffer,ColorHistBuffer,bar);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
