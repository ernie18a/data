//+------------------------------------------------------------------+
//| SpreadMonitor.mq5                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Ali Kazim"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "On-chart panel that shows the current, average, minimum"
#property description "and maximum spread of the attached symbol, in points."

//--- input parameters
input int              InpSpreadLimit   = 30;                // Warning level (points)
input int              InpSampleSize    = 200;               // Samples kept in history
input int              InpUpdateSeconds = 1;                 // Panel refresh interval (seconds)
input ENUM_BASE_CORNER InpCorner        = CORNER_LEFT_UPPER;  // Panel corner
input int              InpPanelX        = 10;                // Horizontal offset (pixels)
input int              InpPanelY        = 20;                // Vertical offset (pixels)

//--- panel layout constants
const string PANEL_PREFIX = "SpreadMon_";
const int    PANEL_WIDTH  = 230;
const int    PANEL_HEIGHT = 150;
const int    ROW_SPACING  = 20;
const int    ROW_COUNT    = 6;
const int    FONT_SIZE    = 8;
const string FONT_NAME    = "Arial";

//--- rolling spread history
double   g_samples[];
int      g_sampleCount = 0;
int      g_sampleHead  = 0;
datetime g_lastUpdate  = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate input parameters before allocating anything
   if(InpSpreadLimit <= 0)
     {
      Print("Error: Warning level must be greater than 0. Current value: ", InpSpreadLimit);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpSampleSize < 10)
     {
      Print("Error: Sample size must be at least 10. Current value: ", InpSampleSize);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpUpdateSeconds < 1)
     {
      Print("Error: Refresh interval must be at least 1 second. Current value: ", InpUpdateSeconds);
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- allocate the rolling buffer and clear it, so every slot holds a known value
   if(ArrayResize(g_samples, InpSampleSize) != InpSampleSize)
     {
      Print("Error: ArrayResize failed for spread history. Error: ", GetLastError());
      return(INIT_FAILED);
     }
   if(ArrayInitialize(g_samples, 0.0) != InpSampleSize)
     {
      Print("Error: ArrayInitialize failed for spread history. Error: ", GetLastError());
      return(INIT_FAILED);
     }

//--- build the on-chart panel objects
   if(!CreatePanel())
     {
      Print("Error: CreatePanel failed. Error: ", GetLastError());
      return(INIT_FAILED);
     }

   Print("SpreadMonitor initialized on ", _Symbol, ". Warning level: ",
         InpSpreadLimit, " points.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove the panel so no objects stay on the chart after the EA is removed
   DeletePanel();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- throttle redraws to the configured interval, so the panel is not rebuilt on every tick
   datetime now = TimeCurrent();
   if(now - g_lastUpdate < InpUpdateSeconds)
      return;
   g_lastUpdate = now;

//--- read the live spread and store it in the history
   double current;
   if(!GetCurrentSpread(current))
      return;
   AddSample(current);

//--- compute statistics over the stored samples and redraw the panel
   double avg, minVal, maxVal;
   int    aboveCount;
   if(!ComputeStats(avg, minVal, maxVal, aboveCount))
      return;
   UpdatePanel(current, avg, minVal, maxVal, aboveCount);
  }

//+------------------------------------------------------------------+
//| Read the current spread of the attached symbol, in points        |
//+------------------------------------------------------------------+
bool GetCurrentSpread(double &spreadPoints)
  {
//--- clear the error state first, because a zero result is also a valid spread
   ResetLastError();
   long value = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(GetLastError() != 0)
     {
      Print("Error: SymbolInfoInteger(SYMBOL_SPREAD) failed. Error: ", GetLastError());
      return(false);
     }

   spreadPoints = (double)value;
   return(true);
  }

//+------------------------------------------------------------------+
//| Store one spread value in the rolling history buffer             |
//+------------------------------------------------------------------+
void AddSample(const double spreadPoints)
  {
//--- write the newest value, then move the write position and wrap at the end of the buffer
   g_samples[g_sampleHead] = spreadPoints;
   g_sampleHead = (g_sampleHead + 1) % InpSampleSize;

//--- the count stops growing once the buffer is full, because old values are overwritten
   if(g_sampleCount < InpSampleSize)
      g_sampleCount++;
  }

//+------------------------------------------------------------------+
//| Compute average, minimum, maximum and count above the limit      |
//+------------------------------------------------------------------+
bool ComputeStats(double &avg, double &minVal, double &maxVal, int &aboveCount)
  {
//--- no statistics are possible before the first sample
   if(g_sampleCount == 0)
      return(false);

   double sum = 0.0;
   minVal     = g_samples[0];
   maxVal     = g_samples[0];
   aboveCount = 0;

//--- only the first g_sampleCount slots hold real samples, the rest are still zero
   for(int i = 0; i < g_sampleCount; i++)
     {
      double v = g_samples[i];
      sum += v;
      if(v < minVal)
         minVal = v;
      if(v > maxVal)
         maxVal = v;
      if(v > InpSpreadLimit)
         aboveCount++;
     }

   avg = sum / g_sampleCount;
   return(true);
  }

//+------------------------------------------------------------------+
//| Create all panel objects, background first, then text rows       |
//+------------------------------------------------------------------+
bool CreatePanel()
  {
//--- remove any objects left from an earlier run, so names never clash
   DeletePanel();

   if(!CreateRectangle(PANEL_PREFIX + "bg", PANEL_WIDTH, PANEL_HEIGHT))
      return(false);

//--- row names from top to bottom, one label object per row
   string rows[6] = {"title", "current", "average", "range", "limit", "status"};
   for(int i = 0; i < ROW_COUNT; i++)
     {
      if(!CreateLabel(PANEL_PREFIX + rows[i], i))
         return(false);
     }

   ChartRedraw();
   return(true);
  }

//+------------------------------------------------------------------+
//| Create the background rectangle of the panel                     |
//+------------------------------------------------------------------+
bool CreateRectangle(const string name, const int width, const int height)
  {
   if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      Print("Error: ObjectCreate failed for ", name, ". Error: ", GetLastError());
      return(false);
     }

//--- dark background with a gold border, so the panel stands out on any chart colour
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrMidnightBlue);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGold);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   return(true);
  }

//+------------------------------------------------------------------+
//| Create one text label at the given row of the panel              |
//+------------------------------------------------------------------+
bool CreateLabel(const string name, const int row)
  {
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
     {
      Print("Error: ObjectCreate failed for ", name, ". Error: ", GetLastError());
      return(false);
     }

//--- rows are placed at a fixed spacing, offset from the panel edge by 10 pixels
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX + 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY + 10 + row * ROW_SPACING);
   ObjectSetString(0, name, OBJPROP_FONT, FONT_NAME);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   return(true);
  }

//+------------------------------------------------------------------+
//| Set the text and colour of one row                               |
//+------------------------------------------------------------------+
void SetRowText(const string rowName, const string text, const color textColor)
  {
   string name = PANEL_PREFIX + rowName;
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
  }

//+------------------------------------------------------------------+
//| Refresh every row of the panel with the latest statistics        |
//+------------------------------------------------------------------+
void UpdatePanel(const double current, const double avg, const double minVal,
                 const double maxVal, const int aboveCount)
  {
//--- status turns red when the current spread is above the warning level
   bool   high        = (current > InpSpreadLimit);
   color  statusColor = high ? clrRed : clrLime;
   string statusText  = high ? "Status: ABOVE LIMIT" : "Status: NORMAL";

   SetRowText("title", "Spread Monitor  " + _Symbol, clrGold);
   SetRowText("current", "Current: " + DoubleToString(current, 0) + " points", clrWhite);
   SetRowText("average", "Average: " + DoubleToString(avg, 1) + " points", clrWhite);
   SetRowText("range", "Min: " + DoubleToString(minVal, 0) +
              "   Max: " + DoubleToString(maxVal, 0), clrWhite);
   SetRowText("limit", "Above " + IntegerToString(InpSpreadLimit) + ": " +
              IntegerToString(aboveCount) + " of " + IntegerToString(g_sampleCount), clrWhite);
   SetRowText("status", statusText, statusColor);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Delete every panel object created by this EA                     |
//+------------------------------------------------------------------+
void DeletePanel()
  {
//--- loop backwards, so deleting an object does not shift the indexes still to be checked
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, PANEL_PREFIX) == 0)
         ObjectDelete(0, name);
     }
  }
