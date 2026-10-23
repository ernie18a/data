//+------------------------------------------------------------------+
//|                                                   FlatTrend2.mq4 |
//|                                     Copyright © 2007, Kirk Sloan |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Kirk Sloan"
#property link      "http://www.metaquotes.ru/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used for the indicator diagram
#property indicator_color1 Gray,Red,Brown,Green,Lime
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "FlatTrend"
//+----------------------------------------------+
//| Indicator window size limitation             |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint   ADXPeriod= 14;   // ADX period
input double SarStep=0.02;    // Parabolic step
input double SarMaximum=0.2;  // Parabolic maximum
//+----------------------------------------------+
//---- indicator buffers
double IndBuffer[],ColorBuffer[];
//---- declaration of integer variables for the indicators handles
int SAR_Handle,ADX_Handle;
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+    
//| FlatTrend2 indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(ADXPeriod);

//---- getting handle of the iSAR indicator
   SAR_Handle=iSAR(NULL,PERIOD_CURRENT,SarStep,SarMaximum);
   if(SAR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iSAR indicator");

//---- getting handle of the iADX indicator
   ADX_Handle=iADX(NULL,PERIOD_CURRENT,ADXPeriod);
   if(ADX_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iADX indicator");

//---- set FlatTrend2Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- set ColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ColorBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"FlatTrend2( ",ADXPeriod,", ",SarStep,SarMaximum," )");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| FlatTrend2 iteration function                                    | 
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
   if(BarsCalculated(SAR_Handle)<rates_total
      || BarsCalculated(ADX_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double SAR[],ADXP[],ADXM[];

//--- calculations of the necessary amount of data to be copied and
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total+1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 
   to_copy=limit+1;

//---- copy newly appeared data in the SAR array
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SAR)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,1,0,to_copy,ADXP)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,ADXM)<=0) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(SAR,true);
   ArraySetAsSeries(ADXP,true);
   ArraySetAsSeries(ADXM,true);
   ArraySetAsSeries(close,true);

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      IndBuffer[bar]=1;
      ColorBuffer[bar]=0;
      if(SAR[bar]<close[bar] && ADXP[bar]>ADXM[bar]) ColorBuffer[bar]=3;
      if(SAR[bar]<close[bar] && ADXM[bar]>ADXP[bar]) ColorBuffer[bar]=4;
      if(SAR[bar]>close[bar] && ADXM[bar]>ADXP[bar]) ColorBuffer[bar]=2;
      if(SAR[bar]>close[bar] && ADXP[bar]>ADXM[bar]) ColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
