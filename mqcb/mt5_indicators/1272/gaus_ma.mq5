//+------------------------------------------------------------------+
//|                                                      Gaus_MA.mq5 |
//|                            Copyright © 2009, Gregory A. Kakhiani |
//|                                              gkakhiani@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Gregory A. Kakhiani"
#property link      "gkakhiani@gmail.com"
#property version   "1.00"

#property description "Averaging of prices (smoothing of a price curve) using the modified algorithm"
#property description "of the linear-weighted moving average, where the smoothing coefficients are calculated"
#property description "by the radial-basis function (Gauss function)"

//---- drawing the indicator in the main window
#property indicator_chart_window
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color1  clrGray,clrTeal,clrCrimson
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "GaussAverage"
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_, //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_  //PRICE_TRENDFOLLOW1_
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input uint      period=10;      //Averaging period 
input double    N_=2;            //Degree of the exponent
input double    A=-0.001;       //Coefficient of the exponent degree
input bool      Vol=false;      //Multiply by volume
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input Applied_price_ Applied_Price=PRICE_CLOSE_;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtLineBuffer[];
double ColorExtLineBuffer[];

double N,dPriceShift;
double Coefs[]; //Array to store the coefficients
//---- Declaration of integer variables of data starting point
int min_rates_total,AvPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- initialization of variables
   AvPeriod=int(period);
//AvPeriod=MathMin(period,49);
   min_rates_total=AvPeriod+1;
   ArrayResize(Coefs,AvPeriod);
   N=N_;
   if(MathAbs(N)>5) N=5;

//Fill the array of coefficients
   for(int iii=0; iii<AvPeriod; iii++) Coefs[iii]=MathExp(A*MathPow(iii,N));

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"GaussAverage");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//----
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total)
      return(0);

//---- declaration of local variables 
   int first,bar;
   double sum=0; //Temporary variables for a sums 
   double W=0;   //involved in the numerator and denominator

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      sum=0;
      W=0;

    for(int kkk=0; kkk<AvPeriod; kkk++)
      if(Vol)
        {
         if(VolumeType==VOLUME_TICK)  
           {
            sum+=PriceSeries(Applied_Price,bar-kkk,open,low,high,close)*tick_volume[bar]*Coefs[kkk];
            W+=Coefs[kkk]*tick_volume[bar];
           }
         else
           {
            sum+=PriceSeries(Applied_Price,bar-kkk,open,low,high,close)*volume[bar]*Coefs[kkk];
            W+=Coefs[kkk]*volume[bar];
           }
        }
      else
        {
         sum+=PriceSeries(Applied_Price,bar-kkk,open,low,high,close)*Coefs[kkk];
         W+=Coefs[kkk];
        }

      //---- Initialization of a cell of the indicator buffer with the obtained value
      ExtLineBuffer[bar]=sum/W+dPriceShift;
     }

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first++;

//---- Main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      ColorExtLineBuffer[bar]=0;
      if(ExtLineBuffer[bar-1]<ExtLineBuffer[bar]) ColorExtLineBuffer[bar]=1;
      if(ExtLineBuffer[bar-1]>ExtLineBuffer[bar]) ColorExtLineBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| PriceSeries() function                                           |
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
//----+
   switch(applied_price)
     {
      //----+ Price constants from the enumeration ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----+                            
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
//----+
//return(0);
  }
//+------------------------------------------------------------------+
