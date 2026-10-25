//+---------------------------------------------------------------------+
//|                                            Cronex_T_DeMarker_GF.mq5 |
//|                                            Copyright © 2009, Cronex |
//|                                         https://www.metaquotes.net/ |
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Cronex"
#property link "https://www.metaquotes.net/" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 7
#property indicator_buffers 7 
//---- five plots are used
#property indicator_plots   5
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrIndianRed,clrTeal
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Divergence move Down";"Divergence move Up"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- as the color of the line used
#property indicator_color2 clrBlue
//---- indicator line is a solid curve
#property indicator_style2 STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2 1
//---- displaying label of the signal line
#property indicator_label2  "DeMarker Smoothed"

//---- drawing indicator as a three-colored line
#property indicator_type3 DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color3 clrRed,clrLime
//---- the indicator line is a dash-dotted curve
#property indicator_style3 STYLE_DASHDOTDOT
//---- Indicator line width is equal to 2
#property indicator_width3 2
//---- displaying label of the signal line
#property indicator_label3  "DeMarker Smoothed move Down";"DeMarker Smoothed move Up"

//---- drawing the indicator as a label
#property indicator_type4 DRAW_ARROW
//---- as the color of the line used
#property indicator_color4 clrLime
//---- indicator line width is equal to 1
#property indicator_width4 1
//---- displaying label of the signal line
#property indicator_label4  "Cross Up"

//---- drawing the indicator as a label
#property indicator_type5 DRAW_ARROW
//---- as the color of the line used
#property indicator_color5 clrRed
//---- indicator line width is equal to 1
#property indicator_width5 1
//---- displaying label of the signal line
#property indicator_label5  "Cross Down"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CT3 class variables from the SmoothAlgorithms.mqh file
CT3 T3;
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint DeMarker=24;
input uint  DeMStep=4;
input double b_=61.8; //coefficient x100
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double DiverTBuffer[];
double ColorDiverTBuffer[];
double DeMarkerBuffer[];
double DeMarkerTBuffer[];
double ColorDeMarkerTBuffer[];
double CrossUpTBuffer[];
double CrossDnTBuffer[];
//---- Declaration of integer variables for storing indicator handles
int Ind_Handle[4];
//+------------------------------------------------------------------+    
//| Cronex_T_DeMarker_GF indicator initialization function           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=int(DeMarker+DeMStep*3);
   min_rates_total=min_rates_+1;

//---- getting handle of the iDeMarker 1 indicator
   Ind_Handle[0]=iDeMarker(Symbol(),PERIOD_CURRENT,DeMarker+DeMStep*0);
   if(Ind_Handle[0]==INVALID_HANDLE)Print(" Failed to get handle of iDeMarker 1 indicator");
//---- getting handle of the iDeMarker 2 indicator
   Ind_Handle[1]=iDeMarker(Symbol(),PERIOD_CURRENT,DeMarker+DeMStep*1);
   if(Ind_Handle[1]==INVALID_HANDLE)Print(" Failed to get handle of iDeMarker 2 indicator");
//---- getting handle of the iDeMarker 3 indicator
   Ind_Handle[2]=iDeMarker(Symbol(),PERIOD_CURRENT,DeMarker+DeMStep*2);
   if(Ind_Handle[2]==INVALID_HANDLE)Print(" Failed to get handle of iDeMarker 3 indicator");
//---- getting handle of the iDeMarker 4 indicator
   Ind_Handle[3]=iDeMarker(Symbol(),PERIOD_CURRENT,DeMarker+DeMStep*3);
   if(Ind_Handle[3]==INVALID_HANDLE)Print(" Failed to get handle of iDeMarker 4 indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,DiverTBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting dynamic arrays as indicator buffers and color index buffers
   SetIndexBuffer(0,DiverTBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorDiverTBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,DeMarkerBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DeMarkerTBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ColorDeMarkerTBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,CrossUpTBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,CrossDnTBuffer,INDICATOR_DATA);

//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DiverTBuffer,true);
   ArraySetAsSeries(ColorDiverTBuffer,true);
   ArraySetAsSeries(DeMarkerBuffer,true);
   ArraySetAsSeries(DeMarkerTBuffer,true);
   ArraySetAsSeries(ColorDeMarkerTBuffer,true);
   ArraySetAsSeries(CrossUpTBuffer,true);
   ArraySetAsSeries(CrossDnTBuffer,true);

//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indicators symbols
   PlotIndexSetInteger(3,PLOT_ARROW,108);
   PlotIndexSetInteger(4,PLOT_ARROW,108);

//---- initializations of variable for indicator short name
   string shortname="Cronex_T_DeMarker_GF("+string(DeMarker)+", "+string(DeMStep)+", "+string(b_)+")";

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Cronex_T_DeMarker_GF iteration function                          | 
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
   if(rates_total<min_rates_total
      || BarsCalculated(Ind_Handle[0])<rates_total
      || BarsCalculated(Ind_Handle[1])<rates_total
      || BarsCalculated(Ind_Handle[2])<rates_total
      || BarsCalculated(Ind_Handle[3])<rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,maxbar;
//---- declaration of variables with a floating point  
   double DeMark1[],DeMark2[],DeMark3[],DeMark4[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(DeMark1,true);
   ArraySetAsSeries(DeMark2,true);
   ArraySetAsSeries(DeMark3,true);
   ArraySetAsSeries(DeMark4,true);

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-2; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//----   
   to_copy=limit+1;
   
//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle[0],0,0,to_copy,DeMark1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[1],0,0,to_copy,DeMark2)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[2],0,0,to_copy,DeMark3)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[3],0,0,to_copy,DeMark4)<=0) return(RESET);
   
   maxbar=rates_total-min_rates_total-2;
   
//---- first calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      DeMarkerBuffer[bar]=(DeMark1[bar]+DeMark2[bar]+DeMark3[bar]+DeMark4[bar])*100/4-50;
      DeMarkerTBuffer[bar]=T3.T3Series(maxbar,prev_calculated,rates_total,0,b_,DeMarker,DeMarkerBuffer[bar],bar,true);
      CrossUpTBuffer[bar]=EMPTY_VALUE;
      CrossDnTBuffer[bar]=EMPTY_VALUE;

      if(DeMarkerBuffer[bar+1]<=DeMarkerTBuffer[bar+1] && DeMarkerBuffer[bar]>DeMarkerTBuffer[bar])
         CrossUpTBuffer[bar]=DeMarkerTBuffer[bar];

      if(DeMarkerBuffer[bar+1]>=DeMarkerTBuffer[bar+1] && DeMarkerBuffer[bar]<DeMarkerTBuffer[bar])
         CrossDnTBuffer[bar]=DeMarkerTBuffer[bar];
         
      if(DeMarkerBuffer[bar]<DeMarkerTBuffer[bar]) ColorDeMarkerTBuffer[bar]=0;
      else ColorDeMarkerTBuffer[bar]=1;
      
      DiverTBuffer[bar]=DeMarkerBuffer[bar]-DeMarkerTBuffer[bar];
      if (DeMarkerBuffer[bar]-DeMarkerTBuffer[bar]<DeMarkerBuffer[bar+1]-DeMarkerTBuffer[bar+1]) ColorDiverTBuffer[bar]=0;
      else ColorDiverTBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
