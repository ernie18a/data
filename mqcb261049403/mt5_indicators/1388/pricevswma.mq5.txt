//+------------------------------------------------------------------+
//|                                                   PriceVSwma.mq5 |
//|                                        Copyright © 2007, perky_z |
//|                                                perky_z@yahoo.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, perky_z"
//---- author of the indicator
#property link      "perky_z@yahoo.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  PriceVSwma indicator drawing parameters     |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DarkOrange color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDarkOrange
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "PriceVSwma"
//+----------------------------------------------+
//|  Signal line drawing parameter               |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- BlueViolet color is used for the indicator bearish line
#property indicator_color2  clrBlueViolet
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Signal PriceVSwma"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 +70.0
#property indicator_level2 +30.0
#property indicator_levelcolor clrTeal
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint InpKPeriod1=8;  // K period 1
input uint InpDPeriod1=3;  // D period 1
input uint InpKPeriod2=89; // K period 2
input uint InpDPeriod2=21; // D period 2
input uint InpKPeriod3=55; // K period 3
input uint InpDPeriod3=13; // D period 3
input uint InpKPeriod4=34; // K period 4
input uint InpDPeriod4=8;  // D period 4
input uint InpKPeriod5=21; // K period 5
input uint InpDPeriod5=5;  // D period 5
input uint InpSlowing=3;   // Slowing
input ENUM_MA_METHOD ma_method=MODE_SMA; // smoothing type
input ENUM_STO_PRICE price_field=STO_LOWHIGH; // stochastic calculation method
input uint Smoothing=15;   // indicator smoothing
input uint Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double SignBuffer[];
//---- Declaration of integer variables for the indicator handles
int CP_Handle;
//---- Declaration of integer variables for the indicator handles
int STOH_Handle[5];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   uint min_rates[5];
   min_rates[0]=InpKPeriod1+InpDPeriod1+InpSlowing;
   min_rates[1]=InpKPeriod2+InpDPeriod2+InpSlowing;
   min_rates[2]=InpKPeriod3+InpDPeriod3+InpSlowing;
   min_rates[3]=InpKPeriod4+InpDPeriod4+InpSlowing;
   min_rates[4]=InpKPeriod5+InpDPeriod5+InpSlowing;
   ArraySetAsSeries(min_rates,true);
   min_rates_total=int(min_rates[ArrayMaximum(min_rates,0,5)]);

//---- getting handle of the iStochastic 1 indicator
   STOH_Handle[0]=iStochastic(NULL,0,InpKPeriod1,InpDPeriod1,InpSlowing,ma_method,price_field);
   if(STOH_Handle[0]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 1 indicator");
//---- getting handle of the iStochastic 2 indicator   
   STOH_Handle[1]=iStochastic(NULL,0,InpKPeriod2,InpDPeriod2,InpSlowing,ma_method,price_field);
   if(STOH_Handle[1]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 2 indicator");
//---- getting handle of the iStochastic 3 indicator  
   STOH_Handle[2]=iStochastic(NULL,0,InpKPeriod3,InpDPeriod3,InpSlowing,ma_method,price_field);
   if(STOH_Handle[2]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 3 indicator");
//---- getting handle of the iStochastic 4 indicator   
   STOH_Handle[3]=iStochastic(NULL,0,InpKPeriod4,InpDPeriod4,InpSlowing,ma_method,price_field);
   if(STOH_Handle[3]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 4 indicator");
//---- getting handle of the iStochastic 5 indicator   
   STOH_Handle[4]=iStochastic(NULL,0,InpKPeriod5,InpDPeriod5,InpSlowing,ma_method,price_field);
   if(STOH_Handle[4]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 5 indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SignBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"PriceVSwma");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---- checking the number of bars to be enough for calculation
   for(int count=0; count<5; count++) if(BarsCalculated(STOH_Handle[count])<rates_total) return(RESET);
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy;
   double Sto1[],Sto2[],Sto3[],Sto4[],Sto5[];
   double stoh1,stoh2,stoh3,stoh4,stoh5,mov,stohsmoothed;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      SignBuffer[limit+1]=0.0;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   to_copy=limit+1;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Sto1,true);
   ArraySetAsSeries(Sto2,true);
   ArraySetAsSeries(Sto3,true);
   ArraySetAsSeries(Sto4,true);
   ArraySetAsSeries(Sto5,true);

//---- copy newly appeared data into the arrays
   if(CopyBuffer(STOH_Handle[0],MAIN_LINE,0,to_copy,Sto1)<=0) return(RESET);
   if(CopyBuffer(STOH_Handle[1],MAIN_LINE,0,to_copy,Sto2)<=0) return(RESET);
   if(CopyBuffer(STOH_Handle[2],MAIN_LINE,0,to_copy,Sto3)<=0) return(RESET);
   if(CopyBuffer(STOH_Handle[3],MAIN_LINE,0,to_copy,Sto4)<=0) return(RESET);
   if(CopyBuffer(STOH_Handle[4],MAIN_LINE,0,to_copy,Sto5)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      stoh1=Sto1[bar]*0.05;
      stoh2=Sto2[bar]*0.43;
      stoh3=Sto3[bar]*0.26;
      stoh4=Sto4[bar]*0.16;
      stoh5=Sto5[bar]*0.10;
      mov=stoh1+stoh2+stoh3+stoh4+stoh5;
      stohsmoothed=mov/Smoothing+SignBuffer[bar+1]*(Smoothing-1)/Smoothing;
      IndBuffer[bar]=mov;
      SignBuffer[bar]=stohsmoothed;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
