//+------------------------------------------------------------------+
//|                                                          DMA.mq5 |
//|                                      Copyright © 2010, LenIFCHIK |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, LenIFCHIK"
#property link      ""
//---- indicator version number
#property version   "1.00"
#property description "DMA Indicator (Displaced Moving Averages) displays three MA in the main window:"
#property description "                                                                                "
#property description "3-period moving average, shifted forward by three periods (SR DMA);"
#property description "7-period moving average, shifted forward by five periods (MR DMA);"
#property description "25-period moving average, shifted forward by five periods (LR DMA)."

//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use the following color for the indicator line
#property indicator_color1 clrRed
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "SR DMA"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- use the following color for the indicator line
#property indicator_color2 clrBlue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "MR DMA"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- use the following color for the indicator line
#property indicator_color3 clrLime
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "LR DMA"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_MA_METHOD SR_method=MODE_SMA;         //SR MA smoothing type
input uint SR_Period=3;                          //SR MA smoothing period            
input ENUM_APPLIED_PRICE SR_price_=PRICE_CLOSE;  //SR MA price constant
input int SR_Shift=3;                            //horizontal shift of SR MA in bars

input ENUM_MA_METHOD MR_method=MODE_SMA;         //MR MA smoothing type
input uint MR_Period=7;                          //MR MA smoothing period            
input ENUM_APPLIED_PRICE MR_price_=PRICE_CLOSE;  //MR MA price constant
input int MR_Shift=5;                            //horizontal shift of MR MA in bars

input ENUM_MA_METHOD LR_method=MODE_SMA;         //LR MA smoothing type
input uint LR_Period=25;                         //LR MA smoothing period            
input ENUM_APPLIED_PRICE LR_price_=PRICE_CLOSE;  //LR MA price constant
input int LR_Shift=5;                            //horizontal shift of LR MA in bars
//+-----------------------------------+
//---- indicator buffers
double SR_Buffer[],MR_Buffer[],LR_Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//----Declaration of variables for storing the indicators handles
int SR_Handle,MR_Handle,LR_Handle;
//+------------------------------------------------------------------+    
//| KalmanFilter indicator initialization function                   | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(MathMax(SR_Period,MR_Period),LR_Period));

//---- getting handle of the iMA SR indicator
   SR_Handle=iMA(NULL,PERIOD_CURRENT,SR_Period,0,SR_method,SR_price_);
   if(SR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA SR indicator");

//---- getting handle of the iMA MR indicator
   MR_Handle=iMA(NULL,PERIOD_CURRENT,MR_Period,0,MR_method,MR_price_);
   if(MR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA MR indicator");

//---- getting handle of the iMA LR indicator
   LR_Handle=iMA(NULL,PERIOD_CURRENT,LR_Period,0,LR_method,LR_price_);
   if(LR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA LR indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SR_Buffer,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,SR_Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,SR_Period);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SR_Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,MR_Buffer,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(1,PLOT_SHIFT,MR_Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,MR_Period);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MR_Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,LR_Buffer,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(2,PLOT_SHIFT,LR_Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,LR_Period);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LR_Buffer,true);

   string shortname;
   StringConcatenate(shortname,"Displaced Moving Averages(",SR_Period,",",MR_Period,",",LR_Period,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| KalmanFilter iteration function                                  | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking the number of bars to be enough for calculation
   if(BarsCalculated(SR_Handle)<rates_total
      || BarsCalculated(MR_Handle)<rates_total
      || BarsCalculated(LR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy;

//---- calculations of the necessary amount of data to be copied
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      to_copy=rates_total;
     }
   else to_copy=rates_total-prev_calculated+1; // starting index for calculation of new bars

//---- copy newly appeared data into the arrays
   if(CopyBuffer(SR_Handle,0,0,to_copy,SR_Buffer)<=0) return(RESET);
   if(CopyBuffer(MR_Handle,0,0,to_copy,MR_Buffer)<=0) return(RESET);
   if(CopyBuffer(LR_Handle,0,0,to_copy,LR_Buffer)<=0) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
