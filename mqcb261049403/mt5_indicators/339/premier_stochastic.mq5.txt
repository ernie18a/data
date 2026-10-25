//+------------------------------------------------------------------+
//|                                Premier Stochastic Oscillator.mq5 |
//|                                           Copyright © 2011, AK20 |
//|                                             traderak20@gmail.com |
//|               Based on Lee Leibfarth article in TASC August 2008 |
//+------------------------------------------------------------------+
#property copyright   "2011, traderak20@gmail.com"
#property description "Premier Stochastic Oscillator"
#property version     "1.0"

/*--------------------------------------------------------------------
2011 04 16: v01   Indicator first published
----------------------------------------------------------------------*/

#property indicator_separate_window

#property indicator_buffers 7
#property indicator_plots   3

//--- indicator plots
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLime,clrGreen,clrMaroon,clrRed,clrDimGray
#property indicator_color2  clrLime,clrGreen,clrMaroon,clrRed,clrAqua
#property indicator_color3  clrLime,clrGreen,clrMaroon,clrRed,clrBlue
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_label1  "Premier Stochastic Osc"
#property indicator_label2  "PSO signal"
#property indicator_label3  "PSO histogram"

//--- indicator maximum and minimum for subwindow
#property indicator_maximum 1
#property indicator_minimum -1
//--- enum variables
enum colorswitch                                                  // use single or multi-color display of Histogram
  {
   MultiColor=0,
   SingleColor=1
  };

//--- input parameters
input int                  InpKPeriod=8;                          // K period
input int                  InpDPeriod=1;                          // D period
input int                  InpSlowing=1;                          // Slowing
input ENUM_MA_METHOD       InpAppliedMA=MODE_SMA;                 // Applied MA method for stochastic
input ENUM_STO_PRICE       InpAppliedPrice=STO_LOWHIGH;           // Applied price for stochastic
input int                  InpEMAPeriod=5;                        // EMA Period
input double               InpOuterTreshold=0.9;                  // Outer threshold
input double               InpInnerTreshold=0.2;                  // Inner threshold
input colorswitch          InpUseMultiColorLine=MultiColor;       // Use multi-color or single-color line
input bool                 InpShowArrows=false;                   // Show/hide arrows
input uchar                InpArrowCode=159;                      // Arrow code
input colorswitch          InpUseMultiColorArrows=MultiColor;     // Use multi-color or single-color arrows
input bool                 InpShowHistrogram=true;                // Show/hide histogram
input colorswitch          InpUseMultiColorHistogram=MultiColor;  // Use multi-color or single-color histogram
input bool                 InpShowLevels=true;                    // Show/hide level lines

//--- indicator buffers
double                     ExtMainBuffer[];
double                     ExtMainColorBuffer[];
double                     ExtMainArrowBuffer[];
double                     ExtMainArrowColorBuffer[];
double                     ExtHistogramBuffer[];
double                     ExtHistogramColorBuffer[];
double                     ExtEMA_2Buffer[];

//--- indicator handle stochastic
int                        ExtStochasticHandle;                   // stochastic handle
int                        ExtEMA_1Handle;                        // EMA of stochastic
int                        ExtEMA_2Handle;                        // EMA of EMA on stochastic

//--- turn on/off error messages
bool                       ShowErrorMessages=true;                // turn on/off error messages for debugging
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMainColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtMainArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtMainArrowColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,ExtHistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHistogramColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,ExtEMA_2Buffer,INDICATOR_CALCULATIONS);

//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtMainBuffer,true);
   ArraySetAsSeries(ExtMainColorBuffer,true);
   ArraySetAsSeries(ExtMainArrowBuffer,true);
   ArraySetAsSeries(ExtMainArrowColorBuffer,true);
   ArraySetAsSeries(ExtHistogramBuffer,true);
   ArraySetAsSeries(ExtHistogramColorBuffer,true);
   ArraySetAsSeries(ExtEMA_2Buffer,true);

//--- set arrow for plot
   PlotIndexSetInteger(1,PLOT_ARROW,InpArrowCode);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,4);

//--- set levels
   if(InpShowLevels)
     {
      IndicatorSetInteger(INDICATOR_LEVELS,4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,InpOuterTreshold);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrChocolate);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,InpInnerTreshold);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrChocolate);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-InpInnerTreshold);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrChocolate);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-InpOuterTreshold);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrChocolate);
     }
   else
      IndicatorSetInteger(INDICATOR_LEVELS,0);
//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"PSO("+(string)InpKPeriod+","+(string)InpDPeriod+","+(string)InpSlowing+","+(string)InpEMAPeriod+")");

//--- get Stochastic handle
   ExtStochasticHandle=iStochastic(NULL,0,InpKPeriod,InpDPeriod,InpSlowing,InpAppliedMA,InpAppliedPrice);
//--- get EMA on Stochastic handle
   ExtEMA_1Handle=iMA(NULL,0,InpEMAPeriod,0,MODE_EMA,ExtStochasticHandle);
//--- get EMA of EMA on Stochastic handle
   ExtEMA_2Handle=iMA(NULL,0,InpEMAPeriod,0,MODE_EMA,ExtEMA_1Handle);

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Premier Stochastic Oscillator                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated;

//--- loop through bars to set buffer values
   for(int i=limit;i>=0;i--)
     {
      //--- get EMA of EMA on stochastic values
      if(CopyBuffer(ExtEMA_2Handle,0,i,1,ExtEMA_2Buffer)<=0)
        {
         if(ShowErrorMessages) Print("Getting EMA of EMA on Stochastic failed! Error",GetLastError());
         return(0);
        }
      //--- calculate and set main buffer
      double rescale=0.1*(ExtEMA_2Buffer[i]-50);
      double exponential=MathExp(rescale);
      ExtMainBuffer[i]=(exponential-1)/(exponential+1);
      //--- set main buffer color
      ExtMainColorBuffer[i]=4;
      if(InpUseMultiColorLine==MultiColor)
        {
         if(ExtMainBuffer[i]>=InpOuterTreshold) ExtMainColorBuffer[i]=0;
         if(ExtMainBuffer[i]>=0 && ExtMainBuffer[i]<InpOuterTreshold) ExtMainColorBuffer[i]=1;
         if(ExtMainBuffer[i]<0 && ExtMainBuffer[i]>-InpOuterTreshold) ExtMainColorBuffer[i]=2;
         if(ExtMainBuffer[i]<=-InpOuterTreshold) ExtMainColorBuffer[i]=3;
        }

      //--- set arrow buffer values and color
      if(InpShowArrows)
        {
         //--- set arrow buffer values
         ExtMainArrowBuffer[i]=EMPTY_VALUE;
         if(i<limit)
           {
            int clrIndex=4;
            ExtMainArrowColorBuffer[i]=clrIndex;
            if(ExtMainBuffer[i]>=InpOuterTreshold && ExtMainBuffer[i+1]<InpOuterTreshold)
              {
               ExtMainArrowBuffer[i]=ExtMainBuffer[i];
               clrIndex=0;
              }
            if(ExtMainBuffer[i]<InpOuterTreshold && ExtMainBuffer[i+1]>=InpOuterTreshold)
              {
               ExtMainArrowBuffer[i]=ExtMainBuffer[i];
               clrIndex=1;
              }
            if(ExtMainBuffer[i]>-InpOuterTreshold && ExtMainBuffer[i+1]<=-InpOuterTreshold)
              {
               ExtMainArrowBuffer[i]=ExtMainBuffer[i];
               clrIndex=2;
              }
            if(ExtMainBuffer[i]<=-InpOuterTreshold && ExtMainBuffer[i+1]>-InpOuterTreshold)
              {
               ExtMainArrowBuffer[i]=ExtMainBuffer[i];
               clrIndex=3;
              }
            if(InpUseMultiColorArrows==MultiColor) ExtMainArrowColorBuffer[i]=clrIndex;
           }
        }
      else
        {
         ExtMainArrowBuffer[i]=EMPTY_VALUE;
         ExtMainArrowColorBuffer[i]=EMPTY_VALUE;
        }

      //--- set histogram buffer values and color
      if(InpShowHistrogram)
        {
         //--- set histogram buffer values
         ExtHistogramBuffer[i]=ExtMainBuffer[i];
         //--- set histogram buffer color
         ExtHistogramColorBuffer[i]=4;
         if(InpUseMultiColorHistogram==MultiColor)
           {
            if(ExtHistogramBuffer[i]>=InpOuterTreshold) ExtHistogramColorBuffer[i]=0;
            if(ExtHistogramBuffer[i]>=0 && ExtHistogramBuffer[i]<InpOuterTreshold) ExtHistogramColorBuffer[i]=1;
            if(ExtHistogramBuffer[i]<0 && ExtHistogramBuffer[i]>-InpOuterTreshold) ExtHistogramColorBuffer[i]=2;
            if(ExtHistogramBuffer[i]<=-InpOuterTreshold) ExtHistogramColorBuffer[i]=3;
           }
        }
      else
        {
         ExtHistogramBuffer[i]=EMPTY_VALUE;
         ExtHistogramColorBuffer[i]=EMPTY_VALUE;
        }
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
