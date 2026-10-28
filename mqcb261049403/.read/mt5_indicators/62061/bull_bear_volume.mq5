//+------------------------------------------------------------------+
//|                                               BullBearVolume.mq5 |
//|                             Converted from Amibroker AFL to MQL5 |
//|                                 Original Author: Nick Molchanoff |
//|                       https://www.mql5.com/en/forum/177976/page2 |
//| Description: Splits tick volume into bullish and bearish         |
//| components using candlestick direction (open vs. close) for      |
//| up-day/down-day and current timeframe close prices for momentum  |
//| (up-close/down-close). Volumes are smoothed with Triple          |
//| Exponential Moving Averages (TEMA). Helps identify daily buying  |
//| and selling pressure on the current timeframe.                   |
//|                                                                  |
//| Volume Classification:                                           |
//| - Up-day (ud): D1 Close > D1 Open (bullish daily candle)         |
//| - Down-day (dd): D1 Close <= D1 Open (bearish/neutral candle)    |
//| - Up-close (uc): Current timeframe Close > Previous Close        |
//| - Down-close (dc): Current timeframe Close <= Previous Close     |
//| Types:                                                           |
//| - Green (vType 1): Up-day and up-close (strong bullish)          |
//| - Green (vType 2): Down-day but up-close (bullish momentum)      |
//| - Red (vType 3): Up-day but down-close (bullish but fading)      |
//| - Red (vType 4): Down-day and down-close (strong bearish)        |
//| - White (vType 5): Neutral (no volume assigned)                  |
//| Bull volume: vType 1 or 2; Bear volume: vType 3 or 4             |
//| D1 volume is assigned to all current timeframe bars within the   |
//| same D1 period.                                                  |
//|                                                                  |
//| Plots:                                                           |
//|- Total Volume MA (White Histogram/Line): TEMA of D1 tick volume, |
//|   showing overall daily market activity.                         |
//| - Bull Volume MA (Green Histogram/Line): TEMA of D1 bullish      |
//|  volume, indicating daily buying pressure with current timeframe |
//|   momentum.                                                      |
//|- Bear Volume MA (Red Histogram/Line): TEMA of D1 bearish volume, |
//|   indicating daily selling pressure with current timeframe       |
//|   momentum.                                                      |
//| - Convergence Oscillator (Magenta Line): TEMA of bull - bear     |
//|   volume difference, showing net daily momentum.                 |
//| - Rise/Fall Shadows (Pale Green/Pink Histogram): Highlights      |
//|    rising (green) or falling (pink) convergence when above zero. |
//| - Bull/Bear Level Lines (Green/Red): Horizontal lines at current |
//|   bull/bear volume MA values for comparison.                     |
//+------------------------------------------------------------------+
#property copyright "Nick Molchanoff"
#property link      "https://www.WiseStockTrader.com"
#property version   "1.03"
#property indicator_separate_window
#property indicator_buffers 17
#property indicator_plots   8
#property indicator_label1  "Total Volume MA"           // White histogram: TEMA of D1 tick volume
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_label2  "Bull Volume MA"            // Green histogram: TEMA of D1 bullish volume
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_label3  "Bear Volume MA"            // Red histogram: TEMA of D1 bearish volume
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_label4  "Total Volume MA Line"      // White line: Overlay of D1 total volume MA
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrWhite
#property indicator_style4  STYLE_SOLID
#property indicator_label5  "Bull Volume MA Line"       // Green line: D1 bull volume MA or level
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrGreen, clrNONE
#property indicator_style5  STYLE_SOLID
#property indicator_label6  "Bear Volume MA Line"       // Red line: D1 bear volume MA or level
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrRed, clrNONE
#property indicator_style6  STYLE_SOLID
#property indicator_label7  "Convergence Oscillator"    // Magenta line: TEMA of D1 bull - bear difference
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrMagenta
#property indicator_style7  STYLE_SOLID
#property indicator_label8  "Rise/Fall Shadows"         // Colored histogram: Green for rising, pink for falling
#property indicator_type8   DRAW_COLOR_HISTOGRAM
#property indicator_color8  clrPaleGreen,clrPink
#property indicator_style8  STYLE_SOLID

//--- Input parameters
input int VolPer = 34;                    // TEMA period for volume (bull, bear, total)
input int ConvPer = 9;                    // TEMA period for convergence oscillator
input bool ShowOscillatorOnly = false;    // Show only convergence oscillator
input bool ShowBullLevel = true;          // Show horizontal line at current bull volume MA
input bool ShowBearLevel = true;          // Show horizontal line at current bull volume MA
input bool ShowBullVolume = true;         // Show bull volume histogram and line
input bool ShowBearVolume = true;         // Show bear volume histogram and line
input bool ShowTotalVolume = true;        // Show total volume histogram and line
input bool ShowConvergenceOscillator = false; // Show convergence oscillator
input bool ShowRiseFallShadows = false;   // Show rise/fall shadows
input int barLimit = 500;                 // Bar limit

//--- Indicator buffers
double TotalVolMABuffer[];      // Total volume TEMA (white histogram)
double BullVolMABuffer[];       // Bull volume TEMA (green histogram)
double BearVolMABuffer[];       // Bear volume TEMA (red histogram)
double TotalVolMALineBuffer[];  // Total volume TEMA line (white line)
double BullVolMALineBuffer[];   // Bull volume TEMA or level (green line)
double BearVolMALineBuffer[];   // Bear volume TEMA or level (red line)
double BullVolMAColBuffer[];   // Bull volume TEMA or level (green line)
double BearVolMAColBuffer[];   // Bear volume TEMA or level (red line)

double ConvergenceBuffer[];     // Convergence oscillator (magenta line)
double UpVolBuffer[];           // D1 bullish volume
double DownVolBuffer[];         // D1 bearish volume
double ShadowBuffer[];          // Rise/fall shadows histogram
double ShadowColorBuffer[];     // Shadow colors (0: pale green, 1: pink)
double temp_buffer[];
double ema1[], ema2[], ema3[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, TotalVolMABuffer, INDICATOR_DATA);
   SetIndexBuffer(1, BullVolMABuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BearVolMABuffer, INDICATOR_DATA);
   SetIndexBuffer(3, TotalVolMALineBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, BullVolMALineBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, BullVolMAColBuffer, INDICATOR_COLOR_INDEX);
      
   SetIndexBuffer(6, BearVolMALineBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, BearVolMAColBuffer, INDICATOR_COLOR_INDEX);
        
   SetIndexBuffer(8, ConvergenceBuffer, INDICATOR_DATA);
   SetIndexBuffer(9, ShadowBuffer, INDICATOR_DATA);
   SetIndexBuffer(10, ShadowColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(11, UpVolBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(12, DownVolBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(13, temp_buffer, INDICATOR_CALCULATIONS);    
   SetIndexBuffer(14, ema1, INDICATOR_CALCULATIONS);    
   SetIndexBuffer(15, ema2, INDICATOR_CALCULATIONS);    
   SetIndexBuffer(16, ema3, INDICATOR_CALCULATIONS);    
            
   ArraySetAsSeries(TotalVolMABuffer, true);
   ArraySetAsSeries(BullVolMABuffer, true);
   ArraySetAsSeries(BearVolMABuffer, true);
   ArraySetAsSeries(TotalVolMALineBuffer, true);
   ArraySetAsSeries(BullVolMALineBuffer, true);
   ArraySetAsSeries(BearVolMALineBuffer, true);
   ArraySetAsSeries(ConvergenceBuffer, true);
   ArraySetAsSeries(UpVolBuffer, true);
   ArraySetAsSeries(DownVolBuffer, true);
   ArraySetAsSeries(ShadowBuffer, true);
   ArraySetAsSeries(ShadowColorBuffer, true);
   ArraySetAsSeries(BearVolMAColBuffer, true);
   ArraySetAsSeries(BullVolMAColBuffer, true);
   ArraySetAsSeries(temp_buffer, true);    
   ArraySetAsSeries(ema1, true);
   ArraySetAsSeries(ema2, true);
   ArraySetAsSeries(ema3, true);
  
   IndicatorSetString(INDICATOR_SHORTNAME,"BullBearVolume");
  
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
  
   PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, ConvPer);
   PlotIndexSetInteger(7, PLOT_DRAW_BEGIN, ConvPer);
  
   if(!ShowOscillatorOnly){
      IndicatorSetInteger(INDICATOR_LEVELS, 2);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrRed);
      IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_SOLID);  
      IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, clrGreen);
      IndicatorSetInteger(INDICATOR_LEVELSTYLE, 1, STYLE_SOLID);  
   }
  
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| TEMA calculation function                                         |
//+------------------------------------------------------------------+
void CalculateTEMA(const double &inp[], int period, double &output[], const int rates_total, int limit)
{
   if(period < 1 || rates_total < 1) return;
   
   double alpha = 2.0 / (period + 1.0);
   
   for(int i = limit - 1; i >= 0 && !IsStopped(); i--)
   {
      if(i >= rates_total) continue;
   
      if(i >= rates_total - 1)
      {
         ema1[i] = inp[i];
         ema2[i] = inp[i];
         ema3[i] = inp[i];
      }
      else
      {
         ema1[i] = inp[i] * alpha + ema1[i + 1] * (1.0 - alpha);
         ema2[i] = ema1[i] * alpha + ema2[i + 1] * (1.0 - alpha);
         ema3[i] = ema2[i] * alpha + ema3[i + 1] * (1.0 - alpha);
      }
      
      output[i] = 3.0 * ema1[i] - 3.0 * ema2[i] + ema3[i];
   }
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(tick_volume, true);

   int limit;
      
   if(prev_calculated == 0)
   {
      limit = MathMax(barLimit + 1, 1);
      ArrayInitialize(UpVolBuffer, 0.0);
      ArrayInitialize(DownVolBuffer, 0.0);
      ArrayInitialize(temp_buffer, 0.0);
      ArrayInitialize(ema1, 0.0);
      ArrayInitialize(ema2, 0.0);
      ArrayInitialize(ema3, 0.0);
      ArrayInitialize(TotalVolMABuffer, EMPTY_VALUE);
      ArrayInitialize(BullVolMABuffer, EMPTY_VALUE);
      ArrayInitialize(BearVolMABuffer, EMPTY_VALUE);
      ArrayInitialize(TotalVolMALineBuffer, EMPTY_VALUE);
      ArrayInitialize(BullVolMALineBuffer, EMPTY_VALUE);
      ArrayInitialize(BearVolMALineBuffer, EMPTY_VALUE);
      ArrayInitialize(ConvergenceBuffer, EMPTY_VALUE);
      ArrayInitialize(ShadowBuffer, EMPTY_VALUE);
   }  
  else
  {
      limit = (rates_total - prev_calculated) + 1;  
      limit = MathMin(limit, barLimit);  
  }
  
  
   for(int i = limit - 1; i >= 0; i--)
   {
      if(i >= rates_total) continue;
   
      bool uc = (i + 1 < rates_total) ? close[i] > close[i + 1] : false;
      bool dc = (i + 1 < rates_total) ? close[i] <= close[i + 1] : false;
      bool ud = close[i] > open[i];  
      bool dd = close[i] <= open[i];

      int vType = 5;
      if(ud && uc)      vType = 1;    // Green: Up-day & Up-close
      else if(dd && uc) vType = 2;    // Green: Down-day & Up-close
      else if(ud && dc) vType = 3;    // Red: Up-day & Down-close
      else if(dd && dc) vType = 4;    // Red: Down-day & Down-close

      UpVolBuffer[i]   = (vType == 1 || vType == 2) ? (double)tick_volume[i] : 0.0;
      DownVolBuffer[i] = (vType == 3 || vType == 4) ? (double)tick_volume[i] : 0.0;
      
      BearVolMAColBuffer[i] = (BullVolMABuffer[i] > BearVolMABuffer[i]) ? 1.0 : 0.0;
      BullVolMAColBuffer[i] = (BearVolMABuffer[i] > BullVolMABuffer[i]) ? 1.0 : 0.0;        
   }

   CalculateTEMA(UpVolBuffer, VolPer, BullVolMABuffer, rates_total, limit);
   CalculateTEMA(DownVolBuffer, VolPer, BearVolMABuffer, rates_total, limit);


   if(!ShowOscillatorOnly && ShowTotalVolume)
   {
      for(int i = limit - 1; i >= 0; i--)
      {
         if(i >= rates_total) continue;
         temp_buffer[i] = (double)tick_volume[i];
      }
      CalculateTEMA(temp_buffer, VolPer, TotalVolMABuffer, rates_total, limit);
      
      for(int i = limit - 1; i >= 0; i--)
         TotalVolMALineBuffer[i] = TotalVolMABuffer[i];
   }

   if(ShowConvergenceOscillator || ShowOscillatorOnly || ShowRiseFallShadows)
   {
      for(int i = limit - 1; i >= 0; i--)
      {
         if(i >= rates_total) continue;
         
         double bull = (i < rates_total) ? BullVolMABuffer[i] : 0.0;
         double bear = (i < rates_total) ? BearVolMABuffer[i] : 0.0;
         
         temp_buffer[i] = bull - bear;
      }
      
      CalculateTEMA(temp_buffer, ConvPer, ConvergenceBuffer, rates_total, limit);
   }
   else
   {
      for(int i = limit - 1; i >= 0; i--) ConvergenceBuffer[i] = EMPTY_VALUE;
   }

   if(ShowRiseFallShadows)
   {
      for(int i = limit - 1; i >= 0; i--)
      {
         if(i >= rates_total) continue;
               
         bool convergeUp   = (i + 1 < rates_total) ? ConvergenceBuffer[i] > ConvergenceBuffer[i + 1] : false;
         bool convergeOver = ConvergenceBuffer[i] > 0.0;
         bool rising       = convergeUp && convergeOver;
         bool falling      = !convergeUp && convergeOver;
         
         ShadowBuffer[i]      = (rising || falling) ? ConvergenceBuffer[i] : 0.0;
         ShadowColorBuffer[i] = rising ? 0.0 : 1.0; 
      }
   }
   else
   {
      for(int i = limit - 1; i >= 0; i--) ShadowBuffer[i] = EMPTY_VALUE;
   }

   if(ShowOscillatorOnly)
   {
      for(int i = limit - 1; i >= 0; i--)
      {
         if(i >= rates_total) continue;
               
         TotalVolMABuffer[i]     = EMPTY_VALUE;
         TotalVolMALineBuffer[i] = EMPTY_VALUE;
         BullVolMABuffer[i]      = EMPTY_VALUE;
         BullVolMALineBuffer[i]  = EMPTY_VALUE;
         BearVolMABuffer[i]      = EMPTY_VALUE;
         BearVolMALineBuffer[i]  = EMPTY_VALUE;
      }
   }
   else 
   {
      for(int i = limit - 1; i >= 0; i--)
      {
         if(i >= rates_total) continue;
                  
         BullVolMALineBuffer[i] = BullVolMABuffer[i];
         BearVolMALineBuffer[i] = BearVolMABuffer[i];
      }

      if(!ShowTotalVolume)
      {
         for(int i = limit - 1; i >= 0; i--) { TotalVolMABuffer[i] = EMPTY_VALUE; TotalVolMALineBuffer[i] = EMPTY_VALUE; }
      }
      if(!ShowBullVolume)
      {
         for(int i = limit - 1; i >= 0; i--) { BullVolMABuffer[i] = EMPTY_VALUE; BullVolMALineBuffer[i] = EMPTY_VALUE; }
      }
      if(!ShowBearVolume)
      {
         for(int i = limit - 1; i >= 0; i--) { BearVolMABuffer[i] = EMPTY_VALUE; BearVolMALineBuffer[i] = EMPTY_VALUE; }
      }
   }
  
   if(ShowBearLevel && !ShowOscillatorOnly) IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, BearVolMABuffer[0]);
   if(ShowBullLevel && !ShowOscillatorOnly) IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, BullVolMABuffer[0]);


   return limit;
}