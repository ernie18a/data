//+------------------------------------------------------------------+
//|                                         PlannedPendingOrders.mq4 |
//|                                                     Dirk Assmann |
//|                https://github.com/dirkmql/planned-pending-orders |
//+------------------------------------------------------------------+
//  Create orders regarding to horizontal lines you have created
//  Copyright (C) 2018  Dirk Assmann
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#property copyright "Dirk Assmann"
#property version   "1.00"
#property strict
#property show_inputs

//--- defines
#define NUM_POSITIONS 4  // Max number of orders
#define SLIPPAGE 10      // Slippage

//+------------------------------------------------------------------+
//| Short description how to use                                     |
//+------------------------------------------------------------------+
// This script is for entering a trade with several positions which
// can have different stoploss and takeprofit levels.
// Before calling the script at least the following levels need to
// be set with named horizontal lines:
// "entry_1" - entry of the first order
// "sl_1" - stoploss of the first order
// "tp_1" - takeprofit of the first order (optional)
// If a following definition has for example TP set only, the other
// attributes are taken from the first order.
// When script is running you are been asked about how much you want
// to risk. This risk is taken as the sum of all trades stoplosses.
// Maximum of 4 positions in one trade processable.
// Execute the script through dragging-and-dropping it on the chart.

//--- input parameters
input double risk = 0.005;  // Aspired risk
// If the aspired risk is below 0.1 the value is taken as a factor
// from the current account size. If the aspired risk is 0.1 or
// higher the value is taken as money amount in account currency.

//+------------------------------------------------------------------+
//| Struct for a position                                            |
//+------------------------------------------------------------------+
struct position_s {
   double entry;       // Entry price
   double stoploss;    // Stoploss
   double takeprofit;  // Takeprofit
   double lots;        // Lotsize
   //+---------------------------------------------------------------+
   //| position_s constructor                                        |
   //+---------------------------------------------------------------+
   position_s() : entry(0), stoploss(0), takeprofit(0), lots(0) { }
};

//+------------------------------------------------------------------+
//| PlannedPendingOrders execute function                            |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   // Show label for the time script is running
   showTitle();
   
   position_s pos[NUM_POSITIONS];
   
   collectPlannedPositions(pos);
       
   if (pos[0].entry == 0 || pos[0].stoploss == 0)
     {
      MessageBox("At least two horizontal lines with the names \"entry_1\" and \"sl_1\" need to be set!",
         "Error", MB_ICONERROR);
      removeTitle();
      return;
     }
   
   int activePositions = checkPlannedPositions(pos);
   
   string message = generateDialogMessage(pos, activePositions);
   int ret = MessageBox(message, "Trade", MB_OKCANCEL | MB_ICONWARNING);

   if (ret == IDOK) 
     {
      for (int i = 0; i < NUM_POSITIONS; ++i) 
        {
         if (pos[i].entry == 0) continue;

         int cmd = OP_BUYLIMIT;
         if (pos[i].entry < pos[i].stoploss)
            cmd = OP_SELLLIMIT;

         int ticket = OrderSend(Symbol(), cmd, pos[i].lots, pos[i].entry, SLIPPAGE, pos[i].stoploss, pos[i].takeprofit);
         if (ticket == -1)
            Print("ERROR Sending order " + IntegerToString(GetLastError()));
        }
     }
   
   removeTitle();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Show script name on chart                                        |
//+------------------------------------------------------------------+
void showTitle()
  {
   const string strTitle = "label_PlannedPendingOrders";
   ObjectDelete(strTitle);
   ObjectCreate(strTitle, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(strTitle, "PlannedPendingOrders", 8, "Verdana", clrBlack);
   ObjectSet(strTitle, OBJPROP_CORNER, 0);
   ObjectSet(strTitle, OBJPROP_XDISTANCE, 14);
   ObjectSet(strTitle, OBJPROP_YDISTANCE, 20);
   ObjectSet(strTitle, OBJPROP_BACK, false);
   WindowRedraw();  // Redraw to show label
  }
//+------------------------------------------------------------------+
//| Remove script name from chart                                    |
//+------------------------------------------------------------------+
void removeTitle()
  {
   const string strTitle = "label_PlannedPendingOrders";
   if (ObjectFind(ChartID(), strTitle) != -1)
      ObjectDelete(ChartID(), strTitle);
  }
//+------------------------------------------------------------------+
//| Collect planned positions from drawn hlines in chart             |
//+------------------------------------------------------------------+
void collectPlannedPositions(position_s& pos[])
  {
   for (int i = ObjectsTotal()-1; i >= 0; --i) 
     {
      const string name = ObjectName(i);

      if (ObjectGetInteger(ChartID(), name, OBJPROP_TYPE) == OBJ_HLINE) 
        {

         const int pos_underscore = StringFind(name, "_");
         if (pos_underscore == -1)
            continue;

         const int index = (int)StringToInteger(StringSubstr(name, pos_underscore+1, 1));

         if (index < 1 || index > 4)
            continue;

         string identifier = StringSubstr(name, 0, pos_underscore);
         StringToLower(identifier);

         if (identifier == "entry") 
           {
            pos[index-1].entry = NormalizeDouble(ObjectGet(name, OBJPROP_PRICE1), Digits);
           }
         else if (identifier == "sl") 
           {
            pos[index-1].stoploss = NormalizeDouble(ObjectGet(name, OBJPROP_PRICE1), Digits);
           }
         else if (identifier == "tp") 
           {
            pos[index-1].takeprofit = NormalizeDouble(ObjectGet(name, OBJPROP_PRICE1), Digits);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Check active positions and fill stoploss and entry where missing |
//+------------------------------------------------------------------+
int checkPlannedPositions(position_s& pos[])
  {
   int activePositions = 0;
   for (int i = 0; i < NUM_POSITIONS; ++i) 
     {
      if (pos[i].entry == 0 && pos[i].stoploss == 0 && pos[i].takeprofit == 0)
         break;

      if (pos[i].entry == 0)
         pos[i].entry = pos[0].entry;
      if (pos[i].stoploss == 0)
         pos[i].stoploss = pos[0].stoploss;
      if (pos[i].entry != 0) 
        {
         //Print("E" + IntegerToString(i+1) + "=" + DoubleToString(pos[i].entry) +
         //    " S" + IntegerToString(i+1) + "=" + DoubleToString(pos[i].stoploss) +
         //    " P" + IntegerToString(i+1) + "=" + DoubleToString(pos[i].takeprofit));
         ++activePositions;
        }
     }
   return activePositions;
  }
//+------------------------------------------------------------------+
//| Calculate chance risk margin and create message to present user  |
//+------------------------------------------------------------------+
string generateDialogMessage(position_s& pos[], int activePositions) 
  {
   double aimedRisk = risk;
   if (risk < 0.1)
      aimedRisk = AccountBalance() * risk;

   double aimedRiskPerPosition = aimedRisk / activePositions;

   double calculatedRisk = 0;
   double calculatedChance = 0;
   double totalLots = 0;
   bool isChancePlusX = false;
   const double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   const double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   const double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   for (int i = 0; i < NUM_POSITIONS; ++i) 
     {
      if (pos[i].entry == 0) break;

      const double stoplossInCurrentPoints = MathAbs(pos[i].entry - pos[i].stoploss);
      double lotSize = aimedRiskPerPosition / ((tickvalue * (stoplossInCurrentPoints / ticksize)));
      if (lotSize < minLot)
         lotSize = minLot;
      pos[i].lots = lotSize;
      totalLots += pos[i].lots;
      calculatedRisk += (stoplossInCurrentPoints / ticksize) * tickvalue * pos[i].lots;

      if (pos[i].takeprofit != 0) 
        {
         const double takeprofitInCurrentPoints = MathAbs(pos[i].takeprofit - pos[i].entry);
         calculatedChance += (takeprofitInCurrentPoints / ticksize) * tickvalue * pos[i].lots;
        }
      else 
        {
         isChancePlusX = true;
        }
     }

   const double riskRewardRatio = calculatedChance / calculatedRisk;
   const double balance = AccountBalance();
   const string accountCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   const double marginRequired = totalLots * MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   string message = StringConcatenate("Overall risk is about ",
                     DoubleToString((calculatedRisk / balance) * 100, 2), "% (",
                     DoubleToString(calculatedRisk, 2), " ", accountCurrency,
                     ").\nChance is about ", DoubleToString((calculatedChance / balance) * 100, 2), "%");
   if(isChancePlusX)
      message = StringConcatenate(message, "+/-X%");
   message = StringConcatenate(message, " (", DoubleToString(calculatedChance,2));
   if(isChancePlusX)
      message = StringConcatenate(message, "+/-X");
   message = StringConcatenate(message, " ", accountCurrency, ").\n",
               "Risk-Reward-Ratio = ", DoubleToString(riskRewardRatio, 2), "\n",
               "Margin required = ", DoubleToString(marginRequired, 2), " ", accountCurrency, "\n",
               "Pending orders will be created now.");
   return message;
  }
//+------------------------------------------------------------------+
