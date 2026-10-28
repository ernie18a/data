//+------------------------------------------------------------------+
//|                                                  LW_Fractals.mq5 |
//|                                          Copyright © 2005, Gosha |
//|                                                                  |
//+------------------------------------------------------------------+
#property description "Fractal on three bars"
//--- Copyright
#property copyright "Copyright © 2005, Gosha"
//--- link to the website of the author
#property link      ""
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- blue color is used for the indicator line
#property indicator_color1  clrBlue
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//--- Magenta color is used as the color of the indicator line
#property indicator_color2  clrMagenta
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2 "Down Fractal"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint  Equals=3;
input uint  nLeftUp=1;
input uint  nRightUp=1;
input uint  nLeftDown=1;
input uint  nRightDown=1;
input int   UpLable=217; // Label of the upper fractal
input int   DnLable=218; // Label of the lower fractal
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double UpBuffer[];
double DownBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   min_rates_total=int(MathMax(nLeftUp+nRightUp,nLeftDown+nRightDown)+Equals+1);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,DownBuffer,INDICATOR_DATA);
//--- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DownBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="LW_Fractals";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit;
   double;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated+2; // starting index for calculation of new bars
     }
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- the main loop of calculation of the upper fractal
   for(int bar=limit; bar>=int(nRightUp) && !IsStopped(); bar--)
     {
      UpBuffer[bar]=0.0;
      int r=int(nRightUp);
      int i;

      for(i=1; i<=r; i++) if(high[bar]<=high[bar-i]) break;

      if(i==r+1)
        {
         int l=int(nLeftUp);
         int e=int(Equals);
         for(int j=1; j<=l+int(Equals); j++)
           {
            if(high[bar]<high[bar+j]) break;
            if(high[bar]>high[bar+j]) l--;
            if(high[bar]==high[bar+j]) e--;
            if(!l)
              {
               UpBuffer[bar]=high[bar];
               break;
              }
            if(e<0) break;
           }
        }
     }
//--- the main loop of calculation of the lower fractal
   for(int bar=limit; bar>=int(nRightDown) && !IsStopped(); bar--)
     {
      DownBuffer[bar]=0.0;
      int r=int(nRightDown);
      int i;

      for(i=1; i<=r; i++) if(low[bar]>=low[bar-i]) break;
      
      if(i==r+1)
        {
         int l=int(nLeftDown);
         int e=int(Equals);
         for(int j=1; j<=l+int(Equals); j++)
           {
            if(low[bar]>low[bar+j]) break;
            if(low[bar]<low[bar+j]) l--;
            if(low[bar]==low[bar+j]) e--;
            if(!l)
              {
               DownBuffer[bar]=low[bar];
               break;
              }
            if(e<0) break;
           }
        }
     }
//---       
   return(rates_total);
  }
//+------------------------------------------------------------------+