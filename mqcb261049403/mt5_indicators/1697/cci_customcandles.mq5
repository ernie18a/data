//+------------------------------------------------------------------+
//|                                             CCICustomCandles.mq5 |
//|                           Copyright © 2007, Christof Risch (iya) |
//|               http://www.forexfactory.com/showthread.php?t=13321 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Christof Risch (iya)"
#property link "http://www.forexfactory.com/showthread.php?t=13321"
#property description "CCICustomCandles"
//---- indicator version number
#property version   "1.00"
//+------------------------------------------------+
//|  Indicator drawing parameters                  |
//+------------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMagenta,clrDodgerBlue
//---- displaying the indicator label
#property indicator_label1  "CCICandles Open; CCICandles High; CCICandles Low; CCICandles Close"

//+------------------------------------------------+
//|  declaration of constants                      |
//+------------------------------------------------+
#define RESET  0 // The constant for returning the indicator recalculation command to the terminal
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input uint                 CCIPeriod=14;
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;
input int                  Overbought=+100; // overbought level 
input int                  Oversold=-100;   // oversold level
//+------------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- Declaration of integer variables for the indicator handles
int CCI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=int(CCIPeriod);

//---- getting handle of the iCCI indicator
   CCI_Handle=iCCI(NULL,0,CCIPeriod,CCIPrice);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- set ExtColorBuffer[] dynamic array as an indicator color buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="CCICustomCandles";
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
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   double CCI[];

   int limit=rates_total-prev_calculated; // starting number for the calculation of new bars

//---- calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-2; // starting number for calculation of all bars

   int to_copy=limit+1;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(CCI,true);

//---- copy newly appeared data into the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtHighBuffer [bar]=EMPTY_VALUE;
      ExtLowBuffer  [bar]=EMPTY_VALUE;
      ExtOpenBuffer [bar]=EMPTY_VALUE;
      ExtCloseBuffer[bar]=EMPTY_VALUE;

      if(CCI[bar]>Overbought)
        {
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtColorBuffer[bar]=1.0;
        }
      else if(CCI[bar]<Oversold)
        {
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtColorBuffer[bar]=0.0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
