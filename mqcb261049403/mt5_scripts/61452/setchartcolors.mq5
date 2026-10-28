//+------------------------------------------------------------------+
//|                                               SetChartColors.mq5 |
//|                                                    ZenKenTrading |
//|                                        twitter.com/zenkentrading |
//+------------------------------------------------------------------+
#property copyright "ZenKenTrading"
#property link      "twitter.com/zenkentrading"
#property version   "1.00"
#property script_show_inputs

//--- Input parameters
enum ColorScheme
  {
   RED_GREEN = 0,     // Classic Red/Green
   PINK_AQUA = 1,     // Pink/Aqua
   BLACK_WHITE = 2    // Black/White
  };

input ColorScheme SelectedScheme = RED_GREEN;  // Color Scheme
input bool ShowAskBid = true;                  // Show Ask/Bid Lines
input int LineWidth = 1;                       // Ask/Bid Line Width

//--- Global variables
string askLineName = "AskLine";  //Ask Line String 
string bidLineName = "BidLine";  //Bid Line String

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
// Apply the selected color scheme
   ApplyColorScheme();

// Show ask/bid lines if enabled
   if(ShowAskBid)
     {
      CreateAskBidLines();
     }
   else
     {
      // Remove existing lines if disabled
      ObjectDelete(0, askLineName);
      ObjectDelete(0, bidLineName);
     }

// Refresh the chart
   ChartRedraw();

   Print("Chart customization applied successfully!");
  }

//+------------------------------------------------------------------+
//| Apply the selected color scheme                                   |
//+------------------------------------------------------------------+
void ApplyColorScheme()
  {
   color bullishColor, bearishColor, backgroundColor, gridColor, textColor;

//Color schemes
   switch(SelectedScheme)
     {
      case RED_GREEN:     //Classic Red and Green Design
         bullishColor = clrLimeGreen;
         bearishColor = clrRed;
         backgroundColor = clrBlack;
         gridColor = clrDimGray;
         textColor = clrWhite;
         break;

      case PINK_AQUA:    //A Personal Favorite Color Design 
         bullishColor = clrAqua;
         bearishColor = clrHotPink;
         backgroundColor = clrBlack;
         gridColor = clrSlateGray;
         textColor = clrWhite;
         break;

      case BLACK_WHITE:   //Classic Black and White Design
         bullishColor = clrWhite;
         bearishColor = clrBlack;
         backgroundColor = clrGray;
         gridColor = clrDarkGray;
         textColor = clrBlack;
         break;

      default:
         bullishColor = clrLimeGreen;
         bearishColor = clrRed;
         backgroundColor = clrBlack;
         gridColor = clrDimGray;
         textColor = clrWhite;
     }

// Apply chart colors
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, backgroundColor);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, textColor);
   ChartSetInteger(0, CHART_COLOR_GRID, gridColor);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, bullishColor);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, bearishColor);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, bullishColor);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, bearishColor);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, textColor);
   ChartSetInteger(0, CHART_COLOR_VOLUME, clrNavy);
   ChartSetInteger(0, CHART_COLOR_BID, bearishColor);
   ChartSetInteger(0, CHART_COLOR_ASK, bullishColor);

// Store colors for ask/bid lines
   GlobalVariableSet("BullishColor", bullishColor);
   GlobalVariableSet("BearishColor", bearishColor);
  }

//+------------------------------------------------------------------+
//| Create Ask and Bid lines                                         |
//+------------------------------------------------------------------+
void CreateAskBidLines()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   color bullishColor = (color)GlobalVariableGet("BullishColor");
   color bearishColor = (color)GlobalVariableGet("BearishColor");

// Create Ask line (bullish color)
   ObjectDelete(0, askLineName);
   ObjectCreate(0, askLineName, OBJ_HLINE, 0, 0, ask);
   ObjectSetInteger(0, askLineName, OBJPROP_COLOR, bullishColor);
   ObjectSetInteger(0, askLineName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, askLineName, OBJPROP_WIDTH, LineWidth);
   ObjectSetString(0, askLineName, OBJPROP_TEXT, "Ask: " + DoubleToString(ask, _Digits));
   ObjectSetInteger(0, askLineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, askLineName, OBJPROP_SELECTABLE, false);

// Create Bid line (bearish color)
   ObjectDelete(0, bidLineName);
   ObjectCreate(0, bidLineName, OBJ_HLINE, 0, 0, bid);
   ObjectSetInteger(0, bidLineName, OBJPROP_COLOR, bearishColor);
   ObjectSetInteger(0, bidLineName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, bidLineName, OBJPROP_WIDTH, LineWidth);
   ObjectSetString(0, bidLineName, OBJPROP_TEXT, "Bid: " + DoubleToString(bid, _Digits));
   ObjectSetInteger(0, bidLineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bidLineName, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Update Ask and Bid line positions                                |
//+------------------------------------------------------------------+
void UpdateAskBidLines()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

// Update Ask line
   if(ObjectFind(0, askLineName) >= 0)
     {
      ObjectSetDouble(0, askLineName, OBJPROP_PRICE, ask);
      ObjectSetString(0, askLineName, OBJPROP_TEXT, "Ask: " + DoubleToString(ask, _Digits));
     }

// Update Bid line
   if(ObjectFind(0, bidLineName) >= 0)
     {
      ObjectSetDouble(0, bidLineName, OBJPROP_PRICE, bid);
      ObjectSetString(0, bidLineName, OBJPROP_TEXT, "Bid: " + DoubleToString(bid, _Digits));
     }
  }
//+------------------------------------------------------------------+
