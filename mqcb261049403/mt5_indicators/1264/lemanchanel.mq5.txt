//+------------------------------------------------------------------+ 
//|                                                  LeManChanel.mq5 | 
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, LeMan."
//---- link to the website of the author
#property link      "b-market@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- three plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used for the indicator line
#property indicator_color1 clrDodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Upper LeMan"
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used for indicator line
#property indicator_color2 clrMagenta
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Lower LeMan"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint period=12;
input int Shift=1; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpperBuffer[];
double LowerBuffer[];
//---- declaration of dynamic arrays that will further be 
// used as ring buffers
int Count[];
double HC[],CL[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[],// Return the current value of the price series by the link
 int Size // number of the elements in the ring buffer
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+    
//| Keltner Channel indicator initialization function                | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initializing constants
   min_rates_total=int(period+1);
   
//---- memory distribution for variables' arrays  
   ArrayResize(Count,period);
   ArrayResize(HC,period);
   ArrayResize(CL,period);  
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(HC,true);
   ArraySetAsSeries(CL,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpperBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(LowerBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"LeManChanel(",period,",",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Keltner Channel iteration function                               | 
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
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
        limit=rates_total-2; // calculated number of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   //---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HC[Count[0]]=high[bar]-close[bar+1];
      CL[Count[0]]=close[bar+1]-low[bar]; 

      UpperBuffer[bar]=close[bar]+HC[ArrayMaximum(HC,0,period)];
      LowerBuffer[bar]=close[bar]-CL[ArrayMaximum(CL,0,period)];
      
      //---- recalculation of positions in ring buffers
      if(bar>0) Recount_ArrayZeroPos(Count,period);
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
