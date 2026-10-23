//+------------------------------------------------------------------+
//|                                             OneClickCloseAll.mq5 |
//|                               Copyright 2025,  Hezekiah Oyetunde |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hezekiah Oyetunde"
#property link      "https://www.mql5.com/en/users/hezetrade"
#property version   "1.00"
#property description "One-Click Close All Positions with Advanced Filters"

//--- Input parameters
input ENUM_BASE_CORNER PanelCorner = CORNER_LEFT_UPPER;  // Panel Corner
input int PanelX = 10;                                    // Panel X Distance
input int PanelY = 50;                                    // Panel Y Distance
input color PanelBackgroundColor = clrDarkSlateGray;      // Panel Background
input color ButtonColorClose = clrCrimson;                // Close Button Color
input color ButtonColorProfit = clrForestGreen;           // Profit Button Color
input color ButtonColorLoss = clrOrangeRed;               // Loss Button Color
input color TextColor = clrWhite;                         // Text Color

//--- Global variables
string prefix = "OCA_";
int panelWidth = 280;
int panelHeight = 380;
int buttonHeight = 35;
int buttonSpacing = 5;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Delete any existing objects first
   DeleteAllObjects();

// Check if algo trading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("ERROR: Algo trading is disabled in terminal! Enable it in Tools -> Options -> Expert Advisors");
      Print("ERROR: Algo trading is disabled in terminal!");
     }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      Alert("ERROR: Automated trading is disabled! Click the 'AutoTrading' button in the toolbar");
      Print("ERROR: Automated trading is disabled for this EA!");
     }

   CreatePanel();
   UpdatePositionInfo();

   Print("=== OneClickCloseAll EA Initialized ===");
   Print("Account: ", AccountInfoInteger(ACCOUNT_LOGIN));
   Print("Symbol: ", _Symbol);
   Print("Initial positions: ", PositionsTotal());

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason != REASON_CHARTCHANGE)
      DeleteAllObjects();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   UpdatePositionInfo();
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == prefix + "BtnCloseAll")
        {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

         if(MessageBox("Close ALL positions?\n\nTotal P&L: " + DoubleToString(GetTotalProfit(), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                       "Confirm Close All", MB_YESNO | MB_ICONQUESTION) == IDYES)
           {
            CloseAllPositions();
           }
        }
      else
         if(sparam == prefix + "BtnCloseBuy")
           {
            ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

            if(MessageBox("Close all BUY positions?\n\nBuy P&L: " + DoubleToString(GetProfitByType(POSITION_TYPE_BUY), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                          "Confirm Close Buy", MB_YESNO | MB_ICONQUESTION) == IDYES)
              {
               ClosePositionsByType(POSITION_TYPE_BUY);
              }
           }
         else
            if(sparam == prefix + "BtnCloseSell")
              {
               ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

               if(MessageBox("Close all SELL positions?\n\nSell P&L: " + DoubleToString(GetProfitByType(POSITION_TYPE_SELL), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                             "Confirm Close Sell", MB_YESNO | MB_ICONQUESTION) == IDYES)
                 {
                  ClosePositionsByType(POSITION_TYPE_SELL);
                 }
              }
            else
               if(sparam == prefix + "BtnCloseSymbol")
                 {
                  ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

                  if(MessageBox("Close all positions on " + _Symbol + "?\n\nSymbol P&L: " + DoubleToString(GetProfitBySymbol(_Symbol), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                                "Confirm Close Symbol", MB_YESNO | MB_ICONQUESTION) == IDYES)
                    {
                     ClosePositionsBySymbol(_Symbol);
                    }
                 }
               else
                  if(sparam == prefix + "BtnCloseProfit")
                    {
                     ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

                     if(MessageBox("Close all PROFITABLE positions?\n\nProfit: " + DoubleToString(GetProfitablePositionsProfit(), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                                   "Confirm Close Profitable", MB_YESNO | MB_ICONQUESTION) == IDYES)
                       {
                        ClosePositionsByProfit(true);
                       }
                    }
                  else
                     if(sparam == prefix + "BtnCloseLoss")
                       {
                        ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

                        if(MessageBox("Close all LOSING positions?\n\nLoss: " + DoubleToString(GetLosingPositionsProfit(), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY),
                                      "Confirm Close Losing", MB_YESNO | MB_ICONQUESTION) == IDYES)
                          {
                           ClosePositionsByProfit(false);
                          }
                       }
                     else
                        if(sparam == prefix + "BtnClose")
                          {
                           ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
                           ExpertRemove();
                          }

      Sleep(100);
      UpdatePositionInfo();
      ChartRedraw(0);
     }
  }

//+------------------------------------------------------------------+
//| Create panel and buttons                                         |
//+------------------------------------------------------------------+
void CreatePanel()
  {
// Background panel
   CreateRectangle(prefix + "Background", PanelX, PanelY, panelWidth, panelHeight, PanelBackgroundColor);

// Title
   CreateLabel(prefix + "Title", PanelX + 10, PanelY + 10, "ONE-CLICK CLOSE PANEL", TextColor, 11, "Arial Bold");

// Position info labels
   CreateLabel(prefix + "InfoPositions", PanelX + 10, PanelY + 40, "Open Positions: 0", TextColor, 9, "Arial");
   CreateLabel(prefix + "InfoProfit", PanelX + 10, PanelY + 60, "Total P&L: 0.00", TextColor, 9, "Arial");
   CreateLabel(prefix + "InfoBuy", PanelX + 10, PanelY + 80, "Buy: 0 | P&L: 0.00", TextColor, 9, "Arial");
   CreateLabel(prefix + "InfoSell", PanelX + 10, PanelY + 100, "Sell: 0 | P&L: 0.00", TextColor, 9, "Arial");

// Separator line
   CreateRectangle(prefix + "Separator", PanelX + 10, PanelY + 125, panelWidth - 20, 1, clrGray);

// Buttons
   int btnY = PanelY + 135;
   CreateButton(prefix + "BtnCloseAll", PanelX + 10, btnY, panelWidth - 20, buttonHeight, "CLOSE ALL POSITIONS", ButtonColorClose);

   btnY += buttonHeight + buttonSpacing;
   CreateButton(prefix + "BtnCloseBuy", PanelX + 10, btnY, (panelWidth - 25) / 2, buttonHeight, "CLOSE BUY", clrDodgerBlue);
   CreateButton(prefix + "BtnCloseSell", PanelX + 15 + (panelWidth - 25) / 2, btnY, (panelWidth - 25) / 2, buttonHeight, "CLOSE SELL", clrTomato);

   btnY += buttonHeight + buttonSpacing;
   CreateButton(prefix + "BtnCloseSymbol", PanelX + 10, btnY, panelWidth - 20, buttonHeight, "CLOSE " + _Symbol, clrSlateBlue);

   btnY += buttonHeight + buttonSpacing;
   CreateButton(prefix + "BtnCloseProfit", PanelX + 10, btnY, panelWidth - 20, buttonHeight, "CLOSE PROFITABLE", ButtonColorProfit);

   btnY += buttonHeight + buttonSpacing;
   CreateButton(prefix + "BtnCloseLoss", PanelX + 10, btnY, panelWidth - 20, buttonHeight, "CLOSE LOSING", ButtonColorLoss);

   btnY += buttonHeight + buttonSpacing + 10;
   CreateButton(prefix + "BtnClose", PanelX + 10, btnY, panelWidth - 20, 30, "✖ REMOVE PANEL", clrDimGray);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Update position information                                      |
//+------------------------------------------------------------------+
void UpdatePositionInfo()
  {
   int totalPositions = PositionsTotal();
   double totalProfit = GetTotalProfit();
   int buyCount = CountPositionsByType(POSITION_TYPE_BUY);
   int sellCount = CountPositionsByType(POSITION_TYPE_SELL);
   double buyProfit = GetProfitByType(POSITION_TYPE_BUY);
   double sellProfit = GetProfitByType(POSITION_TYPE_SELL);

   string currency = AccountInfoString(ACCOUNT_CURRENCY);

   ObjectSetString(0, prefix + "InfoPositions", OBJPROP_TEXT, "Open Positions: " + IntegerToString(totalPositions));

   string profitText = "Total P&L: " + DoubleToString(totalProfit, 2) + " " + currency;
   color profitColor = totalProfit >= 0 ? clrLime : clrRed;
   ObjectSetString(0, prefix + "InfoProfit", OBJPROP_TEXT, profitText);
   ObjectSetInteger(0, prefix + "InfoProfit", OBJPROP_COLOR, profitColor);

   ObjectSetString(0, prefix + "InfoBuy", OBJPROP_TEXT, "Buy: " + IntegerToString(buyCount) + " | P&L: " + DoubleToString(buyProfit, 2) + " " + currency);
   ObjectSetInteger(0, prefix + "InfoBuy", OBJPROP_COLOR, buyProfit >= 0 ? clrLightGreen : clrLightCoral);

   ObjectSetString(0, prefix + "InfoSell", OBJPROP_TEXT, "Sell: " + IntegerToString(sellCount) + " | P&L: " + DoubleToString(sellProfit, 2) + " " + currency);
   ObjectSetInteger(0, prefix + "InfoSell", OBJPROP_COLOR, sellProfit >= 0 ? clrLightGreen : clrLightCoral);
  }

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   int total = PositionsTotal();
   int closed = 0;
   int failed = 0;

   Print("Attempting to close ", total, " positions...");

   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(ClosePosition(ticket))
           {
            closed++;
            Sleep(100); // Small delay between closes
           }
         else
           {
            failed++;
           }
        }
     }

   string message = "Closed " + IntegerToString(closed) + " of " + IntegerToString(total) + " positions";
   if(failed > 0)
      message += " (" + IntegerToString(failed) + " failed)";

   Alert(message);
   Print(message);
  }

//+------------------------------------------------------------------+
//| Close positions by type                                          |
//+------------------------------------------------------------------+
void ClosePositionsByType(ENUM_POSITION_TYPE type)
  {
   int total = PositionsTotal();
   int closed = 0;
   int failed = 0;

   string typeName = type == POSITION_TYPE_BUY ? "BUY" : "SELL";
   Print("Attempting to close ", typeName, " positions...");

   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetInteger(POSITION_TYPE) == type)
        {
         if(ClosePosition(ticket))
           {
            closed++;
            Sleep(100);
           }
         else
           {
            failed++;
           }
        }
     }

   string message = "Closed " + IntegerToString(closed) + " " + typeName + " positions";
   if(failed > 0)
      message += " (" + IntegerToString(failed) + " failed)";

   Alert(message);
   Print(message);
  }

//+------------------------------------------------------------------+
//| Close positions by symbol                                        |
//+------------------------------------------------------------------+
void ClosePositionsBySymbol(string symbol)
  {
   int total = PositionsTotal();
   int closed = 0;
   int failed = 0;

   Print("Attempting to close positions on ", symbol, "...");

   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == symbol)
        {
         if(ClosePosition(ticket))
           {
            closed++;
            Sleep(100);
           }
         else
           {
            failed++;
           }
        }
     }

   string message = "Closed " + IntegerToString(closed) + " positions on " + symbol;
   if(failed > 0)
      message += " (" + IntegerToString(failed) + " failed)";

   Alert(message);
   Print(message);
  }

//+------------------------------------------------------------------+
//| Close positions by profit/loss                                   |
//+------------------------------------------------------------------+
void ClosePositionsByProfit(bool closeProfitable)
  {
   int total = PositionsTotal();
   int closed = 0;
   int failed = 0;

   string typeName = closeProfitable ? "profitable" : "losing";
   Print("Attempting to close ", typeName, " positions...");

   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

         if((closeProfitable && profit > 0) || (!closeProfitable && profit < 0))
           {
            if(ClosePosition(ticket))
              {
               closed++;
               Sleep(100);
              }
            else
              {
               failed++;
              }
           }
        }
     }

   string message = "Closed " + IntegerToString(closed) + " " + typeName + " positions";
   if(failed > 0)
      message += " (" + IntegerToString(failed) + " failed)";

   Alert(message);
   Print(message);
  }

//+------------------------------------------------------------------+
//| Close single position                                            |
//+------------------------------------------------------------------+
bool ClosePosition(ulong ticket)
  {
   Print("=== Attempting to close position #", ticket, " ===");

   if(!PositionSelectByTicket(ticket))
     {
      Print("ERROR: Position ticket ", ticket, " not found or already closed");
      return false;
     }

   string symbol = PositionGetString(POSITION_SYMBOL);
   double volume = PositionGetDouble(POSITION_VOLUME);
   ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   ulong magic = PositionGetInteger(POSITION_MAGIC);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentProfit = PositionGetDouble(POSITION_PROFIT);

   Print("Position details: Symbol=", symbol, " Volume=", volume, " Type=", EnumToString(posType),
         " OpenPrice=", openPrice, " Profit=", currentProfit);

// Check if trading is allowed for this symbol
   if(!SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE))
     {
      Print("ERROR: Trading is not allowed for ", symbol);
      return false;
     }

   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);

   request.action = TRADE_ACTION_DEAL;
   request.position = ticket;
   request.symbol = symbol;
   request.volume = volume;
   request.deviation = 50;
   request.magic = magic;

// Get filling mode from symbol properties
   int filling = (int)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);

// Set order type opposite to position type
   if(posType == POSITION_TYPE_BUY)
     {
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
     }
   else
     {
      request.type = ORDER_TYPE_BUY;
      request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
     }

   Print("Close order: Type=", EnumToString(request.type), " Price=", request.price);

// Try different filling modes
   if(filling && SYMBOL_FILLING_FOK)
     {
      request.type_filling = ORDER_FILLING_FOK;
      Print("Trying ORDER_FILLING_FOK...");
      if(OrderSend(request, result))
        {
         if(result.retcode == TRADE_RETCODE_DONE)
           {
            Print("SUCCESS: Position closed with FOK");
            return true;
           }
        }
      Print("FOK failed: ", result.retcode, " - ", result.comment);
     }

   if(filling && SYMBOL_FILLING_IOC)
     {
      request.type_filling = ORDER_FILLING_IOC;
      Print("Trying ORDER_FILLING_IOC...");
      if(OrderSend(request, result))
        {
         if(result.retcode == TRADE_RETCODE_DONE)
           {
            Print("SUCCESS: Position closed with IOC");
            return true;
           }
        }
      Print("IOC failed: ", result.retcode, " - ", result.comment);
     }

// Try RETURN as fallback
   request.type_filling = ORDER_FILLING_RETURN;
   Print("Trying ORDER_FILLING_RETURN...");
   if(OrderSend(request, result))
     {
      if(result.retcode == TRADE_RETCODE_DONE)
        {
         Print("SUCCESS: Position closed with RETURN");
         return true;
        }
     }

   Print("FAILED to close position #", ticket);
   Print("Final error: ", result.retcode, " - ", result.comment);
   Print("GetLastError: ", GetLastError());

// Detailed error analysis
   switch(result.retcode)
     {
      case TRADE_RETCODE_INVALID:
         Print("DIAGNOSIS: Invalid request");
         break;
      case TRADE_RETCODE_INVALID_VOLUME:
         Print("DIAGNOSIS: Invalid volume");
         break;
      case TRADE_RETCODE_INVALID_PRICE:
         Print("DIAGNOSIS: Invalid price");
         break;
      case TRADE_RETCODE_INVALID_STOPS:
         Print("DIAGNOSIS: Invalid stops");
         break;
      case TRADE_RETCODE_TRADE_DISABLED:
         Print("DIAGNOSIS: Trading is disabled");
         break;
      case TRADE_RETCODE_MARKET_CLOSED:
         Print("DIAGNOSIS: Market is closed");
         break;
      case TRADE_RETCODE_NO_MONEY:
         Print("DIAGNOSIS: Not enough money");
         break;
      case TRADE_RETCODE_PRICE_CHANGED:
         Print("DIAGNOSIS: Price changed (requote)");
         break;
      case TRADE_RETCODE_REJECT:
         Print("DIAGNOSIS: Request rejected by broker");
         break;
      case TRADE_RETCODE_ERROR:
         Print("DIAGNOSIS: Common error");
         break;
      default:
         Print("DIAGNOSIS: Unknown error code");
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Get total profit                                                 |
//+------------------------------------------------------------------+
double GetTotalProfit()
  {
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0)
         profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return profit;
  }

//+------------------------------------------------------------------+
//| Get profit by type                                               |
//+------------------------------------------------------------------+
double GetProfitByType(ENUM_POSITION_TYPE type)
  {
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0 && PositionGetInteger(POSITION_TYPE) == type)
         profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return profit;
  }

//+------------------------------------------------------------------+
//| Get profit by symbol                                             |
//+------------------------------------------------------------------+
double GetProfitBySymbol(string symbol)
  {
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0 && PositionGetString(POSITION_SYMBOL) == symbol)
         profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return profit;
  }

//+------------------------------------------------------------------+
//| Count positions by type                                          |
//+------------------------------------------------------------------+
int CountPositionsByType(ENUM_POSITION_TYPE type)
  {
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0 && PositionGetInteger(POSITION_TYPE) == type)
         count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Get profitable positions profit                                  |
//+------------------------------------------------------------------+
double GetProfitablePositionsProfit()
  {
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0)
        {
         double posProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         if(posProfit > 0)
            profit += posProfit;
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//| Get losing positions profit                                      |
//+------------------------------------------------------------------+
double GetLosingPositionsProfit()
  {
   double profit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetTicket(i) > 0)
        {
         double posProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         if(posProfit < 0)
            profit += posProfit;
        }
     }
   return profit;
  }

//+------------------------------------------------------------------+
//| Create button                                                    |
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int width, int height, string text, color clr)
  {
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, TextColor);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
  }

//+------------------------------------------------------------------+
//| Create label                                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int size, string font)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, font);
  }

//+------------------------------------------------------------------+
//| Create rectangle                                                 |
//+------------------------------------------------------------------+
void CreateRectangle(string name, int x, int y, int width, int height, color clr)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
  }

//+------------------------------------------------------------------+
//| Delete all objects                                               |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   ObjectsDeleteAll(0, prefix);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
