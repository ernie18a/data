//+------------------------------------------------------------------+
//|                                                       Bezier.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "Lizhniyk E"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used as the indicator line color
#property indicator_color1 Chocolate,DodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Bezier"
//+-----------------------------------+
//|  DECLARATION OF ENUMERATIONS          |
//+-----------------------------------+
enum Applied_price_ //Type of constant
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
//+-----------------------------------+
//|  DECLARATION OF ENUMERATIONS          |
//+-----------------------------------+
enum Signal_mode
  {
   Trend, //by trend
   Kalman //by Kalman
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input int BPeriod=8;                        //smoothing period
input double T=0.5;                        //sensitivity ratio (from 0 to 1)               
input Applied_price_ IPC=PRICE_WEIGHTED;   //price constant
input int Shift=0;                         //horizontal shift of the indicator in bars
input int PriceShift=0;                    //vertical shift of the indicator in points
//+-----------------------------------+
//---- indicator buffers
double IndBuffer[],ColorBuffer[];
//----
double dPriceShift,t;
//---- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| KalmanFilter indicator initialization function                   | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=BPeriod;

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
   t=MathMin(MathMax(T,0),1);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization of a variable for a short name of the indicator

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

   string shortname;
   StringConcatenate(shortname,"Bezier(",BPeriod,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| KalmanFilter iteration function                                  | 
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

//---- Declaration of local variables
   int first,bar;
   double;
//----

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
        first=min_rates_total+1; // starting index for the calculation of all bars
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      double r=0;
      for(int iii=BPeriod; iii>=0; iii--)
         r+=PriceSeries(IPC,bar-iii,open,low,high,close)*
            (factorial(BPeriod)/(factorial(iii)*factorial(BPeriod-iii)))*MathPow(t,iii)*MathPow(1-t,BPeriod-iii)+dPriceShift;
            
      IndBuffer[bar]=r;
      if(IndBuffer[bar-1]>IndBuffer[bar]) ColorBuffer[bar]=0;
      else ColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| calculation of the factorial                                            | 
//+------------------------------------------------------------------+  
int factorial(int value)
  {
//---- 
   int res=1;
   for(int j=2; j<value+1; j++) res*=j;
//---- returning the factorial
   return(res);
  }
//+------------------------------------------------------------------+   
//| Getting the value of price time series                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Price constant
 uint   bar,// Shift index relative to the current bar by a specified number of periods backward or forward).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Price constants from the ENUM_APPLIED_PRICE enumeration
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
