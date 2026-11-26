//+------------------------------------------------------------------+
//|                                                   ServerTime.mq5 |
//|                                        Copyright 2025, Your Name |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input bool ShowDailyChange = true;        // Display daily variation
input int FontSize = 12;                  // Font size
input color TextColor = clrRed;         // Text color

//--- global variables
string obj_name = "ServerTimeLabel";
string obj_name_daily = "DailyChangeLabel";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create text label for server time
   if(!ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0))
   {
      Print("Failed to create server time label: ", GetLastError());
      return(INIT_FAILED);
   }
   
   // Set properties for server time label
   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 250);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, 10);
   ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, TextColor);
   ObjectSetString(0, obj_name, OBJPROP_FONT, "Arial");
   
   // Create text label for daily change if enabled
   if(ShowDailyChange)
   {
      if(!ObjectCreate(0, obj_name_daily, OBJ_LABEL, 0, 0, 0))
      {
         Print("Failed to create daily change label: ", GetLastError());
         return(INIT_FAILED);
      }
      
      // Set properties for daily change label
      ObjectSetInteger(0, obj_name_daily, OBJPROP_XDISTANCE, 250);
      ObjectSetInteger(0, obj_name_daily, OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, obj_name_daily, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, obj_name_daily, OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, obj_name_daily, OBJPROP_COLOR, TextColor);
      ObjectSetString(0, obj_name_daily, OBJPROP_FONT, "Arial");
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, obj_name);
   if(ShowDailyChange) ObjectDelete(0, obj_name_daily);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   // Update server time
   string server_time = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, "Server Time: " + server_time);
   
   // Update daily change if enabled
   if(ShowDailyChange)
   {
      double close_price = close[rates_total-1];
      double open_price = iOpen(Symbol(), PERIOD_D1, 0);
      double change = ((close_price - open_price) / open_price) * 100;
      string change_text = StringFormat("Daily Change: %.2f%%", change);
      ObjectSetString(0, obj_name_daily, OBJPROP_TEXT, change_text);
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                    |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Update time every second to reduce CPU usage
   EventSetTimer(1);
   string server_time = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, "Server Time: " + server_time);
}
//+------------------------------------------------------------------+