//+------------------------------------------------------------------+
//|                                                    RFractals.mq5 |
//|                                      Copyright © 2009 Lizhniyk E |
//|                                                                  |
//+------------------------------------------------------------------+
#property description "Fine Fractals"
//---- author of the indicator
#property copyright "Copyright © 2009 Lizhniyk E"
//---- link to the website of the author
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- DodgerBlue color is used for the indicator bearish line
#property indicator_color1  clrDodgerBlue
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- MediumOrchid color is used as the color of the bullish line of the indicator
#property indicator_color2  clrMediumOrchid
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Down Fractal"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint RangeFractal=5; //fractal rank (odd numbers not less than 3)
input int  UpLable=217;//upper fractal label
input int  DnLable=218;//lower fractal label
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//----
int center;
//---- Declaration of integer variables of data starting point
int min_rates_total,range_fractal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables
   range_fractal=int(RangeFractal);
   if(range_fractal%2==0) range_fractal++;
   range_fractal=MathMax(range_fractal,3);
   center=range_fractal/2+1;
   min_rates_total=int(range_fractal+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Up Fractal");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Down Fractal");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DnBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="RFractals("+string(range_fractal)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,barC;
   double cur;
   bool found;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=0.0;      
      DnBuffer[bar]=0.0;
      barC=bar+center;
      
      //---- fractal up
      found=false;
      cur=high[barC];
      
      if(cur>high[bar+1] && cur>high[bar+range_fractal]) found=true;
      else found=false;
      
      if(found)
        {
         for(int j=1; j<center; j++)
           {
            if(cur>=high[barC-j] && cur>=high[barC+j]) found=true;
            else {found=false; break;}
           }
        }
        
      if(found) {UpBuffer[barC]=cur; UpBuffer[barC+1]=0;}

      //---- fractal down
      found=false;
      cur=low[barC];
      
      if(cur<low[bar+1] && cur<low[bar+range_fractal]) found=true;
      else found=false;
      
      if(found)
        {
         for(int k=1;k<center;k++)
           {
            if(cur<=low[barC-k] && cur<=low[barC+k]) found=true;
            else {found=false; break;}
           }
        }
        
      if(found) {DnBuffer[barC]=cur; DnBuffer[barC+1]=0;}
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
