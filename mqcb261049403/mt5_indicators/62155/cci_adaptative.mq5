//+------------------------------------------------------------------+
//|                 CCI Adptive Indicator for MetaTrader 5           |
//|                     Fixed & Enhanced by Joy & Qwen               |
//|                        https://www.mql5.com/en/users/jhoe125     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Joy & Qwen"
#property link      "https://www.mql5.com/en/users/jhoe125"
#property version   "1.0"
#property description "CCI Adaptive"


//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plots do CCI
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1
#property indicator_label1  "CCI"

//--- plots dos limites adaptativos
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_label2  "Over Bought"

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_width3  1
#property indicator_label3  "Over Sold"

//--- input parameters
input int    CCI_Period = 14;          // CCI period
input int    BaseThreshold = 100;      // Threshold base for detection
input double EMA_Smoothing = 0.2;      // EMA suavization Factor (0.1-0.3)
input int    ATR_Period = 14;          // ATR period for volatility adaptation
input double VolatilityFactor = 0.5;   // ATR factor for adaptation

//--- indicator buffers
double ExtCCIBuffer[];
double ExtUpperLimitBuffer[];
double ExtLowerLimitBuffer[];

//--- handles
int cciHandle;
int atrHandle;

//--- global variables
bool   isMonitoringPeak = false;
bool   isMonitoringTrough = false;
double currentPeakValue = -100000;
double currentTroughValue = 100000;
double dynamicUpperLimit = 110.0;
double dynamicLowerLimit = -110.0;
double baseThreshold = 100.0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers
   SetIndexBuffer(0, ExtCCIBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtUpperLimitBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowerLimitBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//--- empty values
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- start draw
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, CCI_Period);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, CCI_Period);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, CCI_Period);

//--- create indicator handles
   cciHandle = iCCI(_Symbol, _Period, CCI_Period, PRICE_CLOSE);
   if(cciHandle == INVALID_HANDLE)
     {
      Print("Erro ao criar handle do CCI");
      return(INIT_FAILED);
     }

   atrHandle = iATR(_Symbol, _Period, ATR_Period);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Erro ao criar handle do ATR");
      return(INIT_FAILED);
     }

//--- start threshold
   baseThreshold = (double)BaseThreshold;
   dynamicUpperLimit = baseThreshold * 1.1;
   dynamicLowerLimit = -baseThreshold * 1.1;

//--- define indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "CCI Adaptativo (Base=" + IntegerToString(BaseThreshold) + ")");

   Print("Indicador inicializado com sucesso. Limite superior inicial: ", dynamicUpperLimit,
         ", Limite inferior inicial: ", dynamicLowerLimit);
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
//--- verify min data
   if(rates_total < CCI_Period + 1)
      return(0);

//--- index
   int start = prev_calculated == 0 ? CCI_Period : prev_calculated - 1;

//--- copy CCI values
   if(CopyBuffer(cciHandle, 0, 0, rates_total, ExtCCIBuffer) <= 0)
     {
      Print("Erro ao copiar valores do CCI");
      return(0);
     }

//--- copy ATR values for adaptive volatility 
   double atrValues[];
   if(CopyBuffer(atrHandle, 0, 0, rates_total, atrValues) <= 0)
     {
      Print("Erro ao copiar valores do ATR");
      return(0);
     }

//--- main loop
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      //--- obtain ATR values for EMA period calculation
      double currentATR = atrValues[i] > 0 ? atrValues[i] : 1.0;
      double avgATR = 1.0;

      // normalized ATR AVG
      if(i >= ATR_Period)
        {
         double sumATR = 0.0;
         for(int j = 0; j < ATR_Period; j++)
            sumATR += atrValues[i-j];
         avgATR = sumATR / ATR_Period;
        }

      //--- adaptive period of EMA with volatility base
      double volatilityRatio = currentATR / avgATR;
      double adaptiveFactor = EMA_Smoothing;

      // adjust suavization factor with volatility base
      if(volatilityRatio > 1.5) // High volatility
         adaptiveFactor = EMA_Smoothing * 1.5;
      else
         if(volatilityRatio < 0.5) // Low volatility
            adaptiveFactor = EMA_Smoothing * 0.7;

      //--- MONITORING TOPS AND BOTTOMS ---

      // Monitoring tops (sell signal)
      if(!isMonitoringPeak && ExtCCIBuffer[i] > baseThreshold)
        {
         isMonitoringPeak = true;
         currentPeakValue = ExtCCIBuffer[i];
        }
      else
         if(isMonitoringPeak)
           {
            if(ExtCCIBuffer[i] > currentPeakValue)
               currentPeakValue = ExtCCIBuffer[i];

            if(ExtCCIBuffer[i] < baseThreshold)
              {
               dynamicUpperLimit = (currentPeakValue * adaptiveFactor) + (dynamicUpperLimit * (1 - adaptiveFactor));

               // Reset monitor
               isMonitoringPeak = false;
              }
           }

      // Monitoring bottoms (buy signal)
      if(!isMonitoringTrough && ExtCCIBuffer[i] < -baseThreshold)
        {
         isMonitoringTrough = true;
         currentTroughValue = ExtCCIBuffer[i];
        }
      else
         if(isMonitoringTrough)
           {
            if(ExtCCIBuffer[i] < currentTroughValue)
               currentTroughValue = ExtCCIBuffer[i];

            if(ExtCCIBuffer[i] > -baseThreshold)
              {
               dynamicLowerLimit = (currentTroughValue * adaptiveFactor) + (dynamicLowerLimit * (1 - adaptiveFactor));

               // Reset monitor
               isMonitoringTrough = false;
              }
           }

      //--- PLOT ADPTIVE THRESHOLD ---
      ExtUpperLimitBuffer[i] = dynamicUpperLimit;
      ExtLowerLimitBuffer[i] = dynamicLowerLimit;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
