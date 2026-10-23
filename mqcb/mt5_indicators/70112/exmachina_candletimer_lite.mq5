//+------------------------------------------------------------------+
//|                                   ExMachina_CandleTimer_Lite.mq5 |
//|                                        ExMachina Trading Systems |
//|                          CandleTimer Lite · Steel Palette · 2026 |
//+------------------------------------------------------------------+
#property copyright   "ExMachina Trading Systems"
#property link        "https://www.mql5.com/en/users/algosphere-quant"
#property version     "1.00"
#property description "ExMachina CandleTimer Lite"
#property description "Candle countdown timer with steel palette theme"
#property description "Digital clock · Progress bar · Flash alert · Sound"
#property description " "
#property description "Full version with 7 panels: mql5.com/en/market"
#property indicator_chart_window
#property indicator_plots 0

//+------------------------------------------------------------------+
//| STEEL PALETTE — ExMachina Official                               |
//+------------------------------------------------------------------+
#define CLR_BASE          C'8,10,18'
#define CLR_PANEL         C'12,15,26'
#define CLR_CARD          C'18,22,36'
#define CLR_INSET         C'10,12,22'
#define CLR_EDGE          C'32,38,58'
#define CLR_GLOW          C'55,70,110'

#define CLR_HI            C'220,226,240'
#define CLR_LO            C'95,105,130'
#define CLR_DIM           C'55,62,85'
#define CLR_MUTED         C'106,126,152'
#define CLR_CHROME        C'170,178,200'
#define CLR_CHROME_BR     C'210,216,232'
#define CLR_CHROME_DK     C'120,130,158'

#define CLR_STEEL         C'58,90,140'
#define CLR_STEEL_LT      C'90,130,184'
#define CLR_ACCENT        C'80,128,192'

#define CLR_UP            C'45,210,160'
#define CLR_DN            C'240,75,80'
#define CLR_WARN          C'245,175,55'

#define FN_UI             "Segoe UI"
#define FN_NUM            "Consolas"
#define FN_HEAD           "Segoe UI Semibold"
#define SZ_H1             11
#define SZ_H2             9
#define SZ_SM             7
#define SZ_TIMER          22

//+------------------------------------------------------------------+
//| ENUMS                                                            |
//+------------------------------------------------------------------+
enum ENUM_TIMER_STYLE { STYLE_DIGITAL, STYLE_PROGRESS, STYLE_BOTH };
enum ENUM_CHART_THEME_MODE { THEME_FULL, THEME_OPAQUE_ONLY, THEME_NONE };
enum ENUM_PANEL_SIDE { SIDE_RIGHT, SIDE_LEFT };

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input group           "══════ LAYOUT ══════"
input ENUM_PANEL_SIDE  InpSide        = SIDE_RIGHT;   // Panel Side
input int              InpMargin      = 8;             // Margin from edge (px)
input int              InpYOffset     = 20;            // Y Offset (px)
input int              InpPanelWidth  = 220;           // Panel Width (px)

input group           "══════ THEME ══════"
input ENUM_CHART_THEME_MODE InpThemeMode = THEME_FULL; // Chart Theme Mode

input group           "══════ TIMER ══════"
input ENUM_TIMER_STYLE InpTimerStyle  = STYLE_BOTH;    // Timer Display Style
input bool             InpShowSeconds = true;           // Show Seconds
input bool             InpFlashLast10 = true;           // Flash last 10 seconds
input bool             InpSoundAlert  = false;          // Sound on new bar

//+------------------------------------------------------------------+
//| GLOBALS                                                          |
//+------------------------------------------------------------------+
string PRE = "EXM_LT_";

int g_padX = 10;
datetime g_lastBar   = 0;
bool     g_collapsed = false;
uint     g_lastClick = 0;

struct SChartBak
{
   color bg; color fg; color grid; color bullC; color bearC;
   color upC; color dnC; color lineC; color volC;
   color bidC; color askC; color stopC;
   bool  chartFg; bool saved;
};
SChartBak g_bak;

//+------------------------------------------------------------------+
int OnInit()
{
   g_bak.saved = false;
   g_collapsed = false;
   
   if(InpThemeMode == THEME_FULL)        ApplyChartTheme();
   else if(InpThemeMode == THEME_OPAQUE_ONLY)
   { SaveTheme(); ChartSetInteger(0,CHART_FOREGROUND,false); ChartRedraw(0); }
   
   EventSetMillisecondTimer(250);
   Draw();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PRE);
   EventKillTimer();
   RestoreTheme();
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   if(InpSoundAlert)
   {
      datetime curBar = iTime(_Symbol,_Period,0);
      if(g_lastBar!=0 && curBar!=g_lastBar) PlaySound("alert.wav");
      g_lastBar = curBar;
   }
   Draw();
   return(rates_total);
}

void OnTimer() { Draw(); }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE) Draw();
   
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == PRE+"BTN_TOG")
   {
      uint now = GetTickCount();
      if(now - g_lastClick < 200) return;
      g_lastClick = now;
      g_collapsed = !g_collapsed;
      ObjectSetInteger(0, PRE+"BTN_TOG", OBJPROP_STATE, false);
      if(g_collapsed) HideAllContent();
      Draw();
   }
}

//+------------------------------------------------------------------+
//| CHART THEME                                                      |
//+------------------------------------------------------------------+
void SaveTheme()
{
   if(g_bak.saved) return;
   g_bak.bg     = (color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   g_bak.fg     = (color)ChartGetInteger(0,CHART_COLOR_FOREGROUND);
   g_bak.grid   = (color)ChartGetInteger(0,CHART_COLOR_GRID);
   g_bak.bullC  = (color)ChartGetInteger(0,CHART_COLOR_CANDLE_BULL);
   g_bak.bearC  = (color)ChartGetInteger(0,CHART_COLOR_CANDLE_BEAR);
   g_bak.upC    = (color)ChartGetInteger(0,CHART_COLOR_CHART_UP);
   g_bak.dnC    = (color)ChartGetInteger(0,CHART_COLOR_CHART_DOWN);
   g_bak.lineC  = (color)ChartGetInteger(0,CHART_COLOR_CHART_LINE);
   g_bak.volC   = (color)ChartGetInteger(0,CHART_COLOR_VOLUME);
   g_bak.bidC   = (color)ChartGetInteger(0,CHART_COLOR_BID);
   g_bak.askC   = (color)ChartGetInteger(0,CHART_COLOR_ASK);
   g_bak.stopC  = (color)ChartGetInteger(0,CHART_COLOR_STOP_LEVEL);
   g_bak.chartFg= (bool)ChartGetInteger(0,CHART_FOREGROUND);
   g_bak.saved  = true;
}

void ApplyChartTheme()
{
   SaveTheme();
   ChartSetInteger(0,CHART_FOREGROUND,false);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,  CLR_BASE);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,  CLR_LO);
   ChartSetInteger(0,CHART_COLOR_GRID,        C'14,17,30');
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL, CLR_CHROME_BR);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR, C'30,35,55');
   ChartSetInteger(0,CHART_COLOR_CHART_UP,    CLR_CHROME);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,  CLR_CHROME_DK);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,  CLR_CHROME);
   ChartSetInteger(0,CHART_COLOR_VOLUME,      C'35,42,65');
   ChartSetInteger(0,CHART_COLOR_BID,         CLR_CHROME_DK);
   ChartSetInteger(0,CHART_COLOR_ASK,         CLR_DIM);
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,  CLR_DN);
   ChartRedraw(0);
}

void RestoreTheme()
{
   if(!g_bak.saved) return;
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,  g_bak.bg);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,  g_bak.fg);
   ChartSetInteger(0,CHART_COLOR_GRID,        g_bak.grid);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL, g_bak.bullC);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR, g_bak.bearC);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,    g_bak.upC);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,  g_bak.dnC);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,  g_bak.lineC);
   ChartSetInteger(0,CHART_COLOR_VOLUME,      g_bak.volC);
   ChartSetInteger(0,CHART_COLOR_BID,         g_bak.bidC);
   ChartSetInteger(0,CHART_COLOR_ASK,         g_bak.askC);
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,  g_bak.stopC);
   ChartSetInteger(0,CHART_FOREGROUND,        g_bak.chartFg);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| POSITIONING                                                      |
//+------------------------------------------------------------------+
int PanelX()
{
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   if(InpSide == SIDE_RIGHT) return MathMax(0, chartW - InpPanelWidth - InpMargin);
   return InpMargin;
}

//+------------------------------------------------------------------+
//| MASTER DRAW                                                      |
//+------------------------------------------------------------------+
void Draw()
{
   if(g_collapsed) DrawCollapsed();
   else            DrawExpanded();
}

//+------------------------------------------------------------------+
//| COLLAPSED — compact strip with live countdown                    |
//+------------------------------------------------------------------+
void DrawCollapsed()
{
   int x = PanelX();
   int W = InpPanelWidth;
   int y = InpYOffset;
   int R = x + W - g_padX - 4;
   int stripH = 30;
   
   Box(PRE+"SH",  x-1, y-1, W+2, stripH+2, CLR_BASE,  CLR_BASE);
   Box(PRE+"BG",  x,   y,   W,   stripH,   CLR_PANEL, CLR_EDGE);
   Box(PRE+"GL",  x+1, y,   W-2, 2,        CLR_GLOW,  CLR_GLOW);
   Box(PRE+"TBG", x+1, y+1, W-2, stripH-2, CLR_INSET, CLR_INSET);
   Box(PRE+"TGL", x+1, y+stripH-1, W-2, 1, CLR_STEEL, CLR_STEEL);
   
   Txt(PRE+"TNM", x+g_padX, y+5, "EXM", CLR_CHROME, SZ_H2, FN_HEAD);
   Txt(PRE+"TDOT", x+g_padX+28, y+5, "·", CLR_DIM, SZ_H2, FN_UI);
   Txt(PRE+"TSY", x+g_padX+36, y+6, _Symbol+" "+TFStr(_Period), CLR_CHROME_DK, SZ_SM, FN_NUM);
   
   int rem = GetRemainingSeconds();
   int mins = (rem%3600)/60, secs = rem%60;
   color tmClr = CLR_HI;
   if(InpFlashLast10 && rem<=10 && rem>0)
      tmClr = (rem%2==0) ? CLR_WARN : CLR_DN;
   Txt(PRE+"TTMR", R-30, y+5, StringFormat("%02d:%02d",mins,secs), tmClr, SZ_H2, FN_NUM);
   
   Btn(PRE+"BTN_TOG", x+W-28, y+4, 22, 22, "+", CLR_CARD, CLR_CHROME);
   
   // Hide expanded-only elements
   HideObj(PRE+"FTL"); HideObj(PRE+"FTR"); HideObj(PRE+"TSUB");
   HideObj(PRE+"CD0");
   HidePanelGroup("T_");
   
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| EXPANDED — timer panel with branding                             |
//+------------------------------------------------------------------+
void DrawExpanded()
{
   int x = PanelX();
   int W = InpPanelWidth;
   int y = InpYOffset;
   int R = x + W - g_padX - 4;
   int L = x + g_padX;
   
   int hdrH = 38;   // title block
   int tmrH = CalcTimerH();
   int ftrH = 32;   // footer with promo
   int totalH = hdrH + tmrH + 4 + ftrH;
   
   // ── Backgrounds ──
   Box(PRE+"SH",  x-1,  y-1,  W+2, totalH+2, CLR_BASE,  CLR_BASE);
   Box(PRE+"BG",  x,    y,    W,   totalH,   CLR_PANEL, CLR_EDGE);
   Box(PRE+"GL",  x+1,  y,    W-2, 2,        CLR_GLOW,  CLR_GLOW);
   Box(PRE+"TBG", x+1,  y+1,  W-2, hdrH-3,  CLR_INSET, CLR_INSET);
   Box(PRE+"TGL", x+1,  y+hdrH-2, W-2, 2,   CLR_STEEL, CLR_STEEL);
   
   // Timer card
   int cardY = y + hdrH;
   Box(PRE+"CD0", x+4, cardY, W-8, tmrH, CLR_CARD, CLR_EDGE);
   
   // ── Title bar ──
   int rem = GetRemainingSeconds();
   bool blink = (InpFlashLast10 && rem<=10 && rem>0 && rem%2==0);
   
   Txt(PRE+"TNM", L, y+6,
       blink ? "EXMACHINA  ●" : "EXMACHINA",
       blink ? CLR_WARN : CLR_CHROME_BR, SZ_H1, FN_HEAD);
   Btn(PRE+"BTN_TOG", x+W-28, y+4, 22, 22, "–", CLR_CARD, CLR_CHROME);
   Txt(PRE+"TSUB", L, y+22, "CandleTimer Lite", CLR_STEEL_LT, SZ_SM, FN_UI);
   Txt(PRE+"TSY", R, y+22, _Symbol+" "+TFStr(_Period), CLR_CHROME_DK, SZ_SM, FN_NUM, ANCHOR_RIGHT_UPPER);
   
   // Hide collapsed-only
   HideObj(PRE+"TDOT"); HideObj(PRE+"TTMR");
   
   // ── Timer content ──
   int ty = cardY + 6;
   ty = DrawTimer(x, ty, W, R);
   
   // ── Footer — brand + promo ──
   int fy = y + totalH - ftrH + 4;
   Txt(PRE+"FTL", L, fy, "ExMachina Trading Systems", CLR_DIM, SZ_SM, FN_UI);
   Txt(PRE+"FTR", R, fy, "Lite", CLR_DIM, SZ_SM, FN_NUM, ANCHOR_RIGHT_UPPER);
   Txt(PRE+"FTP", L, fy+14, "Full version: 7 panels on MQL5 Market", CLR_STEEL, SZ_SM, FN_UI);
   
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| TIMER HEIGHT                                                     |
//+------------------------------------------------------------------+
int CalcTimerH()
{
   int h = 6 + 14;  // pad + section head
   if(InpTimerStyle==STYLE_DIGITAL || InpTimerStyle==STYLE_BOTH)
      h += (int)(SZ_TIMER*1.4) + 2;
   if(InpTimerStyle==STYLE_PROGRESS || InpTimerStyle==STYLE_BOTH)
      h += 5 + 6;
   h += 13 + 4;  // elapsed/left row + pad
   return h;
}

//+------------------------------------------------------------------+
//| TIMER PANEL                                                      |
//+------------------------------------------------------------------+
int DrawTimer(int x, int y, int W, int R)
{
   int L = x + g_padX;
   
   Txt(PRE+"T_SH", L, y, "COUNTDOWN", CLR_CHROME_DK, SZ_SM, FN_HEAD);
   y += 14;
   
   int perSec = PeriodSeconds(_Period);
   int rem = GetRemainingSeconds();
   int hrs = rem/3600, mins = (rem%3600)/60, secs = rem%60;
   double pctE = 1.0 - (double)rem / MathMax(1,(double)perSec);
   pctE = MathMax(0, MathMin(1, pctE));
   
   color tC = CLR_HI;
   if(InpFlashLast10 && rem<=10 && rem>0)
      tC = (rem%2==0) ? CLR_WARN : CLR_DN;
   
   if(InpTimerStyle==STYLE_DIGITAL || InpTimerStyle==STYLE_BOTH)
   {
      string ts;
      if(hrs > 0)             ts = StringFormat("%02d:%02d:%02d", hrs, mins, secs);
      else if(InpShowSeconds) ts = StringFormat("  %02d:%02d", mins, secs);
      else                    ts = StringFormat("  %02d min", mins);
      Txt(PRE+"T_DIG", L+16, y, ts, tC, SZ_TIMER, FN_NUM);
      y += (int)(SZ_TIMER * 1.4) + 2;
   }
   
   if(InpTimerStyle==STYLE_PROGRESS || InpTimerStyle==STYLE_BOTH)
   {
      int bW = W - g_padX*2, bH = 5;
      Box(PRE+"T_PBG", L, y, bW, bH, CLR_INSET, CLR_EDGE);
      int fW = MathMax(1, (int)((bW-2)*pctE));
      color pC = CLR_ACCENT;
      if(pctE > 0.85) pC = CLR_WARN;
      if(pctE > 0.95) pC = CLR_DN;
      Box(PRE+"T_PFL", L+1, y+1, fW, bH-2, pC, pC);
      Txt(PRE+"T_PCT", R, y-1, DoubleToString(pctE*100,0)+"%", CLR_DIM, SZ_SM, FN_NUM, ANCHOR_RIGHT_UPPER);
      y += bH + 6;
   }
   
   Txt(PRE+"T_EL", L, y, FmtTime(perSec-rem)+" elapsed  ·  "+FmtTime(rem)+" left", CLR_LO, SZ_SM, FN_NUM);
   y += 13 + 4;
   return y;
}

//+------------------------------------------------------------------+
//| UTILITY                                                          |
//+------------------------------------------------------------------+
int GetRemainingSeconds()
{
   datetime barT = iTime(_Symbol,_Period,0);
   int perSec = PeriodSeconds(_Period);
   return MathMax(0, (int)((barT+perSec)-TimeCurrent()));
}

string FmtTime(int secs)
{
   if(secs < 0) secs = 0;
   int h=secs/3600, m=(secs%3600)/60, s=secs%60;
   if(h > 0) return StringFormat("%dh%02dm%02ds",h,m,s);
   if(m > 0) return StringFormat("%dm%02ds",m,s);
   return StringFormat("%ds",s);
}

string TFStr(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:return"M1";  case PERIOD_M2:return"M2";
      case PERIOD_M3:return"M3";  case PERIOD_M4:return"M4";
      case PERIOD_M5:return"M5";  case PERIOD_M6:return"M6";
      case PERIOD_M10:return"M10";case PERIOD_M12:return"M12";
      case PERIOD_M15:return"M15";case PERIOD_M20:return"M20";
      case PERIOD_M30:return"M30";case PERIOD_H1:return"H1";
      case PERIOD_H2:return"H2";  case PERIOD_H3:return"H3";
      case PERIOD_H4:return"H4";  case PERIOD_H6:return"H6";
      case PERIOD_H8:return"H8";  case PERIOD_H12:return"H12";
      case PERIOD_D1:return"D1";  case PERIOD_W1:return"W1";
      case PERIOD_MN1:return"MN"; default:return"??";
   }
}

//+------------------------------------------------------------------+
//| OBJECT WRAPPERS                                                  |
//+------------------------------------------------------------------+
void Box(string name,int x,int y,int w,int h,color bg,color brd)
{
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,brd);
}

void Txt(string name,int x,int y,string text,color clr,int size=8,
         string fnt=FN_UI,int anchor=ANCHOR_LEFT_UPPER)
{
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,fnt);
}

void Btn(string name,int x,int y,int w,int h,string text,color bg,color tc)
{
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tc);
   ObjectSetString(0,name,OBJPROP_FONT,FN_HEAD);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,SZ_H1);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,100);
}

void HideObj(string name)
{
   if(ObjectFind(0,name)>=0)
   { ObjectSetInteger(0,name,OBJPROP_XDISTANCE,-5000); ObjectSetInteger(0,name,OBJPROP_YDISTANCE,-5000); }
}

void HidePanelGroup(string prefix)
{
   string full = PRE + prefix;
   int total = ObjectsTotal(0,0,-1);
   for(int i=total-1; i>=0; i--)
   {
      string name = ObjectName(0,i,0,-1);
      if(StringFind(name,full)==0) HideObj(name);
   }
}

void HideAllContent()
{
   string prefixes[] = {"T_","CD","FT","TSUB"};
   for(int p=0; p<ArraySize(prefixes); p++) HidePanelGroup(prefixes[p]);
}
//+------------------------------------------------------------------+
