// This indicator is based on the article: Getting Clear With Short-Term Swings by Ron Black
//
// http://www.traders.com/Documentation/FEEDbk_docs/2010/09/Black.html
// http://www.traders.com/Documentation/FEEDbk_docs/2010/09/TradersTips.html
//
// Clear signal: breaking Clear Line
// Move signal: Clear Line moves again after flat
// Alert: after a closed bar signal (at the first tick of next bar)
// Copy the ClearMethod.mq4 file to the Indicator directory, it will be used by iCustom()

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red

int MaxHistoryBarsToCount = 5000;

extern bool IsDrawClearSignals = true;
extern bool IsDrawMoveSignals = true;

bool IsDrawAsPullbackSignals = false; // true: for pullback trading (Important! This is an extremely dangerous trading style!)

extern bool IsAlertClearUpSignals = true;
extern bool IsAlertClearDownSignals = true;
extern bool IsAlertMoveUpSignals = true;
extern bool IsAlertMoveDownSignals = true;

double SignalClearUpBuffer[];
double SignalClearDownBuffer[];
double SignalMoveUpBuffer[];
double SignalMoveDownBuffer[];

bool IsClearUpSignal = false;
bool IsClearDownSignal = false;
bool IsMoveUpSignal = false;
bool IsMoveDownSignal = false;
datetime AlertsCheckedLastTime = 0;

int init() {
   SetIndexBuffer(0, SignalClearUpBuffer);
   SetIndexBuffer(1, SignalClearDownBuffer);
   SetIndexBuffer(2, SignalMoveUpBuffer);
   SetIndexBuffer(3, SignalMoveDownBuffer);

   if (IsDrawClearSignals) {
      SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, Green);
      SetIndexArrow(0, 251);
      SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, Red);
      SetIndexArrow(1, 251);
      if (IsDrawAsPullbackSignals) {
         SetIndexStyle(0, DRAW_ARROW, EMPTY, EMPTY, Red);
         SetIndexStyle(1, DRAW_ARROW, EMPTY, EMPTY, Green);
      }
   } else {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
   }
   
   if (IsDrawMoveSignals) {
      SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, Green);
      SetIndexArrow(2, 200);
      SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, Red);
      SetIndexArrow(3, 202);
      if (IsDrawAsPullbackSignals) {
         SetIndexStyle(2, DRAW_ARROW, EMPTY, EMPTY, Red);
         SetIndexStyle(3, DRAW_ARROW, EMPTY, EMPTY, Green);
      }
   } else {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
   }

   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   return(0);
}

int start() {
   int countedBars = IndicatorCounted();
   int emptyLength = MathMin(Bars, 50);
   int countFrom = MathMin(Bars - MathMax(countedBars, emptyLength) - 1, MaxHistoryBarsToCount);

   checkAlerts();
   switchOffPrevTickSignals();

   if (countFrom >= 0 && countFrom < Bars) {
      if (countedBars < 1) {
         fillFirstValuesWithEmpty(emptyLength);
      }
      countIndicator(countFrom);
   }
   return(0);
}

void countIndicator(int countFrom) {
   int i;
   bool isUpSwing;
   bool isUpSwingPrevBar;
   bool isUpSwingPrevPrevBar;
   bool isFlat;
   bool isFlatPrevBar;
   
   for (i = countFrom; i >= 0; i--) {
      isUpSwing = (iCustom(NULL, 0, "ClearMethod", 0, i) > 0);
      isUpSwingPrevBar = (iCustom(NULL, 0, "ClearMethod", 0, i + 1) > 0);
      isUpSwingPrevPrevBar = (iCustom(NULL, 0, "ClearMethod", 0, i + 2) > 0);
      
      isFlat = true;
      if (isUpSwing && isUpSwingPrevBar) {
         isFlat = (MathAbs(iCustom(NULL, 0, "ClearMethod", 1, i) - iCustom(NULL, 0, "ClearMethod", 1, i + 1)) < Point / 10000.0);
      } else if (!isUpSwing && !isUpSwingPrevBar) {
         isFlat = (MathAbs(iCustom(NULL, 0, "ClearMethod", 2, i) - iCustom(NULL, 0, "ClearMethod", 2, i + 1)) < Point / 10000.0);      
      }
      
      isFlatPrevBar = false;
      if (isUpSwing && isUpSwingPrevBar) {
         isFlatPrevBar = (MathAbs(iCustom(NULL, 0, "ClearMethod", 1, i + 1) - iCustom(NULL, 0, "ClearMethod", 1, i + 2)) < Point / 10000.0);
      } else if (!isUpSwing && !isUpSwingPrevBar) {
         isFlatPrevBar = (MathAbs(iCustom(NULL, 0, "ClearMethod", 2, i + 1) - iCustom(NULL, 0, "ClearMethod", 2, i + 2)) < Point / 10000.0);
      }

      IsClearUpSignal = (isUpSwing && !isUpSwingPrevBar);
      IsClearDownSignal = (!isUpSwing && isUpSwingPrevBar);
      IsMoveUpSignal = (isUpSwing && !isFlat && isFlatPrevBar);
      IsMoveDownSignal = (!isUpSwing && !isFlat && isFlatPrevBar);
      
      if (IsClearUpSignal) {
         SignalClearUpBuffer[i] = Low[i] - getArrowShiftingPixelsInPoints(i);
         if (IsDrawAsPullbackSignals) {
            SignalClearUpBuffer[i] = High[i] + getArrowShiftingPixelsInPoints(i) * 0.7;
         }
      } else {
         SignalClearUpBuffer[i] = 0.0;
      }
      if (IsClearDownSignal) {
         SignalClearDownBuffer[i] = High[i] + getArrowShiftingPixelsInPoints(i);
         if (IsDrawAsPullbackSignals) {
            SignalClearDownBuffer[i] = Low[i] - getArrowShiftingPixelsInPoints(i) * 0.7;
         }
      } else {
         SignalClearDownBuffer[i] = 0.0;
      }
      if (IsMoveUpSignal) {
         SignalMoveUpBuffer[i] = Low[i] - getArrowShiftingPixelsInPoints(i);
         if (IsDrawAsPullbackSignals) {
            SignalMoveUpBuffer[i] = High[i] + getArrowShiftingPixelsInPoints(i) * 0.7;
         }
      } else {
         SignalMoveUpBuffer[i] = 0.0;
      }
      if (IsMoveDownSignal) {
         SignalMoveDownBuffer[i] = High[i] + getArrowShiftingPixelsInPoints(i);
         if (IsDrawAsPullbackSignals) {
            SignalMoveDownBuffer[i] = Low[i] - getArrowShiftingPixelsInPoints(i) * 0.7;
         }
      } else {
         SignalMoveDownBuffer[i] = 0.0;
      }
   }
   return;
}

void checkAlerts() {
   if (AlertsCheckedLastTime == Time[1]) {
      if (IsClearUpSignal && IsAlertClearUpSignals) {
         Alert("Clear Method (" + Symbol() + ", " + getPeriodsText() + ") - Clear Up signal.");
      }
      if (IsClearDownSignal && IsAlertClearDownSignals) {
         Alert("Clear Method (" + Symbol() + ", " + getPeriodsText() + ") - Clear Down signal.");
      }
      if (IsMoveUpSignal && IsAlertMoveUpSignals) {
         Alert("Clear Method (" + Symbol() + ", " + getPeriodsText() + ") - Move Up signal.");
      }
      if (IsMoveDownSignal && IsAlertMoveDownSignals) {
         Alert("Clear Method (" + Symbol() + ", " + getPeriodsText() + ") - Move Down signal.");
      }
   }
   AlertsCheckedLastTime = Time[0];
   return;
}

void switchOffPrevTickSignals() {
   IsClearUpSignal = false;
   IsClearDownSignal = false;
   IsMoveUpSignal = false;
   IsMoveDownSignal = false;
   return;
}

double getArrowShiftingPixelsInPoints(int barIndex) {
   int i;
   double sum = 0.0;
   for (i = barIndex; i < barIndex + 50; i++) {
      sum += High[i] - Low[i];
   }
   return(sum / 100.0);
}

string getPeriodsText() {
   string periodsText = "";
   int periodsInMinutes = Period();
   if (periodsInMinutes == PERIOD_M1) {
      periodsText = "M1";
   } else if (periodsInMinutes == PERIOD_M5) {
      periodsText = "M5";
   } else if (periodsInMinutes == PERIOD_M15) {
      periodsText = "M15";
   } else if (periodsInMinutes == PERIOD_M30) {
      periodsText = "M30";
   } else if (periodsInMinutes == PERIOD_H1) {
      periodsText = "H1";
   } else if (periodsInMinutes == PERIOD_H4) {
      periodsText = "H4";
   } else if (periodsInMinutes == PERIOD_D1) {
      periodsText = "D1";
   } else if (periodsInMinutes == PERIOD_W1) {
      periodsText = "W1";
   } else if (periodsInMinutes == PERIOD_MN1) {
      periodsText = "MN1";
   }   
   return(periodsText);
}

void fillFirstValuesWithEmpty(int emptyLength) {
   int i;
   int index;
   for (i = 0; i < emptyLength; i++) {
      index = Bars - i - 1;
      SignalClearUpBuffer[index] = 0.0;
      SignalClearDownBuffer[index] = 0.0;
      SignalMoveUpBuffer[index] = 0.0;
      SignalMoveDownBuffer[index] = 0.0;
   }
   return;
}

