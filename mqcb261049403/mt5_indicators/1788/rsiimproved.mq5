//+------------------------------------------------------------------+
//|                                                  RSIImproved.mq5 |
//|                                  Copyright © 2010, Fedor Igumnov |
//|                                           igumnovfedor@yandex.ru |
//+------------------------------------------------------------------+
#property description "Based on the code of the original RSI"
#property description "calculates the difference between the first RSI and the inverted second RSI(100-RSI2),"
#property description " and the rate o change of this difference."
//---- Copyright
#property copyright "Fedor Igumnov"
#property link      "igumnovfedor@yandex.ru"
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- 4 buffers are used for the indicator calculation and drawing
#property indicator_buffers 4
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the bullish line of the indicator
#property indicator_color1  clrLime,clrDeepPink
//---- displaying of the bullish label of the indicator
#property indicator_label1  "RSI Original;RSI Rotated"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type2 DRAW_HISTOGRAM
//---- Gray is used for the histogram color
#property indicator_color2 clrGray
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "Delta"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- clrOrange is used for the color of the indicator line
#property indicator_color3 clrOrange
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Delta Speed"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RSIPeriodOriginal=14; // Period of the original RSI
input uint RSIPeriodRotated=7;   // Period of the inverted RSI
input int  Shift=0; // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// will be used as indicator buffers
double RSIBufferOriginal[],RSIBufferRotated[],Delta[],DeltaSpeed[];
//---- Declaration of integer variables of data starting point
int min_rates_total,RSIPeriodOriginal1,RSIPeriodRotated1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(RSIPeriodOriginal,RSIPeriodRotated))+1;
   RSIPeriodOriginal1=int(RSIPeriodOriginal-1);
   RSIPeriodRotated1=int(RSIPeriodRotated-1);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,RSIBufferOriginal,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(RSIBufferOriginal,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,RSIBufferRotated,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(RSIBufferRotated,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,Delta,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Delta,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(3,DeltaSpeed,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DeltaSpeed,true);

//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 3 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 4 by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"RSI Improved(",RSIPeriodOriginal,", ",RSIPeriodRotated,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- the number of the indicator's horizontal levels is 5   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//---- Values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+70);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+30);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-30);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,-70);
//---- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlueViolet);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrBlueViolet);
//---- Short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASH);
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
//---- checking if the number of bars is enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,MaxBar;
   double rel,negative,positive,negativerot,positiverot;
   static double positive1,negative1,positiverot1,negativerot1;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      positive1=0;
      negative1=0;
      positiverot1=0;
      negativerot1=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(close,true);

   MaxBar=rates_total-min_rates_total-1;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double sumn=0.0;
      double sump=0.0;
      
      if(bar==MaxBar)
        {
         int kkk=rates_total-2;
         //---- initial accumulation
         while(kkk>=bar)
           {
            rel=close[kkk]-close[kkk+1];
            if(rel>0) sump+=rel;
            else      sumn-=rel;
            kkk--;
           }
           
         positive=sump/RSIPeriodOriginal;
         negative=sumn/RSIPeriodOriginal;
         positiverot=sump/RSIPeriodRotated;
         negativerot=sumn/RSIPeriodRotated;
        }
      else
        {
         //---- smoothed moving average
         rel=close[bar]-close[bar+1];
         
         if(rel>0) sump=+rel;
         else      sumn=-rel;
         
         positive=(positive1*RSIPeriodOriginal1+sump)/RSIPeriodOriginal;
         negative=(negative1*RSIPeriodOriginal1+sumn)/RSIPeriodOriginal;
         positiverot=(positiverot1*RSIPeriodRotated1+sump)/RSIPeriodRotated;
         negativerot=(negativerot1*RSIPeriodRotated1+sumn)/RSIPeriodRotated;
        }

      if(negative) RSIBufferOriginal[bar]=100.0-100.0/(1+positive/negative);
      else RSIBufferOriginal[bar]=0.0;
       

      if(negativerot) RSIBufferRotated[bar]=100-(100.0-100.0/(1+positiverot/negativerot));
      else RSIBufferRotated[bar]=0.0;

      Delta[bar]=RSIBufferOriginal[bar]-RSIBufferRotated[bar];
      DeltaSpeed[bar]=Delta[bar+1]-Delta[bar];

      if(bar)
        {
         positive1=positive;
         negative1=negative;
         positiverot1=positiverot;
         negativerot1=negativerot;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
