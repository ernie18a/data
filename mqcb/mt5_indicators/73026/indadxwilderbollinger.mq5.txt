//+------------------------------------------------------------------+
//|                                     IndAdxWilderBollinger.01.mq5 |
//|                            Copyright 2025, AlgoTradeAcademy Ltd. |
//|                                    https://algotradeacademy.com/ |
//+------------------------------------------------------------------+

//--- Indicator general information
#property copyright "Copyright 2025, AlgoTradeAcademy Ltd."
#property link      "https://algotradeacademy.com/"
#property version   "1.00"
#property indicator_separate_window   // Indicator is drawn in a separate window
#property indicator_buffers 6         // Total number of data buffers
#property indicator_plots   6         // Total number of plotted lines

//--- Labels shown in the Data Window for each plot
#property indicator_label1  "Adx"     // ADX main line
#property indicator_label2  "+DI"     // Positive Directional Indicator
#property indicator_label3  "-DI"     // Negative Directional Indicator
#property indicator_label4  "Middle"  // Bollinger Bands middle line
#property indicator_label5  "Upper"   // Bollinger Bands upper line
#property indicator_label6  "Lower"   // Bollinger Bands lower line

//--- Plot types (all drawn as lines)
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE

//--- Plot colors
#property indicator_color1 clrYellow  // ADX line color
#property indicator_color2 clrGreen   // +DI line color
#property indicator_color3 clrRed     // -DI line color
#property indicator_color4 clrDimGray // Bollinger middle band color
#property indicator_color5 clrDimGray // Bollinger upper band color
#property indicator_color6 clrDimGray // Bollinger lower band color

//--- Line widths for main ADX and DI lines
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

//--- Line styles for Bollinger Bands (dotted)
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT
#property indicator_style6 STYLE_DOT

//---- Input parameters configurable by the user
input int                AdxPeriod = 16;           // ADX Wilder calculation period
input int             BollingerPeriod = 20;        // Bollinger Bands period
input int             BollingerDevition = 1;       // Bollinger Bands deviation
input ENUM_APPLIED_PRICE AdxPrice = PRICE_CLOSE;   // Applied price for ADX (reserved)
input ENUM_APPLIED_PRICE BollingerPrice = PRICE_CLOSE; // Applied price for Bands (reserved)

//---- Indicator buffers to store calculated values
double ADXWilderBuff[], ADXWilderDiPossBuff[], ADXWilderDiNegativeBuff[];
double BollingerBandMainBuff[], BollingerBandUPERRBuff[], BollingerBandDOWNBuff[];

//---- Handles for built-in indicators
int    HandleADXWilder, HandleBollingerADXWilder;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Set indicator short name and decimal precision
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "AdxWilder(" + IntegerToString(AdxPeriod) +
                      ")-Bands(" + IntegerToString(BollingerPeriod) + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   //--- Map indicator buffers to plots
   SetIndexBuffer(0, ADXWilderBuff, INDICATOR_DATA);          // ADX buffer
   SetIndexBuffer(1, ADXWilderDiPossBuff, INDICATOR_DATA);   // +DI buffer
   SetIndexBuffer(2, ADXWilderDiNegativeBuff, INDICATOR_DATA); // -DI buffer
   SetIndexBuffer(3, BollingerBandMainBuff, INDICATOR_DATA); // Bollinger middle
   SetIndexBuffer(4, BollingerBandUPERRBuff, INDICATOR_DATA);// Bollinger upper
   SetIndexBuffer(5, BollingerBandDOWNBuff, INDICATOR_DATA); // Bollinger lower

   //--- Define drawing start index to avoid incomplete calculations
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, AdxPeriod);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, AdxPeriod);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, AdxPeriod);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, AdxPeriod + BollingerPeriod);
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, AdxPeriod + BollingerPeriod);
   PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, AdxPeriod + BollingerPeriod);

   //--- Create indicator handles
   HandleADXWilder = iADXWilder(NULL, 0, AdxPeriod); // ADX Wilder handle
   HandleBollingerADXWilder = iBands(NULL, 0,
                                     BollingerPeriod,
                                     0,
                                     BollingerDevition,
                                     HandleADXWilder); // Bollinger Bands on ADX

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                             |
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
   //--- Determine calculation range (reserved for optimization)
   int limit;
   if(prev_calculated == 0)
      limit = 0;
   else
      limit = prev_calculated - 1;

   //--- Copy data from built-in indicator buffers to custom buffers
   CopyBuffer(HandleADXWilder, 0, 0, rates_total, ADXWilderBuff);
   CopyBuffer(HandleADXWilder, 1, 0, rates_total, ADXWilderDiPossBuff);
   CopyBuffer(HandleADXWilder, 2, 0, rates_total, ADXWilderDiNegativeBuff);

   CopyBuffer(HandleBollingerADXWilder, 0, 0, rates_total, BollingerBandMainBuff);
   CopyBuffer(HandleBollingerADXWilder, 1, 0, rates_total, BollingerBandUPERRBuff);
   CopyBuffer(HandleBollingerADXWilder, 2, 0, rates_total, BollingerBandDOWNBuff);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
int deinit()
  {
   //--- Release indicator handles and free memory
   IndicatorRelease(HandleADXWilder);
   IndicatorRelease(HandleBollingerADXWilder);

   ArrayFree(ADXWilderBuff);
   ArrayFree(ADXWilderDiPossBuff);
   ArrayFree(ADXWilderDiNegativeBuff);
   ArrayFree(BollingerBandMainBuff);
   ArrayFree(BollingerBandUPERRBuff);
   ArrayFree(BollingerBandDOWNBuff);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
