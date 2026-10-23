//+------------------------------------------------------------------+
//|                                                     SF-6(AM).mq5 | 
//|                             Copyright © 2010, Andrey Matvievskiy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Andrey Matvievskiy"
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 4 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color1 clrMagenta,clrLime
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width1  5
//---- displaying the indicator label
#property indicator_label1  "Up SF-6(AM)"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the histogram
#property indicator_color2 clrRed,clrBlue
//---- the indicator line is a continuous curve
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Down SF-6(AM)"
//+----------------------------------------------+
//| Window borders showing parameters            |
//+----------------------------------------------+
#property indicator_maximum 1
#property indicator_minimum -1
//---- indicator subwindow fixed height in pixels 
#property indicator_height 50
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input double A1=3.0;
input double A2=2.0;
input double A3=1.0;
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffer
double ExtMapBuffer1[],ColorExtMapBuffer1[];
double ExtMapBuffer2[],ColorExtMapBuffer2[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Variation indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtMapBuffer1,INDICATOR_COLOR_INDEX);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBuffer2,INDICATOR_DATA);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorExtMapBuffer2,INDICATOR_COLOR_INDEX);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"SF-6(AM)( A1 = ",A1,", A2 = ",A2,", A3 = ",A3,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Variation iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- Checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int first,bar;
//---- declaration of variables with a floating point  
   double A,B,close1,open1,median1;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first=min_rates_total; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      close1=Close[bar]*A1+Close[bar-1]*A2+Close[bar-2]*A3;
      open1=Open[bar]*A1+Open[bar-1]*A2+Open[bar-2]*A3;
      median1=((High[bar]+Low[bar])/2)*A1+((High[bar-1]+Low[bar-1])/2)*A2+((High[bar-2]+Low[bar-2])/2)*A3;

      ExtMapBuffer1[bar]=0;
      ExtMapBuffer2[bar]=0;

      //----
      A =(median1 - open1) + (close1 - median1);
      B =median1 - close1;

      if(A>0)
        {
         ExtMapBuffer2[bar]=1;
         ColorExtMapBuffer2[bar]=1;
        }
      else
        {
         ExtMapBuffer2[bar]=-1;
         ColorExtMapBuffer2[bar]=0;
        }
        
      if(B<0)
        {
         ExtMapBuffer1[bar]=1;
         ColorExtMapBuffer1[bar]=1;
        }
      else
        {
         ExtMapBuffer1[bar]=-1;
         ColorExtMapBuffer1[bar]=0;
        }
        
      if(ExtMapBuffer1[bar]==ExtMapBuffer2[bar]) ExtMapBuffer2[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
