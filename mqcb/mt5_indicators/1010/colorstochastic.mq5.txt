//+------------------------------------------------------------------+
//|                                              ColorStochastic.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Stochastic oscillator is used as a color histogram"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 5 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- the following colors are used in the histogram
#property indicator_color1 Gray,MediumSeaGreen,Blue,Red,Magenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "Main"

//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing of the indicator as a three color line
#property indicator_type2   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color2 Gray,Lime,DeepPink
//---- the indicator line is a stroke
#property indicator_style2  STYLE_DASH
//---- Indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  70.0
#property indicator_level2  50.0
#property indicator_level3  30.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int InpKPeriod=5;  // K period
input int InpDPeriod=3;  // D period
input int InpSlowing=3;  // Slowing
input ENUM_MA_METHOD ma_method=MODE_SMA; // smoothing type
input ENUM_STO_PRICE price_field=STO_LOWHIGH; // stochastic calculation method
input int Shift=0; //horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double UpSTOH[],DnSTOH[],SIGN[];
double ColorSTOH[],ColorSIGN[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int STOH_Handle;
//+------------------------------------------------------------------+   
//| STOH indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=InpKPeriod+InpDPeriod+InpSlowing+1;
   
//---- obtaining the indicators handles  
   STOH_Handle=iStochastic(NULL,0,InpKPeriod,InpDPeriod,InpSlowing,ma_method,price_field);
   if(STOH_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSTOH,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpSTOH,true);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSTOH,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnSTOH,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorSTOH,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorSTOH,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,SIGN,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SIGN,true);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(4,ColorSIGN,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorSIGN,true);

//---- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Stoch("+(string)InpKPeriod+","+(string)InpDPeriod+","+(string)InpSlowing+")");

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| STOH iteration function                                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(STOH_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Declaration of integer variables
   int limit,bar,to_copy;
//---- declaration of variables with a floating point  
   double Stoh[];

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Stoh,true);
  
  to_copy=limit+2;

//--- copy newly appeared data in the array
   if(CopyBuffer(STOH_Handle,MAIN_LINE,0,to_copy,Stoh)<=0) return(RESET);
   if(CopyBuffer(STOH_Handle,SIGNAL_LINE,0,to_copy,SIGN)<=0) return(RESET);
   
//---- Main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Stoh[bar]<50)
        {
         DnSTOH[bar]=Stoh[bar];
         UpSTOH[bar]=50;
        }
      else
        {
         UpSTOH[bar]=Stoh[bar];
         DnSTOH[bar]=50;
        }
     }

   if(!prev_calculated) limit--;

//---- Main loop of the Stoh indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorSTOH[bar]=0;

      if(Stoh[bar]>50)
        {
         if(Stoh[bar]>Stoh[bar+1]) ColorSTOH[bar]=1;
         if(Stoh[bar]<Stoh[bar+1]) ColorSTOH[bar]=2;
        }

      if(Stoh[bar]<50)
        {
         if(Stoh[bar]<Stoh[bar+1]) ColorSTOH[bar]=3;
         if(Stoh[bar]>Stoh[bar+1]) ColorSTOH[bar]=4;
        }
     }

//---- Main loop of the signal line coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorSIGN[bar]=0;
      if(Stoh[bar]>SIGN[bar+1]) ColorSIGN[bar]=1;
      if(Stoh[bar]<SIGN[bar+1]) ColorSIGN[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
