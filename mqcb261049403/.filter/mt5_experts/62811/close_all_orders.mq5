//+------------------------------------------------------------------+
//|                                               CloseAllOrders.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Close all Market and Pending orders with button click"

//--- Input parameters
input group "=== Button Settings ==="
input int ButtonX = 20;                  // Button X Position
input int ButtonY = 50;                  // Button Y Position
input int ButtonWidth = 180;             // Button Width
input int ButtonHeight = 40;             // Button Height
input color ButtonColor = clrCrimson;    // Button Color
input color TextColor = clrWhite;        // Text Color

input group "=== Close Settings ==="
input bool CloseMarketOrders = true;     // Close Market Orders
input bool ClosePendingOrders = true;    // Close Pending Orders
input int  Slippage = 10;                // Allowed Slippage (points)
input bool ShowConfirmation = true;      // Show Confirmation Dialog

//--- Button names
#define BTN_CLOSE_ALL "BtnCloseAll"
#define BTN_INFO "BtnInfo"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create Close All button
   CreateButton(BTN_CLOSE_ALL, "CLOSE ALL ORDERS", ButtonX, ButtonY, ButtonWidth, ButtonHeight, ButtonColor, TextColor);
   
   // Create Info button
   CreateButton(BTN_INFO, "INFO", ButtonX, ButtonY + ButtonHeight + 10, ButtonWidth, 30, clrDodgerBlue, TextColor);
   
   // Update info display
   UpdateInfoDisplay();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete all objects
   ObjectDelete(0, BTN_CLOSE_ALL);
   ObjectDelete(0, BTN_INFO);
   ObjectDelete(0, "InfoLabel");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update info every tick
   UpdateInfoDisplay();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Check for button click
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == BTN_CLOSE_ALL)
      {
         CloseAllOrders();
         ObjectSetInteger(0, BTN_CLOSE_ALL, OBJPROP_STATE, false);
         ChartRedraw();
      }
      else if(sparam == BTN_INFO)
      {
         ShowInfo();
         ObjectSetInteger(0, BTN_INFO, OBJPROP_STATE, false);
         ChartRedraw();
      }
   }
}

//+------------------------------------------------------------------+
//| Create Button                                                     |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int width, int height, color bgColor, color txtColor)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   }
   
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
}

//+------------------------------------------------------------------+
//| Update Info Display                                              |
//+------------------------------------------------------------------+
void UpdateInfoDisplay()
{
   int totalMarket = PositionsTotal();
   int totalPending = OrdersTotal();
   
   string infoText = StringFormat("Market: %d | Pending: %d", totalMarket, totalPending);
   
   string labelName = "InfoLabel";
   if(ObjectFind(0, labelName) < 0)
   {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, ButtonX);
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, ButtonY + ButtonHeight + 50);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
   }
   
   ObjectSetString(0, labelName, OBJPROP_TEXT, infoText);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Close All Orders Function                                        |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   int totalOrders = PositionsTotal();
   int totalPending = OrdersTotal();
   
   // Check if there are any orders
   if(totalOrders == 0 && totalPending == 0)
   {
      Alert("No orders to close!");
      return;
   }
   
   // Show confirmation dialog
   if(ShowConfirmation)
   {
      string message = "Are you sure you want to close:\n";
      if(CloseMarketOrders && totalOrders > 0)
         message += StringFormat("- %d Market orders\n", totalOrders);
      if(ClosePendingOrders && totalPending > 0)
         message += StringFormat("- %d Pending orders\n", totalPending);
      
      int result = MessageBox(message, "Confirm Close Orders", MB_YESNO | MB_ICONQUESTION);
      if(result != IDYES)
      {
         Print("Order closing cancelled");
         return;
      }
   }
   
   int closedMarket = 0;
   int closedPending = 0;
   int failedMarket = 0;
   int failedPending = 0;
   
   // Close Market orders
   if(CloseMarketOrders)
   {
      Print("Starting to close Market orders...");
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0)
         {
            if(ClosePosition(ticket))
               closedMarket++;
            else
               failedMarket++;
         }
      }
   }
   
   // Close Pending orders
   if(ClosePendingOrders)
   {
      Print("Starting to delete Pending orders...");
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0)
         {
            if(DeletePendingOrder(ticket))
               closedPending++;
            else
               failedPending++;
         }
      }
   }
   
   // Display results
   string resultMsg = "=== CLOSE ORDERS RESULT ===\n";
   if(CloseMarketOrders)
      resultMsg += StringFormat("Market Orders: %d closed, %d failed\n", 
                                closedMarket, failedMarket);
   if(ClosePendingOrders)
      resultMsg += StringFormat("Pending Orders: %d deleted, %d failed\n", 
                                closedPending, failedPending);
   
   Print(resultMsg);
   Alert(resultMsg);
   
   // Update display
   UpdateInfoDisplay();
}

//+------------------------------------------------------------------+
//| Close a Market position                                          |
//+------------------------------------------------------------------+
bool ClosePosition(ulong ticket)
{
   if(!PositionSelectByTicket(ticket))
   {
      Print("Cannot select position #", ticket);
      return false;
   }
   
   string symbol = PositionGetString(POSITION_SYMBOL);
   long magic = PositionGetInteger(POSITION_MAGIC);
   double volume = PositionGetDouble(POSITION_VOLUME);
   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.position = ticket;
   request.symbol = symbol;
   request.volume = volume;
   request.deviation = Slippage;
   request.magic = magic;
   
   // Determine close order type
   if(type == POSITION_TYPE_BUY)
   {
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
   }
   else
   {
      request.type = ORDER_TYPE_BUY;
      request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
   }
   
   // Send order
   if(!OrderSend(request, result))
   {
      Print("Error closing position #", ticket, " - ", GetLastError(), 
            " RetCode: ", result.retcode, " - ", result.comment);
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE || 
      result.retcode == TRADE_RETCODE_PLACED ||
      result.retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      Print("Position #", ticket, " closed successfully");
      return true;
   }
   else
   {
      Print("Error closing position #", ticket, " RetCode: ", result.retcode);
      return false;
   }
}

//+------------------------------------------------------------------+
//| Delete a Pending order                                           |
//+------------------------------------------------------------------+
bool DeletePendingOrder(ulong ticket)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_REMOVE;
   request.order = ticket;
   
   if(!OrderSend(request, result))
   {
      Print("Error deleting pending order #", ticket, " - ", GetLastError());
      return false;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE)
   {
      Print("Pending order #", ticket, " deleted successfully");
      return true;
   }
   else
   {
      Print("Error deleting pending order #", ticket, " RetCode: ", result.retcode);
      return false;
   }
}

//+------------------------------------------------------------------+
//| Show Info                                                         |
//+------------------------------------------------------------------+
void ShowInfo()
{
   string info = "=== CLOSE ALL ORDERS EA ===\n\n";
   info += "Current Settings:\n";
   info += StringFormat("- Close Market Orders: %s\n", CloseMarketOrders ? "YES" : "NO");
   info += StringFormat("- Close Pending Orders: %s\n", ClosePendingOrders ? "YES" : "NO");
   info += StringFormat("- Slippage: %d points\n", Slippage);
   info += StringFormat("- Show Confirmation: %s\n\n", ShowConfirmation ? "YES" : "NO");
   
   info += StringFormat("- Market Orders: %d\n", PositionsTotal());
   info += StringFormat("- Pending Orders: %d\n", OrdersTotal());
   
   MessageBox(info, "EA Information", MB_OK | MB_ICONINFORMATION);
}
//+------------------------------------------------------------------+