//+------------------------------------------------------------------+
//|                                             Gann_Multi_Trend.mq5 |
//|                      Copyright © 2011, Mikhail Pashnin (raxxla). |
//|                                        http://www.mql4.com       |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Mikhail Pashnin."
//---- link to the author's website
#property link      "http://www.mql4.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 6 buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 6
//---- 6 plots are used
#property indicator_plots   6
//+----------------------------------------------+
//|  Bullish indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color1  Lime
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is 1
#property indicator_width1  1
//---- displaying the bullish label of the indicator
#property indicator_label1  "Bulls Gann Multi 1"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bearish line of the indicator
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is 1
#property indicator_width2  1
//---- displaying the bearish label of the indicator
#property indicator_label2  "Bears Gann Multi 1"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing the indicator 3 as a line
#property indicator_type3   DRAW_LINE
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color3  Lime
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator 3 line width is 2
#property indicator_width3  2
//---- displaying the bullish label of the indicator
#property indicator_label3  "Bulls Gann Multi 2"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing the indicator 4 as a line
#property indicator_type4   DRAW_LINE
//---- red color is used as the color of the bearish line of the indicator
#property indicator_color4  Red
//---- the indicator 4 line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- indicator 4 line width is 2
#property indicator_width4  2
//---- displaying the bearish label of the indicator
#property indicator_label4  "Bears Gann Multi 2"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing the indicator 5 as a line
#property indicator_type5   DRAW_LINE
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color5  Lime
//---- the indicator 5 line is a continuous curve
#property indicator_style5  STYLE_SOLID
//---- indicator 5 line width is 3
#property indicator_width5  3
//---- displaying the bullish label of the indicator
#property indicator_label5  "Bulls Gann Multi 3"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing the indicator 6 as a line
#property indicator_type6   DRAW_LINE
//---- red color is used as the color of the bearish line of the indicator
#property indicator_color6  Red
//---- the indicator 6 line is a continuous curve
#property indicator_style6  STYLE_SOLID
//---- indicator 6 line width is 3
#property indicator_width6  3
//---- displaying the bearish label of the indicator
#property indicator_label6  "Bears Gann Multi 3"
//+----------------------------------------------+
//| Indicator input parameters                 |
//+----------------------------------------------+
input uint GannPeriod1= 3; // micro trend period
input uint GannPeriod2= 5; // middle trend period
input uint GannPeriod3= 8; // main trend period 
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double BullsBuffer1[];
double BearsBuffer1[];
double BullsBuffer2[];
double BearsBuffer2[];
double BullsBuffer3[];
double BearsBuffer3[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=int(MathMax(MathMax(GannPeriod1,GannPeriod2),GannPeriod3));

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,BullsBuffer1,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,GannPeriod1);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BullsBuffer1,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(1,BearsBuffer1,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,GannPeriod1);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BearsBuffer1,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(2,BullsBuffer2,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,GannPeriod2);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BullsBuffer2,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(3,BearsBuffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 4 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,GannPeriod2);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BearsBuffer2,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(4,BullsBuffer3,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 5 drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,GannPeriod3);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BullsBuffer3,true);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(5,BearsBuffer3,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 6 drawing
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,GannPeriod3);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BearsBuffer3,true);

//---- initialization of a variable for a short name of the indicator
   string shortname;
   StringConcatenate(shortname,"Gann Multi Trend(",GannPeriod1,", ",GannPeriod2,", ",GannPeriod3,", ",Shift,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price highs for the calculation of the indicator
                const double& low[],      // price array of price lows for the calculation of the indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);
   
//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- Main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
       SetBufferData(BearsBuffer1,BullsBuffer1,GannPeriod1,bar,low,high);
       SetBufferData(BearsBuffer2,BullsBuffer2,GannPeriod2,bar,low,high);
       SetBufferData(BearsBuffer3,BullsBuffer3,GannPeriod3,bar,low,high);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void SetBufferData(double &upBuffer[],double &dnBuffer[],int period,int index,const double& Low[],const double& High[])
  {
//---- 
   double max=High[ArrayMaximum(High,index+1,period)];
   double min=Low[ArrayMinimum(Low,index+1,period)];

   if(High[index]>=max && Low[index]>min)
     {
      dnBuffer[index]=EMPTY_VALUE;
      upBuffer[index]=High[index];
      return;
     }

   if(Low[index]<=min && High[index]<max)
     {
      upBuffer[index]=EMPTY_VALUE;
      dnBuffer[index]=Low[index];
      return;
     }

   if(Low[index]<=min && High[index]>=max)
     {
      upBuffer[index]=High[index];
      dnBuffer[index]=Low[index];
      return;
     }

   upBuffer[index]=upBuffer[index+1];
   dnBuffer[index]=dnBuffer[index+1];
//---- 
  }
//+------------------------------------------------------------------+
