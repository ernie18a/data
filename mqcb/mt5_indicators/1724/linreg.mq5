//+------------------------------------------------------------------+ 
//|                                                       linreg.mq5 | 
//|                                         Copyright © 2006, ch33z3 | 
//|                                   http://4xjournal.blogspot.com/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, ch33z3"
#property link "http://4xjournal.blogspot.com/" 
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- Number of indicator buffers
#property indicator_buffers 1 
//---- Only one graphical construction used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- Coral is used for the color of the bullish line of the indicator
#property indicator_color1 clrCoral
//---- Indicator line is solid
#property indicator_style1  STYLE_SOLID
//---- Width of the indicator line is 3
#property indicator_width1  3
//---- Indicator label
#property indicator_label1  "linreg"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint LRPeriod=13; // Depth of smoothing                   
input int Shift=0; // Horizontal shift of the indicator in bars
input int PriceShift=0; // Vertical shift of the indicator in points
//+-----------------------------------+
//---- Indicator buffer
double IndBuffer[];

double dPriceShift;
//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| linreg indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(LRPeriod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"linreg(",LRPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//---- end ofo initialization
  }
//+------------------------------------------------------------------+  
//| linreg iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
  //---- Check if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin)return(0);

//---- declaration of local variables
   int first,bar;
//----
   double;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first=min_rates_total+begin; // starting index for the calculation of all bars
      //---- Performing the shift of beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++) IndBuffer[bar]=LinReg(LRPeriod,bar,price)+dPriceShift;
//----+     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| LinReg iteration function                                        | 
//+------------------------------------------------------------------+  
double LinReg(int period,int index,const double &Price[])
  {
//----
   double SumY=0.0;
   double Sum1=0.0;
      
   for(int iii=0; iii<period; iii++)
     {
      double c=Price[index-iii];
      SumY+=c;
      Sum1+=iii*c;
     }
     
   int per1=period-1;
   int per2=period*per1;  
   double SumBars=per2*0.5;
   double SumSqrBars=per2*(2*period-1.0)/6.0;
   double Sum2=SumBars*SumY;
   double Num1=period*Sum1-Sum2;
   double Num2=SumBars*SumBars-period*SumSqrBars;
   double Slope=0.0;
   if(Num2) Slope=Num1/Num2;
   double Intercept=(SumY-Slope*SumBars)/period;
//----
   return(Intercept+Slope*per1);
  }
//+------------------------------------------------------------------+
