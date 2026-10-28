//+------------------------------------------------------------------+ 
//|                                              Linear_Sinus_FT.mq5 | 
//|                                     Copyright © 2009, buldakov_a | 
//|                                               buldakov_a@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, buldakov_a"
#property link "mailto:buldakov_a@mail.ru" 
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Sin indicator drawing parameters            |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color1  clrRed
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Sinus"
//+----------------------------------------------+
//|  Out indicator drawing parameters            |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator bearish line
#property indicator_color2  clrBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Out"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0          // the constant for returning the indicator recalculation command to the terminal
#define PI    3.14159265 // Pi character
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint inHours=600;
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SinBuffer[];
double OutBuffer[];
//---- Declaration of integer variables of data starting point
int Hours,min_rates_total,Hour,n,n2,mBar120,mBar60;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   Hours=int(MathMax(inHours,2));
   int mPeriod=PeriodSeconds(PERIOD_CURRENT)/60;
   mBar120=120/mPeriod;
   mBar60=60/mPeriod;

   n=((Hours*60)/mPeriod)/2;
   n2=2*n;
   min_rates_total=2*n2+1;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SinBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SinBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,OutBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(OutBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Linear_Sinus_FT(",inHours,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(price,true);

//---- declaration of local variables 
   int limit,bar;
   int j,i,t;
   double Num,Den;
   double stti,stttti,sOuti,si,sOutti,sOuttti,a,b,c;
   double Alfa,dAlfa;

//---- calculation of the 'limit' starting index for the bars zeroing loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the zeroing of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-min_rates_total);

//---- Zeroing the data of previous calculation
   for(bar=limit+min_rates_total; bar>=0 && !IsStopped(); bar--)
     {
      SinBuffer[bar]=0.0;
      OutBuffer[bar]=0.0;
     }

//---- Fast Fourier Transform
   for(j=n2; j>=0; j--)
     {
      Num=0;Den=0;
      for(i=(n+n); i>=0; i--)
        {
         Num=Num+MathSin(i*PI/n2)*price[j+i];
         Den=Den+MathSin(i*PI/n2);
        }

      SinBuffer[j+n]=Num/Den;
      for(i=n; i>=0; i--) SinBuffer[i]=SinBuffer[n+0]+(SinBuffer[n+0]-SinBuffer[n+1])*(n-i);
     }
//---- Approximation of second degree polynomial
   t=n2+1;
   stti=(t*t*t-t)/12;
   stttti=(3*t*t*t*t*t-10*t*t*t+7*t)/240;
   sOuti=0.0;
   si=0.0;
   sOutti=0.0;
   sOuttti=0.0;

   for(i=n2; i>=0; i--)
     {
      sOuti=sOuti+SinBuffer[i];
      si=si+(-i+(t/2));
      sOutti=sOutti+(SinBuffer[i]*(-i+(t/2)));
      sOuttti=sOuttti+(SinBuffer[i]*(-i+(t/2))*(-i+(t/2)));
     }

   b=sOutti/stti;
   c=-((sOuti/t)-(sOuttti/stti))/MathAbs((stti/t)-(stttti/stti));
   a=(sOuti-stti*c)/t;
   for(i=(2*n); i>=0; i--) OutBuffer[i]=a+b*(-i+(t/2))+c*(-i+(t/2))*(-i+(t/2));

//----
   dAlfa=0;
   Alfa=((OutBuffer[0]-OutBuffer[mBar60]))/_Point;
   if(Alfa>0) dAlfa=(((OutBuffer[0]-OutBuffer[mBar60])-(OutBuffer[mBar60]-OutBuffer[mBar120])))/_Point;
   if(Alfa<0) dAlfa=(((OutBuffer[mBar120]-OutBuffer[mBar60])-(OutBuffer[mBar60]-OutBuffer[0])))/_Point;
//-----
   Comment(
           "Date and Time ",TimeToString(TimeCurrent()),"\n",
           "Period       ",DoubleToString(Hours,0)," hour.","\n",
           "Tilt angle ",DoubleToString(Alfa,1)," points/hour.",
           "  Tilt angle changing ",DoubleToString(dAlfa,3)," points/hour.^2");
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
