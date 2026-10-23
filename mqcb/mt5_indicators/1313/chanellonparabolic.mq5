//+------------------------------------------------------------------+
//|                                               ChanellOnParabolic |
//|                                      Copyright © 2009, Svinozavr |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, Svinozavr"
//---- link to the website of the author
#property link      ""
//---- indicator version number
#property version   "1.01"
#property description "The channel built on parabolic"
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- three buffers are used for the indicator calculation and drawing
#property indicator_buffers 3
//---- only three plots are used
#property indicator_plots   3

//---- icon is used for the indicator
#property indicator_type1   DRAW_ARROW
//---- displaying the indicator label
#property indicator_label1  " Parabolic Sar"
//---- use the following color for the indicator
#property indicator_color1 clrDodgerBlue
//---- indicator width is equal to 1
#property indicator_width1  1

//---- line is used for the indicator
#property indicator_type2   DRAW_LINE
//---- displaying the indicator label
#property indicator_label2  "Chanell On Parabolic Upper"
//---- use the following colors for the indicator line
#property indicator_color2 clrRed
//---- indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2  2

//---- line is used for the indicator
#property indicator_type3   DRAW_LINE
//---- displaying the indicator label
#property indicator_label3  "Chanell On Parabolic Lower"
//---- use the following colors for the indicator line
#property indicator_color3 clrMediumSeaGreen
//---- indicator line is a solid one
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width3  2
//+----------------------------------------------+ 
//|  declaring constants                         |
//+----------------------------------------------+ 
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input double Step=0.02; //SAR step
input double Maximum=0.2; //SAR maximum
input int Wide=0; // minimal allowable channel width in points
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double LowestBuffer[];
double HighestBuffer[];
double SarBuffer[];

double wide;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int SAR_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=1;
   wide=Wide*_Point;

//---- getting handle of the SAR indicator
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the SAR indicator");

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,SarBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HighestBuffer,INDICATOR_DATA);

//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- indexing buffer elements as time series   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(SarBuffer,true);

//---- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"Chanell On Parabolic Sar(",DoubleToString(Step,2),", ",DoubleToString(Maximum,2),", ",Wide,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double middleprice0,middleprice1,top,bot;
   static double prev_top,prev_bot;

//---- calculate the limit starting number for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
      to_copy=limit+2;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
      to_copy=limit+1;
     }

//---- indexing elements in arrays as timeseries 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
//---- restore values of the variables
   top=prev_top;
   bot=prev_bot;

//--- copy newly appeared data in the array
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SarBuffer)<=0) return(RESET);

//---- First big indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      middleprice0=(high[bar]+low[bar])/2; // average price on the current bar
      middleprice1=(high[bar+1]+low[bar+1])/2; // average price on the previous bar

      

      if(SarBuffer[bar+1]>=middleprice1 && SarBuffer[bar]<middleprice0) // overturn upward
         if(top-SarBuffer[bar]>wide) bot=SarBuffer[bar];

      if(SarBuffer[bar+1]<=middleprice1 && SarBuffer[bar]>middleprice0) // overturn downward
         if(SarBuffer[bar]-bot>wide) top=SarBuffer[bar];

      HighestBuffer[bar]=top;
      LowestBuffer[bar]=bot;
      
      //---- memorize values of the variables before running at the current bar
      if(bar)
       {
        prev_top=top;
        prev_bot=bot;
       }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
