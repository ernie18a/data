//+---------------------------------------------------------------------+
//|                                             ColorX2MA-Parabolic.mq5 | 
//|                         Copyright © 2010, Nikolay Kositsin + lukas1 | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin + lukas1"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----six buffers are used for calculation of drawing of the indicator
#property indicator_buffers 6
//---- only 5 graphical plots are used
#property indicator_plots   5
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color1  Red
//---- indicator 1 width is equal to 1
#property indicator_width1  4
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Lower Parabolic"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- LawnGreen color is used for the indicator
#property indicator_color2  LawnGreen
//---- indicator 2 width is equal to 1
#property indicator_width2  4
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Upper Parabolic"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color3  DeepPink
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying of the bullish label of the indicator
#property indicator_label3  "Parabolic Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- LawnGreen color is used for the indicator
#property indicator_color4  LawnGreen
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying of the bearish label of the indicator
#property indicator_label4 "Parabolic Buy"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a multicolored line
#property indicator_type5   DRAW_COLOR_LINE
//---- the following colors are used in a three-colored line
#property indicator_color5  Gray,Teal,Magenta
//---- the indicator line is a continuous curve
#property indicator_style5  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width5  2
//---- displaying the indicator label
#property indicator_label5  "X2MA"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - the enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| X2MA indicator input parameters              |
//+----------------------------------------------+
input Smooth_Method MA_Method1=MODE_SMA; //Method of averaging of the first smoothing 
input uint Length1=12; //first smoothing depth                    
input int Phase1=15; //First smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_JJMA; //method of averaging of the second smoothing 
input uint Length2=5; //second smoothing depth 
input int Phase2=15;  //Second smoothing parameter,
                      // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+----------------------------------------------+
//| Parabolic indicator input parameters         |
//+----------------------------------------------+
input double StepH_=0.2;//Step for high points
input double MaximumH=0.5;//Maximum for high points
input double StepL_=0.02;//Step for low points
input double MaximumL=0.05;//Maximum for low points
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double X2MA[];
double ColorX2MA[];
double BuyBuffer[],SellBuffer[];
double UpSarBuffer[],DnSarBuffer[];
//---- 
bool dirlong_,first_;
double ep_,start_,last_high_,last_low_;
double StepH,StepL;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+   
//| X2MA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=min_rates_1+min_rates_2+2;
//---- setting up alerts for unacceptable values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting up alerts for unacceptable values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

   StepH=MathMin(StepH_,MaximumH);
   StepL=MathMin(StepL_,MaximumL);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSarBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSarBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,X2MA,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as a color index buffer   
   SetIndexBuffer(5,ColorX2MA,INDICATOR_COLOR_INDEX);

//---- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"X2MA-Parabolic");

//---- set accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| X2MA iteration function                                          | 
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

//double start,last_high,last_low;
//double ep,StepH,StepL;

//---- declaration of variables with a floating point  
   double price_,x1xma,x2xma;
   double price_low,price_high,sar;
   double ep,start,last_high,last_low;
//---- Declaration of integer variables and getting already calculated bars
   int gfirst,bar;
   bool dirlong,first;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      gfirst=0; // starting number for calculation of all bars
      first_=false;
      dirlong_=false;
      last_high_=0.0;
      last_low_=999999999.0;
      ep_=close[min_rates_total-1];
      start_=0.0;
     }
   else gfirst=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   ep=ep_;
   start=start_;
   last_high=last_high_;
   last_low=last_low_;
   dirlong=dirlong_;
   first=first_;

//---- main cycle of calculation of the X2MA indicator
   for(bar=gfirst; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Two calls of the XMASeries function. 
      //---- The 'begin' parameter is increased by min_rates_1 in the second call, as it is another XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(min_rates_1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      //----       
      X2MA[bar]=x2xma;
     }

//---- correction of the first variable value
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      gfirst=min_rates_total; //  starting index for calculation of all bars

//---- Main loop of the X2MA indicator coloring
   for(bar=gfirst; bar<rates_total; bar++)
     {
      ColorX2MA[bar]=0;
      if(X2MA[bar-1]<X2MA[bar]) ColorX2MA[bar]=1;
      if(X2MA[bar-1]>X2MA[bar]) ColorX2MA[bar]=2;
     }

//---- main cycle of calculation of the Parabolic indicator
   for(bar=gfirst; bar<rates_total; bar++)
     {
      price_low=X2MA[bar]-_Point;
      price_high=X2MA[bar]+_Point;
      double prev_sar=MathMax(UpSarBuffer[bar-1],DnSarBuffer[bar-1]);
      sar=prev_sar+start*(ep-prev_sar);
      //----
      if(dirlong)
        {
         if(ep<price_high && start+StepL<=MaximumL) start+=StepL;
         if(sar>=price_low)
           {
            start=StepL;
            dirlong=false;
            ep=price_low;
            last_low=price_low;

            if(price_high<last_high) sar=last_high;
            else sar=price_high;
           }
         else
           {
            if(ep<price_low && start+StepL<=MaximumL) start+=StepL;

            if(ep<price_high)
              {
               last_high=price_high;
               ep=price_high;
              }
           }
        }
      //----
      else//chain down
        {
         if(ep>price_low && start+StepH<=MaximumH) start+=StepH;
         if(sar<=price_high)//if the conditions of switching are came
           {
            start=StepH;
            dirlong=true;
            ep=price_high;//set the last price = maximum
            last_high=price_high;
            if(price_low>last_low) sar=last_low;
            else sar=price_low;
           }
         else
           {
            if(ep>price_high && start+StepH<=MaximumH) start+=StepH;

            if(ep>price_low)
              {
               last_low=price_low;
               ep=price_low;
              }
           }
        }

      //---- zero out the contents of the indicator buffers for calculation
      DnSarBuffer[bar]=0.0;
      UpSarBuffer[bar]=0.0;

      if(X2MA[bar]<sar) UpSarBuffer[bar]=sar;
      else              DnSarBuffer[bar]=sar;

      //---- save values of the variables
      if(bar==rates_total-2)
        {
         ep_=ep;
         start_=start;
         last_high_=last_high;
         last_low_=last_low;
         dirlong_=dirlong;
         first_=first;
        }
     }

//---- recalculation of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator     
      gfirst++;

//---- second cycle of calculation of the Parabolic indicator
   for(bar=gfirst; bar<rates_total; bar++)
     {
      //---- zero out the contents of the indicator buffers for calculation
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(UpSarBuffer[bar-1]>0.0&&DnSarBuffer[bar]>0.0) BuyBuffer [bar]=MathMax(UpSarBuffer[bar],DnSarBuffer[bar]);
      if(DnSarBuffer[bar-1]>0.0&&UpSarBuffer[bar]>0.0) SellBuffer[bar]=MathMax(UpSarBuffer[bar],DnSarBuffer[bar]);
     }
//----      
   return(rates_total);
  }
//+------------------------------------------------------------------+
