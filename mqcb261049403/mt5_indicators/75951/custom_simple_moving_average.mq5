//+------------------------------------------------------------------+
//|                                                CustomAverage.mq5 |
//|                         Copyright 2026, MQL5 CodeBase Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MQL5 CodeBase Submission"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Custom Average - a two-stage (base + smoothing) adaptive moving"
#property description "average with slope-based coloring and price/average cross signals."

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3

//--- Plot 1: the final averaged line, colored by slope direction
#property indicator_label1  "CustomAverage"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue, clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: bullish cross arrow (price crosses above the average)
#property indicator_label2  "Buy Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLime
#property indicator_width2  1

//--- Plot 3: bearish cross arrow (price crosses below the average)
#property indicator_label3  "Sell Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_width3  1

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
input group "=== Base Average Settings ==="
input int                InpMAPeriod       = 14;            // Base averaging period
input ENUM_MA_METHOD      InpMAMethod       = MODE_EMA;       // Base averaging method
input ENUM_APPLIED_PRICE  InpAppliedPrice   = PRICE_CLOSE;    // Applied price

input group "=== Secondary Smoothing ==="
input int                InpSmoothPeriod   = 5;              // Smoothing period (<=1 disables)
input ENUM_MA_METHOD      InpSmoothMethod   = MODE_SMMA;       // Smoothing method applied to base average

input group "=== Trend / Cross Signals ==="
input bool                InpShowSignals    = true;           // Show price/average crossover arrows
input int                 InpArrowUpCode    = 233;             // Wingdings code, bullish arrow
input int                 InpArrowDownCode  = 234;             // Wingdings code, bearish arrow
input color                InpArrowUpColor   = clrLime;         // Bullish arrow color
input color                InpArrowDownColor = clrRed;          // Bearish arrow color

input group "=== Visual Options ==="
input color                InpColorUp        = clrDodgerBlue;   // Line color while rising
input color                InpColorDown      = clrOrangeRed;    // Line color while falling
input int                  InpLineWidth      = 2;               // Line width
input bool                 InpShowLabel      = true;             // Show current value as chart label
input ENUM_BASE_CORNER     InpLabelCorner    = CORNER_RIGHT_UPPER; // Corner for the value label

//+------------------------------------------------------------------+
//| Indicator buffers                                                 |
//+------------------------------------------------------------------+
double ExtLineBuffer[];   // Plot 0 - final (smoothed) average value
double ExtColorBuffer[];  // Plot 0 - color index (0 = up, 1 = down)
double ExtUpArrow[];      // Plot 1 - bullish cross arrow
double ExtDownArrow[];    // Plot 2 - bearish cross arrow
double ExtBaseBuffer[];   // Calculation only - stage 1 base average

string ExtLabelName;      // Name of the on-chart value label object
int    ExtBaseStart;      // First bar index with a valid base-average value

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMAPeriod < 1)
     {
      Alert("CustomAverage: Base averaging period must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpSmoothPeriod < 0)
     {
      Alert("CustomAverage: Smoothing period must be >= 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- map buffers
   SetIndexBuffer(0, ExtLineBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtUpArrow,     INDICATOR_DATA);
   SetIndexBuffer(3, ExtDownArrow,   INDICATOR_DATA);
   SetIndexBuffer(4, ExtBaseBuffer,  INDICATOR_CALCULATIONS);

//--- empty value so gaps are not drawn
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- apply user colors / width / arrow codes
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpColorUp);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpColorDown);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpLineWidth);

   PlotIndexSetInteger(1, PLOT_ARROW, InpArrowUpCode);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpArrowUpColor);

   PlotIndexSetInteger(2, PLOT_ARROW, InpArrowDownCode);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, InpArrowDownColor);

//--- short name / precision
   IndicatorSetString(INDICATOR_SHORTNAME,
                       StringFormat("CustomAverage(%d,%s,%d,%s)",
                                     InpMAPeriod, EnumToString(InpMAMethod),
                                     InpSmoothPeriod, EnumToString(InpSmoothMethod)));
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ExtBaseStart = InpMAPeriod - 1;
   ExtLabelName = "CustomAverage_Label_" + IntegerToString(ChartID());

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove the on-chart value label created in UpdateLabel()
   ObjectDelete(0, ExtLabelName);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Returns the requested applied price for bar idx                  |
//+------------------------------------------------------------------+
double GetPrice(const int idx, const ENUM_APPLIED_PRICE applied,
                 const double &open[], const double &high[],
                 const double &low[],  const double &close[])
  {
   switch(applied)
     {
      case PRICE_OPEN:     return(open[idx]);
      case PRICE_HIGH:     return(high[idx]);
      case PRICE_LOW:      return(low[idx]);
      case PRICE_MEDIAN:   return((high[idx] + low[idx]) / 2.0);
      case PRICE_TYPICAL:  return((high[idx] + low[idx] + close[idx]) / 3.0);
      case PRICE_WEIGHTED: return((high[idx] + low[idx] + 2.0 * close[idx]) / 4.0);
      case PRICE_CLOSE:
      default:              return(close[idx]);
     }
  }

//+------------------------------------------------------------------+
//| Stage 1: base average built directly from price                  |
//+------------------------------------------------------------------+
void CalcStage1(const int i, const double &open[], const double &high[],
                 const double &low[], const double &close[])
  {
   if(i < ExtBaseStart)
     {
      ExtBaseBuffer[i] = EMPTY_VALUE;
      return;
     }

//--- SMA and LWMA are always recomputed over the full window;
//--- EMA and SMMA are seeded with an SMA on the first valid bar,
//--- then continue recursively using the previous buffer value.
   bool needWindow = (i == ExtBaseStart || InpMAMethod == MODE_SMA || InpMAMethod == MODE_LWMA);

   if(needWindow)
     {
      if(InpMAMethod == MODE_LWMA)
        {
         double sum = 0.0;
         int    wsum = 0;
         for(int k = 0; k < InpMAPeriod; k++)
           {
            int idx = i - InpMAPeriod + 1 + k;
            int w   = k + 1;
            sum  += GetPrice(idx, InpAppliedPrice, open, high, low, close) * w;
            wsum += w;
           }
         ExtBaseBuffer[i] = sum / wsum;
        }
      else
        {
         double sum = 0.0;
         for(int idx = i - InpMAPeriod + 1; idx <= i; idx++)
            sum += GetPrice(idx, InpAppliedPrice, open, high, low, close);
         ExtBaseBuffer[i] = sum / InpMAPeriod;
        }
      return;
     }

//--- recursive branch (EMA / SMMA), i > ExtBaseStart
   double price = GetPrice(i, InpAppliedPrice, open, high, low, close);
   double prev  = ExtBaseBuffer[i - 1];

   if(InpMAMethod == MODE_EMA)
     {
      double k = 2.0 / (InpMAPeriod + 1.0);
      ExtBaseBuffer[i] = price * k + prev * (1.0 - k);
     }
   else // MODE_SMMA
     {
      ExtBaseBuffer[i] = (prev * (InpMAPeriod - 1) + price) / InpMAPeriod;
     }
  }

//+------------------------------------------------------------------+
//| Stage 2: secondary smoothing applied to the base average         |
//+------------------------------------------------------------------+
void CalcStage2(const int i)
  {
   if(ExtBaseBuffer[i] == EMPTY_VALUE)
     {
      ExtLineBuffer[i] = EMPTY_VALUE;
      return;
     }

   if(InpSmoothPeriod <= 1)
     {
      ExtLineBuffer[i] = ExtBaseBuffer[i];
      return;
     }

   int localIndex = i - ExtBaseStart;   // number of valid base bars up to and including i, minus 1
   if(localIndex < InpSmoothPeriod - 1)
     {
      ExtLineBuffer[i] = EMPTY_VALUE;
      return;
     }

   bool needWindow = (localIndex == InpSmoothPeriod - 1 ||
                       InpSmoothMethod == MODE_SMA || InpSmoothMethod == MODE_LWMA);

   if(needWindow)
     {
      if(InpSmoothMethod == MODE_LWMA)
        {
         double sum = 0.0;
         int    wsum = 0;
         for(int k = 0; k < InpSmoothPeriod; k++)
           {
            int idx = i - InpSmoothPeriod + 1 + k;
            int w   = k + 1;
            sum  += ExtBaseBuffer[idx] * w;
            wsum += w;
           }
         ExtLineBuffer[i] = sum / wsum;
        }
      else
        {
         double sum = 0.0;
         for(int idx = i - InpSmoothPeriod + 1; idx <= i; idx++)
            sum += ExtBaseBuffer[idx];
         ExtLineBuffer[i] = sum / InpSmoothPeriod;
        }
      return;
     }

//--- recursive branch (EMA / SMMA)
   double src  = ExtBaseBuffer[i];
   double prev = ExtLineBuffer[i - 1];

   if(InpSmoothMethod == MODE_EMA)
     {
      double k = 2.0 / (InpSmoothPeriod + 1.0);
      ExtLineBuffer[i] = src * k + prev * (1.0 - k);
     }
   else // MODE_SMMA
     {
      ExtLineBuffer[i] = (prev * (InpSmoothPeriod - 1) + src) / InpSmoothPeriod;
     }
  }

//+------------------------------------------------------------------+
//| Creates or refreshes the on-chart "current value" label          |
//+------------------------------------------------------------------+
void UpdateLabel(const double value)
  {
   if(!InpShowLabel)
      return;

   if(ObjectFind(0, ExtLabelName) < 0)
     {
      ObjectCreate(0, ExtLabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_CORNER,     InpLabelCorner);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_XDISTANCE,  10);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_YDISTANCE,  20);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_FONTSIZE,   9);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_COLOR,      clrSilver);
      ObjectSetString(0,  ExtLabelName, OBJPROP_FONT,       "Consolas");
      ObjectSetInteger(0, ExtLabelName, OBJPROP_BACK,       false);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, ExtLabelName, OBJPROP_HIDDEN,     true);
     }

   if(value != EMPTY_VALUE)
      ObjectSetString(0, ExtLabelName, OBJPROP_TEXT,
                       StringFormat("CustomAverage: %s", DoubleToString(value, _Digits)));
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   if(rates_total < ExtBaseStart + 1)
      return(0);

//--- only recalculate what changed since the previous call
   int start = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
     {
      CalcStage1(i, open, high, low, close);
      CalcStage2(i);

      //--- slope-based coloring (0 = rising/blue, 1 = falling/orange)
      if(ExtLineBuffer[i] != EMPTY_VALUE && i > 0 && ExtLineBuffer[i - 1] != EMPTY_VALUE)
         ExtColorBuffer[i] = (ExtLineBuffer[i] >= ExtLineBuffer[i - 1]) ? 0.0 : 1.0;
      else
         ExtColorBuffer[i] = 0.0;

      //--- price / average crossover signals
      ExtUpArrow[i]   = EMPTY_VALUE;
      ExtDownArrow[i] = EMPTY_VALUE;

      if(InpShowSignals && i > 0 &&
         ExtLineBuffer[i] != EMPTY_VALUE && ExtLineBuffer[i - 1] != EMPTY_VALUE)
        {
         bool prevBelow = close[i - 1] < ExtLineBuffer[i - 1];
         bool nowAbove  = close[i]     > ExtLineBuffer[i];
         bool prevAbove = close[i - 1] > ExtLineBuffer[i - 1];
         bool nowBelow  = close[i]     < ExtLineBuffer[i];

         double range  = high[i] - low[i];
         double offset = (range > 0.0) ? range * 0.5 : 10.0 * _Point;

         if(prevBelow && nowAbove)
            ExtUpArrow[i] = low[i] - offset;

         if(prevAbove && nowBelow)
            ExtDownArrow[i] = high[i] + offset;
        }
     }

//--- refresh the value label using the most recent bar
   UpdateLabel(ExtLineBuffer[rates_total - 1]);

   return(rates_total);
  }
//+------------------------------------------------------------------+