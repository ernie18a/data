//+------------------------------------------------------------------+
//| Nadaraya-Watson Envelope Non-repainting(NR)                      |
//|                                                                  |
//| Author: Derrick Njagi                                            |
//| Telegram: @Derrick_254F                                          |
//| PayPal: derricknjagitransformed@gmail.com                        |
//| MQL5: https://www.mql5.com/en/users/derrick-254                  |
//| Website: https://forexis.net                                     |
//|                                                                  |
//| Copyright 2026, Derrick Njagi - Forexis.net                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Derrick Njagi - Forexis.net"
#property link      "https://forexis.net"
#property version   "1.00"

#property description "Nadaraya-Watson Envelope NR"
#property description "Non-repainting Gaussian endpoint envelope with upper and lower bands."
#property description "Displays crossover signals when price crosses the envelope."
#property description "Developed by Derrick Njagi - Forexis.net"

#property strict
#property indicator_chart_window
#property indicator_plots   4
#property indicator_buffers 7

#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Crossunder"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_width3  1

#property indicator_label4  "Crossover"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  1


input group "Settings"
input double             InpBandwidth = 8.0;          // Bandwidth
input double             InpMult      = 3.0;          // Envelope multiplier
input ENUM_APPLIED_PRICE InpSource    = PRICE_CLOSE;  // Applied price

input group "Style"
input color              InpUpColor   = clrBlue;      // Upper line and upward signal color
input color              InpDownColor = clrRed;       // Lower line and downward signal color


double UpperBuffer[];
double LowerBuffer[];
double UpArrowBuffer[];
double DownArrowBuffer[];

double SourceBuffer[];
double OutBuffer[];
double ResidualBuffer[];

double g_gauss[500];
double g_den=0.0;


/*
   Calculate the Gaussian weight used by the endpoint estimator.
   The weight becomes smaller as the distance from the current
   price bar increases.
*/
double Gauss(const int x,const double h)
  {
   if(h<=0.0)
      return (x==0 ? 1.0 : 0.0);

   const double xd=(double)x;
   return MathExp(-(xd*xd)/(h*h*2.0));
  }


/*
   Return the price value selected by the user.

   This allows the envelope to work with Close, Open, High, Low,
   Median, Typical or Weighted price without changing the main
   calculation routine.
*/
double AppliedPriceAt(const int i,
                      const double &open[],
                      const double &high[],
                      const double &low[],
                      const double &close[])
  {
   switch(InpSource)
     {
      case PRICE_OPEN:
         return open[i];

      case PRICE_HIGH:
         return high[i];

      case PRICE_LOW:
         return low[i];

      case PRICE_MEDIAN:
         return (high[i]+low[i])*0.5;

      case PRICE_TYPICAL:
         return (high[i]+low[i]+close[i])/3.0;

      case PRICE_WEIGHTED:
         return (high[i]+low[i]+close[i]+close[i])*0.25;

      case PRICE_CLOSE:
      default:
         return close[i];
     }
  }


/*
   Perform a complete historical calculation.

   The first stage calculates the Gaussian endpoint value for every
   available bar. The absolute difference between price and the
   estimated value is stored for the envelope calculation.

   The second stage calculates the mean absolute error and builds
   the upper and lower bands.

   Signal arrows are generated when the closing price crosses the
   corresponding envelope boundary.
*/
void CalculateEndpointFull(const int rates_total,
                           const double &close[],
                           const double &high[],
                           const double &low[])
  {
   ArrayInitialize(UpperBuffer,EMPTY_VALUE);
   ArrayInitialize(LowerBuffer,EMPTY_VALUE);
   ArrayInitialize(UpArrowBuffer,EMPTY_VALUE);
   ArrayInitialize(DownArrowBuffer,EMPTY_VALUE);
   ArrayInitialize(OutBuffer,EMPTY_VALUE);
   ArrayInitialize(ResidualBuffer,EMPTY_VALUE);

   const int maxOut=rates_total-500;

   if(maxOut<0 || g_den==0.0)
      return;


//calculate Gaussian endpoint values
   for(int i=maxOut;i>=0;i--)
     {
      double out=0.0;

      for(int k=0;k<500;k++)
         out+=SourceBuffer[i+k]*g_gauss[k];

      out/=g_den;

      OutBuffer[i]=out;
      ResidualBuffer[i]=MathAbs(SourceBuffer[i]-out);
     }


   const int maxMae=maxOut-498;

   if(maxMae<0)
      return;


//prepare the first rolling residual total
   double residualSum=0.0;

   for(int k=0;k<499;k++)
      residualSum+=ResidualBuffer[maxMae+k];


//calculate envelope boundaries and crossing signals
   for(int i=maxMae;i>=0;i--)
     {
      if(i<maxMae)
        {
         residualSum+=ResidualBuffer[i];
         residualSum-=ResidualBuffer[i+499];
        }

      const double mae=(residualSum/499.0)*InpMult;

      UpperBuffer[i]=OutBuffer[i]+mae;
      LowerBuffer[i]=OutBuffer[i]-mae;


      //upward signal when price crosses below the lower envelope
      if(i+1<rates_total && LowerBuffer[i+1]!=EMPTY_VALUE)
        {
         if(close[i]<LowerBuffer[i] &&
            close[i+1]>=LowerBuffer[i+1])
           {
            UpArrowBuffer[i]=low[i];
           }
        }


      //downward signal when price crosses above the upper envelope
      if(i+1<rates_total && UpperBuffer[i+1]!=EMPTY_VALUE)
        {
         if(close[i]>UpperBuffer[i] &&
            close[i+1]<=UpperBuffer[i+1])
           {
            DownArrowBuffer[i]=high[i];
           }
        }
     }
  }


/*
   Recalculate a single recent endpoint bar.

   Only the current and most recently closed bars need to be refreshed
   during normal operation. Older endpoint values remain unchanged,
   which preserves historical indicator values and signals.
*/
void CalculateEndpointBar(const int i,
                          const int rates_total,
                          const double &close[],
                          const double &high[],
                          const double &low[])
  {
   UpperBuffer[i]=EMPTY_VALUE;
   LowerBuffer[i]=EMPTY_VALUE;
   UpArrowBuffer[i]=EMPTY_VALUE;
   DownArrowBuffer[i]=EMPTY_VALUE;
   OutBuffer[i]=EMPTY_VALUE;
   ResidualBuffer[i]=EMPTY_VALUE;


   if(i+499>=rates_total || g_den==0.0)
      return;


//calculate the Gaussian endpoint value
   double out=0.0;

   for(int k=0;k<500;k++)
      out+=SourceBuffer[i+k]*g_gauss[k];

   out/=g_den;

   OutBuffer[i]=out;
   ResidualBuffer[i]=MathAbs(SourceBuffer[i]-out);


   if(i+498>=rates_total)
      return;


//calculate mean absolute error for the envelope
   double sum=0.0;

   for(int k=0;k<499;k++)
     {
      const double r=ResidualBuffer[i+k];

      if(r==EMPTY_VALUE)
         return;

      sum+=r;
     }


   const double mae=(sum/499.0)*InpMult;

   UpperBuffer[i]=out+mae;
   LowerBuffer[i]=out-mae;


//check for an upward crossing signal
   if(i+1<rates_total && LowerBuffer[i+1]!=EMPTY_VALUE)
     {
      if(close[i]<LowerBuffer[i] &&
         close[i+1]>=LowerBuffer[i+1])
        {
         UpArrowBuffer[i]=low[i];
        }
     }


//check for a downward crossing signal
   if(i+1<rates_total && UpperBuffer[i+1]!=EMPTY_VALUE)
     {
      if(close[i]>UpperBuffer[i] &&
         close[i+1]<=UpperBuffer[i+1])
        {
         DownArrowBuffer[i]=high[i];
        }
     }
  }


/*
   Initialize indicator buffers, plot appearance and Gaussian weights.

   The calculated Gaussian weights are stored once during initialization
   and then reused by the indicator on every calculation.
*/
int OnInit()
  {
//validate user parameters
   if(InpBandwidth<0.0 || InpMult<0.0)
      return INIT_PARAMETERS_INCORRECT;


//connect indicator buffers
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DownArrowBuffer,INDICATOR_DATA);

   SetIndexBuffer(4,SourceBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,OutBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ResidualBuffer,INDICATOR_CALCULATIONS);


//use time-series indexing for all buffers
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(UpArrowBuffer,true);
   ArraySetAsSeries(DownArrowBuffer,true);

   ArraySetAsSeries(SourceBuffer,true);
   ArraySetAsSeries(OutBuffer,true);
   ArraySetAsSeries(ResidualBuffer,true);


//define empty values for all visible plots
   for(int p=0;p<4;p++)
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);


//apply user-selected colors
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,InpUpColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,InpDownColor);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,InpUpColor);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,InpDownColor);


//configure solid Wingdings arrows
   PlotIndexSetInteger(2,PLOT_ARROW,233);
   PlotIndexSetInteger(3,PLOT_ARROW,234);

   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,0);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,0);


//set indicator identification
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Nadaraya-Watson Envelope NR");

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);


//calculate and store Gaussian weights
   g_den=0.0;

   for(int i=0;i<500;i++)
     {
      g_gauss[i]=Gauss(i,InpBandwidth);
      g_den+=g_gauss[i];
     }


   return INIT_SUCCEEDED;
  }


/*
   Main indicator calculation.

   A complete rebuild is performed when the indicator starts, when
   historical data changes or when more than one new bar is received.

   During normal operation only the current bar and the most recently
   closed bar are recalculated.
*/
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
   if(rates_total<3)
      return 0;


//use time-series indexing for price arrays
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);


//determine whether historical values require a full rebuild
   const bool fullRebuild=(prev_calculated<=0 ||
                           prev_calculated>rates_total ||
                           rates_total-prev_calculated>1);


   if(fullRebuild)
     {
      //rebuild the complete source-price history
      ArrayInitialize(SourceBuffer,EMPTY_VALUE);

      for(int i=rates_total-1;i>=0;i--)
         SourceBuffer[i]=AppliedPriceAt(i,
                                        open,
                                        high,
                                        low,
                                        close);


      //calculate complete envelope history
      CalculateEndpointFull(rates_total,
                            close,
                            high,
                            low);
     }
   else
     {
      //update the current source values
      SourceBuffer[0]=AppliedPriceAt(0,
                                     open,
                                     high,
                                     low,
                                     close);

      if(rates_total>1)
         SourceBuffer[1]=AppliedPriceAt(1,
                                        open,
                                        high,
                                        low,
                                        close);


      //refresh only the current and latest closed bars
      const int start=MathMin(1,rates_total-1);

      for(int i=start;i>=0;i--)
         CalculateEndpointBar(i,
                              rates_total,
                              close,
                              high,
                              low);
     }


   return rates_total;
  }
//+------------------------------------------------------------------+
