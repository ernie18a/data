//+------------------------------------------------------------------+
//|          Quantora Multi-Timeframe RSI Dashboard MT5              |
//|             Professional Momentum Monitor v1.00                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional multi-timeframe RSI dashboard for MetaTrader 5."
#property description "Analyzes RSI across M1, M5, M15, M30, H1, H4 and D1."

input group "========== RSI SETTINGS =========="
input int    InpRSIPeriod       = 14;
input double InpOversoldLevel   = 30.0;
input double InpBearishLevel    = 45.0;
input double InpBullishLevel    = 55.0;
input double InpOverboughtLevel = 70.0;

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

string g_prefix="QMTRSI5_";
ENUM_TIMEFRAMES g_tf[TF_COUNT];
string g_tf_name[TF_COUNT];
int g_rsi_handle[TF_COUNT];
double g_rsi[TF_COUNT];
string g_state[TF_COUNT];

double g_average_rsi=0.0;
int g_overbought=0;
int g_bullish=0;
int g_neutral=0;
int g_bearish=0;
int g_oversold=0;
string g_bias="NEUTRAL";

double g_bid=0.0;
double g_ask=0.0;
double g_spread=0.0;

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
      g_rsi_handle[i]=INVALID_HANDLE;
      g_rsi[i]=0.0;
      g_state[i]="WAITING";
   }
}

string RSIState(double value)
{
   if(value<=0.0) return "WAITING";
   if(value>=InpOverboughtLevel) return "OVERBOUGHT";
   if(value>=InpBullishLevel) return "BULLISH";
   if(value>InpBearishLevel) return "NEUTRAL";
   if(value>InpOversoldLevel) return "BEARISH";
   return "OVERSOLD";
}

color StateColor(string state)
{
   if(state=="OVERBOUGHT") return Q_ORANGE;
   if(state=="BULLISH") return Q_GREEN;
   if(state=="NEUTRAL") return Q_YELLOW;
   if(state=="BEARISH") return Q_RED;
   if(state=="OVERSOLD") return Q_BLUE;
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

void CalculateSummary()
{
   g_overbought=0;
   g_bullish=0;
   g_neutral=0;
   g_bearish=0;
   g_oversold=0;

   double sum=0.0;
   int valid=0;

   for(int i=0;i<TF_COUNT;i++)
   {
      if(g_rsi[i]>0.0)
      {
         sum+=g_rsi[i];
         valid++;
      }

      if(g_state[i]=="OVERBOUGHT") g_overbought++;
      else if(g_state[i]=="BULLISH") g_bullish++;
      else if(g_state[i]=="NEUTRAL") g_neutral++;
      else if(g_state[i]=="BEARISH") g_bearish++;
      else if(g_state[i]=="OVERSOLD") g_oversold++;
   }

   g_average_rsi=(valid>0 ? sum/valid : 0.0);

   if(g_average_rsi>=65.0)
      g_bias="STRONG BULLISH";
   else if(g_average_rsi>=InpBullishLevel)
      g_bias="BULLISH";
   else if(g_average_rsi<=35.0 && g_average_rsi>0.0)
      g_bias="STRONG BEARISH";
   else if(g_average_rsi<=InpBearishLevel && g_average_rsi>0.0)
      g_bias="BEARISH";
   else
      g_bias="NEUTRAL";
}

void UpdateData()
{
   for(int i=0;i<TF_COUNT;i++)
   {
      double buf[1];
      if(CopyBuffer(g_rsi_handle[i],0,0,1,buf)==1)
      {
         g_rsi[i]=buf[0];
         g_state[i]=RSIState(g_rsi[i]);
      }
      else
      {
         g_rsi[i]=0.0;
         g_state[i]="WAITING";
      }
   }

   CalculateSummary();

   MqlTick tick;
   if(SymbolInfoTick(_Symbol,tick))
   {
      g_bid=tick.bid;
      g_ask=tick.ask;
      double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      g_spread=(point>0.0 ? (g_ask-g_bid)/point : 0.0);
   }
}

bool Rect(string n,int x,int y,int w,int h,color bg,color br)
{
   if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0)) return false;
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
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
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

   int x=InpPanelX, y=InpPanelY;
   Rect(g_prefix+"BG",x,y,620,610,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","MULTI-TIMEFRAME RSI DASHBOARD MT5",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","v1.00",x+550,y+18,9,Q_GRAY);

   Label(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+78,10,Q_WHITE);
   Label(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+360,y+78,10,Q_GRAY);

   Rect(g_prefix+"SEP1",x+18,y+112,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BIAS","MOMENTUM BIAS: NEUTRAL",x+18,y+136,13,Q_YELLOW,true);
   Label(g_prefix+"AVG","AVERAGE RSI: 0.00",x+390,y+136,11,Q_GOLD,true);

   Label(g_prefix+"COUNTS1","OVERBOUGHT: 0   BULLISH: 0   NEUTRAL: 0",x+18,y+174,9,Q_WHITE);
   Label(g_prefix+"COUNTS2","BEARISH: 0   OVERSOLD: 0",x+18,y+198,9,Q_WHITE);

   Rect(g_prefix+"SEP2",x+18,y+230,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"HDR_TF","TIMEFRAME",x+18,y+252,9,Q_GOLD,true);
   Label(g_prefix+"HDR_RSI","RSI VALUE",x+210,y+252,9,Q_GOLD,true);
   Label(g_prefix+"HDR_STATE","MOMENTUM STATE",x+400,y+252,9,Q_GOLD,true);

   int row=288;
   for(int i=0;i<TF_COUNT;i++)
   {
      string k=IntegerToString(i);
      Label(g_prefix+"TF_"+k,g_tf_name[i],x+18,y+row,10,Q_WHITE,true);
      Label(g_prefix+"RSI_"+k,"0.00",x+210,y+row,10,Q_WHITE);
      Label(g_prefix+"STATE_"+k,"WAITING",x+400,y+row,10,Q_GRAY,true);
      row+=38;
   }

   Rect(g_prefix+"SEP3",x+18,y+562,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BID","BID: 0",x+18,y+580,9,Q_GREEN);
   Label(g_prefix+"ASK","ASK: 0",x+190,y+580,9,Q_RED);
   Label(g_prefix+"FOOT","QUANTORA TRADING SOLUTIONS",x+380,y+580,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread,1)+" pts");

   ObjectSetString(0,g_prefix+"BIAS",OBJPROP_TEXT,"MOMENTUM BIAS: "+g_bias);
   ObjectSetInteger(0,g_prefix+"BIAS",OBJPROP_COLOR,BiasColor());

   ObjectSetString(0,g_prefix+"AVG",OBJPROP_TEXT,
                   "AVERAGE RSI: "+DoubleToString(g_average_rsi,2));

   ObjectSetString(0,g_prefix+"COUNTS1",OBJPROP_TEXT,
                   "OVERBOUGHT: "+IntegerToString(g_overbought)+
                   "   BULLISH: "+IntegerToString(g_bullish)+
                   "   NEUTRAL: "+IntegerToString(g_neutral));

   ObjectSetString(0,g_prefix+"COUNTS2",OBJPROP_TEXT,
                   "BEARISH: "+IntegerToString(g_bearish)+
                   "   OVERSOLD: "+IntegerToString(g_oversold));

   for(int i=0;i<TF_COUNT;i++)
   {
      string k=IntegerToString(i);
      ObjectSetString(0,g_prefix+"RSI_"+k,OBJPROP_TEXT,DoubleToString(g_rsi[i],2));
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
      g_rsi_handle[i]=iRSI(_Symbol,g_tf[i],InpRSIPeriod,PRICE_CLOSE);
      if(g_rsi_handle[i]==INVALID_HANDLE)
      {
         Print("Quantora MTF RSI Dashboard: RSI handle error on ",
               g_tf_name[i],". Error ",GetLastError());
         return false;
      }
   }
   return true;
}

void ReleaseHandles()
{
   for(int i=0;i<TF_COUNT;i++)
   {
      if(g_rsi_handle[i]!=INVALID_HANDLE)
      {
         IndicatorRelease(g_rsi_handle[i]);
         g_rsi_handle[i]=INVALID_HANDLE;
      }
   }
}

int OnInit()
{
   if(InpRSIPeriod<2 ||
      InpOversoldLevel<=0.0 ||
      InpBearishLevel<=InpOversoldLevel ||
      InpBullishLevel<=InpBearishLevel ||
      InpOverboughtLevel<=InpBullishLevel ||
      InpOverboughtLevel>=100.0 ||
      InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Multi-Timeframe RSI Dashboard MT5 v1.00");

   InitTimeframes();

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
      Print("Quantora MTF RSI Dashboard: EventSetTimer error ",GetLastError());
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
