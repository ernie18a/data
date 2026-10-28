//+------------------------------------------------------------------+
//|               Quantora Moving Average Dashboard MT5              |
//|              Professional Trend Monitor v1.00                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional moving average dashboard for MetaTrader 5."
#property description "Monitors EMA/SMA alignment, price position and overall trend bias."

input group "========== MOVING AVERAGE SETTINGS =========="
input int InpEMA20Period   = 20;
input int InpEMA50Period   = 50;
input int InpEMA100Period  = 100;
input int InpEMA200Period  = 200;
input int InpSMA50Period   = 50;
input int InpSMA200Period  = 200;

input group "========== DASHBOARD =========="
input bool             InpShowPanel    = true;
input ENUM_BASE_CORNER InpPanelCorner  = CORNER_LEFT_UPPER;
input int              InpPanelX       = 15;
input int              InpPanelY       = 145;
input int              InpTimerSeconds = 2;

#define Q_BG      C'8,23,38'
#define Q_GOLD    C'212,175,55'
#define Q_WHITE   C'245,245,245'
#define Q_GRAY    C'169,176,184'
#define Q_GREEN   C'0,200,83'
#define Q_YELLOW  C'255,193,7'
#define Q_ORANGE  C'255,152,0'
#define Q_RED     C'255,82,82'
#define Q_BLUE    C'32,93,145'
#define Q_PURPLE  C'156,39,176'
#define Q_BORDER  C'62,76,89'

string g_prefix="QMAD5_";

int g_ema20_handle=INVALID_HANDLE;
int g_ema50_handle=INVALID_HANDLE;
int g_ema100_handle=INVALID_HANDLE;
int g_ema200_handle=INVALID_HANDLE;
int g_sma50_handle=INVALID_HANDLE;
int g_sma200_handle=INVALID_HANDLE;

double g_price=0.0;
double g_bid=0.0;
double g_ask=0.0;
double g_spread=0.0;

double g_ema20=0.0;
double g_ema50=0.0;
double g_ema100=0.0;
double g_ema200=0.0;
double g_sma50=0.0;
double g_sma200=0.0;

string g_price_vs_ema20="WAITING";
string g_price_vs_ema50="WAITING";
string g_price_vs_ema100="WAITING";
string g_price_vs_ema200="WAITING";
string g_ema_stack="WAITING";
string g_sma_stack="WAITING";
string g_short_trend="NEUTRAL";
string g_medium_trend="NEUTRAL";
string g_long_trend="NEUTRAL";
string g_bias="NEUTRAL";

int g_score=0;

string AboveBelow(double price,double ma)
{
   if(price<=0.0 || ma<=0.0) return "WAITING";
   if(price>ma) return "ABOVE";
   if(price<ma) return "BELOW";
   return "AT MA";
}

color RelationColor(string s)
{
   if(s=="ABOVE") return Q_GREEN;
   if(s=="BELOW") return Q_RED;
   if(s=="AT MA") return Q_YELLOW;
   return Q_GRAY;
}

color TrendColor(string s)
{
   if(s=="BULLISH" || s=="STRONG BULLISH") return Q_GREEN;
   if(s=="BEARISH" || s=="STRONG BEARISH") return Q_RED;
   return Q_YELLOW;
}

bool ReadMA(int handle,double &value)
{
   double buf[1];
   if(handle==INVALID_HANDLE) return false;
   if(CopyBuffer(handle,0,0,1,buf)!=1) return false;
   value=buf[0];
   return true;
}

void ClassifyTrends()
{
   g_score=0;

   // Short trend: Price, EMA20, EMA50
   if(g_price>g_ema20 && g_ema20>g_ema50)
   {
      g_short_trend="BULLISH";
      g_score++;
   }
   else if(g_price<g_ema20 && g_ema20<g_ema50)
   {
      g_short_trend="BEARISH";
      g_score--;
   }
   else
      g_short_trend="NEUTRAL";

   // Medium trend: EMA50, EMA100, EMA200
   if(g_ema50>g_ema100 && g_ema100>g_ema200)
   {
      g_medium_trend="BULLISH";
      g_score++;
   }
   else if(g_ema50<g_ema100 && g_ema100<g_ema200)
   {
      g_medium_trend="BEARISH";
      g_score--;
   }
   else
      g_medium_trend="NEUTRAL";

   // Long trend: Price and 200-period references
   if(g_price>g_ema200 && g_price>g_sma200 && g_sma50>g_sma200)
   {
      g_long_trend="BULLISH";
      g_score++;
   }
   else if(g_price<g_ema200 && g_price<g_sma200 && g_sma50<g_sma200)
   {
      g_long_trend="BEARISH";
      g_score--;
   }
   else
      g_long_trend="NEUTRAL";

   // EMA stack
   if(g_ema20>g_ema50 && g_ema50>g_ema100 && g_ema100>g_ema200)
   {
      g_ema_stack="BULLISH STACK";
      g_score++;
   }
   else if(g_ema20<g_ema50 && g_ema50<g_ema100 && g_ema100<g_ema200)
   {
      g_ema_stack="BEARISH STACK";
      g_score--;
   }
   else
      g_ema_stack="MIXED";

   // SMA stack
   if(g_sma50>g_sma200)
   {
      g_sma_stack="BULLISH";
      g_score++;
   }
   else if(g_sma50<g_sma200)
   {
      g_sma_stack="BEARISH";
      g_score--;
   }
   else
      g_sma_stack="NEUTRAL";

   if(g_score>=4)
      g_bias="STRONG BULLISH";
   else if(g_score>=2)
      g_bias="BULLISH";
   else if(g_score<=-4)
      g_bias="STRONG BEARISH";
   else if(g_score<=-2)
      g_bias="BEARISH";
   else
      g_bias="NEUTRAL";
}

void UpdateData()
{
   MqlTick tick;
   if(SymbolInfoTick(_Symbol,tick))
   {
      g_bid=tick.bid;
      g_ask=tick.ask;
      g_price=tick.bid;

      double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      g_spread=(point>0.0 ? (g_ask-g_bid)/point : 0.0);
   }

   ReadMA(g_ema20_handle,g_ema20);
   ReadMA(g_ema50_handle,g_ema50);
   ReadMA(g_ema100_handle,g_ema100);
   ReadMA(g_ema200_handle,g_ema200);
   ReadMA(g_sma50_handle,g_sma50);
   ReadMA(g_sma200_handle,g_sma200);

   g_price_vs_ema20=AboveBelow(g_price,g_ema20);
   g_price_vs_ema50=AboveBelow(g_price,g_ema50);
   g_price_vs_ema100=AboveBelow(g_price,g_ema100);
   g_price_vs_ema200=AboveBelow(g_price,g_ema200);

   ClassifyTrends();
}

bool Rect(string n,int x,int y,int w,int h,color bg,color br)
{
   if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,br);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   return true;
}

bool Label(string n,string t,int x,int y,int size,color clr,bool bold=false)
{
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,n,OBJPROP_FONT,bold ? "Arial Bold" : "Arial");
   ObjectSetString(0,n,OBJPROP_TEXT,t);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);

   return true;
}

void DeletePanel()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string n=ObjectName(0,i);
      if(StringFind(n,g_prefix)==0)
         ObjectDelete(0,n);
   }
}

void BuildPanel()
{
   if(!InpShowPanel) return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   Rect(g_prefix+"BG",x,y,650,590,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","MOVING AVERAGE DASHBOARD MT5",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","v1.00",x+580,y+18,9,Q_GRAY);

   Label(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+78,10,Q_WHITE);
   Label(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+390,y+78,10,Q_GRAY);

   Rect(g_prefix+"SEP1",x+18,y+112,614,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BIAS","OVERALL BIAS: NEUTRAL",x+18,y+136,13,Q_YELLOW,true);
   Label(g_prefix+"SCORE","MA SCORE: 0 / 5",x+440,y+136,11,Q_GOLD,true);

   Label(g_prefix+"SHORT","SHORT TREND: NEUTRAL",x+18,y+176,10,Q_WHITE,true);
   Label(g_prefix+"MEDIUM","MEDIUM TREND: NEUTRAL",x+220,y+176,10,Q_WHITE,true);
   Label(g_prefix+"LONG","LONG TREND: NEUTRAL",x+450,y+176,10,Q_WHITE,true);

   Rect(g_prefix+"SEP2",x+18,y+212,614,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"HDR_MA","MOVING AVERAGE",x+18,y+234,9,Q_GOLD,true);
   Label(g_prefix+"HDR_VAL","VALUE",x+240,y+234,9,Q_GOLD,true);
   Label(g_prefix+"HDR_REL","PRICE POSITION",x+430,y+234,9,Q_GOLD,true);

   Label(g_prefix+"EMA20N","EMA 20",x+18,y+270,10,Q_BLUE,true);
   Label(g_prefix+"EMA20V","0",x+240,y+270,10,Q_WHITE);
   Label(g_prefix+"EMA20R","WAITING",x+430,y+270,10,Q_GRAY,true);

   Label(g_prefix+"EMA50N","EMA 50",x+18,y+308,10,Q_BLUE,true);
   Label(g_prefix+"EMA50V","0",x+240,y+308,10,Q_WHITE);
   Label(g_prefix+"EMA50R","WAITING",x+430,y+308,10,Q_GRAY,true);

   Label(g_prefix+"EMA100N","EMA 100",x+18,y+346,10,Q_PURPLE,true);
   Label(g_prefix+"EMA100V","0",x+240,y+346,10,Q_WHITE);
   Label(g_prefix+"EMA100R","WAITING",x+430,y+346,10,Q_GRAY,true);

   Label(g_prefix+"EMA200N","EMA 200",x+18,y+384,10,Q_ORANGE,true);
   Label(g_prefix+"EMA200V","0",x+240,y+384,10,Q_WHITE);
   Label(g_prefix+"EMA200R","WAITING",x+430,y+384,10,Q_GRAY,true);

   Label(g_prefix+"SMA50N","SMA 50",x+18,y+422,10,Q_GREEN,true);
   Label(g_prefix+"SMA50V","0",x+240,y+422,10,Q_WHITE);
   Label(g_prefix+"SMA50R","REFERENCE",x+430,y+422,10,Q_GRAY,true);

   Label(g_prefix+"SMA200N","SMA 200",x+18,y+460,10,Q_RED,true);
   Label(g_prefix+"SMA200V","0",x+240,y+460,10,Q_WHITE);
   Label(g_prefix+"SMA200R","REFERENCE",x+430,y+460,10,Q_GRAY,true);

   Rect(g_prefix+"SEP3",x+18,y+498,614,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"EMASTACK","EMA STACK: WAITING",x+18,y+520,10,Q_GOLD,true);
   Label(g_prefix+"SMASTACK","SMA 50 / 200: WAITING",x+320,y+520,10,Q_GOLD,true);

   Label(g_prefix+"BID","BID: 0",x+18,y+554,9,Q_GREEN);
   Label(g_prefix+"ASK","ASK: 0",x+200,y+554,9,Q_RED);
   Label(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+380,y+554,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread,1)+" pts");

   ObjectSetString(0,g_prefix+"BIAS",OBJPROP_TEXT,"OVERALL BIAS: "+g_bias);
   ObjectSetInteger(0,g_prefix+"BIAS",OBJPROP_COLOR,TrendColor(g_bias));

   ObjectSetString(0,g_prefix+"SCORE",OBJPROP_TEXT,
                   "MA SCORE: "+IntegerToString(g_score)+" / 5");

   ObjectSetString(0,g_prefix+"SHORT",OBJPROP_TEXT,"SHORT TREND: "+g_short_trend);
   ObjectSetInteger(0,g_prefix+"SHORT",OBJPROP_COLOR,TrendColor(g_short_trend));

   ObjectSetString(0,g_prefix+"MEDIUM",OBJPROP_TEXT,"MEDIUM TREND: "+g_medium_trend);
   ObjectSetInteger(0,g_prefix+"MEDIUM",OBJPROP_COLOR,TrendColor(g_medium_trend));

   ObjectSetString(0,g_prefix+"LONG",OBJPROP_TEXT,"LONG TREND: "+g_long_trend);
   ObjectSetInteger(0,g_prefix+"LONG",OBJPROP_COLOR,TrendColor(g_long_trend));

   ObjectSetString(0,g_prefix+"EMA20V",OBJPROP_TEXT,DoubleToString(g_ema20,digits));
   ObjectSetString(0,g_prefix+"EMA50V",OBJPROP_TEXT,DoubleToString(g_ema50,digits));
   ObjectSetString(0,g_prefix+"EMA100V",OBJPROP_TEXT,DoubleToString(g_ema100,digits));
   ObjectSetString(0,g_prefix+"EMA200V",OBJPROP_TEXT,DoubleToString(g_ema200,digits));
   ObjectSetString(0,g_prefix+"SMA50V",OBJPROP_TEXT,DoubleToString(g_sma50,digits));
   ObjectSetString(0,g_prefix+"SMA200V",OBJPROP_TEXT,DoubleToString(g_sma200,digits));

   ObjectSetString(0,g_prefix+"EMA20R",OBJPROP_TEXT,g_price_vs_ema20);
   ObjectSetString(0,g_prefix+"EMA50R",OBJPROP_TEXT,g_price_vs_ema50);
   ObjectSetString(0,g_prefix+"EMA100R",OBJPROP_TEXT,g_price_vs_ema100);
   ObjectSetString(0,g_prefix+"EMA200R",OBJPROP_TEXT,g_price_vs_ema200);

   ObjectSetInteger(0,g_prefix+"EMA20R",OBJPROP_COLOR,RelationColor(g_price_vs_ema20));
   ObjectSetInteger(0,g_prefix+"EMA50R",OBJPROP_COLOR,RelationColor(g_price_vs_ema50));
   ObjectSetInteger(0,g_prefix+"EMA100R",OBJPROP_COLOR,RelationColor(g_price_vs_ema100));
   ObjectSetInteger(0,g_prefix+"EMA200R",OBJPROP_COLOR,RelationColor(g_price_vs_ema200));

   ObjectSetString(0,g_prefix+"EMASTACK",OBJPROP_TEXT,"EMA STACK: "+g_ema_stack);
   ObjectSetInteger(0,g_prefix+"EMASTACK",OBJPROP_COLOR,
                    StringFind(g_ema_stack,"BULLISH")>=0 ? Q_GREEN :
                    StringFind(g_ema_stack,"BEARISH")>=0 ? Q_RED : Q_YELLOW);

   ObjectSetString(0,g_prefix+"SMASTACK",OBJPROP_TEXT,"SMA 50 / 200: "+g_sma_stack);
   ObjectSetInteger(0,g_prefix+"SMASTACK",OBJPROP_COLOR,TrendColor(g_sma_stack));

   ObjectSetString(0,g_prefix+"BID",OBJPROP_TEXT,
                   "BID: "+DoubleToString(g_bid,digits));
   ObjectSetString(0,g_prefix+"ASK",OBJPROP_TEXT,
                   "ASK: "+DoubleToString(g_ask,digits));

   ChartRedraw();
}

bool CreateHandles()
{
   g_ema20_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpEMA20Period,0,MODE_EMA,PRICE_CLOSE);
   g_ema50_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpEMA50Period,0,MODE_EMA,PRICE_CLOSE);
   g_ema100_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpEMA100Period,0,MODE_EMA,PRICE_CLOSE);
   g_ema200_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpEMA200Period,0,MODE_EMA,PRICE_CLOSE);

   g_sma50_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpSMA50Period,0,MODE_SMA,PRICE_CLOSE);
   g_sma200_handle=iMA(_Symbol,(ENUM_TIMEFRAMES)_Period,InpSMA200Period,0,MODE_SMA,PRICE_CLOSE);

   if(g_ema20_handle==INVALID_HANDLE ||
      g_ema50_handle==INVALID_HANDLE ||
      g_ema100_handle==INVALID_HANDLE ||
      g_ema200_handle==INVALID_HANDLE ||
      g_sma50_handle==INVALID_HANDLE ||
      g_sma200_handle==INVALID_HANDLE)
   {
      Print("Quantora Moving Average Dashboard: MA handle creation error ",GetLastError());
      return false;
   }

   return true;
}

void ReleaseHandles()
{
   if(g_ema20_handle!=INVALID_HANDLE) IndicatorRelease(g_ema20_handle);
   if(g_ema50_handle!=INVALID_HANDLE) IndicatorRelease(g_ema50_handle);
   if(g_ema100_handle!=INVALID_HANDLE) IndicatorRelease(g_ema100_handle);
   if(g_ema200_handle!=INVALID_HANDLE) IndicatorRelease(g_ema200_handle);
   if(g_sma50_handle!=INVALID_HANDLE) IndicatorRelease(g_sma50_handle);
   if(g_sma200_handle!=INVALID_HANDLE) IndicatorRelease(g_sma200_handle);

   g_ema20_handle=INVALID_HANDLE;
   g_ema50_handle=INVALID_HANDLE;
   g_ema100_handle=INVALID_HANDLE;
   g_ema200_handle=INVALID_HANDLE;
   g_sma50_handle=INVALID_HANDLE;
   g_sma200_handle=INVALID_HANDLE;
}

int OnInit()
{
   if(InpEMA20Period<2 ||
      InpEMA50Period<=InpEMA20Period ||
      InpEMA100Period<=InpEMA50Period ||
      InpEMA200Period<=InpEMA100Period ||
      InpSMA50Period<2 ||
      InpSMA200Period<=InpSMA50Period ||
      InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Moving Average Dashboard MT5 v1.00");

   if(!CreateHandles())
   {
      ReleaseHandles();
      return INIT_FAILED;
   }

   BuildPanel();
   UpdateData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Moving Average Dashboard: EventSetTimer error ",GetLastError());
      ReleaseHandles();
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ReleaseHandles();
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
   return rates_total;
}

void OnTimer()
{
   UpdateData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
