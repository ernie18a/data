//+------------------------------------------------------------------+
//|                                                NNFXAutoTrade.mq4 |
//|                                                      Alex Cercos |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Alex Cercos"
#property version   "1.00"
#property strict

//Button identificators

#define SELL_BUTTON "SELL"
#define BUY_BUTTON "BUY"
#define BREAKEVEN_BUTTON "BREAKEVEN"
#define TRAILING_BUTTON "TRAILING"
#define CLOSE_BUTTON "CLOSE"
#define PERCENT_INPUT "PERCENTAJE"
#define SHOW_BUTTON "SHOW"
#define ADVANCED_BUTTON "ADV."

#define PIPV_LABEL "PIP VALUE"
#define ATR_LABEL "ATR"
#define LOTS_LABEL "LOTS"
#define COST_LABEL "COST"

#define MAIN_BG "Background"
#define SHOW_BG "Show Background"
#define ADVANCED_BG "Advanced BG"

#define ADV_STOP "ADV STOP"
#define ADV_TAKE "ADV TAKE"
#define ADV_DATE "DATE BUTTON"


//Inputs

input int inital_y = 30; //Y position in the screen
input int initial_x = 10; //X position in the screen
input double initialRisk = 2.0; //Default risk (saved between sessions)
input int pipPoints = 1; // Pip decimal shift (extra decimals)
input int lotsDecimals = 2; // Lots decimals

int extraAccount = 0; // Money in external account (to not split risk)
//Not a parameter since it would have to be changed in all active EAs
//Instead, change this value and recompile for it to be updated in all instances



//Private variables

bool showValues = true; //Show variables in screen
bool useAdvanced = false; //Customize TP, SL or not use current date (better if using lower timeframes)

bool useDate = true; //Only in D1 charts, reads ATR from previous day if it is <12h after 00:00 (GMT+1 I think, whenever candles are closed)

double risk = 2.0; //Risk value used in the script (which can be modified)

double pipValue; // $/€/etc. per pip
double atr; // current ATR (or last candle ATR)
double lots; // calculated lots for 1 trade
double lotsValue; // Cost of the lots (has to be the risk % of the account)


//stop and tp used with advanced settings

double advStop = 0;
double advTakeProfit = 0;



/*==================================
   INIT FUNCTION
   
   Create buttons and properties and all that
==================================*/

int OnInit()
{
   risk = initialRisk;
   
   //Chart needs to be on foreground (it would be drawn above the buttons if not)
   ChartSetInteger(0, CHART_FOREGROUND, 0);
   
   ObjectCreate(0, MAIN_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, MAIN_BG, OBJPROP_XSIZE, 140);
   ObjectSetInteger(0, MAIN_BG, OBJPROP_YSIZE, 240);
   ObjectSetInteger(0, MAIN_BG, OBJPROP_BGCOLOR, clrGray);
   ObjectSetInteger(0, MAIN_BG, OBJPROP_XDISTANCE, initial_x-5);
   ObjectSetInteger(0, MAIN_BG, OBJPROP_YDISTANCE, inital_y-5);
   
   //Create and set initial buttons and input fields
   
   ObjectCreate(0, "PercentText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "PercentText", OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, "PercentText", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "PercentText", OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, "PercentText", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "PercentText", OBJPROP_XDISTANCE, initial_x + 20);
   ObjectSetInteger(0, "PercentText", OBJPROP_YDISTANCE, inital_y + 5);
   ObjectSetString(0, "PercentText", OBJPROP_TEXT, "RISK");
   ObjectSetInteger(0, "PercentText", OBJPROP_BACK, 0);
   
   ObjectCreate(0, PERCENT_INPUT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, PERCENT_INPUT, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, PERCENT_INPUT, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, PERCENT_INPUT, OBJPROP_XDISTANCE, initial_x + 80);
   ObjectSetInteger(0, PERCENT_INPUT, OBJPROP_YDISTANCE, inital_y);
   ObjectSetString(0, PERCENT_INPUT, OBJPROP_TEXT, DoubleToStr(risk, 2));
   ObjectSetInteger(0, PERCENT_INPUT, OBJPROP_BACK, 0);
   
   //SELL button
   ObjectCreate(0, SELL_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_BGCOLOR, clrOrangeRed);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_XDISTANCE, initial_x);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_YDISTANCE, inital_y + 40);
   ObjectSetString(0, SELL_BUTTON, OBJPROP_TEXT, SELL_BUTTON);
   ObjectSetInteger(0, SELL_BUTTON, OBJPROP_BACK, 0);
   
   //BUY button
   ObjectCreate(0, BUY_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_BGCOLOR, clrAqua);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_XDISTANCE, initial_x + 80);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_YDISTANCE, inital_y + 40);
   ObjectSetString(0, BUY_BUTTON, OBJPROP_TEXT, BUY_BUTTON);
   ObjectSetInteger(0, BUY_BUTTON, OBJPROP_BACK, 0);
   
   //SL TO BREAKEVEN button
   ObjectCreate(0, BREAKEVEN_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_XSIZE, 130);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_BGCOLOR, clrYellowGreen);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_XDISTANCE, initial_x);
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_YDISTANCE, inital_y + 80);
   ObjectSetString(0, BREAKEVEN_BUTTON, OBJPROP_TEXT, "SL to BREAKEVEN");
   ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_BACK, 0);
   
   //TRAILING STOP button
   ObjectCreate(0, TRAILING_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_XSIZE, 130);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_XDISTANCE, initial_x);
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_YDISTANCE, inital_y + 120);
   ObjectSetString(0, TRAILING_BUTTON, OBJPROP_TEXT, "TRAILING STOP");
   ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_BACK, 0);
   
   //CLOSE ALL trades button
   ObjectCreate(0, CLOSE_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_XSIZE, 130);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_BGCOLOR, clrDarkRed);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_XDISTANCE, initial_x);
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_YDISTANCE, inital_y + 160);
   ObjectSetString(0, CLOSE_BUTTON, OBJPROP_TEXT, "CLOSE ALL");
   ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_BACK, 0);
   
   //SHOW parameters button
   ObjectCreate(0, SHOW_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_XDISTANCE, initial_x);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_YDISTANCE, inital_y + 200);
   ObjectSetString(0, SHOW_BUTTON, OBJPROP_TEXT, SHOW_BUTTON);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_BACK, 0);
   ObjectSetInteger(0, SHOW_BUTTON, OBJPROP_STATE, showValues);
   
   //ADVANCED parameters button
   ObjectCreate(0, ADVANCED_BUTTON, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_XDISTANCE, initial_x + 80);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_YDISTANCE, inital_y + 200);
   ObjectSetString(0, ADVANCED_BUTTON, OBJPROP_TEXT, ADVANCED_BUTTON);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_BACK, 0);
   ObjectSetInteger(0, ADVANCED_BUTTON, OBJPROP_STATE, useAdvanced);
   
   
   CreateShowMenu();
   
   return(INIT_SUCCEEDED);
}

/*==================================

   DEINIT (When removing EA, all things are deleted)
   
==================================*/

void OnDeinit(const int reason)
{
   ObjectDelete(SELL_BUTTON);
   ObjectDelete(BUY_BUTTON);
   ObjectDelete(BREAKEVEN_BUTTON);
   ObjectDelete(TRAILING_BUTTON);
   ObjectDelete(CLOSE_BUTTON);
   ObjectDelete(PERCENT_INPUT);
   ObjectDelete(SHOW_BUTTON);
   ObjectDelete(ADVANCED_BUTTON);
   
   ObjectDelete(MAIN_BG);
   
   DeleteShowMenu();
   DeleteAdvancedMenu();
   
   ObjectDelete("PercentText");
}

/*==================================
   TICK FUNCTION
   
   Only recalculates values (ATR changes)
==================================*/

void OnTick()
{
   //Update Values
   RecalculateValues();
}


/*==================================
   BUTTON CLICK HANDLER (for any of the buttons)
==================================*/

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{

   if (sparam == SELL_BUTTON)
   {
      Print("SELL PRESSED");
      double halfLots = NormalizeDouble(lots/2, lotsDecimals);
      
      double SL, TP;
      
      if (useAdvanced)
      {
         SL = advStop * (Point * MathPow(10, pipPoints));
         TP = advTakeProfit * (Point * MathPow(10, pipPoints));
      }
      else 
      {
         SL = atr * 1.5;
         TP = atr;
      }
      
      //Half with take profit
      int ticket = OrderSend(Symbol(), OP_SELL, halfLots, Bid, 3, Bid + SL, Bid - TP, NULL, 16384, 0, clrNONE);
      if(ticket>0)
        {
         if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
            Print("SELL order with TP opened : ",OrderOpenPrice());
        }
      else
         Print("Error opening SELL order with TP: ",GetLastError());
         
      //Half to scale out
      ticket = OrderSend(Symbol(), OP_SELL, lots - halfLots, Bid, 3, Bid + SL, 0, NULL, 16384, 0, clrNONE);
      if(ticket>0)
        {
         if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
            Print("SELL order without TP opened : ",OrderOpenPrice());
        }
      else
         Print("Error opening SELL order without TP: ",GetLastError());
      
      ObjectSetInteger(0, SELL_BUTTON, OBJPROP_STATE, false);
      return;
   }
   
   
   else if (sparam == BUY_BUTTON)
   {
      Print("BUY PRESSED");
      
      double halfLots = NormalizeDouble(lots/2, lotsDecimals);
      
      double SL, TP;
      
      if (useAdvanced)
      {
         SL = advStop * (Point * MathPow(10, pipPoints));
         TP = advTakeProfit * (Point * MathPow(10, pipPoints));
      }
      else 
      {
         SL = atr * 1.5;
         TP = atr;
      }
      
      //Half with take profit
      
      int ticket = OrderSend(Symbol(), OP_BUY, halfLots, Ask, 3, Ask - SL, Ask + TP, NULL, 16384, 0, clrNONE);
      if(ticket>0)
        {
         if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
            Print("BUY order with TP opened : ",OrderOpenPrice());
        }
      else
         Print("Error opening BUY order with TP: ",GetLastError());
         
         
      //Half to scale out
      ticket = OrderSend(Symbol(), OP_BUY, lots - halfLots, Ask, 3, Ask - SL, 0, NULL, 16384, 0, clrNONE);
      if(ticket>0)
        {
         if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
            Print("BUY order without TP opened : ",OrderOpenPrice());
        }
      else
         Print("Error opening BUY order without TP: ",GetLastError());
      
   
      ObjectSetInteger(0, BUY_BUTTON, OBJPROP_STATE, false);
      return;
   }
   
   else if (sparam == BREAKEVEN_BUTTON)
   {
      Print("BREAKEVEN PRESSED");
      //Select all open orders in this symbol and set SL to breakeven
      int i;
      int total = OrdersTotal();
      
      for(i = total-1; i >= 0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderSymbol()== Symbol())
         {
            //Set Stop to Open Price
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), OrderExpiration(), clrNONE))
               Print("Error modyfing order: ",GetLastError());
         }
      }
      
      ObjectSetInteger(0, BREAKEVEN_BUTTON, OBJPROP_STATE, false);
      return;
   }
   
   else if (sparam == TRAILING_BUTTON)
   {
      Print("TRAILING STOP PRESSED");
      //Update trailing stop loss for all opened orders in this symbol (should be only one opened)
      int i;
      int total = OrdersTotal();
      
      for(i = total-1; i >= 0; i--) // Iterate all opened orders in the account
      {
         
         if(!OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderSymbol()== Symbol()) // Order is in the active symbol
         {
            int candle = iBarShift(Symbol(), 0, OrderOpenTime());
            
            double hour = (OrderOpenTime()-Time[candle])/3600.0; // Hour when opened (before or after daily candle close)
            
            double openAtr;
            
            if (useDate && hour < 12) 
               openAtr = iATR(Symbol(), 0, 14, candle + 1);
            else 
               openAtr = iATR(Symbol(), 0, 14, candle);
            
            if(OrderType()==OP_BUY)
            {
               double movedPrice = Close[0] - OrderOpenPrice();
               
               double startMove;
               
               if (useAdvanced) startMove = advStop * (Point * MathPow(10, pipPoints));
               else startMove = openAtr * 2;
               
               if (movedPrice > startMove) //Start moving trailing stop after 2*atr
               {
                  double currentStop = OrderStopLoss();
                  
                  double trailingStop;
                  
                  if (useAdvanced) trailingStop = Close[0] - advStop * (Point * MathPow(10, pipPoints));
                  else trailingStop = Close[0] - 2 * openAtr;
                  
                  if (trailingStop > currentStop) // If price has advanced, modify
                  {
                     if (!OrderModify(OrderTicket(), OrderOpenPrice(), trailingStop, OrderTakeProfit(), OrderExpiration(), clrNONE))
                        Print("Error modyfing order: ",GetLastError());
                  }
               }
               
            }
            else if(OrderType()==OP_SELL)
            {
            
               double movedPrice = OrderOpenPrice() - Close[0];
               
               double startMove;
               
               if (useAdvanced) startMove = advStop * (Point * MathPow(10, pipPoints));
               else startMove = openAtr * 2;
               
               
               if (movedPrice > startMove) //Start moving trailing stop after 2*atr
               {
                  double currentStop = OrderStopLoss();
                  
                  
                  double trailingStop;
                  
                  if (useAdvanced) trailingStop = Close[0] + advStop * (Point * MathPow(10, pipPoints));
                  else trailingStop = Close[0] + 2 * openAtr;
                  
                  
                  if (trailingStop < currentStop) // If price has advanced, modify
                  {
                     if (!OrderModify(OrderTicket(), OrderOpenPrice(), trailingStop, OrderTakeProfit(), OrderExpiration(), clrNONE))
                        Print("Error modyfing order: ",GetLastError());
                  }
               }
            }
         }
      }
   
      ObjectSetInteger(0, TRAILING_BUTTON, OBJPROP_STATE, false);
      return;
   }
   
   else if (sparam == CLOSE_BUTTON)
   {
      Print("CLOSE ALL TRADES PRESSED");
      
      //Close all opened orders in this symbol (when exit indicator says so)
      int i;
      int total = OrdersTotal();
      
      
      for(i = total-1; i >= 0; i--) // Iterate all opened orders in the account
      {
         if(!OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderSymbol()== Symbol()) // Order is in the active symbol
         {
            Print(i);
            if(OrderType()==OP_BUY)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3, clrNONE))
                  Print("Error closing order, ",GetLastError());
            }
            
            else if(OrderType()==OP_SELL)
            {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3, clrNONE))
                  Print("Error closing order, ",GetLastError());
            }
         }
      }
      
      ObjectSetInteger(0, CLOSE_BUTTON, OBJPROP_STATE, false);
      return;
   }
   
   else if (sparam == PERCENT_INPUT)
   {
      double newRisk = NormalizeDouble(StrToDouble(ObjectGetString(0, PERCENT_INPUT, OBJPROP_TEXT)), 2);
      
      if (risk != newRisk)
      {
         risk = newRisk;
         
         ObjectSetString(0, PERCENT_INPUT, OBJPROP_TEXT, DoubleToStr(risk, 2));
      
         Print("Risk Set to ", risk, "%");
         
         RecalculateValues();
      }
   }
   
   else if (sparam == SHOW_BUTTON)
   {
      showValues = !showValues;
      
      if (showValues)
      {
         CreateShowMenu();
      }
      else
      {
         DeleteShowMenu();
      }
   }
   
   else if (sparam == ADVANCED_BUTTON)
   {
      useAdvanced = !useAdvanced;
      
      if (useAdvanced)
      {
         CreateAdvancedMenu();
      }
      else
      {
         DeleteAdvancedMenu();
      }
      
      RecalculateValues();
   }
   
   else if (sparam == ADV_STOP)
   {
      double newStop = NormalizeDouble(StrToDouble(ObjectGetString(0, ADV_STOP, OBJPROP_TEXT)), 1);
      
      if (advStop != newStop)
      {
         advStop = newStop;
         
         ObjectSetString(0, ADV_STOP, OBJPROP_TEXT, DoubleToStr(advStop, 1));
      
         
         RecalculateValues();
      }
   }
   
   else if (sparam == ADV_TAKE)
   {
      double newTake = NormalizeDouble(StrToDouble(ObjectGetString(0, ADV_TAKE, OBJPROP_TEXT)), 1);
      
      if (advTakeProfit != newTake)
      {
         advTakeProfit = newTake;
         
         ObjectSetString(0, ADV_TAKE, OBJPROP_TEXT, DoubleToStr(advTakeProfit, 1));
         
      }
   }
   
   else if (sparam == ADV_DATE)
   {
      useDate = !useDate;
      
      RecalculateValues();
   }
   
}


/*==================================
   Recalculate stop loss, pip value, risk...
==================================*/

void RecalculateValues()
{

   /*
      BASED ON myfxbook's position size calculator and "https://onlinelibrary.wiley.com/doi/pdf/10.1002/9781119204831.app2"
      
      PRECISION DEPENDS ON ACCOUNT SIZE (and other factors)
      
         ***Other errors may appear in calculations outside of forex symbols (in metals, oil, stocks...)
   
   */
   
   //Pick ATR (or ATR from last closed bar)
   
   double hour = (TimeCurrent()-Time[0])/3600.0; //Time current = time of last tick
   
   if (useDate && hour < 12) //Check if daily candle has closed less than 12 hours ago
   {
      atr = iATR(NULL, 0, 14, 1);
   }
   else
   {
      atr = iATR(NULL, 0, 14, 0);
   }
   
   
   double atrInPips = atr / (Point * MathPow(10, pipPoints)); //atr counted as pips
   
   double stopLoss; // stop loss (to determine risk)
   
   if (useAdvanced)
      stopLoss = advStop;
   else
      stopLoss = atrInPips * 1.5;
      
   

   double riskTotal = (AccountBalance() + extraAccount) * risk / 100; // Total money risked (aprox)
   
   
   if (stopLoss > 0) //To avoid 0 division errors
      pipValue = riskTotal / stopLoss;
   else
      pipValue = riskTotal;
   
   
   // Ask price from account currency to secondary pair currency
   
   string accountCurrency = AccountCurrency();
   string currencySecundary = SymbolInfoString(Symbol(), SYMBOL_CURRENCY_PROFIT);
   
   double askPrice = GetCurrencyExchange(accountCurrency, currencySecundary);
   
   double digits = MathPow(10, -SymbolInfoInteger(Symbol(), SYMBOL_DIGITS) + pipPoints); // Pip decimals in active symbol


   lots = NormalizeDouble(pipValue / (askPrice * digits * 100000), lotsDecimals); //Lots to buy (best approximation to risk)
   
   if (stopLoss > 0) //To avoid 0 div errors
      lotsValue = lots * askPrice * digits * 100000 * stopLoss; //Calculate at the end (it rarely is the exact same as risk% of the account)
   else
      lotsValue = lots * askPrice * digits * 100000;
      

   //Show info
   if (showValues)
   {
      ObjectSetString(0, ATR_LABEL, OBJPROP_TEXT, "ATR: " + DoubleToStr(atrInPips, pipPoints));
      ObjectSetString(0, PIPV_LABEL, OBJPROP_TEXT, "PIP VALUE: " + DoubleToStr(pipValue, 2));
      ObjectSetString(0, LOTS_LABEL, OBJPROP_TEXT, "LOTS: " + DoubleToStr(lots, lotsDecimals));
      ObjectSetString(0, COST_LABEL, OBJPROP_TEXT, "RISK: " + DoubleToStr(lotsValue, 2) + " " + accountCurrency);
   }
}

/*===========================================

   Conversion from one currency to another
   
=============================================*/
double GetCurrencyExchange(string from, string to)
{
   string symbol = from + to;

   double exchange;
   
   if (from == to) return 1;
   
   if (SymbolInfoDouble(symbol, SYMBOL_ASK, exchange))
   {
      
      return 1 / exchange;
   }
   else // Correct symbol is the inverse one
   {
      symbol = to + from;
      
      if (SymbolInfoDouble(symbol, SYMBOL_ASK, exchange))
      {
         return exchange;
      }
      
      
      else
      {
         Print("Symbol error: ", symbol, "not found");
         return 1; //Return default if there is an error, but it should not happen...
      }
   }
   
}


/*========================

   Show and hide menus
=========================*/

void CreateShowMenu()
{
   ObjectCreate(0, SHOW_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, SHOW_BG, OBJPROP_XSIZE, 160);
   ObjectSetInteger(0, SHOW_BG, OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, SHOW_BG, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, SHOW_BG, OBJPROP_XDISTANCE, initial_x-5);
   ObjectSetInteger(0, SHOW_BG, OBJPROP_YDISTANCE, inital_y+250-5);
   
   ObjectCreate(0, PIPV_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_XDISTANCE, initial_x + 10);
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_YDISTANCE, inital_y + 255);
   ObjectSetString(0, PIPV_LABEL, OBJPROP_TEXT, "PIP VALUE");
   ObjectSetInteger(0, PIPV_LABEL, OBJPROP_BACK, 0);
   
   ObjectCreate(0, ATR_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_XDISTANCE, initial_x + 10);
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_YDISTANCE, inital_y + 275);
   ObjectSetString(0, ATR_LABEL, OBJPROP_TEXT, "ATR");
   ObjectSetInteger(0, ATR_LABEL, OBJPROP_BACK, 0);
   
   ObjectCreate(0, LOTS_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_XDISTANCE, initial_x + 10);
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_YDISTANCE, inital_y + 295);
   ObjectSetString(0, LOTS_LABEL, OBJPROP_TEXT, "LOTS");
   ObjectSetInteger(0, LOTS_LABEL, OBJPROP_BACK, 0);
   
   ObjectCreate(0, COST_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_XDISTANCE, initial_x + 10);
   ObjectSetInteger(0, COST_LABEL, OBJPROP_YDISTANCE, inital_y + 315);
   ObjectSetString(0, COST_LABEL, OBJPROP_TEXT, "COST");
   ObjectSetInteger(0, COST_LABEL, OBJPROP_BACK, 0);
   
   RecalculateValues();
}


void DeleteShowMenu()
{
   ObjectDelete(SHOW_BG);
   ObjectDelete(PIPV_LABEL);
   ObjectDelete(ATR_LABEL);
   ObjectDelete(LOTS_LABEL);
   ObjectDelete(COST_LABEL);
}



void CreateAdvancedMenu()
{
   if (advStop == 0)
   {
      advStop = atr / (Point * MathPow(10, pipPoints))*1.5;
   }
   
   if (advTakeProfit==0)
   {
      advTakeProfit = atr / (Point * MathPow(10, pipPoints));
   }

   ObjectCreate(0, ADVANCED_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, ADVANCED_BG, OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, ADVANCED_BG, OBJPROP_YSIZE, 120);
   ObjectSetInteger(0, ADVANCED_BG, OBJPROP_BGCOLOR, clrGray);
   ObjectSetInteger(0, ADVANCED_BG, OBJPROP_XDISTANCE, initial_x+150 - 5);
   ObjectSetInteger(0, ADVANCED_BG, OBJPROP_YDISTANCE, inital_y-5);
   
   ObjectCreate(0, "ADVStopText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_XDISTANCE, initial_x + 160);
   ObjectSetInteger(0, "ADVStopText", OBJPROP_YDISTANCE, inital_y + 5);
   ObjectSetString(0, "ADVStopText", OBJPROP_TEXT, "SL");
   ObjectSetInteger(0, "ADVStopText", OBJPROP_BACK, 0);
   
   ObjectCreate(0, ADV_STOP, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, ADV_STOP, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, ADV_STOP, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, ADV_STOP, OBJPROP_XDISTANCE, initial_x + 190);
   ObjectSetInteger(0, ADV_STOP, OBJPROP_YDISTANCE, inital_y);
   ObjectSetString(0, ADV_STOP, OBJPROP_TEXT, DoubleToStr(advStop, 1));
   ObjectSetInteger(0, ADV_STOP, OBJPROP_BACK, 0);
   
   ObjectCreate(0, "ADVTakeText", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_XDISTANCE, initial_x + 160);
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_YDISTANCE, inital_y + 45);
   ObjectSetString(0, "ADVTakeText", OBJPROP_TEXT, "TP");
   ObjectSetInteger(0, "ADVTakeText", OBJPROP_BACK, 0);
   
   ObjectCreate(0, ADV_TAKE, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, ADV_TAKE, OBJPROP_XSIZE, 50);
   ObjectSetInteger(0, ADV_TAKE, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, ADV_TAKE, OBJPROP_XDISTANCE, initial_x + 190);
   ObjectSetInteger(0, ADV_TAKE, OBJPROP_YDISTANCE, inital_y + 40);
   ObjectSetString(0, ADV_TAKE, OBJPROP_TEXT, DoubleToStr(advTakeProfit, 1));
   ObjectSetInteger(0, ADV_TAKE, OBJPROP_BACK, 0);
   
   ObjectCreate(0, ADV_DATE, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_XSIZE, 90);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_XDISTANCE, initial_x + 150);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_YDISTANCE, inital_y + 80);
   ObjectSetString(0, ADV_DATE, OBJPROP_TEXT, "USE DATE");
   ObjectSetInteger(0, ADV_DATE, OBJPROP_BACK, 0);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_BGCOLOR, clrLightGray);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, ADV_DATE, OBJPROP_STATE, useDate);
}


void DeleteAdvancedMenu()
{
   ObjectDelete(ADVANCED_BG);
   ObjectDelete("ADVStopText");
   ObjectDelete(ADV_STOP);
   ObjectDelete("ADVTakeText");
   ObjectDelete(ADV_TAKE);
   ObjectDelete(ADV_DATE);
}