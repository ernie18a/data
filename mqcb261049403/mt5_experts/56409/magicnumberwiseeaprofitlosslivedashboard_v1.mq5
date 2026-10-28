

#define CHART_MODE_LINE 2   // Use line chart mode

#property strict
#property version "1.00"

//--- Panel input parameters
input int PanelX      = 10;
input int PanelY      = 50;
input int PanelWidth  = 600;
input int PanelHeight = 350;
input int LineSpacing = 15;  // Vertical spacing between lines

// Global dynamic array for unique magic numbers
int magicNumbers[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Select full deal history
   if(!HistorySelect(0, LONG_MAX))
      Print("HistorySelect failed in OnInit - check your history settings!");

   // Create header label
   if(!ObjectCreate(0, "HeaderLabel", OBJ_LABEL, 0, 0, 0))
   {
      Print("Failed to create HeaderLabel");
      return INIT_FAILED;
   }
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_XDISTANCE, PanelX);
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_YDISTANCE, PanelY - 30);
   ObjectSetString(0, "HeaderLabel", OBJPROP_TEXT,
       "🚀 MAGIC-NUMBER-WISE-EA-LIVE-RESULTS DASHBOARD 🚀");
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_FONTSIZE, 18);
   ObjectSetString(0, "HeaderLabel", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_COLOR, clrGold);
   ObjectSetInteger(0, "HeaderLabel", OBJPROP_BACK, false);

   // Make chart black background, hide candles
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, 0, clrBlack);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, 0, clrBlack);
   ChartSetInteger(0, CHART_COLOR_GRID, 0, clrBlack);
   ChartSetInteger(0, CHART_MODE, 0, CHART_MODE_LINE);

   // Set timer for OnTimer() calls every 5 seconds
   EventSetTimer(5);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Kill the timer
   EventKillTimer();

   // Delete header/footer labels
   ObjectDelete(0, "HeaderLabel");
   ObjectDelete(0, "FooterLabel");

   // Delete any dynamic trade detail labels
   for(int i = 0; i < 999; i++)
   {
      string objName = "TradeDetails_" + IntegerToString(i);
      if(ObjectFind(0, objName) >= 0)
         ObjectDelete(0, objName);
   }
}

//+------------------------------------------------------------------+
//| BuildUniqueMagicNumbers: collects unique nonzero magic numbers   |
//+------------------------------------------------------------------+
void BuildUniqueMagicNumbers()
{
   ArrayResize(magicNumbers, 0);

   // From open positions
   int totalPos = PositionsTotal();
   for(int i = 0; i < totalPos; i++)
   {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
      {
         long pm = PositionGetInteger(POSITION_MAGIC);
         if(pm != 0)
         {
            int mg = (int)pm;
            bool found = false;
            for(int j = 0; j < ArraySize(magicNumbers); j++)
            {
               if(magicNumbers[j] == mg)
               {
                  found = true;
                  break;
               }
            }
            if(!found)
            {
               int sz = ArraySize(magicNumbers);
               ArrayResize(magicNumbers, sz + 1);
               magicNumbers[sz] = mg;
            }
         }
      }
   }

   // From closed deals
   int totalDeals = HistoryDealsTotal();
   for(int d = 0; d < totalDeals; d++)
   {
      ulong dealTicket = HistoryDealGetTicket(d);
      long dm = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      if(dm != 0)
      {
         int mg2 = (int)dm;
         bool found = false;
         for(int k = 0; k < ArraySize(magicNumbers); k++)
         {
            if(magicNumbers[k] == mg2)
            {
               found = true;
               break;
            }
         }
         if(!found)
         {
            int sz = ArraySize(magicNumbers);
            ArrayResize(magicNumbers, sz + 1);
            magicNumbers[sz] = mg2;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| OnTimer: Refresh panel every 5 seconds                           |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(!HistorySelect(0, LONG_MAX))
      Print("HistorySelect failed in OnTimer - no deals?");

   BuildUniqueMagicNumbers();

   // Build details lines (header plus one line per magic number)
   string details[];
   int detailCount = 0;
   ArrayResize(details, detailCount + 2);

   // Removed the Running P/L column in the header
   details[detailCount++] =
     "Magic # | #Deals |  Total P/L  | Symbol   | EA NAME                                         ";
   details[detailCount++] =
     "--------------------------------------------------------------------------------------------";

   int totalDeals = HistoryDealsTotal();
   int totalPos   = PositionsTotal();

   for(int i = 0; i < ArraySize(magicNumbers); i++)
   {
      int mg         = magicNumbers[i];
      int dealCount  = 0;
      double closedPL = 0.0;
      string comment  = "";
      string symbol   = "";

      // Process closed deals
      for(int d = 0; d < totalDeals; d++)
      {
         ulong dt = HistoryDealGetTicket(d);
         long dealMag = HistoryDealGetInteger(dt, DEAL_MAGIC);
         if((int)dealMag == mg)
         {
            dealCount++;
            closedPL += HistoryDealGetDouble(dt, DEAL_PROFIT)
                      + HistoryDealGetDouble(dt, DEAL_SWAP)
                      + HistoryDealGetDouble(dt, DEAL_COMMISSION);

            string dealComment = HistoryDealGetString(dt, DEAL_COMMENT);
            if(comment == "" && dealComment != "")
               comment = dealComment;

            if(symbol == "")
               symbol = HistoryDealGetString(dt, DEAL_SYMBOL);
         }
      }

      // Process open positions ONLY to get symbol/comment if needed
      for(int p = 0; p < totalPos; p++)
      {
         ulong pt = PositionGetTicket(p);
         if(PositionSelectByTicket(pt))
         {
            long posMag = PositionGetInteger(POSITION_MAGIC);
            if((int)posMag == mg)
            {
               // If no symbol found from closed deals, use the open position's symbol
               if(symbol == "")
                  symbol = PositionGetString(POSITION_SYMBOL);

               // If no comment found from closed deals, use position comment
               string posComment = PositionGetString(POSITION_COMMENT);
               if(comment == "" && posComment != "")
                  comment = posComment;
            }
         }
      }

      if(symbol == "")  symbol = "-";
      if(comment == "") comment = "-";

      // Format WITHOUT the Running P/L column
      // (Magic #, #Deals, Total P/L, Symbol, EA Name)
      // Using a wide format specifier for the EA name column => %-100s
      string line = StringFormat(
         "%7d | %6d | %11.2f | %-8s | %-100s",
         mg, dealCount, closedPL, symbol, comment
      );

      ArrayResize(details, detailCount + 1);
      details[detailCount++] = line;
   }

   // Delete old labels
   for(int iLabel = 0; iLabel < 999; iLabel++)
   {
      string oldName = "TradeDetails_" + IntegerToString(iLabel);
      if(ObjectFind(0, oldName) >= 0)
         ObjectDelete(0, oldName);
   }

   // Create one label per line (using OBJ_LABEL)
   for(int iLine = 0; iLine < detailCount; iLine++)
   {
      string objName = "TradeDetails_" + IntegerToString(iLine);
      if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
      {
         Print("Failed to create label for line ", iLine);
         continue;
      }
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, PanelX);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, PanelY + iLine * LineSpacing);

      // Large bounding box so text isn't clipped
      ObjectSetInteger(0, objName, OBJPROP_XSIZE, 5000); // 5000 px wide
      ObjectSetInteger(0, objName, OBJPROP_YSIZE, 20);   // single line
      ObjectSetInteger(0, objName, OBJPROP_ALIGN, ALIGN_LEFT);

      // Monospaced font helps keep columns aligned
      ObjectSetString(0, objName, OBJPROP_TEXT, details[iLine]);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, objName, OBJPROP_FONT, "Courier New");
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLime);
   }

   Print("Refresh Done");
}

//+------------------------------------------------------------------+
//| OnTick: No actions needed; OnTimer() does the updates            |
//+------------------------------------------------------------------+
void OnTick()
{
   // No actions on every tick
}
