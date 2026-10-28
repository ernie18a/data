//+--------------------------------------------------------------------------------------------------------------------+
//|                                                                                                     V1N1 New Order |
//|                                                                                       Vinicius Pereira De Oliveira |
//+--------------------------------------------------------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------+
//| Program properties
//+--------------------------------------------------------------------------------------------------------------------+
#property copyright   "Copyright (c) 2015-2026, Vinicius Pereira De Oliveira"
#property description "Manual order-sending tool with automatic lot calculation based on risk, flexible SL/TP modes"
#property description "(price, points, amount, percentage), full validation, margin and stops-level checks. Designed"
#property description "for discretionary traders who value precision and risk control."
#property link        "https://www.mql5.com/en/users/vinicius-fx"
#property version     "3.000"
#property strict
#property script_show_inputs
//+--------------------------------------------------------------------------------------------------------------------+
//| Define constants
//+--------------------------------------------------------------------------------------------------------------------+
#define MAX_RISK_LIMIT  100.0   // Absolute risk limit per trade (% balance)
//+--------------------------------------------------------------------------------------------------------------------+
//| Enumerations
//+--------------------------------------------------------------------------------------------------------------------+
enum ENUM_OP_TYPE
  {
   OpNo        = -1,             // Select...
   OpBuy       = OP_BUY,         // Buy (Market)
   OpSell      = OP_SELL,        // Sell (Market)
   OpBuyLimit  = OP_BUYLIMIT,    // Buy Limit
   OpSellLimit = OP_SELLLIMIT,   // Sell Limit
   OpBuyStop   = OP_BUYSTOP,     // Buy Stop
   OpSellStop  = OP_SELLSTOP     // Sell Stop
  };
enum ENUM_ENTRY_LEVEL_BY
  {
   EntryLevelNo,                 // None (for market orders)
   EntryLevelPrice,              // Price
   EntryLevelPoints              // Points (from current price)
  };
enum ENUM_RISK_BY
  {
   RiskPercentage,               // Percentage of balance
   RiskAmount                    // Fixed amount
  };
enum ENUM_SL_BY
  {
   SL_Price,                     // Price
   SL_Points                     // Points (from entry)
  };
enum ENUM_TP_BY
  {
   TP_None,                      // None
   TP_Price,                     // Price
   TP_Points,                    // Points (from entry)
   TP_Amount,                    // Amount (profit target)
   TP_Percentage                 // Percentage of balance
  };
//+--------------------------------------------------------------------------------------------------------------------+
//| Input parameters
//+--------------------------------------------------------------------------------------------------------------------+
//
//=== Order Settings ===================================================================================================
input string              GroupOrder        = "===== ORDER SETTINGS =====";   // Order Settings
input ENUM_OP_TYPE        InpOrderType      = OpNo;                           // Order Type
input ENUM_ENTRY_LEVEL_BY InpEntryMode      = EntryLevelNo;                   // Entry Level Mode (for pending)
input double              InpEntryValue     = 0.0;                            // Entry Level Value
input int                 InpExpHours       = 0;                              // Expiration Hours (0 = no expiration)
//
//=== Risk Settings ====================================================================================================
input string              GroupRisk         = "===== RISK SETTINGS =====";    // Risk Settings
input ENUM_RISK_BY        InpRiskMode       = RiskPercentage;                 // Risk Mode
input double              InpRiskValue      = 0.5;                            // Risk Value
input double              InpMaxRiskPercent = 2.0;                            // Maximum Risk Limit (% of balance)
//
//=== Stop Loss and Take Profit ========================================================================================
input string              GroupSLTP         = "===== STOP LOSS / TAKE PROFIT =====";   // SL / TP Settings
input ENUM_SL_BY          InpSLMode         = SL_Points;                      // SL Mode
input double              InpSLValue        = 0.0;                            // SL Value
input ENUM_TP_BY          InpTPMode         = TP_None;                        // TP Mode
input double              InpTPValue        = 0.0;                            // TP Value
//
//=== Safety ===========================================================================================================
input string              GroupSafety       = "===== SAFETY =====";           // Safety
input int                 InpMaxSpread      = 50;                             // Maximum Spread (points)
input bool                InpRequireConfirm = true;                           // Require Confirmation Before Sending
input string              InpComment        = "";                             // Order Comment
input int                 InpMagicNumber    = 0;                              // Magic Number
input int                 InpSlippage       = 20;                             // Maximum Slippage (points)
//+--------------------------------------------------------------------------------------------------------------------+
//| Global variables
//+--------------------------------------------------------------------------------------------------------------------+
string g_errorMsg = "";
//+--------------------------------------------------------------------------------------------------------------------+
//| Script program start function
//+--------------------------------------------------------------------------------------------------------------------+
void OnStart()
  {
// Validate input parameters
   if(!ValidateInputs())
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Validation failed: ", g_errorMsg);
      return;
     }

// Check whether trading is allowed (terminal, program and account)
   if(!IsTradingAllowed())
     {
      g_errorMsg = "Trading is not allowed. Check terminal, program and account permissions.";
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> ", g_errorMsg);
      return;
     }

// Validate current spread
   if(!ValidateSpread())
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Spread validation failed: ", g_errorMsg);
      return;
     }

// Calculate entry price, SL and TP
   double entryPrice, stopLoss, takeProfit;
   if(!CalculatePrices(entryPrice, stopLoss, takeProfit))
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Price calculation failed: ", g_errorMsg);
      return;
     }

// Calculate lot size based on risk
   double lotSize;
   if(!CalculateLotSize(entryPrice, stopLoss, lotSize))
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Lot calculation failed: ", g_errorMsg);
      return;
     }

// Recalculate TP for amount/percentage modes (depends on lot size)
   if(InpTPMode == TP_Amount || InpTPMode == TP_Percentage)
     {
      if(!CalculateTPFromAmount(entryPrice, lotSize, takeProfit))
        {
         Alert(g_errorMsg);
         Print("<", __FUNCTION__, "> TP recalculation failed: ", g_errorMsg);
         return;
        }
     }

// Validate the broker stops level
   if(!ValidateStopsLevel(entryPrice, stopLoss, takeProfit))
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Stops level validation failed: ", g_errorMsg);
      return;
     }

// Validate available margin
   if(!ValidateMargin(lotSize, entryPrice))
     {
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> Margin validation failed: ", g_errorMsg);
      return;
     }

// Show preview and request confirmation
   if(InpRequireConfirm)
     {
      if(!ShowConfirmation(entryPrice, stopLoss, takeProfit, lotSize))
        {
         Print("<", __FUNCTION__, "> Order cancelled by user");
         return;
        }
     }

// Send the order
   int ticket = SendOrder(entryPrice, stopLoss, takeProfit, lotSize);
   if(ticket < 0)
      return;

   Print("<", __FUNCTION__, "> Order #", ticket, " sent successfully");
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Checks trading permissions
//+--------------------------------------------------------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
          MQLInfoInteger(MQL_TRADE_ALLOWED) &&
          AccountInfoInteger(ACCOUNT_TRADE_EXPERT) &&
          AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validates the input parameters
//+--------------------------------------------------------------------------------------------------------------------+
bool ValidateInputs()
  {
// Check whether an order type was selected
   if(InpOrderType == OpNo)
     {
      g_errorMsg = "Please select Order Type.";
      return false;
     }

// Check order type vs entry mode
   bool isMarket = (InpOrderType == OpBuy || InpOrderType == OpSell);

   if(isMarket && InpEntryMode != EntryLevelNo)
     {
      g_errorMsg = "Market orders do not require Entry Level. Set Entry Mode to 'None'.";
      return false;
     }
   if(!isMarket && (InpEntryMode == EntryLevelNo || InpEntryValue <= 0.0))
     {
      g_errorMsg = "Pending orders require Entry Mode and Entry Value greater than zero.";
      return false;
     }

// Risk
   if(InpRiskValue <= 0.0)
     {
      g_errorMsg = "Risk Value must be greater than zero.";
      return false;
     }
   if(InpMaxRiskPercent <= 0.0 || InpMaxRiskPercent > MAX_RISK_LIMIT)
     {
      g_errorMsg = StringConcatenate("Maximum Risk Limit must be between 0 and ", MAX_RISK_LIMIT, "%.");
      return false;
     }

// Stop Loss
   if(InpSLValue <= 0.0)
     {
      g_errorMsg = "Stop Loss is required and must be greater than zero.";
      return false;
     }

// Take Profit
   if(InpTPMode != TP_None && InpTPValue <= 0.0)
     {
      g_errorMsg = "Take Profit Value must be greater than zero when TP Mode is enabled.";
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validates current spread against the allowed maximum
//+--------------------------------------------------------------------------------------------------------------------+
bool ValidateSpread()
  {
   if(InpMaxSpread <= 0)
      return true;  // Validation disabled

   long currentSpread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   if(currentSpread > InpMaxSpread)
     {
      g_errorMsg = StringConcatenate("Current spread (", currentSpread,
                                     ") exceeds maximum allowed (", InpMaxSpread, ").");
      return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Calculates entry price, SL and TP
//+--------------------------------------------------------------------------------------------------------------------+
bool CalculatePrices(double &entryPrice, double &stopLoss, double &takeProfit)
  {
   bool isBuy = (InpOrderType == OpBuy || InpOrderType == OpBuyLimit || InpOrderType == OpBuyStop);

// Calculate entry price
   if(InpOrderType == OpBuy)
      entryPrice = Ask;
   else
      if(InpOrderType == OpSell)
         entryPrice = Bid;
      else
        {
         // Pending orders
         double refPrice = isBuy ? Ask : Bid;
         if(InpEntryMode == EntryLevelPrice)
            entryPrice = InpEntryValue;
         else // EntryLevelPoints
           {
            if(InpOrderType == OpBuyLimit)
               entryPrice = refPrice - InpEntryValue * Point;
            else
               if(InpOrderType == OpBuyStop)
                  entryPrice = refPrice + InpEntryValue * Point;
               else
                  if(InpOrderType == OpSellLimit)
                     entryPrice = refPrice + InpEntryValue * Point;
                  else
                     if(InpOrderType == OpSellStop)
                        entryPrice = refPrice - InpEntryValue * Point;
           }

         // Validate pending-order logic
         if(InpOrderType == OpBuyLimit && entryPrice >= Ask)
           {
            g_errorMsg = "Buy Limit price must be below current Ask.";
            return false;
           }
         if(InpOrderType == OpBuyStop && entryPrice <= Ask)
           {
            g_errorMsg = "Buy Stop price must be above current Ask.";
            return false;
           }
         if(InpOrderType == OpSellLimit && entryPrice <= Bid)
           {
            g_errorMsg = "Sell Limit price must be above current Bid.";
            return false;
           }
         if(InpOrderType == OpSellStop && entryPrice >= Bid)
           {
            g_errorMsg = "Sell Stop price must be below current Bid.";
            return false;
           }
        }

   if(!NormalizePrice(entryPrice))
     {
      g_errorMsg = "Failed to normalize entry price.";
      return false;
     }

// Calculate Stop Loss
   if(InpSLMode == SL_Price)
      stopLoss = InpSLValue;
   else // SL_Points
     {
      if(isBuy)
         stopLoss = entryPrice - InpSLValue * Point;
      else
         stopLoss = entryPrice + InpSLValue * Point;
     }

   if(!NormalizePrice(stopLoss))
     {
      g_errorMsg = "Failed to normalize stop loss price.";
      return false;
     }

// Validate that SL is on the correct side
   if(isBuy && stopLoss >= entryPrice)
     {
      g_errorMsg = "Stop Loss must be below entry price for buy orders.";
      return false;
     }
   if(!isBuy && stopLoss <= entryPrice)
     {
      g_errorMsg = "Stop Loss must be above entry price for sell orders.";
      return false;
     }

// Calculate Take Profit (only for price/points-based modes)
   takeProfit = 0.0;
   if(InpTPMode == TP_Price)
      takeProfit = InpTPValue;
   else
      if(InpTPMode == TP_Points)
        {
         if(isBuy)
            takeProfit = entryPrice + InpTPValue * Point;
         else
            takeProfit = entryPrice - InpTPValue * Point;
        }
// TP_Amount and TP_Percentage are calculated later (they need the lot size)

   if(takeProfit > 0.0)
     {
      if(!NormalizePrice(takeProfit))
        {
         g_errorMsg = "Failed to normalize take profit price.";
         return false;
        }

      // Validate that TP is on the correct side
      if(isBuy && takeProfit <= entryPrice)
        {
         g_errorMsg = "Take Profit must be above entry price for buy orders.";
         return false;
        }
      if(!isBuy && takeProfit >= entryPrice)
        {
         g_errorMsg = "Take Profit must be below entry price for sell orders.";
         return false;
        }
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Calculates lot size based on risk
//+--------------------------------------------------------------------------------------------------------------------+
bool CalculateLotSize(double entryPrice, double stopLoss, double &lotSize)
  {
   double balance = AccountBalance() + AccountCredit();
   if(balance <= 0.0)
     {
      g_errorMsg = "Invalid account balance.";
      return false;
     }

// Calculate risk amount in account currency
   double riskAmount = 0.0;
   if(InpRiskMode == RiskPercentage)
     {
      riskAmount = balance * (InpRiskValue / 100.0);
     }
   else // RiskAmount
     {
      riskAmount = InpRiskValue;
     }

// Check the maximum risk limit
   double maxRiskAmount = balance * (InpMaxRiskPercent / 100.0);
   if(riskAmount > maxRiskAmount)
     {
      g_errorMsg = StringConcatenate("Risk amount (", DoubleToStr(riskAmount, 2),
                                     ") exceeds maximum allowed (", DoubleToStr(maxRiskAmount, 2), ").");
      return false;
     }

// Calculate potential loss for 1 lot
   double slDistance = MathAbs(entryPrice - stopLoss);
   if(slDistance <= 0.0)
     {
      g_errorMsg = "Invalid stop loss distance.";
      return false;
     }

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if(tickValue <= 0.0 || tickSize <= 0.0)
     {
      g_errorMsg = "Invalid tick value or tick size.";
      return false;
     }

   double lossPerLot = (slDistance / tickSize) * tickValue;
   if(lossPerLot <= 0.0)
     {
      g_errorMsg = "Invalid loss per lot calculation.";
      return false;
     }

// Calculate lot size
   lotSize = riskAmount / lossPerLot;

// Normalize to the volume step
   if(!NormalizeLotSize(lotSize))
     {
      g_errorMsg = "Failed to normalize lot size.";
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Recalcula TP baseado em montante (amount) ou porcentagem
//+--------------------------------------------------------------------------------------------------------------------+
bool CalculateTPFromAmount(double entryPrice, double lotSize, double &takeProfit)
  {
   bool isBuy = (InpOrderType == OpBuy || InpOrderType == OpBuyLimit || InpOrderType == OpBuyStop);

   double balance = AccountBalance() + AccountCredit();
   double targetProfit = 0.0;

   if(InpTPMode == TP_Amount)
      targetProfit = InpTPValue;
   else // TP_Percentage
      targetProfit = balance * (InpTPValue / 100.0);

   if(targetProfit <= 0.0)
     {
      g_errorMsg = "Invalid target profit.";
      return false;
     }

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double profitPerLot = targetProfit / lotSize;
   double pointsDistance = (profitPerLot / tickValue) * tickSize;

   if(isBuy)
      takeProfit = entryPrice + pointsDistance;
   else
      takeProfit = entryPrice - pointsDistance;

   if(!NormalizePrice(takeProfit))
     {
      g_errorMsg = "Failed to normalize take profit.";
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validates the broker stops level
//+--------------------------------------------------------------------------------------------------------------------+
bool ValidateStopsLevel(double entryPrice, double stopLoss, double takeProfit)
  {
   long stopsLevel = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
   if(stopsLevel == 0)
      return true;

   double minDistance = stopsLevel * Point;
   bool isBuy = (InpOrderType == OpBuy || InpOrderType == OpBuyLimit || InpOrderType == OpBuyStop);
   bool isMarket = (InpOrderType == OpBuy || InpOrderType == OpSell);

   if(isMarket)
     {
      double currentPrice = isBuy ? Bid : Ask;

      if(MathAbs(currentPrice - stopLoss) < minDistance)
        {
         g_errorMsg = StringConcatenate("Stop Loss too close. Minimum distance: ", stopsLevel, " points.");
         return false;
        }
      if(takeProfit > 0.0 && MathAbs(currentPrice - takeProfit) < minDistance)
        {
         g_errorMsg = StringConcatenate("Take Profit too close. Minimum distance: ", stopsLevel, " points.");
         return false;
        }
     }
   else
     {
      // Pending: validate distance from current price to entry price
      double currentPrice = isBuy ? Ask : Bid;
      if(MathAbs(currentPrice - entryPrice) < minDistance)
        {
         g_errorMsg = StringConcatenate("Entry price too close to current price. Minimum: ", stopsLevel, " points.");
         return false;
        }
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validates available margin
//+--------------------------------------------------------------------------------------------------------------------+
bool ValidateMargin(double lotSize, double entryPrice)
  {
   double freeMargin = AccountFreeMargin();
   double marginRequired = AccountFreeMarginCheck(Symbol(),
                           (InpOrderType == OpBuy || InpOrderType == OpBuyLimit || InpOrderType == OpBuyStop) ? OP_BUY : OP_SELL,
                           lotSize);

   if(marginRequired < 0.0)
     {
      g_errorMsg = StringConcatenate("Insufficient margin. Free margin: ", DoubleToStr(freeMargin, 2));
      return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Shows a confirmation dialog with a trade preview
//+--------------------------------------------------------------------------------------------------------------------+
bool ShowConfirmation(double entryPrice, double stopLoss, double takeProfit, double lotSize)
  {
   string orderTypeName = "";
   switch(InpOrderType)
     {
      case OpBuy:
         orderTypeName = "BUY (Market)";
         break;
      case OpSell:
         orderTypeName = "SELL (Market)";
         break;
      case OpBuyLimit:
         orderTypeName = "BUY LIMIT";
         break;
      case OpSellLimit:
         orderTypeName = "SELL LIMIT";
         break;
      case OpBuyStop:
         orderTypeName = "BUY STOP";
         break;
      case OpSellStop:
         orderTypeName = "SELL STOP";
         break;
     }

// Calculate risk and potential profit
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double riskMoney = (MathAbs(entryPrice - stopLoss) / tickSize) * tickValue * lotSize;
   double profitMoney = 0.0;
   string rrRatio = "N/A";

   if(takeProfit > 0.0)
     {
      profitMoney = (MathAbs(entryPrice - takeProfit) / tickSize) * tickValue * lotSize;
      double ratio = profitMoney / riskMoney;
      rrRatio = StringConcatenate("1:", DoubleToStr(ratio, 2));
     }

   string msg = StringConcatenate(
                   "CONFIRM ORDER\n",
                   "================\n",
                   "Symbol:     ", Symbol(), "\n",
                   "Type:       ", orderTypeName, "\n",
                   "Lot Size:   ", DoubleToStr(lotSize, 2), "\n",
                   "Entry:      ", DoubleToStr(entryPrice, Digits), "\n",
                   "Stop Loss:  ", DoubleToStr(stopLoss, Digits), "\n",
                   "Take Profit: ", (takeProfit > 0.0 ? DoubleToStr(takeProfit, Digits) : "None"), "\n",
                   "================\n",
                   "Risk:       ", DoubleToStr(riskMoney, 2), " ", AccountCurrency(), "\n",
                   "Reward:     ", (takeProfit > 0.0 ? DoubleToStr(profitMoney, 2) + " " + AccountCurrency() : "N/A"), "\n",
                   "R:R Ratio:  ", rrRatio, "\n",
                   "================\n",
                   "Send this order?"
                );

   int result = MessageBox(msg, "V1N1 New Order", MB_YESNO | MB_ICONQUESTION);
   return (result == IDYES);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Sends the order
//+--------------------------------------------------------------------------------------------------------------------+
int SendOrder(double entryPrice, double stopLoss, double takeProfit, double lotSize)
  {
   datetime expiration = 0;
   if(InpExpHours > 0 && InpOrderType != OpBuy && InpOrderType != OpSell)
      expiration = TimeCurrent() + InpExpHours * 3600;

   int ticket = OrderSend(Symbol(), InpOrderType, lotSize, entryPrice, InpSlippage,
                          stopLoss, takeProfit, InpComment, InpMagicNumber, expiration, clrNONE);

   if(ticket < 0)
     {
      int error = GetLastError();
      g_errorMsg = StringConcatenate("OrderSend failed. Error: ", error, " - ", ErrorDescription(error));
      Alert(g_errorMsg);
      Print("<", __FUNCTION__, "> ", g_errorMsg);
     }

   return ticket;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Normalizes price aligned to the tick size
//+--------------------------------------------------------------------------------------------------------------------+
bool NormalizePrice(double &price)
  {
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if(tickSize <= 0.0)
     {
      price = NormalizeDouble(price, Digits);
      return true;
     }
   price = NormalizeDouble(MathRound(price / tickSize) * tickSize, Digits);
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Normalizes the lot size
//+--------------------------------------------------------------------------------------------------------------------+
bool NormalizeLotSize(double &lots)
  {
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

   if(lotStep <= 0.0)
      return false;

// Determine decimal places
   int digits = 0;
   if(lotStep < 1.0)
     {
      double temp = lotStep;
      while(temp < 1.0 && digits < 4)
        {
         temp *= 10.0;
         digits++;
        }
     }

   lots = NormalizeDouble(MathFloor(lots / lotStep) * lotStep, digits);

   if(lots < minLot)
      lots = minLot;
   if(lots > maxLot)
      lots = maxLot;

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Returns the error description
//+--------------------------------------------------------------------------------------------------------------------+
string ErrorDescription(int code)
  {
   switch(code)
     {
      case 0:
         return "No error";
      case 1:
         return "No error, but result unknown";
      case 2:
         return "Common error";
      case 3:
         return "Invalid trade parameters";
      case 4:
         return "Trade server is busy";
      case 5:
         return "Old version of the client terminal";
      case 6:
         return "No connection with trade server";
      case 7:
         return "Not enough rights";
      case 8:
         return "Too frequent requests";
      case 9:
         return "Malfunctional trade operation";
      case 64:
         return "Account disabled";
      case 65:
         return "Invalid account";
      case 128:
         return "Trade timeout";
      case 129:
         return "Invalid price";
      case 130:
         return "Invalid stops";
      case 131:
         return "Invalid trade volume";
      case 132:
         return "Market is closed";
      case 133:
         return "Trade is disabled";
      case 134:
         return "Not enough money";
      case 135:
         return "Price changed";
      case 136:
         return "Off quotes";
      case 137:
         return "Broker is busy";
      case 138:
         return "Requote";
      case 139:
         return "Order is locked";
      case 140:
         return "Long positions only allowed";
      case 141:
         return "Too many requests";
      case 145:
         return "Modification denied - order too close to market";
      case 146:
         return "Trade context busy";
      case 147:
         return "Expirations are denied by broker";
      case 148:
         return "Amount of open and pending orders has reached the limit";
      default:
         return "Unknown error";
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Script End
//+--------------------------------------------------------------------------------------------------------------------+
