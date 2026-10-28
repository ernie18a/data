//+------------------------------------------------------------------+
//| Based on total_power_indicator.mq4 by Daniel Fernandez           |
//| Asirikuy.com 2011                                                |
//|                                          TotalPowerIndicator.mq5 |
//|                                  Copyright © 2011, EarnForex.com |
//|                                         http://www.earnforex.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, www.EarnForex.com"
//---- link to the website of the author
#property link      "http://www.earnforex.com/"
//---- indicator version
#property version   "1.0"
#property description "Displays the concentration of bull PowerBuffer periods,"
#property description "bear power periods and total periods"
#property description "when either bulls or bears have prevalence."
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- three buffers are used for calculation of drawing of the indicator
#property indicator_buffers 3
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Cloud drawing parameters                    |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator cloud
#property indicator_color1  DodgerBlue,Magenta
//---- displaying the indicator label
#property indicator_label1  "BullsBears Cloud"
//+----------------------------------------------+
//|  Power indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- dark orchid color is used for the indicator bearish line
#property indicator_color2  DarkOrchid
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 3 line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Power"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 100.0
#property indicator_level2  50.0
#property indicator_level3   0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Window borders fixing parameters             |
//+----------------------------------------------+
#property indicator_minimum  -5
#property indicator_maximum 105
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int PowerPeriod=10;    // Indicator period
input int LookbackPeriod=45; // Smoothing period
input int Shift=0;           // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
double PowerBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int Bulls_Handle,Bears_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=LookbackPeriod+PowerPeriod;
//---- getting handle of the Bulls indicator
   Bulls_Handle=iBullsPower(NULL,0,PowerPeriod);
   if(Bulls_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Bulls indicator");
//---- getting handle of the Bears indicator
   Bears_Handle=iBearsPower(NULL,0,PowerPeriod);
   if(Bears_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Bears indicator");

//---- set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by Period
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by Period
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- set PowerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,PowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 3 by Period
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(BullsBuffer,true);
   ArraySetAsSeries(BearsBuffer,true);
   ArraySetAsSeries(PowerBuffer,true);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Total Power Indicator(",PowerPeriod,", ",LookbackPeriod,", ",Shift,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(BarsCalculated(Bulls_Handle)<rates_total
      || BarsCalculated(Bears_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);
//---- declarations of local variables 
   int limit,to_copy,bar,bearscount,bullscount;
   double BULLS[],BEARS[];
//---- indexing elements in arrays as timeseries 
   ArraySetAsSeries(BULLS,true);
   ArraySetAsSeries(BEARS,true);
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars
//---- calculation of the data amount to be copied   
   to_copy=limit+min_rates_total+1;
//---- copy newly appeared data in the variables arrays
   if(CopyBuffer(Bulls_Handle,0,0,to_copy,BULLS)<=0) return(0);
   if(CopyBuffer(Bears_Handle,0,0,to_copy,BEARS)<=0) return(0);
//---- indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bearscount = 0;
      bullscount = 0;

      for(int kkk=LookbackPeriod-1; kkk>=0; kkk--)
        {
         if(BULLS[bar+kkk]>0) bullscount++;
         if(BEARS[bar+kkk]<0) bearscount++;
        }

      PowerBuffer[bar]=MathAbs(bullscount-bearscount)*100/LookbackPeriod;
      BullsBuffer[bar] = bullscount * 100 / LookbackPeriod;
      BearsBuffer[bar] = bearscount * 100 / LookbackPeriod;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+