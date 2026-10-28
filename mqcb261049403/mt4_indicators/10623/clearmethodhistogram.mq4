// This indicator is based on the article: Getting Clear With Short-Term Swings by Ron Black
//
// http://www.traders.com/Documentation/FEEDbk_docs/2010/09/Black.html
// http://www.traders.com/Documentation/FEEDbk_docs/2010/09/TradersTips.html
//
// The histogram shows the distance from the actual switching threshold
// Copy the ClearMethod.mq4 file to the Indicator directory, it will be used by iCustom()

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_level1 0

int maxHistoryBarsToCount = 50000;

double DistanceFromThresholdBuffer1[];
double DistanceFromThresholdBuffer2[];

int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(0, DistanceFromThresholdBuffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(1, DistanceFromThresholdBuffer2);
   return(0);
}

int start() {
   int countedBars = IndicatorCounted();
   int countFrom = MathMin(Bars - countedBars - 1, maxHistoryBarsToCount);

   if (countFrom >= 0 && countFrom < Bars) {
      countIndicator(countFrom);
   }
   return(0);
}

int countIndicator(int countFrom) {
   int i;
   bool isUpSwing;
   double upSwingLine;
   double downSwingLine;
   
   for (i = countFrom; i >= 0; i--) {
      isUpSwing = (iCustom(NULL, 0, "ClearMethod", 0, i) > 0);      
      if (isUpSwing) {
         upSwingLine = iCustom(NULL, 0, "ClearMethod", 1, i);
         DistanceFromThresholdBuffer1[i] = High[i] - upSwingLine;
         DistanceFromThresholdBuffer2[i] = 0.0;
      } else {
         downSwingLine = iCustom(NULL, 0, "ClearMethod", 2, i);
         DistanceFromThresholdBuffer1[i] = 0.0;
         DistanceFromThresholdBuffer2[i] = downSwingLine - Low[i];
      }
   }
   return(0);
}

