//+------------------------------------------------------------------+
//|                                                   PropSpread.mq5 |
//|        Spread Monitor for Prop-Firm / Funded Accounts            |
//|                                     (c) 2026 Timon Krueger       |
//+------------------------------------------------------------------+
//  Free spread monitor for MetaTrader 5. Utility only: it never sends an
//  order. Samples the spread once per second (time weighted, not tick
//  weighted), keeps a ring buffer over a configurable window, tracks a
//  session statistic since server midnight, relates the spread to ATR,
//  raises an alert when the spread stays above a threshold for N seconds,
//  and optionally logs to Files\PropSpread\<symbol>_<yyyymm>.csv.
//+------------------------------------------------------------------+
#property copyright "Timon Krueger"
#property link "https://www.mql5.com/en/users/sg_mephisot"
#property version "1.00"
#property description "PropSpread - spread monitor panel for prop-firm and funded accounts."
#property description "Shows the live spread in points AND in price units (index points on 2-digit index CFDs,"
   #property description "pips on FX), a rolling min/avg/median/max, the spread as % of ATR, a session statistic"
#property description "since server midnight, an alert when the spread stays above a threshold for N seconds,"
#property description "and an optional CSV log. Utility only - it never sends an order."

//--- Enums ----------------------------------------------------------
enum ENUM_PSP_CORNER
  {
   PSP_LEFT_UPPER  =0,                   // Left upper
   PSP_RIGHT_UPPER =1,                   // Right upper
   PSP_LEFT_LOWER  =2,                   // Left lower
   PSP_RIGHT_LOWER =3                    // Right lower
  };

//--- Inputs ---------------------------------------------------------
input group "=== Rolling statistics ==="
input int              InpWindowMinutes    =60;                  // Rolling window (minutes, 1 sample per second)
input group "=== ATR context ==="
input int              InpATRPeriod        =14;                  // ATR period
input ENUM_TIMEFRAMES  InpATRTimeframe     =PERIOD_CURRENT;      // ATR timeframe
input group "=== Alert ==="
input double           InpAlertThreshold   =0.0;                 // Alert when spread > threshold (points, 0 = off)
input int              InpAlertHoldSec     =5;                   // ... for longer than N seconds
input int              InpAlertCooldownSec =300;                 // Minimum seconds between alerts
input bool             InpAlertPopup       =true;                // Popup alert
input bool             InpAlertPush        =false;               // Push notification (needs MetaQuotes ID)
input group "=== CSV log ==="
input bool             InpLogCSV           =false;               // Write CSV log (Files\PropSpread\<symbol>_<yyyymm>.csv)
input int              InpLogEverySec      =10;                  // Log one row every N seconds
input group "=== Panel ==="
input ENUM_PSP_CORNER  InpPanelCorner      =PSP_RIGHT_UPPER;     // Panel corner
input int              InpPanelX           =12;                  // Panel X offset
input int              InpPanelY           =22;                  // Panel Y offset

//--- Constants ------------------------------------------------------
#define PSP_PANEL_PREFIX "PSP_P_"
#define PSP_MAX_ROWS 24
#define PSP_MAX_SAMPLES 86400 // 24 h at one sample per second

//--- State ----------------------------------------------------------
int      g_atrHandle=INVALID_HANDLE;
double   g_buf[];                // ring buffer of spreads in points
int      g_cap=0;
int      g_head=0;               // next write index
int      g_count=0;
double   g_unitPts=1.0;          // points per display unit (pip / index point)
string   g_unitName="pts";
string   g_unitLegend="";
int      g_aboveSec=0;           // consecutive seconds above threshold
datetime g_lastAlert=0;
int      g_alertCount=0;
datetime g_lastLog=0;
int      g_logRows=0;
bool     g_logErrorShown=false;
string   g_logFile="";
// session statistic (since server midnight)
int      g_sessionDay=-1;
long     g_sesN=0;
double   g_sesSum=0.0;
double   g_sesMin=0.0;
double   g_sesMax=0.0;
long     g_sesAbove=0;
double   g_lastSpreadPts=0.0;
bool     g_noQuoteLogged=false;
color    g_colText,g_colDim;

//--- Panel line buffer ---------------------------------------------
string   g_rowText[PSP_MAX_ROWS];
color    g_rowColor[PSP_MAX_ROWS];
int      g_rowSize[PSP_MAX_ROWS];
int      g_rowCount=0;
int      g_rowsDrawn=0;

//+------------------------------------------------------------------+
//| Display unit derived from digits and calc mode (never hardcoded) |
//+------------------------------------------------------------------+
void DeriveUnit()
  {
   int digits=_Digits;
   long calc=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE);
   bool isForex=(calc==SYMBOL_CALC_MODE_FOREX || calc==SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE);

   if(isForex)
     {
      g_unitPts=(digits==3 || digits==5) ? 10.0 : 1.0;
      g_unitName="pips";
     }
   else
     {
      g_unitPts=MathPow(10.0,digits); // one full price unit
      bool isCfd=(calc==SYMBOL_CALC_MODE_CFD || calc==SYMBOL_CALC_MODE_CFDINDEX ||
                    calc==SYMBOL_CALC_MODE_CFDLEVERAGE);
      g_unitName=isCfd ? "index pts" : "price units";
     }
   if(g_unitPts<=0) g_unitPts=1.0;
   g_unitLegend=StringFormat("1 %s = %.0f pts",
                               (g_unitName=="pips") ? "pip" : (g_unitName=="index pts" ? "index pt" : "price unit"),
                               g_unitPts);
  }

//+------------------------------------------------------------------+
//| ATR of the last closed bar, 0 when unavailable                   |
//+------------------------------------------------------------------+
double CurrentATR()
  {
   if(g_atrHandle==INVALID_HANDLE) return 0.0;
   double buf[];
   if(CopyBuffer(g_atrHandle,0,1,1,buf)<1) return 0.0;
   return (buf[0]>0) ? buf[0] : 0.0;
  }

//+------------------------------------------------------------------+
//| Push one spread sample into the ring buffer                      |
//+------------------------------------------------------------------+
void PushSample(const double spreadPts)
  {
   if(g_cap<=0) return;
   g_buf[g_head]=spreadPts;
   g_head=(g_head+1)%g_cap;
   if(g_count<g_cap) g_count++;
  }

//+------------------------------------------------------------------+
//| Min / average / median / max over the rolling window             |
//+------------------------------------------------------------------+
void WindowStats(double &mn,double &avg,double &med,double &mx,double &abovePct)
  {
   mn=0; avg=0; med=0; mx=0; abovePct=0;
   if(g_count<=0) return;

   double tmp[];
   ArrayResize(tmp,g_count);
   double sum=0;
   int above=0;
   mn=DBL_MAX; mx=-DBL_MAX;
   for(int i=0; i<g_count; i++)
     {
      double v=g_buf[i];
      tmp[i]=v;
      sum+=v;
      if(v<mn) mn=v;
      if(v>mx) mx=v;
      if(InpAlertThreshold>0 && v>InpAlertThreshold) above++;
     }
   avg=sum/g_count;
   ArraySort(tmp);
   if(g_count%2==1) med=tmp[g_count/2];
   else med=0.5*(tmp[g_count/2-1]+tmp[g_count/2]);
   abovePct=100.0*above/g_count;
  }

//+------------------------------------------------------------------+
//| Session statistic since server midnight                          |
//+------------------------------------------------------------------+
void SessionUpdate(const double spreadPts)
  {
   int day=(int)(TimeCurrent()/86400);
   if(day!=g_sessionDay)
     {
      if(g_sessionDay>=0)
         PrintFormat("[PropSpread] Session closed | %s | n=%I64d avg=%.1f min=%.1f max=%.1f pts",
                     _Symbol,g_sesN,g_sesN>0 ? g_sesSum/g_sesN : 0.0,g_sesMin,g_sesMax);
      g_sessionDay=day;
      g_sesN=0; g_sesSum=0; g_sesMin=spreadPts; g_sesMax=spreadPts; g_sesAbove=0;
      PrintFormat("[PropSpread] New session (server day) | %s",TimeToString(TimeCurrent(),TIME_DATE));
     }
   g_sesN++;
   g_sesSum+=spreadPts;
   if(spreadPts<g_sesMin) g_sesMin=spreadPts;
   if(spreadPts>g_sesMax) g_sesMax=spreadPts;
   if(InpAlertThreshold>0 && spreadPts>InpAlertThreshold) g_sesAbove++;
  }

//+------------------------------------------------------------------+
//| Alert with hold time and cooldown                                |
//+------------------------------------------------------------------+
void CheckAlert(const double spreadPts,const double avg,const double atrPct)
  {
   if(InpAlertThreshold<=0)
     {
      g_aboveSec=0;
      return;
     }

   if(spreadPts>InpAlertThreshold) g_aboveSec++;
   else g_aboveSec=0;

   if(g_aboveSec<=MathMax(InpAlertHoldSec,0)) return;
   if(g_lastAlert>0 && (TimeCurrent()-g_lastAlert)<MathMax(InpAlertCooldownSec,0)) return;

   g_lastAlert=TimeCurrent();
   g_alertCount++;
   string msg=StringFormat("ALERT: %s spread %.0f pts > %.0f pts for %d s (window avg %.1f, %.1f%% of ATR)",
                             _Symbol,spreadPts,InpAlertThreshold,g_aboveSec,avg,atrPct);
   Print("[PropSpread] ",msg);
   if(MQLInfoInteger(MQL_TESTER)) return;
   if(InpAlertPopup) Alert("PropSpread: ",msg);
   if(InpAlertPush) SendNotification("PropSpread: "+msg);
  }

//+------------------------------------------------------------------+
//| Symbol name that is safe for a file name                         |
//+------------------------------------------------------------------+
string SafeSymbolName()
  {
   string s=_Symbol;
   string bad="\\/:*?\"<>|";
   for(int i=0; i<StringLen(bad); i++)
     {
      string ch=StringSubstr(bad,i,1);
      StringReplace(s,ch,"_");
     }
   return s;
  }

//+------------------------------------------------------------------+
//| Append one row to the monthly CSV log                            |
//+------------------------------------------------------------------+
void LogCSV(const double spreadPts,const double bid,const double ask,const double atr,const double atrPct)
  {
   if(!InpLogCSV) return;
   datetime now=TimeCurrent();
   if(g_lastLog>0 && (now-g_lastLog)<MathMax(InpLogEverySec,1)) return;
   g_lastLog=now;

   MqlDateTime dt;
   TimeToStruct(now,dt);
   string fn=StringFormat("PropSpread\\%s_%04d%02d.csv",SafeSymbolName(),dt.year,dt.mon);
   if(fn!=g_logFile)
     {
      g_logFile=fn;
      FolderCreate("PropSpread");
      PrintFormat("[PropSpread] CSV log file: MQL5\\Files\\%s",fn);
     }

   int h=FileOpen(fn,FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI,';');
   if(h==INVALID_HANDLE)
     {
      if(!g_logErrorShown)
        {
         PrintFormat("[PropSpread] CSV log could not be opened (%s), error %d - logging disabled until restart",fn,GetLastError());
         g_logErrorShown=true;
        }
      return;
     }
   bool fresh=(FileSize(h)==0);
   FileSeek(h,0,SEEK_END);
   if(fresh)
      FileWrite(h,"time_server","symbol","spread_pts","spread_price","bid","ask","atr_price","spread_atr_pct");
   FileWrite(h,TimeToString(now,TIME_DATE | TIME_SECONDS),_Symbol,
             DoubleToString(spreadPts,1),DoubleToString(spreadPts*_Point,_Digits),
             DoubleToString(bid,_Digits),DoubleToString(ask,_Digits),
             DoubleToString(atr,_Digits),DoubleToString(atrPct,2));
   FileClose(h);
   g_logRows++;
  }

//+------------------------------------------------------------------+
//| Panel colours for light and dark chart backgrounds               |
//+------------------------------------------------------------------+
void PickPanelColors()
  {
   color bg=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   int rr=(int)(bg & 0xFF),gg=(int)((bg >> 8) & 0xFF),bb=(int)((bg >> 16) & 0xFF);
   double brightness=0.299*rr+0.587*gg+0.114*bb;
   if(brightness>128)
     {
      g_colText=clrBlack;
      g_colDim=clrDarkSlateGray;
     }
   else
     {
      g_colText=clrWhiteSmoke;
      g_colDim=clrGainsboro;
     }
  }

//+------------------------------------------------------------------+
//| Queue one panel row                                              |
//+------------------------------------------------------------------+
void Row(const string text,const color clr,const int size=9)
  {
   if(g_rowCount>=PSP_MAX_ROWS) return;
   g_rowText[g_rowCount]=text;
   g_rowColor[g_rowCount]=clr;
   g_rowSize[g_rowCount]=size;
   g_rowCount++;
  }

//+------------------------------------------------------------------+
//| Draw queued rows as label objects                                |
//+------------------------------------------------------------------+
void RenderRows()
  {
   ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER;
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;
   bool lower=false;
   switch(InpPanelCorner)
     {
      case PSP_RIGHT_UPPER:
         corner=CORNER_RIGHT_UPPER;
         anchor=ANCHOR_RIGHT_UPPER;
         break;
      case PSP_LEFT_LOWER:
         corner=CORNER_LEFT_LOWER;
         anchor=ANCHOR_LEFT_LOWER;
         lower=true;
         break;
      case PSP_RIGHT_LOWER:
         corner=CORNER_RIGHT_LOWER;
         anchor=ANCHOR_RIGHT_LOWER;
         lower=true;
         break;
      default:
         break;
     }
   const int lh=16;
   for(int i=0; i<g_rowCount; i++)
     {
      string obj=PSP_PANEL_PREFIX+IntegerToString(i);
      if(ObjectFind(0,obj)<0)
         ObjectCreate(0,obj,OBJ_LABEL,0,0,0);
      int y=lower ? InpPanelY+(g_rowCount-1-i)*lh : InpPanelY+i*lh;
      ObjectSetInteger(0,obj,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,obj,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,obj,OBJPROP_XDISTANCE,InpPanelX);
      ObjectSetInteger(0,obj,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,obj,OBJPROP_COLOR,g_rowColor[i]);
      ObjectSetInteger(0,obj,OBJPROP_FONTSIZE,g_rowSize[i]);
      ObjectSetString(0,obj,OBJPROP_TEXT,g_rowText[i]);
      ObjectSetString(0,obj,OBJPROP_FONT,"Courier New");
      ObjectSetInteger(0,obj,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,obj,OBJPROP_HIDDEN,true);
     }
   for(int i=g_rowCount; i<g_rowsDrawn; i++)
      ObjectDelete(0,PSP_PANEL_PREFIX+IntegerToString(i));
   g_rowsDrawn=g_rowCount;
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Format points in the display unit                                |
//+------------------------------------------------------------------+
string Units(const double pts,const int decimals=1)
  {
   return DoubleToString(pts/g_unitPts,decimals)+" "+g_unitName;
  }

//+------------------------------------------------------------------+
//| Rebuild the panel                                                |
//+------------------------------------------------------------------+
void UpdatePanel(const bool haveQuotes,const double spreadPts,const double bid,const double ask,
                 const double mn,const double avg,const double med,const double mx,const double abovePct,
                 const double atr,const double atrPct)
  {
   g_rowCount=0;
   Row("== PropSpread v1.00 ==",g_colText,10);
   Row(StringFormat("%s  digits %d  %s",_Symbol,_Digits,g_unitLegend),g_colDim);

   if(!haveQuotes)
     {
      Row("WAITING FOR QUOTES",clrDarkOrange,10);
      RenderRows();
      return;
     }

   color nowCol=g_colText;
   if(InpAlertThreshold>0 && spreadPts>InpAlertThreshold) nowCol=clrRed;
   else if(avg>0 && spreadPts>2.0*avg) nowCol=clrDarkOrange;
   Row(StringFormat("Spread %.0f pts = %s  (%s)",spreadPts,Units(spreadPts,2),
       DoubleToString(spreadPts*_Point,_Digits)),nowCol,12);
   Row(StringFormat("bid %s  ask %s",DoubleToString(bid,_Digits),DoubleToString(ask,_Digits)),g_colDim);

   int winMin=MathMax(InpWindowMinutes,1);
   Row(StringFormat("-- Last %d min (n=%d/%d) --",winMin,g_count,g_cap),g_colDim);
   Row(StringFormat("min %.0f  avg %.1f  med %.1f  max %.0f pts",mn,avg,med,mx),g_colText);
   Row(StringFormat("       avg %s  max %s",Units(avg,2),Units(mx,2)),g_colDim);
   if(InpAlertThreshold>0)
      Row(StringFormat("above %.0f pts: %.1f%% of window",InpAlertThreshold,abovePct),
          abovePct>10 ? clrDarkOrange : g_colDim);

   Row("-- Session (server day) --",g_colDim);
   if(g_sesN>0)
     {
      Row(StringFormat("n=%I64d  avg %.1f  min %.0f  max %.0f pts",g_sesN,g_sesSum/g_sesN,g_sesMin,g_sesMax),g_colText);
      if(InpAlertThreshold>0)
         Row(StringFormat("above threshold: %.1f%% of session",100.0*g_sesAbove/g_sesN),g_colDim);
     }

   Row(StringFormat("-- ATR(%d, %s) --",MathMax(InpATRPeriod,1),EnumToString(InpATRTimeframe==PERIOD_CURRENT ? _Period : InpATRTimeframe)),g_colDim);
   if(atr>0)
     {
      color atrCol=(atrPct>=10) ? clrRed : (atrPct>=5 ? clrDarkOrange : g_colText);
      Row(StringFormat("ATR %s (%.0f pts)  spread = %.1f%% of ATR",DoubleToString(atr,_Digits),atr/_Point,atrPct),atrCol);
     }
   else
      Row("ATR not available (loading?)",g_colDim);

   Row("-- Alert --",g_colDim);
   if(InpAlertThreshold<=0)
      Row("off (set threshold in points)",g_colDim);
   else
     {
      string a=StringFormat("> %.0f pts for %d s | fired %dx",InpAlertThreshold,MathMax(InpAlertHoldSec,0),g_alertCount);
      if(g_lastAlert>0) a+="  last "+TimeToString(g_lastAlert,TIME_SECONDS);
      Row(a,g_aboveSec>0 ? clrDarkOrange : g_colDim);
     }

   if(InpLogCSV)
      Row(StringFormat("CSV: %s (%d rows)",g_logFile=="" ? "pending" : g_logFile,g_logRows),
          g_logErrorShown ? clrRed : g_colDim);
   RenderRows();
  }

//+------------------------------------------------------------------+
//| One sample per second: measure, aggregate, alert, log, draw      |
//+------------------------------------------------------------------+
void Sample()
  {
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double point=_Point;
   if(point<=0) point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(point<=0) point=0.00001;

   if(bid<=0 || ask<=0)
     {
      if(!g_noQuoteLogged) { Print("[PropSpread] No quotes yet for ",_Symbol); g_noQuoteLogged=true; }
         UpdatePanel(false,0,0,0,0,0,0,0,0,0,0);
      return;
     }

   double spreadPts=MathMax(ask-bid,0.0)/point;
   g_lastSpreadPts=spreadPts;
   PushSample(spreadPts);
   SessionUpdate(spreadPts);

   double mn,avg,med,mx,abovePct;
   WindowStats(mn,avg,med,mx,abovePct);

   double atr=CurrentATR();
   double atrPct=(atr>0) ? (spreadPts*point)/atr*100.0 : 0.0;

   CheckAlert(spreadPts,avg,atrPct);
   LogCSV(spreadPts,bid,ask,atr,atrPct);
   UpdatePanel(true,spreadPts,bid,ask,mn,avg,med,mx,abovePct,atr,atrPct);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   PickPanelColors();
   DeriveUnit();

   g_cap=MathMax(InpWindowMinutes,1)*60;
   if(g_cap>PSP_MAX_SAMPLES) g_cap=PSP_MAX_SAMPLES;
   ArrayResize(g_buf,g_cap);
   ArrayInitialize(g_buf,0.0);
   g_head=0; g_count=0;

   g_atrHandle=iATR(_Symbol,InpATRTimeframe,MathMax(InpATRPeriod,1));
   if(g_atrHandle==INVALID_HANDLE)
      Print("[PropSpread] ATR handle could not be created - ATR line shows 'not available'");

   EventSetTimer(1); // one sample per second, also on quiet charts

   PrintFormat("[PropSpread] Init | %s | digits=%d point=%s | %s | window=%d min (%d samples) | alert %s | csv=%s",
               _Symbol,_Digits,DoubleToString(_Point,_Digits),g_unitLegend,
               MathMax(InpWindowMinutes,1),g_cap,
               InpAlertThreshold>0 ? StringFormat("> %.0f pts for %d s",InpAlertThreshold,MathMax(InpAlertHoldSec,0)) : "off",
               InpLogCSV ? "on" : "off");
   Print("[PropSpread] Utility only - never sends orders.");

   Sample();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Sample();
  }

//+------------------------------------------------------------------+
//| Tick function                                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- sampling is time based (timer), so quiet and busy minutes weigh the same
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,PSP_PANEL_PREFIX);
   if(g_atrHandle!=INVALID_HANDLE)
     {
      IndicatorRelease(g_atrHandle);
      g_atrHandle=INVALID_HANDLE;
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
