//+------------------------------------------------------------------+
//|                                           MT5 Memory Monitor.mq5 |
//|                                             © 2026, ChukwuBuikem |
//|                             https://www.mql5.com/en/users/bikeen |
//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include <ChartObjects\ChartObjectsTxtControls.mqh>

#define PROG_NAME "MT5 Memory Monitor"
#define OUTER_PANEL PROG_NAME + "_OuterPanel"
#define INNER_PANEL PROG_NAME + "_InnerPanel"
#define MAIN_HEADER PROG_NAME + "_Header"
#define LINE_SEPARATOR PROG_NAME + "_Separator"
#define BUTTON_CANCEL PROG_NAME + "_ButtonCancel"
#define RECT_INNER PROG_NAME + "_RectInner"
#define RECT_OUTER PROG_NAME + "_RectOuter"
#define LABEL_PERCENT PROG_NAME + "_LabelPercent"
#define LABEL_USED PROG_NAME + "_LabelUsed"
#define LABEL_AVAILABLE PROG_NAME + "_LabelAvailable"
#define LABEL_TOTAL PROG_NAME + "_LabelTotal"
#define LABEL_INDICATORS PROG_NAME + "_IndicatorTotal"
#define LABEL_WINDOWS PROG_NAME + "_WindowsTotal"

struct st_MemoryStatus
  {
   int               total;
   int               used;
   int               available;
   double               percent;
   int               indicators;
   int               objects;
   int               chartWindows;

   void              getStatus();
  } memory;

CChartObjectRectLabel rectLabel;
CChartObjectLabel label;
CChartObjectButton button;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   IndicatorSetString(INDICATOR_SHORTNAME, PROG_NAME);
   EventSetTimer(5);//--- SET A 5-SECOND TIMMER
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason)
  {
//---
   ChartSetInteger(ChartID(), CHART_SHOW_ONE_CLICK, true);
   ObjectsDeleteAll(0, PROG_NAME);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//--- NO LOGIC REQUIRED
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- UPDATE PANEL EVERY 5 SECONDS
   memory.getStatus();
   showDashboard(memory);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int32_t id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- BUTTON CLICK
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON_CANCEL)
     {
      Print("Cancel button clicked");
      ChartIndicatorDelete(0, 0, PROG_NAME);
      return;
     }
//--- CHART CHANGE: INITIALIZATION, MORE INDICATOR ATTACHMENT
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      memory.getStatus();
      showDashboard(memory);
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void st_MemoryStatus::getStatus(void)
  {
//--- GET MEMORY INFORMATION
   used = TerminalInfoInteger(TERMINAL_MEMORY_USED);
   available = TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE);
   total = TerminalInfoInteger(TERMINAL_MEMORY_TOTAL);
   percent = NormalizeDouble(((double)used / total * 100), 1);
   indicators = 0;
   objects = ObjectsTotal(ChartID());
   chartWindows = (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL);
//--- GET NUMBER OF INDICATORS
   for(int w = 0; w < chartWindows; w++)
      indicators += ChartIndicatorsTotal(ChartID(), w);
  }
//+------------------------------------------------------------------+
//|        Function to create rectangle labels                       |
//+------------------------------------------------------------------+
bool createRectLabel(const string objName, const int xDistance, const int yDistance,
                     const int xSize, const int ySize, const color clr, int borderWidth,
                     const color borderColor  = clrNONE)
  {
//---
   if(rectLabel.Create(ChartID(), objName, 0, 0, 0, 0, 0))
     {
      rectLabel.X_Distance(xDistance);
      rectLabel.Y_Distance(yDistance);
      rectLabel.X_Size(xSize);
      rectLabel.Y_Size(ySize);
      rectLabel.BackColor(clr);
      rectLabel.SetInteger(OBJPROP_BORDER_COLOR, borderColor);
      rectLabel.BorderType(BORDER_FLAT);
      rectLabel.Style(STYLE_SOLID);
      rectLabel.Corner(CORNER_LEFT_UPPER);
      rectLabel.SetInteger(OBJPROP_HIDDEN, true);
      rectLabel.Tooltip("\n");

      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|        Function to create  labels                                |
//+------------------------------------------------------------------+
bool createLabel(const string objName, const int xDistance, const int yDistance,
                 const color clr, const string display, const int fontSize = 15)
  {
//---
   if(label.Create(ChartID(), objName, 0, 0, 0))
     {
      label.X_Distance(xDistance);
      label.Y_Distance(yDistance);
      label.Color(clr);
      label.Tooltip("\n");
      label.SetString(OBJPROP_TEXT, display);
      label.FontSize(fontSize);
      label.Font("Arial Bold");
      label.SetInteger(OBJPROP_HIDDEN, true);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|        Function to create clickable button                       |
//+------------------------------------------------------------------+
bool createButton(const string objName, const int xDistance, const int yDistance,
                  const int xSize, const int ySize, const color backColor, const color borderColor,
                  const string display, const int fontSize, const string toolTip)
  {
//---
   if(button.Create(ChartID(), objName, 0, 0, 0, 0, 0))
     {
      button.X_Distance(xDistance);
      button.Y_Distance(yDistance);
      button.X_Size(xSize);
      button.Y_Size(ySize);
      button.BackColor(backColor);
      button.SetString(OBJPROP_TEXT, display);
      button.Color(clrWhite);
      button.BorderColor(borderColor);
      button.State(false);
      button.Selectable(false);
      button.FontSize(fontSize);
      button.Tooltip(toolTip);
      button.SetInteger(OBJPROP_HIDDEN, true);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showDashboard(st_MemoryStatus &status)
  {
//---
   int barWidth = 200;
   ChartSetInteger(ChartID(), CHART_SHOW_ONE_CLICK, false);
   createRectLabel(OUTER_PANEL, 20, 30, 300, 300, clrBlack, 1);
   createLabel(MAIN_HEADER, 40, 50, clrGoldenrod, "MT5 MEMORY MONITOR", 13);
   createButton(BUTTON_CANCEL, 270, 50, 20, 20, clrBlack, clrWhiteSmoke, "×", 13, "Cancel Button");
   createLabel(LINE_SEPARATOR + "1", 40, 80, clrGray, "_____________________________________", 10);
   createRectLabel(RECT_INNER, 40, 120, barWidth, 20, clrGray, 1, clrGray);
   int filledWidth = (int)(barWidth * status.percent / 100);
   createRectLabel(RECT_OUTER, 40, 120, filledWidth, 20, clrWhite, 1, clrGray);
   createLabel(LABEL_PERCENT, 250, 122, clrWhite, DoubleToString(status.percent, 1) + " %", 13);
   createLabel(LABEL_TOTAL, 40, 160, clrWhiteSmoke, "Total :", 12);
   createLabel(LABEL_TOTAL + "Value", 130, 160, clrWhiteSmoke, IntegerToString(status.total) + " MB", 12);
   createLabel(LABEL_AVAILABLE, 40, 190, clrWhiteSmoke, "Available :", 12);
   createLabel(LABEL_AVAILABLE + "Value", 130, 190, clrWhiteSmoke, IntegerToString(status.available) + " MB", 12);
   createLabel(LABEL_USED, 40, 220, clrWhiteSmoke, "Used :", 12);
   createLabel(LABEL_USED + "Value", 130, 220, clrWhiteSmoke, IntegerToString(status.used) + " MB", 12);
   createLabel(LINE_SEPARATOR + "2", 40, 235, clrGray, "_____________________________________", 10);
   createLabel(LABEL_INDICATORS, 40, 265, clrWhiteSmoke, "Indicators :", 12);
   createLabel(LABEL_INDICATORS + "Value", 130, 265, clrWhiteSmoke, IntegerToString(status.indicators), 12);
   createLabel(LABEL_WINDOWS, 40, 295, clrWhiteSmoke, "Chart Windows :", 12);
   createLabel(LABEL_WINDOWS + "Value", 180, 295, clrWhiteSmoke, IntegerToString(status.chartWindows), 12);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
