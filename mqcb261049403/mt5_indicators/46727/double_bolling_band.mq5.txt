//+------------------------------------------------------------------+
//|                                                    BB_Signal.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "2023, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
//--- input parameters
input int      BB_KIKAN=20;  // BB period

double waitBB = 0; // Initialize waitBB
datetime prevtime;

int orderPtn=0; // 0: Do nothing, 1: Buy, 2: Sell

// Create buffers to hold the upper and lower bands
double upperBuffer[];
double lowerBuffer[];

double BB3UP, BB3LO, BB2UP, BB2LO; // Define these variables here to make them global

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---

   return(INIT_SUCCEEDED);
}

// Custom function to plot arrows
void PlotArrow(int direction, int shift, double price, color clr) {
   string arrowName = direction > 0 ? "BuyArrow" : "SellArrow";
   arrowName += "_" + IntegerToString(shift);
   if (ObjectFind(0, arrowName) != -1) {
      ObjectDelete(0, arrowName);
   }
   if (direction > 0)
      ObjectCreate(0, arrowName, OBJ_ARROW_BUY, 0, iTime(_Symbol, _Period, shift), price);
   else
      ObjectCreate(0, arrowName, OBJ_ARROW_SELL, 0, iTime(_Symbol, _Period, shift), price);
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clr);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
// Get the handle of the Bollinger Bands indicator
   int handle = iBands(_Symbol, _Period, BB_KIKAN, 3, 0, PRICE_CLOSE);

// Copy the upper band (index 0) and lower band (index 2) into the buffers
   CopyBuffer(handle, 0, 0, rates_total, upperBuffer);
   CopyBuffer(handle, 2, 0, rates_total, lowerBuffer);

// Now you can get the upper and lower bands using the buffers
   BB3UP = upperBuffer[1]; // 3σ upper
   BB3LO = lowerBuffer[1]; // 3σ lower

// Repeat the same for the 2σ Bollinger Bands
   handle = iBands(_Symbol, _Period, BB_KIKAN, 2, 0, PRICE_CLOSE);
   CopyBuffer(handle, 0, 0, rates_total, upperBuffer);
   CopyBuffer(handle, 2, 0, rates_total, lowerBuffer);

   BB2UP = upperBuffer[1]; // 2σ upper
   BB2LO = lowerBuffer[1]; // 2σ lower

//*** Buy/Sell Conditions ***//
// Rest of your code...

// If in a Buy or Buy-wait state
   if ((orderPtn == 1) || (waitBB > 0)) {
      // Buy within BB2 range
      if ((BB2UP > close[1]) && (BB2LO < close[1])) {
         orderPtn = 1;
         waitBB = 0;
         PlotArrow(1, 1, close[1], clrGreen); // Plot Green Arrow for Buy Signal
      } else {
         orderPtn = 0;
         waitBB = 1;
      }
   }

// If in a Sell or Sell-wait state
   if ((orderPtn == 2) || (waitBB < 0)) {
      // Sell within 2σ BB range
      if ((BB2LO < close[1]) && (BB2UP > close[1])) {
         orderPtn = 2;
         waitBB = 0;
         PlotArrow(-1, 1, close[1], clrRed); // Plot Red Arrow for Sell Signal
      } else {
         orderPtn = 0;
         waitBB = -1;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
