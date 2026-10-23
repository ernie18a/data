//+------------------------------------------------------------------+
//|                                         AlgoForge_FVG_Finder.mq5 |
//|                                 Copyright 2026, AlgoForge Studio |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AlgoForge Studio"
#property link      "https://forge.mql5.io"
#property version   "1.02"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Р‘СѓС„РµСЂС‹ РґР»СЏ СЃС‚СЂРµР»РѕС‡РµРє РІС…РѕРґР°
#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3 // РЈРІРµР»РёС‡РёР»Рё СЂР°Р·РјРµСЂ СЃС‚СЂРµР»РѕС‡РµРє

#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3 // РЈРІРµР»РёС‡РёР»Рё СЂР°Р·РјРµСЂ СЃС‚СЂРµР»РѕС‡РµРє

//+------------------------------------------------------------------+
//|                                                    FVG_Logic.mqh |
//|                                    Copyright 2026, AlgoForge Studio |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AlgoForge Studio"
#property link      "https://forge.mql5.io"
#property version   "1.02"

//--- РЎС‚СЂСѓРєС‚СѓСЂР° РґР»СЏ С…СЂР°РЅРµРЅРёСЏ РёРЅС„РѕСЂРјР°С†РёРё Рѕ Р·РѕРЅРµ FVG
struct FVG_Zone
  {
   datetime          time_start;       // Р’СЂРµРјСЏ С†РµРЅС‚СЂР°Р»СЊРЅРѕР№ РёРјРїСѓР»СЊСЃРЅРѕР№ СЃРІРµС‡Рё
   datetime          time_end;         // Р’СЂРµРјСЏ РїРµСЂРµРєСЂС‹С‚РёСЏ (РјРёС‚РёРіР°С†РёРё)
   double            price_high;       // Р’РµСЂС…РЅСЏСЏ РіСЂР°РЅРёС†Р° Р·РѕРЅС‹ (СЂР°Р·СЂС‹РІ)
   double            price_low;        // РќРёР¶РЅСЏСЏ РіСЂР°РЅРёС†Р° Р·РѕРЅС‹ (СЂР°Р·СЂС‹РІ)
   bool              is_bullish;       // true - Р±С‹С‡РёР№ РёРјР±Р°Р»Р°РЅСЃ, false - РјРµРґРІРµР¶РёР№
   bool              is_mitigated;     // true - Р·РѕРЅР° РїРµСЂРµРєСЂС‹С‚Р°, false - Р·РѕРЅР° Р°РєС‚РёРІРЅР°
   string            obj_name;         // РРјСЏ РіСЂР°С„РёС‡РµСЃРєРѕРіРѕ РѕР±СЉРµРєС‚Р° (РїСЂСЏРјРѕСѓРіРѕР»СЊРЅРёРєР°)
   string            line_name;        // РРјСЏ РѕР±СЉРµРєС‚Р° РїСѓРЅРєС‚РёСЂРЅРѕР№ Р»РёРЅРёРё (50%)
  };

//--- РљР»Р°СЃСЃ РґР»СЏ СЂР°Р±РѕС‚С‹ СЃ FVG
class CFVG_Scanner
  {
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   FVG_Zone          m_zones[];        // РњР°СЃСЃРёРІ РІСЃРµС… Р·РѕРЅ
   
public:
                     CFVG_Scanner(string symbol, ENUM_TIMEFRAMES period);
                    ~CFVG_Scanner();
                    
   void              ProcessBar(datetime time_center, double high_left, double low_left, double high_right, double low_right);
   void              CheckMitigation(double current_close, datetime current_time);
   
   int               GetTotalZonesCount() { return ArraySize(m_zones); }
   FVG_Zone          GetZone(int array_index);
   void              MarkAsMitigated(int array_index, datetime mitigation_time);
   
private:
   void              AddZone(datetime t, double h, double l, bool bullish);
  };

//+------------------------------------------------------------------+
//| РљРѕРЅСЃС‚СЂСѓРєС‚РѕСЂ                                                      |
//+------------------------------------------------------------------+
CFVG_Scanner::CFVG_Scanner(string symbol, ENUM_TIMEFRAMES period)
  {
   m_symbol = symbol;
   m_period = period;
   ArrayResize(m_zones, 0, 500); 
  }

//+------------------------------------------------------------------+
//| Р”РµСЃС‚СЂСѓРєС‚РѕСЂ                                                       |
//+------------------------------------------------------------------+
CFVG_Scanner::~CFVG_Scanner()
  {
   ArrayFree(m_zones);
  }

//+------------------------------------------------------------------+
//| РћР±СЂР°Р±РѕС‚РєР° РїР°С‚С‚РµСЂРЅР° 3-С… СЃРІРµС‡РµР№                                    |
//+------------------------------------------------------------------+
void CFVG_Scanner::ProcessBar(datetime time_center, double high_left, double low_left, double high_right, double low_right)
  {
   // Р‘С‹С‡РёР№ FVG
   if(low_right > high_left)
     {
      double gapHigh = low_right;
      double gapLow = high_left;
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(gapHigh - gapLow > 5 * point)
         AddZone(time_center, gapHigh, gapLow, true);
     }
     
   // РњРµРґРІРµР¶РёР№ FVG
   if(high_right < low_left)
     {
      double gapHigh = low_left;
      double gapLow = high_right;
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(gapHigh - gapLow > 5 * point)
         AddZone(time_center, gapHigh, gapLow, false);
     }
  }

//+------------------------------------------------------------------+
//| Р”РѕР±Р°РІР»РµРЅРёРµ Р·РѕРЅС‹ РІ РјР°СЃСЃРёРІ                                         |
//+------------------------------------------------------------------+
void CFVG_Scanner::AddZone(datetime t, double h, double l, bool bullish)
  {
   int size = ArraySize(m_zones);
   for(int k = MathMax(0, size - 20); k < size; k++) 
     {
      if(m_zones[k].time_start == t) return; 
     }
     
   ArrayResize(m_zones, size + 1, 500);
   m_zones[size].time_start = t;
   m_zones[size].time_end = 0;
   m_zones[size].price_high = h;
   m_zones[size].price_low = l;
   m_zones[size].is_bullish = bullish;
   m_zones[size].is_mitigated = false;
   
   string prefix = bullish ? "AlgoForge_FVG_BULL_" : "AlgoForge_FVG_BEAR_";
   m_zones[size].obj_name = prefix + "BOX_" + TimeToString(t, TIME_DATE|TIME_MINUTES);
   m_zones[size].line_name = prefix + "LINE_" + TimeToString(t, TIME_DATE|TIME_MINUTES);
  }

//+------------------------------------------------------------------+
//| РџСЂРѕРІРµСЂРєР° РјРёС‚РёРіР°С†РёРё (РїРµСЂРµРєСЂС‹С‚РёСЏ) Р·РѕРЅ                              |
//+------------------------------------------------------------------+
void CFVG_Scanner::CheckMitigation(double current_close, datetime current_time)
  {
   int size = ArraySize(m_zones);
   int start_idx = MathMax(0, size - 100);
   
   for(int k = start_idx; k < size; k++)
     {
      if(m_zones[k].is_mitigated) continue;
      
      if(m_zones[k].is_bullish)
        {
         if(current_close < m_zones[k].price_low)
           {
            m_zones[k].is_mitigated = true;
            m_zones[k].time_end = current_time;
           }
        }
      else
        {
         if(current_close > m_zones[k].price_high)
           {
            m_zones[k].is_mitigated = true;
            m_zones[k].time_end = current_time;
           }
        }
     }
  }

//+------------------------------------------------------------------+
FVG_Zone CFVG_Scanner::GetZone(int array_index)
  {
   if(array_index >= 0 && array_index < ArraySize(m_zones))
      return m_zones[array_index];
   FVG_Zone empty = {};
   return empty;
  }

//+------------------------------------------------------------------+
void CFVG_Scanner::MarkAsMitigated(int array_index, datetime mitigation_time)
  {
   if(array_index >= 0 && array_index < ArraySize(m_zones))
     {
      m_zones[array_index].is_mitigated = true;
      m_zones[array_index].time_end = mitigation_time;
     }
  }


//--- Р’С…РѕРґРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹
input group    "=== Trading Settings ==="
input bool     InpUseRsiFilter = false;           // РСЃРїРѕР»СЊР·РѕРІР°С‚СЊ С„РёР»СЊС‚СЂ RSI
input int      InpRsiPeriod    = 14;              // РџРµСЂРёРѕРґ RSI
input int      InpRsiOversold  = 40;              // Р—РѕРЅР° РґР»СЏ РїРѕРєСѓРїРѕРє (Oversold)
input int      InpRsiOverbought= 60;              // Р—РѕРЅР° РґР»СЏ РїСЂРѕРґР°Р¶ (Overbought)
input bool     InpUseAlerts    = true;            // Р’РєР»СЋС‡РёС‚СЊ РІСЃРїР»С‹РІР°СЋС‰РёРµ РђР»РµСЂС‚С‹ (Popups)

input group    "=== Visual Settings ==="
input color    InpBullColor    = clrDarkSeaGreen; // Р¦РІРµС‚ Р±С‹С‡СЊРµРіРѕ РёРјР±Р°Р»Р°РЅСЃР°
input color    InpBearColor    = clrIndianRed;    // Р¦РІРµС‚ РјРµРґРІРµР¶СЊРµРіРѕ РёРјР±Р°Р»Р°РЅСЃР°
input color    InpLineColor    = clrDimGray;      // Р¦РІРµС‚ Р»РёРЅРёРё 50% (Consequent Encroachment)
input int      InpMaxHistory   = 1000;            // Р“Р»СѓР±РёРЅР° РѕС‚СЂРёСЃРѕРІРєРё РіСЂР°С„РёРєРё

//--- Р“Р»РѕР±Р°Р»СЊРЅС‹Рµ РїРµСЂРµРјРµРЅРЅС‹Рµ
double         BufferBuy[];
double         BufferSell[];
int            handle_rsi;
CFVG_Scanner   *scanner;
datetime       last_alert_time = 0;

//+------------------------------------------------------------------+
//| Р¤СѓРЅРєС†РёСЏ РѕС‚СЂРёСЃРѕРІРєРё РёРЅС„РѕСЂРјР°С†РёРѕРЅРЅРѕР№ РїР°РЅРµР»Рё                          |
//+------------------------------------------------------------------+
void DrawDashboard(double rsi_val, int bull_count, int bear_count)
  {
   string font = "Trebuchet MS";
   
   // Р¤РѕРЅ РїР°РЅРµР»Рё
   if(ObjectFind(0, "DashBG") < 0) {
      ObjectCreate(0, "DashBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "DashBG", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "DashBG", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, "DashBG", OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, "DashBG", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, "DashBG", OBJPROP_XSIZE, 220);
      ObjectSetInteger(0, "DashBG", OBJPROP_YSIZE, 90);
      ObjectSetInteger(0, "DashBG", OBJPROP_BGCOLOR, C'20,20,20');
      ObjectSetInteger(0, "DashBG", OBJPROP_BORDER_COLOR, clrDimGray);
      ObjectSetInteger(0, "DashBG", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "DashBG", OBJPROP_HIDDEN, true);
   }
   
   // Р—Р°РіРѕР»РѕРІРѕРє
   if(ObjectFind(0, "DashTitle") < 0) {
      ObjectCreate(0, "DashTitle", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "DashTitle", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "DashTitle", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, "DashTitle", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "DashTitle", OBJPROP_YDISTANCE, 30);
      ObjectSetString(0, "DashTitle", OBJPROP_TEXT, "ALGOFORGE FVG SNIPER");
      ObjectSetInteger(0, "DashTitle", OBJPROP_COLOR, clrGold);
      ObjectSetString(0, "DashTitle", OBJPROP_FONT, font);
      ObjectSetInteger(0, "DashTitle", OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, "DashTitle", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "DashTitle", OBJPROP_HIDDEN, true);
   }
   
   // РЎС‚Р°С‚СѓСЃ RSI
   if(ObjectFind(0, "DashRSI") < 0) {
      ObjectCreate(0, "DashRSI", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "DashRSI", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "DashRSI", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, "DashRSI", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "DashRSI", OBJPROP_YDISTANCE, 55);
      ObjectSetString(0, "DashRSI", OBJPROP_FONT, font);
      ObjectSetInteger(0, "DashRSI", OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, "DashRSI", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "DashRSI", OBJPROP_HIDDEN, true);
   }
   
   string rsi_text = "RSI Status: NEUTRAL";
   color rsi_col = clrSilver;
   if(rsi_val <= InpRsiOversold) { rsi_text = "RSI Status: BUY ZONE"; rsi_col = clrLime; }
   if(rsi_val >= InpRsiOverbought){ rsi_text = "RSI Status: SELL ZONE"; rsi_col = clrRed; }
   ObjectSetString(0, "DashRSI", OBJPROP_TEXT, rsi_text + " (" + DoubleToString(rsi_val, 1) + ")");
   ObjectSetInteger(0, "DashRSI", OBJPROP_COLOR, rsi_col);
   
   // РђРєС‚РёРІРЅС‹Рµ Р·РѕРЅС‹
   if(ObjectFind(0, "DashZones") < 0) {
      ObjectCreate(0, "DashZones", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, "DashZones", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "DashZones", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, "DashZones", OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, "DashZones", OBJPROP_YDISTANCE, 75);
      ObjectSetString(0, "DashZones", OBJPROP_FONT, font);
      ObjectSetInteger(0, "DashZones", OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, "DashZones", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "DashZones", OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, "DashZones", OBJPROP_TEXT, "Active Zones: " + IntegerToString(bull_count) + " Bull | " + IntegerToString(bear_count) + " Bear");
   ObjectSetInteger(0, "DashZones", OBJPROP_COLOR, clrWhite);
  }

//+------------------------------------------------------------------+
//| РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferBuy, INDICATOR_DATA);
   SetIndexBuffer(1, BufferSell, INDICATOR_DATA);
   
   // 233 = РЎС‚СЂРµР»РєР° РІРІРµСЂС…, 234 = РЎС‚СЂРµР»РєР° РІРЅРёР·
   PlotIndexSetInteger(0, PLOT_ARROW, 233); 
   PlotIndexSetInteger(1, PLOT_ARROW, 234); 
   
   ArraySetAsSeries(BufferBuy, true);
   ArraySetAsSeries(BufferSell, true);
   
   handle_rsi = iRSI(_Symbol, _Period, InpRsiPeriod, PRICE_CLOSE);
   if(handle_rsi == INVALID_HANDLE) return INIT_FAILED;
   
   scanner = new CFVG_Scanner(_Symbol, _Period);
   
   // Р РµРєР»Р°РјРЅР°СЏ РЅР°РґРїРёСЃСЊ СЃР»РµРІР°
   ObjectCreate(0, "AlgoForgePromo", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_YDISTANCE, 20);
   ObjectSetString(0, "AlgoForgePromo", OBJPROP_TEXT, "Ready to automate? AlgoForge Imbalance Sniper EA");
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, "AlgoForgePromo", OBJPROP_SELECTABLE, false);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Р”РµРёРЅРёС†РёР°Р»РёР·Р°С†РёСЏ                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete scanner;
   IndicatorRelease(handle_rsi);
   
   ObjectsDeleteAll(0, "AlgoForge_FVG_");
   ObjectsDeleteAll(0, "Dash");
   ObjectDelete(0, "AlgoForgePromo");
  }

//+------------------------------------------------------------------+
//| РћСЃРЅРѕРІРЅРѕР№ С†РёРєР»                                                    |
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
   if(rates_total < 10) return 0;
   
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   int limit = rates_total - prev_calculated;
   if(limit == 0) limit = 1; 
   if(limit >= rates_total - 2) limit = rates_total - 3; 
   
   double rsi_buffer[];
   ArraySetAsSeries(rsi_buffer, true);
   if(CopyBuffer(handle_rsi, 0, 0, limit + 1, rsi_buffer) <= 0) return 0;

   int active_bull = 0;
   int active_bear = 0;

   // 1. РџРѕРёСЃРє Р·РѕРЅ Рё СЃРёРіРЅР°Р»РѕРІ
   for(int i = limit; i >= 0; i--)
     {
      if(prev_calculated == 0)
        {
         BufferBuy[i] = EMPTY_VALUE;
         BufferSell[i] = EMPTY_VALUE;
        }
      
      scanner.ProcessBar(time[i+1], high[i+2], low[i+2], high[i], low[i]);
      scanner.CheckMitigation(close[i], time[i]);
      
      int zones_count = scanner.GetTotalZonesCount();
      int start_idx = MathMax(0, zones_count - 50); 
      
      for(int k = start_idx; k < zones_count; k++)
        {
         FVG_Zone zone = scanner.GetZone(k);
         if(zone.is_mitigated) continue; 
         
         if(i == 0) // РЎС‡РёС‚Р°РµРј Р°РєС‚РёРІРЅС‹Рµ Р·РѕРЅС‹ С‚РѕР»СЊРєРѕ РґР»СЏ С‚РµРєСѓС‰РµРіРѕ Р±Р°СЂР° (РґР»СЏ Dashboard)
           {
            if(zone.is_bullish) active_bull++; else active_bear++;
           }
         
         bool touch_bull = (zone.is_bullish && low[i] <= zone.price_high && low[i] >= zone.price_low);
         bool touch_bear = (!zone.is_bullish && high[i] >= zone.price_low && high[i] <= zone.price_high);
         
         bool rsi_buy_ok  = (!InpUseRsiFilter || rsi_buffer[i] <= InpRsiOversold);
         bool rsi_sell_ok = (!InpUseRsiFilter || rsi_buffer[i] >= InpRsiOverbought);
         
         // РЎРёРіРЅР°Р» РЅР° РїРѕРєСѓРїРєСѓ
         if(touch_bull && rsi_buy_ok)
           {
            BufferBuy[i] = low[i] - 15 * _Point;
            scanner.MarkAsMitigated(k, time[i]); 
            
            // РђР»РµСЂС‚ С‚РѕР»СЊРєРѕ РІ СЂРµР°Р»СЊРЅРѕРј РІСЂРµРјРµРЅРё (РЅРµ РЅР° РёСЃС‚РѕСЂРёРё)
            if(i == 0 && InpUseAlerts && time[0] != last_alert_time)
              {
               Alert("AlgoForge FVG: BUY Signal on ", _Symbol, " (", EnumToString(_Period), ")");
               last_alert_time = time[0];
              }
           }
         // РЎРёРіРЅР°Р» РЅР° РїСЂРѕРґР°Р¶Сѓ
         else if(touch_bear && rsi_sell_ok)
           {
            BufferSell[i] = high[i] + 15 * _Point;
            scanner.MarkAsMitigated(k, time[i]);
            
            if(i == 0 && InpUseAlerts && time[0] != last_alert_time)
              {
               Alert("AlgoForge FVG: SELL Signal on ", _Symbol, " (", EnumToString(_Period), ")");
               last_alert_time = time[0];
              }
           }
        }
     }
     
   // 2. РћС‚СЂРёСЃРѕРІРєР° РїСЂСЏРјРѕСѓРіРѕР»СЊРЅРёРєРѕРІ Рё Р»РёРЅРёРё 50%
   int total_zones = scanner.GetTotalZonesCount();
   int draw_start = MathMax(0, total_zones - (InpMaxHistory / 10)); 
   
   for(int k = draw_start; k < total_zones; k++)
     {
      FVG_Zone zone = scanner.GetZone(k);
      datetime end_time = zone.is_mitigated ? zone.time_end : time[0];
      double mid_price = (zone.price_high + zone.price_low) / 2.0;
      
      // РџСЂСЏРјРѕСѓРіРѕР»СЊРЅРёРє
      if(ObjectFind(0, zone.obj_name) < 0)
        {
         ObjectCreate(0, zone.obj_name, OBJ_RECTANGLE, 0, zone.time_start, zone.price_high, end_time, zone.price_low);
         ObjectSetInteger(0, zone.obj_name, OBJPROP_COLOR, zone.is_bullish ? InpBullColor : InpBearColor);
         ObjectSetInteger(0, zone.obj_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, zone.obj_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, zone.obj_name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, zone.obj_name, OBJPROP_HIDDEN, true);
         
         // Р›РёРЅРёСЏ 50% (Consequent Encroachment)
         ObjectCreate(0, zone.line_name, OBJ_TREND, 0, zone.time_start, mid_price, end_time, mid_price);
         ObjectSetInteger(0, zone.line_name, OBJPROP_COLOR, InpLineColor);
         ObjectSetInteger(0, zone.line_name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, zone.line_name, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, zone.line_name, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, zone.line_name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, zone.line_name, OBJPROP_HIDDEN, true);
        }
      else
        {
         // РћР±РЅРѕРІР»СЏРµРј РІСЂРµРјСЏ РѕРєРѕРЅС‡Р°РЅРёСЏ РґР»СЏ Р°РєС‚РёРІРЅС‹С… Р·РѕРЅ
         ObjectSetInteger(0, zone.obj_name, OBJPROP_TIME, 1, end_time);
         ObjectSetInteger(0, zone.line_name, OBJPROP_TIME, 1, end_time);
        }
     }

   // 3. РћР±РЅРѕРІР»СЏРµРј Dashboard
   if(rates_total > 0)
     {
      DrawDashboard(rsi_buffer[0], active_bull, active_bear);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

