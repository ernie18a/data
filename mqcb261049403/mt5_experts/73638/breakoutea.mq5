//+------------------------------------------------------------------+
//|                                                 Breakout_EA.mq5  |
//|                                  Copyright 2026, Yashar Seyyedin |
//|                    https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com/en/users/yashar.seyyedin"
#property version   "1.30"

// Include trade library
#include <Trade\Trade.mqh>
CTrade trade;

//--- Input Parameters
input double   InpRiskAmount         = 20.0;   // Fixed Currency Amount to Risk (e.g. $50)
input int      InpMinSLPoints        = 5000;    // Min SL distance allowed (in Points) -> Optimize
input double   InpRewardToRiskRatio  = 1.0;    // Reward-to-Risk Ratio (e.g. 1.5 means TP = 1.5 * SL) -> Optimize
input ulong    InpMagicNumber        = 654321; // EA Magic Number

//--- Global Variables
datetime lastBarTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);

   if(InpRewardToRiskRatio <= 0)
     {
      Print("Error: Reward-to-Risk Ratio must be greater than 0.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   lastBarTime = iTime(_Symbol, _Period, 0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime = iTime(_Symbol, _Period, 0);

// Execute only at the open of a new bar
   if(currentBarTime != lastBarTime)
     {
      // Check if we already have an open position from this EA
      if(!HasOpenPosition())
        {
         // Gather prices for the last two closed bars
         double closeBar1  = iClose(_Symbol, _Period, 1);   // Last completed close
         double lowBar1   = iLow(_Symbol, _Period, 1);    // Low of the last completed bar
         double highBar2  = iHigh(_Symbol, _Period, 2);   // Bar before last

         // Check if Bar 1 broke above the High of Bar 2
         if(closeBar1 > highBar2)
           {
            double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double stopLoss = lowBar1;

            // Calculate raw risk distance in price
            double riskDistancePrice = askPrice - stopLoss;

            if(riskDistancePrice > 0)
              {
               // Convert raw price distance to points
               double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
               if(pointSize > 0)
                 {
                  int riskDistancePoints = (int)MathRound(riskDistancePrice / pointSize);

                  // OPTIMIZATION FILTER: Check if the setup fits your point size range
                  if(riskDistancePoints >= InpMinSLPoints)
                    {
                     // Calculate TP using the dynamic Reward-to-Risk input
                     double takeProfit = askPrice + (riskDistancePrice * InpRewardToRiskRatio);

                     // Calculate automated lot sizing based on your fixed risk amount
                     double lotSize = CalculateLotSize(riskDistancePrice);

                     if(lotSize > 0)
                       {
                        trade.Buy(lotSize, _Symbol, askPrice, stopLoss, takeProfit, "Optimized Breakout Entry");
                       }
                    }
                 }
              }
           }
        }

      lastBarTime = currentBarTime;
     }
  }

//+------------------------------------------------------------------+
//| Check if this EA already has an open trade on this symbol       |
//+------------------------------------------------------------------+
bool HasOpenPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            return true;
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Dynamic Lot Size Calculation based on Currency Risk              |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskInPrice)
  {
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickSize == 0 || tickValue == 0)
      return(0.0);

   double riskInTicks = riskInPrice / tickSize;
   double calculatedLots = InpRiskAmount / (riskInTicks * tickValue);

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   calculatedLots = MathFloor(calculatedLots / lotStep) * lotStep;

   if(calculatedLots < minLot)
      calculatedLots = 0.0;
   else
      if(calculatedLots > maxLot)
         calculatedLots = maxLot;

   return(calculatedLots);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
