//+------------------------------------------------------------------+
//|                            FoxWave_SRZoneScanner.mq5             |
//|                   Copyright Fox Wave - foxwavetrading.top        |
//|          Multi-Timeframe Support & Resistance Zone Scanner       |
//+------------------------------------------------------------------+
#property copyright "Fox Wave | foxwavetrading.top"
#property link      "https://foxwavetrading.top"
#property version   "1.00"
#property description "Automatically detects and draws Supply & Demand zones from multiple timeframes. Alerts when price enters a strong zone."
#property indicator_chart_window
#property indicator_plots 0

//======================================================================
//  INPUTS
//======================================================================
input group "TIMEFRAMES TO SCAN"
input bool   UseTF_M15   = true;    // Scan M15
input bool   UseTF_H1    = true;    // Scan H1
input bool   UseTF_H4    = true;    // Scan H4
input bool   UseTF_D1    = true;    // Scan D1

input group "ZONE DETECTION"
input int    LookbackBars     = 300;   // Bars to scan per timeframe
input int    MinTouches       = 2;     // Minimum touches to qualify as zone
input double ZoneWidthPips    = 8.0;   // Zone width in pips
input double MergeDistPips    = 5.0;   // Merge zones closer than X pips
input int    MinBarsBetween   = 3;     // Min bars between touches

input group "DISPLAY"
input bool   ShowM15Zones     = true;  // Show M15 zones
input bool   ShowH1Zones      = true;  // Show H1 zones
input bool   ShowH4Zones      = true;  // Show H4 zones
input bool   ShowD1Zones      = true;  // Show D1 zones
input bool   ShowZoneLabels   = true;  // Show touch count labels
input bool   ShowPanel        = true;  // Show info panel
input int    MaxZonesPerTF    = 6;     // Max zones to draw per timeframe

input group "COLORS — SUPPLY (resistance)"
input color  ClrSupplyM15     = C'80,20,20';     // M15 supply fill
input color  ClrSupplyH1      = C'110,25,25';    // H1 supply fill
input color  ClrSupplyH4      = C'150,30,30';    // H4 supply fill
input color  ClrSupplyD1      = C'200,40,40';    // D1 supply fill

input group "COLORS — DEMAND (support)"
input color  ClrDemandM15     = C'15,55,30';     // M15 demand fill
input color  ClrDemandH1      = C'20,75,40';     // H1 demand fill
input color  ClrDemandH4      = C'25,100,55';    // H4 demand fill
input color  ClrDemandD1      = C'30,130,70';    // D1 demand fill

input group "ALERTS"
input bool   AlertOnZoneEntry = true;   // Alert when price enters a zone
input double AlertPips        = 2.0;    // Alert when price within X pips of zone
input bool   AlertPopup       = true;   // Popup alert
input bool   AlertPush        = true;   // Push notification
input bool   AlertEmail       = false;  // Email alert

input group "PANEL"
input int    PanelX           = 15;     // Panel X offset
input int    PanelY           = 25;     // Panel Y offset

input group "PANEL COLORS"
input color  ClrPanelBg       = C'10,12,20';
input color  ClrHeaderBg      = C'16,20,38';
input color  ClrAccent        = C'255,140,0';
input color  ClrLabel         = C'110,120,145';
input color  ClrValue         = C'235,240,250';
input color  ClrBorderClr     = C'45,55,85';
input color  ClrFooter        = C'70,80,105';
input color  ClrSupplyTxt     = C'255,100,100';
input color  ClrDemandTxt     = C'90,210,140';

//======================================================================
//  CONSTANTS
//======================================================================
#define PFX          "FWSR_"
#define FONT_MAIN    "Consolas"
#define PANEL_W      230
#define PANEL_H      248
#define MAX_ZONES    120

//======================================================================
//  ZONE STRUCT
//======================================================================
enum ZoneType { ZONE_DEMAND, ZONE_SUPPLY };

struct SRZone
  {
   double      priceHigh;
   double      priceLow;
   double      priceMid;
   int         touches;
   ZoneType    zoneType;
   ENUM_TIMEFRAMES tf;
   string      tfName;
   bool        active;       // price has not broken through
   bool        alerted;
  };

SRZone   g_zones[MAX_ZONES];
int      g_zoneCount  = 0;
bool     g_panelBuilt = false;
datetime g_lastScan   = 0;
int      g_scanInterval = 60; // rescan every 60 seconds

ENUM_TIMEFRAMES g_tfList[4]   = {PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
string          g_tfNames[4]  = {"M15","H1","H4","D1"};
bool            g_tfUse[4];
bool            g_tfShow[4];
color           g_supplyClr[4];
color           g_demandClr[4];

//======================================================================
int OnInit()
  {
   g_tfUse[0]  = UseTF_M15;  g_tfUse[1]  = UseTF_H1;
   g_tfUse[2]  = UseTF_H4;   g_tfUse[3]  = UseTF_D1;

   g_tfShow[0] = ShowM15Zones; g_tfShow[1] = ShowH1Zones;
   g_tfShow[2] = ShowH4Zones;  g_tfShow[3] = ShowD1Zones;

   g_supplyClr[0] = ClrSupplyM15; g_supplyClr[1] = ClrSupplyH1;
   g_supplyClr[2] = ClrSupplyH4;  g_supplyClr[3] = ClrSupplyD1;

   g_demandClr[0] = ClrDemandM15; g_demandClr[1] = ClrDemandH1;
   g_demandClr[2] = ClrDemandH4;  g_demandClr[3] = ClrDemandD1;

   if(ShowPanel) BuildPanel();
   ScanAllZones();
   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//======================================================================
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }

//======================================================================
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[],  const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[],  const int &spread[])
  {
   if(rates_total < 2) return rates_total;
   if(AlertOnZoneEntry) CheckZoneAlerts(close[0]);
   return rates_total;
  }

//======================================================================
void OnTimer()
  {
   // Rescan zones periodically
   if(TimeCurrent() - g_lastScan >= g_scanInterval)
     {
      ScanAllZones();
      g_lastScan = TimeCurrent();
     }
   if(ShowPanel) RefreshPanel();
  }

//======================================================================
//  MAIN SCAN
//======================================================================
void ScanAllZones()
  {
   g_zoneCount = 0;

   for(int t = 0; t < 4; t++)
     {
      if(!g_tfUse[t]) continue;
      ScanTimeframe(g_tfList[t], g_tfNames[t], t);
     }

   DeleteZoneObjects();
   DrawAllZones();
   if(ShowPanel) RefreshPanel();
  }

//======================================================================
void ScanTimeframe(ENUM_TIMEFRAMES tf, string tfName, int tfIdx)
  {
   int bars = MathMin(LookbackBars, iBars(_Symbol, tf));
   if(bars < 10) return;

   double pip    = GetPipSize();
   double zoneW  = ZoneWidthPips  * pip;
   double mergD  = MergeDistPips  * pip;

   // Collect pivot highs and lows
   double pivHigh[];  datetime pivHighTime[];
   double pivLow[];   datetime pivLowTime[];
   ArrayResize(pivHigh, 0); ArrayResize(pivHighTime, 0);
   ArrayResize(pivLow,  0); ArrayResize(pivLowTime,  0);

   for(int i = 2; i < bars-2; i++)
     {
      double h  = iHigh(_Symbol, tf, i);
      double l  = iLow (_Symbol, tf, i);
      double h1 = iHigh(_Symbol, tf, i-1), h2 = iHigh(_Symbol, tf, i+1);
      double h3 = iHigh(_Symbol, tf, i-2), h4 = iHigh(_Symbol, tf, i+2);
      double l1 = iLow (_Symbol, tf, i-1), l2 = iLow (_Symbol, tf, i+1);
      double l3 = iLow (_Symbol, tf, i-2), l4 = iLow (_Symbol, tf, i+2);
      datetime t0 = iTime(_Symbol, tf, i);

      // Pivot high
      if(h >= h1 && h >= h2 && h >= h3 && h >= h4)
        {
         int sz = ArraySize(pivHigh);
         ArrayResize(pivHigh, sz+1);     pivHigh[sz]     = h;
         ArrayResize(pivHighTime, sz+1); pivHighTime[sz] = t0;
        }

      // Pivot low
      if(l <= l1 && l <= l2 && l <= l3 && l <= l4)
        {
         int sz = ArraySize(pivLow);
         ArrayResize(pivLow, sz+1);     pivLow[sz]     = l;
         ArrayResize(pivLowTime, sz+1); pivLowTime[sz] = t0;
        }
     }

   // Cluster pivot highs → Supply zones
   BuildZones(pivHigh, pivHighTime, ZONE_SUPPLY, zoneW, mergD, tf, tfName, tfIdx);

   // Cluster pivot lows → Demand zones
   BuildZones(pivLow, pivLowTime, ZONE_DEMAND, zoneW, mergD, tf, tfName, tfIdx);
  }

//======================================================================
void BuildZones(double &pivots[], datetime &pivTimes[],
                ZoneType zType, double zoneW, double mergD,
                ENUM_TIMEFRAMES tf, string tfName, int tfIdx)
  {
   int n = ArraySize(pivots);
   if(n == 0) return;

   bool used[];
   ArrayResize(used, n);
   ArrayInitialize(used, false);

   int zonesThisTF = 0;

   for(int i = 0; i < n && zonesThisTF < MaxZonesPerTF; i++)
     {
      if(used[i]) continue;

      double clusterPrice = pivots[i];
      int    touches      = 1;
      used[i]             = true;

      // Find nearby pivots within merge distance
      for(int j = i+1; j < n; j++)
        {
         if(used[j]) continue;
         if(MathAbs(pivots[j] - clusterPrice) <= mergD)
           {
            clusterPrice = (clusterPrice * touches + pivots[j]) / (touches + 1);
            touches++;
            used[j] = true;
           }
        }

      if(touches < MinTouches) continue;
      if(g_zoneCount >= MAX_ZONES) break;

      double zHigh = (zType == ZONE_SUPPLY)
                     ? clusterPrice + zoneW * 0.3
                     : clusterPrice + zoneW * 0.5;
      double zLow  = (zType == ZONE_SUPPLY)
                     ? clusterPrice - zoneW * 0.7
                     : clusterPrice - zoneW * 0.5;

      // Check if zone is still active (price hasn't closed through it)
      double lastClose = iClose(_Symbol, tf, 0);
      bool active = true;
      if(zType == ZONE_SUPPLY && lastClose > zHigh) active = false;
      if(zType == ZONE_DEMAND && lastClose < zLow)  active = false;

      g_zones[g_zoneCount].priceHigh = zHigh;
      g_zones[g_zoneCount].priceLow  = zLow;
      g_zones[g_zoneCount].priceMid  = (zHigh + zLow) / 2.0;
      g_zones[g_zoneCount].touches   = touches;
      g_zones[g_zoneCount].zoneType  = zType;
      g_zones[g_zoneCount].tf        = tf;
      g_zones[g_zoneCount].tfName    = tfName;
      g_zones[g_zoneCount].active    = active;
      g_zones[g_zoneCount].alerted   = false;
      g_zoneCount++;
      zonesThisTF++;
     }
  }

//======================================================================
//  DRAW ZONES
//======================================================================
void DeleteZoneObjects()
  {
   // Delete only zone rectangles and labels, keep panel
   long chartId = 0;
   int  total   = ObjectsTotal(chartId, 0, -1);
   for(int i = total-1; i >= 0; i--)
     {
      string nm = ObjectName(chartId, i, 0, -1);
      if(StringFind(nm, PFX+"Z_") == 0) ObjectDelete(chartId, nm);
     }
  }

//======================================================================
void DrawAllZones()
  {
   datetime t1 = iTime(_Symbol, PERIOD_CURRENT, LookbackBars);
   datetime t2 = TimeCurrent() + PeriodSeconds(PERIOD_D1) * 5; // extend right

   for(int z = 0; z < g_zoneCount; z++)
     {
      // Find TF index for color
      int tfIdx = 0;
      for(int t = 0; t < 4; t++)
         if(g_tfList[t] == g_zones[z].tf) { tfIdx = t; break; }

      if(!g_tfShow[tfIdx]) continue;

      color bg  = (g_zones[z].zoneType == ZONE_SUPPLY)
                  ? g_supplyClr[tfIdx]
                  : g_demandClr[tfIdx];

      color brd = (g_zones[z].zoneType == ZONE_SUPPLY)
                  ? AdjustBrightness(bg, 60)
                  : AdjustBrightness(bg, 60);

      string nm = PFX+"Z_"+IntegerToString(z);
      DrawZoneRect(nm, t1, t2,
                   g_zones[z].priceHigh, g_zones[z].priceLow,
                   bg, brd);

      // Label
      if(ShowZoneLabels)
        {
         string lnm = PFX+"Z_LBL_"+IntegerToString(z);
         string lbl = g_zones[z].tfName + " [" +
                      IntegerToString(g_zones[z].touches) + "x]" +
                      (g_zones[z].active ? "" : " ✗");
         DrawZoneLabel(lnm, t2, g_zones[z].priceMid, lbl,
                       g_zones[z].zoneType == ZONE_SUPPLY
                       ? ClrSupplyTxt : ClrDemandTxt);
        }
     }

   ChartRedraw();
  }

//======================================================================
void DrawZoneRect(string name, datetime t1, datetime t2,
                  double priceHigh, double priceLow,
                  color bg, color border)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, priceHigh, t2, priceLow);

   ObjectSetInteger(0, name, OBJPROP_TIME,    0, t1);
   ObjectSetDouble(0,  name, OBJPROP_PRICE,   0, priceHigh);
   ObjectSetInteger(0, name, OBJPROP_TIME,    1, t2);
   ObjectSetDouble(0,  name, OBJPROP_PRICE,   1, priceLow);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      border);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,    bg);
   ObjectSetInteger(0, name, OBJPROP_FILL,       true);
   ObjectSetInteger(0, name, OBJPROP_BACK,       true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//======================================================================
void DrawZoneLabel(string name, datetime t, double price,
                   string txt, color clr)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);

   ObjectSetInteger(0, name, OBJPROP_TIME,  t);
   ObjectSetDouble(0,  name, OBJPROP_PRICE, price);
   ObjectSetString(0,  name, OBJPROP_TEXT,  txt);
   ObjectSetString(0,  name, OBJPROP_FONT,  FONT_MAIN);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, name, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,   ANCHOR_RIGHT);
   ObjectSetInteger(0, name, OBJPROP_BACK,     false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//======================================================================
//  ALERT CHECK
//======================================================================
void CheckZoneAlerts(double price)
  {
   double pip      = GetPipSize();
   double alertDst = AlertPips * pip;

   for(int z = 0; z < g_zoneCount; z++)
     {
      if(!g_zones[z].active) continue;

      double distHigh = MathAbs(price - g_zones[z].priceHigh);
      double distLow  = MathAbs(price - g_zones[z].priceLow);
      double distMin  = MathMin(distHigh, distLow);

      // Inside zone or within alert distance
      bool nearZone = (distMin <= alertDst) ||
                      (price >= g_zones[z].priceLow && price <= g_zones[z].priceHigh);

      if(nearZone && !g_zones[z].alerted)
        {
         string zTypeTxt = (g_zones[z].zoneType == ZONE_SUPPLY) ? "SUPPLY" : "DEMAND";
         string msg = "FoxWave | " + _Symbol + " entering " +
                      g_zones[z].tfName + " " + zTypeTxt + " zone @ " +
                      DoubleToString(price, _Digits) +
                      " [" + IntegerToString(g_zones[z].touches) + " touches]";
         FireAlert(msg);
         g_zones[z].alerted = true;
        }

      // Reset alert when price leaves zone
      if(!nearZone && g_zones[z].alerted)
         g_zones[z].alerted = false;
     }
  }

//======================================================================
void FireAlert(string message)
  {
   if(AlertPopup) Alert(message);
   if(AlertPush)  SendNotification(message);
   if(AlertEmail) SendMail("FoxWave SR Zone Alert", message);
  }

//======================================================================
//  PANEL
//======================================================================
void BuildPanel()
  {
   Rect(PFX+"BG",       PanelX, PanelY, PANEL_W, PANEL_H, ClrPanelBg, ClrBorderClr);
   Rect(PFX+"HDR",      PanelX, PanelY, PANEL_W, 30,      ClrHeaderBg, ClrHeaderBg);
   Rect(PFX+"HDRLINE",  PanelX, PanelY+30, PANEL_W, 2,    ClrAccent, ClrAccent);

   Label(PFX+"TITLE",   PanelX+10, PanelY+6,  "FOX WAVE",           FONT_MAIN, 11, ClrAccent);
   Label(PFX+"SUB",     PanelX+10, PanelY+19, "SR ZONE SCANNER",    FONT_MAIN,  7, ClrLabel);
   Label(PFX+"SYM",     PanelX+10, PanelY+40, _Symbol,              FONT_MAIN, 13, ClrValue);

   Rect(PFX+"DIV1",     PanelX+10, PanelY+62, PANEL_W-20, 1, ClrBorderClr, ClrBorderClr);

   // Nearest zones above / below
   Label(PFX+"LBL_RES", PanelX+10, PanelY+69,  "NEAREST SUPPLY",   FONT_MAIN,  7, ClrLabel);
   Label(PFX+"VAL_RES", PanelX+10, PanelY+81,  "---",              FONT_MAIN, 11, ClrSupplyTxt);
   Label(PFX+"DST_RES", PanelX+10, PanelY+96,  "",                 FONT_MAIN,  7, ClrLabel);

   Rect(PFX+"DIV2",     PanelX+10, PanelY+110, PANEL_W-20, 1, ClrBorderClr, ClrBorderClr);

   Label(PFX+"LBL_SUP", PanelX+10, PanelY+117, "NEAREST DEMAND",   FONT_MAIN,  7, ClrLabel);
   Label(PFX+"VAL_SUP", PanelX+10, PanelY+129, "---",              FONT_MAIN, 11, ClrDemandTxt);
   Label(PFX+"DST_SUP", PanelX+10, PanelY+144, "",                 FONT_MAIN,  7, ClrLabel);

   Rect(PFX+"DIV3",     PanelX+10, PanelY+158, PANEL_W-20, 1, ClrBorderClr, ClrBorderClr);

   // Zone counts per TF
   Label(PFX+"LBL_CNT", PanelX+10, PanelY+164, "ACTIVE ZONES",     FONT_MAIN,  7, ClrLabel);
   Label(PFX+"CNT_M15", PanelX+10, PanelY+176, "M15: --",          FONT_MAIN,  8, C'60,120,180');
   Label(PFX+"CNT_H1",  PanelX+10, PanelY+189, "H1:  --",          FONT_MAIN,  8, C'50,160,90');
   Label(PFX+"CNT_H4",  PanelX+80, PanelY+176, "H4: --",           FONT_MAIN,  8, C'200,100,40');
   Label(PFX+"CNT_D1",  PanelX+80, PanelY+189, "D1: --",           FONT_MAIN,  8, C'200,40,40');

   Rect(PFX+"FOOTLINE", PanelX, PanelY+PANEL_H-18, PANEL_W, 1, ClrBorderClr, ClrBorderClr);
   Label(PFX+"FOOT",    PanelX+10, PanelY+PANEL_H-13, "foxwavetrading.top", FONT_MAIN, 7, ClrFooter);

   g_panelBuilt = true;
  }

//======================================================================
void RefreshPanel()
  {
   if(!g_panelBuilt) return;

   double price   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pip     = GetPipSize();

   // Find nearest supply above price
   double nearSupplyMid  = -1;
   int    nearSupplyTch  = 0;
   string nearSupplyTF   = "";
   double nearSupplyDst  = DBL_MAX;

   // Find nearest demand below price
   double nearDemandMid  = -1;
   int    nearDemandTch  = 0;
   string nearDemandTF   = "";
   double nearDemandDst  = DBL_MAX;

   int cntM15=0, cntH1=0, cntH4=0, cntD1=0;

   for(int z = 0; z < g_zoneCount; z++)
     {
      if(!g_zones[z].active) continue;

      // Count per TF
      if(g_zones[z].tfName == "M15") cntM15++;
      if(g_zones[z].tfName == "H1")  cntH1++;
      if(g_zones[z].tfName == "H4")  cntH4++;
      if(g_zones[z].tfName == "D1")  cntD1++;

      // Nearest supply above
      if(g_zones[z].zoneType == ZONE_SUPPLY && g_zones[z].priceLow > price)
        {
         double dst = g_zones[z].priceLow - price;
         if(dst < nearSupplyDst)
           {
            nearSupplyDst = dst;
            nearSupplyMid = g_zones[z].priceMid;
            nearSupplyTch = g_zones[z].touches;
            nearSupplyTF  = g_zones[z].tfName;
           }
        }

      // Nearest demand below
      if(g_zones[z].zoneType == ZONE_DEMAND && g_zones[z].priceHigh < price)
        {
         double dst = price - g_zones[z].priceHigh;
         if(dst < nearDemandDst)
           {
            nearDemandDst = dst;
            nearDemandMid = g_zones[z].priceMid;
            nearDemandTch = g_zones[z].touches;
            nearDemandTF  = g_zones[z].tfName;
           }
        }
     }

   // Supply
   if(nearSupplyMid > 0)
     {
      ObjectSetString(0, PFX+"VAL_RES", OBJPROP_TEXT,
                      DoubleToString(nearSupplyMid, _Digits) +
                      "  ["+IntegerToString(nearSupplyTch)+"x] "+nearSupplyTF);
      double pips = nearSupplyDst / pip;
      ObjectSetString(0, PFX+"DST_RES", OBJPROP_TEXT,
                      DoubleToString(pips, 1)+" pips away");
     }
   else
     {
      ObjectSetString(0, PFX+"VAL_RES", OBJPROP_TEXT, "none detected");
      ObjectSetString(0, PFX+"DST_RES", OBJPROP_TEXT, "");
     }

   // Demand
   if(nearDemandMid > 0)
     {
      ObjectSetString(0, PFX+"VAL_SUP", OBJPROP_TEXT,
                      DoubleToString(nearDemandMid, _Digits) +
                      "  ["+IntegerToString(nearDemandTch)+"x] "+nearDemandTF);
      double pips = nearDemandDst / pip;
      ObjectSetString(0, PFX+"DST_SUP", OBJPROP_TEXT,
                      DoubleToString(pips, 1)+" pips away");
     }
   else
     {
      ObjectSetString(0, PFX+"VAL_SUP", OBJPROP_TEXT, "none detected");
      ObjectSetString(0, PFX+"DST_SUP", OBJPROP_TEXT, "");
     }

   // Zone counts
   ObjectSetString(0, PFX+"CNT_M15", OBJPROP_TEXT, "M15: "+IntegerToString(cntM15));
   ObjectSetString(0, PFX+"CNT_H1",  OBJPROP_TEXT, "H1:  "+IntegerToString(cntH1));
   ObjectSetString(0, PFX+"CNT_H4",  OBJPROP_TEXT, "H4:  "+IntegerToString(cntH4));
   ObjectSetString(0, PFX+"CNT_D1",  OBJPROP_TEXT, "D1:  "+IntegerToString(cntD1));

   ChartRedraw();
  }

//======================================================================
//  HELPERS
//======================================================================
double GetPipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return (digits == 3 || digits == 5) ? point * 10 : point;
  }

color AdjustBrightness(color clr, int delta)
  {
   int r = MathMin(255, (int)((clr >> 16) & 0xFF) + delta);
   int g = MathMin(255, (int)((clr >>  8) & 0xFF) + delta);
   int b = MathMin(255, (int)( clr        & 0xFF) + delta);
   return (color)((r << 16) | (g << 8) | b);
  }

void Rect(string name,int x,int y,int w,int h,color bg,color border)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,      w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,      h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,    bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,      border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,       true);
  }

void Label(string name,int x,int y,string txt,string font,int sz,color clr)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name,OBJPROP_TEXT,      txt);
   ObjectSetString(0, name,OBJPROP_FONT,      font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,  sz);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     clr);
   ObjectSetInteger(0,name,OBJPROP_CORNER,    CORNER_LEFT_UPPER);
  }
//+------------------------------------------------------------------+