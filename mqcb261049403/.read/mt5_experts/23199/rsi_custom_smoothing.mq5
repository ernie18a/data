//+------------------------------------------------------------------+
//|                                         RSI Custom Smoothing.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Relative Strength Index smoothing"
//--- indicator settings
#include <MovingAverages.mqh>
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
//--- input parameters
input int      Inp_RSI_Period       = 14;             // Period
input color    Inp_RSI_Color        = clrDodgerBlue;  // Color line
input int      Inp_RSI_Width        = 1;              // Width
input int      Inp_RSI_Level1       = 30.0;           // Value Level #1
input double   Inp_RSI_Level2       = 70.0;           // Value Level #2
//--- indicator buffers
double    ExtRSIBufferSmoothing[];
double    ExtRSIBuffer[];
double    ExtPosBuffer[];
double    ExtNegBuffer[];
//--- global variable
int       ExtPeriodRSI;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input
   if(Inp_RSI_Period<1)
     {
      ExtPeriodRSI=12;
      Print("Incorrect value for input variable Inp_RSI_Period =",Inp_RSI_Period,
            "Indicator will use value =",ExtPeriodRSI,"for calculations.");
     }
   else
      ExtPeriodRSI=Inp_RSI_Period;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSIBufferSmoothing,INDICATOR_DATA);
   SetIndexBuffer(1,ExtRSIBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtPosBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtNegBuffer,INDICATOR_CALCULATIONS);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- custom parameters
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,Inp_RSI_Color);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,Inp_RSI_Width);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_RSI_Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_RSI_Level2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtPeriodRSI);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI("+string(ExtPeriodRSI)+")");
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int    i;
   double diff;
//--- check for rates count
   if(rates_total<=ExtPeriodRSI)
      return(0);
//--- preliminary calculations
   int pos=prev_calculated-1;
   if(pos<=ExtPeriodRSI)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtRSIBuffer[0]=0.0;
      ExtPosBuffer[0]=0.0;
      ExtNegBuffer[0]=0.0;
      double SumP=0.0;
      double SumN=0.0;
      for(i=1;i<=ExtPeriodRSI;i++)
        {
         ExtRSIBuffer[i]=0.0;
         ExtPosBuffer[i]=0.0;
         ExtNegBuffer[i]=0.0;
         diff=price[i]-price[i-1];
         SumP+=(diff>0?diff:0);
         SumN+=(diff<0?-diff:0);
        }
      //--- calculate first visible value
      ExtPosBuffer[ExtPeriodRSI]=SumP/ExtPeriodRSI;
      ExtNegBuffer[ExtPeriodRSI]=SumN/ExtPeriodRSI;
      if(ExtNegBuffer[ExtPeriodRSI]!=0.0)
         ExtRSIBuffer[ExtPeriodRSI]=100.0-(100.0/(1.0+ExtPosBuffer[ExtPeriodRSI]/ExtNegBuffer[ExtPeriodRSI]));
      else
        {
         if(ExtPosBuffer[ExtPeriodRSI]!=0.0)
            ExtRSIBuffer[ExtPeriodRSI]=100.0;
         else
            ExtRSIBuffer[ExtPeriodRSI]=50.0;
        }
      //--- prepare the position value for main calculation
      pos=ExtPeriodRSI+1;
     }
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
      diff=price[i]-price[i-1];
      ExtPosBuffer[i]=(ExtPosBuffer[i-1]*(ExtPeriodRSI-1)+(diff>0.0?diff:0.0))/ExtPeriodRSI;
      ExtNegBuffer[i]=(ExtNegBuffer[i-1]*(ExtPeriodRSI-1)+(diff<0.0?-diff:0.0))/ExtPeriodRSI;
      if(ExtNegBuffer[i]!=0.0)
         ExtRSIBuffer[i]=100.0-100.0/(1+ExtPosBuffer[i]/ExtNegBuffer[i]);
      else
        {
         if(ExtPosBuffer[i]!=0.0)
            ExtRSIBuffer[i]=100.0;
         else
            ExtRSIBuffer[i]=50.0;
        }
     }
   SimpleMAOnBuffer(rates_total,prev_calculated,0,6,ExtRSIBuffer,ExtRSIBufferSmoothing);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
