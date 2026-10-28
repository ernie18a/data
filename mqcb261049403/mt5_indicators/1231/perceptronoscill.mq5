//+------------------------------------------------------------------+ 
//|                                             PerceptronOscill.mq5 | 
//|                                            Copyright © 2009, Zar | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Zar"
#property link ""
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
//---- indigo color is used as the color of the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "PerceptronOscill"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Numb=10;// Numb
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffers
double IndBuffer[];
//---- Declaration of global variables
double Kf[];
int min_rates_total,N;
//+------------------------------------------------------------------+    
//| PerceptronOscill indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   N=int(Numb);
   if(N<2) N=2;
   if(N>90) N=90;
//---
   min_rates_total=N;
//---- memory distribution for variables' arrays  
   ArrayResize(Kf,N);
//---- Initialization of variables
   int D=300;
   int kk=int(NormalizeDouble(D/(N+1),0));
   for(int ccc=N; ccc>0; ccc--) Kf[ccc-1]=kk*ccc-D/2;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"PerceptronOscill(",N,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| PerceptronOscill iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- declaration of variables with a floating point  
   double;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total+begin; // starting number for calculation of all bars
      //---- performing the shift of beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++) IndBuffer[bar]=perceptronNN(N,price,bar);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
double perceptronNN(int Nn,const double &Price[],int index)
  {
//----
   double rez=0.0;
//----
   for(int ccc=Nn; ccc>0; ccc--) rez+=(Kf[ccc-1] *(Price[index]-Price[index-ccc]));
//----
   return(rez);
  }
//+------------------------------------------------------------------+
