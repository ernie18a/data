//+------------------------------------------------------------------+
//|          Quantora Multi-Timeframe Trend Dashboard MT5            |
//|              Professional MTF Trend Monitor v1.00                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional multi-timeframe trend dashboard for MetaTrader 5."
#property description "Analyzes M1 to D1 using EMA20, EMA50 and price position."

input group "========== TREND SETTINGS =========="
input int InpFastEMAPeriod = 20;
input int InpSlowEMAPeriod = 50;

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
#define Q_BORDER  C'62,76,89'

#define TF_COUNT 7

string g_prefix="QMTF5_";

ENUM_TIMEFRAMES g_tf[TF_COUNT];
string g_tf_name[TF_COUNT];
int g_fast_handle[TF_COUNT];
int g_slow_handle[TF_COUNT];

double g_fast[TF_COUNT];
double g_slow[TF_COUNT];
double g_close[TF_COUNT];
string g_state[TF_COUNT];

int g_score=0;
int g_bull_count=0;
int g_bear_count=0;
int g_neutral_count=0;
string g_bias="MIXED";

double g_bid=0.0;
double g_ask=0.0;
double g_spread_points=0.0;

void InitTimeframes()
{
   g_tf[0]=PERIOD_M1;  g_tf_name[0]="M1";
   g_tf[1]=PERIOD_M5;  g_tf_name[1]="M5";
   g_tf[2]=PERIOD_M15; g_tf_name[2]="M15";
   g_tf[3]=PERIOD_M30; g_tf_name[3]="M30";
   g_tf[4]=PERIOD_H1;  g_tf_name[4]="H1";
   g_tf[5]=PERIOD_H4;  g_tf_name[5]="H4";
   g_tf[6]=PERIOD_D1;  g_tf_name[6]="D1";

   for(int i=0;i<TF_COUNT;i++)
   {
      g_fast_handle[i]=INVALID_HANDLE;
      g_slow_handle[i]=INVALID_HANDLE;
      g_fast[i]=0.0;
      g_slow[i]=0.0;
      g_close[i]=0.0;
      g_state[i]="WAITING";
   }
}

string ClassifyTrend(double price,double fast,double slow)
{
   if(price<=0.0 || fast<=0.0 || slow<=0.0)
      return "WAITING";

   if(price>fast && fast>slow)
      return "BULLISH";

   if(price<fast && fast<slow)
      return "BEARISH";

   return "NEUTRAL";
}

color StateColor(string state)
{
   if(state=="BULLISH") return Q_GREEN;
   if(state=="BEARISH") return Q_RED;
   if(state=="NEUTRAL") return Q_YELLOW;
   return Q_GRAY;
}

color BiasColor()
{
   if(g_bias=="STRONG BULLISH") return Q_GREEN;
   if(g_bias=="BULLISH") return Q_GREEN;
   if(g_bias=="STRONG BEARISH") return Q_RED;
   if(g_bias=="BEARISH") return Q_RED;
   return Q_YELLOW;
}

void UpdateBias()
{
   g_score=0;
   g_bull_count=0;
   g_bear_count=0;
   g_neutral_count=0;

   for(int i=0;i<TF_COUNT;i++)
   {
      if(g_state[i]=="BULLISH")
      {
         g_score++;
         g_bull_count++;
      }
      else if(g_state[i]=="BEARISH")
      {
         g_score--;
         g_bear_count++;
      }
      else
      {
         g_neutral_count++;
      }
   }

   if(g_score>=5)
      g_bias="STRONG BULLISH";
   else if(g_score>=2)
      g_bias="BULLISH";
   else if(g_score<=-5)
      g_bias="STRONG BEARISH";
   else if(g_score<=-2)
      g_bias="BEARISH";
   else
      g_bias="MIXED";
}

void UpdateMarketData()
{
   MqlTick tick;
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   if(SymbolInfoTick(_Symbol,tick))
   {
      g_bid=tick.bid;
      g_ask=tick.ask;
      g_spread_points=(point>0.0 ? (g_ask-g_bid)/point : 0.0);
   }
}

void UpdateTrendData()
{
   for(int i=0;i<TF_COUNT;i++)
   {
      double fast_buf[1];
      double slow_buf[1];
      double close_buf[1];

      bool ok_fast=(CopyBuffer(g_fast_handle[i],0,0,1,fast_buf)==1);
      bool ok_slow=(CopyBuffer(g_slow_handle[i],0,0,1,slow_buf)==1);
      bool ok_close=(CopyClose(_Symbol,g_tf[i],0,1,close_buf)==1);

      if(ok_fast && ok_slow && ok_close)
      {
         g_fast[i]=fast_buf[0];
         g_slow[i]=slow_buf[0];
         g_close[i]=close_buf[0];
         g_state[i]=ClassifyTrend(g_close[i],g_fast[i],g_slow[i]);
      }
      else
      {
         g_state[i]="WAITING";
      }
   }

   UpdateBias();
   UpdateMarketData();
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

   Rect(g_prefix+"BG",x,y,640,610,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","MULTI-TIMEFRAME TREND DASHBOARD MT5",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","v1.00",x+570,y+18,9,Q_GRAY);

   Label(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+78,10,Q_WHITE);
   Label(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+370,y+78,10,Q_GRAY);

   Rect(g_prefix+"SEP1",x+18,y+112,604,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BIAS","OVERALL BIAS: MIXED",x+18,y+136,13,Q_YELLOW,true);
   Label(g_prefix+"SCORE","TREND SCORE: 0",x+390,y+136,11,Q_GOLD,true);

   Label(g_prefix+"COUNTS","BULL: 0   BEAR: 0   NEUTRAL: 0",x+18,y+174,10,Q_WHITE);

   Rect(g_prefix+"SEP2",x+18,y+208,604,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"HDR_TF","TIMEFRAME",x+18,y+230,9,Q_GOLD,true);
   Label(g_prefix+"HDR_PRICE","PRICE",x+130,y+230,9,Q_GOLD,true);
   Label(g_prefix+"HDR_FAST","EMA "+IntegerToString(InpFastEMAPeriod),x+280,y+230,9,Q_GOLD,true);
   Label(g_prefix+"HDR_SLOW","EMA "+IntegerToString(InpSlowEMAPeriod),x+410,y+230,9,Q_GOLD,true);
   Label(g_prefix+"HDR_STATE","TREND",x+535,y+230,9,Q_GOLD,true);

   int row_y=266;

   for(int i=0;i<TF_COUNT;i++)
   {
      string k=IntegerToString(i);

      Label(g_prefix+"TF_"+k,g_tf_name[i],x+18,y+row_y,10,Q_WHITE,true);
      Label(g_prefix+"PRICE_"+k,"0",x+130,y+row_y,10,Q_WHITE);
      Label(g_prefix+"FAST_"+k,"0",x+280,y+row_y,10,Q_BLUE);
      Label(g_prefix+"SLOW_"+k,"0",x+410,y+row_y,10,Q_ORANGE);
      Label(g_prefix+"STATE_"+k,"WAITING",x+535,y+row_y,10,Q_GRAY,true);

      row_y+=42;
   }

   Rect(g_prefix+"SEP3",x+18,y+566,604,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BID","BID: 0",x+18,y+584,9,Q_GREEN);
   Label(g_prefix+"ASK","ASK: 0",x+210,y+584,9,Q_RED);
   Label(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+390,y+584,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread_points,1)+" pts");

   ObjectSetString(0,g_prefix+"BIAS",OBJPROP_TEXT,"OVERALL BIAS: "+g_bias);
   ObjectSetInteger(0,g_prefix+"BIAS",OBJPROP_COLOR,BiasColor());

   ObjectSetString(0,g_prefix+"SCORE",OBJPROP_TEXT,
                   "TREND SCORE: "+IntegerToString(g_score));

   ObjectSetString(0,g_prefix+"COUNTS",OBJPROP_TEXT,
                   "BULL: "+IntegerToString(g_bull_count)+
                   "   BEAR: "+IntegerToString(g_bear_count)+
                   "   NEUTRAL: "+IntegerToString(g_neutral_count));

   for(int i=0;i<TF_COUNT;i++)
   {
      string k=IntegerToString(i);

      ObjectSetString(0,g_prefix+"PRICE_"+k,OBJPROP_TEXT,
                      DoubleToString(g_close[i],digits));
      ObjectSetString(0,g_prefix+"FAST_"+k,OBJPROP_TEXT,
                      DoubleToString(g_fast[i],digits));
      ObjectSetString(0,g_prefix+"SLOW_"+k,OBJPROP_TEXT,
                      DoubleToString(g_slow[i],digits));

      ObjectSetString(0,g_prefix+"STATE_"+k,OBJPROP_TEXT,g_state[i]);
      ObjectSetInteger(0,g_prefix+"STATE_"+k,OBJPROP_COLOR,StateColor(g_state[i]));
   }

   ObjectSetString(0,g_prefix+"BID",OBJPROP_TEXT,
                   "BID: "+DoubleToString(g_bid,digits));
   ObjectSetString(0,g_prefix+"ASK",OBJPROP_TEXT,
                   "ASK: "+DoubleToString(g_ask,digits));

   ChartRedraw();
}

bool CreateHandles()
{
   for(int i=0;i<TF_COUNT;i++)
   {
      g_fast_handle[i]=iMA(_Symbol,g_tf[i],InpFastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
      g_slow_handle[i]=iMA(_Symbol,g_tf[i],InpSlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);

      if(g_fast_handle[i]==INVALID_HANDLE || g_slow_handle[i]==INVALID_HANDLE)
      {
         Print("Quantora MTF Trend Dashboard: MA handle error on ",g_tf_name[i],
               ". Error ",GetLastError());
         return false;
      }
   }

   return true;
}

void ReleaseHandles()
{
   for(int i=0;i<TF_COUNT;i++)
   {
      if(g_fast_handle[i]!=INVALID_HANDLE)
      {
         IndicatorRelease(g_fast_handle[i]);
         g_fast_handle[i]=INVALID_HANDLE;
      }

      if(g_slow_handle[i]!=INVALID_HANDLE)
      {
         IndicatorRelease(g_slow_handle[i]);
         g_slow_handle[i]=INVALID_HANDLE;
      }
   }
}

int OnInit()
{
   if(InpFastEMAPeriod<2 ||
      InpSlowEMAPeriod<=InpFastEMAPeriod ||
      InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Multi-Timeframe Trend Dashboard MT5 v1.00");

   InitTimeframes();

   if(!CreateHandles())
   {
      ReleaseHandles();
      return INIT_FAILED;
   }

   BuildPanel();
   UpdateTrendData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora MTF Trend Dashboard: EventSetTimer error ",GetLastError());
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
   UpdateTrendData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
