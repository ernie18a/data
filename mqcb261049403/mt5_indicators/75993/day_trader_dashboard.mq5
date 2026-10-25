//+------------------------------------------------------------------+
//|                                         Day Trader Dashboard.mq5 |
//|                                                                  |
//|                    Professional Trading Utility for MetaTrader 5 |
//|                                Copyright (c) 2026 Marian Beceanu |
//|                            https://www.mql5.com/en/users/zorbacc |
//|                                  Email: marian.beceanu@gmail.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2026 Marian Beceanu"
#property link      "https://forge.mql5.io"
#property version   "2.10"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Day Trading Range/Breakout Dashboard - Bloomberg-style panel"
#property description "Multi-instance capable, auto-scaling, on-chart range lines, fully self-cleaning"

//====================================================================
// ENUMS (shown as dropdown lists in the Inputs tab)
//====================================================================
enum ENUM_COLOR_THEME
  {
   THEME_BLOOMBERG_BLACK,   // Bloomberg Black (Black / Amber)
   THEME_BLOOMBERG_NAVY,    // Bloomberg Navy (Navy / Gold)
   THEME_DARK_GRAPHITE,     // Dark Graphite (Charcoal / White)
   THEME_MIDNIGHT_BLUE,     // Midnight Blue (Blue / Cyan)
   THEME_TERMINAL_GREEN,    // Terminal Green (Black / Green)
   THEME_WHITE_PRO          // White Professional (White / Black)
  };

enum ENUM_PANEL_CORNER
  {
   PANEL_TOP_LEFT,          // Top Left
   PANEL_TOP_RIGHT,         // Top Right
   PANEL_BOTTOM_LEFT,       // Bottom Left
   PANEL_BOTTOM_RIGHT       // Bottom Right
  };

enum ENUM_LINE_STYLE_UI
  {
   RLINE_SOLID,             // Solid
   RLINE_DASH,              // Dash
   RLINE_DOT,               // Dot
   RLINE_DASHDOT            // Dash-Dot
  };

//====================================================================
// INPUTS
//====================================================================
input group "========== INSTANCE (allows multiple panels on one chart) =========="
input int                 InpInstanceID            = 1;       // Instance ID (auto-resolved to a free one if already taken)

input group "========== INTRADAY STRATEGY SETTINGS =========="
input int                 InpLookbackBars          = 20;       // Range lookback (bars)
input double              InpBreakoutBufferPts     = 5.0;      // Breakout confirmation buffer (points)
input int                 InpTimerSeconds          = 1;        // Panel refresh interval (seconds)

input group "========== DASHBOARD APPEARANCE =========="
input ENUM_COLOR_THEME    InpColorTheme            = THEME_BLOOMBERG_BLACK; // Color theme
input int                 InpFontSize              = 10;       // Base text size (pt)
input bool                InpAutoScale             = true;     // Auto-scale panel to text length / font size
input double              InpExtraScale            = 1.0;      // Extra manual scale multiplier (0.6 - 2.5)

input group "========== DASHBOARD POSITION =========="
input bool                InpShowPanel             = true;     // Show panel
input ENUM_PANEL_CORNER   InpCorner                = PANEL_TOP_LEFT; // Panel corner (anchor)
input int                 InpPanelX                = 15;       // Horizontal offset from corner (px)
input int                 InpPanelY                = 15;       // Vertical offset from corner (px)

input group "========== RANGE LINES ON CHART =========="
input bool                InpShowRangeLines        = true;     // Draw range High/Low lines on chart
input ENUM_LINE_STYLE_UI  InpRangeLineStyle        = RLINE_DASH; // Range line style
input int                 InpRangeLineWidth        = 1;        // Range line width
input bool                InpShowRangePriceTags    = true;     // Show floating price tags next to the lines

//====================================================================
// GLOBALS
//====================================================================
string g_prefix        = "DTD_";
int    g_effectiveID   = 1;
color  g_bg, g_border, g_header, g_accent, g_text, g_subtext, g_green, g_red, g_yellow, g_chip, g_chipText;
double g_fScale         = 1.0;
int    g_panelW         = 420;
int    g_panelH         = 300;
int    g_originX        = 0;
int    g_originY        = 0;
bool   g_panelBuilt     = false;

//====================================================================
// THEME SELECTION
//====================================================================
void ApplyTheme(ENUM_COLOR_THEME theme)
  {
   switch(theme)
     {
      case THEME_BLOOMBERG_NAVY:
         g_bg=C'8,14,32';     g_border=C'212,175,55'; g_header=C'212,175,55';
         g_accent=C'212,175,55'; g_text=C'235,238,245'; g_subtext=C'150,160,180';
         g_chip=C'16,24,46';  g_chipText=C'8,14,32';
         break;
      case THEME_DARK_GRAPHITE:
         g_bg=C'24,24,24';    g_border=C'90,90,90';   g_header=C'240,240,240';
         g_accent=C'0,174,239'; g_text=C'235,235,235'; g_subtext=C'150,150,150';
         g_chip=C'34,34,34';  g_chipText=C'255,255,255';
         break;
      case THEME_MIDNIGHT_BLUE:
         g_bg=C'6,20,40';     g_border=C'0,174,239';  g_header=C'0,200,255';
         g_accent=C'0,200,255'; g_text=C'225,240,255'; g_subtext=C'120,150,180';
         g_chip=C'10,30,55';  g_chipText=C'6,20,40';
         break;
      case THEME_TERMINAL_GREEN:
         g_bg=C'6,10,6';      g_border=C'0,200,83';   g_header=C'0,255,120';
         g_accent=C'0,255,120'; g_text=C'200,255,210'; g_subtext=C'90,150,100';
         g_chip=C'10,18,10';  g_chipText=C'6,10,6';
         break;
      case THEME_WHITE_PRO:
         g_bg=C'250,250,250'; g_border=C'40,40,40';   g_header=C'20,20,20';
         g_accent=C'0,90,200'; g_text=C'25,25,25';     g_subtext=C'100,100,100';
         g_chip=C'235,235,235'; g_chipText=C'255,255,255';
         break;
      case THEME_BLOOMBERG_BLACK:
      default:
         g_bg=C'8,23,38';     g_border=C'212,175,55'; g_header=C'212,175,55';
         g_accent=C'212,175,55'; g_text=C'245,245,245'; g_subtext=C'169,176,184';
         g_chip=C'5,14,24';   g_chipText=C'8,23,38';
         break;
     }
   g_green  = C'0,200,83';
   g_red    = C'255,82,82';
   g_yellow = C'255,205,60';
  }

ENUM_LINE_STYLE MapLineStyle(ENUM_LINE_STYLE_UI s)
  {
   switch(s)
     {
      case RLINE_SOLID:   return STYLE_SOLID;
      case RLINE_DOT:     return STYLE_DOT;
      case RLINE_DASHDOT: return STYLE_DASHDOT;
      case RLINE_DASH:
      default:            return STYLE_DASH;
     }
  }

//====================================================================
// OBJECT HELPERS
//====================================================================
string Nm(string key) { return g_prefix+key; }

void UpsertRect(string key,int x,int y,int w,int h,color bg,color border)
  {
   string name=Nm(key);
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void UpsertLabel(string key,string text,int x,int y,int fontsize,color clr,bool bold=false)
  {
   string name=Nm(key);
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT, bold ? "Segoe UI Semibold" : "Segoe UI");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void SetLabelText(string key,string text) { ObjectSetString(0,Nm(key),OBJPROP_TEXT,text); }
void SetLabelColor(string key,color clr)  { ObjectSetInteger(0,Nm(key),OBJPROP_COLOR,clr); }

string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   string s=EnumToString(tf);       // e.g. "PERIOD_H1"
   StringReplace(s,"PERIOD_","");   // -> "H1"
   return s;
  }

int TextWidthPx(string text,int fontsize,bool bold=false)
  {
   int n=StringLen(text);
   double perChar=fontsize*0.60 + (bold?0.55:0.0);
   return (int)MathRound(n*perChar)+2;
  }

//--------------------------------------------------------------------
// Horizontal range line + optional floating price tag
//--------------------------------------------------------------------
void UpsertHLine(string key,double price,color clr,int width,ENUM_LINE_STYLE style,string tooltip)
  {
   string name=Nm(key);
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
  }

void UpsertPriceTag(string key,string text,datetime t,double price,color clr,int fontsize)
  {
   string name=Nm(key);
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_TEXT,0,t,price);
   ObjectSetInteger(0,name,OBJPROP_TIME,t);
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
  }

void RemoveObj(string key)
  {
   string name=Nm(key);
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
  }

//====================================================================
// INSTANCE ID RESOLUTION (avoids collisions between copies)
//====================================================================
int ResolveInstanceID(int requested)
  {
   int id=MathMax(1,requested);
   int guard=0;
   while(guard<2000)
     {
      string testName="DTD_"+IntegerToString(id)+"_BG";
      if(ObjectFind(0,testName)<0) break; // free slot found
      id++;
      guard++;
     }
   return id;
  }

//====================================================================
// DELETE ALL OBJECTS OF THIS INSTANCE (robust, single native call)
//====================================================================
void DeletePanel()
  {
   ObjectsDeleteAll(0,g_prefix);
   g_panelBuilt=false;
   ChartRedraw();
  }

//====================================================================
// LAYOUT / ORIGIN COMPUTATION
//====================================================================
void ComputeOrigin()
  {
   long chartW=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   long chartH=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

   switch(InpCorner)
     {
      case PANEL_TOP_RIGHT:
         g_originX=(int)(chartW-InpPanelX-g_panelW);
         g_originY=InpPanelY;
         break;
      case PANEL_BOTTOM_LEFT:
         g_originX=InpPanelX;
         g_originY=(int)(chartH-InpPanelY-g_panelH);
         break;
      case PANEL_BOTTOM_RIGHT:
         g_originX=(int)(chartW-InpPanelX-g_panelW);
         g_originY=(int)(chartH-InpPanelY-g_panelH);
         break;
      case PANEL_TOP_LEFT:
      default:
         g_originX=InpPanelX;
         g_originY=InpPanelY;
         break;
     }
   if(g_originX<0) g_originX=0;
   if(g_originY<0) g_originY=0;
  }

void ComputeLayout()
  {
   double fscale=InpAutoScale ? (InpFontSize/10.0) : 1.0;
   fscale*=MathMax(0.6,MathMin(2.5,InpExtraScale));
   g_fScale=fscale;

   int baseW=420, baseH=300;
   int w=(int)MathRound(baseW*g_fScale);
   int h=(int)MathRound(baseH*g_fScale);

   if(InpAutoScale)
     {
      int fBody =(int)MathRound(InpFontSize*g_fScale);
      int fTitle=(int)MathRound((InpFontSize+4)*g_fScale);

      string longSymbolLine="SYMBOL: "+_Symbol+"    "+TimeframeToString(_Period)+"XX"; // extra padding for the TF badge chip
      string longRangeLine ="RANGE HIGH: "+DoubleToString(1.234567,6);
      string longStatusLine="STATUS: BEARISH BREAKOUT CONFIRMED";
      string titleLine     ="DAY TRADING SYSTEM";

      int candidates[4];
      candidates[0]=TextWidthPx(longSymbolLine,fBody,true);
      candidates[1]=TextWidthPx(longRangeLine,fBody,false);
      candidates[2]=TextWidthPx(longStatusLine,fBody+1,true);
      candidates[3]=TextWidthPx(titleLine,fTitle,true);

      int maxTextW=0;
      for(int i=0;i<4;i++) if(candidates[i]>maxTextW) maxTextW=candidates[i];

      int padX=(int)MathRound(18*g_fScale);
      int neededW=maxTextW+padX*2;
      if(neededW>w) w=neededW;
     }

   g_panelW=MathMax(260,w);
   g_panelH=MathMax(230,h);
   ComputeOrigin();
  }

//====================================================================
// BUILD PANEL (structure - called on init / settings change / resize)
//====================================================================
void BuildPanel()
  {
   if(!InpShowPanel)
     {
      // remove only the panel graphics, keep range lines logic consistent with their own toggle
      RemoveObj("BG"); RemoveObj("HEADBAR"); RemoveObj("DIV1"); RemoveObj("DIV2");
      RemoveObj("TITLE"); RemoveObj("SUB"); RemoveObj("SYMBOL"); RemoveObj("TFBADGE"); RemoveObj("TFTEXT");
      RemoveObj("HIGH"); RemoveObj("LOW"); RemoveObj("BREAKSTAT"); RemoveObj("ACTION"); RemoveObj("UPDATED"); RemoveObj("FOOT");
      g_panelBuilt=false;
      ChartRedraw();
      return;
     }

   ComputeLayout();

   int x=g_originX, y=g_originY;
   int padX=(int)MathRound(18*g_fScale);
   int fTitle=(int)MathRound((InpFontSize+4)*g_fScale);
   int fSub  =(int)MathRound(MathMax(7,InpFontSize-2)*g_fScale);
   int fBody =(int)MathRound(InpFontSize*g_fScale);
   int fStat =(int)MathRound((InpFontSize+1)*g_fScale);
   int fFoot =(int)MathRound(MathMax(6,InpFontSize-3)*g_fScale);

   int rowH  =(int)MathRound(22*g_fScale);
   int gapSm =(int)MathRound(8*g_fScale);
   int gapLg =(int)MathRound(16*g_fScale);

   int yTitle  =(int)MathRound(14*g_fScale);
   int ySub    =yTitle+rowH;
   int yDiv1   =ySub+rowH-(int)MathRound(4*g_fScale);
   int ySymbol =yDiv1+gapLg;
   int yHigh   =ySymbol+rowH+gapSm;
   int yLow    =yHigh+rowH;
   int yDiv2   =yLow+rowH-(int)MathRound(2*g_fScale);
   int yStatus =yDiv2+gapLg;
   int yAction =yStatus+rowH+gapSm;
   int yUpdated=g_panelH-(int)MathRound(46*g_fScale);
   int yFoot   =g_panelH-(int)MathRound(22*g_fScale);

   UpsertRect("BG",x,y,g_panelW,g_panelH,g_bg,g_border);
   UpsertRect("HEADBAR",x,y,g_panelW,(int)MathRound(4*g_fScale),g_accent,g_accent);
   UpsertRect("DIV1",x+padX,y+yDiv1,g_panelW-2*padX,1,g_border,g_border);
   UpsertRect("DIV2",x+padX,y+yDiv2,g_panelW-2*padX,1,g_border,g_border);

   UpsertLabel("TITLE","DAY TRADING SYSTEM",x+padX,y+yTitle,fTitle,g_header,true);
   UpsertLabel("SUB","RANGE FADE & BREAKOUT MONITOR",x+padX,y+ySub,fSub,g_subtext,true);

   string symTxt="SYMBOL: "+_Symbol;
   UpsertLabel("SYMBOL",symTxt,x+padX,y+ySymbol,fBody,g_text,true);

   // Timeframe badge - a small colored chip placed right after the symbol text,
   // so the current chart period (H1, M15, D1, ...) is unmistakably visible.
   string tfTxt=TimeframeToString(_Period);
   int    tfFont=(int)MathRound(MathMax(7,InpFontSize-1)*g_fScale);
   int    tfPadX=(int)MathRound(6*g_fScale);
   int    tfTextW=TextWidthPx(tfTxt,tfFont,true);
   int    tfBadgeW=tfTextW+tfPadX*2;
   int    tfBadgeH=(int)MathRound(16*g_fScale);
   int    tfBadgeX=x+g_panelW-padX-tfBadgeW;   // anchored to the right edge of the panel
   int    tfBadgeY=y+ySymbol-(int)MathRound(2*g_fScale);

   UpsertRect("TFBADGE",tfBadgeX,tfBadgeY,tfBadgeW,tfBadgeH,g_accent,g_accent);
   UpsertLabel("TFTEXT",tfTxt,tfBadgeX+tfPadX,tfBadgeY+(int)MathRound(2*g_fScale),tfFont,g_chipText,true);
   UpsertLabel("HIGH","RANGE HIGH: 0.00000",x+padX,y+yHigh,fBody,g_text,false);
   UpsertLabel("LOW","RANGE LOW: 0.00000",x+padX,y+yLow,fBody,g_text,false);

   UpsertLabel("BREAKSTAT","STATUS: SCANNING",x+padX,y+yStatus,fStat,g_yellow,true);
   UpsertLabel("ACTION","ACTION: WAIT",x+padX,y+yAction,fStat,g_subtext,true);

   UpsertLabel("UPDATED","UPDATED: --:--:--",x+padX,y+yUpdated,fFoot,g_subtext,false);
   UpsertLabel("FOOT","Day Trader Dashboard #"+IntegerToString(g_effectiveID),x+padX,y+yFoot,fFoot,g_accent,false);

   g_panelBuilt=true;
   ChartRedraw();
  }

//====================================================================
// UPDATE PANEL (data only - called on timer, no object recreation)
//====================================================================
void UpdatePanel()
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   if(CopyRates(_Symbol,_Period,1,InpLookbackBars,rates)<InpLookbackBars) return;

   double highest=rates[0].high;
   double lowest =rates[0].low;
   for(int i=1;i<InpLookbackBars;i++)
     {
      if(rates[i].high>highest) highest=rates[i].high;
      if(rates[i].low <lowest)  lowest =rates[i].low;
     }

   double current_price=rates[0].close;
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double buffer=InpBreakoutBufferPts*_Point;

   string stat; color stat_col; string rec; color rec_col;

   if(current_price>highest+buffer)
     {
      stat="BULLISH BREAKOUT";       stat_col=g_green;
      rec ="TRADE THE BREAK (LONG)"; rec_col=g_green;
     }
   else if(current_price<lowest-buffer)
     {
      stat="BEARISH BREAKOUT";        stat_col=g_red;
      rec ="TRADE THE BREAK (SHORT)"; rec_col=g_red;
     }
   else
     {
      stat="WITHIN RANGE (FADE SETUP)";  stat_col=g_yellow;
      rec ="LOOK FOR REVERSAL AT BOUNDS"; rec_col=g_subtext;
     }

   if(InpShowPanel && g_panelBuilt)
     {
      SetLabelText("HIGH","RANGE HIGH: "+DoubleToString(highest,digits));
      SetLabelText("LOW","RANGE LOW: "+DoubleToString(lowest,digits));
      SetLabelText("BREAKSTAT","STATUS: "+stat);
      SetLabelColor("BREAKSTAT",stat_col);
      SetLabelText("ACTION","ACTION: "+rec);
      SetLabelColor("ACTION",rec_col);
      SetLabelText("UPDATED","UPDATED: "+TimeToString(TimeCurrent(),TIME_SECONDS));
     }

   // ---- Range lines on the chart ----
   if(InpShowRangeLines)
     {
      ENUM_LINE_STYLE mStyle=MapLineStyle(InpRangeLineStyle);
      UpsertHLine("LINE_HIGH",highest,g_green,InpRangeLineWidth,mStyle,
                  "Range High ("+DoubleToString(highest,digits)+")");
      UpsertHLine("LINE_LOW",lowest,g_red,InpRangeLineWidth,mStyle,
                  "Range Low ("+DoubleToString(lowest,digits)+")");

      if(InpShowRangePriceTags)
        {
         datetime tagTime=TimeCurrent()+PeriodSeconds(_Period)*3;
         UpsertPriceTag("TAG_HIGH","  H "+DoubleToString(highest,digits),tagTime,highest,g_green,
                         (int)MathRound(MathMax(7,InpFontSize-1)*g_fScale));
         UpsertPriceTag("TAG_LOW","  L "+DoubleToString(lowest,digits),tagTime,lowest,g_red,
                         (int)MathRound(MathMax(7,InpFontSize-1)*g_fScale));
        }
      else
        {
         RemoveObj("TAG_HIGH");
         RemoveObj("TAG_LOW");
        }
     }
   else
     {
      RemoveObj("LINE_HIGH"); RemoveObj("LINE_LOW");
      RemoveObj("TAG_HIGH");  RemoveObj("TAG_LOW");
     }

   ChartRedraw();
  }

//====================================================================
// EVENT HANDLERS
//====================================================================
int OnInit()
  {
   // Resolve a collision-free prefix BEFORE touching any objects,
   // so removing one instance never deletes another instance's panel,
   // and no stale objects from a previous compile linger under the same name.
   g_effectiveID=ResolveInstanceID(InpInstanceID);
   g_prefix="DTD_"+IntegerToString(g_effectiveID)+"_";

   if(g_effectiveID!=InpInstanceID)
      PrintFormat("Day Trader Dashboard: Instance ID %d was already in use on this chart - using %d instead.",
                  InpInstanceID,g_effectiveID);

   ApplyTheme(InpColorTheme);
   DeletePanel();          // guarantee a clean slate for this prefix
   BuildPanel();
   UpdatePanel();
   EventSetTimer(MathMax(1,InpTimerSeconds));
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeletePanel();           // removes every object created by THIS instance, of every type
   ChartRedraw();
  }

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
   return(rates_total);
  }

void OnTimer()
  {
   UpdatePanel();
  }

void OnChartEvent(const int id,
                   const long &lparam,
                   const double &dparam,
                   const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // Chart resized/scrolled - recompute anchor position for RIGHT/BOTTOM corners
      BuildPanel();
      UpdatePanel();
     }
  }
//+------------------------------------------------------------------+
