//+------------------------------------------------------------------+ 
//|                                                 KalmanFilter.mq5 | 
//|                    MQL5 code: Copyright © 2010, Nikolay Kositsin |
//|                                Khabarovsk, farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 3
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used for the indicator line
#property indicator_color1 Orange,Turquoise
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "KalmanFilter velocity"
//+-----------------------------------+
//| Declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Signal_mode
  {
   Trend, // by trend
   Kalman // by Kalman
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input double K=1.0;                      // Smoothing ratio                   
input Applied_price_ IPC=PRICE_WEIGHTED_; // Applied price
input Signal_mode Signal=Kalman;         // Line color change method
input int Shift=0;                       // Horizontal shift of the indicator in bars
input int PriceShift=0;                  // Vertical shift of the indicator in points
//+-----------------------------------+
//---- indicator buffers
double IndBuffer[],ColorBuffer[],val[];
//----
double dPriceShift,Sqrt100,K100;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| KalmanFilter indicator initialization function                   | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=2;

//---- initialization of variables   
   Sqrt100=MathSqrt(K/100);
   K100=K/100.0;

//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,31);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name

//---- set ColorBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

   string shortname;
   StringConcatenate(shortname,"KalmanFilter  velocity(",DoubleToString(K,2),")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   SetIndexBuffer(0,val,INDICATOR_DATA);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| KalmanFilter iteration function                                  | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total)return(0);

//---- declaration of local variables
   int first,bar;
   double Velocity,Distance,Error;
   static double Velocity_;
//----

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1; // starting index for calculation of all bars
      //---- initialization of coefficients
      IndBuffer[first-1]=PriceSeries(IPC,first-1,open,low,high,close);
      Velocity_=0.0;
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   Velocity=Velocity_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         Velocity_=Velocity;
        }

      Distance=PriceSeries(IPC,bar,open,low,high,close)-IndBuffer[bar-1];
      Error=IndBuffer[bar-1]+Distance*Sqrt100;
      Velocity+=Distance*K100;
      IndBuffer[bar]=Error+Velocity+dPriceShift;
      val[bar]=Velocity;

      if(Signal==Trend)
        {
         if(IndBuffer[bar-1]>IndBuffer[bar]) ColorBuffer[bar]=0;
         else ColorBuffer[bar]=1;
        }
      else
        {
         if(Velocity>0) ColorBuffer[bar]=1;
         else           ColorBuffer[bar]=0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price series                                 |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,// Applied price
                   uint   bar,        // Index of shift relative to the current bar for a specified number of periods back or forward
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
