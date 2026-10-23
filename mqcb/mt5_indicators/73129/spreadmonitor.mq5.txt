//+------------------------------------------------------------------+
//|                                         SpreadAndSwapMonitor.mq5 |
//|                                  Copyright 2026, Volodymyr Bobal |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Volodymyr Bobal"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- Input parameters
input color             InpTextColor   = clrBlack;           // Text Color
input int               InpFontSize    = 11;                 // Font Size
input ENUM_BASE_CORNER  InpCorner      = CORNER_LEFT_UPPER;  // Chart Corner Alignment

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set timer to update data every second
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete graphical object when indicator is removed
   ObjectsDeleteAll(0, "SM_");
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
   UpdateDashboard();
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateDashboard();
}

//+------------------------------------------------------------------+
//| Data processing and drawing function                             |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   // Fetch market specifications
   int currentSpread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double swapLong   = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double swapShort  = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   
   // Format display string
   string text = StringFormat("Symbol: %s | Spread: %d | Swap Long: %.2f | Swap Short: %.2f", 
                              _Symbol, currentSpread, swapLong, swapShort);
                              
   string objName = "SM_Label";
                              
   // Create graphical object if it doesn't exist
   if(ObjectFind(0, objName) < 0)
   {
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 40);
   }
   
   // Update dynamic parameters and text
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, InpCorner);
   
   // Force chart refresh
   ChartRedraw(0);
}