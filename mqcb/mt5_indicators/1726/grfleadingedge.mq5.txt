//+------------------------------------------------------------------+
//|                                               GRFLeadingEdge.mq5 | 
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
//---- 5 indicator buffers used
#property indicator_buffers 5 
//---- 5 graphical constructions used
#property indicator_plots   5
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- Indicator drawn as a line
#property indicator_type1   DRAW_LINE
//---- LimeGreen is used for the indicator line color
#property indicator_color1 clrLimeGreen
//---- Indicator line is solid
#property indicator_style1  STYLE_SOLID
//---- Width of the indicator line is 2
#property indicator_width1  2

//+--------------------------------------------+
//|  Parameters for drawing BB levels indicator|
//+--------------------------------------------+
//---- Levels drawn as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- Selecting line colors
#property indicator_color2  clrBlue
#property indicator_color3  clrRed
#property indicator_color4  clrRed
#property indicator_color5  clrBlue
//---- Levels - dot-dash lines
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
//---- Width of the levels is 1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Samples=60;
input int  LookAhead=0;
input double StdLevel1=2.0;
input double  StdLevel2=4.0;
input int Shift=0; // Horizontal shift of the indicator in bars
input int PriceShift=0; // Vertical shift of the indicator in points
//+-----------------------------------+

//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double LeadingEdgeBuffer[];
double LeadingEdgeBufferPlus1[];
double LeadingEdgeBufferNeg1[];
double LeadingEdgeBufferPlus2[];
double LeadingEdgeBufferNeg2[];

double pStdLevel1,pStdLevel2;
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
   
   pStdLevel1=StdLevel1*_Point;
   pStdLevel2=StdLevel2*_Point;

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

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,LeadingEdgeBufferPlus2,INDICATOR_DATA);
   SetIndexBuffer(2,LeadingEdgeBufferPlus1,INDICATOR_DATA);
   SetIndexBuffer(3,LeadingEdgeBufferNeg1,INDICATOR_DATA);
   SetIndexBuffer(4,LeadingEdgeBufferNeg2,INDICATOR_DATA);
//---- setting the position from which drawing of the levels starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- creating labels to show in the Data Window
   PlotIndexSetString(1,PLOT_LABEL,"LeadingEdge +"+DoubleToString(StdLevel2,1));
   PlotIndexSetString(2,PLOT_LABEL,"LeadingEdge +"+DoubleToString(StdLevel1,1));
   PlotIndexSetString(3,PLOT_LABEL,"LeadingEdge -"+DoubleToString(StdLevel1,1));
   PlotIndexSetString(4,PLOT_LABEL,"LeadingEdge -"+DoubleToString(StdLevel2,1));
//---- Drawing of empty values is forbidden
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

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
   double c0,c1,alpha,beta,s0,s1,c01,c11;
   static double base_det,a[2][2],b[2][2];
//---- Declaration of integer variables
   int first,bar,kkk;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total; // starting index for calculation of all bars
      ArrayInitialize(a,0);
      for(int iii=0; iii<int(Samples); iii++)
        {
         a[0][0]+=iii*iii;
         a[0][1]+=iii;
         a[1][0]+=iii;
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
      
      double Leading=(beta-alpha*LookAhead)*_Point+dPriceShift;
      LeadingEdgeBuffer[bar]=Leading;

      c0 = 0;
      c1 = 0;
      c11=0;
      c01=0;
      for(kkk=0; kkk<int(Samples); kkk++)
        {
         s0=get_avg(bar-kkk,high,low,close);
         s1=kkk*alpha+beta;
         double res=MathPow(s0-s1,2);
         
         if(s0<s1)
           {
            c0+=res;
            c01++;
           }
         else
           {
            c1+=res;
            c11++;
           }
        }
        
      if(!c01) c01=1;
      if(!c11) c11=1;

      c01=MathSqrt(1./(0.5/MathPow(Samples,2)+0.5/c01/c01));
      c11=MathSqrt(1./(0.5/MathPow(Samples,2)+0.5/c11/c11));
      c0=MathSqrt(c0/c01);
      c1=MathSqrt(c1/c11);
      
      if(MathAbs(StdLevel1)>0)
        {
         LeadingEdgeBufferPlus1[bar]=Leading+pStdLevel1*c0;
         LeadingEdgeBufferNeg1[bar]=Leading-pStdLevel1*c1;
        }
        
      if(MathAbs(StdLevel2)>0)
        {
         LeadingEdgeBufferPlus2[bar]=Leading+pStdLevel2*c0;
         LeadingEdgeBufferNeg2[bar]=Leading-pStdLevel2*c1;
        }

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
