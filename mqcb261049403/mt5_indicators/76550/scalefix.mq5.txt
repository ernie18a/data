//+------------------------------------------------------------------+
//|                                            ScaleFixAutoReset.mq5 |
//|                                                                  |
//|  Enables CHART_SCALEFIX on init. Adds an "AUTO" button that      |
//|  resets the chart to its original visible price range by         |
//|  toggling scale fix off and on again.                            |
//+------------------------------------------------------------------+
#property copyright "Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- Button parameters
#define BTN_NAME       "btnAutoReset"
#define BTN_WIDTH      60
#define BTN_HEIGHT     25
#define BTN_MARGIN_X   20
#define BTN_MARGIN_Y   40

//--- Store original chart scale (zoom level 0-5)
int g_originalScale;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Save original chart scale (zoom)
   g_originalScale = (int)ChartGetInteger(0, CHART_SCALE);

   //--- Enable scale fix
   ChartSetInteger(0, CHART_SCALEFIX, true);

   //--- Create AUTO button
   CreateAutoButton();

   //--- Enable chart events
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   ChartRedraw(0);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Restore original state
   ChartSetInteger(0, CHART_SCALEFIX, false);
   ChartSetInteger(0, CHART_SCALE, g_originalScale);

   //--- Delete button
   ObjectDelete(0, BTN_NAME);

   ChartRedraw(0);
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
   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   //--- Handle button click
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == BTN_NAME)
      {
         //--- Reset chart to auto-fit
         ResetChartScale();

         //--- Unpress the button
         ObjectSetInteger(0, BTN_NAME, OBJPROP_STATE, false);
         ChartRedraw(0);
      }
   }

   //--- Handle chart resize - reposition button
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      RepositionButton();
      ChartRedraw(0);
   }
}

//+------------------------------------------------------------------+
//| Create the AUTO button in bottom-right corner                    |
//+------------------------------------------------------------------+
void CreateAutoButton()
{
   //--- Delete if exists
   ObjectDelete(0, BTN_NAME);

   //--- Get chart dimensions
   int chartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   //--- Calculate position (bottom-right)
   int xPos = chartWidth  - BTN_WIDTH  - BTN_MARGIN_X;
   int yPos = chartHeight - BTN_HEIGHT - BTN_MARGIN_Y;

   //--- Create button
   ObjectCreate(0, BTN_NAME, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_YDISTANCE, yPos);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_XSIZE, BTN_WIDTH);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_YSIZE, BTN_HEIGHT);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, BTN_NAME, OBJPROP_TEXT, "AUTO");
   ObjectSetString(0, BTN_NAME, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, BTN_NAME, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_BGCOLOR, clrDodgerBlue);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_BORDER_COLOR, clrRoyalBlue);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_STATE, false);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_ZORDER, 100);
}

//+------------------------------------------------------------------+
//| Reposition button on chart resize                                |
//+------------------------------------------------------------------+
void RepositionButton()
{
   int chartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   int xPos = chartWidth  - BTN_WIDTH  - BTN_MARGIN_X;
   int yPos = chartHeight - BTN_HEIGHT - BTN_MARGIN_Y;

   ObjectSetInteger(0, BTN_NAME, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0, BTN_NAME, OBJPROP_YDISTANCE, yPos);
}

//+------------------------------------------------------------------+
//| Calculate high and low of visible bars on chart                  |
//+------------------------------------------------------------------+
bool GetVisibleHighLow(double &visHigh, double &visLow)
{
   //--- Get first visible bar and number of visible bars
   int firstVisible = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int visibleBars  = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);

   //--- The first visible bar index is the leftmost bar on screen
   //    In MQL5 chart, CHART_FIRST_VISIBLE_BAR is the index of the
   //    leftmost bar (counted from current bar 0 to the right).
   //    So visible bars go from index firstVisible down to
   //    firstVisible - visibleBars + 1.

   int barFrom = firstVisible;
   int barTo   = firstVisible - visibleBars + 1;
   if(barTo < 0) barTo = 0;

   //--- Total bars available
   int totalBars = Bars(_Symbol, _Period);
   if(totalBars <= 0) return false;
   if(barFrom >= totalBars) barFrom = totalBars - 1;

   //--- Number of bars to copy
   int count = barFrom - barTo + 1;
   if(count <= 0) return false;

   //--- Copy high and low arrays for visible bars
   double highArr[];
   double lowArr[];

   //--- CopyHigh/CopyLow: start_pos = barTo (closest to current), count = count
   if(CopyHigh(_Symbol, _Period, barTo, count, highArr) <= 0) return false;
   if(CopyLow(_Symbol, _Period, barTo, count, lowArr) <= 0)  return false;

   //--- Find max high and min low
   visHigh = highArr[0];
   visLow  = lowArr[0];

   for(int i = 1; i < ArraySize(highArr); i++)
   {
      if(highArr[i] > visHigh) visHigh = highArr[i];
   }
   for(int i = 1; i < ArraySize(lowArr); i++)
   {
      if(lowArr[i] < visLow) visLow = lowArr[i];
   }

   return true;
}

//+------------------------------------------------------------------+
//| Reset chart scale to auto-fit visible bars                       |
//+------------------------------------------------------------------+
void ResetChartScale()
{
   //--- Restore original zoom level first
   ChartSetInteger(0, CHART_SCALE, g_originalScale);

   //--- Turn off scale fix so chart redraws with new zoom
   ChartSetInteger(0, CHART_SCALEFIX, false);
   ChartRedraw(0);

   //--- We need to let the chart update internally after zoom change
   //    Use a small sleep then recalculate from actual bar data
   Sleep(100);

   //--- Now manually calculate the high/low of all visible bars
   double visHigh = 0, visLow = 0;

   if(GetVisibleHighLow(visHigh, visLow))
   {
      //--- Add padding (~5% of range on each side)
      double range   = visHigh - visLow;
      double padding = range * 0.05;
      if(padding < _Point * 10) padding = _Point * 10; // minimum padding

      double fixMax = visHigh + padding;
      double fixMin = visLow  - padding;

      //--- Apply fixed range and re-enable scale fix
      ChartSetDouble(0, CHART_FIXED_MAX, fixMax);
      ChartSetDouble(0, CHART_FIXED_MIN, fixMin);
      ChartSetInteger(0, CHART_SCALEFIX, true);
   }
   else
   {
      //--- Fallback: just re-enable scale fix with whatever chart shows
      ChartSetInteger(0, CHART_SCALEFIX, true);
   }

   ChartRedraw(0);
}
//+------------------------------------------------------------------+