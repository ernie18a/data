//+------------------------------------------------------------------+
//|                                           VininI Cyber Cycle.mq5 |
//|                                           Copyright © 2011, AK20 |
//|                                             traderak20@gmail.com |
//|                                                                  |
//|                                                        Based on: |
//|                                        VininI_Cyber_Cycle_V2.mq4 |
//|                                Copyright © 2009, Victor Nicolaev |
//|                                            e-mail: vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright   "2011, traderak20@gmail.com"
#property description "VininI Cyber Cycle"
#property version     "1.0"
#property indicator_separate_window
//--- set maximum and minimum for subwindow
#property indicator_minimum -1.05
#property indicator_maximum 1.05
#property indicator_buffers 6
#property indicator_plots   2
//--- indicator plots
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  Yellow,Green,Red
#property indicator_label1  "VininI Cyber Cycle Arrow"

#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  Yellow,Green,Red
#property indicator_label2  "VininI Cyber Cycle"
//--- enum variables
enum colorswitch                                         // use single or multi-color plots
  {
   MultiColor=0,
   SingleColor=1
  };
//---- input parameters 
input double               InpAlpha=0.01;                // Alpha
input double               InpBeta=1.0;                  // Beta
input double               InpNormalizeTarget=7.5;       // Normalize target
input int                  InpBarsInWindow=1000;         // Length of window for calculations
input colorswitch          InpUseMultiColor=MultiColor;  // Use multi-color or single-color line
input bool                 InpDrawArrows=true;           // Draw arrows on color change
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_MEDIAN; // Applied price

//--- indicator buffers
double                     ExtICycleArrowBuffer[];
double                     ExtICycleArrowColorBuffer[];
double                     ExtICycleBuffer[];
double                     ExtICycleColorBuffer[];
double                     ExtSmoothBuffer[];
double                     ExtCycleBuffer[];

//--- global arrays
double                     CalcPriceArray[];             // array to hold applied price data
//+------------------------------------------------------------------+
//| Create array for rate data timeseries                            |
//+------------------------------------------------------------------+
int CreatePriceArray(int f_to_copy)
  {
//--- create array for rate data of timeseries
   MqlRates f_rates[];
   ArraySetAsSeries(f_rates,true);

//--- get rate date for timeseries
   if(CopyRates(NULL,0,0,f_to_copy,f_rates)<=0) return(0);

//--- reset array for price series data
   ArraySetAsSeries(CalcPriceArray,true);
   ArrayInitialize(CalcPriceArray,EMPTY_VALUE);
   ArrayResize(CalcPriceArray,f_to_copy);

//--- fill CalcPriceArray array with close
   if(InpAppliedPrice==PRICE_CLOSE)
      for(int i=0;i<f_to_copy;i++)
         CalcPriceArray[i]=f_rates[i].close;

//--- fill CalcPriceArray array with open
   else if(InpAppliedPrice==PRICE_OPEN)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=f_rates[i].open;

//--- fill CalcPriceArray array with high
   else if(InpAppliedPrice==PRICE_HIGH)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=f_rates[i].high;

//--- fill CalcPriceArray array with low
   else if(InpAppliedPrice==PRICE_LOW)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=f_rates[i].low;

//--- fill CalcPriceArray array with median price
   else if(InpAppliedPrice==PRICE_MEDIAN)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=(f_rates[i].high+f_rates[i].low)/2;

//--- fill CalcPriceArray array with typical price
   else if(InpAppliedPrice==PRICE_TYPICAL)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=(f_rates[i].high+f_rates[i].low+f_rates[i].close)/3;

//--- fill CalcPriceArray array with weighted price
   else if(InpAppliedPrice==PRICE_WEIGHTED)
   for(int i=0;i<f_to_copy;i++)
             CalcPriceArray[i]=(f_rates[i].high+f_rates[i].low+f_rates[i].close+f_rates[i].close)/4;

   return(1);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtICycleArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtICycleArrowColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtICycleBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtICycleColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,ExtSmoothBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtCycleBuffer,INDICATOR_CALCULATIONS);

//--- sets first bar from where index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpBarsInWindow);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpBarsInWindow);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpBarsInWindow);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,InpBarsInWindow);

//--- set arrow for plot
   PlotIndexSetInteger(0,PLOT_ARROW,159);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,4);

//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,-0.5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0.5);

//--- name for indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"VininI_Cyber_Cycle_Norm_Gom");

//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtICycleArrowBuffer,true);
   ArraySetAsSeries(ExtICycleArrowColorBuffer,true);
   ArraySetAsSeries(ExtICycleBuffer,true);
   ArraySetAsSeries(ExtICycleColorBuffer,true);
   ArraySetAsSeries(ExtSmoothBuffer,true);
   ArraySetAsSeries(ExtCycleBuffer,true);

//--- initialization done
  }
//+------------------------------------------------------------------+
//| VininI Cyber Cycle                                               |
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
//--- set positive window size for calculations
   int window_size;
   if(InpBarsInWindow<=0) window_size=1000;
   else window_size=InpBarsInWindow;

//--- check for data
   if(rates_total<window_size)
      return(0);

//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated;
//--- older bars ([1],[2],[3]) are needed to calculate the current bar
   if(limit>rates_total-1-3) limit=rates_total-1-3;

//--- calculate how many bars need to be recalculated
   int to_copy;
   if(prev_calculated<0 || prev_calculated>rates_total)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
      //--- older bars ([1],[2],[3]) are needed to calculate the current bar
      to_copy+=3;
      if(to_copy>rates_total)
         to_copy=rates_total;
     }

//--- create array for rate data of timeseries
   if(CreatePriceArray(to_copy)<=0) return(0);

//--- calculate Smooth buffer
   for(int i=limit;i>=0;i--)
      ExtSmoothBuffer[i]=(CalcPriceArray[i]+2.0*CalcPriceArray[i+1]+2.0*CalcPriceArray[i+2]+CalcPriceArray[i+3])/6.0;

//--- calculate Cycle buffer
   for(int i=limit;i>=0;i--)
      ExtCycleBuffer[i]=InpBeta*((1.0-0.5*InpAlpha)*(1.0-0.5*InpAlpha)*(ExtSmoothBuffer[i]-2.0*ExtSmoothBuffer[i+1]+ExtSmoothBuffer[i+2])+2.0*(1.0-InpAlpha)*ExtCycleBuffer[i+1]-(1.0-InpAlpha)*(1.0-InpAlpha)*ExtCycleBuffer[i+2]);

//--- get maximum from Cycle buffer during window
   int iMax=ArrayMaximum(ExtCycleBuffer,0,window_size);
   double Max=ExtCycleBuffer[iMax];
//--- get minimum from Cycle buffer during window
   int iMin=ArrayMinimum(ExtCycleBuffer,0,window_size);
   double Min=ExtCycleBuffer[iMin];
   double Gomot;
   if(MathAbs(Max)>MathAbs(Min))
      Gomot=MathAbs(Max);
   else
      Gomot=MathAbs(Min);
   double KGomot=InpNormalizeTarget/Gomot;

//--- calculate iCycle buffer
   for(int i=limit;i>=0;i--)
     {
      double NCycle=KGomot*ExtCycleBuffer[i];
      //--- set values for iCycle
      ExtICycleBuffer[i]=(MathExp(2.0*NCycle)-1.0)/(MathExp(2.0*NCycle)+1.0);
      //--- initialize values for iCycle arrow
      ExtICycleArrowBuffer[i]=EMPTY_VALUE;
     }

//--- set values for iCycle arrow
   if(InpDrawArrows==true)
     {
      for(int i=limit;i>=0;i--)
        {
         if(ExtICycleBuffer[i]>=0.5 && ExtICycleBuffer[i+1]<0.5)
            ExtICycleArrowBuffer[i]=ExtICycleBuffer[i];
         if(ExtICycleBuffer[i]<=-0.5 && ExtICycleBuffer[i+1]>-0.5)
            ExtICycleArrowBuffer[i]=ExtICycleBuffer[i];
         if((ExtICycleBuffer[i]<0.5 && ExtICycleBuffer[i+1]>=0.5) || (ExtICycleBuffer[i]>-0.5 && ExtICycleBuffer[i+1]<=-0.5))
            ExtICycleArrowBuffer[i]=ExtICycleBuffer[i];
        }
     }

//--- set multi color for iCycle and iCycle arrow
   if(InpUseMultiColor==MultiColor)
     {
      for(int i=limit;i>=0;i--)
        {
         //--- set color iCycle
         if(ExtICycleBuffer[i]>=0.5)
            ExtICycleColorBuffer[i]=1;
         if(ExtICycleBuffer[i]<=-0.5)
            ExtICycleColorBuffer[i]=2;
         if(ExtICycleBuffer[i]<0.5 && ExtICycleBuffer[i]>-0.5)
            ExtICycleColorBuffer[i]=0;
         //--- set color iCycle arrow
         ExtICycleArrowColorBuffer[i]=ExtICycleColorBuffer[i];
        }
     }
//--- set single color for iCycle and iCycle arrow
   if(InpUseMultiColor==SingleColor)
     {
      for(int i=limit;i>=0;i--)
        {
         //--- set color iCycle
         ExtICycleColorBuffer[i]=0;
         //--- set color iCycle arrow
         ExtICycleArrowColorBuffer[i]=0;
        }
     }

//--- return value of rates_total, will be used as prev_calculated in next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
