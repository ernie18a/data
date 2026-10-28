//+------------------------------------------------------------------------+ 
//|                                                         Val_Bands.mq5  | 
//|                                             Copyright © 2010, Fomenko  | 
//|                                                http://faa1947@mail.ru  | 
//+------------------------------------------------------------------------+
//|   Candlesticks length volatility indicator:                            |
//|      - histogram - candlestick length in pips;                         |
//|      - lines are averages from the candlesticks length with standard   |
//|        deviation;                                                      |
//|    Settings are analogous to the Bollinger Channel;                    |
//|    Usage. It is useful for tracking gaps on the market. The gap        |
//|                     contains everything that is above the yellow line; |
//|      - crossing the upper border - а) ТР (towards a position);         |
//|                                    b) SL (against a position);         | 
//|                                    c) entry prohibition at this point; |
//|      - crossing the lower border - flat;                               |
//|      - crossing the lower border upwards - beginning of a trend.       |
//+------------------------------------------------------------------------+
#property copyright "Copyright © 2010, Fomenko"
#property link      "http://faa1947@mail.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- four plots are used in total
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color1 Gray,Red,Lime,Yellow
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Val Histogram"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- lime color is used for the line
#property indicator_color2 Lime
//---- the indicator line is a dash-dotted curve
#property indicator_style2 STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width2 1
//---- displaying the line label
#property indicator_label2  "Mov"

//---- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//---- yellow color is used for the line
#property indicator_color3 Yellow
//---- the indicator line is a dash-dotted curve
#property indicator_style3 STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width3 1
//---- displaying the line label
#property indicator_label3  "Up"

//---- drawing the indicator as a line 
#property indicator_type4 DRAW_LINE 
//---- use red color for the line
#property indicator_color4 Red
//---- the indicator line is a dash-dotted curve
#property indicator_style4 STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width4 1
//---- displaying the line label
#property indicator_label4  "Down"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal

//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int BandsPeriod=14;         // Calculation period
input double BandsDeviations=1.0; // Standard deviation size
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int HMA_Handle,LMA_Handle;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double UpBuffer[],DownBuffer[],MaBuffer[],ValBuffer[],ColorValBuffer[];
//+------------------------------------------------------------------+    
//| Val_Bands indicator initialization function                      | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=BandsPeriod;

//---- getting handle of the iMA indicator
   HMA_Handle=iMA(NULL,0,BandsPeriod,0,MODE_SMA,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iMA indicator
   LMA_Handle=iMA(NULL,0,BandsPeriod,0,MODE_SMA,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- set ValBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ValBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ValBuffer,true);

//---- set ColorValBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorValBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ColorValBuffer,true);

//---- set MABuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,MaBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(MaBuffer,true);

//---- set UpBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,UpBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(UpBuffer,true);

//---- set DownBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(4,DownBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(DownBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Val_Bands( ",BandsPeriod,", ",BandsDeviations," )");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Val_Bands iteration function                                     | 
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
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declarations of local variables 
   int to_copy,limit,bar,k;
   double HMA[],LMA[];
   double sum,oldval,newres,deviation;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total;                 // calculated number of all bars
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;  // starting index for calculation of new bars
      to_copy=limit+1;                    // calculated number of new bars only
     }

//--- copy newly appeared data in the arrays
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ValBuffer[bar]=(high[bar]-low[bar])/_Point;
      MaBuffer[bar]=(HMA[bar]-LMA[bar])/_Point;
     }

//---- the second indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      sum=0.0;
      k=bar+BandsPeriod-1;
      oldval=MaBuffer[bar];

      while(k>=bar)
        {
         newres=ValBuffer[k]-oldval;
         sum+=newres*newres;
         k--;
        }

      deviation=BandsDeviations*MathSqrt(sum/BandsPeriod);
      UpBuffer[bar]=oldval+deviation;
      DownBuffer[bar]=oldval-deviation;

      ColorValBuffer[bar]=0;

      if(ValBuffer[bar]>UpBuffer[bar]) ColorValBuffer[bar]=3;
      else if(ValBuffer[bar]>MaBuffer[bar]) ColorValBuffer[bar]=2;
      else if(ValBuffer[bar]>DownBuffer[bar]) ColorValBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
