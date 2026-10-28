//+------------------------------------------------------------------+
//|                                            GRFLeadingEdgeMov.mq5 | 
//|                                  Copyright © 2007, GammaRatForex | 
//|                                   http://www.gammarat.com/Forex/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GammaRatForex"
#property link "http://www.gammarat.com/Forex/"
/*
 * LSQ line fitting to the a number of samples.
 * The trendline is the leading point in the fit;
 * the bands are calculated somewhat differently, check the math below and adapt to 
 * your own needs as appropriate
 * also the point estimate is given by the geometric mean
 * MathPow(HCCC,.025) (see function "get_avg" below) rather than 
 * more standard estimates.
 * It's computationally fairly intensive
 */
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window 
//---- 1 indicator buffer used
#property indicator_buffers 1 
//---- 1 graphical construction used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- DeepPink is used for the indicator line color
#property indicator_color1 clrDeepPink
//---- Indicator line is solid
#property indicator_style1  STYLE_SOLID
//---- Width of the indicator line is 2
#property indicator_width1  2

//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input uint Samples=12;
input int  LookAhead=0;
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in points
//+-----------------------------------+

//---- Declaring dynamic arrays that will further 
// be used as indicator buffers
double LeadingEdgeBuffer[];
//---- Declaring a variable of the value of the vertical MA shift
double dPriceShift;
//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(Samples);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,LeadingEdgeBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- creating a label to display in the DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"LeadingEdge Trend");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"LeadingEdge Trend");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
  //---- Check if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaring floating point variables  
   double c0,c1,alpha,beta,b[2][2];
   static double base_det,a[2][2];
//---- Declaring integer variables
   int first,bar,kkk;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total; // starting index for calculation of all bars
      ArrayInitialize(a,0);
      for(int iii=0; iii<int(Samples); iii++)
        {
         a[0][0] += iii*iii;
         a[0][1] += iii;
         a[1][0] += iii;
         a[1][1]++;
        }

      base_det=det2(a);
     }
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      c0=0;
      c1=0;
      for(kkk=0; kkk<int(Samples); kkk++)
        {
         double res=get_avg(bar-kkk,high,low,close);
         c0+=kkk*res;
         c1+=res;
        }

      ArrayCopy(b,a);
      b[0][0]=c0;
      b[1][0]=c1;
      alpha=det2(b)/base_det;

      ArrayCopy(b,a);
      b[0][1]=c0;
      b[1][1]=c1;
      beta=det2(b)/base_det;
      
      LeadingEdgeBuffer[bar]=(beta-alpha*LookAhead)*_Point+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_avg(int index,const double &High[],const double &Low[],const double &Close[])
  {
//----
   return(MathPow((High[index]*Low[index]*Close[index]*Close[index]),1/4.0)/_Point);
  }
//+------------------------------------------------------------------+
//| Point and figure                                                 |
//+------------------------------------------------------------------+       
double det2(double &a[][2])
  {
//----
   return(a[0][0]*a[1][1]-a[1][0]*a[0][1]);
  }
//+------------------------------------------------------------------+
