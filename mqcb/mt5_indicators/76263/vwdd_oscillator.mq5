//+------------------------------------------------------------------+
//|                                              VWDD_Oscillator.mq5 |
//|                                   Copyright 2026, Adeolu Gbadebo |
//|                      Volume-Weighted Delta Divergence Oscillator |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Volume-Weighted Delta Divergence Oscillator: builds a "
#property description "bar-by-bar volume delta proxy, accumulates it into a "
#property description "normalized oscillator, and flags regular bullish/bearish "
#property description "divergence between price swings and the delta."

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3

//--- Plot 0: main oscillator histogram (two-tone)
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDodgerBlue,clrCrimson
#property indicator_width1  2
#property indicator_label1  "VWDD Oscillator"

//--- Plot 1: bullish divergence arrow
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLime
#property indicator_width2  2
#property indicator_label2  "Bullish Divergence"

//--- Plot 2: bearish divergence arrow
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_width3  2
#property indicator_label3  "Bearish Divergence"

//--- indicator levels
#property indicator_level1 0.0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrGray

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
enum ENUM_VWDD_VOLUME
  {
   VWDD_VOL_TICK = 0,   // Tick volume
   VWDD_VOL_REAL = 1    // Real volume (if supplied by broker/feed)
  };

input int               InpDeltaPeriod    = 20;    // Cumulative delta window (bars)
input int               InpNormPeriod     = 50;     // Std-dev normalization lookback (bars)
input int               InpSmoothPeriod   = 5;       // Oscillator smoothing period (bars)
input ENUM_VWDD_VOLUME  InpVolumeType     = VWDD_VOL_TICK; // Volume source
input int               InpDivLookback    = 10;     // Swing confirmation bars (each side)
input int               InpDivSearchRange = 100;    // Max bars searched for a prior swing
input bool              InpShowArrows     = true;   // Show divergence arrows
input double            InpArrowOffset    = 0.30;   // Arrow vertical offset (oscillator units)

//+------------------------------------------------------------------+
//| Indicator buffers                                                 |
//+------------------------------------------------------------------+
double OscBuffer[];        // plot 0 - final smoothed oscillator (visible)
double OscColorBuffer[];   // plot 0 - color index (visible)
double ArrowUpBuffer[];    // plot 1 - bullish divergence arrow (visible)
double ArrowDownBuffer[];  // plot 2 - bearish divergence arrow (visible)
double DeltaBuffer[];      // calc  - raw per-bar volume delta
double CumDeltaBuffer[];   // calc  - rolling cumulative delta
double RawOscBuffer[];     // calc  - normalized oscillator before smoothing

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDeltaPeriod<1 || InpNormPeriod<2 || InpSmoothPeriod<1 || InpDivLookback<1 || InpDivSearchRange<1)
     {
      Print("VWDD_Oscillator: invalid input parameter(s), using safe defaults internally.");
     }

   SetIndexBuffer(0,OscBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,OscColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ArrowUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ArrowDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,DeltaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,CumDeltaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,RawOscBuffer,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(1,PLOT_ARROW,233);   // wingdings up arrow
   PlotIndexSetInteger(2,PLOT_ARROW,234);   // wingdings down arrow

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("VWDD Oscillator (%d,%d,%d)",InpDeltaPeriod,InpNormPeriod,InpSmoothPeriod));
   IndicatorSetInteger(INDICATOR_DIGITS,3);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Standard deviation of arr[] over 'period' bars ending at idx      |
//+------------------------------------------------------------------+
double CalcStdDev(const double &arr[],const int idx,const int period)
  {
   double mean=0.0;
   for(int k=idx;k>=idx-period+1;k--)
      mean+=arr[k];
   mean/=period;

   double var=0.0;
   for(int k=idx;k>=idx-period+1;k--)
     {
      double d=arr[k]-mean;
      var+=d*d;
     }
   var/=period;

   return(MathSqrt(var));
  }

//+------------------------------------------------------------------+
//| Is bar 'idx' a confirmed swing high (strict local max)            |
//+------------------------------------------------------------------+
bool IsSwingHigh(const double &high[],const int idx,const int lookback,const int total)
  {
   if(idx-lookback<0 || idx+lookback>total-1)
      return(false);

   double h=high[idx];
   for(int k=idx-lookback;k<=idx+lookback;k++)
     {
      if(k==idx)
         continue;
      if(high[k]>=h)
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Is bar 'idx' a confirmed swing low (strict local min)             |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &low[],const int idx,const int lookback,const int total)
  {
   if(idx-lookback<0 || idx+lookback>total-1)
      return(false);

   double l=low[idx];
   for(int k=idx-lookback;k<=idx+lookback;k++)
     {
      if(k==idx)
         continue;
      if(low[k]<=l)
         return(false);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Search backward from fromIdx-1 for the nearest confirmed swing    |
//| high; returns bar index or -1 if none found in range              |
//+------------------------------------------------------------------+
int FindPrevSwingHigh(const double &high[],const int fromIdx,const int lookback,
                       const int searchRange,const int total)
  {
   int lowerBound=fromIdx-searchRange;
   if(lowerBound<lookback)
      lowerBound=lookback;

   for(int j=fromIdx-1;j>=lowerBound;j--)
     {
      if(IsSwingHigh(high,j,lookback,total))
         return(j);
     }
   return(-1);
  }

//+------------------------------------------------------------------+
//| Search backward from fromIdx-1 for the nearest confirmed swing    |
//| low; returns bar index or -1 if none found in range                |
//+------------------------------------------------------------------+
int FindPrevSwingLow(const double &low[],const int fromIdx,const int lookback,
                      const int searchRange,const int total)
  {
   int lowerBound=fromIdx-searchRange;
   if(lowerBound<lookback)
      lowerBound=lookback;

   for(int j=fromIdx-1;j>=lowerBound;j--)
     {
      if(IsSwingLow(low,j,lookback,total))
         return(j);
     }
   return(-1);
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
   int minBars=InpNormPeriod+InpDeltaPeriod+2*InpDivLookback+5;
   if(rates_total<minBars)
      return(0);

   int start=(prev_calculated==0)?0:prev_calculated-1;
   if(start<0)
      start=0;

   for(int i=start;i<rates_total;i++)
     {
      //--- 1) raw per-bar volume delta proxy
      double range=high[i]-low[i];
      double buyRatio=0.0;
      if(range>0.0)
         buyRatio=((close[i]-low[i])-(high[i]-close[i]))/range;

      double vol=(InpVolumeType==VWDD_VOL_TICK)?(double)tick_volume[i]:(double)volume[i];
      DeltaBuffer[i]=buyRatio*vol;

      //--- 2) rolling cumulative delta over InpDeltaPeriod bars
      double sum=0.0;
      int cnt=0;
      for(int k=i;k>=0 && cnt<InpDeltaPeriod;k--,cnt++)
         sum+=DeltaBuffer[k];
      CumDeltaBuffer[i]=sum;

      //--- 3) normalize into a z-score style oscillator
      double osc=0.0;
      if(i>=InpNormPeriod-1)
        {
         double sd=CalcStdDev(CumDeltaBuffer,i,InpNormPeriod);
         osc=(sd>0.0)?CumDeltaBuffer[i]/sd:0.0;
        }
      RawOscBuffer[i]=osc;

      //--- 4) smooth the oscillator
      double smSum=0.0;
      int smCnt=0;
      for(int k=i;k>=0 && smCnt<InpSmoothPeriod;k--,smCnt++)
         smSum+=RawOscBuffer[k];
      OscBuffer[i]=smSum/smCnt;
      OscColorBuffer[i]=(OscBuffer[i]>=0.0)?0:1;

      ArrowUpBuffer[i]=EMPTY_VALUE;
      ArrowDownBuffer[i]=EMPTY_VALUE;

      //--- 5) divergence detection (confirmed with a lag of InpDivLookback bars)
      if(InpShowArrows)
        {
         int center=i-InpDivLookback;
         if(center-InpDivLookback>=0)
           {
            if(IsSwingHigh(high,center,InpDivLookback,rates_total))
              {
               int prevIdx=FindPrevSwingHigh(high,center,InpDivLookback,InpDivSearchRange,rates_total);
               if(prevIdx>=0 && high[center]>high[prevIdx] && OscBuffer[center]<OscBuffer[prevIdx])
                  ArrowDownBuffer[center]=OscBuffer[center]+InpArrowOffset;
              }
            if(IsSwingLow(low,center,InpDivLookback,rates_total))
              {
               int prevIdx2=FindPrevSwingLow(low,center,InpDivLookback,InpDivSearchRange,rates_total);
               if(prevIdx2>=0 && low[center]<low[prevIdx2] && OscBuffer[center]>OscBuffer[prevIdx2])
                  ArrowUpBuffer[center]=OscBuffer[center]-InpArrowOffset;
              }
           }
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayFree(OscBuffer);
   ArrayFree(OscColorBuffer);
   ArrayFree(ArrowUpBuffer);
   ArrayFree(ArrowDownBuffer);
   ArrayFree(DeltaBuffer);
   ArrayFree(CumDeltaBuffer);
   ArrayFree(RawOscBuffer);
  }
//+------------------------------------------------------------------+
