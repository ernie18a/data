//+------------------------------------------------------------------+
//|                                              ATRStops_v1_HTF.mq5 |
//|                                            Copyright © 2006, NNN |                                     
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2006, "
//--- A link to the author's site
#property link      ""
#property description "ATRStops_v1 indicator from any timeframe"
//--- The indicator version
#property version   "1.00"
//--- The indicator is drawn in the main window
#property indicator_chart_window
//--- 4 buffers are used for the indicator
#property indicator_buffers 4
//--- 4 graphical constructions are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of the bullish indicator         |
//+----------------------------------------------+
//--- Indicator 1 is drawn as a line
#property indicator_type1   DRAW_LINE
//--- Blue is used for the indicator line color
#property indicator_color1  clrBlue
//--- Solid line is used for indicator 1
#property indicator_style1  STYLE_SOLID
//--- The width of the indicator 1 is 2
#property indicator_width1  2
//--- The label of the indicator
#property indicator_label1  "Upper ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bearish indicator         |
//+----------------------------------------------+
//--- Indicator 2 is drawn as a line
#property indicator_type2   DRAW_LINE
//--- IndianRed is used for the indicator line color
#property indicator_color2  clrIndianRed
//--- Solid line is used for indicator 2
#property indicator_style2  STYLE_SOLID
//--- The width of the indicator 2 is 2
#property indicator_width2  2
//--- The label of the indicator
#property indicator_label2  "Lower ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bullish indicator         |
//+----------------------------------------------+
//--- Indicator 3 is drawn as a symbol
#property indicator_type3   DRAW_ARROW
//--- RoyalBlue is used for the indicator line color
#property indicator_color3  clrRoyalBlue
//--- The width of the indicator 3 is 4
#property indicator_width3  4
//--- The label of the indicator
#property indicator_label3  "Buy ATRStops_v1"
//+----------------------------------------------+
//|  Parameters of the bearish indicator         |
//+----------------------------------------------+
//--- Indicator 4 is drawn as a symbol
#property indicator_type4   DRAW_ARROW
//--- DarkOrange is used for the indicator line color
#property indicator_color4  clrDarkOrange
//--- The width of the indicator 4 is 4
#property indicator_width4  4
//--- The label of the indicator
#property indicator_label4  "Sell ATRStops_v1"
//+----------------------------------------------+
//|  Declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // A constant for returning a command to recalculate the indicator to the terminal

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H6; // Chart period of the iSAR indicator
input uint   Length=10;           // Period of the indicator
input uint   ATRPeriod=5;         // Period of the ATR indicator
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- Declaring dynamic arrays that further will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//--- Declaring a variable for storing the indicator initialization result
bool Init;
string Symbol_;
//--- Declaring integer variables for the indicator handles
int Ind_Handle;
//--- Declaring integer variables of the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   Init=true;
//--- Checking correctness of the chart periods
   if(TimeFrame<Period())
     {
      Print("ATRStops_v1 chart period cannot be less than the current chart period");
      Init=false;
      return;
     }

//--- initialization of variables    
   min_rates_total=3;
   Symbol_=Symbol();

//--- Getting the handle of ATRStops_v1
   Ind_Handle=iCustom(Symbol_,TimeFrame,"ATRStops_v1",Length,ATRPeriod,Kv,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of ATRStops_v1");
      Init=false;
      return;
     }

//--- Set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//--- Shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 1 drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---  Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//--- Shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- Set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//--- Shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,163);

//--- Set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//--- Shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- Shifting the beginning of indicator 4 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffers as in timeseries   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//--- Setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,163);

//--- Setting the indicator display accuracy format
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- A name for the data window and a label for sub-windows
   string short_name="ATRStops_v1 HTF";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
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
//--- Checking the number of bars to be enough for the calculation
   if(BarsCalculated(Ind_Handle)<min_rates_total || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//--- declaration of local variables 
   double iUp[1],iDn[1],iBuy[1],iSell[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;

//--- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-2; // starting index for the calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);

//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- Zero out the contents of the indicator buffers for the calculation
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;

      //--- Copy new data to the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- Copy the new data into the array
         if(CopyBuffer(Ind_Handle,0,time[bar],1,iUp)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,iDn)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,time[bar],1,iBuy)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,3,time[bar],1,iSell)<=0) return(RESET);

         ExtMapBufferUp[bar]=iUp[0];
         ExtMapBufferDown[bar]=iDn[0];
         ExtMapBufferUp1[bar]=iBuy[0];
         ExtMapBufferDown1[bar]=iSell[0];

         LastCountBar=bar;
        }

      if(ExtMapBufferUp[bar+1]!=EMPTY_VALUE && ExtMapBufferUp[bar]==EMPTY_VALUE && ExtMapBufferDown[bar]==EMPTY_VALUE)
        {
         ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
        }

      if(ExtMapBufferDown[bar+1]!=EMPTY_VALUE && ExtMapBufferDown[bar]==EMPTY_VALUE && ExtMapBufferUp[bar]==EMPTY_VALUE)
        {
         ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
