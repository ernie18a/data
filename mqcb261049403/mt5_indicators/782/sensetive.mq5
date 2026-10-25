//+------------------------------------------------------------------+
//|                                                    SeNSetiVe.mq5 | 
//|                                     Copyright © 2006, QuantifiEd |
//|                                       E-mail: MySpons@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, QuantifiEd"
#property link      "E-mail: MySpons@rambler.ru"
#property description "SeNSetiVe"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  StepRSI indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- Blue and Magenta colors are used for the indicator
#property indicator_color1  Blue,Magenta
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "SeNSetiVe"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint SPerioD=150;                            // Indicator period
input uint SFactoR=7;                              // Indicator sensitivity
input int Shift=0;                                 // Horizontal shift of the indicator in bars 
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double Line1Buffer[];
double Line2Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int MAO_Handle,MAC_Handle,MAH_Handle,MAL_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(SFactoR+SPerioD);

//---- getting handle of the iMA indicator
   MAO_Handle=iMA(NULL,0,SPerioD,0,MODE_SMA,PRICE_OPEN);
   if(MAO_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iMA indicator
   MAC_Handle=iMA(NULL,0,SPerioD,0,MODE_SMA,PRICE_CLOSE);
   if(MAC_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iMA indicator
   MAH_Handle=iMA(NULL,0,SPerioD,0,MODE_SMA,PRICE_HIGH);
   if(MAH_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iMA indicator
   MAL_Handle=iMA(NULL,0,SPerioD,0,MODE_SMA,PRICE_LOW);
   if(MAL_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- set Line1Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Line1Buffer,true);

//---- set Line2Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Line2Buffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"SeNSetiVe(",SPerioD,", ",SFactoR,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
   if(BarsCalculated(MAO_Handle)<rates_total
      || BarsCalculated(MAC_Handle)<rates_total
      || BarsCalculated(MAH_Handle)<rates_total
      || BarsCalculated(MAL_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declarations of local variables 
   int limit,to_copy,bar;
   double sOpen[],sClose[],sLow[],sHigh[],max,min;
   long volume_;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-1;                 // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
   to_copy=limit+1;

//--- copy newly appeared data in the arrays
   if(CopyBuffer(MAO_Handle,0,0,to_copy,sOpen)<=0) return(RESET);
   if(CopyBuffer(MAC_Handle,0,0,to_copy,sClose)<=0) return(RESET);
   if(CopyBuffer(MAH_Handle,0,0,to_copy,sLow)<=0) return(RESET);
   if(CopyBuffer(MAL_Handle,0,0,to_copy,sHigh)<=0) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(sOpen,true);
   ArraySetAsSeries(sClose,true);
   ArraySetAsSeries(sLow,true);
   ArraySetAsSeries(sHigh,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else                        ArraySetAsSeries(volume,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      max=high[ArrayMaximum(high,bar,SFactoR)];
      min=low [ArrayMinimum(low, bar,SFactoR)];

      if(VolumeType==VOLUME_TICK) volume_=long(tick_volume[bar]);
      else                        volume_=long(volume[bar]);

      Line1Buffer[bar]=(5*sClose[bar]-5*sOpen[bar]+max+min-sHigh[bar]-sLow[bar])*volume_;
      Line2Buffer[bar]=0.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
