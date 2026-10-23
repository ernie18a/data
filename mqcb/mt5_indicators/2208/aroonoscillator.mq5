//+------------------------------------------------------------------+
//|                                              AroonOscillator.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru"
//---- Indicator Version Number
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 1
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing of the indicator as a three color line
#property indicator_type1 DRAW_LINE
//---- red color is used as the color of the line
#property indicator_color1 Red
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying label of the signal line
#property indicator_label1  "AroonOscillator"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 +50
#property indicator_level2   0
#property indicator_level3 -50
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input int AroonPeriod= 9; // Period of the indicator 
input int AroonShift = 0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(
             const double &array[],// array for searching for maximum element index
             int count,// the number of the array elements (from a current bar to the index descending), 
             // along which the searching must be performed.
             int startPos //the initial bar index (shift relative to a current bar), 
             // the search for the greatest value begins from
             )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double max=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(
            const double &array[],// array for searching for minimum element index
            int count,// the number of the array elements (from a current bar to the index descending), 
            // along which the searching must be performed.
            int startPos //the initial bar index (shift relative to a current bar), 
            // the search for the lowest value begins from
            )
  {
//----
   int index=startPos;

//---- checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- transformation of the dynamic array ExtLineBuffer into an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- Initialization of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"AroonOscillator(",AroonPeriod,")");
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,AroonShift);
//--- Create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
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
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<AroonPeriod) return(0);

//---- declaration of local variables 
   int first,bar,highest,lowest;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=AroonPeriod-1; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      highest=iHighest(high,AroonPeriod,bar);
      lowest=iLowest(low,AroonPeriod,bar);
      //----
      ExtLineBuffer[bar]=100*(highest-lowest)/AroonPeriod;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
