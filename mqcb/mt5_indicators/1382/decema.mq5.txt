//+------------------------------------------------------------------+ 
//|                                                       DecEMA.mq5 | 
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |                      
//|                         Revised by IgorAD,igorad2003@yahoo.co.uk |   
//|                                        http://www.forex-tsd.com/ |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Guru"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.01"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- pink color is used as the color of the bullish line of the indicator
#property indicator_color1 clrRed
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "DecEMA"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint EMA_Period=3; //EMA period 
input int ELength=15; // depth of smoothing                   
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW, 12-DEMARK.) */
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+
//---- indicator buffer
double IndBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- Declaration of global variables
double alfa,dPriceShift;
//+------------------------------------------------------------------+    
//| DecEMA indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation 
   min_rates_total=2;
   alfa=2.0/(1.0+ELength);
   
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"DecEMA(",EMA_Period,",",ELength,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| DecEMA iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total)return(0);

//---- Declaration of local variables
   int first,bar,maxbar;
//----
   double price,EMA0,EMA1,EMA2,EMA3,EMA4,EMA5,EMA6,EMA7,EMA8,EMA9,EMA10;
   static double sdEMA1,sdEMA2,sdEMA3,sdEMA4,sdEMA5,sdEMA6,sdEMA7,sdEMA8,sdEMA9,sdEMA10;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1; // starting number for calculation of all bars
      //---- Initialization of coefficients
      sdEMA1=PriceSeries(IPC,first-1,open,low,high,close);
      sdEMA2=sdEMA1;
      sdEMA3=sdEMA1;
      sdEMA4=sdEMA1;
      sdEMA5=sdEMA1;
      sdEMA6=sdEMA1;
      sdEMA7=sdEMA1;
      sdEMA8=sdEMA1;
      sdEMA9=sdEMA1;
      sdEMA10=sdEMA1;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- variables restoring
   EMA1=sdEMA1;
   EMA2=sdEMA2;
   EMA3=sdEMA3;
   EMA4=sdEMA4;
   EMA5=sdEMA5;
   EMA6=sdEMA6;
   EMA7=sdEMA7;
   EMA8=sdEMA8;
   EMA9=sdEMA9;
   EMA10=sdEMA10;
   maxbar=rates_total-1;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      EMA0=XMA1.XMASeries(1,prev_calculated,rates_total,1,0,EMA_Period,price,bar,false);
      EMA1=alfa*EMA0 + (1-alfa)*EMA1;
      EMA2=alfa*EMA1 + (1-alfa)*EMA2;
      EMA3=alfa*EMA2 + (1-alfa)*EMA3;
      EMA4=alfa*EMA3 + (1-alfa)*EMA4;
      EMA5=alfa*EMA4 + (1-alfa)*EMA5;
      EMA6=alfa*EMA5 + (1-alfa)*EMA6;
      EMA7=alfa*EMA6 + (1-alfa)*EMA7;
      EMA8=alfa*EMA7 + (1-alfa)*EMA8;
      EMA9=alfa*EMA8 + (1-alfa)*EMA9;
      EMA10=alfa*EMA9+(1-alfa)*EMA10;
      IndBuffer[bar]=10*EMA1-45*EMA2+120*EMA3-210*EMA4+252*EMA5-210*EMA6+120*EMA7-45*EMA8+10*EMA9-EMA10;
      IndBuffer[bar]+=dPriceShift;
      
      //---- saving variables 
      if(bar<maxbar)
        {
         sdEMA1=EMA1;
         sdEMA2=EMA2;
         sdEMA3=EMA3;
         sdEMA4=EMA4;
         sdEMA5=EMA5;
         sdEMA6=EMA6;
         sdEMA7=EMA7;
         sdEMA8=EMA8;
         sdEMA9=EMA9;
         sdEMA10=EMA10;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
