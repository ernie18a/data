//+------------------------------------------------------------------+
//|                                  Adaptive Alpha Beta Channel     |
//|                                      Email : amarfx@gmail.com    |
//+------------------------------------------------------------------+
#property copyright "Amarnath Kondiyan Mohan"
#property link      "https://www.linkedin.com/in/amarnath-kondiyan-mohan-546293a/"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3

//--- Plot Settings (Channel Bands & Color-Coded Baseline)
#property indicator_label1  "Adaptive Upper Band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

#property indicator_label2  "Adaptive Baseline"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDodgerBlue, clrCrimson // Index 0 = Bullish (Blue), Index 1 = Bearish (Red)
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Adaptive Lower Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//--- Input Parameters
input group "--- Adaptive Engine Settings ---"
input bool                inpAutoMode    = true;           // True Auto Mode (Dynamic Alpha/Beta)
input int                 inpAutoPeriod  = 14;             // Efficiency Lookback (For Auto Mode)
input double              inpStaticAlpha = 0.2;            // Static Alpha (Used if Auto is false)
input double              inpStaticBeta  = 0.05;           // Static Beta (Used if Auto is false)

input group "--- Channel Settings ---"
input int                 inpChannelPeriod = 20;           // Volatility Lookback Period
input double              inpMultiplier    = 2.0;          // Band Multiplier (Width Factor)

input group "--- Dashboard Grid Settings ---"
input string              inpSymbols     = "EURUSD,GBPUSD,USDJPY,AUDUSD,BTCUSD"; // Symbols
input bool                showM5         = true;           // Show M5
input bool                showM15        = true;           // Show M15
input bool                showH1         = true;           // Show H1
input bool                showH4         = true;           // Show H4
input bool                showD1         = true;           // Show D1

//--- Indicator Buffers
double         UpperBuffer[];    // Upper Channel Band Coordinates
double         PriceBuffer[];    // Plotted Centerline Coordinates
double         ColorBuffer[];    // Plotted Baseline Color Index (0 or 1)
double         LowerBuffer[];    // Lower Channel Band Coordinates
double         VelocityBuffer[]; // Internal Tracking Calculation Buffer

//--- UI & Engine Global Variables
string         prefix = "Adpt_AB_Matrix_";
string         arrSymbols[];
int            totalSymbols = 0;
ENUM_TIMEFRAMES arrTFs[5];
string         arrTFNames[5];
int            totalTFs = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Bind arrays to structural indicator buffers
   SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, PriceBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3, LowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, VelocityBuffer, INDICATOR_CALCULATIONS);

   ArraySetAsSeries(UpperBuffer, true);
   ArraySetAsSeries(PriceBuffer, true);
   ArraySetAsSeries(ColorBuffer, true);
   ArraySetAsSeries(LowerBuffer, true);
   ArraySetAsSeries(VelocityBuffer, true);

//--- Parse Symbols Input List
   string cleanSymbols = inpSymbols;
   StringReplace(cleanSymbols, " ", "");
   totalSymbols = StringSplit(cleanSymbols, ',', arrSymbols);

//--- Configure Active Timeframes Array
   totalTFs = 0;
   if(showM5)
     {
      arrTFs[totalTFs] = PERIOD_M5;
      arrTFNames[totalTFs] = "M5";
      totalTFs++;
     }
   if(showM15)
     {
      arrTFs[totalTFs] = PERIOD_M15;
      arrTFNames[totalTFs] = "M15";
      totalTFs++;
     }
   if(showH1)
     {
      arrTFs[totalTFs] = PERIOD_H1;
      arrTFNames[totalTFs] = "H1";
      totalTFs++;
     }
   if(showH4)
     {
      arrTFs[totalTFs] = PERIOD_H4;
      arrTFNames[totalTFs] = "H4";
      totalTFs++;
     }
   if(showD1)
     {
      arrTFs[totalTFs] = PERIOD_D1;
      arrTFNames[totalTFs] = "D1";
      totalTFs++;
     }

   CreateDashboardObjects();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, prefix);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int required_bars = MathMax(inpChannelPeriod, inpAutoPeriod) + 2;
   if(rates_total < required_bars)
      return(0);

   ArraySetAsSeries(price, true);
   int limit = rates_total - prev_calculated;

   if(prev_calculated == 0)
     {
      limit = rates_total - required_bars;
      PriceBuffer[limit+1] = price[limit+1];
      ColorBuffer[limit+1] = 0;
      VelocityBuffer[limit+1] = 0.0;
      UpperBuffer[limit+1] = price[limit+1];
      LowerBuffer[limit+1] = price[limit+1];
     }

//--- Main History Calculation Loop
   for(int i = limit; i >= 0; i--)
     {
      double currentAlpha = inpStaticAlpha;
      double currentBeta  = inpStaticBeta;

      //--- TRUE AUTO MODE ENGINE: Dynamic Alpha/Beta based on Efficiency Ratio
      if(inpAutoMode)
        {
         double direction = MathAbs(price[i] - price[i + inpAutoPeriod]);
         double volatility = 0.0;

         for(int j = 0; j < inpAutoPeriod; j++)
           {
            volatility += MathAbs(price[i + j] - price[i + j + 1]);
           }

         double ER = (volatility > 0) ? (direction / volatility) : 0.0;

         // Smooth factor mapping ER to dynamic speeds (Fastest: 0.8, Slowest: 0.05)
         double smooth = ER * (0.8 - 0.05) + 0.05;

         // Square the smooth factor to highly penalize choppy noise (KAMA logic)
         currentAlpha = smooth * smooth;

         // Beta dynamically scales as a fraction of Alpha to keep velocity stable
         currentBeta = currentAlpha * 0.25;
        }

      //--- Core Alpha-Beta Calculation with Dynamic Parameters
      double pred_P = PriceBuffer[i+1] + VelocityBuffer[i+1];
      double error = price[i] - pred_P;

      PriceBuffer[i]    = pred_P + (currentAlpha * error);
      VelocityBuffer[i] = VelocityBuffer[i+1] + (currentBeta * error);

      // Assign line color based on velocity state
      ColorBuffer[i] = (VelocityBuffer[i] >= 0.0) ? 0 : 1;

      //--- Calculate Volatility Deviation for the Channel Bands
      double sumSquares = 0;
      int count = 0;
      for(int j = 0; j < inpChannelPeriod; j++)
        {
         if(i + j < rates_total)
           {
            double diff = price[i+j] - PriceBuffer[i+j];
            sumSquares += diff * diff;
            count++;
           }
        }

      double stdDev = (count > 0) ? MathSqrt(sumSquares / count) : 0.0;

      UpperBuffer[i] = PriceBuffer[i] + (inpMultiplier * stdDev);
      LowerBuffer[i] = PriceBuffer[i] - (inpMultiplier * stdDev);
     }

   UpdateDashboardMatrix();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Helper Matrix Calculation: Fetches live data for external targets|
//+------------------------------------------------------------------+
int GetStateForTarget(string symbol, ENUM_TIMEFRAMES tf)
  {
   double closePrices[];
   ArraySetAsSeries(closePrices, true);

// Fetch enough history to satisfy the efficiency lookback period
   int depth = MathMax(50, inpAutoPeriod * 2);
   int copied = CopyClose(symbol, tf, 0, depth, closePrices);
   if(copied < inpAutoPeriod + 2)
      return(-1);

   double p = closePrices[copied-1];
   double v = 0.0;

// Start processing from older bars to recent
   for(int i = copied - inpAutoPeriod - 2; i >= 0; i--)
     {
      double currentAlpha = inpStaticAlpha;
      double currentBeta  = inpStaticBeta;

      if(inpAutoMode)
        {
         double direction = MathAbs(closePrices[i] - closePrices[i + inpAutoPeriod]);
         double volatility = 0.0;
         for(int j = 0; j < inpAutoPeriod; j++)
            volatility += MathAbs(closePrices[i+j] - closePrices[i+j+1]);

         double ER = (volatility > 0) ? (direction / volatility) : 0.0;
         double smooth = ER * (0.8 - 0.05) + 0.05;
         currentAlpha = smooth * smooth;
         currentBeta = currentAlpha * 0.25;
        }

      double pred_p = p + v;
      double err = closePrices[i] - pred_p;
      p += currentAlpha * err;
      v += currentBeta * err;
     }

   return (v >= 0.0) ? 0 : 1; // 0 = Bullish, 1 = Bearish
  }

//+------------------------------------------------------------------+
//| UI: Create Graphic Labels Hierarchy                              |
//+------------------------------------------------------------------+
void CreateDashboardObjects()
  {
   int startX = 20, startY = 30, rowHeight = 22, colWidth = 65;

   for(int t = 0; t < totalTFs; t++)
      CreateLabel(prefix + "Head_" + arrTFNames[t], arrTFNames[t], startX + 90 + (t * colWidth), startY, clrSilver, 9, true);

   for(int s = 0; s < totalSymbols; s++)
     {
      int yPos = startY + 25 + (s * rowHeight);
      CreateLabel(prefix + "Row_" + arrSymbols[s], arrSymbols[s], startX, yPos, clrWhite, 10, true);

      for(int t = 0; t < totalTFs; t++)
        {
         string cellName = prefix + "Cell_" + arrSymbols[s] + "_" + arrTFNames[t];
         CreateLabel(cellName, "[---]", startX + 90 + (t * colWidth), yPos, clrGray, 9, false);
        }
     }
  }

//+------------------------------------------------------------------+
//| UI: Update Real-time Status Grid Values                          |
//+------------------------------------------------------------------+
void UpdateDashboardMatrix()
  {
   for(int s = 0; s < totalSymbols; s++)
     {
      for(int t = 0; t < totalTFs; t++)
        {
         string cellName = prefix + "Cell_" + arrSymbols[s] + "_" + arrTFNames[t];
         int state = GetStateForTarget(arrSymbols[s], arrTFs[t]);

         if(state == 0)
           {
            ObjectSetString(0, cellName, OBJPROP_TEXT, "BULL");
            ObjectSetInteger(0, cellName, OBJPROP_COLOR, clrLimeGreen);
           }
         else
            if(state == 1)
              {
               ObjectSetString(0, cellName, OBJPROP_TEXT, "BEAR");
               ObjectSetInteger(0, cellName, OBJPROP_COLOR, clrCrimson);
              }
            else
              {
               ObjectSetString(0, cellName, OBJPROP_TEXT, "WAIT");
               ObjectSetInteger(0, cellName, OBJPROP_COLOR, clrOrange);
              }
        }
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| UI Elements Wrapper Method                                       |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr, int size, bool bold)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Trebuchet MS Bold" : "Trebuchet MS");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+------------------------------------------------------------------+
