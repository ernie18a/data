//+------------------------------------------------------------------+
//|                                           DailyLotStatistics.mq5 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Daily Lot Statistics"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

// Input parameters
input int InpDaysToShow = 7;                    // Days to display
input color InpHeaderBgColor = C'0,120,215';    // Header background color (Cyan)
input color InpHeaderTextColor = clrWhite;      // Header text color
input color InpColumnBgColor = C'50,50,60';     // Column header background color
input color InpColumnTextColor = clrLightGray;  // Column text color
input color InpTextColor = clrWhiteSmoke;       // Data text color
input color InpProfitColor = clrLime;           // Positive profit color
input color InpLossColor = clrRed;              // Negative profit color
input color InpTotalBgColor = C'60,60,70';      // Total row background color
input color InpTotalColor = clrYellow;          // Total row text color
input color InpPanelBgColor = C'20,25,30';      // Panel background color
input int InpHeaderFontSize = 11;               // Header font size
input int InpDataFontSize = 10;                 // Data font size
input int InpCornerX = 20;                      // Distance from left
input int InpCornerY = 50;                      // Distance from top
input int InpPanelWidth = 500;                  // Panel width

struct DayStats
{
   datetime date;
   double totalLots;
   int totalOrders;
   double totalProfit;
};

DayStats dailyStats[];
string objPrefix = "DLS_";

// Variables to store all-time totals
double g_allTimeLots = 0;
int g_allTimeOrders = 0;
double g_allTimeProfit = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Daily Lot Stats");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   CollectStatistics();
   DrawStatistics();
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Collect trading statistics                                        |
//+------------------------------------------------------------------+
void CollectStatistics()
{
   ArrayResize(dailyStats, 0);
   
   // Reset all-time totals
   g_allTimeLots = 0;
   g_allTimeOrders = 0;
   g_allTimeProfit = 0;
   
   HistorySelect(0, TimeCurrent());
   int totalDeals = HistoryDealsTotal();
   
   for(int i = 0; i < totalDeals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket <= 0) continue;
      
      // Only take OUT deals (closed) to avoid double counting
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT) continue;
      
      // Get deal time (server time)
      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      
      // Normalize to 00:00:00 server time
      MqlDateTime dt;
      TimeToStruct(dealTime, dt);
      dt.hour = 0;
      dt.min = 0;
      dt.sec = 0;
      datetime dayStart = StructToTime(dt);
      
      double lots = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) + 
                     HistoryDealGetDouble(ticket, DEAL_SWAP) + 
                     HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      
      bool isBuy = (dealType == DEAL_TYPE_BUY);
      bool isSell = (dealType == DEAL_TYPE_SELL);
      
      if(!isBuy && !isSell) continue;
      
      // Add to all-time totals
      g_allTimeLots += lots;
      g_allTimeOrders++;
      g_allTimeProfit += profit;
      
      // Find or create day in array
      int idx = FindOrCreateDay(dayStart);
      
      dailyStats[idx].totalLots += lots;
      dailyStats[idx].totalOrders++;
      dailyStats[idx].totalProfit += profit;
   }
   
   // Sort by date descending
   SortStatsByDate();
   
   // Limit displayed days
   if(ArraySize(dailyStats) > InpDaysToShow)
      ArrayResize(dailyStats, InpDaysToShow);
}

//+------------------------------------------------------------------+
//| Find or create day in array                                      |
//+------------------------------------------------------------------+
int FindOrCreateDay(datetime dayStart)
{
   int size = ArraySize(dailyStats);
   
   for(int i = 0; i < size; i++)
   {
      if(dailyStats[i].date == dayStart)
         return i;
   }
   
   ArrayResize(dailyStats, size + 1);
   dailyStats[size].date = dayStart;
   dailyStats[size].totalLots = 0;
   dailyStats[size].totalOrders = 0;
   dailyStats[size].totalProfit = 0;
   
   return size;
}

//+------------------------------------------------------------------+
//| Sort statistics by date descending                               |
//+------------------------------------------------------------------+
void SortStatsByDate()
{
   int size = ArraySize(dailyStats);
   for(int i = 0; i < size - 1; i++)
   {
      for(int j = i + 1; j < size; j++)
      {
         if(dailyStats[i].date < dailyStats[j].date)
         {
            DayStats temp = dailyStats[i];
            dailyStats[i] = dailyStats[j];
            dailyStats[j] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Format number with comma separator                               |
//+------------------------------------------------------------------+
string FormatNumber(double num)
{
   string str = DoubleToString(MathAbs(num), 0);
   string result = "";
   int len = StringLen(str);
   
   for(int i = 0; i < len; i++)
   {
      if(i > 0 && (len - i) % 3 == 0)
         result += ",";
      result += StringSubstr(str, i, 1);
   }
   
   if(num < 0) result = "-" + result;
   return result;
}

//+------------------------------------------------------------------+
//| Draw statistics on chart - FLAT MODERN STYLE                    |
//+------------------------------------------------------------------+
void DrawStatistics()
{
   DeleteAllObjects();
   
   int startX = InpCornerX;
   int startY = InpCornerY;
   int panelWidth = InpPanelWidth;
   
   int currentY = startY;
   
   // ==================== PANEL BACKGROUND ====================
   CreateRectangle(objPrefix + "panel_bg", startX, startY, panelWidth, 0, InpPanelBgColor);
   
   // ==================== HEADER ====================
   int headerHeight = 42;
   CreateRectangle(objPrefix + "header_bg", startX, currentY, panelWidth, headerHeight, InpHeaderBgColor);
   CreateLabel(objPrefix + "header_text", startX + 15, currentY + 10, 
               "DAILY LOT TRADING STATISTICS (7 DAYS)", 
               InpHeaderTextColor, InpHeaderFontSize, "Arial Bold");
   currentY += headerHeight + 5;
   
   // ==================== COLUMN HEADER ====================
   int colHeaderHeight = 30;
   CreateRectangle(objPrefix + "col_bg", startX, currentY, panelWidth, colHeaderHeight, InpColumnBgColor);
   
   string colHeader = StringFormat("  %-12s  %6s  %5s  %12s", "Date", "Lots", "Orders", "P/L ($)");
   CreateLabel(objPrefix + "col_text", startX + 15, currentY + 8, 
               colHeader, InpColumnTextColor, InpDataFontSize, "Consolas");
   currentY += colHeaderHeight + 5;
   
   // ==================== DATA ROWS ====================
   int rowHeight = 27;
   int size = ArraySize(dailyStats);
   
   for(int i = 0; i < size; i++)
   {
      // Format date
      MqlDateTime dtDisplay;
      TimeToStruct(dailyStats[i].date, dtDisplay);
      string dateStr = StringFormat("%04d.%02d.%02d", dtDisplay.year, dtDisplay.mon, dtDisplay.day);
      
      // Select color
      color rowColor = dailyStats[i].totalProfit >= 0 ? InpProfitColor : InpLossColor;
      
      // Format profit with comma separator
      string profitStr = FormatNumber(dailyStats[i].totalProfit);
      
      // Create text row
      string dataRow = StringFormat("  %-12s  %6.0f  %5d  %12s", 
                                    dateStr, 
                                    dailyStats[i].totalLots, 
                                    dailyStats[i].totalOrders, 
                                    profitStr);
      
      CreateLabel(objPrefix + "data_" + IntegerToString(i), startX + 15, currentY + 4, 
                  dataRow, rowColor, InpDataFontSize, "Consolas");
      
      currentY += rowHeight;
   }
   
   currentY += 5;
   
   // ==================== TOTAL ROW ====================
   int totalHeight = 38;
   CreateRectangle(objPrefix + "total_bg", startX, currentY, panelWidth, totalHeight, InpTotalBgColor);
   
   color totalColor = g_allTimeProfit >= 0 ? InpTotalColor : InpLossColor;
   string totalProfitStr = FormatNumber(g_allTimeProfit);
   
   string totalRow = StringFormat("  %-12s  %6.0f  %5d  %12s", 
                                  "TOTAL", 
                                  g_allTimeLots, 
                                  g_allTimeOrders, 
                                  totalProfitStr);
   
   CreateLabel(objPrefix + "total_text", startX + 15, currentY + 10, 
               totalRow, totalColor, InpDataFontSize, "Consolas Bold");
   
   currentY += totalHeight;
   
   // Update panel background height
   int totalPanelHeight = currentY - startY;
   ObjectSetInteger(0, objPrefix + "panel_bg", OBJPROP_YSIZE, totalPanelHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create rectangle background                                       |
//+------------------------------------------------------------------+
void CreateRectangle(string name, int x, int y, int width, int height, color bgColor)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
}

//+------------------------------------------------------------------+
//| Create text label                                                |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int fontSize, string font = "Arial")
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
}
//+------------------------------------------------------------------+
//| Delete all indicator objects                                     |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, objPrefix) == 0)
         ObjectDelete(0, name);
   }
}

//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllObjects();
   ChartRedraw();
}
//+------------------------------------------------------------------+