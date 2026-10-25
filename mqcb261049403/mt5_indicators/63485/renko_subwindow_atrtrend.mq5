#property copyright "Copyright © 2020-2025"
#property link      "https://forge.mql5.io "
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   5

//--- Histogram Plot
#property indicator_label1  "RenkoHistogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//--- ATR Trend Envelope Lines
#property indicator_label2  "TrendEnvelopeUp"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "TrendEnvelopeDown"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- Arrows
#property indicator_label4  "ArrowUp"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDodgerBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

#property indicator_label5  "ArrowDown"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrCrimson
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

//--- Input Parameters
input ushort      InpSize        = 30;     // Renko brick size (in points)
input int         inpAtrPeriod   = 14;    // ATR period
input double      inpDeviation   = 1.5;   // ATR multiplier in Renko blocks

//--- Renko Buffers
double ExtRenkoBufferUP[];
double ExtRenkoBufferDOWN[];
double ExtRenkoColorBuffer[];

//--- ATR Buffers
double ATRUpLineBuffer[];
double ATRDownLineBuffer[];
double ArrowUpBuffer[];
double ArrowDownBuffer[];

//--- Static Variables
static double price_UP = 0;
static double price_DOWN = 0;
static datetime prev_time = 0;

//--- Horizontal Line Names
string m_name_ceil  = "ceil";
string m_name_round = "round";
string m_name_floor = "floor";

//--- Work Array for ATR Trend Envelope
double workTrendEnvelopes[][3]; // [i][0] = min, [i][1] = max, [i][2] = trend
#define _teSmin 0
#define _teSmax 1
#define _teTrend 2

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //--- Histogram Buffers
   SetIndexBuffer(0, ExtRenkoBufferUP, INDICATOR_DATA);
   SetIndexBuffer(1, ExtRenkoBufferDOWN, INDICATOR_DATA);
   SetIndexBuffer(2, ExtRenkoColorBuffer, INDICATOR_COLOR_INDEX);

   //--- ATR Buffers
   SetIndexBuffer(3, ATRUpLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ATRDownLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, ArrowUpBuffer, INDICATOR_DATA);
   SetIndexBuffer(6, ArrowDownBuffer, INDICATOR_DATA);

   //--- Arrow Settings
   PlotIndexSetInteger(4, PLOT_ARROW, 159);
   PlotIndexSetInteger(5, PLOT_ARROW, 159);

   //--- Indicator Name
   string short_name = StringFormat("Renko+ATR(%d,%d)", InpSize, inpAtrPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);

   //--- Point Size Adjustment
   int digits_adjust = 1;
   if(Digits() == 3 || Digits() == 5)
      digits_adjust = 10;
   double ExtSize = Point() * digits_adjust * InpSize;

   //--- Create Horizontal Lines
   HLineCreate(0, m_name_ceil, 0, 0.0, clrBlue, STYLE_DASH, 1);
   HLineCreate(0, m_name_round, 0, 0.0, clrGray, STYLE_DASH, 1);
   HLineCreate(0, m_name_floor, 0, 0.0, clrRed, STYLE_DASH, 1);

   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
   if(time[rates_total - 1] == prev_time)
      return(rates_total);

   //--- Renko Calculation
   int limit = prev_calculated > 0 ? prev_calculated - 1 : 1;
   if(prev_calculated == 0)
   {
      price_UP = 0;
      price_DOWN = 0;
      prev_time = 0;
      ArrayInitialize(workTrendEnvelopes, 0.0);
      ArrayInitialize(ExtRenkoBufferUP, 0.0);
      ArrayInitialize(ExtRenkoBufferDOWN, 0.0);
      ArrayInitialize(ExtRenkoColorBuffer, 0);
   }

   for(int i = limit; i < rates_total && !_StopFlag; i++)
   {
      double price_ceil, price_round, price_floor;
      Math(close[i], InpSize, price_ceil, price_round, price_floor);

      if(close[i] >= price_DOWN && close[i] <= price_UP)
      {
         ExtRenkoBufferUP[i] = price_UP;
         ExtRenkoBufferDOWN[i] = price_DOWN;
         ExtRenkoColorBuffer[i] = ExtRenkoColorBuffer[i - 1];
      }
      else if(close[i] < price_DOWN)
      {
         if(CompareDoubles(price_round, price_DOWN))
         {
            ExtRenkoBufferUP[i] = price_UP;
            ExtRenkoBufferDOWN[i] = price_DOWN;
            ExtRenkoColorBuffer[i] = ExtRenkoColorBuffer[i - 1];
         }
         else
         {
            price_UP = price_ceil;
            price_DOWN = price_round;
            ExtRenkoBufferUP[i] = price_UP;
            ExtRenkoBufferDOWN[i] = price_DOWN;
            ExtRenkoColorBuffer[i] = 1;
         }
      }
      else if(close[i] > price_UP)
      {
         if(CompareDoubles(price_round, price_UP))
         {
            ExtRenkoBufferUP[i] = price_UP;
            ExtRenkoBufferDOWN[i] = price_DOWN;
            ExtRenkoColorBuffer[i] = ExtRenkoColorBuffer[i - 1];
         }
         else
         {
            price_DOWN = price_floor;
            price_UP = price_round;
            ExtRenkoBufferUP[i] = price_UP;
            ExtRenkoBufferDOWN[i] = price_DOWN;
            ExtRenkoColorBuffer[i] = 0;
         }
      }

      HLineMove(0, m_name_ceil, price_ceil);
      HLineMove(0, m_name_round, price_round);
      HLineMove(0, m_name_floor, price_floor);
   }

   prev_time = time[rates_total - 1];

   //--- ATR Trend Envelope Calculation
   for(int i = 0; i < rates_total; i++)
   {
      double _atr_blocks = 0;

      // Calculate ATR in Renko blocks
      for(int k = 0; k < inpAtrPeriod && (i - k - 1) >= 0; k++)
      {
         double tr = MathMax(high[i - k], close[i - k - 1]) - MathMin(low[i - k], close[i - k - 1]);
         _atr_blocks += tr / (Point() * InpSize);  // Convert to Renko blocks
      }
      _atr_blocks /= inpAtrPeriod;

      // Convert back to price deviation
      double deviation = _atr_blocks * Point() * InpSize * inpDeviation;

      // Get current Renko brick values
      double renko_high = ExtRenkoBufferUP[i];
      double renko_low = ExtRenkoBufferDOWN[i];

      sTrendEnvelope result;
      result = iTrendEnvelope(renko_high, renko_low, close[i], deviation, i, rates_total);

      ATRUpLineBuffer[i]   = result.upline;
      ATRDownLineBuffer[i] = result.downline;
      ArrowUpBuffer[i]     = (result.trendChange && result.trend == 1) ? result.upline   : EMPTY_VALUE;
      ArrowDownBuffer[i]   = (result.trendChange && result.trend == -1) ? result.downline : EMPTY_VALUE;
     }

   return(rates_total);
}

//------------------------------------------------------------------
// ATR Trend Envelope Function
//------------------------------------------------------------------
struct sTrendEnvelope
{
   double upline;
   double downline;
   int trend;
   bool trendChange;
};

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if(ArrayRange(workTrendEnvelopes, 0) != bars)
      ArrayResize(workTrendEnvelopes, bars);
   instanceNo *= 3;

   workTrendEnvelopes[i][instanceNo + _teSmax] = valueh + deviation;
   workTrendEnvelopes[i][instanceNo + _teSmin] = valuel - deviation;

   workTrendEnvelopes[i][instanceNo + _teTrend] = 
      (i > 0) ? 
         (value > workTrendEnvelopes[i - 1][instanceNo + _teSmax]) ? 1 :
         (value < workTrendEnvelopes[i - 1][instanceNo + _teSmin]) ? -1 :
         workTrendEnvelopes[i - 1][instanceNo + _teTrend] : 0;

   if(i > 0 && workTrendEnvelopes[i][instanceNo + _teTrend] > 0 && 
      workTrendEnvelopes[i][instanceNo + _teSmin] < workTrendEnvelopes[i - 1][instanceNo + _teSmin])
      workTrendEnvelopes[i][instanceNo + _teSmin] = workTrendEnvelopes[i - 1][instanceNo + _teSmin];

   if(i > 0 && workTrendEnvelopes[i][instanceNo + _teTrend] < 0 && 
      workTrendEnvelopes[i][instanceNo + _teSmax] > workTrendEnvelopes[i - 1][instanceNo + _teSmax])
      workTrendEnvelopes[i][instanceNo + _teSmax] = workTrendEnvelopes[i - 1][instanceNo + _teSmax];

   sTrendEnvelope _result;
   _result.trend = (int)workTrendEnvelopes[i][instanceNo + _teTrend];
   _result.trendChange = (i > 0) ? (workTrendEnvelopes[i][instanceNo + _teTrend] != workTrendEnvelopes[i - 1][instanceNo + _teTrend]) : false;
   _result.upline = (workTrendEnvelopes[i][instanceNo + _teTrend] == 1) ? workTrendEnvelopes[i][instanceNo + _teSmin] : EMPTY_VALUE;
   _result.downline = (workTrendEnvelopes[i][instanceNo + _teTrend] == -1) ? workTrendEnvelopes[i][instanceNo + _teSmax] : EMPTY_VALUE;

   return _result;
}

//------------------------------------------------------------------
// Math Function for Renko Rounding
//------------------------------------------------------------------
void Math(const double price, const double step, double &price_ceil, double &price_round, double &price_floor)
{
   double point = Point();
   double step1 = MathRound(price / point / step);
   price_round = step * step1 * point;

   double step1_ceil = MathCeil((price_round + step / 2.0 * point) / point / step);
   double step1_floor = MathFloor((price_round - step / 2.0 * point) / point / step);

   price_ceil = step * step1_ceil * point;
   price_floor = step * step1_floor * point;
}

//------------------------------------------------------------------
// Compare Doubles
//------------------------------------------------------------------
bool CompareDoubles(double number1, double number2)
{
   return(NormalizeDouble(number1 - number2, Digits() - 1) == 0);
}

//------------------------------------------------------------------
// Horizontal Line Functions
//------------------------------------------------------------------
bool HLineCreate(long chart_ID, string name, int sub_window, double price, color clr, ENUM_LINE_STYLE style, int width)
{
   if(!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price))
   {
      Print(__FUNCTION__, ": failed to create line! Error: ", GetLastError());
      return false;
   }
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
   return true;
}

bool HLineMove(long chart_ID, string name, double price)
{
   if(!ObjectMove(chart_ID, name, 0, 0, price))
   {
      Print(__FUNCTION__, ": failed to move line! Error: ", GetLastError());
      return false;
   }
   return true;
}

bool HLineDelete(long chart_ID, string name)
{
   return ObjectDelete(chart_ID, name);
}

//------------------------------------------------------------------
// Deinitialization
//------------------------------------------------------------------
void OnDeinit(const int reason)
{
   HLineDelete(0, m_name_ceil);
   HLineDelete(0, m_name_round);
   HLineDelete(0, m_name_floor);
}