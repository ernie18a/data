//+------------------------------------------------------------------+
//|                                                        Clock.mq5 |
//|                                  Copyright 2026, AI Collaborator |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AI Collaborator"
#property link      "https://forge.mql5.io"
#property version   "2.20"
#property indicator_chart_window
#property indicator_plots 0

//--- Custom dropdown list for colors (Full Linux / Wine compatibility)
enum ENUM_CLOCK_COLOR
  {
   CLK_AQUA = 0,        // Aqua (Standard)
   CLK_NAVY = 1,        // Navy (Dark Blue)
   CLK_TEAL = 2,        // Teal (Native Pro)
   CLK_MAROON = 3,      // Maroon (Deep)
   CLK_LIME = 4,        // Lime (Green)
   CLK_SALMON = 5,      // Salmon (Pink-Orange)
   CLK_WHITE = 6,       // White
   CLK_YELLOW = 7,      // Yellow
   CLK_RED = 8          // Red (Alert)
  };

//--- Input parameters
input group "--- Clock Visual Settings ---"
input string           InpFontName   = "Trebuchet MS";   // Font Name
input int              InpFontSize   = 12;              // Font Size
input ENUM_CLOCK_COLOR InpFontColor  = CLK_AQUA;         // Font Color (Dropdown Selection)

input group "--- Spread Settings ---"
input ENUM_CLOCK_COLOR InpSpreadUpColor    = CLK_LIME;  // Spread Up Color (Increasing)
input ENUM_CLOCK_COLOR InpSpreadDownColor  = CLK_RED;   // Spread Down Color (Decreasing)

input group "--- Positioning Settings ---"
input int              InpXDistance  = 20;              // X Distance (Horizontal)
input int              InpYDistance  = 20;              // Y Distance (Vertical)
input string           InpObjPrefix  = "CLK_";          // Unique Object Prefix

//--- Variabile globale securizate per instanță
string g_object_name        = "";
string g_object_name_spread = "";

//--- Forward Declarations
color ResolveClockColor(ENUM_CLOCK_COLOR selected_color);
void  UpdateClockText();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Construire nume unic pentru obiect pentru a rula pe 15+ grafice simultan fără coliziuni
   g_object_name        = InpObjPrefix + "Countdown_" + IntegerToString(ChartID()) + "_" + _Symbol + "_" + EnumToString(_Period);
   g_object_name_spread = g_object_name + "_Spread";

   // Ștergem preventiv orice reziduu din memorie
   ObjectDelete(0, g_object_name);
   ObjectDelete(0, g_object_name_spread);

   // Creare etichetă timp (OBJ_LABEL este 100% sigur și stabil)
   if(ObjectCreate(0, g_object_name, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, g_object_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_object_name, OBJPROP_XDISTANCE, InpXDistance);
      ObjectSetInteger(0, g_object_name, OBJPROP_YDISTANCE, InpYDistance);
      ObjectSetInteger(0, g_object_name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0,  g_object_name, OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0, g_object_name, OBJPROP_COLOR, ResolveClockColor(InpFontColor));
      ObjectSetInteger(0, g_object_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_object_name, OBJPROP_HIDDEN, true);
     }

   // Creare etichetă spread separată, ca să îi putem schimba doar ei culoarea în funcție de prag
   if(ObjectCreate(0, g_object_name_spread, OBJ_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_XDISTANCE, InpXDistance);
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_YDISTANCE, InpYDistance);
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0,  g_object_name_spread, OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_COLOR, ResolveClockColor(InpFontColor));
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_object_name_spread, OBJPROP_HIDDEN, true);
     }

   // Activare Timer la o secundă: Asigură fluiditatea secundarului chiar și când nu sunt tick-uri pe piață
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, g_object_name);
   ObjectDelete(0, g_object_name_spread);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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
   if(rates_total < 2) return 0;

   // Actualizare fluidă la venirea fiecărui tick proaspăt
   UpdateClockText();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| TIMER EVENT - RULARE ASINCRONĂ SECUNDĂ CU SECUNDĂ                |
//+------------------------------------------------------------------+
void OnTimer()
  {
   // Actualizează timpul chiar dacă piața este oprită sau spread-ul este fix (ex. weekend/nopți)
   UpdateClockText();
  }

//+------------------------------------------------------------------+
//| NUCLEUL CENTRAL DE CALCUL ȘI RENDERIZARE CEAS                     |
//+------------------------------------------------------------------+
void UpdateClockText()
  {
   // Preluare timp deschidere lumânare curentă securizat
   datetime bar_open = iTime(_Symbol, _Period, 0);
   if(bar_open == 0) return;

   datetime bar_close = bar_open + PeriodSeconds(_Period);
   
   int sec_left = (int)(bar_close - TimeCurrent());
   if(sec_left < 0) sec_left = 0;

   // Calcul ore, minute, secunde
   int hh = sec_left / 3600;
   int mm = (sec_left % 3600) / 60;
   int ss = sec_left % 60;

   // Calcul Spread în puncte reale
   double spr = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;

   // Formatare text timp (Dacă timeframe-ul are peste o oră, ex: H4, D1, adăugăm și formatul de oră)
   string time_text = "";
   if(hh > 0)
     {
      time_text = StringFormat("< %02d:%02d:%02d  ", hh, mm, ss);
     }
   else
     {
      time_text = StringFormat("< %02d:%02d  ", mm, ss);
     }

   string spread_text = StringFormat("(%.0f)", spr);

   // Aplicare text pe cele două etichete (Modificare dinamică de parametri, zero lag RAM)
   ObjectSetString(0, g_object_name, OBJPROP_TEXT, time_text);
   ObjectSetString(0, g_object_name_spread, OBJPROP_TEXT, spread_text);

   // Repoziționăm eticheta de spread imediat după textul de timp, măsurând lățimea reală a fontului
   TextSetFont(InpFontName, -InpFontSize * 10);
   uint text_w = 0, text_h = 0;
   TextGetSize(time_text, text_w, text_h);
   ObjectSetInteger(0, g_object_name_spread, OBJPROP_XDISTANCE, InpXDistance + (int)text_w);
   ObjectSetInteger(0, g_object_name_spread, OBJPROP_YDISTANCE, InpYDistance);

   // Colorăm spread-ul în funcție de direcție: crește -> InpSpreadUpColor, scade -> InpSpreadDownColor
   static bool   s_first_run  = true;
   static double s_last_spr   = 0.0;
   static color  s_last_color = clrAqua;

   if(s_first_run)
     {
      s_last_color = ResolveClockColor(InpFontColor);
      s_first_run  = false;
     }
   else if(spr > s_last_spr)
     {
      s_last_color = ResolveClockColor(InpSpreadUpColor);
     }
   else if(spr < s_last_spr)
     {
      s_last_color = ResolveClockColor(InpSpreadDownColor);
     }
   // dacă spr == s_last_spr, păstrăm ultima culoare (fără schimbare)

   s_last_spr = spr;
   ObjectSetInteger(0, g_object_name_spread, OBJPROP_COLOR, s_last_color);
  }

//+------------------------------------------------------------------+
//| CONVERSIE DROPDOWN -> CULOARE REAL REALĂ (FORMAT BGR COMPATIBIL) |
//+------------------------------------------------------------------+
color ResolveClockColor(ENUM_CLOCK_COLOR selected_color)
  {
   switch(selected_color)
     {
      case CLK_AQUA:   return clrAqua;
      case CLK_NAVY:   return 0x800000;   // Navy nativ hex (BGR)
      case CLK_TEAL:   return 0x808000;   // Teal nativ hex
      case CLK_MAROON: return 0x000080;   // Maroon nativ hex
      case CLK_LIME:   return clrLime;
      case CLK_SALMON: return 0x7280FA;   // Salmon nativ hex
      case CLK_WHITE:  return clrWhite;
      case CLK_YELLOW: return clrYellow;
      case CLK_RED:    return clrRed;
      default:         return clrAqua;
     }
  }