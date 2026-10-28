//+------------------------------------------------------------------+
//|                  Quantora Candle Countdown MT5                   |
//|       Professional Trading Indicator for MetaTrader 5            |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional candle countdown indicator for MetaTrader 5."
#property description "Displays remaining candle time, progress and configurable alerts."

//============================== INPUTS =====================================
input group "========== COUNTDOWN SETTINGS =========="
input int                 InpTimerSeconds          = 1;

input group "========== ALERT SETTINGS =========="
input bool                InpEnableAlerts          = true;
input bool                InpAlertAt30Seconds      = true;
input bool                InpAlertAt10Seconds      = true;
input bool                InpAlertAt5Seconds       = true;
input bool                InpAlertOnNewCandle      = false;
input bool                InpPopupAlert            = true;
input bool                InpSoundAlert            = false;
input string              InpSoundFile             = "alert.wav";
input bool                InpPushNotification      = false;

input group "========== DASHBOARD =========="
input bool                InpShowPanel             = true;
input ENUM_BASE_CORNER    InpPanelCorner           = CORNER_LEFT_UPPER;
input int                 InpPanelX                = 15;
input int                 InpPanelY                = 145;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
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
string   g_prefix="QCC5_";
string   g_status="INITIALIZING";
string   g_market_status="UNKNOWN";

datetime g_candle_open=0;
datetime g_candle_close=0;
datetime g_last_candle_open=0;
datetime g_last_tick_time=0;

int      g_period_seconds=0;
int      g_elapsed_seconds=0;
int      g_remaining_seconds=0;
double   g_progress_pct=0.0;

bool     g_alert_enabled=true;
bool     g_alerted_30=false;
bool     g_alerted_10=false;
bool     g_alerted_5=false;
int      g_alert_count=0;

//============================== HELPERS ====================================
string TimeframeText()
  {
   string text=EnumToString((ENUM_TIMEFRAMES)_Period);
   StringReplace(text,"PERIOD_","");
   return text;
  }

string FormatDuration(int total_seconds)
  {
   total_seconds=MathMax(0,total_seconds);

   int days=total_seconds/86400;
   int hours=(total_seconds%86400)/3600;
   int minutes=(total_seconds%3600)/60;
   int seconds=total_seconds%60;

   if(days>0)
      return StringFormat("%dd %02d:%02d:%02d",days,hours,minutes,seconds);

   if(hours>0)
      return StringFormat("%02d:%02d:%02d",hours,minutes,seconds);

   return StringFormat("%02d:%02d",minutes,seconds);
  }

string FormatDateTime(datetime value)
  {
   if(value<=0)
      return "--";

   return TimeToString(value,TIME_DATE|TIME_SECONDS);
  }

color CountdownColor()
  {
   if(g_remaining_seconds<=5)
      return Q_RED;
   if(g_remaining_seconds<=10)
      return Q_ORANGE;
   if(g_remaining_seconds<=30)
      return Q_YELLOW;

   return Q_GOLD;
  }

bool IsTesterEnvironment()
  {
   return (bool)MQLInfoInteger(MQL_TESTER);
  }

void ResetCandleAlerts()
  {
   g_alerted_30=false;
   g_alerted_10=false;
   g_alerted_5=false;
  }

void SendCountdownAlert(const string event_text)
  {
   if(!InpEnableAlerts || !g_alert_enabled)
      return;

   g_alert_count++;

   // CodeBase/Strategy Tester ortamında harici bildirim oluşturma.
   if(IsTesterEnvironment())
      return;

   string message="Quantora Candle Countdown: "+_Symbol+" "+
                  TimeframeText()+" - "+event_text;

   if(InpPopupAlert)
      Alert(message);

   if(InpSoundAlert && StringLen(InpSoundFile)>0)
      PlaySound(InpSoundFile);

   if(InpPushNotification)
      SendNotification(message);
  }

void CheckCountdownAlerts()
  {
   if(!InpEnableAlerts || !g_alert_enabled)
      return;

   if(InpAlertAt30Seconds &&
      g_remaining_seconds<=30 &&
      g_remaining_seconds>10 &&
      !g_alerted_30)
     {
      g_alerted_30=true;
      SendCountdownAlert("30 seconds remaining");
     }

   if(InpAlertAt10Seconds &&
      g_remaining_seconds<=10 &&
      g_remaining_seconds>5 &&
      !g_alerted_10)
     {
      g_alerted_10=true;
      SendCountdownAlert("10 seconds remaining");
     }

   if(InpAlertAt5Seconds &&
      g_remaining_seconds<=5 &&
      g_remaining_seconds>0 &&
      !g_alerted_5)
     {
      g_alerted_5=true;
      SendCountdownAlert("5 seconds remaining");
     }
  }

void UpdateCountdown()
  {
   g_period_seconds=PeriodSeconds((ENUM_TIMEFRAMES)_Period);

   if(g_period_seconds<=0)
     {
      g_status="INVALID TIMEFRAME";
      return;
     }

   // CopyTime, test ortamında geçmiş yoksa güvenli biçimde başarısız olur.
   datetime candle_time[1];
   int copied=CopyTime(_Symbol,(ENUM_TIMEFRAMES)_Period,0,1,candle_time);

   if(copied!=1 || candle_time[0]<=0)
     {
      g_status="WAITING FOR HISTORY";
      g_market_status="NO HISTORY";
      g_candle_open=0;
      g_candle_close=0;
      g_elapsed_seconds=0;
      g_remaining_seconds=0;
      g_progress_pct=0.0;
      return;
     }

   datetime open_time=candle_time[0];

   if(g_last_candle_open>0 && open_time!=g_last_candle_open)
     {
      if(InpAlertOnNewCandle)
         SendCountdownAlert("New candle opened");

      ResetCandleAlerts();
     }

   g_last_candle_open=open_time;
   g_candle_open=open_time;
   g_candle_close=g_candle_open+g_period_seconds;

   datetime now=TimeCurrent();

   MqlTick tick;
   if(SymbolInfoTick(_Symbol,tick) && tick.time>0)
      g_last_tick_time=tick.time;

   g_elapsed_seconds=(int)(now-g_candle_open);
   g_elapsed_seconds=MathMax(0,MathMin(g_period_seconds,g_elapsed_seconds));

   g_remaining_seconds=(int)(g_candle_close-now);
   g_remaining_seconds=MathMax(0,g_remaining_seconds);

   g_progress_pct=
      (g_period_seconds>0
       ? 100.0*(double)g_elapsed_seconds/(double)g_period_seconds
       : 0.0);

   g_progress_pct=MathMax(0.0,MathMin(100.0,g_progress_pct));

   long trade_mode=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   bool recent_tick=(g_last_tick_time>0 && (now-g_last_tick_time)<=300);
   bool market_open=(trade_mode!=SYMBOL_TRADE_MODE_DISABLED && recent_tick);

   g_market_status=(market_open ? "MARKET OPEN" : "MARKET CLOSED");
   g_status=(market_open ? "COUNTDOWN ACTIVE" : "MARKET CLOSED");

   CheckCountdownAlerts();
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

//============================== DASHBOARD ==================================
void BuildPanel()
  {
   if(!InpShowPanel)
      return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   CreateRectangle(g_prefix+"BG",x,y,500,440,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","CANDLE COUNTDOWN",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5  v1.01",x+410,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+72,10,Q_GREEN,true);
   CreateLabel(g_prefix+"MARKET","MARKET: UNKNOWN",x+260,y+72,10,Q_GRAY,true);

   CreateLabel(g_prefix+"COUNTDOWN","00:00",x+150,y+104,28,Q_GOLD,true);
   CreateLabel(g_prefix+"CAPTION","TIME REMAINING",x+185,y+145,10,Q_GRAY,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+180,10,Q_WHITE);
   CreateLabel(g_prefix+"TF","TIMEFRAME: "+TimeframeText(),x+260,y+180,10,Q_WHITE);

   CreateLabel(g_prefix+"OPEN","CANDLE OPEN: --",x+18,y+210,10,Q_GRAY);
   CreateLabel(g_prefix+"CLOSE","CANDLE CLOSE: --",x+260,y+210,10,Q_GRAY);

   CreateLabel(g_prefix+"ELAPSED","ELAPSED: 00:00",x+18,y+240,10,Q_WHITE);
   CreateLabel(g_prefix+"REMAIN","REMAINING: 00:00",x+260,y+240,10,Q_WHITE);

   CreateLabel(g_prefix+"PROGRESS_TEXT","CANDLE PROGRESS: 0.0 %",
               x+18,y+276,10,Q_GOLD,true);

   CreateRectangle(g_prefix+"PROGRESS_BG",x+18,y+302,464,22,
                   C'5,14,24',Q_BORDER);
   CreateRectangle(g_prefix+"PROGRESS_FILL",x+20,y+304,1,18,
                   Q_GREEN,Q_GREEN);

   CreateLabel(g_prefix+"SERVER","SERVER TIME: --:--:--",x+18,y+338,10,Q_GRAY);
   CreateLabel(g_prefix+"ALERTS","ALERTS: 0",x+260,y+338,10,Q_GRAY);

   CreateButton(g_prefix+"RESET","RESET TIMER",x+18,y+372,225,38,Q_BLUE);
   CreateButton(g_prefix+"ALERT","DISABLE ALERTS",x+257,y+372,225,38,Q_RED);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",
               x+18,y+420,9,Q_GOLD);

   ChartRedraw();
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   color countdown_color=CountdownColor();
   color market_color=(g_market_status=="MARKET OPEN" ? Q_GREEN : Q_RED);
   color status_color=(g_status=="COUNTDOWN ACTIVE" ? Q_GREEN :
                       g_status=="WAITING FOR HISTORY" ? Q_YELLOW : Q_RED);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   string server_time=StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,status_color);

   ObjectSetString(0,g_prefix+"MARKET",OBJPROP_TEXT,"MARKET: "+g_market_status);
   ObjectSetInteger(0,g_prefix+"MARKET",OBJPROP_COLOR,market_color);

   ObjectSetString(0,g_prefix+"COUNTDOWN",OBJPROP_TEXT,
                   FormatDuration(g_remaining_seconds));
   ObjectSetInteger(0,g_prefix+"COUNTDOWN",OBJPROP_COLOR,countdown_color);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"TF",OBJPROP_TEXT,"TIMEFRAME: "+TimeframeText());

   ObjectSetString(0,g_prefix+"OPEN",OBJPROP_TEXT,
                   "CANDLE OPEN: "+FormatDateTime(g_candle_open));
   ObjectSetString(0,g_prefix+"CLOSE",OBJPROP_TEXT,
                   "CANDLE CLOSE: "+FormatDateTime(g_candle_close));

   ObjectSetString(0,g_prefix+"ELAPSED",OBJPROP_TEXT,
                   "ELAPSED: "+FormatDuration(g_elapsed_seconds));
   ObjectSetString(0,g_prefix+"REMAIN",OBJPROP_TEXT,
                   "REMAINING: "+FormatDuration(g_remaining_seconds));

   ObjectSetString(0,g_prefix+"PROGRESS_TEXT",OBJPROP_TEXT,
                   "CANDLE PROGRESS: "+DoubleToString(g_progress_pct,1)+" %");

   int fill_width=(int)MathRound(460.0*g_progress_pct/100.0);
   fill_width=MathMax(1,MathMin(460,fill_width));

   ObjectSetInteger(0,g_prefix+"PROGRESS_FILL",OBJPROP_XSIZE,fill_width);
   ObjectSetInteger(0,g_prefix+"PROGRESS_FILL",OBJPROP_BGCOLOR,countdown_color);
   ObjectSetInteger(0,g_prefix+"PROGRESS_FILL",OBJPROP_BORDER_COLOR,countdown_color);

   ObjectSetString(0,g_prefix+"SERVER",OBJPROP_TEXT,"SERVER TIME: "+server_time);
   ObjectSetString(0,g_prefix+"ALERTS",OBJPROP_TEXT,
                   "ALERTS: "+IntegerToString(g_alert_count));

   ObjectSetString(0,g_prefix+"ALERT",OBJPROP_TEXT,
                   g_alert_enabled ? "DISABLE ALERTS" : "ENABLE ALERTS");
   ObjectSetInteger(0,g_prefix+"ALERT",OBJPROP_BGCOLOR,
                    g_alert_enabled ? Q_RED : Q_GREEN);

   ChartRedraw();
  }

//============================== INDICATOR EVENTS ===========================
int OnInit()
  {
   if(InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Candle Countdown MT5 v1.01");

   g_alert_enabled=InpEnableAlerts;

   BuildPanel();
   UpdateCountdown();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
     {
      Print("Quantora Candle Countdown MT5: EventSetTimer failed. Error ",
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
   // Indicator does not calculate chart buffers.
   // time[0] confirms that chart history exists in tester and live terminal.
   if(rates_total>0 && time[0]>0)
      g_last_candle_open=time[0];

   return rates_total;
  }

void OnTimer()
  {
   UpdateCountdown();
   UpdatePanel();
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
      ResetCandleAlerts();
      g_alert_count=0;
      g_last_candle_open=0;
      UpdateCountdown();
      UpdatePanel();
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
