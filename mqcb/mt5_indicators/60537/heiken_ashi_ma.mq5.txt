#property copyright "Copyright 2025, ProtimeTrader."
#property link      "https://www.mql5.com/en/users/protimetrader"
#property description "Moving Average based on Heiken-Ashi"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers   7
#property indicator_plots     1

#property indicator_type1     DRAW_COLOR_LINE
#property indicator_color1    clrDodgerBlue, clrRed

//--- Input parameters
input ENUM_TIMEFRAMES      InpTimeframe         = PERIOD_CURRENT;       // Timeframe for Heiken Ashi calculation
input int                  InpMAPeriod          = 13;                   // Moving Average period
input int                  InpMAShift           = 0;                    // MA shift
input ENUM_MA_METHOD       InpMAMethod          = MODE_SMMA;            // MA method
input ENUM_APPLIED_PRICE   InpMAAppliedPrice    = PRICE_CLOSE;          // Source price for MA

//--- Indicator buffers
// Buffer 0: MA values
double ExtLineBuffer[];             // Buffer 0: MA values
double ExtLineColorBuffer[];        // Buffer 1: Color index
double ExtPriceBuffer[];            // Buffer 2: Source price from Heiken Ashi

// Buffer 3-6: Heiken Ashi OHLC
double ExtHAOpenPriceBuffer[];
double ExtHAHighPriceBuffer[];
double ExtHALowPriceBuffer[];
double ExtHAClosePriceBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
// Map buffers to indices
   SetIndexBuffer(0, ExtLineBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtLineColorBuffer, INDICATOR_COLOR_INDEX);

   SetIndexBuffer(2, ExtPriceBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, ExtHAOpenPriceBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ExtHAHighPriceBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, ExtHALowPriceBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, ExtHAClosePriceBuffer, INDICATOR_CALCULATIONS);

// Precision
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);

// Start drawing after enough data is available
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpMAPeriod);
   PlotIndexSetInteger(0, PLOT_SHIFT, InpMAShift);

// Label in Data Window
   string short_name;
   switch(InpMAMethod)
     {
      case MODE_EMA:
         short_name = "EMA";
         break;
      case MODE_LWMA:
         short_name = "LWMA";
         break;
      case MODE_SMA:
         short_name = "SMA";
         break;
      case MODE_SMMA:
         short_name = "SMMA";
         break;
      default:
         short_name = "unknown";
         break;
     }

   IndicatorSetString(INDICATOR_SHORTNAME, short_name + "(" + string(InpMAPeriod) + ")");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  }

//+------------------------------------------------------------------+
//| Core calculation function                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total < InpMAPeriod - 1 + begin)
     {
      string warn_msg = "Not enough bars to calculate Heiken Ashi MA (need at least " + IntegerToString(InpMAPeriod) + " bars)";
      Comment(warn_msg);
      Print(warn_msg);
      return(0);
     }
   else
     {
      Comment(""); // Clear any previous warning once conditions are met
     }

   int start = (prev_calculated == 0) ? 0 : 1;

// Initialize first HA candle to current OHLC
   if(prev_calculated == 0)
     {
      int last = rates_total - 1;
      ExtHAOpenPriceBuffer[last]  = iOpen(_Symbol, InpTimeframe, start);
      ExtHAClosePriceBuffer[last] = iClose(_Symbol, InpTimeframe, start);
      ExtHAHighPriceBuffer[last]  = iHigh(_Symbol, InpTimeframe, start);
      ExtHALowPriceBuffer[last]   = iLow(_Symbol, InpTimeframe, start);
     }

//--- Calculate Heiken Ashi candles
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      CalculateHeikenAshi(rates_total, i);
     }

//--- Copy selected Heiken Ashi price into MA source buffer
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      switch(InpMAAppliedPrice)
        {
         case PRICE_OPEN:
            ExtPriceBuffer[i] = ExtHAOpenPriceBuffer[i];
            break;
         case PRICE_HIGH:
            ExtPriceBuffer[i] = ExtHAHighPriceBuffer[i];
            break;
         case PRICE_LOW:
            ExtPriceBuffer[i] = ExtHALowPriceBuffer[i];
            break;
         case PRICE_MEDIAN:
            ExtPriceBuffer[i] = (ExtHAHighPriceBuffer[i] + ExtHALowPriceBuffer[i]) / 2.0;
            break;
         case PRICE_TYPICAL:
            ExtPriceBuffer[i] = (ExtHAHighPriceBuffer[i] + ExtHALowPriceBuffer[i] + ExtHAClosePriceBuffer[i]) / 3.0;
            break;
         case PRICE_WEIGHTED:
            ExtPriceBuffer[i] = (ExtHAHighPriceBuffer[i] + ExtHALowPriceBuffer[i] + ExtHAClosePriceBuffer[i] + ExtHAClosePriceBuffer[i]) / 4.0;
            break;

         default: // PRICE_CLOSE
            ExtPriceBuffer[i] = ExtHAClosePriceBuffer[i];
            break;
        }
     }

//--- Calculate moving average
   switch(InpMAMethod)
     {
      case MODE_EMA:
         CalculateEMA(rates_total, prev_calculated, begin, ExtPriceBuffer);
         break;
      case MODE_LWMA:
         CalculateLWMA(rates_total, prev_calculated, begin, ExtPriceBuffer);
         break;
      case MODE_SMA:
         CalculateSimpleMA(rates_total, prev_calculated, begin, ExtPriceBuffer);
         break;
      case MODE_SMMA:
         CalculateSmoothedMA(rates_total, prev_calculated, begin, ExtPriceBuffer);
         break;
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Calculate Heiken Ashi bar values                                 |
//+------------------------------------------------------------------+
void CalculateHeikenAshi(const int total, const int ind)
  {
   int i = ind;

   double o = iOpen(_Symbol, InpTimeframe, total - i - 1);
   double h = iHigh(_Symbol, InpTimeframe, total - i - 1);
   double l = iLow(_Symbol, InpTimeframe, total - i - 1);
   double c = iClose(_Symbol, InpTimeframe, total - i - 1);

   double ha_close = (o + h + l + c) / 4.0;

   double ha_open = (i > 0) ? (ExtHAOpenPriceBuffer[i - 1] + ExtHAClosePriceBuffer[i - 1]) / 2.0 : (o + c) / 2.0;

   double ha_high = MathMax(h, MathMax(ha_open, ha_close));
   double ha_low  = MathMin(l, MathMin(ha_open, ha_close));

   ExtHAOpenPriceBuffer[i]  = ha_open;
   ExtHAClosePriceBuffer[i] = ha_close;
   ExtHAHighPriceBuffer[i]  = ha_high;
   ExtHALowPriceBuffer[i]   = ha_low;

   ExtLineColorBuffer[i] = (ha_close > ha_open) ? 0.0 : 1.0;
  }

//+------------------------------------------------------------------+
//| Standard Moving Average Calculations                             |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int start = (prev_calculated == 0) ? InpMAPeriod : prev_calculated - 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      double sum = 0.0;
      for(int j = 0; j < InpMAPeriod; j++)
         sum += price[i - j];
      ExtLineBuffer[i] = sum / InpMAPeriod;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   double k = 2.0 / (InpMAPeriod + 1.0);
   int start = (prev_calculated == 0) ? InpMAPeriod : prev_calculated - 1;

   if(prev_calculated == 0)
      ExtLineBuffer[InpMAPeriod - 1] = price[InpMAPeriod - 1];

   for(int i = start; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = price[i] * k + ExtLineBuffer[i - 1] * (1 - k);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int weight_sum = InpMAPeriod * (InpMAPeriod + 1) / 2;
   int start = (prev_calculated == 0) ? InpMAPeriod : prev_calculated - 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      double sum = 0.0;
      for(int j = 0; j < InpMAPeriod; j++)
         sum += price[i - j] * (InpMAPeriod - j);
      ExtLineBuffer[i] = sum / weight_sum;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int start = (prev_calculated == 0) ? InpMAPeriod : prev_calculated - 1;

   if(prev_calculated == 0)
     {
      double sum = 0;
      for(int i = 0; i < InpMAPeriod; i++)
         sum += price[i];
      ExtLineBuffer[InpMAPeriod - 1] = sum / InpMAPeriod;
      start = InpMAPeriod;
     }

   for(int i = start; i < rates_total && !IsStopped(); i++)
      ExtLineBuffer[i] = (ExtLineBuffer[i - 1] * (InpMAPeriod - 1) + price[i]) / InpMAPeriod;
  }
//+------------------------------------------------------------------+
