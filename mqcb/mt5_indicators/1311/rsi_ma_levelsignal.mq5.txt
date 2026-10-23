//+------------------------------------------------------------------+
//|                                           RSI_MA_LevelSignal.mq5 |
//|                                       Copyright © 2009, Helen_Iv |
//|                                      http://helenclubfinance.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, Helen_Iv"
//---- link to the website of the author
#property link      "http://helenclubfinance.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying of the bullish label of the indicator
#property indicator_label1  "RSI_MA_LevelSignal Sell"
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color2  Lime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying of the bearish label of the indicator
#property indicator_label2 "RSI_MA_LevelSignal Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RsiPeriod=7;
input uint Ma1Period=50;
input uint Ma2Period=150;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int Rsi_Handle,Ma1_Handle,Ma2_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=int(MathMax(RsiPeriod+1,MathMax(Ma1Period,Ma2Period)));

//---- getting handle of the iRSI indicator
   Rsi_Handle=iRSI(NULL,0,RsiPeriod,PRICE_CLOSE);
   if(Rsi_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");

//---- getting the iMA1 indicator handle
   Ma1_Handle=iMA(NULL,0,Ma1Period,0,MODE_EMA,PRICE_CLOSE);
   if(Ma1_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA1 indicator");

//---- getting the iMA2 indicator handle
   Ma2_Handle=iMA(NULL,0,Ma2Period,0,MODE_EMA,PRICE_CLOSE);
   if(Ma2_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA2 indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"RSI_MA_LevelSignal Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"RSI_MA_LevelSignal Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="RSI_MA_LevelSignal";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(Rsi_Handle)<rates_total
      || BarsCalculated(Ma1_Handle)<rates_total
      || BarsCalculated(Ma2_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double range,Rsi[],Ma1[],Ma2[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Rsi,true);
   ArraySetAsSeries(Ma1,true);
   ArraySetAsSeries(Ma2,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ma1_Handle,0,0,to_copy,Ma1)<=0) return(RESET);
   if(CopyBuffer(Ma2_Handle,0,0,to_copy,Ma2)<=0) return(RESET);

   to_copy++;
//--- copy newly appeared data in the array
   if(CopyBuffer(Rsi_Handle,0,0,to_copy,Rsi)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      
      range=0.0;
      for(int kkk=bar+9; kkk<=bar; kkk--) range+=MathAbs(high[kkk]-low[kkk]);
      range*=0.2/10.0;


      if (Rsi[bar]>30.0 && Rsi[bar+1]<30.0 && Rsi[bar]>Rsi[bar+1] && Ma1[bar]>Ma2[bar]) BuyBuffer[bar] = low[bar] - range;
      if (Rsi[bar]<70.0 && Rsi[bar+1]>70.0 && Rsi[bar]<Rsi[bar+1] && Ma1[bar]<Ma2[bar]) SellBuffer[bar] = high[bar] + range;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
