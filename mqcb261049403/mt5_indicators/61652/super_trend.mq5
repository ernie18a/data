//+------------------------------------------------------------------+
//|                  SuperTrend Indicator for MetaTrader 5           |
//|               Fixed & Enhanced by BENALI (dahmi_benali)          |
//|                   https://www.mql5.com/en/users/dahmi_benali     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, BENALI"
#property link      "https://www.mql5.com/en/users/dahmi_benali"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2

//--- Plot settings
#property indicator_label1  "UpTrend"
#property indicator_label2  "DownTrend"
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_width1  2
#property indicator_width2  2

//--- Input parameters
input int     ATR_Period            = 10;      // ATR Period
input double  Multiplier            = 3.0;     // Multiplier for SuperTrend
input bool    ShowChartInfo         = true;    // Display trend info on chart
input color   InfoColor             = clrWhite;// Text color
input bool    EnablePushNotification= true;    // Enable mobile notification on trend change

//--- Buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double TrendBuffer[];
double ATRBuffer[];

//--- Internal variables
int atr_handle;
static int lastTrendDirection = 0;

//--- Chart label names
string trend_label_name     = "Trend_Label";
string trend_value_name     = "Trend_Value";
string trend_count_label    = "Trend_Count";

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, UpTrendBuffer,   INDICATOR_DATA);
   SetIndexBuffer(1, DownTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, TrendBuffer,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, ATRBuffer,       INDICATOR_CALCULATIONS);

   atr_handle = iATR(_Symbol, _Period, ATR_Period);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Failed to create ATR handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Helper: Convert TimeFrame to readable string                     |
//+------------------------------------------------------------------+
string TimeFrameToString(int period)
  {
   switch(period)
     {
      case PERIOD_M1:   return "M1";
      case PERIOD_M3:   return "M3";
      case PERIOD_M5:   return "M5";
      case PERIOD_M15:  return "M15";
      case PERIOD_M30:  return "M30";
      case PERIOD_H1:   return "H1";
      case PERIOD_H4:   return "H4";
      case PERIOD_D1:   return "D1";
      case PERIOD_W1:   return "W1";
      case PERIOD_MN1:  return "MN1";
      default:          return "Unknown";
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total < ATR_Period + 2)
      return(0);

   double close[], high[], low[];
   if(CopyClose(_Symbol, _Period, 0, rates_total, close) <= 0) return(0);
   if(CopyHigh(_Symbol, _Period, 0, rates_total, high) <= 0) return(0);
   if(CopyLow(_Symbol, _Period, 0, rates_total, low) <= 0) return(0);

   if(CopyBuffer(atr_handle, 0, 0, rates_total, ATRBuffer) <= 0)
      return(0);

   int start = (prev_calculated == 0) ? ATR_Period : prev_calculated - 1;

   // First bar initialization
   if(prev_calculated == 0)
     {
      int i = ATR_Period;
      double atr = ATRBuffer[i];
      double hl2 = (high[i] + low[i]) / 2.0;
      double upperBand = hl2 - Multiplier * atr;
      double lowerBand = hl2 + Multiplier * atr;

      TrendBuffer[i]      = (close[i] > hl2) ? 1 : -1;
      UpTrendBuffer[i]    = (TrendBuffer[i] == 1) ? upperBand : EMPTY_VALUE;
      DownTrendBuffer[i]  = (TrendBuffer[i] == -1) ? lowerBand : EMPTY_VALUE;
      start = i + 1;
     }

   // Main SuperTrend calculation
   for(int i = start; i < rates_total; i++)
     {
      if(ATRBuffer[i] == 0) continue;

      double atr = ATRBuffer[i];
      double hl2 = (high[i] + low[i]) / 2.0;

      double upperBand = hl2 - Multiplier * atr;
      double lowerBand = hl2 + Multiplier * atr;

      // Trailing logic
      if(TrendBuffer[i - 1] == 1 && close[i - 1] > UpTrendBuffer[i - 1])
         UpTrendBuffer[i] = MathMax(upperBand, UpTrendBuffer[i - 1]);
      else
         UpTrendBuffer[i] = upperBand;

      if(TrendBuffer[i - 1] == -1 && close[i - 1] < DownTrendBuffer[i - 1])
         DownTrendBuffer[i] = MathMin(lowerBand, DownTrendBuffer[i - 1]);
      else
         DownTrendBuffer[i] = lowerBand;

      // Trend reversal check
      if(TrendBuffer[i - 1] == 1 && close[i] < UpTrendBuffer[i - 1])
         TrendBuffer[i] = -1;
      else if(TrendBuffer[i - 1] == -1 && close[i] > DownTrendBuffer[i - 1])
         TrendBuffer[i] = 1;
      else
         TrendBuffer[i] = TrendBuffer[i - 1];

      // Clear opposite buffer
      UpTrendBuffer[i]   = (TrendBuffer[i] == 1)  ? UpTrendBuffer[i]   : EMPTY_VALUE;
      DownTrendBuffer[i] = (TrendBuffer[i] == -1) ? DownTrendBuffer[i] : EMPTY_VALUE;
     }

   // Push Notification on trend change
   if(EnablePushNotification && rates_total >= 3)
     {
      int current  = (int)TrendBuffer[rates_total - 1];
      int previous = (int)TrendBuffer[rates_total - 2];

      if(current != previous && current != lastTrendDirection)
        {
         string msg = StringFormat("SuperTrend - %s [%s]: %s",
                                   Symbol(),
                                   TimeFrameToString(Period()),
                                   (current == 1 ? "UP Trend Started" : "DOWN Trend Started"));

         SendNotification(msg);
         lastTrendDirection = current;
        }
     }

   // Display trend info on chart
   ShowTrendInfo(rates_total);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Remove chart objects on deinitialization                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectFind(0, trend_label_name)     != -1) ObjectDelete(0, trend_label_name);
   if(ObjectFind(0, trend_value_name)     != -1) ObjectDelete(0, trend_value_name);
   if(ObjectFind(0, trend_count_label)    != -1) ObjectDelete(0, trend_count_label);
  }

//+------------------------------------------------------------------+
//| Draw trend info as chart labels                                  |
//+------------------------------------------------------------------+
void ShowTrendInfo(int rates_total)
  {
   if(!ShowChartInfo || rates_total < 2)
      return;

   int last_index = rates_total - 1;
   int trend_dir = (int)TrendBuffer[last_index];

   string trend_word  = (trend_dir == 1) ? "UP" : "DOWN";
   color  trend_color = (trend_dir == 1) ? clrLime : clrRed;

   int trend_count = 1;
   for(int j = last_index - 1; j >= 0; j--)
     {
      if((int)TrendBuffer[j] == trend_dir)
         trend_count++;
      else
         break;
     }

   string bars_text = "Bars : " + IntegerToString(trend_count);

   // Label: "Trend :"
   if(ObjectFind(0, trend_label_name) == -1)
     {
      ObjectCreate(0, trend_label_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, trend_label_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, trend_label_name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, trend_label_name, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, trend_label_name, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, trend_label_name, OBJPROP_COLOR, InfoColor);
     }
   ObjectSetString(0, trend_label_name, OBJPROP_TEXT, "Trend :");

   // Label: Trend Direction
   if(ObjectFind(0, trend_value_name) == -1)
     {
      ObjectCreate(0, trend_value_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, trend_value_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, trend_value_name, OBJPROP_XDISTANCE, 60);
      ObjectSetInteger(0, trend_value_name, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, trend_value_name, OBJPROP_FONTSIZE, 12);
     }
   ObjectSetInteger(0, trend_value_name, OBJPROP_COLOR, trend_color);
   ObjectSetString(0, trend_value_name, OBJPROP_TEXT, trend_word);

   // Label: Trend Length
   if(ObjectFind(0, trend_count_label) == -1)
     {
      ObjectCreate(0, trend_count_label, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, trend_count_label, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, trend_count_label, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, trend_count_label, OBJPROP_YDISTANCE, 40);
      ObjectSetInteger(0, trend_count_label, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, trend_count_label, OBJPROP_COLOR, InfoColor);
     }
   ObjectSetString(0, trend_count_label, OBJPROP_TEXT, bars_text);
  }
//+------------------------------------------------------------------+
