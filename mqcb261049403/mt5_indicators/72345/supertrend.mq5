//+------------------------------------------------------------------+
//|                                                   Supertrend.mq5 |
//|                                                    Hammad Dilber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Hammad Dilber"
#property link        ""
#property version     "1.00"
#property description "Supertrend Indicator - ATR Based Trend Following"
#property strict

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4

//--- Plot 1: Up Trend Line (green)
#property indicator_label1  "Up Trend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot 2: Down Trend Line (red)
#property indicator_label2  "Down Trend"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Plot 3: Buy Signal Arrow
#property indicator_label3  "Buy Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_width3  2

//--- Plot 4: Sell Signal Arrow
#property indicator_label4  "Sell Signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2

//--- Input Parameters
input int    ATRPeriod       = 10;     // ATR Period
input double ATRMultiplier   = 3.0;   // ATR Multiplier
input bool   ChangeATRMethod = true;  // Change ATR Calculation Method? (true=ATR, false=SMA of TR)
input bool   ShowSignals     = true;  // Show Buy/Sell Signals?

//--- Indicator Buffers
double UpTrendBuffer[];     // Green line (up trend)
double DnTrendBuffer[];     // Red line (down trend)
double BuySignalBuffer[];   // Buy arrow
double SellSignalBuffer[];  // Sell arrow
double UpBuffer[];          // Internal: upper band values
double DnBuffer[];          // Internal: lower band values

//--- ATR Handle
int atrHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Bind buffers to plots
   SetIndexBuffer(0, UpTrendBuffer,   INDICATOR_DATA);
   SetIndexBuffer(1, DnTrendBuffer,   INDICATOR_DATA);
   SetIndexBuffer(2, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, SellSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(4, UpBuffer,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, DnBuffer,        INDICATOR_CALCULATIONS);

//--- Set arrow codes for Buy/Sell signals
   PlotIndexSetInteger(2, PLOT_ARROW, 233); // Up arrow for Buy
   PlotIndexSetInteger(3, PLOT_ARROW, 234); // Down arrow for Sell

//--- Set empty values
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- Initialize ATR indicator handle
   atrHandle = iATR(_Symbol, _Period, ATRPeriod);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Error creating ATR handle: ", GetLastError());
      return INIT_FAILED;
     }

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Supertrend(" + IntegerToString(ATRPeriod) + ", " +
                      DoubleToString(ATRMultiplier, 1) + ")");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
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
   if(rates_total < ATRPeriod + 2)
      return 0;

//--- Copy ATR values
   double atrValues[];
   if(CopyBuffer(atrHandle, 0, 0, rates_total, atrValues) <= 0)
      return 0;
   ArraySetAsSeries(atrValues, false);

//--- Determine start bar
   int startBar = (prev_calculated <= 1) ? ATRPeriod + 1 : prev_calculated - 1;

//--- Main calculation loop
   for(int i = startBar; i < rates_total; i++)
     {
      //--- Source price = hl2
      double src = (high[i] + low[i]) / 2.0;

      double atr = 0.0;
      if(ChangeATRMethod)
        {
         //--- Standard ATR
         atr = atrValues[i];
        }
      else
        {
         //--- SMA of True Range (manual)
         double sumTR = 0.0;
         for(int k = i; k > i - ATRPeriod && k > 0; k--)
           {
            double tr = MathMax(high[k], close[k-1]) - MathMin(low[k], close[k-1]);
            sumTR += tr;
           }
         atr = sumTR / ATRPeriod;
        }

      //--- Calculate basic upper and lower bands
      double up_basic = src - (ATRMultiplier * atr);
      double dn_basic = src + (ATRMultiplier * atr);

      //--- Apply trailing stop logic
      double up_prev = (i > 0 && UpBuffer[i-1] != EMPTY_VALUE) ? UpBuffer[i-1] : up_basic;
      double dn_prev = (i > 0 && DnBuffer[i-1] != EMPTY_VALUE) ? DnBuffer[i-1] : dn_basic;

      if(i > 0 && close[i-1] > up_prev)
         UpBuffer[i] = MathMax(up_basic, up_prev);
      else
         UpBuffer[i] = up_basic;

      if(i > 0 && close[i-1] < dn_prev)
         DnBuffer[i] = MathMin(dn_basic, dn_prev);
      else
         DnBuffer[i] = dn_basic;
     }

//--- Second pass: calculate trend direction and plot signals
   static int  prevTrend = 1;  // 1 = bullish, -1 = bearish
   int trend = (prev_calculated <= 1) ? 1 : prevTrend;

   for(int i = startBar; i < rates_total; i++)
     {
      int prevTrendLocal = trend;

      //--- Trend direction logic
      if(trend == -1 && close[i] > DnBuffer[i-1])
         trend = 1;
      else if(trend == 1 && close[i] < UpBuffer[i-1])
         trend = -1;

      //--- Paint trend lines
      if(trend == 1)
        {
         UpTrendBuffer[i] = UpBuffer[i];
         DnTrendBuffer[i] = EMPTY_VALUE;
        }
      else
        {
         DnTrendBuffer[i] = DnBuffer[i];
         UpTrendBuffer[i] = EMPTY_VALUE;
        }

      //--- Buy Signal: trend flipped from -1 to 1
      if(trend == 1 && prevTrendLocal == -1)
        {
         BuySignalBuffer[i]  = ShowSignals ? UpBuffer[i] : EMPTY_VALUE;
         SellSignalBuffer[i] = EMPTY_VALUE;
        }
      //--- Sell Signal: trend flipped from 1 to -1
      else if(trend == -1 && prevTrendLocal == 1)
        {
         SellSignalBuffer[i] = ShowSignals ? DnBuffer[i] : EMPTY_VALUE;
         BuySignalBuffer[i]  = EMPTY_VALUE;
        }
      else
        {
         BuySignalBuffer[i]  = EMPTY_VALUE;
         SellSignalBuffer[i] = EMPTY_VALUE;
        }

      prevTrend = trend;
     }

   return rates_total;
  }
//+------------------------------------------------------------------+