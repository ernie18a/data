#property link      "https://forge.mql5.io"                       // URL
#property description "q-period Stochastic Momentum (William Blau)" // description
#property description "output as colored candles" // description
//--- indicator settings
#property indicator_separate_window     // indicator in a separate window
#property indicator_buffers 5           // number of buffers used
#property indicator_plots   1           // number of plots
//#property indicator_maximum  0.5
//#property indicator_minimum  -0.5
#property indicator_level1      0.0
#property indicator_level1    100.0
//#property indicator_level2    0.081
//--- graphic plot #0 (Main)
#property indicator_label1  "SM Candles"        // label of plot #0
#property indicator_type1   DRAW_COLOR_CANDLES   // draw as a line
#property indicator_color1  clrDimGray,clrPeru,clrLime   // line color

enum ENUM_STOCHMOM_VALUE
  {
   RELATIVE = 0,
   ABSOLUTE = 1
  };

//--- input parameters
input int                     Inpq = 12;              // q - period of Stochastic Momentum
input ENUM_STOCHMOM_VALUE     InpFormula = ABSOLUTE;  // Formula - absolute value or relative (percent)

ENUM_APPLIED_PRICE AppliedPrices[] = {PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_CLOSE}; // AppliedPrice - price type
//--- dynamic arrays, used for the calculation
double OpenBuffer[];    // q-period Stochastic Momentum O (graphic plot #0)
double HighBuffer[];    // q-period Stochastic Momentum H (graphic plot #0)
double LowBuffer[];     // q-period Stochastic Momentum L (graphic plot #0)
double CloseBuffer[];   // q-period Stochastic Momentum C (graphic plot #0)
double ColorsBuffer[];  // color buffer


//--- global variables
int    begin1; // starting index
int    rates_total_min; // rates total min
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers
// graphic plot #0
   SetIndexBuffer(0, OpenBuffer, INDICATOR_DATA);           // u-period 3rd EMA
   SetIndexBuffer(1, HighBuffer, INDICATOR_DATA);           // price array
   SetIndexBuffer(2, LowBuffer, INDICATOR_DATA);            // min value (q bars)
   SetIndexBuffer(3, CloseBuffer, INDICATOR_DATA);          // max value (q bars)
   SetIndexBuffer(4, ColorsBuffer, INDICATOR_COLOR_INDEX);

//--- precision
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   begin1 = Inpq - 1;    //

//
   rates_total_min = begin1 + 1; // rates total min
//--- starting index for graphic plot #0
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin1);
//--- indicator short name
   string shortname = "StochMomCandles" + "," + string(Inpq);
   IndicatorSetString(INDICATOR_SHORTNAME, "(" + shortname + ")");
//--- OnInit done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,     // rates total
   const int prev_calculated, // bars, calculated at previous call
   const datetime &Time[],    // Time
   const double &open[],      // Open
   const double &high[],      // High
   const double &low[],       // Low
   const double &close[],     // Close
   const long &TickVolume[],  // Tick Volume
   const long &Volume[],      // Real Volume
   const int &Spread[]        // Spread
)
  {

   int pos;
//--- check rates min
   if(rates_total < rates_total_min)
      return(0);



//--- Preliminary conditions
   if(prev_calculated == 0)    // at first call
      pos = begin1;            // starting from 0
   else
      pos = prev_calculated - 1; // overwise calculate only last value


//--- calculation of q-period Stochastic Momentum into Open, High, Low and CloseBuffer[]

   CalculatePlotBuffer(AppliedPrices[0], open, high, low, close, OpenBuffer, pos, rates_total);
   CalculatePlotBuffer(AppliedPrices[1], open, high, low, close, HighBuffer, pos, rates_total);
   CalculatePlotBuffer(AppliedPrices[2], open, high, low, close, LowBuffer, pos, rates_total);
   CalculatePlotBuffer(AppliedPrices[3], open, high, low, close, CloseBuffer, pos, rates_total);

   for(int i = pos; i < rates_total; i++)
     {
      ColorsBuffer[i] = Color(OpenBuffer, CloseBuffer, i);
     }

//--- OnCalculate done. Return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



//+-----------------------------------------------------------------------+
//|Function that calculates one buffer at a time from the ohlc inputs     |
//+-----------------------------------------------------------------------+
int   CalculatePlotBuffer(ENUM_APPLIED_PRICE AppliedPrice,
                          const double &o[],  //ohlc buffers are passed by reference
                          const double &h[],
                          const double &l[],
                          const double &c[],
                          double &DstBuffer[],
                          int pos,
                          int rates)
  {
   int i, k;
   double min, max;
   for(i = pos; i < rates; i++)
     {
      double HH = 0.0;    //intermediate variables store the HH and LL over q period
      double LL = 0.0;

      min = 1000000.0;
      max = -1000000.0;
      for(k = i - (Inpq - 1); k <= i; k++)
        {
         if(min > l[k])    //this whole function has been adopted from Andrey F. Zelinsky
            min = l[k];
         if(max < h[k])
            max = h[k];
        }
      LL = min;
      HH = max;
      // calculation of destination Buffer[] - q-period Stochastic Momentum (formula through ternary operator)
      DstBuffer[i] = InpFormula ? (Price(i, AppliedPrice, o, h, l, c) - (0.5 * (LL + HH))) : (100 * Price(i, AppliedPrice, o, h, l, c) / (0.5 * (LL + HH)));

     }
   return(ArraySize(DstBuffer));
  }


//+-------------------------------------------------------------------------------------+
//| Function that gets a certain index of a price buffer depending on the applied price |
//+-------------------------------------------------------------------------------------+
double Price(int idx, ENUM_APPLIED_PRICE applied, const double &o[], const double &h[], const double &l[], const double &c[])
//--- ohlc buffers had to be provided by reference again
  {
   double price = 0.0;
   switch(applied)
     {
      case PRICE_OPEN :
         price = o[idx];
         break;

      case PRICE_HIGH :
         price = h[idx];
         break;

      case PRICE_LOW :
         price = l[idx];
         break;

      case  PRICE_CLOSE:
         price = c[idx];
         break;

      case  PRICE_MEDIAN:
         price = (h[idx] + l[idx]) / 2;
         break;

      case  PRICE_TYPICAL:
         price = (h[idx] + l[idx] + c[idx]) / 3;
         break;

      case  PRICE_WEIGHTED:
         price = (h[idx] + l[idx] + (2 * c[idx])) / 4;
         break;
     }
   return(price);
  }

//+------------------------------------------------------------------+
//| Color function                                                   |
//+------------------------------------------------------------------+
double   Color(double &Open[], double &Close[], int idx)
  {
   double Color = 0.0;
   Color = (Open[idx] > Close[idx]) ? 1.0 : 2.0 ;
   return(Color);
  }
//+------------------------------------------------------------------+
