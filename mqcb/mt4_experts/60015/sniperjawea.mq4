//+------------------------------------------------------------------+
//|                                                   SniperJawEA.mq4|
//|                          EA by:                                  |
//|              https://t.me/strategynotebook                       |
//+------------------------------------------------------------------+
#property copyright "EA by: https://t.me/strategynotebook"
#property link      "https://t.me/strategynotebook"
#property version   "1.00"
#property strict
#property description "SniperJaw EA trades using the Bill Williams Alligator Indicator."
#property description "It detects precise trend alignment for sniper-style entries."
#property description "Use at your own risk. Always test on demo before going live."

extern double LotSize = 0.1;
extern bool UseEntryToExit = true;
extern double StopLoss = 20;
extern double TakeProfit = 50;
extern int Slippage = 2;
extern bool TradeEnabled = true;

string labelName = "t.me/strategynote";
string labelText = "EA by t.me/strategynote";
int labelFontSize = 18;
color labelColor = Yellow;
int spaceFromBottom = 50;



void createOrUpdateLabel()
{
    // Create the main label
    if (ObjectFind(0, labelName) == -1)
    {
        ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, spaceFromBottom);
        ObjectSetInteger(0, labelName, OBJPROP_COLOR, labelColor);
        ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, labelFontSize);
        ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
    }


}


double pipPoint;
bool isTradeAllowed;
bool canBuy;
bool canSell;

int maxOrderRetries = 10;
int retryWaitSeconds = 3;
int minBarsRequired = 60;

datetime lastOrderTime;

double stopLossPips;
double takeProfitPips;
double spreadValue;
int slippagePoints;

void InitTradeSettings() {
   RefreshRates();
   pipPoint = Point;
   slippagePoints = Slippage;
   if (MathMod(Digits, 2) == 1) {
      pipPoint *= 10;
      slippagePoints *= 10;
   }
   takeProfitPips = TakeProfit * pipPoint;
   stopLossPips = StopLoss * pipPoint;
   isTradeAllowed = TradeEnabled;
   canBuy = true;
   canSell = true;
}

void ValidateTradeConditions() {
   if (Bars < minBarsRequired) {
      Print("INFO - Not enough Bars to trade");
      isTradeAllowed = false;
   }
   CheckOpenOrders();
}

void CheckOpenOrders() {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
      }
      if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) canBuy = false;
      if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) canSell = false;
   }
}

void CloseOpenOrders(int orderType) {
   double closePrice = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
      }
      if (OrderSymbol() == Symbol() && OrderType() == orderType) {
         closePrice = (orderType == OP_BUY) ? Bid : Ask;
         double lots = OrderLots();
         int ticket = OrderTicket();
         for (int j = 1; j < maxOrderRetries; j++) {
            if (OrderClose(ticket, lots, closePrice, slippagePoints, Red)) {
               Print("TRADE - CLOSE - Order ", ticket, " closed at price ", closePrice);
               break;
            } else {
               Print("ERROR - CLOSE - error closing order ", ticket, " return error: ", GetLastError());
            }
         }
      }
   }
}

void PlaceNewOrder(int orderType) {
   RefreshRates();
   double openPrice = (orderType == OP_BUY) ? Ask : Bid;
   double sl = (orderType == OP_BUY) ? openPrice - stopLossPips : openPrice + stopLossPips;
   double tp = 0;
   if (!UseEntryToExit) {
      tp = (orderType == OP_BUY) ? openPrice + takeProfitPips : openPrice - takeProfitPips;
   }
   for (int i = 1; i < maxOrderRetries; i++) {
     string volMessage;
if (!CheckVolumeValue(LotSize, volMessage)) {
   Print("VOLUME ERROR: ", volMessage);
   return;
}

int ticket = OrderSend(Symbol(), orderType, LotSize, openPrice, slippagePoints, NormalizeDouble(sl, Digits), NormalizeDouble(tp, Digits), "", 0, 0, Green);

      if (ticket > 0) {
         Print("TRADE - NEW - Order ", ticket, " submitted: Command ", orderType, " Volume ", LotSize, " Open ", openPrice);
         break;
      } else {
         Print("ERROR - NEW - error sending order, return error: ", GetLastError());
      }
   }
}

extern int JawPeriod = 13;
extern int JawShift = 8;
extern int TeethPeriod = 8;
extern int TeethShift = 5;
extern int LipsPeriod = 5;
extern int LipsShift = 3;

double jawNow, teethNow, lipsNow;
double jawPrev, teethPrev, lipsPrev;
bool isUptrend = false;
bool isDowntrend = false;

void DetectAlligatorTrend() {
   isUptrend = false;
   isDowntrend = false;
   jawNow = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 0);
   teethNow = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 0);
   lipsNow = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 0);
   jawPrev = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 1);
   teethPrev = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 1);
   lipsPrev = iAlligator(Symbol(), 0, JawPeriod, JawShift, TeethPeriod, TeethShift, LipsPeriod, LipsShift, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
   if (jawNow < teethNow && teethNow < lipsNow && jawNow > jawPrev && teethNow > teethPrev && lipsNow > lipsPrev) isUptrend = true;
   if (jawNow > teethNow && teethNow > lipsNow && jawNow < jawPrev && teethNow < teethPrev && lipsNow < lipsPrev) isDowntrend = true;
}



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   createOrUpdateLabel();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   InitTradeSettings();
   ValidateTradeConditions();
   DetectAlligatorTrend();

   if (isUptrend) {
      if (UseEntryToExit) CloseOpenOrders(OP_SELL);
      if (canBuy && canSell && isTradeAllowed && lastOrderTime != Time[0]) {
         PlaceNewOrder(OP_BUY);
         lastOrderTime = Time[0];
      }
   }

   if (isDowntrend) {
      if (UseEntryToExit) CloseOpenOrders(OP_BUY);
      if (canSell && canBuy && isTradeAllowed && lastOrderTime != Time[0]) {
         PlaceNewOrder(OP_SELL);
         lastOrderTime = Time[0];
      }
   }
}

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume, string &description)
{
   double min_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if (volume < min_volume)
   {
      description = StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", min_volume);
      return(false);
   }

   double max_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   if (volume > max_volume)
   {
      description = StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", max_volume);
      return(false);
   }

   double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   int ratio = (int)MathRound(volume / volume_step);
   if (MathAbs(ratio * volume_step - volume) > 0.0000001)
   {
      description = StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                 volume_step, ratio * volume_step);
      return(false);
   }

   description = "Correct volume value";
   return(true);
}

