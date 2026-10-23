//+------------------------------------------------------------------+
//|                                            Spread Calculator.mq5 |
//|            Copyright 2003-2026, Opengates Success International. |
//|               https://www.mql5.com/en/users/opengates2012/seller |
//+------------------------------------------------------------------+
#property copyright "2003-2026, Opengates Success International Org."
#property link "https://www.mql5.com/en/users/opengates2012/seller"
#property version   "1.0"
#property indicator_buffers 0
#property indicator_plots   0
#property indicator_chart_window
//+------------------------------------------------------------------+
//Global Variables  
input bool DisplaySpreadOnChart = true;//Display the pair's spread on the chart 
input double MaxAllowedSpread = 5;//Maximum approved spread for trading
input int SpreadX = 180;//Spread's left or right shift
input int SpreadY = 20;//Spread's up or down shift
input int FontSize = 15;//Spread font size
input string FontType = "Arial Bold";//Spread font type
input ENUM_BASE_CORNER SpreadPlacement = CORNER_RIGHT_UPPER;//Spread calculator placement

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {  
   CreateSpreadLabel();  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CreateSpreadLabel()
{ 
   double spreadPoints = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point*10;
   double spreadPips = spreadPoints / 10.0; // Convert to pips for 5-digit brokers
   string spread_text = "Spread: " + DoubleToString(spreadPips, 0) + " pips";
   color textColor;
   if(DisplaySpreadOnChart && spreadPips > MaxAllowedSpread) { textColor = clrRed; } else { textColor = clrLime; }
   ObjectSetInteger(0, "SpreadLabel", OBJPROP_COLOR, textColor);
   if(!ObjectCreate(0, "SpreadLabel", OBJ_LABEL, 0, 0, 0)) return;
   ObjectSetInteger(0, "SpreadLabel", OBJPROP_CORNER, SpreadPlacement);
   ObjectSetInteger(0, "SpreadLabel", OBJPROP_XDISTANCE, SpreadX);
   ObjectSetInteger(0, "SpreadLabel", OBJPROP_YDISTANCE, SpreadY);
   ObjectSetInteger(0, "SpreadLabel", OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, "SpreadLabel", OBJPROP_FONT, FontType);
   ObjectSetString(0, "SpreadLabel", OBJPROP_TEXT, spread_text);
}
//+------------------------------------------------------------------+