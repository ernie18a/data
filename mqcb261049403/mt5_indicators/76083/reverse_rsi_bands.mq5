//+------------------------------------------------------------------+
//|                                            Reverse_RSI_Bands.mq5 |
//|                                            Copyright 2026, Ondeb 0
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Ondeb"
#property version   "1.0"
#property description "Exact mathematical Reverse RSI bands"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2

//--- plot Overbought Price Level
#property indicator_label1  "RSI OB Band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- plot Oversold Price Level
#property indicator_label2  "RSI OS Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- input parameters
input uint                 InpPeriodRSI      = 14;            // RSI Period
input double               InpObLevel        = 70.0;          // Overbought target RSI
input double               InpOsLevel        = 30.0;          // Oversold target RSI
input ENUM_APPLIED_PRICE   InpAppliedPrice   = PRICE_CLOSE;   // Applied Price

//--- indicator buffers
double         BufferOB[];      // Plot 1: Price level for OB
double         BufferOS[];      // Plot 2: Price level for OS

double         BufferPrice[];   // Internal: Source prices
double         BufferUP[];      // Internal: Up changes
double         BufferDN[];      // Internal: Down changes
double         BufferAvgU[];    // Internal: Wilder Avg Gain
double         BufferAvgD[];    // Internal: Wilder Avg Loss

//--- constants
const double   MAX_RSI_VALUE = 100.0;
const double   MAX_RSI_LIMIT = 99.9;
const double   MIN_RSI_LIMIT = 0.1;
const double   NEUTRAL_RSI   = 50.0;

//--- global variables
int            period_rsi;
double         ob_level;
double         os_level;
int            handle_price;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- sanitize inputs
   period_rsi = (int)(InpPeriodRSI < 2 ? 2 : InpPeriodRSI);
   ob_level = InpObLevel;
   if(ob_level >= MAX_RSI_VALUE)
      ob_level = MAX_RSI_LIMIT;
   if(ob_level <= 0.0)
      ob_level = MIN_RSI_LIMIT;

   os_level = InpOsLevel;
   if(os_level >= MAX_RSI_VALUE)
      os_level = MAX_RSI_LIMIT;
   if(os_level <= 0.0)
      os_level = MIN_RSI_LIMIT;

//--- indicator buffers mapping
   SetIndexBuffer(0, BufferOB, INDICATOR_DATA);
   SetIndexBuffer(1, BufferOS, INDICATOR_DATA);
   SetIndexBuffer(2, BufferPrice, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, BufferUP, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, BufferDN, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, BufferAvgU, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, BufferAvgD, INDICATOR_CALCULATIONS);

//--- set indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME, "Reverse RSI Bands (" + (string)period_rsi + ", " + DoubleToString(ob_level, 1) + "/" + DoubleToString(os_level, 1) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- set drawing offset
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, period_rsi);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, period_rsi);

//--- arrays are treated as standard arrays (index 0 is oldest, rates_total-1 is latest)
   ArraySetAsSeries(BufferOB, false);
   ArraySetAsSeries(BufferOS, false);
   ArraySetAsSeries(BufferPrice, false);
   ArraySetAsSeries(BufferUP, false);
   ArraySetAsSeries(BufferDN, false);
   ArraySetAsSeries(BufferAvgU, false);
   ArraySetAsSeries(BufferAvgD, false);

//--- create helper MA handle to easily copy applied price
   ResetLastError();
   handle_price = iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, InpAppliedPrice);
   if(handle_price == INVALID_HANDLE)
     {
      Print("Failed to create price iMA handle: Error ", GetLastError());
      return(INIT_FAILED);
     }

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
//--- check minimum bars
   if(rates_total < period_rsi + 2)
      return(0);

//--- copy applied price values
   int copied = CopyBuffer(handle_price, 0, 0, rates_total, BufferPrice);
   if(copied != rates_total)
     {
      Print("Error copying price data: ", GetLastError());
      return(0);
     }

//--- determine starting index
   int start = prev_calculated;
   if(start <= 0)
     {
      start = 1; // start from index 1 because we need BufferPrice[i] - BufferPrice[i-1]
      // Initialize arrays
      ArrayInitialize(BufferOB, EMPTY_VALUE);
      ArrayInitialize(BufferOS, EMPTY_VALUE);
      ArrayInitialize(BufferUP, 0.0);
      ArrayInitialize(BufferDN, 0.0);
      ArrayInitialize(BufferAvgU, 0.0);
      ArrayInitialize(BufferAvgD, 0.0);
     }
   else
     {
      // Recalculate last bar to update live tick calculations
      start = prev_calculated - 1;
      if(start < 1)
         start = 1;
     }

//--- Calculate raw gains and losses (UP and DN)
   CalculateRawGains(start, rates_total);

//--- Calculate Wilder Smoothing for AvgU and AvgD
   CalculateWilderSmoothing(start, rates_total);

//--- Calculate exact Reverse RSI Prices for OB and OS levels
   CalculateReversePrices(start, rates_total);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate raw positive and negative price changes                |
//+------------------------------------------------------------------+
void CalculateRawGains(const int start, const int rates_total)
  {
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      double diff = BufferPrice[i] - BufferPrice[i-1];
      BufferUP[i] = (diff > 0.0) ? diff : 0.0;
      BufferDN[i] = (diff < 0.0) ? -diff : 0.0;
     }
  }

//+------------------------------------------------------------------+
//| Calculate Wilder Smoothing averages                              |
//+------------------------------------------------------------------+
void CalculateWilderSmoothing(const int start, const int rates_total)
  {
   double alpha = 1.0 / (double)period_rsi;
   int first_valid_index = period_rsi;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      if(i < first_valid_index)
        {
         BufferAvgU[i] = 0.0;
         BufferAvgD[i] = 0.0;
         BufferOB[i]   = EMPTY_VALUE;
         BufferOS[i]   = EMPTY_VALUE;
         continue;
        }

      //--- Seed initialization: Simple Moving Average on the first window
      if(i == first_valid_index)
        {
         double sumU = 0.0;
         double sumD = 0.0;
         for(int j = 1; j <= period_rsi; j++)
           {
            sumU += BufferUP[j];
            sumD += BufferDN[j];
           }
         BufferAvgU[i] = sumU / (double)period_rsi;
         BufferAvgD[i] = sumD / (double)period_rsi;
        }
      else
        {
         //--- Wilder Smoothing recursive formula
         BufferAvgU[i] = BufferAvgU[i-1] * (1.0 - alpha) + BufferUP[i] * alpha;
         BufferAvgD[i] = BufferAvgD[i-1] * (1.0 - alpha) + BufferDN[i] * alpha;
        }
     }
  }

//+------------------------------------------------------------------+
//| Calculate exact Reverse RSI target prices                        |
//+------------------------------------------------------------------+
void CalculateReversePrices(const int start, const int rates_total)
  {
   int first_valid_index = period_rsi;
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      if(i <= first_valid_index)
        {
         BufferOB[i] = EMPTY_VALUE;
         BufferOS[i] = EMPTY_VALUE;
         continue;
        }

      //--- Prior state
      double prev_avg_u = BufferAvgU[i-1];
      double prev_avg_d = BufferAvgD[i-1];
      double prev_price = BufferPrice[i-1];

      double AU0 = prev_avg_u * (double)(period_rsi - 1);
      double AD0 = prev_avg_d * (double)(period_rsi - 1);

      //--- Overbought Price Band
      double RS_ob = ob_level / (MAX_RSI_VALUE - ob_level);
      double x_ob = RS_ob * AD0 - AU0;
      if(x_ob >= 0.0)
         BufferOB[i] = prev_price + x_ob;
      else
         BufferOB[i] = prev_price + x_ob * (MAX_RSI_VALUE - ob_level) / ob_level;

      //--- Oversold Price Band
      double RS_os = os_level / (MAX_RSI_VALUE - os_level);
      double x_os = RS_os * AD0 - AU0;
      if(x_os >= 0.0)
         BufferOS[i] = prev_price + x_os;
      else
         BufferOS[i] = prev_price + x_os * (MAX_RSI_VALUE - os_level) / os_level;
     }
  }
//+------------------------------------------------------------------+

