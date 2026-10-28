//+------------------------------------------------------------------+
//|                                      Quantora Spread Monitor MT5 |
//|           Professional Trading Utility for MetaTrader 5          |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.01"
#property strict
#property description "Professional live spread monitor for MetaTrader 5."
#property description "Displays current, minimum, maximum and average spread with alerts."

//============================== INPUTS =====================================
input group "========== MONITOR SETTINGS =========="
input bool                InpUseCurrentSymbol      = true;
input string              InpCustomSymbol         = "";
input int                 InpHistorySize          = 60;
input int                 InpTimerSeconds         = 1;

input group "========== QUALITY LEVELS (POINTS) =========="
input double              InpExcellentMax         = 10.0;
input double              InpLowMax               = 20.0;
input double              InpNormalMax            = 35.0;
input double              InpHighMax              = 60.0;

input group "========== ALERT SETTINGS =========="
input bool                InpEnableAlerts         = true;
input double              InpAlertSpreadPoints    = 50.0;
input bool                InpPopupAlert           = true;
input bool                InpSoundAlert           = false;
input string              InpSoundFile            = "alert.wav";
input bool                InpPushNotification     = false;
input int                 InpAlertCooldownSeconds = 60;

input group "========== DASHBOARD =========="
input bool                InpShowPanel            = true;
input ENUM_BASE_CORNER    InpPanelCorner          = CORNER_LEFT_UPPER;
input int                 InpPanelX               = 15;
input int                 InpPanelY               = 145;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
#define Q_GRAPH_BG C'5,14,24'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_ORANGE   C'255,152,0'
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'

//============================== STATE ======================================
string   g_prefix="QSM5_";
string   g_symbol="";
string   g_status="INITIALIZING";
string   g_quality="WAITING";

double   g_history[];
int      g_history_size=60;
int      g_sample_count=0;
int      g_write_index=0;

double   g_current=0.0;
double   g_minimum=0.0;
double   g_maximum=0.0;
double   g_average=0.0;

bool     g_alert_enabled=true;
datetime g_last_alert_time=0;
int      g_alert_count=0;
int      g_error_count=0;

//============================== SYMBOL HELPERS =============================
string SelectedSymbol()
  {
   if(InpUseCurrentSymbol || StringLen(InpCustomSymbol)==0)
      return _Symbol;

   return InpCustomSymbol;
  }

bool ReadSpreadPoints(const string symbol,double &spread)
  {
   MqlTick tick;
   if(!SymbolInfoTick(symbol,tick))
      return false;

   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0.0 || tick.ask<=0.0 || tick.bid<=0.0)
      return false;

   spread=(tick.ask-tick.bid)/point;
   return (spread>=0.0);
  }

string QualityText(const double spread)
  {
   if(spread<=InpExcellentMax)
      return "EXCELLENT";
   if(spread<=InpLowMax)
      return "LOW";
   if(spread<=InpNormalMax)
      return "NORMAL";
   if(spread<=InpHighMax)
      return "HIGH";

   return "EXTREME";
  }

color QualityColor(const string quality)
  {
   if(quality=="EXCELLENT" || quality=="LOW")
      return Q_GREEN;
   if(quality=="NORMAL")
      return Q_YELLOW;
   if(quality=="HIGH")
      return Q_ORANGE;

   return Q_RED;
  }

//============================== STATISTICS =================================
void ResetStatistics()
  {
   ArrayInitialize(g_history,0.0);

   g_sample_count=0;
   g_write_index=0;
   g_current=0.0;
   g_minimum=0.0;
   g_maximum=0.0;
   g_average=0.0;
   g_quality="WAITING";
   g_status="STATISTICS RESET";
  }

double HistoryValueChronological(const int position)
  {
   if(position<0 || position>=g_sample_count)
      return 0.0;

   int first_index=(g_sample_count<g_history_size ? 0 : g_write_index);
   int actual_index=(first_index+position)%g_history_size;

   return g_history[actual_index];
  }

void RecalculateStatistics()
  {
   if(g_sample_count<=0)
     {
      g_minimum=0.0;
      g_maximum=0.0;
      g_average=0.0;
      return;
     }

   double minimum=DBL_MAX;
   double maximum=0.0;
   double total=0.0;
   int valid_count=0;

   for(int i=0;i<g_sample_count;i++)
     {
      double value=HistoryValueChronological(i);
      if(value<0.0)
         continue;

      minimum=MathMin(minimum,value);
      maximum=MathMax(maximum,value);
      total+=value;
      valid_count++;
     }

   g_minimum=(minimum==DBL_MAX ? 0.0 : minimum);
   g_maximum=maximum;
   g_average=(valid_count>0 ? total/valid_count : 0.0);
  }

void AddSpreadSample(const double spread)
  {
   g_history[g_write_index]=spread;
   g_write_index=(g_write_index+1)%g_history_size;

   if(g_sample_count<g_history_size)
      g_sample_count++;

   g_current=spread;
   g_quality=QualityText(g_current);
   g_status="MONITORING";

   RecalculateStatistics();
  }

//============================== ALERTS =====================================
bool IsTesterEnvironment()
  {
   return (bool)MQLInfoInteger(MQL_TESTER);
  }

void CheckHighSpreadAlert()
  {
   if(!InpEnableAlerts || !g_alert_enabled)
      return;

   if(g_current<InpAlertSpreadPoints)
      return;

   datetime now=TimeCurrent();
   if(g_last_alert_time>0 &&
      (now-g_last_alert_time)<InpAlertCooldownSeconds)
      return;

   g_last_alert_time=now;
   g_alert_count++;
   g_status="HIGH SPREAD ALERT";

   // Do not open external alerts inside the Strategy Tester / CodeBase tester.
   if(IsTesterEnvironment())
      return;

   string message="Quantora Spread Monitor: High spread on "+
                  g_symbol+" = "+DoubleToString(g_current,1)+" points";

   if(InpPopupAlert)
      Alert(message);

   if(InpSoundAlert && StringLen(InpSoundFile)>0)
      PlaySound(InpSoundFile);

   if(InpPushNotification)
      SendNotification(message);
  }

//============================== OBJECT HELPERS =============================
bool CreateRectangle(const string name,const int x,const int y,
                     const int width,const int height,
                     const color background,const color border)
  {
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return true;
  }

bool CreateLabel(const string name,const string text,
                 const int x,const int y,const int font_size,
                 const color text_color,const bool bold=false)
  {
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,(bold ? "Arial Bold" : "Arial"));
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return true;
  }

bool CreateButton(const string name,const string text,
                  const int x,const int y,const int width,const int height,
                  const color background)
  {
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,Q_GOLD);
   ObjectSetInteger(0,name,OBJPROP_COLOR,Q_WHITE);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return true;
  }

void DeletePanel()
  {
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
     {
      string name=ObjectName(0,i);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
     }
  }

//============================== GRAPH ======================================
void CreateGraphBars(const int x,const int y,
                     const int width,const int height)
  {
   CreateRectangle(g_prefix+"GRAPH_BG",x,y,width,height,Q_GRAPH_BG,Q_BORDER);

   int bar_width=MathMax(2,width/g_history_size);

   for(int i=0;i<g_history_size;i++)
     {
      string name=g_prefix+"BAR_"+IntegerToString(i);

      CreateRectangle(name,
                      x+i*bar_width,
                      y+height-2,
                      MathMax(1,bar_width-1),
                      1,
                      Q_BORDER,
                      Q_BORDER);
     }
  }

void UpdateGraph(const int x,const int y,
                 const int width,const int height)
  {
   double scale_max=MathMax(g_maximum,InpAlertSpreadPoints);
   if(scale_max<=0.0)
      scale_max=1.0;

   int bar_width=MathMax(2,width/g_history_size);

   for(int i=0;i<g_history_size;i++)
     {
      string name=g_prefix+"BAR_"+IntegerToString(i);
      double value=(i<g_sample_count ? HistoryValueChronological(i) : 0.0);

      int bar_height=1;
      color bar_color=Q_BORDER;

      if(value>0.0)
        {
         bar_height=(int)MathRound((value/scale_max)*(height-8));
         bar_height=MathMax(1,MathMin(height-8,bar_height));
         bar_color=QualityColor(QualityText(value));
        }

      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x+i*bar_width);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y+height-bar_height-2);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,MathMax(1,bar_width-1));
      ObjectSetInteger(0,name,OBJPROP_YSIZE,bar_height);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bar_color);
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,bar_color);
     }
  }

//============================== DASHBOARD ==================================
void BuildPanel()
  {
   if(!InpShowPanel)
      return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;
   int w=520;
   int h=470;

   CreateRectangle(g_prefix+"BG",x,y,w,h,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","SPREAD MONITOR",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5  v1.01",x+430,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+72,10,Q_GREEN,true);
   CreateLabel(g_prefix+"SYMBOL","SYMBOL: "+SelectedSymbol(),x+270,y+72,10,Q_WHITE);

   CreateLabel(g_prefix+"CURRENT","CURRENT SPREAD: 0.0 points",
               x+18,y+110,12,Q_GOLD,true);
   CreateLabel(g_prefix+"QUALITY","QUALITY: WAITING",
               x+270,y+110,12,Q_GOLD,true);

   CreateLabel(g_prefix+"MIN","MINIMUM: 0.0",x+18,y+146,10,Q_GREEN);
   CreateLabel(g_prefix+"MAX","MAXIMUM: 0.0",x+180,y+146,10,Q_RED);
   CreateLabel(g_prefix+"AVG","AVERAGE: 0.0",x+350,y+146,10,Q_WHITE);

   CreateLabel(g_prefix+"DIGITS","DIGITS: 0",x+18,y+176,10,Q_GRAY);
   CreateLabel(g_prefix+"POINT","POINT: 0.00000",x+180,y+176,10,Q_GRAY);
   CreateLabel(g_prefix+"TIME","SERVER TIME: --:--:--",x+350,y+176,10,Q_GRAY);

   CreateLabel(g_prefix+"GRAPH_TITLE","LIVE SPREAD HISTORY",
               x+18,y+208,10,Q_GOLD,true);
   CreateGraphBars(x+18,y+232,484,120);

   CreateLabel(g_prefix+"ALERT_LEVEL","ALERT LEVEL: 0.0 points",
               x+18,y+370,10,Q_WHITE);
   CreateLabel(g_prefix+"ALERT_COUNT","ALERTS: 0",
               x+270,y+370,10,Q_GRAY);

   CreateButton(g_prefix+"RESET","RESET STATISTICS",
                x+18,y+402,225,38,Q_BLUE);
   CreateButton(g_prefix+"ALERT","DISABLE ALERTS",
                x+277,y+402,225,38,Q_RED);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",
               x+18,y+450,9,Q_GOLD);

   ChartRedraw();
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   int digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   double point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   string server_time=StringFormat("%02d:%02d:%02d",
                                   dt.hour,dt.min,dt.sec);

   color quality_color=QualityColor(g_quality);
   color status_color=(g_status=="HIGH SPREAD ALERT" ? Q_RED : Q_GREEN);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,status_color);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+g_symbol);

   ObjectSetString(0,g_prefix+"CURRENT",OBJPROP_TEXT,
                   "CURRENT SPREAD: "+DoubleToString(g_current,1)+" points");
   ObjectSetInteger(0,g_prefix+"CURRENT",OBJPROP_COLOR,quality_color);

   ObjectSetString(0,g_prefix+"QUALITY",OBJPROP_TEXT,
                   "QUALITY: "+g_quality);
   ObjectSetInteger(0,g_prefix+"QUALITY",OBJPROP_COLOR,quality_color);

   ObjectSetString(0,g_prefix+"MIN",OBJPROP_TEXT,
                   "MINIMUM: "+DoubleToString(g_minimum,1));
   ObjectSetString(0,g_prefix+"MAX",OBJPROP_TEXT,
                   "MAXIMUM: "+DoubleToString(g_maximum,1));
   ObjectSetString(0,g_prefix+"AVG",OBJPROP_TEXT,
                   "AVERAGE: "+DoubleToString(g_average,1));

   ObjectSetString(0,g_prefix+"DIGITS",OBJPROP_TEXT,
                   "DIGITS: "+IntegerToString(digits));
   ObjectSetString(0,g_prefix+"POINT",OBJPROP_TEXT,
                   "POINT: "+DoubleToString(point,digits));
   ObjectSetString(0,g_prefix+"TIME",OBJPROP_TEXT,
                   "SERVER TIME: "+server_time);

   ObjectSetString(0,g_prefix+"ALERT_LEVEL",OBJPROP_TEXT,
                   "ALERT LEVEL: "+DoubleToString(InpAlertSpreadPoints,1)+" points");
   ObjectSetString(0,g_prefix+"ALERT_COUNT",OBJPROP_TEXT,
                   "ALERTS: "+IntegerToString(g_alert_count));

   ObjectSetString(0,g_prefix+"ALERT",OBJPROP_TEXT,
                   g_alert_enabled ? "DISABLE ALERTS" : "ENABLE ALERTS");
   ObjectSetInteger(0,g_prefix+"ALERT",OBJPROP_BGCOLOR,
                    g_alert_enabled ? Q_RED : Q_GREEN);

   UpdateGraph(InpPanelX+18,InpPanelY+232,484,120);
   ChartRedraw();
  }

//============================== CORE =======================================
void ProcessSpread()
  {
   double spread=0.0;

   if(!ReadSpreadPoints(g_symbol,spread))
     {
      g_status="WAITING FOR TICKS";
      UpdatePanel();
      return;
     }

   AddSpreadSample(spread);
   CheckHighSpreadAlert();
   UpdatePanel();
  }

//============================== EVENTS =====================================
int OnInit()
  {
   if(InpHistorySize<20 || InpHistorySize>100 ||
      InpTimerSeconds<1 ||
      InpExcellentMax<0.0 ||
      InpLowMax<InpExcellentMax ||
      InpNormalMax<InpLowMax ||
      InpHighMax<InpNormalMax ||
      InpAlertSpreadPoints<=0.0 ||
      InpAlertCooldownSeconds<0)
     {
      Print("Quantora Spread Monitor MT5: Invalid input values.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
     {
      Print("Quantora Spread Monitor MT5: Symbol is not available: ",g_symbol);
      return INIT_FAILED;
     }

   g_history_size=InpHistorySize;
   ArrayResize(g_history,g_history_size);
   ArrayInitialize(g_history,0.0);

   g_alert_enabled=InpEnableAlerts;
   g_status="ACTIVE";

   BuildPanel();
   ProcessSpread();

   if(!EventSetTimer(InpTimerSeconds))
     {
      Print("Quantora Spread Monitor MT5: EventSetTimer failed. Error ",
            GetLastError());
      return INIT_FAILED;
     }

   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeletePanel();
  }

void OnTick()
  {
   // Spread sampling is timer-controlled to reduce CPU and object updates.
  }

void OnTimer()
  {
   ProcessSpread();
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam==g_prefix+"RESET")
     {
      ResetStatistics();
      ProcessSpread();
     }
   else if(sparam==g_prefix+"ALERT")
     {
      g_alert_enabled=!g_alert_enabled;
      g_status=(g_alert_enabled ? "ALERTS ENABLED" : "ALERTS DISABLED");
      UpdatePanel();
     }
  }

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
