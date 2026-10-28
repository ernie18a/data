//+------------------------------------------------------------------+
//|              Quantora Market Volatility Monitor MT5              |
//|            Professional Volatility Dashboard v1.00               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional market volatility monitor for MetaTrader 5."
#property description "Tracks ATR, ATR ratio, daily range, spread and volatility state."

input group "========== VOLATILITY SETTINGS =========="
input int    InpATRPeriod          = 14;
input int    InpATRLookback        = 50;
input double InpLowRatio           = 0.75;
input double InpHighRatio          = 1.25;
input double InpExtremeRatio       = 1.75;

input group "========== DASHBOARD =========="
input bool             InpShowPanel    = true;
input ENUM_BASE_CORNER InpPanelCorner  = CORNER_LEFT_UPPER;
input int              InpPanelX       = 15;
input int              InpPanelY       = 145;
input int              InpTimerSeconds = 1;

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

string g_prefix="QMVM5_";
int g_atr_handle=INVALID_HANDLE;

double g_atr=0.0;
double g_avg_atr=0.0;
double g_ratio=0.0;
double g_spread=0.0;
double g_day_high=0.0;
double g_day_low=0.0;
double g_day_range=0.0;
double g_range_atr_ratio=0.0;
double g_bid=0.0;
double g_ask=0.0;
string g_state="NORMAL";
string g_currency="";

color StateColor()
{
   if(g_state=="LOW") return Q_BLUE;
   if(g_state=="NORMAL") return Q_GREEN;
   if(g_state=="HIGH") return Q_ORANGE;
   if(g_state=="EXTREME") return Q_RED;
   return Q_GRAY;
}

void CalculateVolatility()
{
   MqlTick tick;
   if(SymbolInfoTick(_Symbol,tick))
   {
      g_bid=tick.bid;
      g_ask=tick.ask;
      double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      g_spread=(point>0.0 ? (g_ask-g_bid)/point : 0.0);
   }

   double atr[];
   ArraySetAsSeries(atr,true);
   int need=MathMax(InpATRLookback,2);

   if(CopyBuffer(g_atr_handle,0,0,need,atr)>0)
   {
      g_atr=atr[0];

      double sum=0.0;
      int count=0;
      int copied=ArraySize(atr);

      for(int i=1;i<copied && i<=InpATRLookback;i++)
      {
         if(atr[i]>0.0)
         {
            sum+=atr[i];
            count++;
         }
      }

      g_avg_atr=(count>0 ? sum/count : g_atr);
      g_ratio=(g_avg_atr>0.0 ? g_atr/g_avg_atr : 0.0);
   }

   MqlRates d1[1];
   ArraySetAsSeries(d1,true);
   if(CopyRates(_Symbol,PERIOD_D1,0,1,d1)==1)
   {
      g_day_high=d1[0].high;
      g_day_low=d1[0].low;
      g_day_range=MathMax(0.0,g_day_high-g_day_low);
      g_range_atr_ratio=(g_atr>0.0 ? g_day_range/g_atr : 0.0);
   }

   if(g_ratio>=InpExtremeRatio)
      g_state="EXTREME";
   else if(g_ratio>=InpHighRatio)
      g_state="HIGH";
   else if(g_ratio<InpLowRatio)
      g_state="LOW";
   else
      g_state="NORMAL";

   g_currency=AccountInfoString(ACCOUNT_CURRENCY);
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

bool Label(string n,string t,int x,int y,int s,color c,bool bold=false)
{
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,s);
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

   int x=InpPanelX,y=InpPanelY;
   Rect(g_prefix+"BG",x,y,570,500,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","MARKET VOLATILITY MONITOR MT5",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","v1.00",x+500,y+18,9,Q_GRAY);

   Label(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+78,10,Q_WHITE);
   Label(g_prefix+"TF","TIMEFRAME: "+EnumToString((ENUM_TIMEFRAMES)_Period),x+300,y+78,10,Q_WHITE);

   Label(g_prefix+"STATE","VOLATILITY: NORMAL",x+18,y+118,13,Q_GREEN,true);

   Rect(g_prefix+"SEP1",x+18,y+154,534,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"ATR","CURRENT ATR: 0",x+18,y+178,10,Q_WHITE);
   Label(g_prefix+"AVGATR","AVERAGE ATR: 0",x+300,y+178,10,Q_WHITE);
   Label(g_prefix+"RATIO","ATR RATIO: 0.00x",x+18,y+214,11,Q_GOLD,true);

   Label(g_prefix+"LOW","LOW < 0.75x",x+18,y+254,9,Q_BLUE);
   Label(g_prefix+"NORMAL","NORMAL",x+145,y+254,9,Q_GREEN);
   Label(g_prefix+"HIGH","HIGH >= 1.25x",x+260,y+254,9,Q_ORANGE);
   Label(g_prefix+"EXTREME","EXTREME >= 1.75x",x+410,y+254,9,Q_RED);

   Rect(g_prefix+"SEP2",x+18,y+288,534,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"MARKET","MARKET RANGE",x+18,y+310,10,Q_GOLD,true);
   Label(g_prefix+"HIGHV","DAILY HIGH: 0",x+18,y+346,10,Q_WHITE);
   Label(g_prefix+"LOWV","DAILY LOW: 0",x+300,y+346,10,Q_WHITE);
   Label(g_prefix+"RANGE","DAILY RANGE: 0",x+18,y+382,10,Q_WHITE);
   Label(g_prefix+"RATR","RANGE / ATR: 0.00x",x+300,y+382,10,Q_WHITE);

   Rect(g_prefix+"SEP3",x+18,y+416,534,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BID","BID: 0",x+18,y+438,9,Q_GRAY);
   Label(g_prefix+"ASK","ASK: 0",x+190,y+438,9,Q_GRAY);
   Label(g_prefix+"SPREAD","SPREAD: 0 pts",x+365,y+438,9,Q_GOLD);

   Label(g_prefix+"STATUS","STATUS: MONITORING",x+18,y+472,9,Q_GREEN);
   Label(g_prefix+"FOOT","QUANTORA TRADING SOLUTIONS",x+330,y+472,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   ObjectSetString(0,g_prefix+"STATE",OBJPROP_TEXT,"VOLATILITY: "+g_state);
   ObjectSetInteger(0,g_prefix+"STATE",OBJPROP_COLOR,StateColor());

   ObjectSetString(0,g_prefix+"ATR",OBJPROP_TEXT,
                   "CURRENT ATR: "+DoubleToString(g_atr,digits));
   ObjectSetString(0,g_prefix+"AVGATR",OBJPROP_TEXT,
                   "AVERAGE ATR: "+DoubleToString(g_avg_atr,digits));
   ObjectSetString(0,g_prefix+"RATIO",OBJPROP_TEXT,
                   "ATR RATIO: "+DoubleToString(g_ratio,2)+"x");

   ObjectSetString(0,g_prefix+"LOW",OBJPROP_TEXT,
                   "LOW < "+DoubleToString(InpLowRatio,2)+"x");
   ObjectSetString(0,g_prefix+"HIGH",OBJPROP_TEXT,
                   "HIGH >= "+DoubleToString(InpHighRatio,2)+"x");
   ObjectSetString(0,g_prefix+"EXTREME",OBJPROP_TEXT,
                   "EXTREME >= "+DoubleToString(InpExtremeRatio,2)+"x");

   ObjectSetString(0,g_prefix+"HIGHV",OBJPROP_TEXT,
                   "DAILY HIGH: "+DoubleToString(g_day_high,digits));
   ObjectSetString(0,g_prefix+"LOWV",OBJPROP_TEXT,
                   "DAILY LOW: "+DoubleToString(g_day_low,digits));
   ObjectSetString(0,g_prefix+"RANGE",OBJPROP_TEXT,
                   "DAILY RANGE: "+DoubleToString(g_day_range,digits));
   ObjectSetString(0,g_prefix+"RATR",OBJPROP_TEXT,
                   "RANGE / ATR: "+DoubleToString(g_range_atr_ratio,2)+"x");

   ObjectSetString(0,g_prefix+"BID",OBJPROP_TEXT,
                   "BID: "+DoubleToString(g_bid,digits));
   ObjectSetString(0,g_prefix+"ASK",OBJPROP_TEXT,
                   "ASK: "+DoubleToString(g_ask,digits));
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread,1)+" pts");

   ChartRedraw();
}

int OnInit()
{
   if(InpATRPeriod<2 ||
      InpATRLookback<2 ||
      InpLowRatio<=0.0 ||
      InpHighRatio<=InpLowRatio ||
      InpExtremeRatio<=InpHighRatio ||
      InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Market Volatility Monitor MT5 v1.00");

   g_atr_handle=iATR(_Symbol,(ENUM_TIMEFRAMES)_Period,InpATRPeriod);
   if(g_atr_handle==INVALID_HANDLE)
   {
      Print("Quantora Market Volatility Monitor: ATR handle error ",GetLastError());
      return INIT_FAILED;
   }

   BuildPanel();
   CalculateVolatility();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Market Volatility Monitor: EventSetTimer error ",GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();

   if(g_atr_handle!=INVALID_HANDLE)
   {
      IndicatorRelease(g_atr_handle);
      g_atr_handle=INVALID_HANDLE;
   }

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
   CalculateVolatility();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
