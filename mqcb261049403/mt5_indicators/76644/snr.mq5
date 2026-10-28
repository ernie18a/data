//+------------------------------------------------------------------+
//|                                                          SNR.mq5 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ahmad Arju"
#property link      "https://www.mql5.com/en/users/arju0612_/"
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Enums
enum ENUM_OVERLAP_MODE {
   OVERLAP_MOST_EXTREME,   // Most Extreme 
   OVERLAP_NEWEST          // Newest 
};

enum ENUM_DASH_POSITION {
   POS_TOP_LEFT,     // Top Left
   POS_BOTTOM_LEFT,  // Bottom Left
   POS_TOP_RIGHT,    // Top Right
   POS_BOTTOM_RIGHT  // Bottom Right
};

//--- Input Parameters
input group "ZigZag Settings"
input int      InpDepth        = 12;      // ZigZag Depth
input int      InpDeviation    = 5;       // ZigZag Deviation
input int      InpBackstep     = 5;       // ZigZag Backstep

input group "Zone Colors"
input color    InpColorSupport    = C'7, 135, 32';      // Support Zone
input color    InpColorResistance = C'150, 5, 19';      // Resistance Zone
input color    InpColorSBR        = C'141, 3, 168';     // Support Becomes Resistance
input color    InpColorRBS        = C'5, 84, 173';      // Resistance Becomes Support

input group "Text Settings"
input int      InpTextOffsetBars = 3;      // Text Horizontal Offset (bars)

input group "Repaint Safety"
input int      InpConfirmBars     = 2;      // Number of Latest Pivots to Exclude (Anti-Repaint)

input group "Zone Width Normalization"
input bool     InpEnableNormalize     = true;    // Enable Zone Width Normalization
input int      InpNormalizeLookback   = 1000;    // Lookback Bars (average width used for normalization)
input double   InpRefineThresholdMult = 2.0;     // Trigger: Refine if Width > (Multiplier x Average)
input double   InpRefineTargetMult    = 1.5;     // Target: Width After Refine = (Multiplier x Average)

input group "Overlap Resolution"
input ENUM_OVERLAP_MODE InpOverlapMode = OVERLAP_MOST_EXTREME;  // Overlapping Zones: Winner Determined By?

input group "SBR/RBS Settings"
input bool     InpEnableSBRRBS    = false;   // Enable SBR/RBS Zones (if false, breakout zones are removed immediately)

input group "Distance Filter"
input double   InpMinMoveAwayMult = 2.0;     // Minimum Distance Away From Zone (x Zone Width) Before a Signal May Trigger

input group "Alert & Notification Settings"
input bool     InpSendAlert        = true;               // Pop-up Terminal Alert
input bool     InpSendPush         = false;              // Send Push Notification (Mobile)

input group "Performance"
input int      InpMaxHistory      = 3000;    // Max Bars to Calculate

input group "Market Bias Settings"
input int      InpMarketMoveLookback = 100;   // Market Move Lookback Bars (recent window)

input group "Dashboard Panel"
input bool                InpShowDashboard = true;           // Show On-Chart Dashboard Panel
input ENUM_DASH_POSITION InpDashPosition  = POS_TOP_LEFT;   // Panel Position

//--- Enums Internal
enum ENUM_ZONE_TYPE {
   ZONE_SUPPORT,
   ZONE_RESISTANCE,
   ZONE_SBR,
   ZONE_RBS
};

//--- Structs
struct SZone {
   datetime       time_start;
   datetime       valid_time;       
   double         high;
   double         low;
   ENUM_ZONE_TYPE type;
   bool           alert_triggered; 
   double         extreme_since;   
   int            extreme_bar_index;    
   bool           moved_away;       
   int            birth_bar_index;      
   int            moved_away_bar_index; 
};

//--- Global Variables
SZone          active_zones[];
datetime       triggered_alerts[];
string         obj_prefix;
int            g_refined_count = 0;  
double         g_avg_zone_width = 0.0; 

// Dynamic arrays untuk kalkulasi ZigZag internal (sama seperti core MT5)
double         zz[];
double         HighMapBuffer[];
double         LowMapBuffer[];

// Cache untuk hindari full-history rebuild di setiap tick
int            g_last_calc_bars     = -1;    
double         g_f_choppiness       = 1.0;
double         g_zz_sum_up          = 0.0;
double         g_zz_sum_down        = 0.0;
double         g_zz_sum_up_recent   = 0.0;   
double         g_zz_sum_down_recent = 0.0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   obj_prefix = "ZZ_SNR_" + IntegerToString(ChartID()) + "_";
   g_last_calc_bars = -1; 
   EventSetMillisecondTimer(200);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Timer — paksa redraw berkala                                     |
//+------------------------------------------------------------------+
void OnTimer()
{
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, obj_prefix);
}

//+------------------------------------------------------------------+
//| Pure Manual ZigZag Calculation Engine (Identical to MT5 Core)    |
//+------------------------------------------------------------------+
void CalculateZigZag(int rates_total, int prev_calculated, const double &high[], const double &low[])
{
   if(ArraySize(zz) != rates_total) {
      ArrayResize(zz, rates_total);
      ArrayResize(HighMapBuffer, rates_total);
      ArrayResize(LowMapBuffer, rates_total);
   }
   
   if (prev_calculated == 0) {
      ArrayInitialize(zz, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
   }

   int limit = prev_calculated - 1;
   if (prev_calculated == 0) {
      limit = rates_total - InpMaxHistory - 1000; // Ekstra history agar garis awal zigzag stabil
      if (limit < InpDepth) limit = InpDepth;
   }
   if (limit < InpDepth) limit = InpDepth;
   
   // --- Pass 1: Depth Map (Cari titik tertinggi & terendah lokal) ---
   for (int i = limit; i < rates_total; i++) {
      LowMapBuffer[i]  = 0.0;
      HighMapBuffer[i] = 0.0;

      // Cari Lowest di rentang Depth
      double min_val = low[i];
      for (int j = 1; j < InpDepth && (i - j) >= 0; j++) {
         if (low[i - j] < min_val) min_val = low[i - j];
      }
      if (low[i] == min_val) {
         LowMapBuffer[i] = low[i];
      }

      // Cari Highest di rentang Depth
      double max_val = high[i];
      for (int j = 1; j < InpDepth && (i - j) >= 0; j++) {
         if (high[i - j] > max_val) max_val = high[i - j];
      }
      if (high[i] == max_val) {
         HighMapBuffer[i] = high[i];
      }
   }

   // --- Pass 2: Backstep Filter (Membersihkan peak yang berdekatan) ---
   for (int i = limit; i < rates_total; i++) {
      if (LowMapBuffer[i] != 0.0) {
         for (int j = 1; j <= InpBackstep && (i - j) >= 0; j++) {
            if (LowMapBuffer[i - j] != 0.0) {
               if (LowMapBuffer[i - j] > LowMapBuffer[i]) LowMapBuffer[i - j] = 0.0;
               else { LowMapBuffer[i] = 0.0; break; }
            }
         }
      }
      if (HighMapBuffer[i] != 0.0) {
         for (int j = 1; j <= InpBackstep && (i - j) >= 0; j++) {
            if (HighMapBuffer[i - j] != 0.0) {
               if (HighMapBuffer[i - j] < HighMapBuffer[i]) HighMapBuffer[i - j] = 0.0;
               else { HighMapBuffer[i] = 0.0; break; }
            }
         }
      }
   }

   // --- Pass 3: Construct ZigZag (Menghitung Deviation & Aturan Selang-Seling) ---
   // Mundur sedikit untuk memastikan koneksi dengan history sebelumnya rapi
   int final_pass_start = limit - InpBackstep - 1;
   if (final_pass_start < 0) final_pass_start = 0;

   int last_type = 0; // 1 = High, -1 = Low
   int last_idx  = -1;

   // Deteksi state terakhir sebelum titik mulai
   for (int i = final_pass_start - 1; i >= 0; i--) {
      if (zz[i] != 0.0) {
         last_type = (zz[i] == high[i]) ? 1 : -1;
         last_idx = i;
         break;
      }
   }

   for (int i = final_pass_start; i < rates_total; i++) {
      zz[i] = 0.0; // Reset state saat ini

      if (last_type == 0) { 
         if (HighMapBuffer[i] != 0.0) {
            zz[i] = HighMapBuffer[i];
            last_type = 1;
            last_idx = i;
         } else if (LowMapBuffer[i] != 0.0) {
            zz[i] = LowMapBuffer[i];
            last_type = -1;
            last_idx = i;
         }
         continue;
      }

      if (last_type == 1) { // Sedang mencari Low baru
         if (LowMapBuffer[i] != 0.0) {
            // Cek minimum deviasi dari High sebelumnya
            if (zz[last_idx] - LowMapBuffer[i] >= InpDeviation * _Point) {
               zz[i] = LowMapBuffer[i];
               last_type = -1;
               last_idx = i;
            }
         }
         // Apabila ada High baru yang lebih tinggi (menggantikan High lama)
         if (HighMapBuffer[i] != 0.0) {
            if (HighMapBuffer[i] > zz[last_idx]) {
               zz[last_idx] = 0.0; 
               zz[i] = HighMapBuffer[i];
               last_idx = i;
            }
         }
      } else if (last_type == -1) { // Sedang mencari High baru
         if (HighMapBuffer[i] != 0.0) {
            // Cek minimum deviasi dari Low sebelumnya
            if (HighMapBuffer[i] - zz[last_idx] >= InpDeviation * _Point) {
               zz[i] = HighMapBuffer[i];
               last_type = 1;
               last_idx = i;
            }
         }
         // Apabila ada Low baru yang lebih rendah (menggantikan Low lama)
         if (LowMapBuffer[i] != 0.0) {
            if (LowMapBuffer[i] < zz[last_idx]) {
               zz[last_idx] = 0.0; 
               zz[i] = LowMapBuffer[i];
               last_idx = i;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Helper: Check if Zone needs to be added or replaces ANY overlap  |
//+------------------------------------------------------------------+
void AddZone(SZone &new_zone)
{
   bool new_zone_wins = true;
   int winning_existing_idx = -1;

   if(InpOverlapMode == OVERLAP_MOST_EXTREME) {
      for(int i = 0; i < ArraySize(active_zones); i++) {
         if(new_zone.high >= active_zones[i].low && new_zone.low <= active_zones[i].high) {
            if(new_zone.type == ZONE_SUPPORT) {
               if(new_zone.low >= active_zones[i].low) {
                  new_zone_wins = false; 
                  winning_existing_idx = i;
                  break; 
               }
            }
            else if(new_zone.type == ZONE_RESISTANCE) {
               if(new_zone.high <= active_zones[i].high) {
                  new_zone_wins = false;
                  winning_existing_idx = i;
                  break; 
               }
            }
         }
      }
   }
   
   if(new_zone_wins) {
      for(int i = ArraySize(active_zones) - 1; i >= 0; i--) {
         if(new_zone.high >= active_zones[i].low && new_zone.low <= active_zones[i].high) {
            ArrayRemove(active_zones, i, 1);
         }
      }
      
      int sz = ArraySize(active_zones);
      ArrayResize(active_zones, sz + 1);
      
      new_zone.alert_triggered = false;
      for(int a=0; a<ArraySize(triggered_alerts); a++) {
         if(triggered_alerts[a] == new_zone.time_start) { new_zone.alert_triggered = true; break; }
      }
      
      active_zones[sz] = new_zone;
   } else {
      if(winning_existing_idx != -1) {
         active_zones[winning_existing_idx].alert_triggered = false;
         for(int a = ArraySize(triggered_alerts) - 1; a >= 0; a--) {
            if(triggered_alerts[a] == active_zones[winning_existing_idx].time_start) {
               ArrayRemove(triggered_alerts, a, 1);
               break; 
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Helper: Update Chart Objects (S/R Zones)                         |
//+------------------------------------------------------------------+
void UpdateUI(datetime current_time)
{
   int total_rect = ObjectsTotal(0, 0, OBJ_RECTANGLE);
   for(int i = total_rect - 1; i >= 0; i--) {
      string obj_name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(obj_name, obj_prefix) == 0) {
         bool found = false;
         for(int z = 0; z < ArraySize(active_zones); z++) {
            string expected_name = obj_prefix + IntegerToString(active_zones[z].time_start);
            if(obj_name == expected_name) { found = true; break; }
         }
         if(!found) ObjectDelete(0, obj_name);
      }
   }

   int total_txt = ObjectsTotal(0, 0, OBJ_TEXT);
   for(int i = total_txt - 1; i >= 0; i--) {
      string obj_name = ObjectName(0, i, 0, OBJ_TEXT);
      if(StringFind(obj_name, obj_prefix) == 0) {
         bool found = false;
         for(int z = 0; z < ArraySize(active_zones); z++) {
            string expected_txt = obj_prefix + "TXT_" + IntegerToString(active_zones[z].time_start);
            if(obj_name == expected_txt) { found = true; break; }
         }
         if(!found) ObjectDelete(0, obj_name);
      }
   }

   datetime text_time = current_time + (datetime)(PeriodSeconds(_Period) * InpTextOffsetBars);

   for(int z = 0; z < ArraySize(active_zones); z++) {
      string expected_name = obj_prefix + IntegerToString(active_zones[z].time_start);
      string expected_txt = obj_prefix + "TXT_" + IntegerToString(active_zones[z].time_start);
      
      color c = clrNONE;
      string label_text = "";
      double price_level = 0;
      int anchor = ANCHOR_LEFT;
      
      if(active_zones[z].type == ZONE_SUPPORT) {
         c = InpColorSupport;
         label_text = "SUP " + DoubleToString(active_zones[z].high, _Digits);
         price_level = active_zones[z].high;
      }
      else if(active_zones[z].type == ZONE_RESISTANCE) {
         c = InpColorResistance;
         label_text = "RES " + DoubleToString(active_zones[z].low, _Digits);
         price_level = active_zones[z].low;
      }
      else if(active_zones[z].type == ZONE_SBR) {
         c = InpColorSBR;
         label_text = "SBR " + DoubleToString(active_zones[z].low, _Digits);
         price_level = active_zones[z].low;
      }
      else if(active_zones[z].type == ZONE_RBS) {
         c = InpColorRBS;
         label_text = "RBS " + DoubleToString(active_zones[z].high, _Digits);
         price_level = active_zones[z].high;
      }
      
      if(ObjectFind(0, expected_name) < 0) {
         ObjectCreate(0, expected_name, OBJ_RECTANGLE, 0, active_zones[z].time_start, active_zones[z].high, current_time, active_zones[z].low);
         ObjectSetInteger(0, expected_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, expected_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, expected_name, OBJPROP_COLOR, c);
         ObjectSetInteger(0, expected_name, OBJPROP_BGCOLOR, c);
         ObjectSetString(0, expected_name, OBJPROP_TOOLTIP, EnumToString(active_zones[z].type));
         ObjectSetInteger(0, expected_name, OBJPROP_HIDDEN, true);
      } else {
         ObjectSetInteger(0, expected_name, OBJPROP_COLOR, c);
         ObjectSetInteger(0, expected_name, OBJPROP_BGCOLOR, c);
         ObjectSetInteger(0, expected_name, OBJPROP_TIME, 1, current_time);
      }
      
      if(ObjectFind(0, expected_txt) < 0) {
         ObjectCreate(0, expected_txt, OBJ_TEXT, 0, text_time, price_level);
         ObjectSetString(0, expected_txt, OBJPROP_TEXT, label_text);
         ObjectSetInteger(0, expected_txt, OBJPROP_COLOR, c);
         ObjectSetString(0, expected_txt, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, expected_txt, OBJPROP_FONTSIZE, 10);
         ObjectSetInteger(0, expected_txt, OBJPROP_ANCHOR, anchor);
         ObjectSetInteger(0, expected_txt, OBJPROP_BACK, false);
         ObjectSetInteger(0, expected_txt, OBJPROP_HIDDEN, true);
      } else {
         ObjectSetInteger(0, expected_txt, OBJPROP_TIME, text_time);
         ObjectSetDouble(0, expected_txt, OBJPROP_PRICE, price_level);
         ObjectSetString(0, expected_txt, OBJPROP_TEXT, label_text);
         ObjectSetInteger(0, expected_txt, OBJPROP_COLOR, c);
         ObjectSetInteger(0, expected_txt, OBJPROP_ANCHOR, anchor);
      }
   }
   
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Helper: Two-way zone width normalization                         |
//+------------------------------------------------------------------+
void RefineZoneWidth(SZone &z, double avg_width)
{
   if(!InpEnableNormalize || avg_width <= 0.0) return;

   double width = z.high - z.low;
   double threshold = avg_width * InpRefineThresholdMult;

   if(width > threshold) {
      double target_width = avg_width * InpRefineTargetMult;
      if(target_width >= width) return;

      if(z.type == ZONE_SUPPORT) z.high = z.low + target_width;
      else if(z.type == ZONE_RESISTANCE) z.low = z.high - target_width;
      g_refined_count++;
   }
   else if(width < avg_width) {
      double target_width = avg_width;

      if(z.type == ZONE_SUPPORT) z.low = z.high - target_width;   
      else if(z.type == ZONE_RESISTANCE) z.high = z.low + target_width;   
      g_refined_count++;
   }
}

//+------------------------------------------------------------------+
//| Dashboard Helper: Create/Update a background rectangle panel     |
//+------------------------------------------------------------------+
void PanelBG(string name, int x, int y, int w, int h)
{
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_COLOR, C'70,70,70');
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'18,18,18');
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
}

//+------------------------------------------------------------------+
//| Dashboard Helper: Create/Update a single text label ("cell")     |
//+------------------------------------------------------------------+
void PanelLabel(string name, string text, int x, int y, color clr, int fontsize, bool bold=false)
{
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_FONT, bold ? "Consolas Bold" : "Consolas");
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------+
//| Dashboard: Compact status table                                  |
//+------------------------------------------------------------------+
void UpdateDashboard(double avg_width, int total_zones, int refined_count,
                     double sum_up_recent, double sum_down_recent, double choppiness)
{
   if(!InpShowDashboard) {
      ObjectDelete(0, obj_prefix + "DASH_BG");
      for(int i = 0; i < 6; i++) {
         ObjectDelete(0, obj_prefix + "DASH_L" + IntegerToString(i));
         ObjectDelete(0, obj_prefix + "DASH_V" + IntegerToString(i));
      }
      ChartRedraw(0);
      return;
   }

   double total_move_recent = sum_up_recent + sum_down_recent;
   double bull_pct = (total_move_recent > 0.0) ? (sum_up_recent / total_move_recent * 100.0) : 50.0;

   string move_str;
   color  move_clr;
   if(bull_pct >= 55.0)      { move_str = "BULLISH (" + DoubleToString(bull_pct, 0) + "%)"; move_clr = clrLimeGreen; }
   else if(bull_pct <= 45.0) { move_str = "BEARISH (" + DoubleToString(100.0 - bull_pct, 0) + "%)"; move_clr = clrTomato; }
   else                      { move_str = "SIDEWAYS (" + DoubleToString(bull_pct, 0) + "%)"; move_clr = clrKhaki; }

   double bias_strength = MathAbs(bull_pct - 50.0) * 2.0;

   string rev_str;
   color  rev_clr;
   if(choppiness >= 0.70 && bias_strength <= 30.0) {
      rev_str = "GOOD";    rev_clr = clrLimeGreen;
   }
   else if(choppiness >= 0.40 && bias_strength <= 60.0) {
      rev_str = "MIXED";   rev_clr = clrKhaki;
   }
   else {
      rev_str = "POOR";    rev_clr = clrTomato;
   }

   int row_h   = 17;
   int col1_w  = 118;   
   int panel_w = 236;
   int panel_h = row_h * 6 + 20;

   int x0 = 10;
   int y0 = 30;
   
   switch(InpDashPosition) {
      case POS_TOP_LEFT:     x0 = 10;   y0 = 30;  break;
      case POS_BOTTOM_LEFT:  x0 = 10;   y0 = 770; break;
      case POS_TOP_RIGHT:    x0 = 1620; y0 = 15;  break;
      case POS_BOTTOM_RIGHT: x0 = 1620; y0 = 770; break;
   }

   PanelBG(obj_prefix + "DASH_BG", x0 - 6, y0 - 6, panel_w, panel_h);

   PanelLabel(obj_prefix + "DASH_TITLE", "SNR FLIP ZONE — MONITOR", x0, y0, clrWhite, 8, true);

   int r = 1;
   PanelLabel(obj_prefix + "DASH_L0", "Avg Zone Width",   x0,          y0 + row_h*r, clrSilver, 8);
   PanelLabel(obj_prefix + "DASH_V0", DoubleToString(avg_width, _Digits), x0 + col1_w, y0 + row_h*r, clrWhite, 8);
   r++;

   PanelLabel(obj_prefix + "DASH_L1", "Total Active Zones", x0,          y0 + row_h*r, clrSilver, 8);
   PanelLabel(obj_prefix + "DASH_V1", IntegerToString(total_zones),       x0 + col1_w, y0 + row_h*r, clrWhite, 8);
   r++;

   PanelLabel(obj_prefix + "DASH_L2", "Zones Refined",    x0,          y0 + row_h*r, clrSilver, 8);
   PanelLabel(obj_prefix + "DASH_V2", IntegerToString(refined_count),   x0 + col1_w, y0 + row_h*r, clrWhite, 8);
   r++;

   PanelLabel(obj_prefix + "DASH_L3", "Market Move",      x0,          y0 + row_h*r, clrSilver, 8);
   PanelLabel(obj_prefix + "DASH_V3", move_str,             x0 + col1_w, y0 + row_h*r, move_clr, 8, true);
   r++;

   PanelLabel(obj_prefix + "DASH_L4", "Reversal Setup",   x0,          y0 + row_h*r, clrSilver, 8);
   PanelLabel(obj_prefix + "DASH_V4", rev_str,              x0 + col1_w, y0 + row_h*r, rev_clr, 8, true);

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
   if(rates_total < InpMaxHistory) return 0;
   
   if(prev_calculated == 0) {
      g_last_calc_bars = -1; 
      ArrayResize(triggered_alerts, 0); 
   }
   
   ArraySetAsSeries(time, false);
   ArraySetAsSeries(high, false);
   ArraySetAsSeries(low, false);
   ArraySetAsSeries(close, false);

   // HITUNG ZIGZAG MANUAL DENGAN KODE EMBEDDED
   CalculateZigZag(rates_total, prev_calculated, high, low);

   bool need_full_rebuild = (prev_calculated == 0) || (rates_total != g_last_calc_bars);

   if(need_full_rebuild)
   {
      ArrayResize(triggered_alerts, 0); 

      int start_idx = rates_total - InpMaxHistory;
      if(start_idx < 1) start_idx = 1;

      g_refined_count = 0; 

      double avg_zone_width = 0.0;
      {
         int lb_start = rates_total - InpNormalizeLookback;
         if(lb_start < 0) lb_start = 0;
         double sum_width = 0.0;
         int count_width = 0;
         for(int j = lb_start; j < rates_total; j++) {
            sum_width += (high[j] - low[j]);
            count_width++;
         }
         if(count_width > 0) avg_zone_width = sum_width / count_width;
      }
      g_avg_zone_width = avg_zone_width;

      ArrayResize(active_zones, 0);

      int prev_tc_array[];
      ArrayResize(prev_tc_array, rates_total);
      int current_tc = start_idx;
      int last_node_type = 0; 
      
      int confirm_bars = (InpConfirmBars < 1) ? 1 : InpConfirmBars;
      
      int pivot_bars[];
      int total_pivots = 0;
      for(int p = 0; p < rates_total; p++) {
         if(zz[p] != 0.0 && zz[p] != EMPTY_VALUE) {
            ArrayResize(pivot_bars, total_pivots + 1);
            pivot_bars[total_pivots] = p;
            total_pivots++;
         }
      }

      // --- HISTORICAL LOOP ---
      for(int i = start_idx; i < rates_total - 1; i++) 
      {
         prev_tc_array[i] = current_tc; 
         
         if(high[i] > high[current_tc] || low[i] < low[current_tc]) {
            current_tc = i;
         }

         for(int k = ArraySize(active_zones) - 1; k >= 0; k--) {
            
            bool transition = false;
            if(active_zones[k].type == ZONE_SUPPORT && close[i] < active_zones[k].low) {
               if(InpEnableSBRRBS) {
                  active_zones[k].type = ZONE_SBR; active_zones[k].alert_triggered = false; transition = true;
                  active_zones[k].extreme_since = active_zones[k].low; active_zones[k].moved_away = false;
                  active_zones[k].extreme_bar_index = i;
                  active_zones[k].birth_bar_index = i; active_zones[k].moved_away_bar_index = -1;
               } else {
                  ArrayRemove(active_zones, k, 1); continue;
               }
            }
            else if(active_zones[k].type == ZONE_RESISTANCE && close[i] > active_zones[k].high) {
               if(InpEnableSBRRBS) {
                  active_zones[k].type = ZONE_RBS; active_zones[k].alert_triggered = false; transition = true;
                  active_zones[k].extreme_since = active_zones[k].high; active_zones[k].moved_away = false;
                  active_zones[k].extreme_bar_index = i;
                  active_zones[k].birth_bar_index = i; active_zones[k].moved_away_bar_index = -1;
               } else {
                  ArrayRemove(active_zones, k, 1); continue;
               }
            }
            else if(active_zones[k].type == ZONE_SBR && close[i] > active_zones[k].high) { 
               ArrayRemove(active_zones, k, 1); continue;
            }
            else if(active_zones[k].type == ZONE_RBS && close[i] < active_zones[k].low) {
               ArrayRemove(active_zones, k, 1); continue;
            }

            if(transition) continue;

            double zwidth_i = active_zones[k].high - active_zones[k].low;
            if(active_zones[k].type == ZONE_SUPPORT || active_zones[k].type == ZONE_RBS) {
               if(high[i] > active_zones[k].extreme_since) {
                  active_zones[k].extreme_since = high[i];
                  active_zones[k].extreme_bar_index = i;
               }
               if(!active_zones[k].moved_away && zwidth_i > 0 &&
                  (active_zones[k].extreme_since - active_zones[k].high) >= zwidth_i * InpMinMoveAwayMult) {
                  active_zones[k].moved_away = true;
                  active_zones[k].moved_away_bar_index = i;
               }
            }
            else if(active_zones[k].type == ZONE_RESISTANCE || active_zones[k].type == ZONE_SBR) {
               if(low[i] < active_zones[k].extreme_since) {
                  active_zones[k].extreme_since = low[i];
                  active_zones[k].extreme_bar_index = i;
               }
               if(!active_zones[k].moved_away && zwidth_i > 0 &&
                  (active_zones[k].low - active_zones[k].extreme_since) >= zwidth_i * InpMinMoveAwayMult) {
                  active_zones[k].moved_away = true;
                  active_zones[k].moved_away_bar_index = i;
               }
            }

            if(time[i] >= active_zones[k].valid_time) {
               if(!active_zones[k].alert_triggered && active_zones[k].moved_away) {
                  bool is_touched_now = false;
                  
                  if(active_zones[k].type == ZONE_SUPPORT && low[i] <= active_zones[k].high) is_touched_now = true;
                  else if(active_zones[k].type == ZONE_RESISTANCE && high[i] >= active_zones[k].low) is_touched_now = true;
                  else if(active_zones[k].type == ZONE_SBR && high[i] >= active_zones[k].low) is_touched_now = true;
                  else if(active_zones[k].type == ZONE_RBS && low[i] <= active_zones[k].high) is_touched_now = true;
                  
                  if(is_touched_now) {
                     active_zones[k].alert_triggered = true;
                     int sz = ArraySize(triggered_alerts);
                     ArrayResize(triggered_alerts, sz + 1);
                     triggered_alerts[sz] = active_zones[k].time_start;
                  }
               }
            }
         }

         if(zz[i] != 0.0 && zz[i] != EMPTY_VALUE) {
            
            int p_idx = -1;
            for(int p = 0; p < total_pivots; p++) {
               if(pivot_bars[p] == i) { p_idx = p; break; }
            }
            
            if(p_idx != -1 && p_idx + confirm_bars < total_pivots) {
               datetime v_time = time[pivot_bars[p_idx + confirm_bars]];
               
               bool is_high = false;
               bool is_low = false;
               
               if(zz[i] == high[i] && zz[i] != low[i]) is_high = true;
               else if(zz[i] == low[i] && zz[i] != high[i]) is_low = true;
               else { 
                  if(last_node_type == -1) is_high = true;
                  else if(last_node_type == 1) is_low = true;
               }

               int ptc = prev_tc_array[i];
               
               if(is_high) {
                  last_node_type = 1;
                  if(ptc > 0 && high[i] > high[ptc]) {
                     SZone z;
                     z.time_start = time[i];
                     z.valid_time = v_time; 
                     z.high = high[i];
                     z.low = low[i];
                     z.type = ZONE_RESISTANCE;
                     RefineZoneWidth(z, avg_zone_width);
                     z.extreme_since = z.low; z.moved_away = false;
                     z.birth_bar_index = i; z.moved_away_bar_index = -1;
                     z.extreme_bar_index = i;
                     AddZone(z);
                  }
               }
               
               if(is_low) {
                  last_node_type = -1;
                  if(ptc > 0 && low[i] < low[ptc]) {
                     SZone z;
                     z.time_start = time[i];
                     z.valid_time = v_time;
                     z.high = high[i];
                     z.low = low[i];
                     z.type = ZONE_SUPPORT;
                     RefineZoneWidth(z, avg_zone_width);
                     z.extreme_since = z.high; z.moved_away = false;
                     z.birth_bar_index = i; z.moved_away_bar_index = -1;
                     z.extreme_bar_index = i;
                     AddZone(z);
                  }
               }
            }
         }
      }

      UpdateUI(time[rates_total-1]);

      int pivot_count_1000 = 0;
      int pivot_count_500  = 0;
      double zz_sum_up     = 0.0;
      double zz_sum_down   = 0.0;
      double zz_sum_up_recent   = 0.0;
      double zz_sum_down_recent = 0.0;
      double last_zz_val   = 0.0;
      
      int start_idx_1000   = MathMax(1, rates_total - 1000);
      int start_idx_500    = MathMax(1, rates_total - 500);
      int start_idx_recent = MathMax(1, rates_total - MathMax(10, InpMarketMoveLookback));

      for(int i = start_idx_1000; i < rates_total; i++) {
         if(zz[i] != 0.0 && zz[i] != EMPTY_VALUE) {
            pivot_count_1000++;
            if(i >= start_idx_500) {
               pivot_count_500++;
               if(last_zz_val != 0.0) {
                  double leg_move = zz[i] - last_zz_val;
                  if(leg_move > 0) zz_sum_up += leg_move;
                  else if(leg_move < 0) zz_sum_down += (-leg_move);

                  if(i >= start_idx_recent) {
                     if(leg_move > 0) zz_sum_up_recent += leg_move;
                     else if(leg_move < 0) zz_sum_down_recent += (-leg_move);
                  }
               }
            }
            last_zz_val = zz[i];
         }
      }

      int actual_bars_1000 = rates_total - start_idx_1000;
      int actual_bars_500  = rates_total - start_idx_500;
      
      double avg_dist_1000 = (pivot_count_1000 > 0) ? ((double)actual_bars_1000 / pivot_count_1000) : (double)actual_bars_1000;
      double avg_dist_500  = (pivot_count_500 > 0)  ? ((double)actual_bars_500  / pivot_count_500)  : (double)actual_bars_500;
      
      g_f_choppiness = MathMax(0.1, MathMin(1.0, avg_dist_1000 / avg_dist_500));
      g_zz_sum_up    = zz_sum_up;
      g_zz_sum_down  = zz_sum_down;
      g_zz_sum_up_recent   = zz_sum_up_recent;
      g_zz_sum_down_recent = zz_sum_down_recent;

      g_last_calc_bars = rates_total;
   }

   // ==================================================================
   // LIVE BAR TRIGGER LOGIC
   // ==================================================================
   double cur_low = low[rates_total - 1];
   double cur_high = high[rates_total - 1];
   double cur_close = close[rates_total - 1];
   int current_bar_idx = rates_total - 1;
   
   string tf_str = StringSubstr(EnumToString(_Period), 7);

   for(int k = ArraySize(active_zones) - 1; k >= 0; k--) {
      
      bool transition = false;
      
      if(active_zones[k].type == ZONE_SUPPORT && cur_close < active_zones[k].low) {
         if(InpEnableSBRRBS) {
            active_zones[k].type = ZONE_SBR; active_zones[k].alert_triggered = false; transition = true;
            active_zones[k].extreme_since = active_zones[k].low; active_zones[k].moved_away = false;
            active_zones[k].extreme_bar_index = current_bar_idx;
            active_zones[k].birth_bar_index = current_bar_idx; active_zones[k].moved_away_bar_index = -1;
         } else {
            ArrayRemove(active_zones, k, 1); continue;
         }
      }
      else if(active_zones[k].type == ZONE_RESISTANCE && cur_close > active_zones[k].high) {
         if(InpEnableSBRRBS) {
            active_zones[k].type = ZONE_RBS; active_zones[k].alert_triggered = false; transition = true;
            active_zones[k].extreme_since = active_zones[k].high; active_zones[k].moved_away = false;
            active_zones[k].extreme_bar_index = current_bar_idx;
            active_zones[k].birth_bar_index = current_bar_idx; active_zones[k].moved_away_bar_index = -1;
         } else {
            ArrayRemove(active_zones, k, 1); continue;
         }
      }
      else if(active_zones[k].type == ZONE_SBR && cur_close > active_zones[k].high) {
         ArrayRemove(active_zones, k, 1); continue;
      }
      else if(active_zones[k].type == ZONE_RBS && cur_close < active_zones[k].low) {
         ArrayRemove(active_zones, k, 1); continue;
      }

      if(transition) continue;

      double zwidth_live = active_zones[k].high - active_zones[k].low;
      if(active_zones[k].type == ZONE_SUPPORT || active_zones[k].type == ZONE_RBS) {
         if(cur_high > active_zones[k].extreme_since) {
            active_zones[k].extreme_since = cur_high;
            active_zones[k].extreme_bar_index = current_bar_idx;
         }
         if(!active_zones[k].moved_away && zwidth_live > 0 &&
            (active_zones[k].extreme_since - active_zones[k].high) >= zwidth_live * InpMinMoveAwayMult) {
            active_zones[k].moved_away = true;
            active_zones[k].moved_away_bar_index = current_bar_idx;
         }
      }
      else if(active_zones[k].type == ZONE_RESISTANCE || active_zones[k].type == ZONE_SBR) {
         if(cur_low < active_zones[k].extreme_since) {
            active_zones[k].extreme_since = cur_low;
            active_zones[k].extreme_bar_index = current_bar_idx;
         }
         if(!active_zones[k].moved_away && zwidth_live > 0 &&
            (active_zones[k].low - active_zones[k].extreme_since) >= zwidth_live * InpMinMoveAwayMult) {
            active_zones[k].moved_away = true;
            active_zones[k].moved_away_bar_index = current_bar_idx;
         }
      }

      if(time[current_bar_idx] >= active_zones[k].valid_time) {
         if(!active_zones[k].alert_triggered && active_zones[k].moved_away) {
            bool is_touched_now = false;
            
            if(active_zones[k].type == ZONE_SUPPORT && cur_low <= active_zones[k].high) is_touched_now = true;
            else if(active_zones[k].type == ZONE_RESISTANCE && cur_high >= active_zones[k].low) is_touched_now = true;
            else if(active_zones[k].type == ZONE_SBR && cur_high >= active_zones[k].low) is_touched_now = true;
            else if(active_zones[k].type == ZONE_RBS && cur_low <= active_zones[k].high) is_touched_now = true;

            if(is_touched_now) {
               active_zones[k].alert_triggered = true; 
               
               bool already_alerted = false;
               for(int a=0; a<ArraySize(triggered_alerts); a++) {
                  if(triggered_alerts[a] == active_zones[k].time_start) {
                     already_alerted = true; break;
                  }
               }

               if(!already_alerted) {
                  int sz = ArraySize(triggered_alerts);
                  ArrayResize(triggered_alerts, sz + 1);
                  triggered_alerts[sz] = active_zones[k].time_start;
               }

               if(!already_alerted && prev_calculated > 0) {
                  string zone_name = EnumToString(active_zones[k].type);
                  StringReplace(zone_name, "ZONE_", "");
                  
                  string final_msg = zone_name + " Hit\nPrice: " + DoubleToString(cur_close, _Digits) + "\n[" + tf_str + "]";

                  if(InpSendAlert) Alert(final_msg);
                  if(InpSendPush)  SendNotification(final_msg);
               }
            }
         }
      }
   }

   // Dashboard panel compact 
   UpdateDashboard(g_avg_zone_width, ArraySize(active_zones), g_refined_count,
                    g_zz_sum_up_recent, g_zz_sum_down_recent, g_f_choppiness);

   return(rates_total);
}
//+------------------------------------------------------------------+