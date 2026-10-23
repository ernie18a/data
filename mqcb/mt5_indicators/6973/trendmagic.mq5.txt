//+------------------------------------------------------------------+
//|                                                   TrendMagic.mq5 |
//|                                 Copyright © 2014, Sergey Gritsai |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Sergey Gritsai"
#property link "sergey1294@list.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//| Indicator drawing parameters      |
//+-----------------------------------+
//--- drawing the indicator as a multicolored line
#property indicator_type1   DRAW_COLOR_LINE
//--- the following colors are used in a three-color line
#property indicator_color1  clrGreen,clrMagenta
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "TrendMagic"
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint CCI_Period=50;                         // CCI period
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN; // CCI price
input uint ATR_Period=5;                          // ATR period
input int Shift=0;                                // Horizontal shift of the indicator in bars
input int PriceShift=0;                           // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- declaring the variable of the value of the MA vertical shift
double dPriceShift;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int CCI_Handle,ATR_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_total=int(MathMax(CCI_Period,ATR_Period));
//---- getting handle of the iCCI indicator
   CCI_Handle=iCCI(NULL,0,CCI_Period,CCIPrice);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iCCI indicator");
      return(INIT_FAILED);
     }
//--- getting handle of the iATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the iATR indicator handle");
      return(INIT_FAILED);
     }
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   string shortname;
//--- initializations of a variable for the indicator short name
   StringConcatenate(shortname,"TrendMagic(",CCI_Period,", ",ATR_Period,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double CCI[],ATR[];
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-2; // Starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(CCI[bar]>=0.0)
        {
         IndBuffer[bar]=low[bar]-ATR[bar]+PriceShift;
         if(IndBuffer[bar]<IndBuffer[bar+1]) IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=0.0;
        }
      else if(CCI[bar]<0.0)
        {
         IndBuffer[bar]=high[bar]+ATR[bar]+PriceShift;
         if(IndBuffer[bar]>IndBuffer[bar+1]) IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=1.0;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
