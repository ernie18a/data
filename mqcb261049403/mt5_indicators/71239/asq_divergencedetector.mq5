//+------------------------------------------------------------------+
//|                                    ASQ_DivergenceDetector.mq5    |
//|                              Copyright 2026, AlgoSphere Quant    |
//|                      https://www.mql5.com/en/users/robin2.0      |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, AlgoSphere Quant"
#property link        "https://www.mql5.com/en/users/robin2.0"
#property version     "3.00"
#property description "ASQ Divergence Detector v3.00"
#property description "Multi-oscillator divergence: RSI, MACD, Stochastic, CCI."
#property description "Non-repaint arrows, divergence trendlines, strength scoring,"
#property description "enhanced dashboard, and configurable alerts."
#property description ""
#property description "Free & open-source. AlgoSphere Quant — Precision before profit."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property strict

//--- Plot 1: Divergence arrows
#property indicator_label1  "Divergence"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrLimeGreen,clrCrimson,clrDodgerBlue,clrGold
#property indicator_width1  3

//--- Plot 2: Strength dots
#property indicator_label2  "Strength"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrLimeGreen,clrCrimson,clrDodgerBlue,clrGold
#property indicator_width2  1

//+------------------------------------------------------------------+
//| ENUMS                                                             |
//+------------------------------------------------------------------+
enum ENUM_DIV_OSCILLATOR
  {
   DIV_RSI        = 0, // RSI
   DIV_MACD       = 1, // MACD
   DIV_STOCHASTIC = 2, // Stochastic
   DIV_CCI        = 3  // CCI
  };

enum ENUM_DIV_TYPE
  {
   DIV_REG_BULL = 0,
   DIV_REG_BEAR = 1,
   DIV_HID_BULL = 2,
   DIV_HID_BEAR = 3
  };

//+------------------------------------------------------------------+
//| INPUTS                                                            |
//+------------------------------------------------------------------+
input group "══════ Oscillator ══════"
input ENUM_DIV_OSCILLATOR InpOscillator  = DIV_RSI;  // Primary oscillator
input int    InpRSIPeriod      = 14;    // RSI period
input int    InpMACDFast       = 12;    // MACD fast EMA
input int    InpMACDSlow       = 26;    // MACD slow EMA
input int    InpMACDSignal     = 9;     // MACD signal
input int    InpStochK         = 14;    // Stochastic %K period
input int    InpStochD         = 3;     // Stochastic %D period
input int    InpStochSlowing   = 3;     // Stochastic slowing
input int    InpCCIPeriod      = 20;    // CCI period

input group "══════ Detection ══════"
input int    InpSwingLen       = 5;     // Swing length (bars each side)
input int    InpLookback       = 100;   // Max lookback for previous swing
input bool   InpShowRegular    = true;  // Show regular divergences
input bool   InpShowHidden     = true;  // Show hidden divergences
input double InpMinOscDiff     = 2.0;   // Min oscillator difference (filter noise)

input group "══════ Visuals ══════"
input bool   InpShowLabels     = true;  // Show text labels on chart
input bool   InpShowTrendlines = true;  // Draw divergence trendlines
input int    InpTrendlineWidth = 1;     // Trendline width
input ENUM_LINE_STYLE InpTrendlineStyle = STYLE_DOT; // Trendline style
input int    InpArrowOffset    = 50;    // Arrow offset from price (points)

input group "══════ Alerts ══════"
input bool   InpAlertPopup     = true;  // Alert popup
input bool   InpAlertSound     = true;  // Alert sound
input bool   InpAlertPush      = false; // Push notification
input bool   InpAlertEmail     = false; // Email notification
input int    InpAlertCooldown  = 300;   // Alert cooldown (seconds)

input group "══════ Dashboard ══════"
input bool   InpShowDashboard  = true;  // Show stats dashboard
input int    InpDashX          = 20;    // Dashboard X offset (px)
input int    InpDashY          = 40;    // Dashboard Y offset (px)
input int    InpDashFontSize   = 9;     // Font size
input color  InpDashBgColor    = C'8,10,18';    // Background color

//+------------------------------------------------------------------+
//| GLOBALS                                                           |
//+------------------------------------------------------------------+
const string OBJ_PREFIX = "ASQDD_";

double   BuffArrow[], BuffArrowColor[];
double   BuffStrength[], BuffStrengthColor[];

int      g_oscHandle  = INVALID_HANDLE;
int      g_regBull = 0, g_regBear = 0;
int      g_hidBull = 0, g_hidBear = 0;
string   g_lastDivType = "---", g_lastDivBar = "---";
double   g_lastDivStrength = 0;
datetime g_lastAlertTime   = 0;

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSwingLen < 2)
     { Print("[ASQ DivDetector] ERROR: Swing length must be >= 2"); return(INIT_PARAMETERS_INCORRECT); }

   SetIndexBuffer(0, BuffArrow,         INDICATOR_DATA);
   SetIndexBuffer(1, BuffArrowColor,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BuffStrength,      INDICATOR_DATA);
   SetIndexBuffer(3, BuffStrengthColor, INDICATOR_COLOR_INDEX);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, C'0,185,140');
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, C'220,50,80');
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, C'90,180,220');
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, C'200,170,50');

   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, C'0,185,140');
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 1, C'220,50,80');
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 2, C'90,180,220');
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 3, C'200,170,50');

   g_oscHandle = CreateOscHandle();
   if(g_oscHandle == INVALID_HANDLE)
     { Print("[ASQ DivDetector] ERROR: Oscillator handle failed"); return(INIT_FAILED); }

   string oscName = OscName();
   IndicatorSetString(INDICATOR_SHORTNAME, "ASQ Div (" + oscName + ")");
   if(InpShowDashboard) CreateDashboard(oscName);

   Print("[ASQ DivDetector] v3.00 | ", _Symbol, " | ", oscName,
         " | Swing:", InpSwingLen, " | Lookback:", InpLookback);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(g_oscHandle != INVALID_HANDLE) { IndicatorRelease(g_oscHandle); g_oscHandle = INVALID_HANDLE; }
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Oscillator handle factory                                         |
//+------------------------------------------------------------------+
int CreateOscHandle()
  {
   switch(InpOscillator)
     {
      case DIV_RSI:        return iRSI(_Symbol, PERIOD_CURRENT, InpRSIPeriod, PRICE_CLOSE);
      case DIV_MACD:       return iMACD(_Symbol, PERIOD_CURRENT, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
      case DIV_STOCHASTIC: return iStochastic(_Symbol, PERIOD_CURRENT, InpStochK, InpStochD, InpStochSlowing, MODE_SMA, STO_LOWHIGH);
      case DIV_CCI:        return iCCI(_Symbol, PERIOD_CURRENT, InpCCIPeriod, PRICE_TYPICAL);
     }
   return INVALID_HANDLE;
  }

string OscName()
  {
   switch(InpOscillator)
     {
      case DIV_RSI:        return StringFormat("RSI %d", InpRSIPeriod);
      case DIV_MACD:       return StringFormat("MACD %d/%d/%d", InpMACDFast, InpMACDSlow, InpMACDSignal);
      case DIV_STOCHASTIC: return StringFormat("Stoch %d/%d/%d", InpStochK, InpStochD, InpStochSlowing);
      case DIV_CCI:        return StringFormat("CCI %d", InpCCIPeriod);
     }
   return "?";
  }

//+------------------------------------------------------------------+
//| Main calculation                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   int minBars = InpSwingLen * 2 + InpLookback + 50;
   if(rates_total < minBars || g_oscHandle == INVALID_HANDLE) return(0);

   double osc[];
   ArraySetAsSeries(osc, false);
   if(CopyBuffer(g_oscHandle, 0, 0, rates_total, osc) < rates_total) return(0);

   int start;
   if(prev_calculated == 0)
     {
      start = InpSwingLen + 50;
      g_regBull = 0; g_regBear = 0; g_hidBull = 0; g_hidBear = 0;
      g_lastDivType = "---"; g_lastDivBar = "---"; g_lastDivStrength = 0;
      ObjectsDeleteAll(0, OBJ_PREFIX + "LBL_");
      ObjectsDeleteAll(0, OBJ_PREFIX + "TL_");
      for(int i = 0; i < rates_total; i++)
        { BuffArrow[i] = EMPTY_VALUE; BuffArrowColor[i] = 0; BuffStrength[i] = EMPTY_VALUE; BuffStrengthColor[i] = 0; }
     }
   else
      start = MathMax(prev_calculated - 1, InpSwingLen + 50);

   for(int i = start; i < rates_total - InpSwingLen; i++)
     {
      BuffArrow[i] = EMPTY_VALUE;
      BuffStrength[i] = EMPTY_VALUE;

      //=== SWING LOW → Bullish ===
      if(IsSwingLow(low, i, InpSwingLen, rates_total))
        {
         int p = FindPrevSwingLow(low, i, InpSwingLen, InpLookback, rates_total);
         if(p >= 0)
           {
            double diff = MathAbs(osc[i] - osc[p]);
            if(InpShowRegular && low[i] < low[p] && osc[i] > osc[p] && diff >= InpMinOscDiff)
               RegisterDiv(i, DIV_REG_BULL, low[i], low[p], diff, time, p, true);
            else if(InpShowHidden && low[i] > low[p] && osc[i] < osc[p] && diff >= InpMinOscDiff)
               RegisterDiv(i, DIV_HID_BULL, low[i], low[p], diff, time, p, true);
           }
        }

      //=== SWING HIGH → Bearish ===
      if(BuffArrow[i] == EMPTY_VALUE && IsSwingHigh(high, i, InpSwingLen, rates_total))
        {
         int p = FindPrevSwingHigh(high, i, InpSwingLen, InpLookback, rates_total);
         if(p >= 0)
           {
            double diff = MathAbs(osc[i] - osc[p]);
            if(InpShowRegular && high[i] > high[p] && osc[i] < osc[p] && diff >= InpMinOscDiff)
               RegisterDiv(i, DIV_REG_BEAR, high[i], high[p], diff, time, p, false);
            else if(InpShowHidden && high[i] < high[p] && osc[i] > osc[p] && diff >= InpMinOscDiff)
               RegisterDiv(i, DIV_HID_BEAR, high[i], high[p], diff, time, p, false);
           }
        }

      if(BuffArrow[i] != EMPTY_VALUE && i >= rates_total - InpSwingLen - 2)
         TryAlert(time[i]);
     }

   if(InpShowDashboard) UpdateDashboard();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| SWING DETECTION                                                   |
//+------------------------------------------------------------------+
bool IsSwingLow(const double &a[], int i, int len, int total)
  { for(int j=1;j<=len;j++){if(i-j<0||i+j>=total||a[i-j]<=a[i]||a[i+j]<=a[i])return false;} return true; }

bool IsSwingHigh(const double &a[], int i, int len, int total)
  { for(int j=1;j<=len;j++){if(i-j<0||i+j>=total||a[i-j]>=a[i]||a[i+j]>=a[i])return false;} return true; }

int FindPrevSwingLow(const double &a[], int from, int len, int lb, int total)
  { for(int k=from-len*2; k>=MathMax(from-lb,len); k--) if(IsSwingLow(a,k,len,total)) return k; return -1; }

int FindPrevSwingHigh(const double &a[], int from, int len, int lb, int total)
  { for(int k=from-len*2; k>=MathMax(from-lb,len); k--) if(IsSwingHigh(a,k,len,total)) return k; return -1; }

//+------------------------------------------------------------------+
//| REGISTER DIVERGENCE                                               |
//+------------------------------------------------------------------+
void RegisterDiv(int bar, ENUM_DIV_TYPE type, double price1, double price2,
                 double oscDiff, const datetime &time[], int prevBar, bool isBull)
  {
   int ci = (int)type;
   string tn; color clr;
   switch(type)
     {
      case DIV_REG_BULL: tn="Reg Bull"; clr=C'0,185,140';  g_regBull++; break;
      case DIV_REG_BEAR: tn="Reg Bear"; clr=C'220,50,80';  g_regBear++; break;
      case DIV_HID_BULL: tn="Hid Bull"; clr=C'90,180,220'; g_hidBull++; break;
      case DIV_HID_BEAR: tn="Hid Bear"; clr=C'200,170,50'; g_hidBear++; break;
     }

   double off = _Point * InpArrowOffset;
   BuffArrow[bar]      = isBull ? price1 - off : price1 + off;
   BuffArrowColor[bar] = (double)ci;

   double strength = MathMin(100.0, oscDiff * 3.0);
   g_lastDivStrength = strength;
   BuffStrength[bar]      = isBull ? price1 - off * 2 : price1 + off * 2;
   BuffStrengthColor[bar] = (double)ci;

   g_lastDivType = tn;
   g_lastDivBar  = TimeToString(time[bar], TIME_DATE | TIME_MINUTES);

   if(InpShowLabels)
     {
      double lp = isBull ? price1 - off * 1.6 : price1 + off * 1.6;
      DrawLabel(bar, time[bar], lp, tn + " (" + IntegerToString((int)strength) + ")", clr);
     }
   if(InpShowTrendlines && prevBar >= 0)
      DrawTrendline(bar, prevBar, time, price1, price2, clr);
  }

//+------------------------------------------------------------------+
//| ALERTS                                                            |
//+------------------------------------------------------------------+
void TryAlert(datetime barTime)
  {
   datetime now = TimeCurrent();
   if(now - g_lastAlertTime < InpAlertCooldown) return;
   g_lastAlertTime = now;
   string msg = StringFormat("[ASQ DivDetector] %s | %s | Str:%d | %s",
                             _Symbol, g_lastDivType, (int)g_lastDivStrength, g_lastDivBar);
   if(InpAlertPopup) Alert(msg);
   if(InpAlertSound) PlaySound("alert.wav");
   if(InpAlertPush)  SendNotification(msg);
   if(InpAlertEmail) SendMail("ASQ Div: " + _Symbol, msg);
   Print(msg);
  }

//+------------------------------------------------------------------+
//| DRAW HELPERS                                                      |
//+------------------------------------------------------------------+
void DrawLabel(int idx, datetime t, double p, string text, color clr)
  {
   string n = OBJ_PREFIX + "LBL_" + IntegerToString(idx);
   if(ObjectFind(0, n) >= 0) ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_TEXT, 0, t, p);
   ObjectSetString(0,n,OBJPROP_TEXT,text); ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetString(0,n,OBJPROP_FONT,"Consolas"); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,n,OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
  }

void DrawTrendline(int bar, int prev, const datetime &time[], double p1, double p2, color clr)
  {
   string n = OBJ_PREFIX + "TL_" + IntegerToString(bar);
   if(ObjectFind(0, n) >= 0) ObjectDelete(0, n);
   ObjectCreate(0, n, OBJ_TREND, 0, time[prev], p2, time[bar], p1);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr); ObjectSetInteger(0,n,OBJPROP_WIDTH,InpTrendlineWidth);
   ObjectSetInteger(0,n,OBJPROP_STYLE,InpTrendlineStyle); ObjectSetInteger(0,n,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,n,OBJPROP_BACK,true); ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| DASHBOARD                                                         |
//+------------------------------------------------------------------+
void CreateDashboard(string oscName)
  {
   int w=280, h=200, y=InpDashY, x=InpDashX+10, fs=InpDashFontSize;
   string bg=OBJ_PREFIX+"DASH_BG";
   ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,InpDashX); ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,w); ObjectSetInteger(0,bg,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,InpDashBgColor); ObjectSetInteger(0,bg,OBJPROP_BORDER_COLOR,C'30,34,46');
   ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT); ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,bg,OBJPROP_BACK,false); ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);

   ML("Title",  x,y+8,  "ASQ DIVERGENCE DETECTOR",C'90,180,220',fs+1);
   ML("OscInfo",x,y+26, _Symbol+" | "+oscName,C'55,60,75',fs-1);
   ML("Sep1",   x,y+40, StringFormat("%c",0x2500)+"────────────────────────────",C'30,34,46',fs-2);
   ML("RBLbl",  x,y+54, "Reg Bullish:",C'90,95,110',fs);  ML("RBVal",x+170,y+54,"0",C'0,185,140',fs);
   ML("RSLbl",  x,y+72, "Reg Bearish:",C'90,95,110',fs);  ML("RSVal",x+170,y+72,"0",C'220,50,80',fs);
   ML("HBLbl",  x,y+90, "Hid Bullish:",C'90,95,110',fs);  ML("HBVal",x+170,y+90,"0",C'90,180,220',fs);
   ML("HSLbl",  x,y+108,"Hid Bearish:",C'90,95,110',fs);  ML("HSVal",x+170,y+108,"0",C'200,170,50',fs);
   ML("Sep2",   x,y+124,"──────────────────────────────",C'30,34,46',fs-2);
   ML("TotLbl", x,y+138,"Total:",C'90,95,110',fs);        ML("TotVal",x+170,y+138,"0",C'200,205,220',fs);
   ML("LastLbl",x,y+156,"Last:",C'90,95,110',fs-1);        ML("LastVal",x+60,y+156,"---",C'200,205,220',fs-1);
   ML("StrLbl", x,y+170,"Strength:",C'90,95,110',fs-1);    ML("StrVal",x+100,y+170,"---",C'200,205,220',fs-1);
   ML("Brand",  x,y+186,"AlgoSphere Quant",C'40,44,58',fs-2);
   ChartRedraw(0);
  }

void ML(string id,int x,int y,string text,color clr,int fs)
  {
   string n=OBJ_PREFIX+"DASH_"+id;
   if(ObjectFind(0,n)<0)
     { ObjectCreate(0,n,OBJ_LABEL,0,0,0); ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
       ObjectSetInteger(0,n,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER); ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
       ObjectSetInteger(0,n,OBJPROP_HIDDEN,true); ObjectSetInteger(0,n,OBJPROP_BACK,false); }
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,n,OBJPROP_TEXT,text); ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
  }

void UpdateDashboard()
  {
   int total=g_regBull+g_regBear+g_hidBull+g_hidBear;
   ObjectSetString(0,OBJ_PREFIX+"DASH_RBVal",OBJPROP_TEXT,IntegerToString(g_regBull));
   ObjectSetString(0,OBJ_PREFIX+"DASH_RSVal",OBJPROP_TEXT,IntegerToString(g_regBear));
   ObjectSetString(0,OBJ_PREFIX+"DASH_HBVal",OBJPROP_TEXT,IntegerToString(g_hidBull));
   ObjectSetString(0,OBJ_PREFIX+"DASH_HSVal",OBJPROP_TEXT,IntegerToString(g_hidBear));
   ObjectSetString(0,OBJ_PREFIX+"DASH_TotVal",OBJPROP_TEXT,IntegerToString(total));
   ObjectSetString(0,OBJ_PREFIX+"DASH_LastVal",OBJPROP_TEXT,g_lastDivType+" @ "+g_lastDivBar);
   ObjectSetString(0,OBJ_PREFIX+"DASH_StrVal",OBJPROP_TEXT,IntegerToString((int)g_lastDivStrength)+"/100");
   color sc = g_lastDivStrength>=70 ? C'0,185,140' : g_lastDivStrength>=40 ? C'200,170,50' : C'220,50,80';
   ObjectSetInteger(0,OBJ_PREFIX+"DASH_StrVal",OBJPROP_COLOR,sc);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
