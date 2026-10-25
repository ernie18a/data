//+------------------------------------------------------------------+
//|                                    Draw Of Liquidity ( DOL ).mq5 |
//|                                Copyright @ 2025, TradingLabs ID. |
//|                           https://www.tiktok.com/@cakndutproject |
//+------------------------------------------------------------------+
#property copyright "Copyright @ 2025, TradingLabs ID."
#property link      "https://www.mql5.com/en/users/suhendrawan/seller"
#property version   "2.5" 
#property description "Charting Tools Draw On Liquidity ( DOL )."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input group "Charting Tools Information"
input string  Tools                  = "Draw On Liquidity ( DOL )"; // Indicator Name
input string  Company                = "Copyright @ 2025 - TradingLabs ID"; // Developer
input string  MoreIndicatorsLink = "https://www.mql5.com/en/users/suhendrawan/seller"; // More Free Indicator & EA Link

//--- Input Parameters ---
input group "Daily/Weekly Levels"
input bool   InpShowPDHL = true; // Show Previous Daily High Low ?
input color  InpPDHColor = clrHotPink; // PDH Color
input color  InpPDLColor = clrDodgerBlue; // PDL Color
input bool   InpShowPWHL = true; // Show Previous Weekly High Low ?
input color  InpPWHColor = clrRed; // PWH Color
input color  InpPWLColor = clrBlue; // PWL Color

input group "Static Line Settings (PDHL/PWHL)"
input ENUM_LINE_STYLE InpStaticLineStyle = STYLE_SOLID; // Line style for PDHL/PWHL
input int    InpStaticLineWidth   = 1; // Line width for PDHL/PWHL
input int    InpLineExtensionBars = 12;

input group "PDHL/PWHL Text Settings"
input color  InpTextColor         = clrDimGray; // Text Color PDHL/PWHL
input int    InpTextFontSize      = 8; // Text size for PDHL/PWHL

input group "Liquidity Sessions (Broker Server Time)"
input bool   InpShowSessions      = false; // Show Kill Zone Sessions ?
input int    InpSessionDaysToShow = 1; // Days to show

input group "Session Box Customization"
input bool   InpFillSessionBox    = true; // Fill Box Background ?
input bool   InpDrawSessionBorder = true; // Draw Box Border ?
input ENUM_LINE_STYLE InpSessionBorderStyle = STYLE_SOLID; // Border Line Style
input int    InpSessionBorderWidth= 1; // Border Line Width

input group "Tokyo Session"
input color  InpTokyoBorderColor  = clrDarkOrange; // Asia Border Color
input color  InpTokyoFillColor    = clrBisque; // Asia Fill Color (Lebih Muda)
input int    InpTokyoStartHour    = 2; // Asia Start Hour
input int    InpTokyoEndHour      = 7; // Asia End Hour

input group "London Session"
input color  InpLondonBorderColor = clrSeaGreen; // London Border Color
input color  InpLondonFillColor   = clrPaleGreen; // London Fill Color (Lebih Muda)
input int    InpLondonStartHour   = 9; // London Start Hour
input int    InpLondonEndHour     = 11; // London End Hour

input group "New York Session"
input color  InpNewYorkBorderColor= clrDarkViolet; // NewYork Border Color
input color  InpNewYorkFillColor  = clrThistle; // NewYork Fill Color (Lebih Muda)
input int    InpNewYorkStartHour  = 14; // NewYork Start Hour
input int    InpNewYorkEndHour    = 16; // NewYork End Hour

struct MarketSession
{
   string   name;
   color    border_color;
   color    fill_color;
   int      start_hour;
   int      end_hour;
   double   high;
   double   low;
};

//--- Variabel Global ---
string         g_obj_prefix;
double         g_pdh = 0, g_pdl = 0, g_pwh = 0, g_pwl = 0;
datetime       g_pd_time = 0, g_pw_time = 0;
datetime       g_last_update_time_d1 = 0;
datetime       g_last_update_time_w1 = 0;
datetime       g_last_calc_bar_time = 0;

void UpdateLevels();
void ProcessAndDrawSessionsForDay(int days_ago);
void DrawStaticLines(datetime current_bar_time);
void DrawOneStaticLine(string name_prefix, datetime time_start, double price_level, color line_color, string label_text, datetime current_bar_time);
void DeleteAllIndicatorObjects();

//+------------------------------------------------------------------+
int OnInit()
{
   g_obj_prefix = "IndicatorLevels_" + IntegerToString(ChartID()) + "_";
   IndicatorSetString(INDICATOR_SHORTNAME, "Levels/Sessions v2.3");
   g_last_calc_bar_time = 0;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllIndicatorObjects();
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   if(rates_total < 2) return 0;
   datetime current_bar_time = time[rates_total - 1];

   if(current_bar_time == g_last_calc_bar_time && prev_calculated > 0)
      return rates_total;

   DeleteAllIndicatorObjects();
   
   UpdateLevels();
   DrawStaticLines(current_bar_time);

   if(InpShowSessions && PeriodSeconds(_Period) <= 3600)
   {
      for(int d = 0; d < InpSessionDaysToShow; d++)
      {
         ProcessAndDrawSessionsForDay(d);
      }
   }

   g_last_calc_bar_time = current_bar_time;
   ChartRedraw();
   return rates_total;
}
//+------------------------------------------------------------------+
void UpdateLevels()
{
   if(InpShowPDHL)
   {
      MqlRates daily_rates[];
      if(CopyRates(_Symbol, PERIOD_D1, 1, 1, daily_rates) > 0)
         if(daily_rates[0].time != g_last_update_time_d1)
         {
            g_pdh = daily_rates[0].high; g_pdl = daily_rates[0].low;
            g_pd_time = daily_rates[0].time; g_last_update_time_d1 = daily_rates[0].time;
         }
   }
   if(InpShowPWHL)
   {
      MqlRates weekly_rates[];
      if(CopyRates(_Symbol, PERIOD_W1, 1, 1, weekly_rates) > 0)
         if(weekly_rates[0].time != g_last_update_time_w1)
         {
            g_pwh = weekly_rates[0].high; g_pwl = weekly_rates[0].low;
            g_pw_time = weekly_rates[0].time; g_last_update_time_w1 = weekly_rates[0].time;
         }
   }
}
//+------------------------------------------------------------------+
void ProcessAndDrawSessionsForDay(int days_ago)
{
   MqlDateTime today_struct;
   TimeToStruct((datetime)TimeCurrent(), today_struct);
   today_struct.hour = 0; today_struct.min = 0; today_struct.sec = 0;
   datetime target_day_start = StructToTime(today_struct) - (days_ago * 86400);
   datetime target_day_end = target_day_start + 86400;

   MarketSession sessions[3];
   // Tokyo
   sessions[0].name = "Asian Range";
   sessions[0].border_color = InpTokyoBorderColor;
   sessions[0].fill_color = InpTokyoFillColor;
   sessions[0].start_hour = InpTokyoStartHour;
   sessions[0].end_hour = InpTokyoEndHour;
   sessions[0].high = 0;
   sessions[0].low = 1e10;
   // London
   sessions[1].name = "London KZ";
   sessions[1].border_color = InpLondonBorderColor;
   sessions[1].fill_color = InpLondonFillColor;
   sessions[1].start_hour = InpLondonStartHour;
   sessions[1].end_hour = InpLondonEndHour;
   sessions[1].high = 0;
   sessions[1].low = 1e10;
   // New York
   sessions[2].name = "NewYork KZ";
   sessions[2].border_color = InpNewYorkBorderColor;
   sessions[2].fill_color = InpNewYorkFillColor;
   sessions[2].start_hour = InpNewYorkStartHour;
   sessions[2].end_hour = InpNewYorkEndHour;
   sessions[2].high = 0;
   sessions[2].low = 1e10;

   MqlRates rates_h1[];
   int copied = CopyRates(_Symbol, PERIOD_H1, target_day_start, target_day_end, rates_h1);
   if(copied <= 0) return;

   for(int k = 0; k < copied; k++)
   {
      MqlDateTime bar_time_struct;
      TimeToStruct(rates_h1[k].time, bar_time_struct);
      int bar_hour = bar_time_struct.hour;

      for(int i = 0; i < 3; i++)
      {
         if(bar_hour >= sessions[i].start_hour && bar_hour <= sessions[i].end_hour)
         {
            if(rates_h1[k].high > sessions[i].high) sessions[i].high = rates_h1[k].high;
            if(rates_h1[k].low < sessions[i].low) sessions[i].low = rates_h1[k].low;
         }
      }
   }

   for(int i = 0; i < 3; i++)
   {
      if(sessions[i].high == 0) continue;
      
      datetime session_start_time = target_day_start + sessions[i].start_hour * 3600;
      datetime session_end_time = target_day_start + (sessions[i].end_hour + 1) * 3600;
      string day_str_id = TimeToString(target_day_start, TIME_DATE);

      // --- Draw Fill Background ---
      if(InpFillSessionBox)
      {
         string fill_name = g_obj_prefix + sessions[i].name + "_Fill_" + day_str_id;
         ObjectCreate(0, fill_name, OBJ_RECTANGLE, 0, session_start_time, sessions[i].high, session_end_time, sessions[i].low);
         ObjectSetInteger(0, fill_name, OBJPROP_COLOR, sessions[i].fill_color);
         ObjectSetInteger(0, fill_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, fill_name, OBJPROP_BACK, true); // Di belakang candle
         ObjectSetInteger(0, fill_name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, fill_name, OBJPROP_HIDDEN, true);
      }

      // --- Draw Border ---
      if(InpDrawSessionBorder)
      {
         string border_name = g_obj_prefix + sessions[i].name + "_Border_" + day_str_id;
         ObjectCreate(0, border_name, OBJ_RECTANGLE, 0, session_start_time, sessions[i].high, session_end_time, sessions[i].low);
         ObjectSetInteger(0, border_name, OBJPROP_COLOR, sessions[i].border_color);
         ObjectSetInteger(0, border_name, OBJPROP_STYLE, InpSessionBorderStyle);
         ObjectSetInteger(0, border_name, OBJPROP_WIDTH, InpSessionBorderWidth);
         ObjectSetInteger(0, border_name, OBJPROP_FILL, false); // Hanya border
         ObjectSetInteger(0, border_name, OBJPROP_BACK, false);
         ObjectSetInteger(0, border_name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, border_name, OBJPROP_HIDDEN, true);
      }

      // --- Draw Text ---
      string text_name = g_obj_prefix + sessions[i].name + "_Text_" + day_str_id;
      ObjectCreate(0, text_name, OBJ_TEXT, 0, session_start_time, sessions[i].high);
      ObjectSetString(0, text_name, OBJPROP_TEXT, " " + sessions[i].name);
      ObjectSetInteger(0, text_name, OBJPROP_COLOR, sessions[i].border_color);
      ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, InpTextFontSize);
      ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, text_name, OBJPROP_HIDDEN, true);
   }
}
//+------------------------------------------------------------------+
void DrawStaticLines(datetime current_bar_time)
{
   if(InpShowPDHL)
   {
      if(g_pdh != 0) DrawOneStaticLine("PDH_", g_pd_time, g_pdh, InpPDHColor, "PDH", current_bar_time);
      if(g_pdl != 0) DrawOneStaticLine("PDL_", g_pd_time, g_pdl, InpPDLColor, "PDL", current_bar_time);
   }
   if(InpShowPWHL)
   {
      if(g_pwh != 0) DrawOneStaticLine("PWH_", g_pw_time, g_pwh, InpPWHColor, "PWH", current_bar_time);
      if(g_pwl != 0) DrawOneStaticLine("PWL_", g_pw_time, g_pwl, InpPWLColor, "PWL", current_bar_time);
   }
}
//+------------------------------------------------------------------+
void DeleteAllIndicatorObjects()
{
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i, -1, -1);
      if(StringFind(obj_name, g_obj_prefix) == 0)
         ObjectDelete(0, obj_name);
   }
}
//+------------------------------------------------------------------+
void DrawOneStaticLine(string name_prefix, datetime time_start_level, double price_level,
                       color line_color, string label_text, datetime current_bar_time)
{
   string obj_line_name = g_obj_prefix + name_prefix + TimeToString(time_start_level, TIME_DATE);
   string obj_text_name = obj_line_name + "_Text";

   long period_seconds = PeriodSeconds();
   if(period_seconds == 0) period_seconds = 3600;
   datetime time_end_extended = (datetime)(current_bar_time + (InpLineExtensionBars * period_seconds));

   ObjectCreate(0, obj_line_name, OBJ_TREND, 0, time_start_level, price_level, time_end_extended, price_level);
   ObjectSetInteger(0, obj_line_name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(0, obj_line_name, OBJPROP_STYLE, InpStaticLineStyle);
   ObjectSetInteger(0, obj_line_name, OBJPROP_WIDTH, InpStaticLineWidth);
   ObjectSetInteger(0, obj_line_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_line_name, OBJPROP_BACK, true);

   double text_price = price_level + 2 * _Point;
   ObjectCreate(0, obj_text_name, OBJ_TEXT, 0, time_end_extended, text_price);
   ObjectSetString(0, obj_text_name, OBJPROP_TEXT, " " + label_text);
   ObjectSetInteger(0, obj_text_name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, obj_text_name, OBJPROP_FONTSIZE, InpTextFontSize);
   ObjectSetInteger(0, obj_text_name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, obj_text_name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+