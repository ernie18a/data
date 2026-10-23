//+------------------------------------------------------------------+
//|                                                 ADX Smoothed.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
//---- link to the website of the author
#property link      "https://www.metaquotes.net"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- three buffers are used for calculation and drawing the indicator
#property indicator_buffers 3
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- lime color is used as the color of the indicator bullish line
#property indicator_color1  Lime
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "Di Plus"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bearish indicator line
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "Di Minus"
//+----------------------------------------------+
//|  ADX indicator drawing parameters            |
//+----------------------------------------------+
//---- drawing the indicator 3 as a line
#property indicator_type3   DRAW_LINE
//---- blue color is used for the indicator ADX line
#property indicator_color3  Blue
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator 3 line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator line label
#property indicator_label3  "ADX"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 88.0
#property indicator_level2 50.0
#property indicator_level3 12.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int    period = 14;
input double alpha1 = 0.25;
input double alpha2 = 0.33;
input int    PriceType=0;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double DiPlusBuffer[];
double DiMinusBuffer[];
double ADXBuffer[];
//---- declaration of integer variables for the indicators handles
int ADX_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- getting handle of the ADX indicator
   ADX_Handle=iADX(NULL,0,period);
   if(ADX_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ADX indicator");

//---- initialization of variables of the start of data calculation
   min_rates_total=period+1;

//---- set DiPlusBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,DiPlusBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(DiPlusBuffer,true);

//---- set DiMinusBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,DiMinusBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(DiMinusBuffer,true);

//---- set ADXBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ADXBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ADXBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"ADX(",period,")smothed");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ADX_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double ADX[],DIP[],DIM[],DiPlus,DiMinus,Adx;
   static double DiPlus_,DiMinus_,Adx_;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(ADX,true);
   ArraySetAsSeries(DIP,true);
   ArraySetAsSeries(DIM,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-2; // starting index for calculation of all bars
      DiPlus_=0.0;
      DiMinus_=0.0;
      Adx_=0.0;
      DiPlusBuffer[rates_total-1]=0.0;
      DiMinusBuffer[rates_total-1]=0.0;
      ADXBuffer[rates_total-1]=0.0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+2;

//---- copy newly appeared data in the arrays
   if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(0);
   if(CopyBuffer(ADX_Handle,1,0,to_copy,DIP)<=0) return(0);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,DIM)<=0) return(0);

//---- restore values of the variables
   DiPlus=DiPlus_;
   DiMinus=DiMinus_;
   Adx=Adx_;

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         DiPlus_=DiPlus;
         DiMinus_=DiMinus;
         Adx_=Adx;
        }

      DiPlus=2*DIP[bar]+(alpha1-2)*DIP[bar+1]+(1-alpha1)*DiPlus;
      DiMinus=2*DIM[bar]+(alpha1-2)*DIM[bar+1]+(1-alpha1)*DiMinus;
      Adx=2*ADX[bar]+(alpha1-2)*ADX[bar+1]+(1-alpha1)*Adx;

      DiPlusBuffer[bar]=alpha2*DiPlus+(1-alpha2)*DiPlusBuffer[bar+1];
      DiMinusBuffer[bar]=alpha2*DiMinus+(1-alpha2)*DiMinusBuffer[bar+1];
      ADXBuffer[bar]=alpha2*Adx+(1-alpha2)*ADXBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
