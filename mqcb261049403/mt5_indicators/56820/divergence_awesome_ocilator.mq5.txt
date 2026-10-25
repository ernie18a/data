//+------------------------------------------------------------------+
//|                                  Divergence Awesome Ocilator.mq5 |
//|                                 Copyright 2025, Francisco Gomes. |
//|             https://www.mql5.com/en/users/franciscogomes5/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Francisco Gomes (mql5.com)"
#property link      "https://www.mql5.com/en/users/franciscogomes5/seller"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot Buy
#property indicator_label1  "Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrTeal
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Sell
#property indicator_label2  "Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- plot histogram
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  5
//--- count lines in sequence
#property indicator_label4  "Sequence"
#property indicator_type4   DRAW_NONE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  5
//--- plot line
#property indicator_label5  "Line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
#include <Arrays\ArrayInt.mqh>
//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+
#define MIDDLE 0
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
double         BuyBuffer[];
double         SellBuffer[];
double         HistogramBuffer[];
double         PointsCounterBuffer[];
double         LineBuffer[];
CChartObjectTrend UpTrends[];
int Handle;
CArrayInt coordinates;
CArrayInt alignedCoordinates;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BuyBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SellBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,PointsCounterBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,0);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,0);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

   Handle = iAO(NULL,NULL);
   if(Handle == INVALID_HANDLE)
      return INVALID_HANDLE;
//---
   return(INIT_SUCCEEDED);
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
//---
   static char     lastSet = 'N';

   if(prev_calculated == rates_total)
      return rates_total;

   if(prev_calculated == 0)
     {
      // first tick
      lastSet = 'N';
      coordinates.Clear();
      alignedCoordinates.Clear();
      RemoveDraw();
      ArrayInitialize(BuyBuffer,0);
      ArrayInitialize(SellBuffer,0);
      ArrayInitialize(HistogramBuffer,0);
      ArrayInitialize(PointsCounterBuffer,0);
      ArrayInitialize(LineBuffer,0);
     }
   if(prev_calculated != rates_total)
     {
      // new bar
      const int i = rates_total -1;
      BuyBuffer[i] = 0;
      SellBuffer[i] = 0;
      HistogramBuffer[i] = 0;
      PointsCounterBuffer[i] = 0;
      LineBuffer[i] = 0;
      const int copied = CopyBuffer(Handle,0,0,rates_total,HistogramBuffer);
      if(copied != rates_total)
         return 0;
     }
   int limit = prev_calculated -2;
   if(limit <= 0)
      limit = 1;

   for(int i=limit; i<rates_total-2;i++)
     {
      if(IsBottom(HistogramBuffer,i) && IsBottom(low,i) && HistogramBuffer[i] < MIDDLE)
        {
         //BuyBuffer[i] = HistogramBuffer[i];
         lastSet = 'B';
         coordinates.Add(i);
        }
      if(IsTop(HistogramBuffer,i) && IsTop(high,i) && HistogramBuffer[i] > MIDDLE)
        {
         //SellBuffer[i] = HistogramBuffer[i];
         lastSet = 'T';
         coordinates.Add(i);
        }
#define HISTO_CROSS_UNDER  (HistogramBuffer[i-1] >= MIDDLE && HistogramBuffer[i] < MIDDLE)
#define HISTO_CROSS_OVER   (HistogramBuffer[i-1]  <= MIDDLE && HistogramBuffer[i] > MIDDLE)
      if(HISTO_CROSS_UNDER || HISTO_CROSS_OVER)
        {
         coordinates.Clear();
         alignedCoordinates.Clear();
        }
      const int icord1 = Shift(coordinates,1);
      const int icord2 = Shift(coordinates,0);
      if(icord1 > 0 && icord2 > 0)
        {
         int totalLines = ArraySize(UpTrends);
         const int j = totalLines;
         totalLines++;
         ArrayResize(UpTrends,totalLines,rates_total);
         static int lastCode1 = 0;
         static int lastCode2 = 0;
         if(lastCode1 == icord1 && lastCode2 == icord2)
            continue;
         lastCode1 = icord1;
         lastCode2 = icord2;

         //checking bottoms
         if(lastSet == 'B' &&
            !CheckCrossing(false,low,close,icord1,icord2) &&
            !CheckCrossing(false,HistogramBuffer,HistogramBuffer,icord1,icord2) &&
            IsBullishTrend(HistogramBuffer,icord1,icord2) &&
            IsBearishTrend(low,icord1,icord2) &&
            true)
           {
            AddUniqueCoordinates(alignedCoordinates,icord1,icord2);
            BuyBuffer[i+1] = HistogramBuffer[i];
            PointsCounterBuffer[i+1] = TotalAligned(alignedCoordinates);
            UpTrends[j].Create(0,"lt-"+(string)j,0,time[icord1],low[icord1],time[icord2],low[icord2]);
            FillBufferLine(LineBuffer,icord1,icord2,HistogramBuffer);
           }

         //checking tops
         if(lastSet == 'T' &&
            !CheckCrossing(true,high,close,icord1,icord2) &&
            !CheckCrossing(true,HistogramBuffer,HistogramBuffer,icord1,icord2) &&
            IsBullishTrend(high,icord1,icord2) &&
            IsBearishTrend(HistogramBuffer,icord1,icord2) &&
            true)
           {
            AddUniqueCoordinates(alignedCoordinates,icord1,icord2);
            SellBuffer[i+1] = HistogramBuffer[i];
            PointsCounterBuffer[i+1] = TotalAligned(alignedCoordinates);
            UpTrends[j].Create(0,"lt-"+(string)j,0,time[icord1],high[icord1],time[icord2],high[icord2]);
            FillBufferLine(LineBuffer,icord1,icord2,HistogramBuffer);
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBottom(const double &array[], const int i)
  {
   const int total = ArraySize(array);
   if(i > total - 2)
      return false;
   if(i < 1)
      return false;
   return array[i+1] > array[i] && array[i] < array[i-1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTop(const double &array[], const int i)
  {
   const int total = ArraySize(array);
   if(i > total - 2)
      return false;
   if(i < 1)
      return false;
   return array[i+1] < array[i] && array[i] > array[i-1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateIntermediateValue(const double &points[], const int startIndex, const int endIndex, const double intermediateIndex)
  {
// Check if the indices are within the array bounds
   if(startIndex < 0 || endIndex >= ArraySize(points) || intermediateIndex < startIndex || intermediateIndex > endIndex)
     {
      Print("Indices out of valid range.");
      DebugBreak();
      return 0; // Return 0 in case of error
     }

// Get the values corresponding to the start and end indices
   double startValue = points[startIndex];
   double endValue = points[endIndex];

// Calculate the intermediate value using linear interpolation
   double intermediateValue = startValue + (endValue - startValue) * (intermediateIndex - startIndex) / (endIndex - startIndex);

   return intermediateValue;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckCrossing(const bool isTop, const double &points[], const double &crossing[], const int startIndex, const int endIndex)
  {
// Iterate over the range to check for crossing
   for(int i = startIndex; i <= endIndex; i++)
     {
      // Calculate the interpolated value using the previous function
      const double interpolatedValue = CalculateIntermediateValue(points, startIndex, endIndex, i);

      // Check if the crossing value is above or below the line
      if(i >= 0 && i < ArraySize(crossing))
        {
         const double crossingValue = crossing[i];

         // Return true if the crossing value crossed the line
         if(isTop)
           {
            if(crossingValue > interpolatedValue)
               return true; // Crossing occurred
           }
         else //is not top
           {
            if(crossingValue < interpolatedValue)
               return true; // Crossing occurred
           }
        }
     }
   return false; // No crossing occurred
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullishTrend(const double &array[], const int start, const int end)
  {
   return array[start] < array[end];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearishTrend(const double &array[], const int start, const int end)
  {
   return array[start] > array[end];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalAligned(const CArrayInt &array)
  {
   const int total = array.Total();

   if(total < 2)
      return 0;

   int count = 0;
   int p1, p2, lastP2;

   lastP2 = array.At(0);

   for(int i=1;i<total;i++)
     {
      p1 = array.At(i-1);
      p2 = array.At(i);
      if(p1 == lastP2)
        {
         count++;
        }
      else
        {
         count = 0;
        }
      lastP2 = p2;
     }
   return count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddUniqueCoordinates(CArrayInt &array, const int p1, const int p2)
  {
   int i;
   i = array.SearchLinear(p1);
   if(i == -1)
      array.Add(p1);

   i = array.SearchLinear(p2);
   if(i == -1)
      array.Add(p2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Shift(const CArrayInt &array, const int shift)
  {
   const int index = array.Total() -1 - shift;
   if(index < 0)
      return 0;
   return array.At(index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveDraw(void)
  {
   int total;

   total = ArraySize(UpTrends);
   for(int i=0;i<total;i++)
      UpTrends[i].Delete();

   ArrayResize(UpTrends,0,1024);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillBufferLine(double &buffer[], const int p1, const int p2, const double &prices[])
  {
   for(int i=p1;i<=p2;i++)
      buffer[i] = CalculateIntermediateValue(prices,p1,p2,i);
  }
//+------------------------------------------------------------------+
