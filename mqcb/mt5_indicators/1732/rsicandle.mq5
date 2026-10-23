//+------------------------------------------------------------------+
//|                                                    RSICandle.mq5 |
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "RSICandle Smoothed"
//---- Indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- The indicator is drawn in a separate window
#property indicator_separate_window
//---- Five buffers are used for the indicator calculation and drawing
#property indicator_buffers 5
//---- Only one graphical construction is used
#property indicator_plots   1
//---- The indicator is implemented as colored candlesticks
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrDeepPink,clrBlue,clrTeal
//---- Label of the indicator
#property indicator_label1  "RSICandle Open;RSICandle High;RSICandle Low;RSICandle Close"
//+----------------------------------------------+
//| Parameters for horizontal levels             |
//+----------------------------------------------+
#property indicator_level1  75
#property indicator_level2  50
#property indicator_level3  25
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET  0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RSI_Period=14;
//+----------------------------------------------+

//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];

//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//---- Declaring integer variables for the indicator handles
int RSI_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of global variables 
   min_rates_total=int(RSI_Period);
   
//---- Getting the handle of the iRSI indicator
   RSI_Handle[0]=iRSI(NULL,0,RSI_Period,PRICE_OPEN);
   if(RSI_Handle[0]==INVALID_HANDLE) Print(" Failed to get the handle of iRSI["+string(0)+"]!");
   
   RSI_Handle[1]=iRSI(NULL,0,RSI_Period,PRICE_HIGH);
   if(RSI_Handle[1]==INVALID_HANDLE) Print(" Failed to get the handle of iRSI["+string(1)+"]!");
   
   RSI_Handle[2]=iRSI(NULL,0,RSI_Period,PRICE_LOW);
   if(RSI_Handle[2]==INVALID_HANDLE) Print(" Failed to get the handle of iRSI["+string(2)+"]!");
   
   RSI_Handle[3]=iRSI(NULL,0,RSI_Period,PRICE_CLOSE);
   if(RSI_Handle[3]==INVALID_HANDLE) Print(" Failed to get the handle of iRSI["+string(3)+"]!");

//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
   
//---- Indexing buffer elements as timeseries
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

/ / ---- Setting the recording fidelity of the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- A name for the data window and a label for sub-windows 
   string short_name="RSICandl";
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
//---- Checking if the number of bars is enough for the calculation
   if(BarsCalculated(RSI_Handle[0])<rates_total
      || BarsCalculated(RSI_Handle[1])<rates_total
      || BarsCalculated(RSI_Handle[2])<rates_total
      || BarsCalculated(RSI_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar;

//---- Calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1; // Starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
     
   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,ExtCloseBuffer)<=0) return(RESET);


//---- he main loop for corrections and candlestick coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
