//+-------------------------------------------------------------------------+ 
//|                                                      LaguerreVolume.mq5 | 
//|                                 Copyright © 2007, Emerald King, t_david |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators |
//+-------------------------------------------------------------------------+
#property copyright "Copyright © 2007, Emerald King, t_david"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DarkOrchid color is used as the color of the bullish line of the indicator
#property indicator_color1 clrDarkOrchid
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1 1
//---- displaying the indicator label
#property indicator_label1  "LaguerreVolume"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input double gamma=0.618;                          //smoothing ratio
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input int Shift=0;                                 //horizontal shift of the indicator in bars
input double inHighLevel=0.75;
input double inMiddleLevel=0.50;
input double inLowLevel=0.25;
//+-----------------------------------+
//---- indicator buffer
double IndBuffer[];
//---- Declaration of global variables
int min_rates_total;
//+------------------------------------------------------------------+    
//| LaguerreVolume indicator initialization function                 | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"LaguerreVolume",DoubleToString(gamma,3),")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inMiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,inLowLevel);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
//---- short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| LaguerreVolume iteration function                                | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   long vol;
   int limit,bar;
   double L0,L1,L2,L3,L0A,L1A,L2A,L3A,CD,CU,RES;

//---- declaration of static variables for storing real values of coefficients
   static double L0_,L1_,L2_,L3_,L0A_,L1A_,L2A_,L3A_;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      //---- the starting initialization of calculated coefficients
      double Vol;
      if(VolumeType==VOLUME_TICK) Vol=double(tick_volume[0]);
      else                        Vol=double(volume[0]);
      L0_ = Vol;
      L1_ = Vol;
      L2_ = Vol;
      L3_ = Vol;
      L0A_ = Vol;
      L1A_ = Vol;
      L2A_ = Vol;
      L3A_ = Vol;
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- restore values of the variables
   L0 = L0_;
   L1 = L1_;
   L2 = L2_;
   L3 = L3_;
   L0A = L0A_;
   L1A = L1A_;
   L2A = L2A_;
   L3A = L3A_;

//---- indexing elements in arrays as timeseries  
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else                        ArraySetAsSeries(volume,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      //----
      if(VolumeType==VOLUME_TICK) vol=tick_volume[bar];
      else                        vol=volume[bar];
      //----
      L0 = (1 - gamma) * vol + gamma * L0A;
      L1 = - gamma * L0 + L0A + gamma * L1A;
      L2 = - gamma * L1 + L1A + gamma * L2A;
      L3 = - gamma * L2 + L2A + gamma * L3A;
      //----
      CU = 0;
      CD = 0;
      //---- 
      if(L0 >= L1) CU  = L0 - L1; else CD  = L1 - L0;
      if(L1 >= L2) CU += L1 - L2; else CD += L2 - L1;
      if(L2 >= L3) CU += L2 - L3; else CD += L3 - L2;
      //----
      RES=CU+CD;
      if(RES) IndBuffer[bar]=CU/RES;
      else IndBuffer[bar]=0.0;

      //---- memorize values of the variables before running at the current bar
      if(bar)
        {
         L0_ = L0;
         L1_ = L1;
         L2_ = L2;
         L3_ = L3;
         L0A_ = L0A;
         L1A_ = L1A;
         L2A_ = L2A;
         L3A_ = L3A;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
