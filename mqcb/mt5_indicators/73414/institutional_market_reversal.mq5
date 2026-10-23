//+------------------------------------------------------------------+
//|                                Institutional Market Reversal.mq5 |
//|                                    Copyright 2026, QuantMT5 Ltd. |
//|                                         https://www.quantmt5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, QuantMT5 Ltd."
#property link      "https://www.quantmt5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_level1  55.0
#property indicator_level2  45.0
#property indicator_level3  25.0
#property indicator_level4  0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1

#property indicator_label1  "Hurst"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "ADX"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "RegScore"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1


input group "=== Hurst Settings ==="
input int    InpHurstPeriod   = 200;   //---[look back bars for Hurst calculation]---
input int    InpHurstMinChunk = 8;     //---[smallest chunk size for R/S analysis]---
input int    InpHurstSmooth   = 3;     //---[EMA smoothing on Hurst output - 1 means no smoothing]---

input group "=== ADX Settings ==="
input int    InpADXPeriod     = 14;    //---[standard ADX lookback period]---
input double InpADXThreshold  = 25.0;  //---[ADX above this means trend is active]---

input group "=== Regression Settings ==="
input int    InpRegPeriod     = 200;    //---[how many bars to fit the regression line]---
input double InpR2Threshold   = 0.60;   //---[minimum R squared needed to trust the slope]---

input group "=== Regime Thresholds ==="
input double InpHurstTrend    = 0.55;  //---[Hurst above this means trending market]---
input double InpHurstMeanRev  = 0.45;  //---[Hurst below this means mean reverting market]---

double HurstBuffer[];
double ADXBuffer[];
double RegScoreBuffer[];
int    adxHandle = INVALID_HANDLE;
static int lastSignalState = 0;

//--- object name constants (prefix keeps names unique per chart)
#define IMR_PFX            "IMR_"
#define IMR_BG             IMR_PFX "BG"
#define IMR_TITLE          IMR_PFX "Title"
#define IMR_DIVIDER        IMR_PFX "Divider"
#define IMR_LBL_HURST      IMR_PFX "LblHurst"
#define IMR_LBL_ADX        IMR_PFX "LblADX"
#define IMR_LBL_ROW        IMR_PFX "LblRow"
#define IMR_VAR_HURST      IMR_PFX "LblVarHurst"
#define IMR_VAR_ADX        IMR_PFX "LblVarADX"
#define IMR_PILL_BG        IMR_PFX "PillBG"
#define IMR_PILL_TXT       IMR_PFX "PillTxt"

//--- colour palette (BGR format for MQL5)
#define CLR_PANEL_BG       (color)0x260C05
#define CLR_PANEL_BORDER   (color)0x5A3026
#define CLR_DIVIDER        (color)0x5A3026
#define CLR_TITLE_TXT      (color)0xFF901E
#define CLR_HDR_TXT        (color)0x6699AA
#define CLR_ROW_TXT        (color)0xB99B8C
#define CLR_NEUTRAL_TXT    (color)0xCCDDEE
#define CLR_NEUTRAL_BG     (color)0x3A2E26
#define CLR_BULLISH_TXT    (color)0x00CC66
#define CLR_BULLISH_BG     (color)0x0A2A18
#define CLR_BEARISH_TXT    (color)0x3333FF
#define CLR_BEARISH_BG     (color)0x0A0A2A
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   IMR_CreatePanel();
   SetIndexBuffer(0, HurstBuffer,    INDICATOR_DATA);
   SetIndexBuffer(1, ADXBuffer,      INDICATOR_DATA);
   SetIndexBuffer(2, RegScoreBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "TrendStack");
   adxHandle = iADX(Symbol(), PERIOD_CURRENT, InpADXPeriod);
   if(adxHandle == INVALID_HANDLE)
     {
      Print("Failed to create ADX handle. Error: ", GetLastError());
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(adxHandle != INVALID_HANDLE)
      IndicatorRelease(adxHandle);
   IMR_DeletePanel();
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
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
//---[find the biggest lookback needed among all three calculations]---
   int minBars = MathMax(InpHurstPeriod + 10,
                         MathMax(2 * InpADXPeriod + 1, InpRegPeriod + 10));
   if(rates_total < minBars)
      return(0);
   int adxCopied = CopyBuffer(adxHandle, 0, 0, rates_total, ADXBuffer);
   if(adxCopied < rates_total)
     {
      for(int i = adxCopied; i < rates_total; i++)
         ADXBuffer[i] = EMPTY_VALUE;
     }
   if(adxCopied <= 0)
     {
      Print("CopyBuffer failed. Error: ", GetLastError());
      return(prev_calculated);
     }
   if(prev_calculated == 0)
     {
      ArrayInitialize(HurstBuffer,    EMPTY_VALUE);
      ArrayInitialize(RegScoreBuffer, EMPTY_VALUE);
     }
   int start = (prev_calculated == 0) ? minBars : prev_calculated;
//---[loop through every bar that needs updating]---
   for(int i = start; i < rates_total; i++)
     {
      //---[build a temporary array of closing prices for Hurst lookback]---
      double prices[];
      ArrayResize(prices, InpHurstPeriod);
      for(int j = 0; j < InpHurstPeriod; j++)
         prices[j] = close[i - InpHurstPeriod + 1 + j];
      //---[run the Hurst Exponent calculation on those prices]---
      double rawHurst = CalculateHurstRS(prices, InpHurstPeriod);
      //---[if smoothing is enabled apply EMA to reduce noise]---
      if(InpHurstSmooth > 1 && i > 0 && HurstBuffer[i - 1] != EMPTY_VALUE)
        {
         double alpha = 2.0 / (InpHurstSmooth + 1.0);
         rawHurst = rawHurst * alpha + (HurstBuffer[i - 1] / 100.0) * (1.0 - alpha);
        }
      //---[store Hurst multiplied by 100 so it fits the 0 to 100 scale]---
      HurstBuffer[i] = rawHurst * 100.0;
      //---[calculate linear regression slope and R squared for this bar]---
      double slope, r2;
      CalculateRegression(close, i, InpRegPeriod, slope, r2);
      //---[convert regression result into a direction score]---
      double regDir = 0.0;
      if(r2 >= InpR2Threshold)
         regDir = (slope > 0.0) ? 1.0 : (slope < 0.0) ? -1.0 : 0.0;
      RegScoreBuffer[i] = regDir * 100.0;
      //---[read the clean Hurst value and the ADX value for this bar]---
      double hVal   = rawHurst;
      double adxVal = (ADXBuffer[i] != EMPTY_VALUE) ? ADXBuffer[i] : 0.0;
      //---[only evaluate signal on bar index 1 the most recently closed bar]---
      if(i == rates_total - 1)
        {
         //---[check if we have valid data in all buffers before reading]---
         if(HurstBuffer[i] != EMPTY_VALUE && ADXBuffer[i] != EMPTY_VALUE && RegScoreBuffer[i] != EMPTY_VALUE)
           {
            //---[BULLISH REVERSAL: oversold in mean reverting market with strong ADX]---
            if(RegScoreBuffer[i] == -100.0)
              {
               IMR_UpdatePanel(1, HurstBuffer[i], ADXBuffer[i]);
              }
            //---[BEARISH REVERSAL: overbought in mean reverting market with strong ADX]---
            else
               if(RegScoreBuffer[i] == +100.0)
                 {
                  IMR_UpdatePanel(-1, HurstBuffer[i], ADXBuffer[i]);
                 }
               //---[NEUTRAL: neither bullish nor bearish conditions met]---
               else
                 {
                  IMR_UpdatePanel(0, RegScoreBuffer[i], ADXBuffer[i]);
                 }
           }
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| CalculateHurstRS computes the Hurst Exponent using               |
//| Rescaled Range analysis on log returns                           |
//+------------------------------------------------------------------+
double CalculateHurstRS(const double &prices[], int n)
  {
//---[need at least 20 bars for a meaningful calculation]---
   if(n < 20)
      return 0.5;
//---[step 1: convert raw prices into log returns for stationarity]---
   double returns[];
   int r = n - 1;
   ArrayResize(returns, r);
   for(int i = 1; i < n; i++)
      returns[i - 1] = (prices[i - 1] > 0.000001)
                       ? MathLog(prices[i] / prices[i - 1])
                       : 0.0;
//---[step 2: build geometric chunk sizes powers of two]---
   int chunkSizes[10];
   int cs = 0;
   int sz = InpHurstMinChunk;
   while(sz <= r / 2 && cs < 10)
     {
      chunkSizes[cs] = sz;
      cs++;
      sz *= 2;
     }
//---[if we cannot build at least 2 chunk sizes return random walk]---
   if(cs < 2)
      return 0.5;
   double logRS[];
   double logN[];
   ArrayResize(logRS, cs);
   ArrayResize(logN,  cs);
   ArrayInitialize(logRS, 0.0);
   ArrayInitialize(logN,  0.0);
//---[step 3: compute average rescaled range for each chunk size]---
   for(int c = 0; c < cs; c++)
     {
      int chunkSize = chunkSizes[c];
      int numChunks = r / chunkSize;
      if(numChunks < 2)
         continue;
      double sumRS = 0.0;
      int valid = 0;
      for(int k = 0; k < numChunks; k++)
        {
         int s = k * chunkSize;
         //---[calculate the mean of this chunk]---
         double mean = 0.0;
         for(int j = 0; j < chunkSize; j++)
            mean += returns[s + j];
         mean /= chunkSize;
         //---[build the cumulative deviation profile and find its range]---
         double maxD = -DBL_MAX;
         double minD =  DBL_MAX;
         double cum  = 0.0;
         for(int j = 0; j < chunkSize; j++)
           {
            cum += (returns[s + j] - mean);
            if(cum > maxD)
               maxD = cum;
            if(cum < minD)
               minD = cum;
           }
         double R = maxD - minD;
         //---[calculate sample standard deviation of the chunk]---
         double var = 0.0;
         for(int j = 0; j < chunkSize; j++)
            var += MathPow(returns[s + j] - mean, 2);
         var /= (chunkSize - 1);
         double S = MathSqrt(var);
         //---[only count chunks with valid standard deviation]---
         if(S > 1e-12 && R > 0)
           {
            sumRS += (R / S);
            valid++;
           }
        }
      //---[store the log of average R/S and log of chunk size]---
      if(valid > 0)
        {
         logRS[c] = MathLog(sumRS / valid);
         logN[c]  = MathLog((double)chunkSize);
        }
     }
//---[step 4: linear regression of log R/S against log chunk size]---
   double sx = 0, sy = 0, sxy = 0, sx2 = 0;
   int m = 0;
   for(int i = 0; i < cs; i++)
     {
      if(logN[i] > 0.001)
        {
         sx  += logN[i];
         sy  += logRS[i];
         sxy += logN[i] * logRS[i];
         sx2 += logN[i] * logN[i];
         m++;
        }
     }
//---[need at least 2 points for a regression line]---
   if(m < 2)
      return 0.5;
   double d = (m * sx2 - sx * sx);
   if(MathAbs(d) < 1e-10)
      return 0.5;
//---[the slope of this regression IS the Hurst Exponent]---
   double h = (m * sxy - sx * sy) / d;
//---[clamp Hurst to the theoretical 0 to 1 range]---
   if(h > 1.0)
      h = 1.0;
   if(h < 0.0)
      h = 0.0;
   return h;
  }
//+------------------------------------------------------------------+
//| CalculateRegression fits a straight line to recent closes      |
//| and returns the slope and R squared goodness of fit            |
//+------------------------------------------------------------------+
void CalculateRegression(const double &close[], int endIdx, int period,
                         double &slope, double &r2)
  {
//---[start with zero in case we exit early]---
   slope = 0.0;
   r2    = 0.0;
//---[not enough bars yet to calculate]---
   if(endIdx < period - 1)
      return;
   int n = period;
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
//---[sum up x y x*y and x squared for every bar in the lookback]---
   for(int i = 0; i < n; i++)
     {
      double x = (double)i;
      double y = close[endIdx - n + 1 + i];
      sumX  += x;
      sumY  += y;
      sumXY += x * y;
      sumX2 += x * x;
     }
//---[calculate means for x and y]---
   double xMean = sumX / n;
   double yMean = sumY / n;
   double denom = (sumX2 - n * xMean * xMean);
//---[if denominator is zero the line is vertical skip it]---
   if(MathAbs(denom) < 1e-12)
      return;
//---[calculate the slope of the best fit line]---
   slope = (sumXY - n * xMean * yMean) / denom;
//---[calculate intercept for predicted values]---
   double intercept = yMean - slope * xMean;
//---[sum of squared residuals and total sum of squares]---
   double ssRes = 0.0, ssTot = 0.0;
   for(int i = 0; i < n; i++)
     {
      double x = (double)i;
      double y = close[endIdx - n + 1 + i];
      //---[what the regression line predicts at this x]---
      double yPred = slope * x + intercept;
      //---[distance from actual price to prediction]---
      ssRes += MathPow(y - yPred, 2);
      //---[distance from actual price to mean price]---
      ssTot += MathPow(y - yMean, 2);
     }
//---[R squared tells us how well the line fits the data]---
   if(ssTot > 1e-12)
      r2 = 1.0 - ssRes / ssTot;
   else
      r2 = 0.0;
//---[R squared cannot be negative clamp to zero]---
   if(r2 < 0.0)
      r2 = 0.0;
  }
//------------------------------------------------------------------
// HELPER FUNCTION: Create Text Label                              |
//------------------------------------------------------------------
void CreateLabel(string objName, string text, int x, int y, int corner, int chartWin,
                 ENUM_ANCHOR_POINT anchor, color txtColor, string font = "Arial Bold", int fontSize = 9)
  {
   ObjectCreate(0, objName, OBJ_LABEL, chartWin, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER,     corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE,  y);
   ObjectSetString(0,  objName, OBJPROP_TEXT,       text);
   ObjectSetString(0,  objName, OBJPROP_FONT,       font);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE,   fontSize);
   ObjectSetInteger(0, objName, OBJPROP_COLOR,      txtColor);
   ObjectSetInteger(0, objName, OBJPROP_ANCHOR,     anchor);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN,     true);
  }

//------------------------------------------------------------------
// HELPER FUNCTION: Create Rectangle Label (Backgrounds/Dividers)   |
//------------------------------------------------------------------
void CreateRectangleLabel(string objName, int x, int y, int width, int height, int corner, int chartWin,
                          color bgColor, color borderColor, bool back = false, int borderWidth = 1)
  {
   ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, chartWin, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER,      corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE,       width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE,       height);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR,     bgColor);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, objName, OBJPROP_COLOR,       borderColor);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH,       borderWidth);
   ObjectSetInteger(0, objName, OBJPROP_BACK,        back);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN,      true);
  }
//------------------------------------------------------------------
// MAIN PANEL CREATION FUNCTION
//------------------------------------------------------------------
void IMR_CreatePanel(int xPos       = 10,
                     int yPos       = 30,
                     int corner     = CORNER_LEFT_UPPER,
                     int chartWin   = 0)
  {
//--- layout constants (pixels)
   const int W        = 230;   // total panel width
   const int TITLE_H  = 24;   // title bar height
   const int DIV_H    = 1;    // divider thickness
   const int HDR_H    = 20;   // column-header row height
   const int ROW_H    = 32;   // data row height
   const int PAD      = 8;    // left/right padding
   const int TOTAL_H  = TITLE_H + DIV_H + HDR_H + PAD + ROW_H * 2 + 12; // ~83 px
   const int PILL_W   = 82;
   const int PILL_H   = 22;
   CreateRectangleLabel(IMR_BG, xPos, yPos, W, TOTAL_H, corner, chartWin, CLR_PANEL_BG, CLR_PANEL_BORDER, false, 1);
   CreateLabel(IMR_TITLE, "INSTITUTIONAL MARKET REVERSAL", xPos + W / 2, yPos + 6, corner, chartWin, ANCHOR_UPPER, CLR_TITLE_TXT);
   CreateRectangleLabel(IMR_DIVIDER, xPos, yPos + TITLE_H, W, DIV_H, corner, chartWin, CLR_DIVIDER, CLR_DIVIDER);
   int rowY = yPos + TITLE_H + DIV_H + 10;
   CreateLabel(IMR_LBL_HURST, "Hurst Exponent", xPos + PAD, rowY, corner, chartWin, ANCHOR_LEFT_UPPER, CLR_ROW_TXT);
   CreateLabel(IMR_LBL_ADX, "ADX", xPos + PAD, rowY + ROW_H, corner, chartWin, ANCHOR_LEFT_UPPER, CLR_ROW_TXT);
   rowY = yPos + TITLE_H + DIV_H + HDR_H + HDR_H + 2;
   CreateLabel(IMR_LBL_ROW, "Reversals", xPos + PAD, rowY + ROW_H, corner, chartWin, ANCHOR_LEFT_UPPER, CLR_ROW_TXT);
   int pillX = xPos + W - PAD - PILL_W;
   int pillY = yPos + TITLE_H + DIV_H + 10;
   CreateLabel(IMR_VAR_HURST, "0.0", pillX + PILL_W / 2, pillY, corner, chartWin, ANCHOR_UPPER, clrOrange);
   CreateLabel(IMR_VAR_ADX, "0.0", pillX + PILL_W / 2, pillY + ROW_H, corner, chartWin, ANCHOR_UPPER, clrOrange);
   CreateRectangleLabel(IMR_PILL_BG, pillX, pillY + ROW_H * 2, PILL_W, PILL_H, corner, chartWin, CLR_NEUTRAL_BG, CLR_NEUTRAL_BG);
   CreateLabel(IMR_PILL_TXT, "NEUTRAL", pillX + PILL_W / 2, pillY + ROW_H * 2 + 4, corner, chartWin, ANCHOR_UPPER, CLR_NEUTRAL_TXT);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| IMR_UpdatePanel                                                  |
//|  Refreshes the pill colour and text whenever the signal changes. |
//|  state :  1 = Bullish | -1 = Bearish | 0 = Neutral              |
//+------------------------------------------------------------------+
void IMR_UpdatePanel(int state, double hurst, double adx)
  {
   string txt  = "NEUTRAL";
   color  cTxt = CLR_NEUTRAL_TXT;
   color  cBG  = CLR_NEUTRAL_BG;
   if(state == 1)
     {
      txt  = "BULLISH";
      cTxt = CLR_BULLISH_TXT;
      cBG  = CLR_BULLISH_BG;
     }
   else
      if(state == -1)
        {
         txt  = "BEARISH";
         cTxt = CLR_BEARISH_TXT;
         cBG  = CLR_BEARISH_BG;
        }
   ObjectSetString(0, IMR_PILL_TXT, OBJPROP_TEXT,   txt);
   ObjectSetInteger(0, IMR_PILL_TXT, OBJPROP_COLOR,  cTxt);
   ObjectSetInteger(0, IMR_PILL_BG,  OBJPROP_BGCOLOR, cBG);
   ObjectSetInteger(0, IMR_PILL_BG,  OBJPROP_COLOR,   cBG);
//---
   ObjectSetString(0, IMR_VAR_HURST, OBJPROP_TEXT,   DoubleToString(hurst, 1));
//---
   ObjectSetString(0, IMR_VAR_ADX, OBJPROP_TEXT,   DoubleToString(adx, 1));
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| IMR_DeletePanel                                                  |
//|  Removes every panel object.  Call from OnDeinit().             |
//+------------------------------------------------------------------+
void IMR_DeletePanel()
  {
   ObjectsDeleteAll(0, IMR_PFX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
