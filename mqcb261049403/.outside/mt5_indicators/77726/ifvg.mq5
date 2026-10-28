#property copyright   "Inversion Fair Value Gaps"
#property version     "1.00"
#property description "Inversion fair value gaps with signals. Bar-close, no repaint."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Bounce Up"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Bounce Down"

enum ENUM_IFVG_BOUNCE
{
   BOUNCE_CLOSE = 0,   // Close
   BOUNCE_WICK  = 1    // Wick
};

enum ENUM_IFVG_LABEL
{
   LABEL_SMALL  = 0,   // Small
   LABEL_MEDIUM = 1,   // Medium
   LABEL_LARGE  = 2    // Large
};

//---------------------------------------------------------------- inputs (engine first: the dump script passes this prefix; no "input group": it shifts iCustom)
// --- 1. Parameters
input int              InpBoxCount      = 5;            // Show Last
input ENUM_IFVG_BOUNCE InpBounce        = BOUNCE_CLOSE; // Detect Bounce
input int              InpHistoryBars   = 20000;        // History bars (loaded and computed)
// --- 2. Filter
input int              InpAtrLength     = 200;          // ATR Length
input double           InpAtrMultiplier = 0.25;         // ATR Multiplier
input bool             InpRemoveFilled  = true;         // Remove Filled iFVG
// --- 3. Parity
input bool             InpWriteParity   = false;        // Write parity CSV files (MQL5\Files)
// --- 4. Style
input bool             InpShowBull      = true;         // Show Bull IFVG
input bool             InpShowBear      = true;         // Show Bear IFVG
input bool             InpShowMidLine   = true;         // Show MidLine
input bool             InpShowSignals   = true;         // Show Bounce Signals
input int              InpExtend        = 50;           // Extend Active IFVG (bars, 0-100)
input ENUM_IFVG_LABEL  InpLabelSize     = LABEL_MEDIUM; // Signal Label Size
input color            InpBullColor     = clrDarkGreen; // Bull Colour
input color            InpBearColor     = clrMaroon;    // Bear Colour
input color            InpLineColor     = clrGray;      // Mid line colour
input int              InpOpacity       = 40;           // Opacity (5-100, blended with the chart background)
// --- 5. Alerts
input bool             InpAlertBounce   = true;         // Alert on bounce
input bool             InpAlertInversion = false;       // Alert on inversion
input bool             InpUsePopup      = true;         // Popup (Alert)
input bool             InpUseSound      = true;         // Sound
input string           InpSoundFile     = "alert.wav";  // Sound file (terminal Sounds folder)
input bool             InpUsePush       = false;        // Push notification (MetaQuotes ID)
input bool             InpUseMail       = false;        // E-mail (terminal mail settings)
input string           InpTelegramToken = "";           // Telegram: bot token (empty = off, allow api.telegram.org in WebRequest)
input string           InpTelegramChat  = "";           // Telegram: chat id
input bool             InpLogEvents     = true;         // Log every event (Experts tab)

//---------------------------------------------------------------- engine state (single instance per chart)
#define EV_CREATED  0
#define EV_INVERTED 1
#define EV_UP       2
#define EV_DOWN     3
#define EV_FILLED   4

struct Zone
{
   int    left;
   double top;
   int    right;
   double bot;
   double mid;
   int    dir;     // +1 support, -1 resistance (flipped when the gap inverts)
   int    state;   // 0 = just inverted, 1 = active inversion, -1 = filled and kept
   int    xval;    // bar where the gap became an inversion
};

// a bounce label: the reference stores them on the zone and redraws them from there
struct Lab { int zone; int x; double y; int dir; };

int      gBuffer = 500;       // the reference caps each list at 500 entries
double   gO[], gH[], gL[], gC[], gCTop[], gCBot[];
datetime gT[];
int      gCount = 0;          // closed bars fed
int      gFirst = 0;          // chart index of engine bar 0
double   gAtr = 0, gPrevClose = 0;
bool     gLive = false;
int      gEvents = 0;

Zone gZ[];                    // every zone ever created; the lists below hold indexes into it
int  gZn = 0;
int  gBullFvg[], gBearFvg[];  // open gaps
int  gBullInv[], gBearInv[];  // inverted zones, by the list of their origin
Lab  gLabs[];

// the reference's plots that matter to a caller
double gBounceSignal = 0, gIsIfvg = 0;

double gUpBuf[], gDnBuf[];
string gDrawn[];
int    gBarsFile = INVALID_HANDLE, gEvFile = INVALID_HANDLE;

//---------------------------------------------------------------- helpers
double O(int k) { return gO[gCount - 1 - k]; }
double H(int k) { return gH[gCount - 1 - k]; }
double L(int k) { return gL[gCount - 1 - k]; }
double C(int k) { return gC[gCount - 1 - k]; }
double CTop(int k) { return gCTop[gCount - 1 - k]; }
double CBot(int k) { return gCBot[gCount - 1 - k]; }

string TimeStr(datetime t)
{
   MqlDateTime dt; TimeToStruct(t, dt);
   return StringFormat("%04d-%02d-%02d %02d:%02d:%02d", dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
}

string Px(double p) { return DoubleToString(p, _Digits); }

void ListInsert0(int &a[], int v)
{
   int n = ArraySize(a);
   ArrayResize(a, n + 1, 256);
   for(int i = n; i > 0; i--) a[i] = a[i - 1];
   a[0] = v;
}

void ListRemoveAt(int &a[], int i)
{
   int n = ArraySize(a);
   for(int k = i; k < n - 1; k++) a[k] = a[k + 1];
   ArrayResize(a, n - 1, 256);
}

void ResetEngine()
{
   gCount = 0; gAtr = 0; gPrevClose = 0; gEvents = 0; gZn = 0;
   gBounceSignal = 0; gIsIfvg = 0;
   ArrayResize(gO, 0); ArrayResize(gH, 0); ArrayResize(gL, 0); ArrayResize(gC, 0);
   ArrayResize(gCTop, 0); ArrayResize(gCBot, 0); ArrayResize(gT, 0);
   ArrayResize(gZ, 0); ArrayResize(gLabs, 0);
   ArrayResize(gBullFvg, 0); ArrayResize(gBearFvg, 0); ArrayResize(gBullInv, 0); ArrayResize(gBearInv, 0);
   ObjectsDeleteAll(0, "IFVG_");
   ArrayResize(gDrawn, 0);
}

int NewZone(int left, double bot, int right, double top, double mid, int dir)
{
   ArrayResize(gZ, gZn + 1, 1024);
   gZ[gZn].left = left; gZ[gZn].top = top; gZ[gZn].right = right; gZ[gZn].bot = bot; gZ[gZn].mid = mid;
   gZ[gZn].dir = dir; gZ[gZn].state = 0; gZ[gZn].xval = INT_MIN;
   return gZn++;
}

void AddLab(int zone, int x, double y, int dir)
{
   int k = ArraySize(gLabs);
   ArrayResize(gLabs, k + 1, 1024);
   gLabs[k].zone = zone; gLabs[k].x = x; gLabs[k].y = y; gLabs[k].dir = dir;
}

//---------------------------------------------------------------- events
string Token(int type)
{
   switch(type)
   {
      case EV_CREATED:  return "G";
      case EV_INVERTED: return "I";
      case EV_UP:       return "U";
      case EV_DOWN:     return "D";
      default:          return "F";
   }
}

// Built when the event fires. The cTrader indicator builds it after the bar, once InvManage has already flipped the
// polarity, so its inversion line names the opposite role; here the zone's direction is read before the flip.
string Describe(int type, int n, int z)
{
   string when = TimeStr(gT[n]);
   string span = Px(gZ[z].bot) + " - " + Px(gZ[z].top);
   switch(type)
   {
      case EV_CREATED:  return when + " fair value gap " + span;
      case EV_INVERTED: return when + " INVERSION: the zone " + span + " becomes " + (gZ[z].dir == 1 ? "resistance" : "support");
      case EV_UP:       return when + " BULLISH BOUNCE off " + span + " (close " + Px(gC[n]) + ")";
      case EV_DOWN:     return when + " BEARISH BOUNCE off " + span + " (close " + Px(gC[n]) + ")";
      default:          return when + " zone " + span + " filled";
   }
}

bool Wanted(int type)
{
   if(type == EV_UP || type == EV_DOWN) return InpAlertBounce;
   if(type == EV_INVERTED) return InpAlertInversion;
   return false;
}

string JsonEscape(string s)
{
   string r = s;
   StringReplace(r, "\\", "\\\\");
   StringReplace(r, "\"", "\\\"");
   StringReplace(r, "\n", "\\n");
   StringReplace(r, "\r", "");
   StringReplace(r, "\t", "\\t");
   return r;
}

void SendTelegram(string text)
{
   string url = "https://api.telegram.org/bot" + InpTelegramToken + "/sendMessage";
   string body = "{\"chat_id\":\"" + JsonEscape(InpTelegramChat) + "\",\"text\":\"" + JsonEscape(text) + "\"}";
   char data[]; char result[]; string headers;
   int len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8) - 1;
   if(len > 0) ArrayResize(data, len);
   int code = WebRequest("POST", url, "Content-Type: application/json\r\n", 5000, data, result, headers);
   if(code != 200) Print("[IFVG] Telegram KO : ", code, " ", GetLastError());
}

void Notify(int type, string line)
{
   if(InpLogEvents) Print("[IFVG] ", line);
   if(!Wanted(type) || MQLInfoInteger(MQL_TESTER) != 0) return;
   string title = "IFVG " + _Symbol + " : " + (type == EV_INVERTED ? "inversion" : type == EV_UP ? "BOUNCE ▲" : "BOUNCE ▼");
   if(InpUsePopup) Alert(title, " | ", line);
   if(InpUseSound) PlaySound(InpSoundFile);
   if(InpUsePush) SendNotification(title + " | " + line);
   if(InpUseMail) SendMail(title, line);
   if(StringLen(InpTelegramToken) > 0 && StringLen(InpTelegramChat) > 0) SendTelegram(title + "\n" + line);
}

void Emit(int type, int n, int z)
{
   gEvents++;
   if(gEvFile != INVALID_HANDLE)
      FileWrite(gEvFile, IntegerToString(n) + "," + TimeStr(gT[n]) + "," + Token(type) + "," + DoubleToString(gZ[z].top, 8) + "," + DoubleToString(gZ[z].bot, 8));
   if(gLive) Notify(type, Describe(type, n, z));
   else if(InpLogEvents && (type == EV_UP || type == EV_DOWN)) Print("[IFVG] ", Describe(type, n, z));
   int chart = gFirst + n;
   if(type == EV_UP && chart < ArraySize(gUpBuf)) gUpBuf[chart] = gZ[z].bot;
   if(type == EV_DOWN && chart < ArraySize(gDnBuf)) gDnBuf[chart] = gZ[z].top;
}

//---------------------------------------------------------------- engine (IfvgEngine.cs)
// NinjaTrader's ATR: seeded with the first range, then a running mean over min(bar+1, period)
void UpdateAtr(double high, double low, double close, int n)
{
   if(n == 0) { gAtr = high - low; gPrevClose = close; return; }
   double tr = MathMax(high - low, MathMax(MathAbs(high - gPrevClose), MathAbs(low - gPrevClose)));
   int p = MathMin(n + 1, MathMax(1, InpAtrLength));
   gAtr = ((p - 1) * gAtr + tr) / p;
   gPrevClose = close;
}

// a gap whose body is crossed becomes an inversion and changes list
void FvgManage(int &source[], int &inv[], int n)
{
   if(ArraySize(source) >= gBuffer) ListRemoveAt(source, ArraySize(source) - 1);
   for(int i = ArraySize(source) - 1; i >= 0; i--)
   {
      int g = source[i];
      if(gZ[g].dir == 1 && CBot(0) < gZ[g].bot)
      {
         gZ[g].xval = n;
         ListInsert0(inv, g); ListRemoveAt(source, i);
         gIsIfvg = -1;
         Emit(EV_INVERTED, n, g);
      }
      else if(gZ[g].dir == -1 && CTop(0) > gZ[g].top)
      {
         gZ[g].xval = n;
         ListInsert0(inv, g); ListRemoveAt(source, i);
         gIsIfvg = 1;
         Emit(EV_INVERTED, n, g);
      }
   }
}

// flip the polarity on the first pass, then look for bounces and for the fill that kills the zone
void InvManage(int &ary[], int n)
{
   if(ArraySize(ary) >= gBuffer) ListRemoveAt(ary, ArraySize(ary) - 1);
   for(int i = ArraySize(ary) - 1; i >= 0; i--)
   {
      int z = ary[i];
      double top = gZ[z].top, bot = gZ[z].bot;
      int dirBefore = gZ[z].dir, state = gZ[z].state;
      if(state == 0 && dirBefore == 1) { gZ[z].state = 1; gZ[z].dir = -1; }
      else if(state == 0 && dirBefore == -1) { gZ[z].state = 1; gZ[z].dir = 1; }
      int prevDir = dirBefore;                 // the reference keeps the direction as it was before the flip
      int dir = gZ[z].dir; state = gZ[z].state; // and re-reads the current one
      if(state >= 1) gZ[z].right = n;

      double refPrice = InpBounce == BOUNCE_WICK ? H(0) : C(1);
      double refPriceLow = InpBounce == BOUNCE_WICK ? L(0) : C(1);
      if(dir == -1 && prevDir == -1 && state == 1 && C(0) < bot && refPrice >= bot && refPrice < top)
      {
         AddLab(z, n, top, -1);
         gBounceSignal = -1;
         Emit(EV_DOWN, n, z);
      }
      else if(dir == 1 && prevDir == 1 && state == 1 && C(0) > top && refPriceLow <= top && refPriceLow > bot)
      {
         AddLab(z, n, bot, 1);
         gBounceSignal = 1;
         Emit(EV_UP, n, z);
      }

      if(state >= 1 && ((gZ[z].dir == -1 && CTop(0) > top && C(0) > O(0)) || (gZ[z].dir == 1 && CBot(0) < bot && O(0) > C(0))))
      {
         Emit(EV_FILLED, n, z);
         if(!InpRemoveFilled) { gZ[z].state = -1; gZ[z].right = n; }
         else ListRemoveAt(ary, i);
      }
   }
}

void FeedBar(datetime t, double o, double h, double l, double c)
{
   int n = gCount;
   ArrayResize(gO, n + 1, 4096); ArrayResize(gH, n + 1, 4096); ArrayResize(gL, n + 1, 4096); ArrayResize(gC, n + 1, 4096);
   ArrayResize(gCTop, n + 1, 4096); ArrayResize(gCBot, n + 1, 4096); ArrayResize(gT, n + 1, 4096);
   gO[n] = o; gH[n] = h; gL[n] = l; gC[n] = c; gCTop[n] = MathMax(o, c); gCBot[n] = MathMin(o, c); gT[n] = t;
   gCount = n + 1;
   if(gBarsFile != INVALID_HANDLE)
      FileWrite(gBarsFile, IntegerToString(n) + "," + TimeStr(t) + "," + DoubleToString(o, _Digits) + "," + DoubleToString(h, _Digits) + "," + DoubleToString(l, _Digits) + "," + DoubleToString(c, _Digits));

   UpdateAtr(h, l, c, n);
   gBounceSignal = 0;
   if(n < 3) return;

   double filter = gAtr * InpAtrMultiplier;
   gIsIfvg = 0;

   bool bullGap = L(0) > H(2) && C(1) > H(2);
   bool bearGap = H(0) < L(2) && C(1) < L(2);

   if(bullGap && MathAbs(L(0) - H(2)) > filter)
   {
      int g = NewZone(n - 1, MathMin(L(0), H(2)), n, MathMax(L(0), H(2)), (L(0) + H(2)) / 2.0, 1);
      ListInsert0(gBullFvg, g);
      Emit(EV_CREATED, n, g);
   }
   if(bearGap && MathAbs(L(2) - H(0)) > filter)
   {
      int g = NewZone(n - 1, MathMin(L(2), H(0)), n, MathMax(L(2), H(0)), (H(0) + L(2)) / 2.0, -1);
      ListInsert0(gBearFvg, g);
      Emit(EV_CREATED, n, g);
   }

   FvgManage(gBullFvg, gBullInv, n);
   FvgManage(gBearFvg, gBearInv, n);
   InvManage(gBullInv, n);
   InvManage(gBearInv, n);
}

//---------------------------------------------------------------- drawing (the reference's geometry)
// engine index -> time; past the last closed bar the time is extrapolated one period per bar, like a bar index
datetime XT(int x)
{
   int last = gCount - 1;
   if(x <= last) return gT[MathMax(0, x)];
   return (datetime)((long)gT[last] + (long)(x - last) * PeriodSeconds(_Period));
}

// MT5 has no alpha: the cTrader opacity becomes a blend with the chart background, the box drawn behind the candles
color Blend(color c, int alpha)
{
   long bg = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   int br = (int)(bg & 0xFF), bgg = (int)((bg >> 8) & 0xFF), bb = (int)((bg >> 16) & 0xFF);
   int cr = (int)(c & 0xFF), cg = (int)((c >> 8) & 0xFF), cb = (int)((c >> 16) & 0xFF);
   int r = br + (cr - br) * alpha / 255, g = bgg + (cg - bgg) * alpha / 255, b = bb + (cb - bb) * alpha / 255;
   return (color)((b << 16) | (g << 8) | r);
}

void Mark(string name, string &live[])
{
   int k = ArraySize(live);
   ArrayResize(live, k + 1, 64);
   live[k] = name;
   for(int i = 0; i < ArraySize(gDrawn); i++) if(gDrawn[i] == name) return;
   k = ArraySize(gDrawn);
   ArrayResize(gDrawn, k + 1, 64);
   gDrawn[k] = name;
}

void Rect(string name, int x1, double y1, int x2, double y2, color c, string &live[])
{
   if(y1 == 0 || y2 == 0) return;
   if(x2 <= x1) x2 = x1 + 1;
   datetime t1 = XT(x1), t2 = XT(x2);
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, y1, t2, y2);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectMove(0, name, 0, t1, y1);
      ObjectMove(0, name, 1, t2, y2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, Blend(c, MathMax(10, InpOpacity * 255 / 100)));
   Mark(name, live);
}

void Seg(string name, int x1, double y, int x2, color c, string &live[])
{
   if(y == 0) return;
   if(x2 <= x1) x2 = x1 + 1;
   datetime t1 = XT(x1), t2 = XT(x2);
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, y, t2, y);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else
   {
      ObjectMove(0, name, 0, t1, y);
      ObjectMove(0, name, 1, t2, y);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, Blend(c, 200));
   Mark(name, live);
}

void Arrow(string name, int x, double y, int dir, string &live[])
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, XT(x), y);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   else ObjectMove(0, name, 0, XT(x), y);
   ObjectSetString(0, name, OBJPROP_TEXT, dir == 1 ? "▲" : "▼");
   ObjectSetInteger(0, name, OBJPROP_COLOR, dir == 1 ? InpBullColor : InpBearColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpLabelSize == LABEL_LARGE ? 16 : InpLabelSize == LABEL_MEDIUM ? 12 : 9);
   // below the zone for a bullish bounce, above it for a bearish one
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, dir == 1 ? ANCHOR_UPPER : ANCHOR_LOWER);
   Mark(name, live);
}

void DrawList(int &ary[], string prefix, bool showBox, string &live[], int now)
{
   int extend = MathMax(0, MathMin(100, InpExtend));
   for(int i = 0; i < ArraySize(ary) && i < InpBoxCount; i++)
   {
      int id = ary[i];
      if(gZ[id].xval == INT_MIN || gZ[id].left == INT_MIN) continue;
      // the reference: the half before the inversion keeps the gap's original colour, the half after takes the other
      color first = gZ[id].dir == -1 ? InpBullColor : InpBearColor;
      color second = gZ[id].dir == -1 ? InpBearColor : InpBullColor;
      string p = "IFVG_" + prefix + IntegerToString(gZ[id].left) + "_";
      int xEnd = gZ[id].state < 1 ? gZ[id].right : now;
      if(showBox)
      {
         Rect(p + "M", gZ[id].left, gZ[id].top, gZ[id].xval, gZ[id].bot, first, live);
         Rect(p + "O", gZ[id].xval, gZ[id].top, xEnd, gZ[id].bot, second, live);
         if(gZ[id].state >= 1 && extend > 0) Rect(p + "E", now, gZ[id].top, now + extend, gZ[id].bot, second, live);
      }
      if(InpShowMidLine)
      {
         Seg(p + "L1", gZ[id].left, gZ[id].mid, xEnd, InpLineColor, live);
         if(gZ[id].state >= 1 && extend > 0) Seg(p + "L2", now, gZ[id].mid, now + extend, InpLineColor, live);
      }
      if(!InpShowSignals) continue;
      for(int k = 0; k < ArraySize(gLabs); k++)
      {
         if(gLabs[k].zone != id) continue;
         Arrow("IFVG_lab" + IntegerToString(gLabs[k].x) + "_" + IntegerToString(gLabs[k].dir), gLabs[k].x, gLabs[k].y, gLabs[k].dir, live);
      }
   }
}

void Redraw()
{
   if(gCount < 1) return;
   string live[];
   int now = gCount - 1;
   DrawList(gBullInv, "FVGP", InpShowBear, live, now);   // zones born bullish, now resistance
   DrawList(gBearInv, "FVGN", InpShowBull, live, now);
   for(int i = ArraySize(gDrawn) - 1; i >= 0; i--)
   {
      bool keep = false;
      for(int k = 0; k < ArraySize(live); k++) if(live[k] == gDrawn[i]) { keep = true; break; }
      if(keep) continue;
      ObjectDelete(0, gDrawn[i]);
      int n = ArraySize(gDrawn);
      gDrawn[i] = gDrawn[n - 1];
      ArrayResize(gDrawn, n - 1, 64);
   }
   ChartRedraw(0);
}

//---------------------------------------------------------------- parity files
void OpenParityFiles(int total)
{
   string stem = "ifvg_" + _Symbol + "_" + EnumToString(_Period);
   StringReplace(stem, "PERIOD_", "");
   gBarsFile = FileOpen(stem + "_bars.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   gEvFile = FileOpen(stem + "_events.csv", FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(gBarsFile == INVALID_HANDLE || gEvFile == INVALID_HANDLE) { Print("[IFVG] parity files KO : ", GetLastError()); return; }
   FileWrite(gBarsFile, "# count=" + IntegerToString(total) + " atrlen=" + IntegerToString(InpAtrLength) + " atrmult=" + DoubleToString(InpAtrMultiplier, 4) +
             " bounce=" + (InpBounce == BOUNCE_WICK ? "wick" : "close") + " removefilled=" + (InpRemoveFilled ? "1" : "0") + " history=" + IntegerToString(InpHistoryBars));
   FileWrite(gBarsFile, "index,time,open,high,low,close");
   FileWrite(gEvFile, "index,time,token,top,bot");
   Print("[IFVG] parity files: MQL5\\Files\\", stem, "_bars.csv / _events.csv");
}

void CloseParityFiles()
{
   if(gBarsFile != INVALID_HANDLE) { FileClose(gBarsFile); gBarsFile = INVALID_HANDLE; }
   if(gEvFile != INVALID_HANDLE) { FileClose(gEvFile); gEvFile = INVALID_HANDLE; }
}

//---------------------------------------------------------------- MQL5 entry points
int OnInit()
{
   SetIndexBuffer(0, gUpBuf, INDICATOR_DATA);
   SetIndexBuffer(1, gDnBuf, INDICATOR_DATA);
   ArraySetAsSeries(gUpBuf, false);
   ArraySetAsSeries(gDnBuf, false);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "IFVG");
   ResetEngine();
   Print("[IFVG] Inversion Fair Value Gaps, show last ", InpBoxCount, ", bounce on ", (InpBounce == BOUNCE_WICK ? "Wick" : "Close"),
         ", ATR ", InpAtrLength, " x ", DoubleToString(InpAtrMultiplier, 2), ", remove filled ", InpRemoveFilled,
         ", history ", InpHistoryBars, " bars, parity ", InpWriteParity);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   CloseParityFiles();
   ObjectsDeleteAll(0, "IFVG_");
   ChartRedraw(0);
}

void FullPass(const int rates_total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   CloseParityFiles();
   ResetEngine();
   gLive = false;
   ArrayInitialize(gUpBuf, EMPTY_VALUE);
   ArrayInitialize(gDnBuf, EMPTY_VALUE);
   gFirst = MathMax(0, rates_total - InpHistoryBars);
   if(InpWriteParity) OpenParityFiles(rates_total - 1 - gFirst);
   for(int i = gFirst; i < rates_total - 1; i++) FeedBar(time[i], open[i], high[i], low[i], close[i]);
   CloseParityFiles();
   Print("[IFVG] history loaded: ", gCount, " bars (from chart index ", gFirst, "), ", gEvents, " events, ",
         ArraySize(gBullInv), " active zones born bullish, ", ArraySize(gBearInv), " born bearish.");
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
   if(rates_total < 2) return 0;
   // the engine maps bar gFirst + k to its bar k; if the terminal shifted or rewrote the history, start over
   bool shifted = gCount > 0 && (gFirst + gCount - 1 >= rates_total || time[gFirst + gCount - 1] != gT[gCount - 1]);
   if(prev_calculated == 0 || shifted)
   {
      FullPass(rates_total, time, open, high, low, close);
      Redraw();
      return rates_total;
   }
   gLive = true;
   for(int i = MathMax(0, prev_calculated - 1); i < rates_total; i++) { gUpBuf[i] = EMPTY_VALUE; gDnBuf[i] = EMPTY_VALUE; }
   int before = gCount;
   for(int i = gFirst + gCount; i < rates_total - 1; i++) FeedBar(time[i], open[i], high[i], low[i], close[i]);
   if(gCount != before) Redraw();
   return rates_total;
}
//+------------------------------------------------------------------+
