//+------------------------------------------------------------------+
//|                                             RiskSizer_Panel_Lite |
//|                                 © 2026, Ngo The Hung (thehung21) |
//|                          https://www.mql5.com/en/users/thehung21 |
//+------------------------------------------------------------------+
#property copyright "© 2026, Ngo The Hung (thehung21)"
#property link      "https://www.mql5.com/en/users/thehung21"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//----------------------------- Inputs ------------------------------
input double InpRiskPercent        = 1.0;     // Risk % per trade (Balance)
input double InpRiskStep           = 0.10;    // Risk step for +/- buttons
input int    InpDefaultSL_Points   = 3000;     // Default SL distance (points)
input int    InpDefaultTP_Points   = 6000;     // Default TP distance (points)
input int    InpMaxSpread_Points   = 0;       // Max spread filter (points). 0 = ignore
input int    InpDeviation_Points   = 20;      // Deviation (points)
input ulong  InpMagic              = 20260120;// Magic number
input int    InpUiRefreshMs        = 250;     // UI refresh interval (ms)

//----------------------------- Constants ---------------------------
#define  PREFIX_BASE   "RSZL_"

//----------------------------- Globals -----------------------------
string   GPrefix;
bool     GUiReady = false;

// Panel objects
string   OBJ_BG, OBJ_HDR, OBJ_SEP;
string   OBJ_TITLE;

string   OBJ_BTN_RISK_MINUS, OBJ_BTN_RISK_PLUS;
string   OBJ_RISK_BG;                        // rectangle label (visual input box)
string   OBJ_RISK_TXT;                       // label inside input box

string   OBJ_BTN_BUY, OBJ_BTN_SELL, OBJ_BTN_RESET;

// Lines
string   OBJ_LINE_A, OBJ_LINE_B; // 2 draggable lines

// Value labels
string   OBJ_SYM_VAL, OBJ_SPREAD_VAL, OBJ_RMONEY_VAL;
string   OBJ_USED_RISK_BUY_VAL, OBJ_USED_RISK_SELL_VAL;
string   OBJ_LOW_VAL, OBJ_HIGH_VAL;
string   OBJ_BUYLOT_VAL, OBJ_SELLLOT_VAL;

double   GRiskPercent = 0.0;

// risk edit (keyboard-driven) - community-proven workaround
bool     gRiskEditing = false;
string   gRiskBuffer  = "";

// risk box hit-test area (screen pixels from CORNER_LEFT_UPPER)
int      gRiskX=0, gRiskY=0, gRiskW=0, gRiskH=0;

// pending risk sync
bool     GPendRiskSync = false;
double   GPendRiskValue = 0.0;

// lock panel XY to prevent accidental moving
string   GLockNames[];
int      GLockX[];
int      GLockY[];

//----------------------------- Helpers -----------------------------
int VolumeDigits(double step)
{
   int d=0;
   double s=step;
   while(s < 1.0 && d < 8)
   {
      s *= 10.0;
      d++;
   }
   return d;
}

double Clamp(double v, double mn, double mx)
{
   if(v < mn) return mn;
   if(v > mx) return mx;
   return v;
}

double NormalizeVolumeDown(double vol)
{
   double vmin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double vstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(vstep <= 0.0) vstep = 0.01;

   vol = Clamp(vol, 0.0, vmax);

   double steps = MathFloor(vol / vstep);
   double out   = steps * vstep;

   if(out < vmin) out = 0.0;

   int digits = VolumeDigits(vstep);
   return NormalizeDouble(out, digits);
}

void RememberXY(const string name, int x, int y)
{
   int n = ArraySize(GLockNames);
   ArrayResize(GLockNames, n+1);
   ArrayResize(GLockX, n+1);
   ArrayResize(GLockY, n+1);
   GLockNames[n] = name;
   GLockX[n] = x;
   GLockY[n] = y;
}

bool RestoreXY(const string name)
{
   int n = ArraySize(GLockNames);
   for(int i=0;i<n;i++)
   {
      if(GLockNames[i] == name)
      {
         if(ObjectFind(0, name) >= 0)
         {
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, GLockX[i]);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, GLockY[i]);
            return true;
         }
      }
   }
   return false;
}

bool IsPanelObject(const string name)
{
   if(GPrefix == "") return false;
   return (StringFind(name, GPrefix) == 0);
}

bool ObjCreateRectLabel(const string name, int x, int y, int w, int h, color bg, bool selectable=false, bool back=false)
{
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);

   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (color)C'70,70,70');

   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

   RememberXY(name, x, y);
   return true;
}

bool ObjCreateLabel(const string name, const string text, int x, int y, int fs=10, bool selectable=false)
{
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return false;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetString (0, name, OBJPROP_TEXT, text);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

   RememberXY(name, x, y);
   return true;
}

bool ObjCreateButton(const string name, const string text, int x, int y, int w, int h)
{
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0))
      return false;

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);

   ObjectSetString (0, name, OBJPROP_TEXT, text);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

   RememberXY(name, x, y);
   return true;
}

void StyleLabel(const string name, color txt, int fs=10, string font="Segoe UI")
{
   if(ObjectFind(0,name)<0) return;
   ObjectSetInteger(0, name, OBJPROP_COLOR, txt);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetString(0, name, OBJPROP_FONT, font);
}

void StyleButton(const string name, color bg, color txt, int fs=10, string font="Segoe UI")
{
   if(ObjectFind(0,name)<0) return;
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, txt);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetString(0, name, OBJPROP_FONT, font);
}

bool CreateOrMoveHLine(const string name, double price, color col, const string tip)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
         return false;

      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);

      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, true); // pre-select for easier drag
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

      ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   return true;
}

double GetHLinePrice(const string name)
{
   if(ObjectFind(0, name) < 0) return 0.0;
   return ObjectGetDouble(0, name, OBJPROP_PRICE);
}

string PriceToStr(double p)
{
   return DoubleToString(p, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
}

double GetAsk()
{
   double a=0;
   SymbolInfoDouble(_Symbol, SYMBOL_ASK, a);
   return a;
}

double GetBid()
{
   double b=0;
   SymbolInfoDouble(_Symbol, SYMBOL_BID, b);
   return b;
}

double GetSpreadPoints()
{
   double ask = GetAsk();
   double bid = GetBid();
   if(_Point <= 0.0) return 0.0;
   return (ask - bid) / _Point;
}

// Return LOW/HIGH price from 2 lines
bool GetLowHigh(double &low, double &high)
{
   double a = GetHLinePrice(OBJ_LINE_A);
   double b = GetHLinePrice(OBJ_LINE_B);
   if(a <= 0.0 || b <= 0.0) return false;

   low  = MathMin(a,b);
   high = MathMax(a,b);
   return true;
}

// Core (Lite): simplified lot calculation by Risk%
// NOTE: This is intentionally "Lite" / approximate for universal symbols.
// - Uses SYMBOL_TRADE_TICK_VALUE and assumes 1 point ~= 1 tick for loss estimate.
// - Does NOT handle complex currency conversion edge-cases.
// For a fully accurate engine, use a Pro version.
bool CalcLotByRisk(const double entryPrice, const double slPrice,
                   double &outLot, double &outRiskMoney, double &outLossPerLot,
                   const double riskPercent)
{
   outLot = 0.0;
   outRiskMoney = 0.0;
   outLossPerLot = 0.0;

   if(entryPrice <= 0.0 || slPrice <= 0.0) return false;

   double stopDist = MathAbs(entryPrice - slPrice);
   if(stopDist <= 0.0) return false;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickValue <= 0.0) return false;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   outRiskMoney = balance * (riskPercent / 100.0);

   // Approx: number of points between Entry and SL
   double points = stopDist / _Point;
   if(points <= 0.0) return false;

   // Approx loss per 1.00 lot
   outLossPerLot = points * tickValue;
   if(outLossPerLot <= 0.0) return false;

   double rawLot = outRiskMoney / outLossPerLot;
   outLot = NormalizeVolumeDown(rawLot);

   return (outLot > 0.0);
}

//----------------------------- Risk edit (community) ----------------
// We DO NOT use OBJ_EDIT because MT5 focus is unreliable.
// Instead: rectangle+label + capture CHARTEVENT_CLICK + CHARTEVENT_KEYDOWN.
bool HitRiskBox(const int mx, const int my)
{
   return (mx >= gRiskX && mx <= (gRiskX + gRiskW) && my >= gRiskY && my <= (gRiskY + gRiskH));
}

void RiskBoxSetText(const string text)
{
   if(ObjectFind(0, OBJ_RISK_TXT) >= 0)
      ObjectSetString(0, OBJ_RISK_TXT, OBJPROP_TEXT, text);
}

double RiskBufferToDouble(double fallback)
{
   string s = gRiskBuffer;
   StringReplace(s, ",", ".");
   double v = StringToDouble(s);
   if(v <= 0.0) return fallback;
   return v;
}

void RiskEditBegin()
{
   gRiskEditing = true;
   gRiskBuffer  = DoubleToString(GRiskPercent, 2);
   RiskBoxSetText(gRiskBuffer + " |");
   ChartRedraw();
}

void RiskEditCancel()
{
   gRiskEditing = false;
   gRiskBuffer  = "";
   RiskBoxSetText(DoubleToString(GRiskPercent, 2));
   ChartRedraw();
}

void RequestRiskSync(double newRisk)
{
   GPendRiskValue = Clamp(newRisk, 0.01, 50.0);
   GPendRiskSync = true;
}

void RiskEditApply()
{
   double r = RiskBufferToDouble(GRiskPercent);
   r = Clamp(r, 0.01, 50.0);

   RequestRiskSync(r);
   gRiskEditing = false;
   gRiskBuffer  = "";

   RiskBoxSetText(DoubleToString(r, 2));
   ChartRedraw();
}

void ApplyRiskSyncIfNeeded()
{
   if(!GPendRiskSync) return;

   GRiskPercent = GPendRiskValue;
   GPendRiskSync = false;

   if(!gRiskEditing)
      RiskBoxSetText(DoubleToString(GRiskPercent, 2));
}

void RiskHandleKey(const int key)
{
   // Enter
   if(key == 13)
   {
      RiskEditApply();
      return;
   }
   // ESC
   if(key == 27)
   {
      RiskEditCancel();
      return;
   }
   // Backspace
   if(key == 8)
   {
      int n = (int)StringLen(gRiskBuffer);
      if(n > 0)
         gRiskBuffer = StringSubstr(gRiskBuffer, 0, n-1);
      return;
   }

   // Allow digits
   if(key >= 48 && key <= 57)
   {
      string ch = CharToString((uchar)key);
      gRiskBuffer += ch;
      return;
   }

   // Allow dot/comma ('.' keycodes vary between keyboards)
   if(key == 190 || key == 110 || key == 188 || key == 46)
   {
      if(StringFind(gRiskBuffer, ".") < 0 && StringFind(gRiskBuffer, ",") < 0)
         gRiskBuffer += ".";
      return;
   }
}

//----------------------------- Trading actions ----------------------
void ResetLines()
{
   double ask = GetAsk();
   double bid = GetBid();
   if(ask <= 0.0 || bid <= 0.0) return;

   double mid = (ask + bid) * 0.5;

   double low  = mid - InpDefaultSL_Points * _Point;
   double high = mid + InpDefaultTP_Points * _Point;

   CreateOrMoveHLine(OBJ_LINE_A, low,  clrRed,  "Line A (Drag)");
   CreateOrMoveHLine(OBJ_LINE_B, high, clrLime, "Line B (Drag)");

   ObjectSetInteger(0, OBJ_LINE_A, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, OBJ_LINE_B, OBJPROP_SELECTED, true);
}

bool SpreadOk()
{
   if(InpMaxSpread_Points <= 0) return true;
   return (GetSpreadPoints() <= (double)InpMaxSpread_Points);
}

// BUY uses SL=LOW, TP=HIGH
bool OpenBuy()
{
   if(!SpreadOk())
   {
      Alert("RiskSizer Lite: Spread too high.");
      return false;
   }

   double low=0, high=0;
   if(!GetLowHigh(low,high))
   {
      Alert("RiskSizer Lite: Lines not ready.");
      return false;
   }

   double ask = GetAsk();

   double sl = low;
   double tp = (high > ask ? high : 0.0);

   if(!(sl > 0.0 && sl < ask))
   {
      Alert("RiskSizer Lite: BUY requires LOW line below price.");
      return false;
   }

   double lot=0, riskMoney=0, lossPerLot=0;
   if(!CalcLotByRisk(ask, sl, lot, riskMoney, lossPerLot, GRiskPercent) || lot <= 0.0)
   {
      Alert("RiskSizer Lite: Cannot calc BUY lot.");
      return false;
   }

   trade.SetDeviationInPoints((uint)InpDeviation_Points);
   trade.SetExpertMagicNumber(InpMagic);

   bool ok = trade.Buy(lot, _Symbol, 0.0, sl, tp, "RiskSizerLite");
   if(!ok)
   {
      Alert("RiskSizer Lite: BUY failed. Retcode=", (int)trade.ResultRetcode(), "  ", trade.ResultRetcodeDescription());
      return false;
   }
   return true;
}

// SELL uses SL=HIGH, TP=LOW
bool OpenSell()
{
   if(!SpreadOk())
   {
      Alert("RiskSizer Lite: Spread too high.");
      return false;
   }

   double low=0, high=0;
   if(!GetLowHigh(low,high))
   {
      Alert("RiskSizer Lite: Lines not ready.");
      return false;
   }

   double bid = GetBid();

   double sl = high;
   double tp = (low < bid ? low : 0.0);

   if(!(sl > 0.0 && sl > bid))
   {
      Alert("RiskSizer Lite: SELL requires HIGH line above price.");
      return false;
   }

   double lot=0, riskMoney=0, lossPerLot=0;
   if(!CalcLotByRisk(bid, sl, lot, riskMoney, lossPerLot, GRiskPercent) || lot <= 0.0)
   {
      Alert("RiskSizer Lite: Cannot calc SELL lot.");
      return false;
   }

   trade.SetDeviationInPoints((uint)InpDeviation_Points);
   trade.SetExpertMagicNumber(InpMagic);

   bool ok = trade.Sell(lot, _Symbol, 0.0, sl, tp, "RiskSizerLite");
   if(!ok)
   {
      Alert("RiskSizer Lite: SELL failed. Retcode=", (int)trade.ResultRetcode(), "  ", trade.ResultRetcodeDescription());
      return false;
   }
   return true;
}

// Close 50% for ALL positions (symbol+magic)
bool Close50()
{
   bool any=false;

   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;

      long magic = (long)PositionGetInteger(POSITION_MAGIC);
      if(magic != (long)InpMagic) continue;

      double vol = PositionGetDouble(POSITION_VOLUME);
      double half = NormalizeVolumeDown(vol * 0.5);

      if(half <= 0.0) continue;

      trade.SetDeviationInPoints((uint)InpDeviation_Points);
      trade.SetExpertMagicNumber(InpMagic);

      if(trade.PositionClosePartial(ticket, half))
         any = true;
   }

   if(!any) Alert("RiskSizer Lite: No position closed (Close50).");
   return any;
}

bool CloseAll()
{
   bool any=false;

   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;

      long magic = (long)PositionGetInteger(POSITION_MAGIC);
      if(magic != (long)InpMagic) continue;

      trade.SetDeviationInPoints((uint)InpDeviation_Points);
      trade.SetExpertMagicNumber(InpMagic);

      if(trade.PositionClose(ticket))
         any = true;
   }

   if(!any) Alert("RiskSizer Lite: No position to close (symbol+magic).");
   return any;
}

//----------------------------- UI Build ----------------------------
bool BuildUI()
{
   GPrefix = PREFIX_BASE + IntegerToString((long)ChartID()) + "_";

   OBJ_BG        = GPrefix + "BG";
   OBJ_HDR       = GPrefix + "HDR";
   OBJ_SEP       = GPrefix + "SEP";

   OBJ_TITLE     = GPrefix + "TITLE";

   OBJ_RISK_BG   = GPrefix + "RISK_BG";
   OBJ_RISK_TXT  = GPrefix + "RISK_TXT";
   OBJ_BTN_RISK_MINUS = GPrefix + "RISK_MINUS";
   OBJ_BTN_RISK_PLUS  = GPrefix + "RISK_PLUS";

   OBJ_BTN_BUY   = GPrefix + "BTN_BUY";
   OBJ_BTN_SELL  = GPrefix + "BTN_SELL";
   OBJ_BTN_RESET = GPrefix + "BTN_RESET";

   OBJ_LINE_A = GPrefix + "LINE_A";
   OBJ_LINE_B = GPrefix + "LINE_B";

   OBJ_SYM_VAL      = GPrefix + "SYM_VAL";
   OBJ_SPREAD_VAL   = GPrefix + "SPR_VAL";
   OBJ_RMONEY_VAL   = GPrefix + "RM_VAL";
   OBJ_USED_RISK_BUY_VAL  = GPrefix + "URB_VAL";
   OBJ_USED_RISK_SELL_VAL = GPrefix + "URS_VAL";
   OBJ_LOW_VAL      = GPrefix + "LOW_VAL";
   OBJ_HIGH_VAL     = GPrefix + "HIGH_VAL";
   OBJ_BUYLOT_VAL   = GPrefix + "BUYLOT_VAL";
   OBJ_SELLLOT_VAL  = GPrefix + "SELLLOT_VAL";

   // Theme
   color PANEL_BG   = (color)C'18,18,18';
   color PANEL_HDR  = (color)C'28,28,28';
   color TXT_MAIN   = clrWhite;
   color TXT_MUTED  = (color)C'180,180,180';

   color BUY_BG     = (color)C'0,140,70';
   color SELL_BG    = (color)C'170,40,40';
   color BTN_BG     = (color)C'45,45,45';
   color EDIT_BG    = (color)C'35,35,35';

   int x=12, y=20, w=320, h=220;

   if(!ObjCreateRectLabel(OBJ_BG, x, y, w, h, PANEL_BG, false, false))
      return false;

   ObjCreateRectLabel(OBJ_HDR, x, y, w, 26, PANEL_HDR, false, false);

   ObjCreateLabel(OBJ_TITLE, "RiskSizer Panel Lite", x+12, y+5, 11);
   StyleLabel(OBJ_TITLE, TXT_MAIN, 11);

   // Risk row label
   ObjCreateLabel(GPrefix+"RISK_LBL", "Risk %", x+12, y+34, 9);
   StyleLabel(GPrefix+"RISK_LBL", TXT_MUTED, 9);

   // ✅ Risk "input" box: NOT selectable, so click becomes CHARTEVENT_CLICK (chart focus stays)
   gRiskX = x+70;
   gRiskY = y+30;
   gRiskW = 62;
   gRiskH = 18;

   ObjCreateRectLabel(OBJ_RISK_BG, gRiskX, gRiskY, gRiskW, gRiskH, EDIT_BG, false, false);
   ObjCreateLabel(OBJ_RISK_TXT, DoubleToString(InpRiskPercent,2), gRiskX+6, gRiskY+2, 9, false);
   StyleLabel(OBJ_RISK_TXT, TXT_MAIN, 9);

   ObjCreateButton(OBJ_BTN_RISK_MINUS, "-", x+135, y+30, 18, 18);
   ObjCreateButton(OBJ_BTN_RISK_PLUS,  "+", x+156, y+30, 18, 18);
   StyleButton(OBJ_BTN_RISK_MINUS, BTN_BG, clrWhite, 10);
   StyleButton(OBJ_BTN_RISK_PLUS,  BTN_BG, clrWhite, 10);

   ObjCreateRectLabel(OBJ_SEP, x+10, y+54, w-20, 1, (color)C'60,60,60', false, false);

   // Left labels
   ObjCreateLabel(GPrefix+"L1", "Symbol",        x+12, y+60,  9);
   ObjCreateLabel(GPrefix+"L2", "Spread",        x+12, y+78,  9);
   ObjCreateLabel(GPrefix+"L3", "RiskMoney",     x+12, y+96,  9);
   ObjCreateLabel(GPrefix+"L4", "UsedRisk BUY",  x+12, y+114, 9);
   ObjCreateLabel(GPrefix+"L5", "UsedRisk SELL", x+12, y+132, 9);
   ObjCreateLabel(GPrefix+"L6", "LOW line",      x+12, y+150, 9);
   ObjCreateLabel(GPrefix+"L7", "HIGH line",     x+12, y+168, 9);
   ObjCreateLabel(GPrefix+"L8", "BUY Lot",       x+12, y+186, 9);
   ObjCreateLabel(GPrefix+"L9", "SELL Lot",      x+12, y+204, 9);

   for(int k=1;k<=9;k++)
      StyleLabel(GPrefix+"L"+IntegerToString(k), TXT_MUTED, 9);

   // Right values
   ObjCreateLabel(OBJ_SYM_VAL,      "-", x+130, y+60,  9);
   ObjCreateLabel(OBJ_SPREAD_VAL,   "-", x+130, y+78,  9);
   ObjCreateLabel(OBJ_RMONEY_VAL,   "-", x+130, y+96,  9);
   ObjCreateLabel(OBJ_USED_RISK_BUY_VAL,  "-", x+130, y+114, 9);
   ObjCreateLabel(OBJ_USED_RISK_SELL_VAL, "-", x+130, y+132, 9);
   ObjCreateLabel(OBJ_LOW_VAL,      "-", x+130, y+150, 9);
   ObjCreateLabel(OBJ_HIGH_VAL,     "-", x+130, y+168, 9);
   ObjCreateLabel(OBJ_BUYLOT_VAL,   "-", x+130, y+186, 9);
   ObjCreateLabel(OBJ_SELLLOT_VAL,  "-", x+130, y+204, 9);

   StyleLabel(OBJ_SYM_VAL,      TXT_MAIN, 9);
   StyleLabel(OBJ_SPREAD_VAL,   TXT_MAIN, 9);
   StyleLabel(OBJ_RMONEY_VAL,   TXT_MAIN, 9);
   StyleLabel(OBJ_USED_RISK_BUY_VAL,  TXT_MAIN, 9);
   StyleLabel(OBJ_USED_RISK_SELL_VAL, TXT_MAIN, 9);
   StyleLabel(OBJ_LOW_VAL,      TXT_MAIN, 9);
   StyleLabel(OBJ_HIGH_VAL,     TXT_MAIN, 9);
   StyleLabel(OBJ_BUYLOT_VAL,   (color)C'0,220,120', 9);
   StyleLabel(OBJ_SELLLOT_VAL,  (color)C'255,90,90', 9);

   // Buttons under panel
   int by = y + h + 6;

   ObjCreateButton(OBJ_BTN_BUY,   "BUY",   x+12,  by, 90, 22);
   ObjCreateButton(OBJ_BTN_SELL,  "SELL",  x+108, by, 90, 22);
   ObjCreateButton(OBJ_BTN_RESET, "Reset", x+204, by, 90, 22);

   StyleButton(OBJ_BTN_BUY,   BUY_BG,  clrWhite, 10);
   StyleButton(OBJ_BTN_SELL,  SELL_BG, clrWhite, 10);
   StyleButton(OBJ_BTN_RESET, BTN_BG,  clrWhite, 10);

   ResetLines();
   return true;
}

void DestroyUI()
{
   int total = ObjectsTotal(0, 0, -1);
   for(int i=total-1; i>=0; i--)
   {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, GPrefix) == 0)
         ObjectDelete(0, name);
   }
}

void UpdateUI()
{
   if(!GUiReady) return;

   ApplyRiskSyncIfNeeded();

   // Preview risk while editing (valid number -> preview lot calculations)
   double riskUse = GRiskPercent;
   if(gRiskEditing)
   {
      double tmp = RiskBufferToDouble(GRiskPercent);
      tmp = Clamp(tmp, 0.01, 50.0);
      riskUse = tmp;
      RiskBoxSetText(gRiskBuffer + " |");
   }
   else
   {
      RiskBoxSetText(DoubleToString(GRiskPercent, 2));
   }

   double ask = GetAsk();
   double bid = GetBid();
   double spreadPts = GetSpreadPoints();

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * (riskUse/100.0);

   double low=0, high=0;
   bool okLH = GetLowHigh(low,high);

   double buyLot=0, buyRM=0, buyLossPerLot=0;
   bool okBuy = false;

   double sellLot=0, sellRM=0, sellLossPerLot=0;
   bool okSell = false;

   if(okLH)
   {
      if(low < ask)
         okBuy = CalcLotByRisk(ask, low, buyLot, buyRM, buyLossPerLot, riskUse);

      if(high > bid)
         okSell = CalcLotByRisk(bid, high, sellLot, sellRM, sellLossPerLot, riskUse);
   }

   double usedBuy  = (okBuy  ? buyLossPerLot  * buyLot  : 0.0);
   double usedSell = (okSell ? sellLossPerLot * sellLot : 0.0);

   ObjectSetString(0, OBJ_SYM_VAL,    OBJPROP_TEXT, _Symbol);
   ObjectSetString(0, OBJ_SPREAD_VAL, OBJPROP_TEXT, DoubleToString(spreadPts,1) + " pts");
   ObjectSetString(0, OBJ_RMONEY_VAL, OBJPROP_TEXT, DoubleToString(riskMoney,2));

   ObjectSetString(0, OBJ_USED_RISK_BUY_VAL,  OBJPROP_TEXT, okBuy  ? DoubleToString(usedBuy,2)  : "N/A");
   ObjectSetString(0, OBJ_USED_RISK_SELL_VAL, OBJPROP_TEXT, okSell ? DoubleToString(usedSell,2) : "N/A");

   ObjectSetString(0, OBJ_LOW_VAL,  OBJPROP_TEXT, okLH ? PriceToStr(low)  : "-");
   ObjectSetString(0, OBJ_HIGH_VAL, OBJPROP_TEXT, okLH ? PriceToStr(high) : "-");

   ObjectSetString(0, OBJ_BUYLOT_VAL,  OBJPROP_TEXT, okBuy  ? DoubleToString(buyLot,2)  : "N/A");
   ObjectSetString(0, OBJ_SELLLOT_VAL, OBJPROP_TEXT, okSell ? DoubleToString(sellLot,2) : "N/A");
}

//----------------------------- MT5 Events --------------------------
int OnInit()
{
   GRiskPercent = InpRiskPercent;

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints((uint)InpDeviation_Points);

   // Keep terminal from eating keyboard actions, but we still receive KEYDOWN events when chart has focus.
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, false);
   ChartSetInteger(0, CHART_QUICK_NAVIGATION, false);

   if(!BuildUI())
      return INIT_FAILED;

   GUiReady = true;
   RequestRiskSync(InpRiskPercent);
   UpdateUI();

   if(!EventSetMillisecondTimer(InpUiRefreshMs))
      EventSetTimer(1);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DestroyUI();
}

void OnTimer()
{
   UpdateUI();
}

void ResetButtonState(const string btnName)
{
   if(ObjectFind(0, btnName) >= 0)
      ObjectSetInteger(0, btnName, OBJPROP_STATE, false);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(!GUiReady) return;

   // 1) Drag lines / prevent moving panel
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
      // lock panel objects from accidental moving (except lines)
      if(IsPanelObject(sparam) && sparam != OBJ_LINE_A && sparam != OBJ_LINE_B)
      {
         RestoreXY(sparam);
         return;
      }

      if(sparam == OBJ_LINE_A || sparam == OBJ_LINE_B)
         UpdateUI();

      return;
   }

   // 2) Chart click hit-test (this is the key to 1-click typing)
   if(id == CHARTEVENT_CLICK)
   {
      int mx = (int)lparam;
      int my = (int)dparam;

      if(HitRiskBox(mx,my))
      {
         if(!gRiskEditing) RiskEditBegin();
         return;
      }
      else
      {
         // click outside while editing -> apply for fast workflow
         if(gRiskEditing) RiskEditApply();
      }
      return;
   }

   // 3) Buttons
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(IsPanelObject(sparam))
         ResetButtonState(sparam);

      if(sparam == OBJ_BTN_BUY)        OpenBuy();
      else if(sparam == OBJ_BTN_SELL)  OpenSell();
      else if(sparam == OBJ_BTN_RESET) ResetLines();
      else if(sparam == OBJ_BTN_RISK_MINUS) { if(gRiskEditing) RiskEditCancel(); RequestRiskSync(GRiskPercent - InpRiskStep); }
      else if(sparam == OBJ_BTN_RISK_PLUS)  { if(gRiskEditing) RiskEditCancel(); RequestRiskSync(GRiskPercent + InpRiskStep); }

      UpdateUI();
      return;
   }

   // 4) Keyboard input for Risk%
   if(id == CHARTEVENT_KEYDOWN)
   {
      if(gRiskEditing)
      {
         int key = (int)lparam;
         RiskHandleKey(key);
         UpdateUI();
      }
      return;
   }
}

void OnTick()
{
   // optional
}
