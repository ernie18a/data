//+------------------------------------------------------------------+
//|                                      LinearRegressionChannel.mq5 | 
//|                                         Copyright © 2008, dimicr | 
//|                                         http://www.signalsbg.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, dimicr"
#property link "http://www.signalsbg.com"
#property description "LinearRegression Channel"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only 5 graphical plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "LinearRegression Line"

//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of Bollinger Bands colors
#property indicator_color2  Lime
#property indicator_color3  Red
//---- levels are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- display levels labels
#property indicator_label2  "LinearRegression Resistance"
#property indicator_label3  "LinearRegression Support"
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum ENUM_USER_PRICE
  {
   MODE_CLOSE,    //Используем close
   MODE_HIGH_LOW  //Используем high и low
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_USER_PRICE UserPrice=MODE_CLOSE; //price mode
input uint  barsToCount=50;  //Number of bars for calculation
//+-----------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double LineBuffer[];
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ResBuffer[],SupBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| LinearRegression indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(barsToCount);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(LineBuffer,true);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ResBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,SupBuffer,INDICATOR_DATA);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ResBuffer,true);
   ArraySetAsSeries(SupBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"LinearRegression(",EnumToString(UserPrice),", ",barsToCount,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| LinearRegression iteration function                              | 
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

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- performing the shift of beginning of indicator drawing
   int DRAW_BEGIN=rates_total-min_rates_total-1;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DRAW_BEGIN);

//---- declaration of variables with a floating point  
   double a,b,c,res,
   sumy=0.0,
   sumx=0.0,
   sumxy=0.0,
   sumx2=0.0,
   h=0.0,l=0.0;

//---- Declaration of integer variables
   int bar,limit;

//---- calculation of the 'limit' starting index for the bars erasing loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;
     }
   else limit=rates_total-prev_calculated;

//---- erase already unnecessary data
   for(bar=limit+min_rates_total; bar>min_rates_total && !IsStopped(); bar--)
     {
      LineBuffer[bar]=0.0;
      SupBuffer[bar]=0.0;
      ResBuffer[bar]=0.0;
     }

   for(bar=0; bar<min_rates_total; bar++)
     {
      sumy+=close[bar];
      sumxy+=close[bar]*bar;
      sumx+=bar;
      sumx2+=bar*bar;
     }
//----
   c=sumx2*barsToCount-sumx*sumx;

   if(!c)
     {
      Alert("Error in linear regression!");
      return(0);
     }

//---- Line equation    
   b=(sumxy*barsToCount-sumx*sumy)/c;
   a=(sumy-sumx*b)/barsToCount;

//---- Linear regression line in buffer
   for(bar=0; bar<min_rates_total; bar++)
      LineBuffer[bar]=a+b*bar;

//---- Use PRICE_CLOSE for support-resistance
   if(UserPrice==MODE_CLOSE)
      for(bar=0; bar<min_rates_total; bar++)
        {
         h=MathMax(h,close[bar]-LineBuffer[bar]);
         l=MathMax(l,LineBuffer[bar]-close[bar]);
        }
//---- Use HIGH - LOW
   else
   for(bar=0; bar<min_rates_total; bar++)
     {
      h=MathMax(h,high[bar]-LineBuffer[bar]);
      l=MathMax(l,LineBuffer[bar]-low[bar]);
     }

//----  Drawing support - resistance lines   
   if(h>l) res=h;
   else res=l;

   for(bar=0; bar<min_rates_total; bar++)
     {
      SupBuffer[bar]=a-res+b*bar;
      ResBuffer[bar]=a+res+b*bar;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
