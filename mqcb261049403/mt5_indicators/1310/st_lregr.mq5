//+------------------------------------------------------------------+
//|                                                     St_LRegr.mq5 | 
//|                                       Copyright © 2009, Stajer59 | 
//|                                      http://www.stajer59.ucoz.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Stajer59"
#property link "http://www.stajer59.ucoz.ru"
#property description "Indicator of the linear regression channel"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 7 
//---- only one plot is used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1 clrRed
//---- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "St_LRegression chanell"

//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing channel levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//---- selection of channel levels colors
#property indicator_color2  Purple
#property indicator_color3  Red
#property indicator_color4  Blue
#property indicator_color5  Blue
#property indicator_color6  Red
#property indicator_color7  Purple
//---- channel levels are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
//---- channel levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
//---- display the labels of channel levels
#property indicator_label2  "+3Sigma"
#property indicator_label3  "+2Sigma"
#property indicator_label4  "+1Sigma"
#property indicator_label5  "-1Sigma"
#property indicator_label6  "-2Sigma"
#property indicator_label7  "-3Sigma"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint N_=240; // number of candles for analyze
input double StdDev=1.0; // deviation
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double LineBuffer[];

//---- declaration of dynamic arrays that will further be 
//---- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[];
double ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];

//---- declaration of the Bollinger Bands proportion variables
double quotient2,quotient3;

//---- Declaration of the average vertical shift value variable
double dPriceShift;
//---- Declaration of integer variables of data starting point
int min_rates_total,N;
//+------------------------------------------------------------------+   
//| St_LRegr indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   N=int(N_);
   min_rates_total=N;

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(LineBuffer,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"St_LRegression chanell(",N,", ",DoubleToString(StdDev,2),", ",Shift,", ",PriceShift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| St_LRegr iteration function                                      | 
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

//---- Declaration of variables
   int j,x,drawbegin;
   double a,b,Summ_x,Summ_y,Summ_x_2,Summ_xy,Deviation,StdDeviation,Middle_y;
   
//---- performing the shift of beginning of indicator drawing
   drawbegin=rates_total-1-N;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,drawbegin); 
   

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(close,true);
   
   Summ_x=0.0;
   Summ_y=0.0;
   Summ_xy=0.0;
   Summ_x_2=0.0;

   for(x=1; x<=N && !IsStopped(); x++)
     {
      j=N-x;
      Summ_x+=x;
      Summ_y+=close[j];
      Summ_xy+=x*close[j];
      Summ_x_2+=MathPow(x,2);
     }

   b=(N*Summ_xy-Summ_x*Summ_y)/(N*Summ_x_2-MathPow(Summ_x,2));
   a=(Summ_y-b*Summ_x)/N;
   Middle_y=Summ_y/N;
   Deviation=0.0;

   for(x=0; x<N && !IsStopped(); x++)
     {
      j=N-x;
      Deviation+=MathPow((close[j]-Middle_y),2);
     }

   StdDeviation=MathSqrt(Deviation/N);
   ExtLineBuffer1[N]=EMPTY_VALUE;
   ExtLineBuffer2[N]=EMPTY_VALUE;
   ExtLineBuffer3[N]=EMPTY_VALUE;
   ExtLineBuffer4[N]=EMPTY_VALUE;
   ExtLineBuffer5[N]=EMPTY_VALUE;
   ExtLineBuffer6[N]=EMPTY_VALUE;
   LineBuffer[N]=EMPTY_VALUE;

   for(x=0; x<=N && !IsStopped(); x++)
     {
      j=N-x;
      LineBuffer[j]=b*x+a+dPriceShift;
      ExtLineBuffer3[j]=b*x+a+StdDev*StdDeviation+dPriceShift;
      ExtLineBuffer4[j]=b*x+a-StdDev*StdDeviation+dPriceShift;
      ExtLineBuffer2[j]=b*x+a+1.5*StdDev*StdDeviation+dPriceShift;
      ExtLineBuffer5[j]=b*x+a-1.5*StdDev*StdDeviation+dPriceShift;
      ExtLineBuffer1[j]=b*x+a+2.0*StdDev*StdDeviation+dPriceShift;
      ExtLineBuffer6[j]=b*x+a-2.0*StdDev*StdDeviation+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
