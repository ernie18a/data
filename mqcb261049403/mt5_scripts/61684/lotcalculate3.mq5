//+------------------------------------------------------------------+
//|                                      LotCalculate_Updated.mq5    |
//|              Dynamic lot sizing from stop distance and risk      |
//+------------------------------------------------------------------+
#property copyright "Wamek Script-2026"
#property link      "eawamek@gmail.com"
#property version   "3.00"
#property script_show_inputs
#property strict
#property description  "Forex stoploss in pips. Converts pips to points if needed." 
#property description  "CDF / Commodities / indicies/stocks etc, pips=points. Input stoploss as required."   

enum RiskMode
  {
   RiskByPercent,
   RiskByAmount
  };

input string   InpNote         = "Only selected input is used.";
input RiskMode InpRiskMode     = RiskByPercent;   // Select risk mode
input double   InpRiskPercent  = 1.0;            // Risk % of account balance
input double   InpRiskAmount   = 100.0;         // Risk amount in account currency
input double   InpStopLossPips = 50.0;         // Stoploss in pips

//+------------------------------------------------------------------+
//| Calculate the money allowed to be risked                         |
//+------------------------------------------------------------------+
double RiskMoney()
  {
   const double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0.0)
      return 0.0;

   if(InpRiskMode == RiskByPercent)
     {
      if(InpRiskPercent <= 0.0)
         return 0.0;
      return balance * InpRiskPercent / 100.0;
     }

   return (InpRiskAmount > 0.0) ? InpRiskAmount : 0.0;
  }

//+------------------------------------------------------------------+
//| Normalize a raw lot size to the symbol's volume constraints      |
//+------------------------------------------------------------------+
double NormalizeVolume(double volume)
  {
    double min_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(volume <= 0.0 || min_lot <= 0.0 || max_lot <= 0.0 || lot_step <= 0.0)
     {
      Print("Error: Invalid market data — volume: ",volume, " minLot: ", min_lot, " maxLot: ", max_lot, " lotStep: ", lot_step);
      return 0.0;
     }
   volume = MathFloor(volume / lot_step) * lot_step;
   return fmax(min_lot, fmin(max_lot, volume));
  }



//+------------------------------------------------------------------+
//| Calculate volume from a stop distance expressed in price units   |
//+------------------------------------------------------------------+
double DynamicLotSize(const double stop_distance)
  {
   const double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if(stop_distance <= 0.0 || tick_size <= 0.0 || tick_value <= 0.0)
      return 0.0;

   // Risk money = selected risk value; loss per lot = distance/tick_size*tick_value.
   const double risk_money   = RiskMoney();
   const double loss_per_lot = (stop_distance / tick_size) * tick_value;

   if(risk_money <= 0.0 || loss_per_lot <= 0.0)
      return 0.0;

   return NormalizeVolume(risk_money / loss_per_lot);
  }

//+------------------------------------------------------------------+
//| Price distance of one "pip" for the current symbol               |
//| 5/3-digit forex quotes: a pip = 10 points. Everything else: pip  |
//| = point (CFDs, metals, indices, stocks all use point directly).  |
//+------------------------------------------------------------------+
double PipSize()
  {
   const int    digits    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   const double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const int    calc_mode = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE);
   const bool   is_forex  = (calc_mode == SYMBOL_CALC_MODE_FOREX || calc_mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE);
   return (is_forex && (digits % 2 == 1)) ? point * 10.0 : point;
  }


//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
    double pip_size    = PipSize();
    double tick_size   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double tick_value  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
    double min_volume  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_volume  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //--- Fallback if broker does not provide LOSS tick value
   if(tick_value <= 0.0) tick_value =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if(InpStopLossPips <= 0.0 || pip_size <= 0.0)
     {
      Print("Error: stop loss and symbol point data must be valid.");
      return;
     }

   if(tick_size <= 0.0 || tick_value <= 0.0 || min_volume <= 0.0 ||
      max_volume < min_volume || volume_step <= 0.0)
     {
      Print("Error: invalid symbol trading properties.");
      return;
     }

   const double stop_distance = InpStopLossPips * pip_size;
   const double risk_money    = RiskMoney();
   const double lot_size      = DynamicLotSize(stop_distance);

   if(risk_money <= 0.0)
     {
      Print("Error: selected risk input must be greater than zero.");
      return;
     }

   if(lot_size <= 0.0)
     {
      Print("Warning: calculated volume is below the broker minimum; no tradable lot size returned.");
      return;
     }

   const double loss_per_lot  = (stop_distance / tick_size) * tick_value;
   const double estimated_loss = lot_size * loss_per_lot;
   const int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   Alert(_Symbol,
         "\nCalculated Lot Size: ", DoubleToString(lot_size, digits),
         "\nRisk Method: ", EnumToString(InpRiskMode),
         "\nRisk Value: ", DoubleToString(risk_money, digits),
         "\nEstimated Loss: ", DoubleToString(estimated_loss, digits),
         "\nStop Loss: ", DoubleToString(InpStopLossPips, digits), " pips",
         "\nStop Distance: ", DoubleToString(stop_distance, digits),
         "\nTick Size: ", DoubleToString(tick_size, digits),
         "\nTick Value: ", DoubleToString(tick_value, digits)
         );
  }
//+------------------------------------------------------------------+
