//+------------------------------------------------------------------+
//|                                             FX Dashboard.mq5     |
//|                                                                  |
//|                Professional Trading Utility for MetaTrader 5     |
//|                            Copyright (c) 2026 Marian Beceanu     |
//|                        https://www.mql5.com/en/users/zorbacc     |
//|                              Email: marian.beceanu@gmail.com     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Marian Beceanu"
#property version   "1.10"
#property indicator_chart_window
#property indicator_plots   8
#property indicator_buffers 8

//--- Plot 0: EMA Fast
#property indicator_label1  "EMA Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Plot 1: EMA Mid
#property indicator_label2  "EMA Mid"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Plot 2: EMA Slow
#property indicator_label3  "EMA Slow"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- Plot 3: BB Upper
#property indicator_label4  "BB Upper"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

//--- Plot 4: BB Middle
#property indicator_label5  "BB Mid"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_width5  1

//--- Plot 5: BB Lower
#property indicator_label6  "BB Lower"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSilver
#property indicator_style6  STYLE_DOT
#property indicator_width6  1

//--- Plot 6: Donchian High
#property indicator_label7  "Donchian High"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrAqua
#property indicator_style7  STYLE_DASH
#property indicator_width7  1

//--- Plot 7: Donchian Low
#property indicator_label8  "Donchian Low"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrAqua
#property indicator_style8  STYLE_DASH
#property indicator_width8  1

//====================================================================
// ENUMS — full color dropdowns (no free color picker needed)
//====================================================================

// Comprehensive named colors for dropdown selection
enum ENUM_NAMED_COLOR
  {
   COL_BLACK,            // Black
   COL_WHITE,            // White
   COL_SILVER,           // Silver
   COL_GRAY,             // Gray
   COL_DIM_GRAY,         // Dim Gray
   COL_DARK_GRAY,        // Dark Gray
   COL_LIGHT_GRAY,       // Light Gray
   COL_RED,              // Red
   COL_DARK_RED,         // Dark Red
   COL_ORANGE_RED,       // Orange Red
   COL_CRIMSON,          // Crimson
   COL_ORANGE,           // Orange
   COL_DARK_ORANGE,      // Dark Orange
   COL_AMBER,            // Amber / Bloomberg Orange
   COL_GOLD,             // Gold (drawn as Yellow)
   COL_YELLOW,           // Yellow
   COL_LIME,             // Lime
   COL_LIME_GREEN,       // Lime Green
   COL_GREEN,            // Green
   COL_DARK_GREEN,       // Dark Green
   COL_FOREST_GREEN,     // Forest Green
   COL_CYAN,             // Cyan
   COL_AQUA,             // Aqua
   COL_TURQUOISE,        // Turquoise
   COL_DODGER_BLUE,      // Dodger Blue
   COL_STEEL_BLUE,       // Steel Blue
   COL_BLUE,             // Blue
   COL_NAVY,             // Navy
   COL_MIDNIGHT_BLUE,    // Midnight Blue
   COL_PURPLE,           // Purple
   COL_MAGENTA,          // Magenta
   COL_VIOLET,           // Violet
   COL_PINK,             // Pink
   COL_BROWN,            // Brown
   COL_SADDLE_BROWN,     // Saddle Brown
   COL_CHOCOLATE,        // Chocolate
   COL_TERMINAL_BG,      // Terminal near-black (8,8,8)
   COL_DARK_NAVY_BG,     // Dark Navy Blue (8,12,28)
   COL_CHARCOAL_BG,      // Charcoal (24,24,24)
   COL_DARK_GREEN_BG,    // Dark Green terminal (4,18,8)
   COL_MIDNIGHT_PURPLE,  // Midnight Purple (18,8,28)
   COL_DARK_SLATE,       // Dark Slate (22,26,32)
   COL_SOFT_LIME,        // Soft Lime (150,220,90)
   COL_SOFT_ORANGE,      // Soft Orange (240,150,90)
   COL_NONE              // Transparent / none (for optional lines)
  };

// News importance filter
enum ENUM_NEWS_FILTER
  {
   NEWS_HIGH_ONLY,       // High-importance events only
   NEWS_MEDIUM_AND_UP,   // Medium + High importance
   NEWS_ALL              // All events (low/medium/high)
  };

//====================================================================
// INPUTS
//====================================================================

input group "=== PANEL IDENTITY (required for multiple instances) ===";
input string              InpPanelID           = "Main";              // Unique Panel ID (different value per extra instance)

input group "=== PANEL POSITION ===";
input ENUM_BASE_CORNER    InpCorner            = CORNER_LEFT_UPPER;    // Panel corner
input int                 InpOffsetX           = 12;                   // Horizontal offset from corner (px)
input int                 InpOffsetY           = 12;                   // Vertical offset from corner (px)

input group "=== PANEL & TEXT COLORS (dropdown lists) ===";
input ENUM_NAMED_COLOR    InpBgColor           = COL_TERMINAL_BG;      // Panel background color
input ENUM_NAMED_COLOR    InpBorderColor       = COL_DIM_GRAY;         // Panel border / separator color
input ENUM_NAMED_COLOR    InpAccentColor       = COL_YELLOW;           // Header / accent color (yellow)
input ENUM_NAMED_COLOR    InpTextColor         = COL_WHITE;            // Neutral / base text color (white)
input ENUM_NAMED_COLOR    InpBullColor         = COL_GREEN;            // Bullish / positive signal color (green)
input ENUM_NAMED_COLOR    InpBearColor         = COL_RED;              // Bearish / negative signal color (red)
input ENUM_NAMED_COLOR    InpWarnColor         = COL_ORANGE_RED;       // Warning / fade / risk color
input ENUM_NAMED_COLOR    InpNeutralColor      = COL_SILVER;           // Neutral / sideways color
input ENUM_NAMED_COLOR    InpInfoColor         = COL_AQUA;             // Info / squeeze / nascent color
input ENUM_NAMED_COLOR    InpAgingColor        = COL_YELLOW;           // Aging trend color (yellow)
input ENUM_NAMED_COLOR    InpGrayNoteColor     = COL_GRAY;             // Secondary notes / disclaimer color

input group "=== TEXT SIZE & SCALING ===";
input string              InpFontName          = "Arial";              // Font (Arial everywhere)
input int                 InpFontSize          = 8;                    // Base text size (pt)
input bool                InpAutoScalePanel    = true;                 // Auto-fit panel width/height to longest text line
input double              InpManualScale       = 1.0;                  // Extra manual scale multiplier (0.5 .. 3.0)
input int                 InpLineSpacing       = 4;                    // Extra pixels between lines

input group "=== UPDATE ===";
input int                 InpUpdateSeconds     = 1;                    // Panel refresh interval (seconds)

input group "=== CHART OVERLAYS (what is drawn on the chart) ===";
input bool                InpShowEma           = true;                 // Draw EMA Fast / Mid / Slow
input bool                InpShowBB            = true;                 // Draw Bollinger Bands
input bool                InpShowDonchian      = true;                 // Draw Donchian channel
input ENUM_NAMED_COLOR    InpEmaFastColor      = COL_DODGER_BLUE;      // EMA Fast line color
input ENUM_NAMED_COLOR    InpEmaMidColor       = COL_ORANGE;           // EMA Mid line color
input ENUM_NAMED_COLOR    InpEmaSlowColor      = COL_MAGENTA;          // EMA Slow line color
input ENUM_NAMED_COLOR    InpBbColor           = COL_SILVER;           // Bollinger Bands color
input ENUM_NAMED_COLOR    InpDonchianColor     = COL_AQUA;             // Donchian channel color
input int                 InpEmaFastWidth      = 1;                    // EMA Fast width
input int                 InpEmaMidWidth       = 1;                    // EMA Mid width
input int                 InpEmaSlowWidth      = 2;                    // EMA Slow width
input int                 InpBbWidth           = 1;                    // BB line width
input int                 InpDonchianWidth     = 1;                    // Donchian line width

input group "=== STRATEGY 2: TREND RIDING (EMA / MACD / Stochastic) ===";
input int                 InpEmaFast           = 20;                   // Fast EMA period
input int                 InpEmaMid            = 50;                   // Mid EMA period
input int                 InpEmaSlow           = 200;                  // Slow EMA period
input int                 InpMacdFast          = 12;                   // MACD fast EMA
input int                 InpMacdSlow          = 26;                   // MACD slow EMA
input int                 InpMacdSignal        = 9;                    // MACD signal period
input int                 InpStochK            = 14;                   // Stochastic %K period
input int                 InpStochD            = 3;                    // Stochastic %D period
input int                 InpStochSlow         = 3;                    // Stochastic slowing

input group "=== STRATEGY 3/4/5: VOLATILITY & BREAKOUT ===";
input int                 InpAtrPeriod         = 14;                   // ATR period
input int                 InpBbPeriod          = 20;                   // Bollinger Bands period
input double              InpBbDeviation       = 2.0;                  // Bollinger Bands deviation
input int                 InpBbSqueezeLookback = 100;                  // Lookback bars to rank current BB width
input double              InpSqueezeThreshold  = 25.0;                 // Squeeze if BB width percentile below this (%)
input int                 InpDonchianPeriod    = 20;                   // Donchian channel period
input int                 InpFadeLookbackBars  = 3;                    // Bars allowed for a breakout to fail (fade window)
input double              InpBreakoutAtrMult   = 0.5;                  // Min close-through distance (ATR) for confirmed breakout

input group "=== STRATEGY 1: TECHNICAL SENTIMENT SCORE (proxy) ===";
input bool                InpShowSentiment     = true;                 // Show sentiment score row

input group "=== STRATEGY 6: CARRY TRADE (swap) ===";
input bool                InpShowCarry         = true;                 // Show swap / carry row

input group "=== STRATEGY 7: NEWS STRADDLING (Economic Calendar) ===";
input bool                InpShowNews          = true;                 // Show upcoming high-impact news
input int                 InpNewsLookAheadMin  = 180;                  // Look-ahead window (minutes)
input ENUM_NEWS_FILTER    InpNewsFilter        = NEWS_HIGH_ONLY;       // Minimum importance to display

//====================================================================
// GLOBAL STATE
//====================================================================
string   g_prefix;
int      g_fontPx;
int      g_lineH;
double   g_scale;
color    g_bg, g_accent, g_border, g_text;
color    g_bull, g_bear, g_warn, g_neutral, g_info, g_aging, g_grayNote;

int      h_ema_fast, h_ema_mid, h_ema_slow;
int      h_macd, h_stoch, h_atr, h_bb;

datetime g_lastCalc = 0;
int      g_rowCount = 0;

#define BBFX_MAX_ROWS 40

// Plot buffers
double BufEmaFast[];
double BufEmaMid[];
double BufEmaSlow[];
double BufBbUpper[];
double BufBbMid[];
double BufBbLower[];
double BufDonHigh[];
double BufDonLow[];

//====================================================================
// COLOR RESOLVER (enum -> actual color)
//====================================================================
color NamedColor(const ENUM_NAMED_COLOR c)
  {
   switch(c)
     {
      case COL_BLACK:           return(clrBlack);
      case COL_WHITE:           return(clrWhite);
      case COL_SILVER:          return(clrSilver);
      case COL_GRAY:            return(clrGray);
      case COL_DIM_GRAY:        return(clrDimGray);
      case COL_DARK_GRAY:       return(C'64,64,64');
      case COL_LIGHT_GRAY:      return(C'210,210,210');
      case COL_RED:             return(clrRed);
      case COL_DARK_RED:        return(C'110,20,20');
      case COL_ORANGE_RED:      return(clrOrangeRed);
      case COL_CRIMSON:         return(clrCrimson);
      case COL_ORANGE:          return(clrOrange);
      case COL_DARK_ORANGE:     return(clrDarkOrange);
      case COL_AMBER:           return(C'255,176,0');
      case COL_GOLD:            return(clrYellow);   // Gold maps to Yellow as requested
      case COL_YELLOW:          return(clrYellow);
      case COL_LIME:            return(clrLime);
      case COL_LIME_GREEN:      return(clrLimeGreen);
      case COL_GREEN:           return(clrGreen);
      case COL_DARK_GREEN:      return(clrDarkGreen);
      case COL_FOREST_GREEN:    return(clrForestGreen);
      case COL_CYAN:            return(clrCyan);
      case COL_AQUA:            return(clrAqua);
      case COL_TURQUOISE:       return(clrTurquoise);
      case COL_DODGER_BLUE:     return(clrDodgerBlue);
      case COL_STEEL_BLUE:      return(C'70,110,150');
      case COL_BLUE:            return(clrBlue);
      case COL_NAVY:            return(clrNavy);
      case COL_MIDNIGHT_BLUE:   return(clrMidnightBlue);
      case COL_PURPLE:          return(clrPurple);
      case COL_MAGENTA:         return(clrMagenta);
      case COL_VIOLET:          return(clrViolet);
      case COL_PINK:            return(clrPink);
      case COL_BROWN:           return(clrBrown);
      case COL_SADDLE_BROWN:    return(clrSaddleBrown);
      case COL_CHOCOLATE:       return(clrChocolate);
      case COL_TERMINAL_BG:     return(C'8,8,8');
      case COL_DARK_NAVY_BG:    return(C'8,12,28');
      case COL_CHARCOAL_BG:     return(C'24,24,24');
      case COL_DARK_GREEN_BG:   return(C'4,18,8');
      case COL_MIDNIGHT_PURPLE: return(C'18,8,28');
      case COL_DARK_SLATE:      return(C'22,26,32');
      case COL_SOFT_LIME:       return(C'150,220,90');
      case COL_SOFT_ORANGE:     return(C'240,150,90');
      case COL_NONE:            return(clrNONE);
     }
   return(clrWhite);
  }

//====================================================================
// SMALL HELPERS
//====================================================================
string P(const string suffix){ return(g_prefix+suffix); }

int MeasureTextWidth(const string text)
  {
   TextSetFont(InpFontName, -(g_fontPx*10), 0, 0);
   uint w=0, h=0;
   TextGetSize(text, w, h);
   return((int)w);
  }

double Clamp(double v,double lo,double hi){ if(v<lo) return(lo); if(v>hi) return(hi); return(v); }

//====================================================================
// OBJECT MANAGEMENT
//====================================================================
void EnsureRectangle(const string name)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(0,name,OBJPROP_FILL,true);
     }
  }

void EnsureLabel(const string name)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,1);
     }
  }

void RemoveAllPanelObjects()
  {
   if(g_prefix=="") return;
   ObjectsDeleteAll(0, g_prefix, -1, -1);
   int total = ObjectsTotal(0,-1,-1);
   for(int i=total-1;i>=0;i--)
     {
      string nm = ObjectName(0,i,-1,-1);
      if(StringFind(nm,g_prefix)==0)
         ObjectDelete(0,nm);
     }
   ChartRedraw(0);
  }

int RowY(int rowIndex,int totalRows,int panelPadTop,int panelHeight)
  {
   bool isLower = (InpCorner==CORNER_LEFT_LOWER || InpCorner==CORNER_RIGHT_LOWER);
   if(!isLower)
      return(InpOffsetY + panelPadTop + rowIndex*g_lineH);
   else
      return(InpOffsetY + (panelHeight - panelPadTop - (rowIndex+1)*g_lineH));
  }

//====================================================================
// STRATEGY 2 — TREND RIDING
//====================================================================
struct TrendInfo
  {
   string   direction;
   color    dirColor;
   string   stage;
   color    stageColor;
   string   momentum;
   color    momColor;
   double   emaFast,emaMid,emaSlow;
   double   macdHist0,macdHist1,macdHist2;
   double   stochMain0,stochMain1;
  };

bool CalcTrend(TrendInfo &t)
  {
   double ef[], em[], es[];
   ArraySetAsSeries(ef,true); ArraySetAsSeries(em,true); ArraySetAsSeries(es,true);
   if(CopyBuffer(h_ema_fast,0,0,3,ef)<3) return(false);
   if(CopyBuffer(h_ema_mid ,0,0,3,em)<3) return(false);
   if(CopyBuffer(h_ema_slow,0,0,3,es)<3) return(false);

   double macdMain[], macdSig[];
   ArraySetAsSeries(macdMain,true); ArraySetAsSeries(macdSig,true);
   if(CopyBuffer(h_macd,0,0,3,macdMain)<3) return(false);
   if(CopyBuffer(h_macd,1,0,3,macdSig)<3) return(false);

   double stochMain[];
   ArraySetAsSeries(stochMain,true);
   if(CopyBuffer(h_stoch,0,0,3,stochMain)<3) return(false);

   t.emaFast=ef[0]; t.emaMid=em[0]; t.emaSlow=es[0];
   t.macdHist0 = macdMain[0]-macdSig[0];
   t.macdHist1 = macdMain[1]-macdSig[1];
   t.macdHist2 = macdMain[2]-macdSig[2];
   t.stochMain0 = stochMain[0];
   t.stochMain1 = stochMain[1];

   if(ef[0]>em[0] && em[0]>es[0])
     { t.direction="UPTREND";   t.dirColor=g_bull;   }
   else if(ef[0]<em[0] && em[0]<es[0])
     { t.direction="DOWNTREND"; t.dirColor=g_bear;   }
   else
     { t.direction="SIDEWAYS";  t.dirColor=g_neutral; }

   bool macdRising  = (t.macdHist0 > t.macdHist1);
   bool stochRising = (t.stochMain0 > t.stochMain1);
   bool bothAgreeUp   = macdRising && stochRising;
   bool bothAgreeDown = (!macdRising) && (!stochRising);

   if(t.direction=="UPTREND")
     {
      if(bothAgreeUp)       { t.momentum="CONFIRMING"; t.momColor=g_bull; }
      else if(bothAgreeDown){ t.momentum="DIVERGING";  t.momColor=g_warn; }
      else                  { t.momentum="MIXED";      t.momColor=g_neutral; }
     }
   else if(t.direction=="DOWNTREND")
     {
      if(bothAgreeDown)     { t.momentum="CONFIRMING"; t.momColor=g_bull; }
      else if(bothAgreeUp)  { t.momentum="DIVERGING";  t.momColor=g_warn; }
      else                  { t.momentum="MIXED";      t.momColor=g_neutral; }
     }
   else
     { t.momentum="FLAT"; t.momColor=g_neutral; }

   double gapFastMid_now  = MathAbs(ef[0]-em[0]);
   double gapFastMid_prev = MathAbs(ef[2]-em[2]);
   bool   gapWidening     = (gapFastMid_now > gapFastMid_prev);
   bool   emaCrossedRecently = ((ef[2]-em[2])*(ef[0]-em[0]) < 0);

   if(t.direction=="SIDEWAYS")
     { t.stage="-"; t.stageColor=g_neutral; }
   else if(emaCrossedRecently)
     { t.stage="1-NASCENT";       t.stageColor=g_info; }
   else if(gapWidening && t.momentum=="CONFIRMING")
     { t.stage="2-ESTABLISHED";   t.stageColor=g_bull; }
   else if(!gapWidening && t.momentum!="DIVERGING")
     { t.stage="3-AGING";         t.stageColor=g_aging; }
   else
     { t.stage="4-REVERSAL RISK"; t.stageColor=g_warn; }

   return(true);
  }

//====================================================================
// STRATEGY 3/4/5 — VOLATILITY, SQUEEZE & BREAKOUT
//====================================================================
struct VolBreakoutInfo
  {
   double atr;
   double bbUpper,bbLower,bbMid,bbWidth;
   double squeezePercentile;
   bool   isSqueeze;
   double donHigh,donLow;
   string breakoutState;
   color  breakoutColor;
  };

bool CalcVolBreakout(VolBreakoutInfo &v)
  {
   double atrBuf[]; ArraySetAsSeries(atrBuf,true);
   if(CopyBuffer(h_atr,0,0,2,atrBuf)<2) return(false);
   v.atr = atrBuf[0];

   double bbUpBuf[], bbLowBuf[], bbMidBuf[];
   ArraySetAsSeries(bbUpBuf,true); ArraySetAsSeries(bbLowBuf,true); ArraySetAsSeries(bbMidBuf,true);
   int bbNeed = InpBbSqueezeLookback+2;
   if(CopyBuffer(h_bb,1,0,bbNeed,bbUpBuf)<bbNeed)  return(false);
   if(CopyBuffer(h_bb,2,0,bbNeed,bbLowBuf)<bbNeed) return(false);
   if(CopyBuffer(h_bb,0,0,bbNeed,bbMidBuf)<bbNeed) return(false);

   v.bbUpper = bbUpBuf[0];
   v.bbLower = bbLowBuf[0];
   v.bbMid   = bbMidBuf[0];
   v.bbWidth = v.bbUpper - v.bbLower;

   int narrower=0;
   for(int i=1;i<InpBbSqueezeLookback;i++)
     {
      double w = bbUpBuf[i]-bbLowBuf[i];
      if(v.bbWidth <= w) narrower++;
     }
   v.squeezePercentile = 100.0 * narrower / (double)(InpBbSqueezeLookback-1);
   v.isSqueeze = (v.squeezePercentile <= InpSqueezeThreshold);

   double hh = -DBL_MAX, ll = DBL_MAX;
   int barsAvail = Bars(_Symbol,_Period);
   int period = MathMin(InpDonchianPeriod, barsAvail-2);
   for(int i=1;i<=period;i++)
     {
      double h = iHigh(_Symbol,_Period,i);
      double l = iLow (_Symbol,_Period,i);
      if(h>hh) hh=h;
      if(l<ll) ll=l;
     }
   v.donHigh=hh; v.donLow=ll;

   double close1 = iClose(_Symbol,_Period,1);
   double close0 = iClose(_Symbol,_Period,0);

   bool wasUpBreakRecently=false, wasDownBreakRecently=false;
   for(int i=1;i<=InpFadeLookbackBars;i++)
     {
      double h_i = iHigh(_Symbol,_Period,i);
      double l_i = iLow (_Symbol,_Period,i);
      double priorHigh=-DBL_MAX, priorLow=DBL_MAX;
      for(int j=i+1;j<=i+period;j++)
        {
         double h=iHigh(_Symbol,_Period,j), l=iLow(_Symbol,_Period,j);
         if(h>priorHigh) priorHigh=h;
         if(l<priorLow)  priorLow=l;
        }
      if(h_i>priorHigh) wasUpBreakRecently=true;
      if(l_i<priorLow)  wasDownBreakRecently=true;
     }

   bool nowBackInsideUp   = wasUpBreakRecently   && (close0 < v.donHigh);
   bool nowBackInsideDown = wasDownBreakRecently && (close0 > v.donLow);

   bool confirmedUp   = (close1 > v.donHigh) && (close0 - v.donHigh > InpBreakoutAtrMult*v.atr);
   bool confirmedDown = (close1 < v.donLow)  && (v.donLow - close0  > InpBreakoutAtrMult*v.atr);

   if(nowBackInsideUp)
     { v.breakoutState="FALSE UP BREAK - FADE"; v.breakoutColor=g_warn; }
   else if(nowBackInsideDown)
     { v.breakoutState="FALSE DOWN BREAK - FADE"; v.breakoutColor=g_warn; }
   else if(confirmedUp)
     { v.breakoutState="CONFIRMED UP BREAKOUT"; v.breakoutColor=g_bull; }
   else if(confirmedDown)
     { v.breakoutState="CONFIRMED DOWN BREAKOUT"; v.breakoutColor=g_bull; }
   else if(close0>v.donHigh)
     { v.breakoutState="TESTING UPPER RANGE"; v.breakoutColor=g_aging; }
   else if(close0<v.donLow)
     { v.breakoutState="TESTING LOWER RANGE"; v.breakoutColor=g_aging; }
   else
     { v.breakoutState="INSIDE RANGE"; v.breakoutColor=g_neutral; }

   return(true);
  }

//====================================================================
// STRATEGY 1 — TECHNICAL SENTIMENT SCORE (proxy)
//====================================================================
string CalcSentiment(const TrendInfo &t,const VolBreakoutInfo &v,color &outColor,double &outScore)
  {
   if(v.atr<=0.0){ outColor=g_neutral; outScore=0; return("N/A"); }

   double trendComponent  = Clamp((t.emaFast - t.emaSlow)/v.atr, -3.0, 3.0)/3.0;
   double macdComponent   = Clamp(t.macdHist0/v.atr, -2.0, 2.0)/2.0;
   double stochComponent  = Clamp((t.stochMain0-50.0)/50.0, -1.0, 1.0);

   double score = (trendComponent*0.5 + macdComponent*0.3 + stochComponent*0.2)*100.0;
   score = Clamp(score,-100.0,100.0);
   outScore = score;

   if(score>=40)      { outColor=g_bull;        return("STRONG BULLISH"); }
   if(score>=15)      { outColor=NamedColor(COL_SOFT_LIME); return("BULLISH"); }
   if(score>-15)      { outColor=g_neutral;     return("NEUTRAL / MIXED"); }
   if(score>-40)      { outColor=NamedColor(COL_SOFT_ORANGE); return("BEARISH"); }
   outColor=g_bear; return("STRONG BEARISH");
  }

//====================================================================
// STRATEGY 6 — CARRY TRADE
//====================================================================
void CalcCarry(string &line,color &lineColor)
  {
   double swapLong  = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG);
   double swapShort = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT);

   string dir;
   color  c;
   if(swapLong>0 && swapLong>=(-swapShort))
     { dir="LONG carry +"; c=g_bull; }
   else if(swapShort>0 && swapShort>=(-swapLong))
     { dir="SHORT carry +"; c=g_bull; }
   else
     { dir="NEGATIVE both sides"; c=g_warn; }

   line = StringFormat("SwapL:%s  SwapS:%s  ->  %s",
                        DoubleToString(swapLong,2), DoubleToString(swapShort,2), dir);
   lineColor=c;
  }

//====================================================================
// STRATEGY 7 — NEWS STRADDLING
//====================================================================
bool GetCurrencyPair(string &base,string &quote)
  {
   base  = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   quote = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   if(base=="" ) base = StringSubstr(_Symbol,0,3);
   if(quote=="") quote= StringSubstr(_Symbol,3,3);
   return(true);
  }

bool CalcNextNews(string &line,color &lineColor)
  {
   string base,quote;
   GetCurrencyPair(base,quote);

   datetime now = TimeCurrent();
   datetime to  = now + InpNewsLookAheadMin*60;

   ENUM_CALENDAR_EVENT_IMPORTANCE minImportance;
   switch(InpNewsFilter)
     {
      case NEWS_HIGH_ONLY:      minImportance=CALENDAR_IMPORTANCE_HIGH;     break;
      case NEWS_MEDIUM_AND_UP:  minImportance=CALENDAR_IMPORTANCE_MODERATE; break;
      default:                  minImportance=CALENDAR_IMPORTANCE_NONE;     break;
     }

   datetime bestTime = 0;
   string   bestName  = "";
   string   bestCcy   = "";

   string currencies[2]; currencies[0]=base; currencies[1]=quote;
   for(int c=0;c<2;c++)
     {
      MqlCalendarValue values[];
      if(!CalendarValueHistory(values, now, to, NULL, currencies[c])) continue;
      for(int i=0;i<ArraySize(values);i++)
        {
         MqlCalendarEvent ev;
         if(!CalendarEventById(values[i].event_id, ev)) continue;
         if(ev.importance < minImportance) continue;
         if(bestTime==0 || values[i].time < bestTime)
           {
            bestTime = values[i].time;
            bestName = ev.name;
            bestCcy  = currencies[c];
           }
        }
     }

   if(bestTime==0)
     {
      line = "No qualifying events in the next "+IntegerToString(InpNewsLookAheadMin)+" min";
      lineColor = g_neutral;
      return(true);
     }

   int minsLeft = (int)((bestTime-now)/60);
   line = StringFormat("[%s] %s in %d min", bestCcy, bestName, minsLeft);
   lineColor = (minsLeft<=30) ? g_warn : g_aging;
   return(true);
  }

//====================================================================
// PANEL BUILD & DRAW
//====================================================================
struct RowItem { string text; color col; bool isHeader; };

int BuildRows(RowItem &rows[])
  {
   int n=0;
   ArrayResize(rows,BBFX_MAX_ROWS);

   TrendInfo t;
   VolBreakoutInfo v;
   bool okT = CalcTrend(t);
   bool okV = CalcVolBreakout(v);

   rows[n].text = StringFormat("%s  %s", _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period));
   rows[n].col  = g_accent; rows[n].isHeader=true; n++;

   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   int    digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double spreadPts = (point>0)? (ask-bid)/point : 0;

   rows[n].text = StringFormat("Bid:%s  Ask:%s  Spread:%.1fp",
                    DoubleToString(bid,digits), DoubleToString(ask,digits), spreadPts);
   rows[n].col = g_text; rows[n].isHeader=false; n++;

   rows[n].text = "-------------------------------------";
   rows[n].col = g_border; rows[n].isHeader=false; n++;

   rows[n].text = "TREND RIDING (S2)"; rows[n].col=g_accent; rows[n].isHeader=true; n++;
   if(okT)
     {
      rows[n].text = StringFormat("Dir: %-10s  Stage: %s", t.direction, t.stage);
      rows[n].col  = t.dirColor; n++;
      rows[n].text = StringFormat("Momentum: %s (MACD/Stoch)", t.momentum);
      rows[n].col  = t.momColor; n++;
      rows[n].text = StringFormat("EMA%d/%d/%d: %s/%s/%s",
                       InpEmaFast,InpEmaMid,InpEmaSlow,
                       DoubleToString(t.emaFast,digits),DoubleToString(t.emaMid,digits),DoubleToString(t.emaSlow,digits));
      rows[n].col = g_neutral; n++;
     }
   else
     { rows[n].text="Trend data unavailable (loading...)"; rows[n].col=g_grayNote; n++; }

   rows[n].text = "-------------------------------------";
   rows[n].col = g_border; n++;

   rows[n].text = "VOLATILITY / BREAKOUT (S3-S5)"; rows[n].col=g_accent; rows[n].isHeader=true; n++;
   if(okV)
     {
      rows[n].text = StringFormat("ATR%d: %s   BBwidth pct: %.0f%% %s",
                       InpAtrPeriod, DoubleToString(v.atr,digits+1), v.squeezePercentile,
                       (v.isSqueeze?"[SQUEEZE]":""));
      rows[n].col = v.isSqueeze ? g_info : g_neutral; n++;

      rows[n].text = StringFormat("Donchian%d Hi:%s Lo:%s",
                       InpDonchianPeriod, DoubleToString(v.donHigh,digits), DoubleToString(v.donLow,digits));
      rows[n].col = g_neutral; n++;

      rows[n].text = "Breakout: "+v.breakoutState;
      rows[n].col  = v.breakoutColor; n++;
     }
   else
     { rows[n].text="Volatility data unavailable (loading...)"; rows[n].col=g_grayNote; n++; }

   rows[n].text = "-------------------------------------";
   rows[n].col = g_border; n++;

   if(InpShowSentiment)
     {
      rows[n].text = "TECHNICAL SENTIMENT (S1 proxy)"; rows[n].col=g_accent; rows[n].isHeader=true; n++;
      if(okT && okV)
        {
         color sc; double score;
         string label = CalcSentiment(t,v,sc,score);
         rows[n].text = StringFormat("%s  (score %+.0f)", label, score);
         rows[n].col  = sc; n++;
         rows[n].text = "Proxy only - not COT/news fundamental data";
         rows[n].col  = g_grayNote; n++;
        }
      else
        { rows[n].text="N/A"; rows[n].col=g_grayNote; n++; }
      rows[n].text = "-------------------------------------";
      rows[n].col = g_border; n++;
     }

   if(InpShowCarry)
     {
      rows[n].text = "CARRY TRADE (S6)"; rows[n].col=g_accent; rows[n].isHeader=true; n++;
      string cline; color ccol;
      CalcCarry(cline,ccol);
      rows[n].text = cline; rows[n].col=ccol; n++;
      rows[n].text = "-------------------------------------";
      rows[n].col = g_border; n++;
     }

   if(InpShowNews)
     {
      rows[n].text = "NEWS STRADDLING (S7)"; rows[n].col=g_accent; rows[n].isHeader=true; n++;
      string nline; color ncol;
      if(CalcNextNews(nline,ncol))
        { rows[n].text=nline; rows[n].col=ncol; n++; }
      else
        { rows[n].text="Calendar unavailable on this account/server"; rows[n].col=g_grayNote; n++; }
      rows[n].text = "-------------------------------------";
      rows[n].col = g_border; n++;
     }

   rows[n].text = "Updated: "+TimeToString(TimeCurrent(),TIME_SECONDS);
   rows[n].col  = g_grayNote; n++;

   ArrayResize(rows,n);
   return(n);
  }

void DrawPanel()
  {
   RowItem rows[];
   int n = BuildRows(rows);
   if(n<=0) return;

   g_scale  = Clamp(InpManualScale,0.5,3.0);
   g_fontPx = (int)MathRound(InpFontSize*g_scale);
   if(g_fontPx<6) g_fontPx=6;
   g_lineH  = (int)MathRound((g_fontPx*1.55) + InpLineSpacing*g_scale);

   int padX = (int)MathRound(10*g_scale);
   int padY = (int)MathRound(8*g_scale);

   int maxW = 0;
   for(int i=0;i<n;i++)
     {
      int w = MeasureTextWidth(rows[i].text);
      if(w>maxW) maxW=w;
     }
   int panelW = InpAutoScalePanel ? (maxW + padX*2) : (int)MathRound(300*g_scale);
   int panelH = n*g_lineH + padY*2;

   string bgName = P("BG");
   EnsureRectangle(bgName);
   ObjectSetInteger(0,bgName,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,bgName,OBJPROP_XDISTANCE,InpOffsetX);
   ObjectSetInteger(0,bgName,OBJPROP_YDISTANCE,InpOffsetY);
   ObjectSetInteger(0,bgName,OBJPROP_XSIZE,panelW);
   ObjectSetInteger(0,bgName,OBJPROP_YSIZE,panelH);
   ObjectSetInteger(0,bgName,OBJPROP_BGCOLOR,g_bg);
   ObjectSetInteger(0,bgName,OBJPROP_COLOR,g_border);
   ObjectSetInteger(0,bgName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,bgName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,bgName,OBJPROP_WIDTH,1);

   bool isRightCorner = (InpCorner==CORNER_RIGHT_UPPER || InpCorner==CORNER_RIGHT_LOWER);
   ENUM_ANCHOR_POINT anchor = isRightCorner ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER;

   for(int i=0;i<n;i++)
     {
      string lname = P("Row"+IntegerToString(i));
      EnsureLabel(lname);
      ObjectSetInteger(0,lname,OBJPROP_CORNER,InpCorner);
      ObjectSetInteger(0,lname,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,lname,OBJPROP_XDISTANCE,InpOffsetX+padX);
      ObjectSetInteger(0,lname,OBJPROP_YDISTANCE,RowY(i,n,padY,panelH));
      ObjectSetString (0,lname,OBJPROP_TEXT, rows[i].text);
      ObjectSetString (0,lname,OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0,lname,OBJPROP_FONTSIZE,g_fontPx);
      ObjectSetInteger(0,lname,OBJPROP_COLOR,rows[i].col);
     }

   for(int i=n;i<g_rowCount;i++)
     {
      string lname = P("Row"+IntegerToString(i));
      if(ObjectFind(0,lname)>=0)
         ObjectSetString(0,lname,OBJPROP_TEXT,"");
     }
   g_rowCount = MathMax(g_rowCount,n);

   ChartRedraw(0);
  }

//====================================================================
// OnInit
//====================================================================
int OnInit()
  {
   g_prefix = StringFormat("BBFX_%s_%I64d_", InpPanelID, ChartID());

   // Resolve all panel/signal colors from dropdowns
   g_bg        = NamedColor(InpBgColor);
   g_border    = NamedColor(InpBorderColor);
   g_accent    = NamedColor(InpAccentColor);
   g_text      = NamedColor(InpTextColor);
   g_bull      = NamedColor(InpBullColor);
   g_bear      = NamedColor(InpBearColor);
   g_warn      = NamedColor(InpWarnColor);
   g_neutral   = NamedColor(InpNeutralColor);
   g_info      = NamedColor(InpInfoColor);
   g_aging     = NamedColor(InpAgingColor);
   g_grayNote  = NamedColor(InpGrayNoteColor);

   // Plot buffers
   SetIndexBuffer(0, BufEmaFast,  INDICATOR_DATA);
   SetIndexBuffer(1, BufEmaMid,   INDICATOR_DATA);
   SetIndexBuffer(2, BufEmaSlow,  INDICATOR_DATA);
   SetIndexBuffer(3, BufBbUpper,  INDICATOR_DATA);
   SetIndexBuffer(4, BufBbMid,    INDICATOR_DATA);
   SetIndexBuffer(5, BufBbLower,  INDICATOR_DATA);
   SetIndexBuffer(6, BufDonHigh,  INDICATOR_DATA);
   SetIndexBuffer(7, BufDonLow,   INDICATOR_DATA);

   ArraySetAsSeries(BufEmaFast, true);
   ArraySetAsSeries(BufEmaMid,  true);
   ArraySetAsSeries(BufEmaSlow, true);
   ArraySetAsSeries(BufBbUpper, true);
   ArraySetAsSeries(BufBbMid,   true);
   ArraySetAsSeries(BufBbLower, true);
   ArraySetAsSeries(BufDonHigh, true);
   ArraySetAsSeries(BufDonLow,  true);

   // Apply user colors/widths to plots
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, NamedColor(InpEmaFastColor));
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpEmaFastWidth);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, NamedColor(InpEmaMidColor));
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpEmaMidWidth);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, NamedColor(InpEmaSlowColor));
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, InpEmaSlowWidth);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, NamedColor(InpBbColor));
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, InpBbWidth);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, NamedColor(InpBbColor));
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, InpBbWidth);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, NamedColor(InpBbColor));
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, InpBbWidth);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, NamedColor(InpDonchianColor));
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, InpDonchianWidth);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, NamedColor(InpDonchianColor));
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, InpDonchianWidth);

   // Hide plots if user disabled them
   if(!InpShowEma)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(!InpShowBB)
     {
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(!InpShowDonchian)
     {
      PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_NONE);
     }

   h_ema_fast = iMA(_Symbol,_Period,InpEmaFast,0,MODE_EMA,PRICE_CLOSE);
   h_ema_mid  = iMA(_Symbol,_Period,InpEmaMid ,0,MODE_EMA,PRICE_CLOSE);
   h_ema_slow = iMA(_Symbol,_Period,InpEmaSlow,0,MODE_EMA,PRICE_CLOSE);
   h_macd     = iMACD(_Symbol,_Period,InpMacdFast,InpMacdSlow,InpMacdSignal,PRICE_CLOSE);
   h_stoch    = iStochastic(_Symbol,_Period,InpStochK,InpStochD,InpStochSlow,MODE_SMA,STO_LOWHIGH);
   h_atr      = iATR(_Symbol,_Period,InpAtrPeriod);
   h_bb       = iBands(_Symbol,_Period,InpBbPeriod,0,InpBbDeviation,PRICE_CLOSE);

   if(h_ema_fast==INVALID_HANDLE || h_ema_mid==INVALID_HANDLE || h_ema_slow==INVALID_HANDLE ||
      h_macd==INVALID_HANDLE     || h_stoch==INVALID_HANDLE   || h_atr==INVALID_HANDLE      ||
      h_bb==INVALID_HANDLE)
     {
      Print("BloombergFX_Dashboard [",InpPanelID,"]: failed to create one or more indicator handles.");
      return(INIT_FAILED);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "BloombergFX Dashboard ["+InpPanelID+"]");

   EventSetTimer(MathMax(1,InpUpdateSeconds));
   DrawPanel();
   return(INIT_SUCCEEDED);
  }

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
  {
   EventKillTimer();

   if(h_ema_fast!=INVALID_HANDLE) IndicatorRelease(h_ema_fast);
   if(h_ema_mid !=INVALID_HANDLE) IndicatorRelease(h_ema_mid);
   if(h_ema_slow!=INVALID_HANDLE) IndicatorRelease(h_ema_slow);
   if(h_macd    !=INVALID_HANDLE) IndicatorRelease(h_macd);
   if(h_stoch   !=INVALID_HANDLE) IndicatorRelease(h_stoch);
   if(h_atr     !=INVALID_HANDLE) IndicatorRelease(h_atr);
   if(h_bb      !=INVALID_HANDLE) IndicatorRelease(h_bb);

   RemoveAllPanelObjects();
  }

//====================================================================
// OnCalculate — fill chart plot buffers + refresh panel on new bar
//====================================================================
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
   if(rates_total < InpEmaSlow + 5) return(0);

   int start;
   if(prev_calculated <= 0)
      start = rates_total - 1;
   else
      start = rates_total - prev_calculated;

   // Copy EMA & BB from handles into plot buffers
   if(InpShowEma)
     {
      CopyBuffer(h_ema_fast, 0, 0, rates_total, BufEmaFast);
      CopyBuffer(h_ema_mid,  0, 0, rates_total, BufEmaMid);
      CopyBuffer(h_ema_slow, 0, 0, rates_total, BufEmaSlow);
     }
   else
     {
      ArrayInitialize(BufEmaFast, EMPTY_VALUE);
      ArrayInitialize(BufEmaMid,  EMPTY_VALUE);
      ArrayInitialize(BufEmaSlow, EMPTY_VALUE);
     }

   if(InpShowBB)
     {
      CopyBuffer(h_bb, 1, 0, rates_total, BufBbUpper); // upper
      CopyBuffer(h_bb, 0, 0, rates_total, BufBbMid);   // middle
      CopyBuffer(h_bb, 2, 0, rates_total, BufBbLower); // lower
     }
   else
     {
      ArrayInitialize(BufBbUpper, EMPTY_VALUE);
      ArrayInitialize(BufBbMid,   EMPTY_VALUE);
      ArrayInitialize(BufBbLower, EMPTY_VALUE);
     }

   // Donchian channel (high[]/low[] are NOT series: 0 = oldest bar)
   // Buffers ARE series: Buf[0] = current bar. Convert indices.
   if(InpShowDonchian)
     {
      int period = InpDonchianPeriod;
      int limit  = (prev_calculated <= 0) ? rates_total - period - 2 : rates_total - prev_calculated + 1;
      if(limit > rates_total - 1) limit = rates_total - 1;
      if(limit < 0) limit = 0;

      for(int pos = 0; pos <= limit; pos++)
        {
         // pos = series index (0 = current/newest)
         int bar = rates_total - 1 - pos;   // non-series index of this bar
         if(bar - period < 0)
           {
            BufDonHigh[pos] = EMPTY_VALUE;
            BufDonLow[pos]  = EMPTY_VALUE;
            continue;
           }
         // Exclude current forming bar: look at bars [bar-1 .. bar-period]
         double hh = high[bar - 1];
         double ll = low[bar - 1];
         for(int k = 2; k <= period; k++)
           {
            int idx = bar - k;
            if(idx < 0) break;
            if(high[idx] > hh) hh = high[idx];
            if(low[idx]  < ll) ll = low[idx];
           }
         BufDonHigh[pos] = hh;
         BufDonLow[pos]  = ll;
        }
     }
   else
     {
      ArrayInitialize(BufDonHigh, EMPTY_VALUE);
      ArrayInitialize(BufDonLow,  EMPTY_VALUE);
     }

   // Panel refresh on new bar (timer handles live ticks)
   if(rates_total > 0 && time[rates_total-1] != g_lastCalc)
     {
      g_lastCalc = time[rates_total-1];
      DrawPanel();
     }

   return(rates_total);
  }

//====================================================================
// OnTimer
//====================================================================
void OnTimer()
  {
   DrawPanel();
  }

//====================================================================
// OnChartEvent
//====================================================================
void OnChartEvent(const int id,
                   const long &lparam,
                   const double &dparam,
                   const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      DrawPanel();
  }
//+------------------------------------------------------------------+
