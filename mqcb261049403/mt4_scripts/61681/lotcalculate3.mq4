//+------------------------------------------------------------------+
//|                                      LotCalculate_Updated.mq4    |
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

extern string   InpNote         = "Only selected input is used.";
extern RiskMode InpRiskMode     = RiskByPercent;   // Select risk mode
extern double   InpRiskPercent  = 1.0;            // Risk % of account balance
extern double   InpRiskAmount   = 100.0;         // Risk amount in account currency
extern double   InpStopLossPips = 50.0;         // Stoploss in pips

//+------------------------------------------------------------------+
//| Calculate the money allowed to be risked                         |
//+------------------------------------------------------------------+
double RiskMoney()
  {
   const double balance = AccountBalance();  
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
   double min_lot  = MarketInfo(Symbol(), MODE_MINLOT);   
   double max_lot  = MarketInfo(Symbol(), MODE_MAXLOT);   
   double lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);  

   if(volume <= 0.0 || min_lot <= 0.0 || max_lot <= 0.0 || lot_step <= 0.0)
     {
      Print("Error: Invalid market data — volume: ", DoubleToStr(volume, 2),
            " minLot: ", DoubleToStr(min_lot, 2),
            " maxLot: ", DoubleToStr(max_lot, 2),
            " lotStep: ", DoubleToStr(lot_step, 2));
      return 0.0;
     }

   volume = MathFloor(volume / lot_step) * lot_step;
   return MathMax(min_lot, MathMin(max_lot, volume)); 
  }

//+------------------------------------------------------------------+
//| Calculate volume from a stop distance expressed in price units   |
//+------------------------------------------------------------------+
double DynamicLotSize(const double stop_distance)
  {
   const double tick_size  = MarketInfo(Symbol(), MODE_TICKSIZE);   
   const double tick_value = MarketInfo(Symbol(), MODE_TICKVALUE);  

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
   const int    digits    = Digits;                                  
   const double point     = Point;                                  
   const int    calc_mode = (int)MarketInfo(Symbol(), MODE_PROFITCALCMODE); 
   const bool   is_forex  = (calc_mode == 0);                          
   return (is_forex && (digits % 2 == 1)) ? point * 10.0 : point;
  }

//+------------------------------------------------------------------+
//| Script entry point (MQL4: 'start', not 'OnStart')                |
//+------------------------------------------------------------------+
int start()
  {
   double pip_size    = PipSize();
   double tick_size   = MarketInfo(Symbol(), MODE_TICKSIZE);
   double tick_value  = MarketInfo(Symbol(), MODE_TICKVALUE); 
   double min_lot  = MarketInfo(Symbol(), MODE_MINLOT);
   double max_lot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);

   if(InpStopLossPips <= 0.0 || pip_size <= 0.0)
     {
      Print("Error: stop loss and symbol point data must be valid.");
      return 0;
     }

   if(tick_size <= 0.0 || tick_value <= 0.0 || min_lot <= 0.0 ||
      max_lot < min_lot || lot_step <= 0.0)
     {
      Print("Error: invalid symbol trading properties.");
      return 0;
     }

   const double stop_distance = InpStopLossPips * pip_size;
   const double risk_money    = RiskMoney();
   const double lot_size      = DynamicLotSize(stop_distance);

   if(risk_money <= 0.0)
     {
      Print("Error: selected risk input must be greater than zero.");
      return 0;
     }

   if(lot_size <= 0.0)
     {
      Print("Warning: calculated volume is below the broker minimum; no tradable lot size returned.");
      return 0;
     }

   const double loss_per_lot   = (stop_distance / tick_size) * tick_value;
   const double estimated_loss = lot_size * loss_per_lot;
   const int    digits         = Digits;

   Alert(Symbol(),
         "\nCalculated Lot Size: ", DoubleToStr(lot_size, 2),
         "\nRisk Method: ", EnumToStringCustom(InpRiskMode),
         "\nRisk Value: ", DoubleToStr(risk_money, 2),
         "\nEstimated Loss: ", DoubleToStr(estimated_loss, 2),
         "\nStop Loss: ", DoubleToStr(InpStopLossPips, 1), " pips",
         "\nStop Distance: ", DoubleToStr(stop_distance, digits),
         "\nTick Size: ", DoubleToStr(tick_size, digits),
         "\nTick Value: ", DoubleToStr(tick_value, 4)
         );

   return 0;
  }
//+------------------------------------------------------------------+
//| Custom EnumToString for MQL4 (MQL5 has built-in EnumToString)   |
//+------------------------------------------------------------------+
string EnumToStringCustom(RiskMode mode)
  {
   if(mode == RiskByPercent) return("RiskByPercent");
   if(mode == RiskByAmount)  return("RiskByAmount");
   return("Unknown");
  }
//+------------------------------------------------------------------+