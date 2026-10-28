//+------------------------------------------------------------------+
//|                         Pivot SuperTrend.mq5                     |
//|                             BhanuCodeLab                         |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.00"
#property description "Pivot-driven adaptive trend indicator with a weighted pivot center."

#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots   7

//--- Adaptive trailing trend line
#property indicator_label1  "Pivot Trend Trail"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLime,clrRed,clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Weighted pivot center
#property indicator_label2  "Weighted Pivot Center"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDodgerBlue,clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Confirmed support level
#property indicator_label3  "Confirmed Support"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_width3  1

//--- Confirmed resistance level
#property indicator_label4  "Confirmed Resistance"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  1

//--- EA-accessible signal and trend buffers
#property indicator_label5  "Long Signal Price"
#property indicator_type5   DRAW_NONE
#property indicator_label6  "Short Signal Price"
#property indicator_type6   DRAW_NONE
#property indicator_label7  "Trend Direction"
#property indicator_type7   DRAW_NONE

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "01. Pivot SuperTrend Engine"
input int     bclSwingRadius           = 2;             // Bars on each side of a confirmed pivot
input double  bclAtrMultiplier         = 3.0;           // ATR multiplier applied to the trend trail
input int     bclAtrPeriod             = 10;            // ATR calculation period

input group "02. Chart Presentation"
input bool    bclShowSwingMarks        = false;         // Show confirmed pivot-high and pivot-low marks
input bool    bclShowTradeTags         = true;          // Show BUY and SELL signal tags
input bool    bclShowCenterLine        = false;         // Show the weighted pivot center line
input bool    bclShowPivotLevels       = false;         // Show confirmed support and resistance levels
input int     bclHistoryBars           = 1500;          // Maximum history used for chart text objects
input int     bclTrendLineWidth        = 2;             // Trend trail line width
input int     bclTextSize              = 8;             // Pivot and signal text size

input group "03. Display Colors"
input color   bclBullTrailColor        = clrLime;       // Bullish trend trail color
input color   bclBearTrailColor        = clrRed;        // Bearish trend trail color
input color   bclCenterBelowPriceColor = clrDodgerBlue; // Center color when below the bar midpoint
input color   bclCenterAbovePriceColor = clrTomato;     // Center color when above the bar midpoint
input color   bclSupportColor          = clrLime;       // Confirmed support color
input color   bclResistanceColor       = clrRed;        // Confirmed resistance color
input color   bclBuyTagColor           = clrLime;       // BUY tag color
input color   bclSellTagColor          = clrRed;        // SELL tag color

input group "04. Signal Notifications"
input bool    bclEnablePopupAlert      = false;         // Enable terminal popup alerts
input bool    bclEnablePushAlert       = false;         // Enable mobile push notifications
input bool    bclEnableEmailAlert      = false;         // Enable email notifications
input bool    bclAlertOnClosedBar      = true;          // Generate alerts only from a closed candle

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double bclTrailBuffer[];
double bclTrailColorBuffer[];
double bclCenterBuffer[];
double bclCenterColorBuffer[];
double bclSupportBuffer[];
double bclResistanceBuffer[];
double bclLongSignalBuffer[];
double bclShortSignalBuffer[];
double bclTrendDirectionBuffer[];

double bclCenterStateBuffer[];
double bclUpperTrailStateBuffer[];
double bclLowerTrailStateBuffer[];
double bclSupportStateBuffer[];
double bclResistanceStateBuffer[];
double bclActiveTrailStateBuffer[];

//+------------------------------------------------------------------+
//| Runtime state                                                    |
//+------------------------------------------------------------------+
int      bclAtrHandle         = INVALID_HANDLE;
string   bclObjectPrefix      = "";
datetime bclLastBuyAlertTime  = 0;
datetime bclLastSellAlertTime = 0;

//+------------------------------------------------------------------+
//| Returns whether a value is valid for calculations                |
//+------------------------------------------------------------------+
bool BclIsValidValue(const double bclValue)
  {
   return(bclValue != EMPTY_VALUE && MathIsValidNumber(bclValue));
  }

//+------------------------------------------------------------------+
//| Checks whether a bar is a confirmed pivot high                   |
//+------------------------------------------------------------------+
bool BclIsConfirmedPivotHigh(const double &bclHigh[],
                             const int bclCandidateBar,
                             const int bclRadius,
                             const int bclTotalBars)
  {
   if(bclCandidateBar - bclRadius < 0 ||
      bclCandidateBar + bclRadius >= bclTotalBars)
     {
      return(false);
     }

   const double bclCandidatePrice = bclHigh[bclCandidateBar];

   for(int bclOffset = 1; bclOffset <= bclRadius; bclOffset++)
     {
      if(bclHigh[bclCandidateBar - bclOffset] > bclCandidatePrice)
         return(false);
     }

   for(int bclOffset = 1; bclOffset <= bclRadius; bclOffset++)
     {
      if(bclHigh[bclCandidateBar + bclOffset] >= bclCandidatePrice)
         return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Checks whether a bar is a confirmed pivot low                    |
//+------------------------------------------------------------------+
bool BclIsConfirmedPivotLow(const double &bclLow[],
                            const int bclCandidateBar,
                            const int bclRadius,
                            const int bclTotalBars)
  {
   if(bclCandidateBar - bclRadius < 0 ||
      bclCandidateBar + bclRadius >= bclTotalBars)
     {
      return(false);
     }

   const double bclCandidatePrice = bclLow[bclCandidateBar];

   for(int bclOffset = 1; bclOffset <= bclRadius; bclOffset++)
     {
      if(bclLow[bclCandidateBar - bclOffset] < bclCandidatePrice)
         return(false);
     }

   for(int bclOffset = 1; bclOffset <= bclRadius; bclOffset++)
     {
      if(bclLow[bclCandidateBar + bclOffset] <= bclCandidatePrice)
         return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Creates or updates a chart text marker                           |
//+------------------------------------------------------------------+
void BclSetTextMarker(const string bclObjectName,
                      const datetime bclMarkerTime,
                      const double bclMarkerPrice,
                      const string bclMarkerText,
                      const color bclMarkerColor,
                      const ENUM_ANCHOR_POINT bclAnchor)
  {
   if(ObjectFind(0, bclObjectName) < 0)
     {
      if(!ObjectCreate(0,
                       bclObjectName,
                       OBJ_TEXT,
                       0,
                       bclMarkerTime,
                       bclMarkerPrice))
        {
         return;
        }
     }
   else
     {
      if(!ObjectMove(0,
                     bclObjectName,
                     0,
                     bclMarkerTime,
                     bclMarkerPrice))
        {
         return;
        }
     }

   ObjectSetString(0,
                   bclObjectName,
                   OBJPROP_TEXT,
                   bclMarkerText);

   ObjectSetString(0,
                   bclObjectName,
                   OBJPROP_FONT,
                   "Arial");

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_FONTSIZE,
                    bclTextSize);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_COLOR,
                    bclMarkerColor);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_ANCHOR,
                    bclAnchor);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_SELECTABLE,
                    false);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_SELECTED,
                    false);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_HIDDEN,
                    true);

   ObjectSetInteger(0,
                    bclObjectName,
                    OBJPROP_BACK,
                    false);
  }

//+------------------------------------------------------------------+
//| Deletes chart objects belonging to one visual feature            |
//+------------------------------------------------------------------+
void BclDeleteFeatureObjects(const string bclFeaturePrefix)
  {
   ObjectsDeleteAll(0, bclObjectPrefix + bclFeaturePrefix);
  }

//+------------------------------------------------------------------+
//| Sends enabled signal notifications                               |
//+------------------------------------------------------------------+
void BclSendSignalAlert(const string bclSignalName,
                        const datetime bclSignalTime,
                        const double bclSignalPrice)
  {
   const string bclTimeframeName =
      EnumToString((ENUM_TIMEFRAMES)_Period);

   const string bclMessage =
      StringFormat("%s %s | %s | Price: %s | %s",
                   _Symbol,
                   bclTimeframeName,
                   bclSignalName,
                   DoubleToString(bclSignalPrice, _Digits),
                   TimeToString(bclSignalTime,
                                TIME_DATE | TIME_MINUTES));

   if(bclEnablePopupAlert)
      Alert(bclMessage);

   if(bclEnablePushAlert)
      SendNotification(bclMessage);

   if(bclEnableEmailAlert)
     {
      SendMail("BhanuCodeLab Pivot Trend Signal",
               bclMessage);
     }
  }

//+------------------------------------------------------------------+
//| Processes the latest eligible BUY or SELL alert                  |
//+------------------------------------------------------------------+
void BclProcessLatestAlert(const int bclRatesTotal,
                           const datetime &bclTime[])
  {
   if(!bclEnablePopupAlert &&
      !bclEnablePushAlert &&
      !bclEnableEmailAlert)
     {
      return;
     }

   const int bclSignalBar =
      bclAlertOnClosedBar
      ? bclRatesTotal - 2
      : bclRatesTotal - 1;

   if(bclSignalBar < 1)
      return;

   if(BclIsValidValue(bclLongSignalBuffer[bclSignalBar]) &&
      bclLastBuyAlertTime != bclTime[bclSignalBar])
     {
      bclLastBuyAlertTime = bclTime[bclSignalBar];

      BclSendSignalAlert("BUY signal",
                         bclTime[bclSignalBar],
                         bclLongSignalBuffer[bclSignalBar]);
     }

   if(BclIsValidValue(bclShortSignalBuffer[bclSignalBar]) &&
      bclLastSellAlertTime != bclTime[bclSignalBar])
     {
      bclLastSellAlertTime = bclTime[bclSignalBar];

      BclSendSignalAlert("SELL signal",
                         bclTime[bclSignalBar],
                         bclShortSignalBuffer[bclSignalBar]);
     }
  }

//+------------------------------------------------------------------+
//| Validates indicator input parameters                             |
//+------------------------------------------------------------------+
bool BclValidateInputs()
  {
   if(bclSwingRadius < 1 || bclSwingRadius > 50)
     {
      Print("Swing radius must be between 1 and 50.");
      return(false);
     }

   if(bclAtrMultiplier < 0.1 || bclAtrPeriod < 1)
     {
      Print("ATR multiplier and ATR period must be positive.");
      return(false);
     }

   if(bclHistoryBars < 100)
     {
      Print("History bars must be at least 100.");
      return(false);
     }

   if(bclTrendLineWidth < 1 || bclTrendLineWidth > 5)
     {
      Print("Trend line width must be between 1 and 5.");
      return(false);
     }

   if(bclTextSize < 6 || bclTextSize > 20)
     {
      Print("Text size must be between 6 and 20.");
      return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Binds and configures indicator buffers                           |
//+------------------------------------------------------------------+
bool BclConfigureBuffers()
  {
   if(!SetIndexBuffer(0,
                      bclTrailBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(1,
                      bclTrailColorBuffer,
                      INDICATOR_COLOR_INDEX) ||
      !SetIndexBuffer(2,
                      bclCenterBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(3,
                      bclCenterColorBuffer,
                      INDICATOR_COLOR_INDEX) ||
      !SetIndexBuffer(4,
                      bclSupportBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(5,
                      bclResistanceBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(6,
                      bclLongSignalBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(7,
                      bclShortSignalBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(8,
                      bclTrendDirectionBuffer,
                      INDICATOR_DATA) ||
      !SetIndexBuffer(9,
                      bclCenterStateBuffer,
                      INDICATOR_CALCULATIONS) ||
      !SetIndexBuffer(10,
                      bclUpperTrailStateBuffer,
                      INDICATOR_CALCULATIONS) ||
      !SetIndexBuffer(11,
                      bclLowerTrailStateBuffer,
                      INDICATOR_CALCULATIONS) ||
      !SetIndexBuffer(12,
                      bclSupportStateBuffer,
                      INDICATOR_CALCULATIONS) ||
      !SetIndexBuffer(13,
                      bclResistanceStateBuffer,
                      INDICATOR_CALCULATIONS) ||
      !SetIndexBuffer(14,
                      bclActiveTrailStateBuffer,
                      INDICATOR_CALCULATIONS))
     {
      Print("Failed to bind one or more indicator buffers. Error: ",
            GetLastError());

      return(false);
     }

   ArraySetAsSeries(bclTrailBuffer, false);
   ArraySetAsSeries(bclTrailColorBuffer, false);
   ArraySetAsSeries(bclCenterBuffer, false);
   ArraySetAsSeries(bclCenterColorBuffer, false);
   ArraySetAsSeries(bclSupportBuffer, false);
   ArraySetAsSeries(bclResistanceBuffer, false);
   ArraySetAsSeries(bclLongSignalBuffer, false);
   ArraySetAsSeries(bclShortSignalBuffer, false);
   ArraySetAsSeries(bclTrendDirectionBuffer, false);
   ArraySetAsSeries(bclCenterStateBuffer, false);
   ArraySetAsSeries(bclUpperTrailStateBuffer, false);
   ArraySetAsSeries(bclLowerTrailStateBuffer, false);
   ArraySetAsSeries(bclSupportStateBuffer, false);
   ArraySetAsSeries(bclResistanceStateBuffer, false);
   ArraySetAsSeries(bclActiveTrailStateBuffer, false);

   return(true);
  }

//+------------------------------------------------------------------+
//| Configures indicator plots                                       |
//+------------------------------------------------------------------+
void BclConfigurePlots()
  {
   PlotIndexSetInteger(0,
                       PLOT_LINE_WIDTH,
                       bclTrendLineWidth);

   PlotIndexSetInteger(0,
                       PLOT_LINE_COLOR,
                       0,
                       bclBullTrailColor);

   PlotIndexSetInteger(0,
                       PLOT_LINE_COLOR,
                       1,
                       bclBearTrailColor);

   PlotIndexSetInteger(0,
                       PLOT_LINE_COLOR,
                       2,
                       clrNONE);

   PlotIndexSetInteger(1,
                       PLOT_LINE_COLOR,
                       0,
                       bclCenterBelowPriceColor);

   PlotIndexSetInteger(1,
                       PLOT_LINE_COLOR,
                       1,
                       bclCenterAbovePriceColor);

   PlotIndexSetInteger(2,
                       PLOT_ARROW,
                       159);

   PlotIndexSetInteger(2,
                       PLOT_LINE_COLOR,
                       0,
                       bclSupportColor);

   PlotIndexSetInteger(2,
                       PLOT_SHIFT,
                       -bclSwingRadius);

   PlotIndexSetInteger(3,
                       PLOT_ARROW,
                       159);

   PlotIndexSetInteger(3,
                       PLOT_LINE_COLOR,
                       0,
                       bclResistanceColor);

   PlotIndexSetInteger(3,
                       PLOT_SHIFT,
                       -bclSwingRadius);

   for(int bclPlotIndex = 0;
       bclPlotIndex < 7;
       bclPlotIndex++)
     {
      PlotIndexSetDouble(bclPlotIndex,
                         PLOT_EMPTY_VALUE,
                         EMPTY_VALUE);
     }

   const int bclFirstTrendBar =
      (bclSwingRadius * 2) + bclAtrPeriod;

   const int bclFirstPivotBar =
      bclSwingRadius * 2;

   PlotIndexSetInteger(0,
                       PLOT_DRAW_BEGIN,
                       bclFirstTrendBar);

   PlotIndexSetInteger(1,
                       PLOT_DRAW_BEGIN,
                       bclFirstTrendBar);

   PlotIndexSetInteger(2,
                       PLOT_DRAW_BEGIN,
                       bclFirstPivotBar);

   PlotIndexSetInteger(3,
                       PLOT_DRAW_BEGIN,
                       bclFirstPivotBar);
  }

//+------------------------------------------------------------------+
//| Initializes all indicator buffers                                |
//+------------------------------------------------------------------+
void BclInitializeBuffers()
  {
   ArrayInitialize(bclTrailBuffer, EMPTY_VALUE);
   ArrayInitialize(bclTrailColorBuffer, 2.0);
   ArrayInitialize(bclCenterBuffer, EMPTY_VALUE);
   ArrayInitialize(bclCenterColorBuffer, 0.0);
   ArrayInitialize(bclSupportBuffer, EMPTY_VALUE);
   ArrayInitialize(bclResistanceBuffer, EMPTY_VALUE);
   ArrayInitialize(bclLongSignalBuffer, EMPTY_VALUE);
   ArrayInitialize(bclShortSignalBuffer, EMPTY_VALUE);
   ArrayInitialize(bclTrendDirectionBuffer, 1.0);
   ArrayInitialize(bclCenterStateBuffer, EMPTY_VALUE);
   ArrayInitialize(bclUpperTrailStateBuffer, EMPTY_VALUE);
   ArrayInitialize(bclLowerTrailStateBuffer, EMPTY_VALUE);
   ArrayInitialize(bclSupportStateBuffer, EMPTY_VALUE);
   ArrayInitialize(bclResistanceStateBuffer, EMPTY_VALUE);
   ArrayInitialize(bclActiveTrailStateBuffer, EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!BclValidateInputs())
      return(INIT_PARAMETERS_INCORRECT);

   if(!BclConfigureBuffers())
      return(INIT_FAILED);

   BclConfigurePlots();

   IndicatorSetInteger(INDICATOR_DIGITS,
                       _Digits);

   IndicatorSetString(
      INDICATOR_SHORTNAME,
      StringFormat("BhanuCodeLab Pivot Trend (%d, %.2f, %d)",
                   bclSwingRadius,
                   bclAtrMultiplier,
                   bclAtrPeriod));

   bclObjectPrefix =
      StringFormat("bcl_pte_%I64d_%u_",
                   ChartID(),
                   GetTickCount());

   ObjectsDeleteAll(0, bclObjectPrefix);

   ResetLastError();

   bclAtrHandle =
      iATR(_Symbol,
           PERIOD_CURRENT,
           bclAtrPeriod);

   if(bclAtrHandle == INVALID_HANDLE)
     {
      Print("Failed to create the ATR indicator handle. Error: ",
            GetLastError());

      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                |
//+------------------------------------------------------------------+
void OnDeinit(const int bclReason)
  {
   if(bclAtrHandle != INVALID_HANDLE)
     {
      IndicatorRelease(bclAtrHandle);
      bclAtrHandle = INVALID_HANDLE;
     }

   ObjectsDeleteAll(0, bclObjectPrefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Main indicator calculation                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int bclRatesTotal,
                const int bclPrevCalculated,
                const datetime &bclTime[],
                const double &bclOpen[],
                const double &bclHigh[],
                const double &bclLow[],
                const double &bclClose[],
                const long &bclTickVolume[],
                const long &bclVolume[],
                const int &bclSpread[])
  {
   const int bclMinimumBars =
      (bclSwingRadius * 2) + bclAtrPeriod + 2;

   if(bclRatesTotal < bclMinimumBars)
      return(0);

   ArraySetAsSeries(bclTime, false);
   ArraySetAsSeries(bclOpen, false);
   ArraySetAsSeries(bclHigh, false);
   ArraySetAsSeries(bclLow, false);
   ArraySetAsSeries(bclClose, false);
   ArraySetAsSeries(bclTickVolume, false);
   ArraySetAsSeries(bclVolume, false);
   ArraySetAsSeries(bclSpread, false);

   if(BarsCalculated(bclAtrHandle) < bclRatesTotal)
      return(bclPrevCalculated);

   double bclAtrValues[];

   ArrayResize(bclAtrValues,
               bclRatesTotal);

   ArraySetAsSeries(bclAtrValues,
                    false);

   ResetLastError();

   const int bclCopiedAtr =
      CopyBuffer(bclAtrHandle,
                 0,
                 0,
                 bclRatesTotal,
                 bclAtrValues);

   if(bclCopiedAtr != bclRatesTotal)
     {
      if(bclCopiedAtr < 0)
        {
         Print("Failed to copy ATR data. Error: ",
               GetLastError());
        }

      return(bclPrevCalculated);
     }

   int bclStartBar = 0;

   if(bclPrevCalculated == 0)
     {
      BclInitializeBuffers();
      ObjectsDeleteAll(0, bclObjectPrefix);
     }
   else
     {
      bclStartBar =
         bclPrevCalculated > 2
         ? bclPrevCalculated - 2
         : 1;
     }

   const int bclObjectStartBar =
      bclRatesTotal > bclHistoryBars
      ? bclRatesTotal - bclHistoryBars
      : 0;

   for(int bclBar = bclStartBar;
       bclBar < bclRatesTotal;
       bclBar++)
     {
      const double bclPreviousCenter =
         bclBar > 0
         ? bclCenterStateBuffer[bclBar - 1]
         : EMPTY_VALUE;

      const double bclPreviousUpperTrail =
         bclBar > 0
         ? bclUpperTrailStateBuffer[bclBar - 1]
         : EMPTY_VALUE;

      const double bclPreviousLowerTrail =
         bclBar > 0
         ? bclLowerTrailStateBuffer[bclBar - 1]
         : EMPTY_VALUE;

      const int bclPreviousDirection =
         bclBar > 0
         ? (int)bclTrendDirectionBuffer[bclBar - 1]
         : 1;

      const double bclPreviousSupport =
         bclBar > 0
         ? bclSupportStateBuffer[bclBar - 1]
         : EMPTY_VALUE;

      const double bclPreviousResistance =
         bclBar > 0
         ? bclResistanceStateBuffer[bclBar - 1]
         : EMPTY_VALUE;

      bool   bclHasPivotHigh = false;
      bool   bclHasPivotLow  = false;
      int    bclPivotBar     = -1;
      double bclPivotHigh    = EMPTY_VALUE;
      double bclPivotLow     = EMPTY_VALUE;

      if(bclBar >= bclSwingRadius * 2)
        {
         bclPivotBar = bclBar - bclSwingRadius;

         bclHasPivotHigh =
            BclIsConfirmedPivotHigh(bclHigh,
                                    bclPivotBar,
                                    bclSwingRadius,
                                    bclRatesTotal);

         bclHasPivotLow =
            BclIsConfirmedPivotLow(bclLow,
                                   bclPivotBar,
                                   bclSwingRadius,
                                   bclRatesTotal);

         if(bclHasPivotHigh)
            bclPivotHigh = bclHigh[bclPivotBar];

         if(bclHasPivotLow)
            bclPivotLow = bclLow[bclPivotBar];
        }

      double bclCurrentCenter = bclPreviousCenter;
      double bclLatestPivot   = EMPTY_VALUE;

      if(bclHasPivotHigh)
         bclLatestPivot = bclPivotHigh;
      else
         if(bclHasPivotLow)
            bclLatestPivot = bclPivotLow;

      if(BclIsValidValue(bclLatestPivot))
        {
         bclCurrentCenter =
            BclIsValidValue(bclPreviousCenter)
            ? ((bclPreviousCenter * 2.0) + bclLatestPivot) / 3.0
            : bclLatestPivot;
        }

      bclCenterStateBuffer[bclBar] =
         bclCurrentCenter;

      bclSupportStateBuffer[bclBar] =
         bclHasPivotLow
         ? bclPivotLow
         : bclPreviousSupport;

      bclResistanceStateBuffer[bclBar] =
         bclHasPivotHigh
         ? bclPivotHigh
         : bclPreviousResistance;

      bclTrailBuffer[bclBar]          = EMPTY_VALUE;
      bclTrailColorBuffer[bclBar]     = 2.0;
      bclCenterBuffer[bclBar]         = EMPTY_VALUE;
      bclCenterColorBuffer[bclBar]    = 0.0;
      bclLongSignalBuffer[bclBar]     = EMPTY_VALUE;
      bclShortSignalBuffer[bclBar]    = EMPTY_VALUE;

      bclSupportBuffer[bclBar] =
         bclShowPivotLevels
         ? bclSupportStateBuffer[bclBar]
         : EMPTY_VALUE;

      bclResistanceBuffer[bclBar] =
         bclShowPivotLevels
         ? bclResistanceStateBuffer[bclBar]
         : EMPTY_VALUE;

      int bclCurrentDirection =
         bclPreviousDirection;

      bclUpperTrailStateBuffer[bclBar] = EMPTY_VALUE;
      bclLowerTrailStateBuffer[bclBar] = EMPTY_VALUE;
      bclActiveTrailStateBuffer[bclBar] = EMPTY_VALUE;

      if(BclIsValidValue(bclCurrentCenter) &&
         bclBar >= bclAtrPeriod - 1 &&
         BclIsValidValue(bclAtrValues[bclBar]) &&
         bclAtrValues[bclBar] > 0.0)
        {
         const double bclRawUpperBand =
            bclCurrentCenter -
            (bclAtrMultiplier * bclAtrValues[bclBar]);

         const double bclRawLowerBand =
            bclCurrentCenter +
            (bclAtrMultiplier * bclAtrValues[bclBar]);

         double bclCurrentUpperTrail =
            bclRawUpperBand;

         double bclCurrentLowerTrail =
            bclRawLowerBand;

         if(bclBar > 0 &&
            BclIsValidValue(bclPreviousUpperTrail) &&
            bclClose[bclBar - 1] > bclPreviousUpperTrail)
           {
            bclCurrentUpperTrail =
               MathMax(bclRawUpperBand,
                       bclPreviousUpperTrail);
           }

         if(bclBar > 0 &&
            BclIsValidValue(bclPreviousLowerTrail) &&
            bclClose[bclBar - 1] < bclPreviousLowerTrail)
           {
            bclCurrentLowerTrail =
               MathMin(bclRawLowerBand,
                       bclPreviousLowerTrail);
           }

         if(bclBar > 0 &&
            BclIsValidValue(bclPreviousLowerTrail) &&
            bclClose[bclBar] > bclPreviousLowerTrail)
           {
            bclCurrentDirection = 1;
           }
         else
            if(bclBar > 0 &&
               BclIsValidValue(bclPreviousUpperTrail) &&
               bclClose[bclBar] < bclPreviousUpperTrail)
              {
               bclCurrentDirection = -1;
              }

         const double bclActiveTrail =
            bclCurrentDirection == 1
            ? bclCurrentUpperTrail
            : bclCurrentLowerTrail;

         bclUpperTrailStateBuffer[bclBar] =
            bclCurrentUpperTrail;

         bclLowerTrailStateBuffer[bclBar] =
            bclCurrentLowerTrail;

         bclActiveTrailStateBuffer[bclBar] =
            bclActiveTrail;

         bclTrailBuffer[bclBar] =
            bclActiveTrail;

         if(bclBar > 0 &&
            bclCurrentDirection == bclPreviousDirection)
           {
            bclTrailColorBuffer[bclBar] =
               bclCurrentDirection == 1
               ? 0.0
               : 1.0;
           }

         if(bclShowCenterLine)
           {
            const double bclBarMidpoint =
               (bclHigh[bclBar] + bclLow[bclBar]) * 0.5;

            bclCenterBuffer[bclBar] =
               bclCurrentCenter;

            bclCenterColorBuffer[bclBar] =
               bclCurrentCenter < bclBarMidpoint
               ? 0.0
               : 1.0;
           }

         if(bclBar > 0 &&
            bclCurrentDirection == 1 &&
            bclPreviousDirection == -1)
           {
            bclLongSignalBuffer[bclBar] =
               bclActiveTrail;
           }

         if(bclBar > 0 &&
            bclCurrentDirection == -1 &&
            bclPreviousDirection == 1)
           {
            bclShortSignalBuffer[bclBar] =
               bclActiveTrail;
           }
        }

      bclTrendDirectionBuffer[bclBar] =
         (double)bclCurrentDirection;

      if(bclShowTradeTags &&
         bclPrevCalculated > 0)
        {
         const string bclBuyObjectName =
            bclObjectPrefix +
            "BUY_" +
            IntegerToString((long)bclTime[bclBar]);

         const string bclSellObjectName =
            bclObjectPrefix +
            "SELL_" +
            IntegerToString((long)bclTime[bclBar]);

         if(!BclIsValidValue(bclLongSignalBuffer[bclBar]))
            ObjectDelete(0, bclBuyObjectName);

         if(!BclIsValidValue(bclShortSignalBuffer[bclBar]))
            ObjectDelete(0, bclSellObjectName);
        }

      if(bclBar < bclObjectStartBar)
         continue;

      if(bclShowSwingMarks &&
         bclPivotBar >= bclObjectStartBar)
        {
         const double bclMarkerOffset =
            BclIsValidValue(bclAtrValues[bclBar]) &&
            bclAtrValues[bclBar] > 0.0
            ? bclAtrValues[bclBar] * 0.12
            : _Point * 20.0;

         if(bclHasPivotHigh)
           {
            BclSetTextMarker(
               bclObjectPrefix +
               "PH_" +
               IntegerToString((long)bclTime[bclPivotBar]),
               bclTime[bclPivotBar],
               bclHigh[bclPivotBar] + bclMarkerOffset,
               "H",
               bclResistanceColor,
               ANCHOR_LOWER);
           }

         if(bclHasPivotLow)
           {
            BclSetTextMarker(
               bclObjectPrefix +
               "PL_" +
               IntegerToString((long)bclTime[bclPivotBar]),
               bclTime[bclPivotBar],
               bclLow[bclPivotBar] - bclMarkerOffset,
               "L",
               bclSupportColor,
               ANCHOR_UPPER);
           }
        }

      if(bclShowTradeTags)
        {
         if(BclIsValidValue(bclLongSignalBuffer[bclBar]))
           {
            BclSetTextMarker(
               bclObjectPrefix +
               "BUY_" +
               IntegerToString((long)bclTime[bclBar]),
               bclTime[bclBar],
               bclLongSignalBuffer[bclBar],
               "BUY",
               bclBuyTagColor,
               ANCHOR_LOWER);
           }

         if(BclIsValidValue(bclShortSignalBuffer[bclBar]))
           {
            BclSetTextMarker(
               bclObjectPrefix +
               "SELL_" +
               IntegerToString((long)bclTime[bclBar]),
               bclTime[bclBar],
               bclShortSignalBuffer[bclBar],
               "SELL",
               bclSellTagColor,
               ANCHOR_UPPER);
           }
        }
     }

   if(!bclShowSwingMarks)
     {
      BclDeleteFeatureObjects("PH_");
      BclDeleteFeatureObjects("PL_");
     }

   if(!bclShowTradeTags)
     {
      BclDeleteFeatureObjects("BUY_");
      BclDeleteFeatureObjects("SELL_");
     }

   if(bclPrevCalculated == 0)
     {
      const int bclInitialAlertBar =
         bclAlertOnClosedBar
         ? bclRatesTotal - 2
         : bclRatesTotal - 1;

      if(bclInitialAlertBar >= 1)
        {
         if(BclIsValidValue(
               bclLongSignalBuffer[bclInitialAlertBar]))
           {
            bclLastBuyAlertTime =
               bclTime[bclInitialAlertBar];
           }

         if(BclIsValidValue(
               bclShortSignalBuffer[bclInitialAlertBar]))
           {
            bclLastSellAlertTime =
               bclTime[bclInitialAlertBar];
           }
        }
     }
   else
     {
      BclProcessLatestAlert(bclRatesTotal,
                            bclTime);
     }

   return(bclRatesTotal);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
