//+------------------------------------------------------------------+
//|                                              Fox Wave Clean.mq5  |
//|                                      Professional Order Manager  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Fox Wave QCW"
#property link      "https://www.foxwavetrading.top"
#property version   "1.10"
//#property icon "fox.ico"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

// Dashboard pozice
int cornerX = 20;
int cornerY = 30;
int panelWidth = 340;
int panelHeight = 210;

// Barvy
color bgColor = C'20,20,30';
color textColor = clrWhiteSmoke;
color headerColor = C'255,140,0';
color deleteBtn = C'220,60,60';
color profitBtn = C'50,180,100';
color lossBtn = C'255,150,50';

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   CreateDashboard();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "FWC_");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   UpdateDashboard();
}

//+------------------------------------------------------------------+
//| Chart Event function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == "FWC_DeletePending")
      {
         DeleteAllPendingOrders();
         Sleep(100);
         ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_STATE, false);
      }
      else if(sparam == "FWC_CloseProfits")
      {
         CloseAllProfitablePositions();
         Sleep(100);
         ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_STATE, false);
      }
      else if(sparam == "FWC_CloseLosses")
      {
         CloseAllLosingPositions();
         Sleep(100);
         ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_STATE, false);
      }
   }
}

//+------------------------------------------------------------------+
//| Create Dashboard                                                   |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   // Hlavní panel - pozadí
   ObjectCreate(0, "FWC_Panel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_XDISTANCE, cornerX);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_YDISTANCE, cornerY);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_YSIZE, panelHeight);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_COLOR, C'60,60,80');
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "FWC_Panel", OBJPROP_BACK, true);
   
   // Header
   ObjectCreate(0, "FWC_Header", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "FWC_Header", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_Header", OBJPROP_YDISTANCE, cornerY + 12);
   ObjectSetInteger(0, "FWC_Header", OBJPROP_COLOR, headerColor);
   ObjectSetInteger(0, "FWC_Header", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, "FWC_Header", OBJPROP_FONT, "Arial Black");
   ObjectSetString(0, "FWC_Header", OBJPROP_TEXT, "🦊 FOX WAVE CLEAN");
   ObjectSetInteger(0, "FWC_Header", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   // Statistiky label 1 - první řádek
   ObjectCreate(0, "FWC_Stats1", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "FWC_Stats1", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_Stats1", OBJPROP_YDISTANCE, cornerY + 40);
   ObjectSetInteger(0, "FWC_Stats1", OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, "FWC_Stats1", OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, "FWC_Stats1", OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, "FWC_Stats1", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   // Statistiky label 2 - druhý řádek
   ObjectCreate(0, "FWC_Stats2", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "FWC_Stats2", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_Stats2", OBJPROP_YDISTANCE, cornerY + 55);
   ObjectSetInteger(0, "FWC_Stats2", OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, "FWC_Stats2", OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, "FWC_Stats2", OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, "FWC_Stats2", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   // Tlačítko 1 - Smazat pending ordery
   ObjectCreate(0, "FWC_DeletePending", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_YDISTANCE, cornerY + 80);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_XSIZE, 310);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_YSIZE, 35);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_BGCOLOR, deleteBtn);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "FWC_DeletePending", OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, "FWC_DeletePending", OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, "FWC_DeletePending", OBJPROP_TEXT, "🗑️ DELETE PENDING ORDERS");
   
   // Tlačítko 2 - Zavřít zisky
   ObjectCreate(0, "FWC_CloseProfits", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_YDISTANCE, cornerY + 120);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_XSIZE, 310);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_YSIZE, 35);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_BGCOLOR, profitBtn);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "FWC_CloseProfits", OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, "FWC_CloseProfits", OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, "FWC_CloseProfits", OBJPROP_TEXT, "✅ CLOSE PROFIT POSITIONS");
   
   // Tlačítko 3 - Zavřít ztráty
   ObjectCreate(0, "FWC_CloseLosses", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_XDISTANCE, cornerX + 15);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_YDISTANCE, cornerY + 160);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_XSIZE, 310);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_YSIZE, 35);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_BGCOLOR, lossBtn);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "FWC_CloseLosses", OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, "FWC_CloseLosses", OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, "FWC_CloseLosses", OBJPROP_TEXT, "❌ CLOSE LOSS POSITIONS");
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Dashboard Statistics                                        |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   int totalPositions = PositionsTotal();
   int totalOrders = OrdersTotal();
   int profitPositions = 0;
   int lossPositions = 0;
   double totalProfit = 0.0;
   
   // Počítání pozic
   for(int i = 0; i < totalPositions; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         totalProfit += profit;
         
         if(profit > 0)
            profitPositions++;
         else if(profit < 0)
            lossPositions++;
      }
   }
   
   string stats1 = StringFormat("Positions: %d | Pending: %d", totalPositions, totalOrders);
   string stats2 = StringFormat("Profit: %d | Loss: %d | Total P/L: %.2f %s", 
                                profitPositions, lossPositions, totalProfit, AccountInfoString(ACCOUNT_CURRENCY));
   
   ObjectSetString(0, "FWC_Stats1", OBJPROP_TEXT, stats1);
   ObjectSetString(0, "FWC_Stats2", OBJPROP_TEXT, stats2);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Delete All Pending Orders                                          |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
   int total = OrdersTotal();
   
   if(total == 0)
   {
      Comment("⚠️ No pending orders to delete");
      return;
   }
   
   string msg = StringFormat("Really delete %d pending orders?", total);
   int answer = MessageBox(msg, "⚠️ CONFIRMATION", MB_YESNO | MB_ICONWARNING);
   
   if(answer == IDNO)
   {
      Comment("❌ Operation cancelled");
      return;
   }
   
   int deleted = 0;
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(trade.OrderDelete(ticket))
            deleted++;
      }
   }
   
   string result = StringFormat("✓ Deleted %d pending orders", deleted);
   Comment(result);
   Print(result);
}

//+------------------------------------------------------------------+
//| Close All Profitable Positions                                     |
//+------------------------------------------------------------------+
void CloseAllProfitablePositions()
{
   int total = PositionsTotal();
   int profitCount = 0;
   
   // Počítání ziskových pozic
   for(int i = 0; i < total; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit > 0)
            profitCount++;
      }
   }
   
   if(profitCount == 0)
   {
      Comment("⚠️ No profit positions to close");
      return;
   }
   
   string msg = StringFormat("Really close %d profit positions?", profitCount);
   int answer = MessageBox(msg, "✅ CONFIRMATION", MB_YESNO | MB_ICONQUESTION);
   
   if(answer == IDNO)
   {
      Comment("❌ Operation cancelled");
      return;
   }
   
   int closed = 0;
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit > 0)
         {
            if(trade.PositionClose(ticket))
               closed++;
         }
      }
   }
   
   string result = StringFormat("✓ Closed %d profit positions", closed);
   Comment(result);
   Print(result);
}

//+------------------------------------------------------------------+
//| Close All Losing Positions                                         |
//+------------------------------------------------------------------+
void CloseAllLosingPositions()
{
   int total = PositionsTotal();
   int lossCount = 0;
   
   // Počítání ztrátových pozic
   for(int i = 0; i < total; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit < 0)
            lossCount++;
      }
   }
   
   if(lossCount == 0)
   {
      Comment("⚠️ No loss positions to close");
      return;
   }
   
   string msg = StringFormat("Really close %d loss positions?", lossCount);
   int answer = MessageBox(msg, "⚠️ WARNING", MB_YESNO | MB_ICONWARNING);
   
   if(answer == IDNO)
   {
      Comment("❌ Operation cancelled");
      return;
   }
   
   int closed = 0;
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit < 0)
         {
            if(trade.PositionClose(ticket))
               closed++;
         }
      }
   }
   
   string result = StringFormat("✓ Closed %d loss positions", closed);
   Comment(result);
   Print(result);
}
//+------------------------------------------------------------------+