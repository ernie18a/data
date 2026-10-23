//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#define  PROG_NAME "Bid and Ask Pressure"
#define OUTER_PANEL PROG_NAME + "_OuterPanel"
#define INNER_PANEL PROG_NAME + "_InnerPanel"
#define HEADER PROG_NAME + "_Header"
#define CLOSE_BTN PROG_NAME + "_CloseBtn"
#define BID_LABEL PROG_NAME + "_BidLabel"
#define ASK_LABEL PROG_NAME + "_AskLabel"
#define BID_PRICE PROG_NAME + "_BidPrice"
#define ASK_PRICE PROG_NAME + "_AskPrice"
#define ASK_HISTOGRAM PROG_NAME + "_AskHisto"
#define BID_HISTOGRAM PROG_NAME + "_BidHisto"
#define BULL_COLOR clrLimeGreen
#define BEAR_COLOR clrRed

//+------------------------------------------------------------------+
//| NOTE:
//| 1. Each histogram bar represents the number of consecutive
//|    Bid/Ask price movements (up = clrLimeGreen, down = clrRed).
//|
//| 2. Histogram direction does not flip immediately. The current
//|    dominant trend gradually decays and a reversal occurs only
//|    after its strength is reduced to one.
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>

enum ENUM_DIRECTION_TYPE {
   DIRECTION_NONE,//Trend direction NONE
   DIRECTION_UP,//Trend direction UP
   DIRECTION_DOWN//Trend direction DOWN
};
//---+
struct PriceBuffer {
//---
private:
   double prices[6];
public:
   //---+
   PriceBuffer() {
      //-Fill with Empty values at initialization
      ArrayInitialize(prices, EMPTY_VALUE);
   }
   //============================
   // Function to update structure(array) with new tick prices
   //============================
   bool update(const double price) {
      if(price == prices[0])
         return false;
      for(int w = getArraySize() - 1; w > 0; w--) {
         prices[w] = prices[w - 1];
      }
      prices[0] = price;

      return true;
   }
   //---+
   double lastPrice() {
      return NormalizeDouble(prices[0], _Digits);
   }
   //---+
   int getArraySize() {
      return ArraySize(prices);
   }
   //============================
   // Function to analyze for consecutive price up's and down's
   //============================
   int analyzeConsecutivePriceTrend(ENUM_DIRECTION_TYPE &trendDirection) {
      static ENUM_DIRECTION_TYPE lastDirection = DIRECTION_NONE;
      static int lastStrength = 0;
      trendDirection = DIRECTION_NONE;
      //--- Count valid prices
      int valid = 0;
      for(int i = 0; i < getArraySize(); i++) {
         if(prices[i] != EMPTY_VALUE)
            valid++;
         else
            break;
      }
      //-Case 1 : first run, or only 1 valid price
      if(valid < 2)
         return 0;
      //-Case 2 : second run, or exactly 2 valid prices
      if(valid == 2) {
         if(prices[0] > prices[1]) {
            trendDirection = DIRECTION_UP;
            lastDirection = trendDirection;
            lastStrength = 1;
            return lastStrength;
         } else if(prices[0] < prices[1]) {
            trendDirection = DIRECTION_DOWN;
            lastDirection = trendDirection;
            lastStrength = 1;
            return lastStrength;
         }
      }
      //--- Calculate market pressure
      int upCount = 0, downCount = 0;
      for(int w = 0; w < valid - 1; w++) {
         if(prices[w] > prices[w + 1])
            upCount++;
         else if(prices[w] < prices[w + 1])
            downCount++;
      }
      //====================================
      // Tie Case Handling (ternary logic)
      //====================================
      if(upCount == downCount && upCount > 0) {
         trendDirection = lastDirection;
         lastStrength = upCount;
         return (trendDirection == DIRECTION_UP) ? upCount :
                (trendDirection == DIRECTION_DOWN) ? downCount : 0;
      }
      //====================================
      // Determine market direction
      //====================================
      ENUM_DIRECTION_TYPE marketDir = DIRECTION_NONE;
      int marketStrength = 0;
      if(upCount > downCount) {
         marketDir = DIRECTION_UP;
         marketStrength = upCount;
      } else if(downCount > upCount) {
         marketDir = DIRECTION_DOWN;
         marketStrength = downCount;
      }
      //============================
      // Trend Control Logic
      //============================

      // Case 1 : no previous trend
      if(lastDirection == DIRECTION_NONE) {
         lastDirection = marketDir;
         lastStrength = marketStrength;
         trendDirection = lastDirection;
         return lastStrength;
      }
      // Case 2 : same direction continues
      if(marketDir == lastDirection) {
         lastStrength = marketStrength;
         trendDirection = lastDirection;
         return lastStrength;
      }
      // Case 3 : opposite direction detected
      if(marketDir != lastDirection && marketDir != DIRECTION_NONE) {
         // decay previous trend first
         if(lastStrength > 1) {
            lastStrength--;
            trendDirection = lastDirection;
            return lastStrength;
         }
         // flip allowed
         lastDirection = marketDir;
         lastStrength = 1;
         trendDirection = lastDirection;
         return lastStrength;
      }
      trendDirection = lastDirection;
      return lastStrength;
   }
//---+
   void print(string name) {
      //Print("Market Data");
      for(int w = 0; w < getArraySize(); w++)
         Print(name, "[", w, "] = ", prices[w]);
   }
} Ask, Bid;
MqlTick tick;
CChartObjectRectLabel rectLabel;
CChartObjectButton button;
CChartObjectLabel label;
//+------------------------------------------------------------------+
int OnInit() {
//---
   IndicatorSetString(INDICATOR_SHORTNAME, PROG_NAME);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
   //==============================
   // Create Dashboard
   //==============================

   //-Outer panel
   createRectLabel(OUTER_PANEL, 30, 50, 400, 270, C'30,30,30', 1, clrDarkBlue, BORDER_FLAT, STYLE_SOLID);
   //-Inner panel
   createRectLabel(INNER_PANEL, 40, 95, 380, 200, C'43,43,43', 1, C'43,43,43', BORDER_FLAT, STYLE_SOLID);
   //-Cancel / removal button
   createButton(CLOSE_BTN, 380, 62, 20, 20);
   //-Header
   createLabel(HEADER, 55, 63, C'244,208,63', PROG_NAME);
   //-Ask label
   createLabel(ASK_LABEL, 55, 135, clrCornsilk, "ASK  :");
   //-Bid label
   createLabel(BID_LABEL, 55, 210, clrCornsilk, "BID   :");
   //-Ask price
   createLabel(ASK_PRICE, 140, 135, clrBlue, "", 17);
   //-Bid price
   createLabel(BID_PRICE, 140, 210, clrRed, "", 17);
   //-Create 5 histograms for ask
   createRectLabel(ASK_HISTOGRAM + "1", 260, 143, 10, 15, clrNONE, 1,  clrNONE, BORDER_FLAT);
   createRectLabel(ASK_HISTOGRAM + "2", 275, 133, 10, 25, clrNONE, 1,  clrNONE, BORDER_FLAT);
   createRectLabel(ASK_HISTOGRAM + "3", 290, 123, 10, 35, clrNONE, 1, clrNONE, BORDER_FLAT);
   createRectLabel(ASK_HISTOGRAM + "4", 305, 113, 10, 45, clrNONE, 1,  clrNONE, BORDER_FLAT);
   createRectLabel(ASK_HISTOGRAM + "5", 320, 103, 10, 55, clrNONE, 1,  clrNONE, BORDER_FLAT);
   //-Create 5 histograms for bid
   createRectLabel(BID_HISTOGRAM + "1", 260, 218, 10, 15, clrNONE, 1, clrNONE, BORDER_FLAT);
   createRectLabel(BID_HISTOGRAM + "2", 275, 208, 10, 25, clrNONE, 1, clrNONE, BORDER_FLAT);
   createRectLabel(BID_HISTOGRAM + "3", 290, 198, 10, 35, clrNONE, 1, clrNONE, BORDER_FLAT);
   createRectLabel(BID_HISTOGRAM + "4", 305, 188, 10, 45, clrNONE, 1, clrNONE, BORDER_FLAT);
   createRectLabel(BID_HISTOGRAM + "5", 320, 178, 10, 55, clrNONE, 1, clrNONE, BORDER_FLAT);
   ChartRedraw();//-Force chart to redraw
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason) {
//---
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK, true);
   ObjectsDeleteAll(0, PROG_NAME);
   ChartRedraw();
}
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
                const int32_t &spread[]) {
//--
   if(!SymbolInfoTick(_Symbol, tick))
      return rates_total;
   if(Ask.update(NormalizeDouble(tick.ask, _Digits))) {
      UpdateDashboard(ASK_HISTOGRAM, Ask);
   }
   if(Bid.update(NormalizeDouble(tick.bid, _Digits))) {
      UpdateDashboard(BID_HISTOGRAM, Bid);
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int32_t id, const long& lparam, const double& dparam, const string& sparam) {
//-Close button clicked → remove this indicator from the chart
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == CLOSE_BTN) {
      Print("Cancel button clicked.Program deinitializing");
      ChartIndicatorDelete(0, 0, PROG_NAME);
   }
}
//==============================
// Function to create OBJ_RECTANGLE_LABEL
//==============================
void createRectLabel(const string objName, const int xDistance, const int yDistance,
                     const int xSize, const int ySize, const color clr, int borderWidth,
                     const color borderColor  = clrNONE, const ENUM_BORDER_TYPE borderType  = BORDER_FLAT,
                     const ENUM_LINE_STYLE  borderStyle = STYLE_SOLID) {
//---
   if(rectLabel.Create(0, objName, 0, 0, 0, 0, 0)) {
      rectLabel.X_Distance(xDistance);
      rectLabel.Y_Distance(yDistance);
      rectLabel.X_Size(xSize);
      rectLabel.Y_Size(ySize);
      rectLabel.BackColor(clr);
      rectLabel.SetInteger(OBJPROP_BORDER_COLOR, borderColor);
      rectLabel.BorderType(borderType);
      rectLabel.Style(borderStyle);
      rectLabel.Corner(CORNER_LEFT_UPPER);
      rectLabel.Tooltip("\n");
      ChartRedraw();
   }
}
//==============================
// Function to create OBJ_BUTTON
//==============================
void createButton(const string objName, const int xDistance,
                  const int yDistance, const int xSize, const int ySize) {
//---
   if(button.Create(0, objName, 0, 0, 0, 0, 0)) {
      button.X_Distance(xDistance);
      button.Y_Distance(yDistance);
      button.X_Size(xSize);
      button.Y_Size(ySize);
      button.BackColor(C'30,30,30');
      button.SetString(OBJPROP_TEXT, "X");
      button.Color(clrWhiteSmoke);
      button.BorderColor(clrWhiteSmoke);
      button.State(false);
      button.Selectable(false);
      button.FontSize(9);
      button.Tooltip("Cancel Button");
      ChartRedraw();
   }
}
//==============================
// Function to create OBJ_LABEL
//==============================
void createLabel(const string objName, const int xDistance, const int yDistance,
                 const color clr, const string display, const int fontSize = 15,
                 const string font = "Arial Bold") {
//---
   if(label.Create(0, objName, 0, 0, 0)) {
      label.X_Distance(xDistance);
      label.Y_Distance(yDistance);
      label.Color(clr);
      label.Tooltip("\n");
      label.SetString(OBJPROP_TEXT, display);
      label.FontSize(fontSize);
      label.Font(font);
      ChartRedraw();
   }
}
//==============================
// Function to update histogram
//==============================
void UpdateDashboard(const string prefix, PriceBuffer &structure) {
//---
   ENUM_DIRECTION_TYPE directionType = DIRECTION_NONE;
   int strength = structure.analyzeConsecutivePriceTrend(directionType);
   color histoColor = (directionType == DIRECTION_DOWN) ? BEAR_COLOR : BULL_COLOR;

   for(int w = 1; w < structure.getArraySize(); w++) {
      string obj = prefix + IntegerToString(w);
      if(w < strength) {
         // Fill histogram bar according to current market pressure
         ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, histoColor);
      } else {
         // Clear/hide bars beyond current trend strength
         ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, clrNONE);
      }
   }
   string priceDisplay = (prefix == ASK_HISTOGRAM) ? ASK_PRICE : BID_PRICE;
   ObjectSetString(0, priceDisplay, OBJPROP_TEXT, DoubleToString(structure.lastPrice(), _Digits));
   ObjectSetInteger(0, priceDisplay, OBJPROP_COLOR, histoColor);
   ChartRedraw();
}
//+------------------------------------------------------------------+
